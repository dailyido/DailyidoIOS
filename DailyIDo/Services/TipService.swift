import Foundation

final class TipService: ObservableObject {
    static let shared = TipService()

    @Published var tips: [Tip] = []
    @Published var funTips: [FunTip] = []
    @Published var criticalTips: [Tip] = []  // First 50 tips for long engagements
    @Published var isLoading = true

    private let supabase = SupabaseService.shared

    // Cache for fun tips shown to user (to avoid repeated DB calls)
    private var userShownFunTipIds: Set<UUID> = []
    private var lastShownFunTipCategory: String?

    // CONFIGURABLE: Change this when you finalize the exact day count
    // Users with more days until wedding than this threshold use long engagement logic
    private let longEngagementThreshold = 420

    // BYPASS FLAG: Set to true to disable all fun tips logic and use only wedding_tips
    // This allows testing while fun_tips database tables are being set up
    // TODO: Remove this flag once fun_tips is fully tested
    private let bypassFunTipsLogic = false

    private init() {}

    func loadTips() async throws {
        let fetchedTips = try await supabase.fetchAllTips()

        // Load random illustrations for tips without their own
        await RandomIllustrationService.shared.loadRandomIllustrations()

        // BYPASS: Skip fun tips loading entirely when bypassing
        if bypassFunTipsLogic {
            await MainActor.run {
                self.tips = fetchedTips
                self.isLoading = false
            }
            return
        }

        // Fun tips are optional - tables may not exist yet
        // Fail gracefully so regular tips still work
        var fetchedFunTips: [FunTip] = []
        var fetchedCriticalTips: [Tip] = []

        do {
            fetchedFunTips = try await supabase.fetchAllFunTips()
        } catch {
            print("⚠️ Fun tips table not available yet: \(error.localizedDescription)")
        }

        do {
            fetchedCriticalTips = try await supabase.fetchFirst50CriticalTips()
        } catch {
            print("⚠️ Could not fetch critical tips: \(error.localizedDescription)")
        }

        await MainActor.run {
            self.tips = fetchedTips
            self.funTips = fetchedFunTips
            self.criticalTips = fetchedCriticalTips
            self.isLoading = false
        }
    }

    /// Load user's fun tip history for smart selection
    func loadUserFunTipHistory(userId: UUID) async {
        // BYPASS: Skip loading fun tip history when bypassing
        if bypassFunTipsLogic {
            return
        }

        do {
            let shownIds = try await supabase.fetchUserShownFunTipIds(userId: userId)
            let lastCategory = try await supabase.fetchLastShownFunTipCategory(userId: userId)

            await MainActor.run {
                self.userShownFunTipIds = Set(shownIds)
                self.lastShownFunTipCategory = lastCategory
            }
        } catch {
            print("Error loading fun tip history: \(error)")
        }
    }

    // MARK: - Main Tip Selection Logic

    /// Get the appropriate tip for the given day
    /// This is the main entry point that handles both long and normal engagements
    /// - Parameters:
    ///   - user: The current user
    ///   - daysUntilWedding: The day being displayed (displayedDaysOut)
    ///   - actualDaysUntilWedding: The real current day (optional, used for first-time user logic)
    func getTipForDay(user: User, daysUntilWedding: Int, actualDaysUntilWedding: Int? = nil) -> Tip? {
        // BYPASS: Skip all fun tips logic and use simple tip selection
        if bypassFunTipsLogic {
            // Try direct lookup first
            if let tip = getMasterTipForDay(daysUntilWedding: daysUntilWedding, isTentedWedding: user.isTentedWedding) {
                return tip
            }

            // Fallback for long engagements (>threshold days) or users without a wedding date:
            // Show a critical tip based on position
            // This ensures users with 500+ days still see useful tips while fun_tips isn't set up
            if daysUntilWedding > longEngagementThreshold || user.weddingDate == nil {
                return getBypassFallbackTip(user: user, daysUntilWedding: daysUntilWedding)
            }

            return nil
        }

        // SCENARIO 1: Long engagement (>threshold days out)
        if daysUntilWedding > longEngagementThreshold {
            return getTipForLongEngagement(user: user, daysUntilWedding: daysUntilWedding, actualDaysUntilWedding: actualDaysUntilWedding)
        }

        // SCENARIO 2: Normal engagement (≤threshold days out)
        return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
    }

