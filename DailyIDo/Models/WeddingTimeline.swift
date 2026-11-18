import Foundation

// Data model for the wedding-day Timeline Builder.
// Pure Foundation (no UIKit/SwiftUI) so the engine and these types can be
// unit-tested outside the app target (see TimelineEngineTests/).

// MARK: - Time of day

/// A wall-clock time on the wedding day, stored as minutes after midnight.
/// Values past 1440 mean "after midnight" (an after-party until 1 AM is 1500).
struct TimeOfDay: Hashable, Comparable, Codable {
    var minutes: Int

    init(minutes: Int) {
        self.minutes = minutes
    }

    init(hour: Int, minute: Int = 0) {
        self.minutes = hour * 60 + minute
    }

    var hour24: Int { (((minutes % 1440) + 1440) % 1440) / 60 }
    var minute: Int { ((minutes % 60) + 60) % 60 }

    /// "4:30 PM"
    var formatted: String {
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        return String(format: "%d:%02d %@", hour12, minute, hour24 < 12 ? "AM" : "PM")
    }

    static func + (lhs: TimeOfDay, rhs: Int) -> TimeOfDay { TimeOfDay(minutes: lhs.minutes + rhs) }
    static func - (lhs: TimeOfDay, rhs: Int) -> TimeOfDay { TimeOfDay(minutes: lhs.minutes - rhs) }
    static func - (lhs: TimeOfDay, rhs: TimeOfDay) -> Int { lhs.minutes - rhs.minutes }
    static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool { lhs.minutes < rhs.minutes }

    /// Converts to a `Date` on an arbitrary day, for use with `DatePicker`.
    func date(on day: Date = Date(), calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: day)
        return calendar.date(byAdding: .minute, value: hour24 * 60 + minute, to: start) ?? start
    }

    init(date: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        self.init(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
    }

    // Stored as a bare integer to keep the saved JSON small.
    init(from decoder: Decoder) throws {
        minutes = try decoder.singleValueContainer().decode(Int.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(minutes)
    }
}

// MARK: - Calendar dates

/// Wedding and weekend dates are stored as "yyyy-MM-dd" strings so they never
/// shift with the phone's time zone.
enum TimelineDate {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static var utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// Noon UTC on that day (noon keeps day-of-year math stable everywhere).
    static func date(from string: String) -> Date? {
        guard let midnight = formatter.date(from: string) else { return nil }
        return utcCalendar.date(byAdding: .hour, value: 12, to: midnight)
    }

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    /// Converts a local `Date` (e.g. from a DatePicker or the user profile) to
    /// "yyyy-MM-dd" using the phone's calendar day.
    static func string(fromLocal date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 2000, parts.month ?? 1, parts.day ?? 1)
    }

    /// The inverse of `string(fromLocal:)`: midnight local time on that day.
    static func localDate(from string: String, calendar: Calendar = .current) -> Date? {
        let pieces = string.split(separator: "-").compactMap { Int($0) }
        guard pieces.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: pieces[0], month: pieces[1], day: pieces[2]))
    }

    static func adding(days: Int, to string: String) -> String? {
        guard let date = date(from: string),
              let shifted = utcCalendar.date(byAdding: .day, value: days, to: date) else { return nil }
        return self.string(from: shifted)
    }

    /// "Fri, Jun 12"
    static func display(_ string: String) -> String {
        guard let date = date(from: string) else { return string }
        let display = DateFormatter()
        display.timeZone = TimeZone(identifier: "UTC")
        display.dateFormat = "EEE, MMM d"
        return display.string(from: date)
    }
}

// MARK: - Answer choices

enum PartnerRole: String, Codable, CaseIterable {
    case bride, groom, partner

    var label: String {
        switch self {
        case .bride: return "Bride"
        case .groom: return "Groom"
        case .partner: return "Partner"
        }
    }
}

enum TimelineVendor: String, Codable, CaseIterable {
    case planner, photographer, videographer, hair, makeup, florist, officiant
    case ceremonyMusicians, band, dj, transportation, rentals, photoBooth, other

