import Foundation

// The wedding-day timing engine. Pure Foundation and side-effect free:
// answers (+ an optional sunset time and the couple's edits) in, timeline out.
// Unit-tested in TimelineEngineTests/ against the planners' worked examples.

// MARK: - Timing rules

/// Every default offset and duration, in minutes, from the planners' first-look
/// and no-first-look sheets. Tune numbers here, not in the engine.
enum TimelineRules {
    // Ceremony
    static func ceremonyMinutes(_ type: CeremonyType) -> Int {
        switch type {
        case .civil: return 30
        case .religious: return 45
        case .fullService: return 60
        case .cultural: return 45
        }
    }

    /// Extra ceremony minutes per tradition. Signing gets its own slot instead.
    static func traditionMinutes(_ tradition: CeremonyTradition) -> Int {
        switch tradition {
        case .signing: return 0
        case .unityCandle: return 5
        case .handfasting: return 5
        case .teaCeremony: return 15
        case .readings: return 10
        case .other: return 5
        }
    }

    static let guestArrivalBeforeCeremony = 30
    static let officiantBeforeCeremony = 15
    static let ceremonyMusiciansBeforeCeremony = 45
    static let signingBeforeCeremony = 45
    static let signingMinutes = 15

    // Before the ceremony: first look
    static let firstLookBeforeGuestArrival = 90
    static let firstLookMinutes = 30
    static let familyPhotosAfterFirstLook = 30
    static let weddingPartyPhotosMinutes = 30
    static let preCeremonyMomentMinutes = 15

    // Getting ready (both versions)
    static let dressOnBeforeReady = 30          // ready = first look, or departure
    static let hairMakeupEndBeforeReady = 60
    static let gettingReadyPhotosBeforeDressOn = 15
    static let flowersBeforeDressOn = 60
    static let photographerBeforeDressOn = 60
    static let shortTrackGettingReadyMinutes = 90   // "groom & groomsmen" 1.5 hrs
    static let lunchMinutes = 30
    static let shortTrackLunchBeforeStart = 30
    static let hairMakeupMinutesPerRound = 45
    static let hairMakeupFinalLookMinutes = 45
    static let hairMakeupTouchUpMinutes = 30

    // Before the ceremony: no first look
    static let hairMakeupTrackArrivalBeforeCeremony = 15   // bride & bridesmaids
    static let shortTrackArrivalBeforeCeremony = 45        // groom & groomsmen
    static let weddingPartyPhotosAfterCeremonyMinutes = 15
    static let coupleJoinsCocktailAfterStart = 45

    // Cocktail hour & setup
    static let roomRevealBeforeReception = 10
    static let bandSetupBeforeCocktail = 120
    static let photoBoothSetupBeforeCocktail = 60
    static let shuttlesBeforeCeremony = 60

    // Reception
    static let introductionsAfterReceptionStart = 20
    static let shortMomentSlot = 5              // first dance, toasts, blessing, dances
    static let saladToDinner = 30
    static let dinnerToCake = 30
    static let buffetMinutes = 60
    static let cakeToNextMoment = 10
    static let duringDinnerToastsAfterFirstCourse = 15
    static let afterDinnerToastsEarliest = 20   // minutes into dinner
    static let dessertAfterOpenFloor = 15
    static let dancingMomentsAfterOpenFloor = 30
    static let secondLookSlot = 15
    static let lateNightSnackBeforeEnd = 60
    static let lastDanceBeforeEnd = 10

    static func dancingMomentSlot(_ moment: DancingMoment) -> Int {
        switch moment {
        case .bouquetToss: return 15
        case .garterToss: return 10
        case .hora: return 15
        case .moneyDance: return 15
        case .other: return 10
        }
    }

    // Sunset
    static let sunsetPhotosBeforeSunset = 30
    static let sunsetPhotosMinutes = 20

    // Warnings
    static let earliestComfortableHairMakeup = TimeOfDay(hour: 7)
}

// MARK: - Engine

enum TimelineEngine {
    static func generate(
        _ questionnaire: TimelineQuestionnaire,
        branch: FirstLookBranch,
        sunset: TimeOfDay? = nil,
        overrides: TimelineOverrides = [:]
    ) -> TimelineResult {
        TimelineBuilder(questionnaire: questionnaire, branch: branch, sunset: sunset, overrides: overrides).build()
    }

    /// Start = End − (rounds × 45) − 45 (final look) − 30 (touch-ups), where
    /// rounds = the larger of hair people ÷ hair artists and makeup people ÷
    /// makeup artists, rounded up.
    static func hairAndMakeupMinutes(hairCount: Int, makeupCount: Int, hairArtists: Int, makeupArtists: Int) -> Int {
        hairAndMakeupRounds(hairCount: hairCount, makeupCount: makeupCount, hairArtists: hairArtists, makeupArtists: makeupArtists)
            * TimelineRules.hairMakeupMinutesPerRound
            + TimelineRules.hairMakeupFinalLookMinutes
            + TimelineRules.hairMakeupTouchUpMinutes
    }

    static func hairAndMakeupRounds(hairCount: Int, makeupCount: Int, hairArtists: Int, makeupArtists: Int) -> Int {
        func rounds(_ people: Int, _ artists: Int) -> Int {
            guard people > 0 else { return 0 }
            return Int((Double(people) / Double(max(artists, 1))).rounded(.up))
        }
        return max(rounds(hairCount, hairArtists), rounds(makeupCount, makeupArtists))
    }
}

// MARK: - Builder

/// How a line's time is computed, in terms of other lines.
private enum Rule {
    case fixed(TimeOfDay)
    case offset(String, Int)
    case latest([(String, Int)])
    case earliest([(String, Int)])
}

private struct NodeSpec {
    let id: String
    var label: String
    var detail: String?
    var track: TimelineTrack
    var rule: Rule
    var duration: Int?
    var kind: TimelineItemKind
    var isEditable = true
    var sequenceId: String?
    var phaseOverride: TimelinePhase?
}

/// Moments spaced one after another; each item's slot is the gap before the
/// next one starts. A hidden moment keeps its place with a zero slot, so the
/// next moment moves up into it and everything after shifts earlier.
private struct SequenceSpec {
    struct Item {
        let id: String
        var label: String
        var detail: String?
        var track: TimelineTrack
        var slot: Int
        var isFixed: Bool
        var duration: Int?
    }