    /// Fallback tip selection for bypass mode when user is in long engagement territory
    /// Shows critical tips (priority=1) spread across the long engagement period
    private func getBypassFallbackTip(user: User, daysUntilWedding: Int) -> Tip? {
        // Get critical tips (priority=1) for long engagements
        let criticalTips = tips.filter { tip in
            tip.priority == 1 &&
            (user.isTentedWedding ? true : tip.weddingType != "tented")
        }.sorted { ($0.specificDay ?? 0) > ($1.specificDay ?? 0) }

        guard !criticalTips.isEmpty else {
            // No critical tips, fall back to any tip from the highest day available
            let sortedTips = tips.filter { tip in
                user.isTentedWedding ? true : tip.weddingType != "tented"
            }.sorted { ($0.specificDay ?? 0) > ($1.specificDay ?? 0) }
            return sortedTips.first
        }

        // Calculate which critical tip to show based on position in long engagement
        guard let initialDays = user.initialDaysUntilWedding, initialDays > longEngagementThreshold else {
            // If no initial days set, use current days as reference
            let totalLongDays = daysUntilWedding - longEngagementThreshold
            let tipIndex = min(totalLongDays % criticalTips.count, criticalTips.count - 1)
            return criticalTips[tipIndex]
        }

        // Spread critical tips across the long engagement period
        let totalLongEngagementDays = initialDays - longEngagementThreshold
        let currentDayInPhase = initialDays - daysUntilWedding

        guard totalLongEngagementDays > 0 else {
            return criticalTips.first
        }

        // Calculate which tip index we're at
        let tipsPerDay = Double(criticalTips.count) / Double(totalLongEngagementDays)
        let tipIndex = min(Int(Double(currentDayInPhase) * tipsPerDay), criticalTips.count - 1)

        print("DEBUG TipService: bypass fallback - showing critical tip index \(tipIndex) of \(criticalTips.count)")
        return criticalTips[max(0, tipIndex)]
    }

    // MARK: - Long Engagement Logic (>420 days)

    private func getTipForLongEngagement(user: User, daysUntilWedding: Int, actualDaysUntilWedding: Int?) -> Tip? {

        // If fun tips system isn't set up yet, fall back to normal engagement logic
        // This allows the app to work before fun_tips table exists
        if funTips.isEmpty && criticalTips.isEmpty {
            print("DEBUG TipService: No fun tips or critical tips loaded, falling back to normal engagement")
            return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
        }

        // PRIORITY 1 TIP ON "TODAY": When user catches up to today, always show a priority 1 tip
        // This applies to users without a wedding date or any long engagement user who reaches today
        if let actual = actualDaysUntilWedding, daysUntilWedding == actual {
            print("DEBUG TipService: User caught up to today (day \(actual)), showing priority 1 tip")
            if let priority1Tip = getFirstPriority1MasterTip(isTentedWedding: user.isTentedWedding) {
                return priority1Tip
            }
        }

        guard let initialDays = user.initialDaysUntilWedding, initialDays > longEngagementThreshold else {
            print("DEBUG TipService: initialDaysUntilWedding not set or <= threshold, using fun tip for day \(daysUntilWedding)")
            // Fallback if initialDaysUntilWedding not set - show deterministic fun tip
            if let funTip = getFunTipForDay(daysUntilWedding)?.toTip() {
                return funTip
            }
            return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
        }

        // Calculate total days in "long engagement" phase
        // Example: 600 days wedding with threshold 420 = 180 days in this phase (600 → 421)
        let totalLongEngagementDays = initialDays - longEngagementThreshold
        let currentDayInPhase = initialDays - daysUntilWedding
        // currentDayInPhase: 0 = first day, increases as wedding approaches

        // We need to spread 50 critical tips across totalLongEngagementDays
        guard totalLongEngagementDays > 0 else {
            if let funTip = getFunTipForDay(daysUntilWedding)?.toTip() {
                return funTip
            }
            return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
        }

        // If viewing days BEFORE registration (negative phase), always show fun tips
        // Critical tips are only for days after user started using the app
        if currentDayInPhase < 0 {
            if let funTip = getFunTipForDay(daysUntilWedding)?.toTip() {
                return funTip
            }
            return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
        }

        let tipsPerDay = 50.0 / Double(totalLongEngagementDays)
        let criticalTipIndex = Int(Double(currentDayInPhase) * tipsPerDay)

        // Check if today is a "critical tip day"
        // A day is critical if we've crossed into a new tip index
        let previousDayIndex = currentDayInPhase > 0 ? Int(Double(currentDayInPhase - 1) * tipsPerDay) : -1
        let isCriticalTipDay = criticalTipIndex > previousDayIndex && criticalTipIndex < 50

        if isCriticalTipDay && criticalTipIndex < criticalTips.count {
            // Show the critical tip
            let tip = criticalTips[criticalTipIndex]

            // Filter for tented wedding if applicable
            if !user.isTentedWedding && tip.weddingType == "tented" {
                // Skip tented-specific tips for non-tented weddings, show fun tip instead
                if let funTip = getFunTipForDay(daysUntilWedding)?.toTip() {
                    return funTip
                }
                return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
            }

            return tip
        }

        // Otherwise, show a deterministic fun tip for this day
        if let funTip = getFunTipForDay(daysUntilWedding)?.toTip() {
            return funTip
        }
        return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
    }

