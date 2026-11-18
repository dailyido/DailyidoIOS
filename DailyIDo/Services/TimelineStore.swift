import Foundation
import SwiftUI
import CoreLocation

/// Owns the couple's Timeline Builder answers and edits, keeps the generated
/// timelines up to date, and persists everything locally (source of truth for
/// the session) and to the `wedding_timelines` Supabase table.
@MainActor
final class TimelineStore: ObservableObject {
    static let shared = TimelineStore()

    @Published private(set) var questionnaire = TimelineQuestionnaire()
    @Published private(set) var overrides: TimelineOverrides = [:]
    @Published private(set) var results: [FirstLookBranch: TimelineResult] = [:]
    @Published private(set) var sunset: TimeOfDay?
    @Published private(set) var isLoaded = false

    private var updatedAt = Date.distantPast
    private var remoteSaveTask: Task<Void, Never>?
    private let storageKey = "weddingTimeline.v1"
    private let supabase = SupabaseService.shared

    private init() {}

    /// True once the couple has answered anything beyond what onboarding
    /// prefilled. (The cached venue time zone doesn't count as an answer.)
    var hasStarted: Bool {
        if questionnaire.completedAt != nil { return true }
        var answers = questionnaire
        answers.ceremonyTimeZoneId = nil
        return answers != Self.prefilled()
    }
    var isBuilt: Bool { questionnaire.completedAt != nil }

    // MARK: - Loading

    func load() async {
        guard !isLoaded else { return }
        if let stored = loadLocal() {
            apply(stored)
        } else {
            questionnaire = Self.prefilled()
        }
        isLoaded = true
        regenerate()
        await refreshSunset()
        await syncFromRemote()
    }

    /// Answers we already know from onboarding: date, names, location.
    private static func prefilled() -> TimelineQuestionnaire {
        var q = TimelineQuestionnaire()
        guard let user = AuthService.shared.currentUser else { return q }
        if let date = user.weddingDate, !user.doesntKnowDate {
            q.weddingDate = TimelineDate.string(fromLocal: date)
        }
        q.partners[0].name = user.name ?? ""
        q.partners[1].name = user.partnerName ?? ""
        if !user.doesntKnowLocation {
            q.ceremonyVenue = user.weddingVenue
            q.ceremonyCity = user.weddingTown
            q.ceremonyLatitude = user.weddingLatitude
            q.ceremonyLongitude = user.weddingLongitude
            q.ceremonyTimeZoneId = nil
        }
        return q
    }

    // MARK: - Answering questions

    func update(_ change: (inout TimelineQuestionnaire) -> Void) {
        var updated = questionnaire
        change(&updated)
        guard updated != questionnaire else { return }

        let placeChanged = updated.ceremonyLatitude != questionnaire.ceremonyLatitude
            || updated.ceremonyLongitude != questionnaire.ceremonyLongitude
        let dateChanged = updated.weddingDate != questionnaire.weddingDate
        if placeChanged { updated.ceremonyTimeZoneId = nil }

        questionnaire = updated
        touch()
        regenerate()
        if placeChanged || dateChanged {
            Task { await refreshSunset() }
        }
    }

    func binding<Value>(_ keyPath: WritableKeyPath<TimelineQuestionnaire, Value>) -> Binding<Value> {
        Binding(
            get: { self.questionnaire[keyPath: keyPath] },
            set: { value in self.update { $0[keyPath: keyPath] = value } }
        )
    }

    func partnerBinding<Value>(_ index: Int, _ keyPath: WritableKeyPath<TimelinePartner, Value>) -> Binding<Value> {
        Binding(
            get: { self.questionnaire.partners[index][keyPath: keyPath] },
            set: { value in self.update { $0.partners[index][keyPath: keyPath] = value } }
        )
    }

    /// Called when the couple taps "Build my timeline".
    func markBuilt() {
        let firstTime = questionnaire.completedAt == nil
        update { $0.completedAt = $0.completedAt ?? Date() }
        if firstTime {
            AnalyticsService.shared.logTimelineQuestionnaireCompleted(firstLook: questionnaire.firstLook?.rawValue)
        }
        AnalyticsService.shared.logTimelineGenerated(branches: questionnaire.branches.map(\.rawValue))
    }

    /// From the compare view: keep one version of the day.
    func chooseBranch(_ branch: FirstLookBranch) {
        update { $0.firstLook = branch == .firstLook ? .yes : .no }
        AnalyticsService.shared.logTimelineFirstLookChosen(branch.rawValue)
    }

    func startOver() {
        questionnaire = Self.prefilled()
        overrides = [:]
        touch()
        regenerate()
        Task { await refreshSunset() }
    }

    // MARK: - Editing the timeline

    func setTime(_ time: TimeOfDay, for itemId: String) {
        editOverride(itemId) { $0.time = time }
        AnalyticsService.shared.logTimelineEdited(action: "time", itemId: itemId)
    }

    func resetTime(for itemId: String) {
        editOverride(itemId) { $0.time = nil }
        AnalyticsService.shared.logTimelineEdited(action: "reset", itemId: itemId)
    }

    func setHidden(_ hidden: Bool, for itemId: String) {
        editOverride(itemId) { $0.isHidden = hidden ? true : nil }
        AnalyticsService.shared.logTimelineEdited(action: hidden ? "hide" : "restore", itemId: itemId)
    }