    let id: String
    let title: String
    let start: Rule
    var items: [Item]
}

private final class TimelineBuilder {
    let q: TimelineQuestionnaire
    let branch: FirstLookBranch
    let sunset: TimeOfDay?
    let overrides: TimelineOverrides

    private var specs: [String: NodeSpec] = [:]
    private var insertionOrder: [String] = []
    private var sequences: [SequenceSpec] = []
    private var resolved: [String: TimeOfDay] = [:]
    private var resolving: Set<String> = []

    private let partners: [TimelinePartner]
    private let vendors: Set<TimelineVendor>

    init(questionnaire: TimelineQuestionnaire, branch: FirstLookBranch, sunset: TimeOfDay?, overrides: TimelineOverrides) {
        self.q = questionnaire
        self.branch = branch
        self.sunset = sunset
        self.overrides = overrides
        var partners = questionnaire.partners
        if partners.isEmpty { partners = [TimelinePartner(id: "p1"), TimelinePartner(id: "p2")] }
        self.partners = partners
        self.vendors = questionnaire.vendors ?? TimelineDefaults.vendors
    }

    // MARK: Build

    func build() -> TimelineResult {
        let ceremonyStart = q.ceremonyStart ?? TimeOfDay(hour: 16)
        var receptionEnd = q.receptionEnd ?? ceremonyStart + 7 * 60
        if receptionEnd <= ceremonyStart { receptionEnd = receptionEnd + 1440 }

        addCeremony(start: ceremonyStart)
        addCocktailHourAndSetup()
        if branch == .firstLook {
            addFirstLookMorning()
        } else {
            addNoFirstLookMorning()
        }
        addReception(end: receptionEnd)
        addEndOfNight(end: receptionEnd)
        expandSequences()

        for id in insertionOrder { _ = time(id) }
        addSunset()

        let items = makeItems()
        let ceremonyEnd = time("ceremony.end") ?? ceremonyStart + 30
        return TimelineResult(
            branch: branch,
            items: items,
            weekend: makeWeekend(),
            warnings: makeWarnings(items: items, ceremonyEnd: ceremonyEnd),
            sequences: makeSequences(),
            sunset: sunset,
            guestArrival: time("ceremony.guestArrival") ?? ceremonyStart - 30,
            ceremonyEnd: ceremonyEnd,
            receptionStart: time("reception.start") ?? ceremonyEnd + 60,
            receptionEnd: receptionEnd
        )
    }

    // MARK: Ceremony

    private func addCeremony(start: TimeOfDay) {
        let type = q.ceremonyType ?? TimelineDefaults.ceremonyType
        let traditions = q.traditions ?? []
        let length = TimelineRules.ceremonyMinutes(type)
            + traditions.map(TimelineRules.traditionMinutes).reduce(0, +)

        var detail = type.label
        let named = CeremonyTradition.allCases.filter { traditions.contains($0) && $0 != .signing }.map(\.label)
        if !named.isEmpty { detail += " · " + named.joined(separator: ", ") }

        add("ceremony.start", "Ceremony begins", detail: detail, track: .everyone, rule: .fixed(start),
            duration: length, kind: .anchor, editable: false)
        add("ceremony.guestArrival", "Guests arrive · prelude music", track: .guests,
            rule: .offset("ceremony.start", -TimelineRules.guestArrivalBeforeCeremony), kind: .derived)
        if vendors.contains(.officiant) {
            add("ceremony.officiant", "Officiant arrives · mic check", track: .vendor(.officiant),
                rule: .offset("ceremony.start", -TimelineRules.officiantBeforeCeremony), kind: .vendor)
        }
        if vendors.contains(.ceremonyMusicians) {
            add("ceremony.musicians", "Ceremony musicians arrive", track: .vendor(.ceremonyMusicians),
                rule: .offset("ceremony.start", -TimelineRules.ceremonyMusiciansBeforeCeremony), kind: .vendor)
        }
        if traditions.contains(.signing) {
            add("ceremony.signing", "Ketubah / license signing", track: .couple,
                rule: .offset("ceremony.start", -TimelineRules.signingBeforeCeremony),
                duration: TimelineRules.signingMinutes, kind: .derived)
        }

        let exit: String
        switch q.ceremonyExit ?? TimelineDefaults.ceremonyExit {
        case .walkOut, .other: exit = "Ceremony ends · recessional"
        case .petalToss: exit = "Ceremony ends · petal toss exit"
        case .bubbles: exit = "Ceremony ends · bubble exit"
        }
        add("ceremony.end", exit, track: .everyone, rule: .offset("ceremony.start", length), kind: .derived)
    }

    // MARK: Cocktail hour & setup

    private var sameVenue: Bool { q.receptionSameVenue ?? TimelineDefaults.receptionSameVenue }
    private var receptionDrive: Int { sameVenue ? 0 : (q.receptionDriveMinutes ?? TimelineDefaults.receptionDriveMinutes) }

    private var cocktailMinutes: Int {
        q.cocktailMinutes ?? (branch == .firstLook
            ? TimelineDefaults.cocktailMinutesWithFirstLook
            : TimelineDefaults.cocktailMinutesWithoutFirstLook)
    }