    // MARK: - Normal Engagement Logic (≤420 days)

    private func getTipForNormalEngagement(user: User, daysUntilWedding: Int) -> Tip? {
        // Get the master tip for this day using existing logic
        guard let masterTip = getMasterTipForDay(daysUntilWedding: daysUntilWedding, isTentedWedding: user.isTentedWedding) else {
            return nil
        }

        // If this tip is marked as fun_tip and fun tips exist, show a deterministic fun tip
        // Otherwise just use the master tip (graceful fallback when fun_tips table doesn't exist)
        if masterTip.funTip && !funTips.isEmpty {
            return getFunTipForDay(daysUntilWedding)?.toTip() ?? masterTip
        }

        return masterTip
    }

    /// Tip selection logic - direct lookup by specific_day
    private func getMasterTipForDay(daysUntilWedding: Int, isTentedWedding: Bool) -> Tip? {
        print("DEBUG TipService: getMasterTipForDay called with daysUntilWedding=\(daysUntilWedding), isTented=\(isTentedWedding)")
        print("DEBUG TipService: total tips loaded = \(tips.count)")

        // Filter tips based on tented wedding status
        let filteredTips = tips.filter { tip in
            isTentedWedding ? true : tip.weddingType != "tented"
        }

        print("DEBUG TipService: filtered tips count = \(filteredTips.count)")

        // Direct lookup by specific_day (supports negative numbers for post-wedding tips)
        let result = filteredTips.first(where: { $0.specificDay == daysUntilWedding })
        print("DEBUG TipService: found tip for day \(daysUntilWedding): \(result?.title ?? "NIL")")

        return result
    }

    // MARK: - Priority 1 Master Tip Selection

    /// Get the first priority 1 tip from the master wedding_tips list
    /// Used for the "landing" tip when first-time long engagement users catch up
    private func getFirstPriority1MasterTip(isTentedWedding: Bool) -> Tip? {
        // Find priority 1 tips from the master list, sorted by highest specific_day first
        let priority1Tips = tips.filter { tip in
            tip.priority == 1 &&
            !tip.title.isEmpty &&  // Exclude fun_tip placeholder rows
            (isTentedWedding ? true : tip.weddingType != "tented")
        }.sorted { ($0.specificDay ?? 0) > ($1.specificDay ?? 0) }

        print("DEBUG TipService: Found \(priority1Tips.count) priority 1 master tips")
        return priority1Tips.first
    }

    // MARK: - Fun Tip Selection

    /// Get a fun tip for a specific day
    /// Uses a hash-based selection to spread tips out and avoid nearby repeats
    private func getFunTipForDay(_ daysUntilWedding: Int) -> FunTip? {
        guard !funTips.isEmpty else { return nil }

        // Sort fun tips consistently by ID so the selection is deterministic
        let sortedFunTips = funTips.sorted { $0.id.uuidString < $1.id.uuidString }
        let totalTips = sortedFunTips.count

        // Use a hash-based approach to scatter the selection across the tip pool
        // This prevents nearby days from getting the same or adjacent tips
        // The multiplier 2654435761 is the golden ratio hash constant (Knuth's multiplicative hash)
        let hash = abs(daysUntilWedding &* 2654435761)
        let index = hash % totalTips

        let selectedTip = sortedFunTips[index]
        print("DEBUG TipService: Day \(daysUntilWedding) - fun tip hash index \(index) of \(totalTips): \(selectedTip.title)")

        return selectedTip
    }