    var label: String {
        switch self {
        case .planner: return "Planner / coordinator"
        case .photographer: return "Photographer"
        case .videographer: return "Videographer"
        case .hair: return "Hair"
        case .makeup: return "Makeup"
        case .florist: return "Florist"
        case .officiant: return "Officiant"
        case .ceremonyMusicians: return "Ceremony musicians"
        case .band: return "Band"
        case .dj: return "DJ"
        case .transportation: return "Transportation"
        case .rentals: return "Rentals / tent"
        case .photoBooth: return "Photo booth"
        case .other: return "Other"
        }
    }
}

enum CeremonyType: String, Codable, CaseIterable {
    case civil, religious, fullService, cultural

    var label: String {
        switch self {
        case .civil: return "Civil"
        case .religious: return "Religious"
        case .fullService: return "Full religious service (e.g. a mass)"
        case .cultural: return "Cultural"
        }
    }
}

enum CeremonyTradition: String, Codable, CaseIterable {
    case signing, unityCandle, handfasting, teaCeremony, readings, other

    var label: String {
        switch self {
        case .signing: return "Ketubah or license signing"
        case .unityCandle: return "Unity candle"
        case .handfasting: return "Handfasting"
        case .teaCeremony: return "Tea ceremony"
        case .readings: return "Readings"
        case .other: return "Other"
        }
    }
}

enum CeremonyExit: String, Codable, CaseIterable {
    case walkOut, petalToss, bubbles, other

    var label: String {
        switch self {
        case .walkOut: return "Walk out"
        case .petalToss: return "Petal toss"
        case .bubbles: return "Bubbles"
        case .other: return "Other"
        }
    }
}

enum FirstLookChoice: String, Codable, CaseIterable {
    case yes, no, both

    var label: String {
        switch self {
        case .yes: return "Yes"
        case .no: return "No"
        case .both: return "Show me both"
        }
    }
}

/// Which version of the day a timeline describes.
enum FirstLookBranch: String, Codable, CaseIterable {
    case firstLook, noFirstLook

    var label: String {
        switch self {
        case .firstLook: return "First look"
        case .noFirstLook: return "No first look"
        }
    }
}

enum PreCeremonyMoment: String, Codable, CaseIterable {
    case parentFirstLook, weddingPartyReveal, lettersOrGifts, privateVows, petPhotos

    var label: String {
        switch self {
        case .parentFirstLook: return "First look with a parent"
        case .weddingPartyReveal: return "Wedding party reveal"
        case .lettersOrGifts: return "Letters or gifts"
        case .privateVows: return "Private vows"
        case .petPhotos: return "Photos with a pet"
        }
    }
}

enum FamilyPhotoGroups: String, Codable, CaseIterable {
    case underTen, tenToTwenty, overTwenty

    var label: String {
        switch self {
        case .underTen: return "Under 10"
        case .tenToTwenty: return "10–20"
        case .overTwenty: return "20+"
        }
    }

    var minutes: Int {
        switch self {
        case .underTen: return 15
        case .tenToTwenty: return 30
        case .overTwenty: return 45
        }
    }
}

enum PartyTransport: String, Codable, CaseIterable {
    case driving, shuttle, alreadyThere

    var label: String {
        switch self {
        case .driving: return "Driving"
        case .shuttle: return "Shuttle or trolley"
        case .alreadyThere: return "Already there"
        }
    }
}

enum CocktailPresence: String, Codable, CaseIterable {
    case wholeTime, partOfIt, takingPhotos

    var label: String {
        switch self {
        case .wholeTime: return "The whole time"
        case .partOfIt: return "Part of it"
        case .takingPhotos: return "We'll be taking photos"
        }
    }
}

enum GrandEntrance: String, Codable, CaseIterable {
    case none, justUs, withWeddingParty

    var label: String {
        switch self {
        case .none: return "No"
        case .justUs: return "Just us"
        case .withWeddingParty: return "With our wedding party"
        }
    }
}

enum FirstDanceTiming: String, Codable, CaseIterable {
    case afterEntrance, afterDinner, skip