    private func addCocktailHourAndSetup() {
        let shuttles = q.guestShuttles ?? TimelineDefaults.guestShuttles
        if !sameVenue {
            add("travel.toReception", "Guests travel to the reception", detail: "About \(receptionDrive) min drive"
                + (shuttles ? " · shuttles run from the ceremony" : ""),
                track: .guests, rule: .offset("ceremony.end", 0), kind: .derived)
        }
        add("cocktail.start", "Cocktail hour begins", track: .guests,
            rule: .offset("ceremony.end", receptionDrive), duration: cocktailMinutes, kind: .derived)
        add("reception.start", "Guests head into the reception", track: .guests,
            rule: .offset("cocktail.start", cocktailMinutes), kind: .derived)
        add("reception.roomReveal", "Room reveal for the couple", track: .couple,
            rule: .offset("reception.start", -TimelineRules.roomRevealBeforeReception), kind: .derived)

        if vendors.contains(.florist) {
            add("vendor.florist.move", "Ceremony flowers moved to the reception", track: .vendor(.florist),
                rule: .offset("cocktail.start", 0), kind: .vendor)
        }
        if let setup = q.vendorSetupTime {
            add("vendor.setup", "Vendor setup begins", track: .vendor(.other), rule: .fixed(setup), kind: .anchor)
        } else {
            add("vendor.setup", "Vendor setup begins", detail: "Check access time with your venue",
                track: .vendor(.other), rule: .offset("cocktail.start", -TimelineDefaults.vendorSetupLeadMinutes), kind: .vendor)
        }
        if vendors.contains(.band) {
            add("vendor.band.setup", "Band sets up", track: .vendor(.band),
                rule: .offset("cocktail.start", -TimelineRules.bandSetupBeforeCocktail), kind: .vendor)
        }
        if vendors.contains(.dj) {
            add("vendor.dj.setup", "DJ sets up", track: .vendor(.dj),
                rule: .offset("cocktail.start", -TimelineRules.bandSetupBeforeCocktail), kind: .vendor)
        }
        if vendors.contains(.photoBooth) {
            add("vendor.photoBooth.setup", "Photo booth set up", track: .vendor(.photoBooth),
                rule: .offset("cocktail.start", -TimelineRules.photoBoothSetupBeforeCocktail), kind: .vendor)
        }
    }

    // MARK: Before the ceremony

    private var moments: [PreCeremonyMoment] {
        PreCeremonyMoment.allCases.filter { (q.preCeremonyMoments ?? []).contains($0) }
    }

    private var momentsMinutes: Int { moments.count * TimelineRules.preCeremonyMomentMinutes }

    private var familyPhotoMinutes: Int { (q.familyPhotoGroups ?? TimelineDefaults.familyPhotoGroups).minutes }

    private func addFirstLookMorning() {
        add("photos.firstLook", "First look + couple portraits", track: .couple,
            rule: .offset("ceremony.guestArrival", -TimelineRules.firstLookBeforeGuestArrival),
            duration: TimelineRules.firstLookMinutes, kind: .derived)

        // Extra moments sit right before the first look and push getting ready earlier.
        for (index, moment) in moments.enumerated() {
            let before = (moments.count - index) * TimelineRules.preCeremonyMomentMinutes
            add("moment.\(moment.rawValue)", moment.label, track: .couple,
                rule: .offset("photos.firstLook", -before), duration: TimelineRules.preCeremonyMomentMinutes, kind: .derived)
        }

        add("photos.family", "Family photos", track: .couple,
            rule: .offset("photos.firstLook", TimelineRules.familyPhotosAfterFirstLook),
            duration: familyPhotoMinutes, kind: .derived)
        add("photos.weddingParty", "Wedding party photos", track: .couple,
            rule: .offset("photos.family", familyPhotoMinutes),
            duration: TimelineRules.weddingPartyPhotosMinutes, kind: .derived)
        add("photos.done", "Photos wrap · couple tucks away", track: .couple,
            rule: .offset("ceremony.guestArrival", 0), kind: .derived)

        for partner in partners {
            addGettingReady(partner, readyId: "photos.firstLook", readyOffset: -momentsMinutes)
        }
        addPhotoAndVideoCoverage()

        if (q.cocktailPresence ?? TimelineDefaults.cocktailPresence) == .takingPhotos {
            add("photos.cocktail", "Couple photos during cocktail hour", track: .couple,
                rule: .offset("cocktail.start", 0),
                duration: cocktailMinutes - TimelineRules.roomRevealBeforeReception, kind: .derived)
        }
    }

    private func addNoFirstLookMorning() {
        let transport = q.weddingPartyTransport ?? TimelineDefaults.weddingPartyTransport

        for partner in partners {
            let id = partner.id
            let hasHairMakeup = partner.hasHairAndMakeupTrack
            let arrivalBefore = hasHairMakeup
                ? TimelineRules.hairMakeupTrackArrivalBeforeCeremony
                : TimelineRules.shortTrackArrivalBeforeCeremony
            add("\(id).arrive", "Arrives at the ceremony", detail: hasHairMakeup ? "Out of sight until the ceremony" : nil,
                track: .partner(id), rule: .offset("ceremony.start", -arrivalBefore), kind: .derived)

            let drive = partner.driveToCeremonyMinutes ?? TimelineDefaults.driveToCeremonyMinutes
            var readyId = "\(id).arrive"
            if drive > 0 {
                var detail = "\(drive) min drive"
                if transport == .shuttle { detail += " · wedding party shuttle" }
                if transport == .driving { detail += " · wedding party drives" }
                add("\(id).depart", "Leaves for the ceremony", detail: detail, track: .partner(id),
                    rule: .offset("\(id).arrive", -drive), kind: .derived)
                readyId = "\(id).depart"
            }
            addGettingReady(partner, readyId: readyId, readyOffset: -momentsMinutes)
        }

        // Extra moments happen right before the earliest departure.
        if !moments.isEmpty {
            let readyIds = partners.map { specs["\($0.id).depart"] != nil ? "\($0.id).depart" : "\($0.id).arrive" }
            add("moments.anchor", "", track: .couple, rule: .earliest(readyIds.map { ($0, 0) }), kind: .derived)
            for (index, moment) in moments.enumerated() {
                let before = (moments.count - index) * TimelineRules.preCeremonyMomentMinutes
                add("moment.\(moment.rawValue)", moment.label, track: .couple,
                    rule: .offset("moments.anchor", -before), duration: TimelineRules.preCeremonyMomentMinutes, kind: .derived)
            }
        }

        addPhotoAndVideoCoverage()

        // Photos move to after the ceremony.
        add("photos.family", "Family photos", track: .couple, rule: .offset("ceremony.end", 0),
            duration: familyPhotoMinutes, kind: .derived)
        let presence = q.cocktailPresence ?? TimelineDefaults.cocktailPresence
        if presence == .wholeTime {
            add("couple.joinsCocktail", "Couple joins cocktail hour",
                detail: "Wedding party & couple portraits move to later in the night",
                track: .couple, rule: .offset("photos.family", familyPhotoMinutes), kind: .derived)
            return
        }

        add("photos.weddingParty", "Wedding party photos", track: .couple,
            rule: .offset("photos.family", familyPhotoMinutes),
            duration: TimelineRules.weddingPartyPhotosAfterCeremonyMinutes, kind: .derived)

        let portraitsFromCeremonyEnd = familyPhotoMinutes + TimelineRules.weddingPartyPhotosAfterCeremonyMinutes
        let portraitsUntil = presence == .takingPhotos
            ? receptionDrive + cocktailMinutes - TimelineRules.roomRevealBeforeReception
            : receptionDrive + TimelineRules.coupleJoinsCocktailAfterStart
        if portraitsUntil - portraitsFromCeremonyEnd >= 10 {
            add("photos.couple", "Couple portraits", track: .couple,
                rule: .offset("photos.weddingParty", TimelineRules.weddingPartyPhotosAfterCeremonyMinutes),
                duration: portraitsUntil - portraitsFromCeremonyEnd, kind: .derived)
        }
        if presence == .partOfIt {
            add("couple.joinsCocktail", "Couple joins cocktail hour", track: .couple,
                rule: .offset("cocktail.start", TimelineRules.coupleJoinsCocktailAfterStart), kind: .derived)
        }
    }