    /// Legacy random fun tip selection (kept for compatibility)
    private func getRandomFunTip(excludeCategory: String?) -> FunTip? {
        // Filter out already shown tips
        var availableTips = funTips.filter { !userShownFunTipIds.contains($0.id) }

        // Exclude last category to prevent back-to-back
        if let category = excludeCategory {
            let filtered = availableTips.filter { $0.category != category }
            if !filtered.isEmpty {
                availableTips = filtered
            }
        }

        if availableTips.isEmpty && !funTips.isEmpty {
            return funTips.randomElement()
        }

        let priorityTips = availableTips.filter { $0.priority == 1 }
        if !priorityTips.isEmpty {
            return priorityTips.randomElement()
        }

        return availableTips.randomElement()
    }

    /// Record that a fun tip was shown (call this after displaying a fun tip)
    func recordFunTipShown(userId: UUID, funTip: FunTip, daysOut: Int) async {
        // Update local cache
        await MainActor.run {
            self.userShownFunTipIds.insert(funTip.id)
            self.lastShownFunTipCategory = funTip.category
        }

        // Persist to database
        do {
            try await supabase.recordFunTipShown(userId: userId, funTipId: funTip.id, daysOut: daysOut)
        } catch {
            print("Error recording fun tip shown: \(error)")
        }

        // Check if all fun tips have been shown
        if userShownFunTipIds.count >= funTips.count {
            await resetFunTipHistory(userId: userId)
        }
    }

    /// Reset fun tip history when all have been shown
    private func resetFunTipHistory(userId: UUID) async {
        do {
            try await supabase.resetFunTipHistory(userId: userId)
            await MainActor.run {
                self.userShownFunTipIds.removeAll()
                self.lastShownFunTipCategory = nil
            }
        } catch {
            print("Error resetting fun tip history: \(error)")
        }
    }

    // MARK: - Legacy Methods (kept for compatibility)

    /// Legacy method - use getTipForDay(user:daysUntilWedding:) instead
    func getTipForDay(daysUntilWedding: Int, isTentedWedding: Bool) -> Tip? {
        return getMasterTipForDay(daysUntilWedding: daysUntilWedding, isTentedWedding: isTentedWedding)
    }

    func getChecklistTips(isTentedWedding: Bool) -> [String: [Tip]] {
        let checklistTips = tips.filter { tip in
            guard tip.onChecklist else { return false }

            // weddingType can be: nil/empty (general), "tented", or "non-tented"
            let weddingType = tip.weddingType?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let isGeneral = weddingType == nil || weddingType?.isEmpty == true
            let isTentedTip = weddingType?.contains("tented") == true && weddingType?.contains("non") == false
            let isNonTentedTip = weddingType?.contains("non") == true && weddingType?.contains("tented") == true

            if isTentedWedding {
                // Show general tips + tented-specific tips (exclude non-tented specific)
                return isGeneral || isTentedTip
            } else {
                // Show general tips + non-tented-specific tips (exclude tented specific)
                return isGeneral || isNonTentedTip
            }
        }

        // Group by month category and dedupe by title within each category
        var grouped: [String: [Tip]] = [:]

        for tip in checklistTips {
            let category = tip.monthCategory ?? "General"
            if grouped[category] == nil {
                grouped[category] = []
            }

            // Dedupe: only add if no tip with same title already exists in this category
            let normalizedTitle = tip.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let alreadyExists = grouped[category]?.contains { existing in
                existing.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedTitle
            } ?? false

            if !alreadyExists {
                grouped[category]?.append(tip)
            }
        }

        // Sort each group by specificDay (higher day number = further from wedding = top of list)
        for (category, categoryTips) in grouped {
            grouped[category] = categoryTips.sorted { ($0.specificDay ?? 0) > ($1.specificDay ?? 0) }
        }

        return grouped
    }

    func getSortedCategories() -> [MonthCategory] {
        return MonthCategory.allCases.sorted { $0.displayOrder < $1.displayOrder }
    }
}