    var label: String {
        switch self {
        case .afterEntrance: return "Right after our entrance"
        case .afterDinner: return "After dinner"
        case .skip: return "Skipping it"
        }
    }
}

enum ToastTiming: String, Codable, CaseIterable {
    case beforeDinner, duringDinner, afterDinner

    var label: String {
        switch self {
        case .beforeDinner: return "Before dinner"
        case .duringDinner: return "During dinner"
        case .afterDinner: return "After dinner"
        }
    }
}

enum DinnerService: String, Codable, CaseIterable {
    case plated, buffet, stations, familyStyle

    var label: String {
        switch self {
        case .plated: return "Plated"
        case .buffet: return "Buffet"
        case .stations: return "Stations"
        case .familyStyle: return "Family style"
        }
    }
}

enum SpecialDance: String, Codable, CaseIterable {
    case parentDances, weddingPartyDance, anniversaryDance, other

    var label: String {
        switch self {
        case .parentDances: return "Parent dances"
        case .weddingPartyDance: return "Wedding party dance"
        case .anniversaryDance: return "Anniversary dance"
        case .other: return "Other"
        }
    }
}

enum CakeCutting: String, Codable, CaseIterable {
    case inFrontOfGuests, privately, none

    var label: String {
        switch self {
        case .inFrontOfGuests: return "In front of guests"
        case .privately: return "Privately"
        case .none: return "No cake"
        }
    }
}

enum DancingMoment: String, Codable, CaseIterable {
    case bouquetToss, garterToss, hora, moneyDance, other

    var label: String {
        switch self {
        case .bouquetToss: return "Bouquet toss"
        case .garterToss: return "Garter toss"
        case .hora: return "Hora"
        case .moneyDance: return "Money dance"
        case .other: return "Other"
        }
    }
}

enum EndOfNight: String, Codable, CaseIterable {
    case lastDance, sendOff, nothing

    var label: String {
        switch self {
        case .lastDance: return "Last dance"
        case .sendOff: return "Send-off (sparklers, etc.)"
        case .nothing: return "Nothing planned"
        }
    }
}

// MARK: - Defaults

/// The value used when a question is skipped or answered "Not sure".
/// Every default from the questionnaire spec lives here so the engine and the
/// questionnaire UI ("Not sure? We'll use …") always agree.
enum TimelineDefaults {
    static let partnerRole: PartnerRole = .partner
    static let guestCount = 100
    static let receptionSameVenue = true
    static let receptionDriveMinutes = 20
    static let vendors: Set<TimelineVendor> = [.photographer, .hair, .makeup, .florist, .officiant, .dj]
    static let vendorSetupLeadMinutes = 180          // 3 hrs before cocktail hour
    static let ceremonyType: CeremonyType = .civil
    static let ceremonyExit: CeremonyExit = .walkOut
    static let hairArtists = 2
    static let makeupArtists = 2
    static let plansLunch = true
    static let flowersDelivered = true
    static let driveToCeremonyMinutes = 15
    static let familyPhotoGroups: FamilyPhotoGroups = .tenToTwenty
    static let wantsSunsetPhotos = true
    static let photographerHours = 8.0
    static let weddingPartyTransport: PartyTransport = .alreadyThere
    static let guestShuttles = false
    static let getawayCar = false
    static let cocktailMinutesWithFirstLook = 60
    static let cocktailMinutesWithoutFirstLook = 90
    static let cocktailPresence: CocktailPresence = .partOfIt
    static let grandEntrance: GrandEntrance = .justUs
    static let firstDance: FirstDanceTiming = .afterEntrance
    static let hasWelcomeToast = true
    static let peerToastCount = 2
    static let hasBlessing = false
    static let toastTiming: ToastTiming = .beforeDinner
    static let dinnerService: DinnerService = .plated
    static let specialDances: Set<SpecialDance> = [.parentDances]
    static let cakeCutting: CakeCutting = .inFrontOfGuests
    static let secondLook = false
    static let lateNightSnack = false
    static let endOfNight: EndOfNight = .lastDance
    static let hasAfterParty = false
    static let rehearsalDaysBefore = 1
    static let rehearsalTime = TimeOfDay(hour: 16)
    static let hasBrunch = false
    static let brunchTime = TimeOfDay(hour: 10)
}