    /// One partner's getting-ready track, counted back from `readyId`
    /// (the first look, or their departure for the ceremony).
    private func addGettingReady(_ partner: TimelinePartner, readyId: String, readyOffset: Int) {
        let id = partner.id
        let track = TimelineTrack.partner(id)
        let flowers = partner.flowersDelivered ?? TimelineDefaults.flowersDelivered
        let lunch = partner.plansLunch ?? TimelineDefaults.plansLunch
        let location = partner.gettingReadyLocation?.trimmingCharacters(in: .whitespacesAndNewlines)
        let locationDetail = (location?.isEmpty == false) ? location : nil

        guard partner.hasHairAndMakeupTrack else {
            add("\(id).start", "Starts getting ready", detail: locationDetail, track: track,
                rule: .offset(readyId, readyOffset - TimelineRules.shortTrackGettingReadyMinutes), kind: .derived)
            if flowers {
                add("\(id).flowers", "Boutonnières delivered", detail: locationDetail, track: track,
                    rule: .offset("\(id).start", 0), kind: .vendor)
            }
            if lunch {
                add("\(id).lunch", "Lunch", track: track,
                    rule: .offset("\(id).start", -TimelineRules.shortTrackLunchBeforeStart),
                    duration: TimelineRules.lunchMinutes, kind: .derived)
            }
            return
        }

        let hair = partner.hairCount ?? (partner.makeupCount ?? 1)
        let makeup = partner.makeupCount ?? (partner.hairCount ?? 1)
        let hairArtists = partner.hairArtists ?? TimelineDefaults.hairArtists
        let makeupArtists = partner.makeupArtists ?? TimelineDefaults.makeupArtists
        let estimated = TimelineEngine.hairAndMakeupMinutes(
            hairCount: hair, makeupCount: makeup, hairArtists: hairArtists, makeupArtists: makeupArtists)

        add("\(id).dressOn", "Gets dressed", track: track,
            rule: .offset(readyId, readyOffset - TimelineRules.dressOnBeforeReady), kind: .derived)

        if let end = partner.hairMakeupEnd {
            add("\(id).hmuEnd", "Hair & makeup wraps", track: track, rule: .fixed(end), kind: .anchor)
        } else {
            add("\(id).hmuEnd", "Hair & makeup wraps", track: track,
                rule: .offset(readyId, readyOffset - TimelineRules.hairMakeupEndBeforeReady), kind: .derived)
        }

        var hairMakeupMinutes = estimated
        if let start = partner.hairMakeupStart {
            add("\(id).hmuStart", "Hair & makeup begins", detail: locationDetail, track: track,
                rule: .fixed(start), kind: .anchor)
            if let end = partner.hairMakeupEnd { hairMakeupMinutes = max(end - start, 0) }
        } else {
            let rounds = TimelineEngine.hairAndMakeupRounds(
                hairCount: hair, makeupCount: makeup, hairArtists: hairArtists, makeupArtists: makeupArtists)
            var detail = "\(hair) hair · \(makeup) makeup · \(rounds) round\(rounds == 1 ? "" : "s")"
            if let locationDetail { detail = locationDetail + " · " + detail }
            add("\(id).hmuStart", "Hair & makeup begins", detail: detail, track: track,
                rule: .offset("\(id).hmuEnd", -estimated), duration: estimated, kind: .derived)
        }

        add("\(id).photos", "Getting-ready photos", track: track,
            rule: .offset("\(id).dressOn", -TimelineRules.gettingReadyPhotosBeforeDressOn), kind: .derived)
        if flowers {
            add("\(id).flowers", "Bouquets delivered", detail: locationDetail, track: track,
                rule: .offset("\(id).dressOn", -TimelineRules.flowersBeforeDressOn), kind: .vendor)
        }
        if lunch {
            let half = (hairMakeupMinutes / 2) / 15 * 15
            add("\(id).lunch", "Lunch", track: track, rule: .offset("\(id).hmuStart", half),
                duration: TimelineRules.lunchMinutes, kind: .derived)
        }
    }

    private func addPhotoAndVideoCoverage() {
        // Default arrival: an hour before the first partner gets dressed.
        let defaultArrival: Rule = {
            let dressIds = partners.filter(\.hasHairAndMakeupTrack).map { "\($0.id).dressOn" }
            if !dressIds.isEmpty {
                return .earliest(dressIds.map { ($0, -TimelineRules.photographerBeforeDressOn) })
            }
            return .earliest(partners.map { ("\($0.id).start", 0) })
        }()

        let photoHours = q.photographerHours ?? TimelineDefaults.photographerHours
        let photoArrival: Rule = q.photographerStart.map { .fixed($0) } ?? defaultArrival
        if vendors.contains(.photographer) {
            add("vendor.photographer.arrive", "Photographer arrives", track: .vendor(.photographer),
                rule: photoArrival, kind: q.photographerStart == nil ? .vendor : .anchor)
            add("vendor.photographer.depart", "Photographer coverage ends",
                detail: "\(Self.hoursLabel(photoHours)) booked", track: .vendor(.photographer),
                rule: .offset("vendor.photographer.arrive", Int(photoHours * 60)), kind: .vendor)
        }
        if vendors.contains(.videographer) {
            let videoHours = q.videographerHours ?? photoHours
            let videoArrival: Rule = q.videographerStart.map { .fixed($0) } ?? photoArrival
            add("vendor.videographer.arrive", "Videographer arrives", track: .vendor(.videographer),
                rule: videoArrival, kind: q.videographerStart == nil ? .vendor : .anchor)
            add("vendor.videographer.depart", "Videographer coverage ends",
                detail: "\(Self.hoursLabel(videoHours)) booked", track: .vendor(.videographer),
                rule: .offset("vendor.videographer.arrive", Int(videoHours * 60)), kind: .vendor)
        }
    }