    /// Saves a new order for one sequence of moments.
    func saveOrder(_ orderedIds: [String]) {
        var updated = overrides
        for (index, id) in orderedIds.enumerated() {
            var override = updated[id] ?? TimelineOverride()
            override.order = index
            updated[id] = override
        }
        overrides = updated
        touch()
        regenerate()
        AnalyticsService.shared.logTimelineEdited(action: "reorder", itemId: orderedIds.first ?? "")
    }

    func resetOrder(_ sequence: TimelineSequence) {
        var updated = overrides
        for entry in sequence.entries {
            updated[entry.id]?.order = nil
            if updated[entry.id]?.isEmpty == true { updated[entry.id] = nil }
        }
        overrides = updated
        touch()
        regenerate()
    }

    private func editOverride(_ itemId: String, _ change: (inout TimelineOverride) -> Void) {
        var override = overrides[itemId] ?? TimelineOverride()
        change(&override)
        overrides[itemId] = override.isEmpty ? nil : override
        touch()
        regenerate()
    }

    // MARK: - Generating

    private func regenerate() {
        var updated: [FirstLookBranch: TimelineResult] = [:]
        for branch in questionnaire.branches {
            updated[branch] = TimelineEngine.generate(questionnaire, branch: branch, sunset: sunset, overrides: overrides)
        }
        results = updated
    }

    /// Sunset for the wedding date at the ceremony location, as a wall-clock
    /// time in the venue's time zone.
    func refreshSunset() async {
        guard let dateString = questionnaire.weddingDate,
              let date = TimelineDate.date(from: dateString),
              let latitude = questionnaire.ceremonyLatitude,
              let longitude = questionnaire.ceremonyLongitude,
              let instant = SunsetService.shared.calculateSunset(for: date, latitude: latitude, longitude: longitude) else {
            if sunset != nil {
                sunset = nil
                regenerate()
            }
            return
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = await venueTimeZone(latitude: latitude, longitude: longitude)
        let parts = calendar.dateComponents([.hour, .minute], from: instant)
        let resolved = TimeOfDay(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
        if resolved != sunset {
            sunset = resolved
            regenerate()
        }
    }

    private func venueTimeZone(latitude: Double, longitude: Double) async -> TimeZone {
        if let id = questionnaire.ceremonyTimeZoneId, let zone = TimeZone(identifier: id) {
            return zone
        }
        if let placemark = try? await CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)).first,
           let zone = placemark.timeZone {
            // Cache it without counting as an edit.
            questionnaire.ceremonyTimeZoneId = zone.identifier
            saveLocal()
            return zone
        }
        if let id = AuthService.shared.currentUser?.timezone, let zone = TimeZone(identifier: id) {
            return zone
        }
        return .current
    }

    // MARK: - Persistence

    private struct StoredTimeline: Codable {
        var questionnaire: TimelineQuestionnaire
        var overrides: TimelineOverrides
        var updatedAt: Date
    }

    private struct WeddingTimelineRow: Codable {
        let userId: UUID
        let questionnaire: TimelineQuestionnaire
        let overrides: TimelineOverrides
        let firstLookChoice: String?
        let updatedAt: Date

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case questionnaire
            case overrides
            case firstLookChoice = "first_look_choice"
            case updatedAt = "updated_at"
        }
    }

    private func apply(_ stored: StoredTimeline) {
        questionnaire = stored.questionnaire
        overrides = stored.overrides
        updatedAt = stored.updatedAt
    }

    private func touch() {
        updatedAt = Date()
        saveLocal()
        scheduleRemoteSave()
    }

    private func loadLocal() -> StoredTimeline? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(StoredTimeline.self, from: data)
    }

    private func saveLocal() {
        let stored = StoredTimeline(questionnaire: questionnaire, overrides: overrides, updatedAt: updatedAt)
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    /// Debounced so typing a name doesn't send a request per keystroke.
    private func scheduleRemoteSave() {
        remoteSaveTask?.cancel()
        remoteSaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }
            await self?.saveRemote()
        }
    }

    private func saveRemote() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        let row = WeddingTimelineRow(
            userId: userId, questionnaire: questionnaire, overrides: overrides,
            firstLookChoice: questionnaire.firstLook?.rawValue, updatedAt: updatedAt)
        do {
            try await supabase.client
                .from("wedding_timelines")
                .upsert(row, onConflict: "user_id")
                .execute()
        } catch {
            print("⚠️ [Timeline] Remote save failed: \(error)")
        }
    }

    /// Takes the server copy if it's newer (e.g. after reinstalling the app).
    private func syncFromRemote() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        do {
            let rows: [WeddingTimelineRow] = try await supabase.client
                .from("wedding_timelines")
                .select()
                .eq("user_id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value
            guard let row = rows.first, row.updatedAt > updatedAt else { return }
            apply(StoredTimeline(questionnaire: row.questionnaire, overrides: row.overrides, updatedAt: row.updatedAt))
            saveLocal()
            regenerate()
            await refreshSunset()
        } catch {
            print("⚠️ [Timeline] Remote load failed: \(error)")
        }
    }
}