// MARK: - Questionnaire answers

/// One partner's identity plus their own getting-ready answers (section 3 is
/// answered per partner, giving each their own track).
struct TimelinePartner: Codable, Equatable, Identifiable {
    var id: String
    var name: String
    var role: PartnerRole?

    // 3. Getting ready
    var gettingReadyLocation: String?
    var hairMakeupStart: TimeOfDay?
    var hairMakeupEnd: TimeOfDay?
    var hairCount: Int?
    var makeupCount: Int?
    var hairArtists: Int?
    var makeupArtists: Int?
    var plansLunch: Bool?
    var flowersDelivered: Bool?
    var driveToCeremonyMinutes: Int?   // 0 = getting ready on site

    init(id: String, name: String = "", role: PartnerRole? = nil) {
        self.id = id
        self.name = name
        self.role = role
    }

    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return id == "p1" ? "Partner 1" : "Partner 2"
    }

    var resolvedRole: PartnerRole { role ?? TimelineDefaults.partnerRole }

    /// A partner gets the full hair & makeup track (HMU, dress on,
    /// getting-ready photos) if they gave HMU times or anyone is getting hair or
    /// makeup done with them. A bride who skipped the counts gets the full track
    /// for just herself. Everyone else gets the shorter "start getting ready"
    /// track (the team sheet's groom & groomsmen lines).
    var hasHairAndMakeupTrack: Bool {
        if hairMakeupStart != nil || hairMakeupEnd != nil { return true }
        if hairCount != nil || makeupCount != nil {
            return (hairCount ?? 0) > 0 || (makeupCount ?? 0) > 0
        }
        return resolvedRole == .bride
    }
}

struct WeekendEventInput: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var date: String?          // "yyyy-MM-dd"
    var time: TimeOfDay?
    var place: String?
}

/// Every answer from the couple questionnaire. `nil` means unanswered or
/// "Not sure", which falls back to `TimelineDefaults`. Required questions (★)
/// have no default.
struct TimelineQuestionnaire: Codable, Equatable {
    // 1. The basics
    var weddingDate: String?                    // ★ 1.1 "yyyy-MM-dd"
    var partners: [TimelinePartner] = [TimelinePartner(id: "p1"), TimelinePartner(id: "p2")]  // 1.2 (+ section 3)
    var guestCount: Int?                        // 1.3
    var ceremonyVenue: String?                  // ★ 1.4 venue name
    var ceremonyCity: String?                   // ★ 1.4 city / ZIP
    var ceremonyLatitude: Double?
    var ceremonyLongitude: Double?
    var ceremonyTimeZoneId: String?
    var receptionSameVenue: Bool?               // 1.5
    var receptionDriveMinutes: Int?             // 1.5
    var vendors: Set<TimelineVendor>?           // 1.6
    var vendorSetupTime: TimeOfDay?             // 1.7
    var hasOutdoorPortion: Bool?                // 1.8
    var rainPlan: String?                       // 1.8

    // 2. Ceremony
    var ceremonyStart: TimeOfDay?               // ★ 2.1
    var ceremonyType: CeremonyType?             // 2.2
    var traditions: Set<CeremonyTradition>?     // 2.3
    var ceremonyExit: CeremonyExit?             // 2.4

    // 4. Photos
    var firstLook: FirstLookChoice?             // ★ 4.1
    var preCeremonyMoments: Set<PreCeremonyMoment>?  // 4.2
    var familyPhotoGroups: FamilyPhotoGroups?   // 4.3
    var wantsSunsetPhotos: Bool?                // 4.4
    var photographerStart: TimeOfDay?           // 4.5
    var photographerHours: Double?              // 4.5
    var videographerStart: TimeOfDay?           // 4.6
    var videographerHours: Double?              // 4.6

    // 5. Getting around
    var weddingPartyTransport: PartyTransport?  // 5.1
    var guestShuttles: Bool?                    // 5.2
    var shuttleHotels: String?                  // 5.2
    var getawayCar: Bool?                       // 5.3