    private static func hoursLabel(_ hours: Double) -> String {
        hours == hours.rounded() ? "\(Int(hours)) hrs" : String(format: "%.1f hrs", hours)
    }

    // MARK: Reception

    /// The id of the first dinner line (salad, or the buffet/stations opening).
    private var firstMealId = "reception.salad"
    private var mealEndId = "reception.dinner"

    private func addReception(end: TimeOfDay) {
        let entrance = q.grandEntrance ?? TimelineDefaults.grandEntrance
        let firstDance = q.firstDance ?? TimelineDefaults.firstDance
        let toastTiming = q.toastTiming ?? TimelineDefaults.toastTiming
        let service = q.dinnerService ?? TimelineDefaults.dinnerService
        let dances = q.specialDances ?? TimelineDefaults.specialDances
        let cake = q.cakeCutting ?? TimelineDefaults.cakeCutting
        let slot = TimelineRules.shortMomentSlot

        typealias Item = SequenceSpec.Item
        var main: [Item] = []

        let introLabel: String
        switch entrance {
        case .none: introLabel = "Couple is seated"
        case .justUs: introLabel = "Grand entrance & introductions"
        case .withWeddingParty: introLabel = "Wedding party & couple introductions"
        }
        main.append(Item(id: "reception.introductions", label: introLabel, track: .everyone, slot: slot, isFixed: true))

        let firstDanceItem = Item(id: "reception.firstDance", label: "First dance", track: .couple, slot: slot, isFixed: false)
        if firstDance == .afterEntrance { main.append(firstDanceItem) }

        if q.hasWelcomeToast ?? TimelineDefaults.hasWelcomeToast {
            let by = q.welcomeToastBy?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            main.append(Item(id: "reception.welcomeToast", label: "Welcome toast", detail: by.isEmpty ? nil : by,
                             track: .everyone, slot: slot, isFixed: false))
        }

        let toasts = peerToastItems()
        if toastTiming == .beforeDinner { main.append(contentsOf: toasts) }

        if q.hasBlessing ?? TimelineDefaults.hasBlessing {
            main.append(Item(id: "reception.blessing", label: "Blessing", track: .everyone, slot: slot, isFixed: false))
        }

        let mealMinutes: Int
        switch service {
        case .plated, .familyStyle:
            main.append(Item(id: "reception.salad", label: service == .plated ? "Salad served" : "First course served",
                             track: .everyone, slot: TimelineRules.saladToDinner, isFixed: true))
            main.append(Item(id: "reception.dinner",
                             label: service == .plated ? "Dinner served" : "Family-style dinner served",
                             track: .everyone, slot: TimelineRules.dinnerToCake, isFixed: true))
            firstMealId = "reception.salad"
            mealEndId = "reception.dinner"
            mealMinutes = TimelineRules.dinnerToCake
        case .buffet, .stations:
            main.append(Item(id: "reception.salad", label: service == .buffet ? "Buffet opens" : "Dinner stations open",
                             track: .everyone, slot: TimelineRules.buffetMinutes, isFixed: true))
            firstMealId = "reception.salad"
            mealEndId = "reception.salad"
            mealMinutes = TimelineRules.buffetMinutes
        }

        if toastTiming == .afterDinner, !toasts.isEmpty {
            // Toasts start at least 20 minutes into the meal; cake stays at
            // dinner + 30 for two toasts and slides later for more.
            let mealSlot = max(mealMinutes - (TimelineRules.dinnerToCake - TimelineRules.afterDinnerToastsEarliest),
                               mealMinutes - slot * toasts.count)
            if let index = main.lastIndex(where: { $0.id == mealEndId }) {
                main[index].slot = mealSlot
                main.insert(contentsOf: toasts, at: index + 1)
            }
        }

        if cake != .none {
            main.append(Item(id: "reception.cake", label: cake == .privately ? "Private cake cutting" : "Cake cutting",
                             track: .couple, slot: TimelineRules.cakeToNextMoment, isFixed: false))
        }
        if firstDance == .afterDinner { main.append(firstDanceItem) }
        if dances.contains(.parentDances) {
            main.append(Item(id: "reception.parentDance1", label: "Parent dance", track: .couple, slot: slot, isFixed: false))
            main.append(Item(id: "reception.parentDance2", label: "Parent dance", track: .couple, slot: slot, isFixed: false))
        }
        if dances.contains(.weddingPartyDance) {
            main.append(Item(id: "reception.weddingPartyDance", label: "Wedding party dance", track: .everyone, slot: slot, isFixed: false))
        }
        if dances.contains(.anniversaryDance) {
            main.append(Item(id: "reception.anniversaryDance", label: "Anniversary dance", track: .everyone, slot: slot, isFixed: false))
        }
        if dances.contains(.other) {
            main.append(Item(id: "reception.otherDance", label: "Special dance", track: .everyone, slot: slot, isFixed: false))
        }
        main.append(Item(id: "reception.openFloor", label: "Dance floor opens", track: .everyone, slot: 0, isFixed: true))

        sequences.append(SequenceSpec(
            id: "seq.reception", title: "Reception moments",
            start: .offset("reception.start", TimelineRules.introductionsAfterReceptionStart), items: main))

        if toastTiming == .duringDinner, !toasts.isEmpty {
            sequences.append(SequenceSpec(
                id: "seq.dinnerToasts", title: "Toasts during dinner",
                start: .offset(firstMealId, TimelineRules.duringDinnerToastsAfterFirstCourse), items: toasts))
        }

        add("vendor.meals", "Vendor meals served", track: .vendor(.other), rule: .offset(firstMealId, 0), kind: .vendor)
        add("reception.dessert", "Dessert served", track: .everyone,
            rule: .offset("reception.openFloor", TimelineRules.dessertAfterOpenFloor), kind: .derived)

        var dancing: [Item] = DancingMoment.allCases
            .filter { (q.dancingMoments ?? []).contains($0) }
            .map { Item(id: "reception.\($0.rawValue)", label: $0.label, track: .everyone,
                        slot: TimelineRules.dancingMomentSlot($0), isFixed: false) }
        if q.secondLook ?? TimelineDefaults.secondLook {
            dancing.append(Item(id: "reception.secondLook", label: "Couple changes into second look", track: .couple,
                                slot: TimelineRules.secondLookSlot, isFixed: false))
        }
        if !dancing.isEmpty {
            sequences.append(SequenceSpec(
                id: "seq.dancing", title: "Dancing moments",
                start: .offset("reception.openFloor", TimelineRules.dancingMomentsAfterOpenFloor), items: dancing))
        }
    }

    private func peerToastItems() -> [SequenceSpec.Item] {
        let toasts = q.peerToasts ?? Array(repeating: "", count: TimelineDefaults.peerToastCount)
        return toasts.enumerated().map { index, name in
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            return SequenceSpec.Item(
                id: "reception.toast\(index + 1)", label: Self.ordinal(index + 1) + " toast",
                detail: trimmed.isEmpty ? nil : trimmed, track: .everyone,
                slot: TimelineRules.shortMomentSlot, isFixed: false)
        }
    }

    private static func ordinal(_ number: Int) -> String {
        switch number {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(number)th"
        }
    }

    // MARK: End of the night

    private func addEndOfNight(end: TimeOfDay) {
        add("reception.end", "Reception ends", track: .everyone, rule: .fixed(end), kind: .anchor, editable: false)

        if q.lateNightSnack ?? TimelineDefaults.lateNightSnack {
            add("reception.lateNightSnack", "Late-night snack", track: .everyone,
                rule: .offset("reception.end", -TimelineRules.lateNightSnackBeforeEnd), kind: .derived)
        }
        switch q.endOfNight ?? TimelineDefaults.endOfNight {
        case .lastDance:
            add("reception.lastDance", "Last dance", track: .everyone,
                rule: .offset("reception.end", -TimelineRules.lastDanceBeforeEnd), kind: .derived)
        case .sendOff:
            add("reception.sendOff", "Send-off", track: .everyone,
                rule: .offset("reception.end", -TimelineRules.lastDanceBeforeEnd), kind: .derived)
        case .nothing:
            break
        }
        if q.getawayCar ?? TimelineDefaults.getawayCar {
            add("transport.getaway", "Getaway car departs", track: .couple, rule: .offset("reception.end", 0), kind: .derived)
        }
        if q.guestShuttles ?? TimelineDefaults.guestShuttles {
            let hotels = q.shuttleHotels?.trimmingCharacters(in: .whitespacesAndNewlines)
            let detail = (hotels?.isEmpty == false) ? hotels : nil
            add("transport.shuttlesOut", "Guest shuttles depart", detail: detail, track: .guests,
                rule: .offset("ceremony.start", -TimelineRules.shuttlesBeforeCeremony), kind: .derived)
            add("transport.shuttlesHome", "Last shuttles back", detail: detail, track: .guests,
                rule: .offset("reception.end", 0), kind: .derived)
        }
        if let name = q.giftsTakenHomeBy?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            add("reception.gifts", "Gifts, cards & personal items go home", detail: "With \(name)",
                track: .everyone, rule: .offset("reception.end", 0), kind: .derived)
        }
        if q.hasAfterParty ?? TimelineDefaults.hasAfterParty {
            let place = q.afterPartyPlace?.trimmingCharacters(in: .whitespacesAndNewlines)
            add("after.start", "After party", detail: (place?.isEmpty == false) ? place : nil, track: .everyone,
                rule: .offset("reception.end", 0), kind: .derived, phase: .afterReception)
            if var afterEnd = q.afterPartyEnd {
                if afterEnd <= end { afterEnd = afterEnd + 1440 }
                add("after.end", "After party ends", track: .everyone, rule: .fixed(afterEnd),
                    kind: .anchor, phase: .afterReception)
            }
        }
    }

    // MARK: Sequences

    private func expandSequences() {
        for sequence in sequences {
            let ordered = applyOrder(sequence.items)
            for (index, item) in ordered.enumerated() {
                let rule: Rule
                if index == 0 {
                    rule = sequence.start
                } else {
                    let previous = ordered[index - 1]
                    rule = .offset(previous.id, isHidden(previous.id) ? 0 : previous.slot)
                }
                var spec = NodeSpec(id: item.id, label: item.label, detail: item.detail, track: item.track,
                                    rule: rule, duration: item.duration, kind: item.isFixed ? .derived : .sequenced)
                spec.sequenceId = sequence.id
                insert(spec)
            }
        }
    }

    /// Items the couple reordered sort by their stored position. Items with no
    /// stored position (new since the reorder) go right after the item that
    /// precedes them by default.
    private func applyOrder(_ items: [SequenceSpec.Item]) -> [SequenceSpec.Item] {
        let ordered = items.filter { overrides[$0.id]?.order != nil }
        guard !ordered.isEmpty else { return items }
        var result = ordered.sorted { (overrides[$0.id]?.order ?? 0) < (overrides[$1.id]?.order ?? 0) }
        for (index, item) in items.enumerated() where overrides[item.id]?.order == nil {
            var insertAt = 0
            var previous = index - 1
            while previous >= 0 {
                if let position = result.firstIndex(where: { $0.id == items[previous].id }) {
                    insertAt = position + 1
                    break
                }
                previous -= 1
            }
            result.insert(item, at: insertAt)
        }
        return result
    }

    private func makeSequences() -> [TimelineSequence] {
        sequences.compactMap { sequence in
            let ordered = applyOrder(sequence.items).filter { !isHidden($0.id) }
            guard ordered.filter({ !$0.isFixed }).count >= 2 else { return nil }
            return TimelineSequence(
                id: sequence.id, title: sequence.title,
                entries: ordered.map { .init(id: $0.id, label: $0.label + ($0.detail.map { " · \($0)" } ?? ""), isFixed: $0.isFixed) })
        }
    }

    // MARK: Sunset

    private func addSunset() {
        guard let sunset else { return }
        add("sunset", "Sunset", track: .everyone, rule: .fixed(sunset), kind: .lookup, editable: false)
        resolved["sunset"] = sunset

        guard q.wantsSunsetPhotos ?? TimelineDefaults.wantsSunsetPhotos,
              let ceremonyEnd = time("ceremony.end"), sunset >= ceremonyEnd else { return }

        let duration = TimelineRules.sunsetPhotosMinutes
        let target = max(sunset - TimelineRules.sunsetPhotosBeforeSunset, ceremonyEnd)
        let blocked = mustAttendWindows()
        func isFree(_ start: TimeOfDay) -> Bool {
            !blocked.contains { start < $0.upperBound && start + duration > $0.lowerBound }
        }

        var start = target
        var moved = false
        if !isFree(target) {
            let candidates = openGaps(duration: duration).compactMap { gap -> TimeOfDay? in
                let clamped = min(max(target, gap.lowerBound), gap.upperBound)
                return isFree(clamped) ? clamped : nil
            }
            if let best = candidates.min(by: { abs($0 - target) < abs($1 - target) }) {
                start = best
                moved = true
            }
        }

        var detail = "Sunset is at \(sunset.formatted)"
        if moved { detail += " · moved so you don't miss a key moment" }
        add("couple.sunsetPhotos", "Sunset photos", detail: detail, track: .couple,
            rule: .fixed(start), duration: duration, kind: .lookup)
        if let pinned = overrides["couple.sunsetPhotos"]?.time {
            resolved["couple.sunsetPhotos"] = pinned
        } else {
            resolved["couple.sunsetPhotos"] = start
        }
    }

    /// Introductions through salad, the cake cutting, the first dance and
    /// the parent dances.
    private func mustAttendWindows() -> [ClosedRange<TimeOfDay>] {
        var windows: [ClosedRange<TimeOfDay>] = []
        func window(_ from: String, _ to: String, extra: Int) {
            guard !isHidden(from), let start = time(from), let end = time(to) else { return }
            windows.append(start...max(start, end + extra))
        }
        window("reception.introductions", firstMealId, extra: 15)
        window("reception.cake", "reception.cake", extra: TimelineRules.cakeToNextMoment)
        window("reception.firstDance", "reception.firstDance", extra: TimelineRules.shortMomentSlot)
        if specs["reception.parentDance1"] != nil {
            let last = specs["reception.parentDance2"] != nil ? "reception.parentDance2" : "reception.parentDance1"
            window("reception.parentDance1", last, extra: TimelineRules.shortMomentSlot)
        }
        return windows
    }

    /// Where sunset photos can move: cocktail hour, after dinner is served,
    /// and once the dance floor is open. Each range is of allowed start times.
    private func openGaps(duration: Int) -> [ClosedRange<TimeOfDay>] {
        var gaps: [ClosedRange<TimeOfDay>] = []
        func gap(_ start: TimeOfDay?, _ end: TimeOfDay?) {
            guard let start, let end, end - duration >= start else { return }
            gaps.append(start...(end - duration))
        }
        gap(time("cocktail.start"), time("reception.roomReveal"))
        let dinnerServed = specs["reception.dinner"] != nil ? time("reception.dinner") : time(firstMealId).map { $0 + 30 }
        let afterDinnerNext = ["reception.cake", "reception.firstDance", "reception.parentDance1", "reception.openFloor"]
            .compactMap { id -> TimeOfDay? in
                guard let t = time(id), let served = dinnerServed, t > served else { return nil }
                return t
            }.min()
        gap(dinnerServed.map { $0 + 5 }, afterDinnerNext)
        let danceStart = ["reception.parentDance2", "reception.parentDance1", "reception.openFloor"]
            .compactMap { time($0) }.max()
        gap(danceStart.map { $0 + TimelineRules.shortMomentSlot }, time("reception.end"))
        return gaps
    }

    // MARK: Weekend

    private func makeWeekend() -> [WeekendItem] {
        var items: [WeekendItem] = []
        let wedding = q.weddingDate

        let rehearsalDate = q.rehearsalDate ?? wedding.flatMap { TimelineDate.adding(days: -TimelineDefaults.rehearsalDaysBefore, to: $0) }
        items.append(WeekendItem(id: "weekend.rehearsal", title: "Ceremony rehearsal", date: rehearsalDate,
                                 time: q.rehearsalTime ?? TimelineDefaults.rehearsalTime, place: nil))

        for event in q.weekendEvents ?? [] {
            let title = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
            items.append(WeekendItem(id: "weekend.event.\(event.id)", title: title.isEmpty ? "Rehearsal dinner" : title,
                                     date: event.date, time: event.time, place: event.place))
        }
        for appointment in q.appointments ?? [] {
            let title = appointment.title.trimmingCharacters(in: .whitespacesAndNewlines)
            items.append(WeekendItem(id: "weekend.appointment.\(appointment.id)", title: title.isEmpty ? "Appointment" : title,
                                     date: appointment.date, time: appointment.time, place: appointment.place))
        }
        if vendors.contains(.rentals) {
            items.append(WeekendItem(id: "weekend.rentalsIn", title: "Rentals & tent delivered",
                                     date: wedding.flatMap { TimelineDate.adding(days: -1, to: $0) }, time: nil, place: nil))
            items.append(WeekendItem(id: "weekend.rentalsOut", title: "Rentals & tent picked up (morning)",
                                     date: wedding.flatMap { TimelineDate.adding(days: 1, to: $0) }, time: nil, place: nil))
        }
        if q.hasBrunch ?? TimelineDefaults.hasBrunch {
            items.append(WeekendItem(id: "weekend.brunch", title: "Farewell brunch",
                                     date: wedding.flatMap { TimelineDate.adding(days: 1, to: $0) },
                                     time: q.brunchTime ?? TimelineDefaults.brunchTime, place: q.brunchPlace))
        }

        return items.enumerated().sorted { lhs, rhs in
            let l = (lhs.element.date ?? "", lhs.element.time?.minutes ?? -1, lhs.offset)
            let r = (rhs.element.date ?? "", rhs.element.time?.minutes ?? -1, rhs.offset)
            return l < r
        }.map(\.element)
    }

    // MARK: Warnings

    private func makeWarnings(items: [TimelineItem], ceremonyEnd: TimeOfDay) -> [TimelineWarning] {
        var warnings: [TimelineWarning] = []
        let visible = Dictionary(uniqueKeysWithValues: items.filter { !$0.isHidden }.map { ($0.id, $0) })

        for partner in partners where partner.hasHairAndMakeupTrack {
            let id = "\(partner.id).hmuStart"
            if let start = visible[id]?.time, start < TimelineRules.earliestComfortableHairMakeup {
                warnings.append(TimelineWarning(
                    kind: .earlyHairAndMakeup, title: "Early hair & makeup start",
                    message: "\(partner.displayName)'s hair & makeup starts at \(start.formatted). Adding another artist would let everyone start later.",
                    relatedItemIds: [id]))
            }
        }

        if branch == .noFirstLook {
            if cocktailMinutes <= 60 {
                warnings.append(TimelineWarning(
                    kind: .shortCocktailHour, title: "Short cocktail hour",
                    message: "Without a first look, photos happen during cocktail hour, so a 60-minute cocktail hour leaves you about 5 minutes with your guests. Consider 90 minutes.",
                    relatedItemIds: ["cocktail.start"]))
            }
            if (q.familyPhotoGroups ?? TimelineDefaults.familyPhotoGroups) == .overTwenty {
                warnings.append(TimelineWarning(
                    kind: .tightFamilyPhotos, title: "Tight family photo time",
                    message: "20+ family photo groupings in the window after the ceremony is tight. Trim the list or consider a first look.",
                    relatedItemIds: ["photos.family"]))
            }
        }

        let keyMoments = ["reception.cake", "reception.parentDance1", "reception.parentDance2"]
            .compactMap { visible[$0] }
            .sorted { $0.time < $1.time }
        for (vendor, kind) in [("photographer", TimelineWarning.Kind.photographerLeavesEarly),
                               ("videographer", TimelineWarning.Kind.videographerLeavesEarly)] {
            let departId = "vendor.\(vendor).depart"
            guard let depart = visible[departId],
                  let missed = keyMoments.first(where: { depart.time < $0.time }) else { continue }
            warnings.append(TimelineWarning(
                kind: kind, title: "\(vendor.capitalized) leaves early",
                message: "Your \(vendor)'s coverage ends at \(depart.time.formatted), before the \(missed.label.lowercased()) at \(missed.time.formatted). Consider adding time.",
                relatedItemIds: [departId, missed.id]))
        }

        if let sunset {
            if (q.wantsSunsetPhotos ?? TimelineDefaults.wantsSunsetPhotos), sunset < ceremonyEnd {
                warnings.append(TimelineWarning(
                    kind: .sunsetBeforeCeremonyEnds, title: "Sunset is before the ceremony ends",
                    message: "Sunset is at \(sunset.formatted), before your ceremony ends at \(ceremonyEnd.formatted), so sunset photos aren't possible.",
                    relatedItemIds: ["sunset", "ceremony.end"]))
            }
            if branch == .firstLook, let firstLook = visible["photos.firstLook"], firstLook.time >= sunset {
                warnings.append(TimelineWarning(
                    kind: .firstLookAfterSunset, title: "First look after sunset",
                    message: "Your first look at \(firstLook.time.formatted) is after sunset (\(sunset.formatted)), so those photos will be in the dark.",
                    relatedItemIds: ["photos.firstLook", "sunset"]))
            }
        }

        return warnings
    }

    // MARK: Items

    private func makeItems() -> [TimelineItem] {
        let positions = Dictionary(uniqueKeysWithValues: insertionOrder.enumerated().map { ($1, $0) })
        return insertionOrder.compactMap { id -> TimelineItem? in
            guard let spec = specs[id], !spec.label.isEmpty, let time = resolved[id] else { return nil }
            let override = overrides[id]
            return TimelineItem(
                id: id, label: spec.label, detail: spec.detail, track: spec.track,
                trackName: trackName(spec.track), time: time, durationMinutes: spec.duration,
                kind: spec.kind, isEditable: spec.isEditable,
                isEdited: spec.isEditable && override?.time != nil,
                isHidden: override?.isHidden == true,
                sequenceId: spec.sequenceId, phaseOverride: spec.phaseOverride)
        }
        .sorted { lhs, rhs in
            lhs.time == rhs.time ? (positions[lhs.id] ?? 0) < (positions[rhs.id] ?? 0) : lhs.time < rhs.time
        }
    }

    private func trackName(_ track: TimelineTrack) -> String {
        switch track {
        case .everyone: return "Everyone"
        case .couple: return "Couple"
        case .guests: return "Guests"
        case .partner(let id): return q.partnerName(id)
        case .vendor(let vendor): return vendor == .other ? "Vendors" : vendor.label
        }
    }

    // MARK: Resolution

    private func isHidden(_ id: String) -> Bool { overrides[id]?.isHidden == true }

    /// Resolves a line's time from its rule, depth-first, honoring the couple's
    /// pinned times so everything chained after a pinned line follows it.
    private func time(_ id: String) -> TimeOfDay? {
        if let known = resolved[id] { return known }
        guard let spec = specs[id], !resolving.contains(id) else { return nil }
        if spec.isEditable, let pinned = overrides[id]?.time {
            resolved[id] = pinned
            return pinned
        }
        resolving.insert(id)
        defer { resolving.remove(id) }

        let value: TimeOfDay?
        switch spec.rule {
        case .fixed(let fixed):
            value = fixed
        case .offset(let reference, let minutes):
            value = time(reference).map { $0 + minutes }
        case .latest(let references):
            value = references.compactMap { ref in time(ref.0).map { $0 + ref.1 } }.max()
        case .earliest(let references):
            value = references.compactMap { ref in time(ref.0).map { $0 + ref.1 } }.min()
        }
        if let value { resolved[id] = value }
        return value
    }

    // MARK: Helpers

    private func add(_ id: String, _ label: String, detail: String? = nil, track: TimelineTrack, rule: Rule,
                     duration: Int? = nil, kind: TimelineItemKind, editable: Bool = true, phase: TimelinePhase? = nil) {
        var spec = NodeSpec(id: id, label: label, detail: detail, track: track, rule: rule, duration: duration, kind: kind)
        spec.isEditable = editable
        spec.phaseOverride = phase
        insert(spec)
    }

    private func insert(_ spec: NodeSpec) {
        if specs[spec.id] == nil { insertionOrder.append(spec.id) }
        specs[spec.id] = spec
    }
}