    // 6. Cocktail hour
    var cocktailMinutes: Int?                   // ★ 6.1 (60 or 90)
    var cocktailPresence: CocktailPresence?     // 6.2

    // 7. Reception
    var receptionEnd: TimeOfDay?                // ★ 7.1
    var grandEntrance: GrandEntrance?           // 7.2
    var firstDance: FirstDanceTiming?           // 7.3
    var hasWelcomeToast: Bool?                  // 7.4
    var welcomeToastBy: String?                 // 7.4
    var peerToasts: [String]?                   // 7.4 (one entry per toast; names optional)
    var hasBlessing: Bool?                      // 7.4
    var toastTiming: ToastTiming?               // 7.4
    var dinnerService: DinnerService?           // 7.5
    var specialDances: Set<SpecialDance>?       // 7.6
    var cakeCutting: CakeCutting?               // 7.7
    var dancingMoments: Set<DancingMoment>?     // 7.8
    var secondLook: Bool?                       // 7.9
    var lateNightSnack: Bool?                   // 7.10
    var endOfNight: EndOfNight?                 // 7.11

    // 8. After the reception
    var hasAfterParty: Bool?                    // 8.1
    var afterPartyPlace: String?                // 8.1
    var afterPartyEnd: TimeOfDay?               // 8.1
    var giftsTakenHomeBy: String?               // 8.2

    // 9. The rest of the weekend
    var rehearsalDate: String?                  // 9.1
    var rehearsalTime: TimeOfDay?               // 9.1
    var weekendEvents: [WeekendEventInput]?     // 9.2
    var appointments: [WeekendEventInput]?      // 9.3
    var hasBrunch: Bool?                        // 9.4
    var brunchTime: TimeOfDay?                  // 9.4
    var brunchPlace: String?                    // 9.4

    /// Set when the couple taps "Build my timeline" the first time.
    var completedAt: Date?

    init() {}

    // MARK: Required questions

    enum RequiredQuestion: String, CaseIterable {
        case weddingDate = "1.1"
        case ceremonyLocation = "1.4"
        case ceremonyStart = "2.1"
        case firstLook = "4.1"
        case cocktailLength = "6.1"
        case receptionEnd = "7.1"

        var title: String {
            switch self {
            case .weddingDate: return "Wedding date"
            case .ceremonyLocation: return "Ceremony location"
            case .ceremonyStart: return "Ceremony start time"
            case .firstLook: return "First look"
            case .cocktailLength: return "Cocktail hour length"
            case .receptionEnd: return "Reception end time"
            }
        }
    }

    var missingRequired: [RequiredQuestion] {
        var missing: [RequiredQuestion] = []
        if weddingDate == nil { missing.append(.weddingDate) }
        let city = ceremonyCity?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let venue = ceremonyVenue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if city.isEmpty && venue.isEmpty { missing.append(.ceremonyLocation) }
        if ceremonyStart == nil { missing.append(.ceremonyStart) }
        if firstLook == nil { missing.append(.firstLook) }
        if cocktailMinutes == nil { missing.append(.cocktailLength) }
        if receptionEnd == nil { missing.append(.receptionEnd) }
        return missing
    }

    var isReadyToBuild: Bool { missingRequired.isEmpty }

    /// Which versions of the day to generate.
    var branches: [FirstLookBranch] {
        switch firstLook {
        case .yes: return [.firstLook]
        case .no: return [.noFirstLook]
        case .both, .none: return [.firstLook, .noFirstLook]
        }
    }

    func partnerName(_ id: String) -> String {
        partners.first(where: { $0.id == id })?.displayName ?? id
    }
}

// MARK: - Generated timeline

enum TimelinePhase: Int, CaseIterable, Comparable {
    case gettingReady, ceremony, cocktailHour, reception, afterReception

    var title: String {
        switch self {
        case .gettingReady: return "Getting ready & photos"
        case .ceremony: return "Ceremony"
        case .cocktailHour: return "Cocktail hour"
        case .reception: return "Reception"
        case .afterReception: return "After the reception"
        }
    }

    static func < (lhs: TimelinePhase, rhs: TimelinePhase) -> Bool { lhs.rawValue < rhs.rawValue }
}

/// Who a line is for. Drives the colored tag on each row.
enum TimelineTrack: Hashable {
    case everyone
    case couple
    case guests
    case partner(String)          // TimelinePartner.id
    case vendor(TimelineVendor)
}

/// How a line's time is set (the spec's item types).
enum TimelineItemKind: Hashable {
    case anchor       // asked directly
    case derived      // anchor ± default offset
    case sequenced    // reception moments the couple can reorder
    case lookup       // sunset / golden hour
    case vendor       // contract hours or setup needs
}

struct TimelineItem: Identifiable, Hashable {
    let id: String
    var label: String
    var detail: String?
    var track: TimelineTrack
    var trackName: String
    var time: TimeOfDay
    var durationMinutes: Int?
    var kind: TimelineItemKind
    /// False for the couple's anchors (ceremony start, reception end): those
    /// change through the questionnaire, not the timeline.
    var isEditable: Bool
    /// The couple pinned this line to a custom time.
    var isEdited: Bool
    /// The couple hid (skipped) this line.
    var isHidden: Bool
    /// Set for lines the couple can reorder (reception and dancing moments).
    var sequenceId: String?
    /// Forces a phase instead of deriving it from the time (after-party lines).
    var phaseOverride: TimelinePhase?
}

/// A group of moments the couple can reorder, in its current order.
struct TimelineSequence: Identifiable, Hashable {
    struct Entry: Identifiable, Hashable {
        let id: String
        let label: String
        /// Fixed entries (introductions, salad, dinner, open dance floor) hold
        /// their place; the moments around them can move.
        let isFixed: Bool
    }

    let id: String
    let title: String
    let entries: [Entry]
}

struct TimelineWarning: Identifiable, Hashable {
    enum Kind: String {
        case earlyHairAndMakeup
        case shortCocktailHour
        case tightFamilyPhotos
        case photographerLeavesEarly
        case videographerLeavesEarly
        case sunsetBeforeCeremonyEnds
        case firstLookAfterSunset
    }

    let kind: Kind
    let title: String
    let message: String
    let relatedItemIds: [String]

    var id: String { kind.rawValue + "|" + relatedItemIds.joined(separator: ",") }
}

struct WeekendItem: Identifiable, Hashable {
    let id: String
    let title: String
    let date: String?          // "yyyy-MM-dd"
    let time: TimeOfDay?
    let place: String?
}

/// The couple's edits to one line, stored by item id so they survive answer
/// changes. Lines that no longer exist simply ignore their override.
struct TimelineOverride: Codable, Equatable {
    var time: TimeOfDay?
    var order: Int?
    var isHidden: Bool?

    var isEmpty: Bool { time == nil && order == nil && isHidden != true }
}

typealias TimelineOverrides = [String: TimelineOverride]

struct TimelineResult {
    let branch: FirstLookBranch
    /// Chronological, including hidden lines (filter on `isHidden` to display).
    let items: [TimelineItem]
    let weekend: [WeekendItem]
    let warnings: [TimelineWarning]
    let sequences: [TimelineSequence]
    let sunset: TimeOfDay?

    // Phase boundaries
    let guestArrival: TimeOfDay
    let ceremonyEnd: TimeOfDay
    let receptionStart: TimeOfDay
    let receptionEnd: TimeOfDay

    var visibleItems: [TimelineItem] { items.filter { !$0.isHidden } }
    var hiddenItems: [TimelineItem] { items.filter { $0.isHidden } }

    func item(_ id: String) -> TimelineItem? { items.first { $0.id == id } }

    func phase(of item: TimelineItem) -> TimelinePhase {
        if let forced = item.phaseOverride { return forced }
        if item.time < guestArrival { return .gettingReady }
        if item.time < ceremonyEnd { return .ceremony }
        if item.time < receptionStart { return .cocktailHour }
        if item.time <= receptionEnd { return .reception }
        return .afterReception
    }
}
