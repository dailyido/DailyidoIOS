import SwiftUI

/// One screen of the questionnaire. Section 3 (getting ready) appears once per
/// partner so each gets their own track.
enum QuestionnairePage: Hashable {
    case basics, ceremony, gettingReady(Int), photos, gettingAround, cocktailHour, reception, afterReception, weekend

    static let all: [QuestionnairePage] = [
        .basics, .ceremony, .gettingReady(0), .gettingReady(1), .photos,
        .gettingAround, .cocktailHour, .reception, .afterReception, .weekend,
    ]

    func title(_ q: TimelineQuestionnaire) -> String {
        switch self {
        case .basics: return "The basics"
        case .ceremony: return "Ceremony"
        case .gettingReady(let index):
            return "Getting ready: " + (q.partners.indices.contains(index) ? q.partners[index].displayName : "Partner")
        case .photos: return "Photos"
        case .gettingAround: return "Getting around"
        case .cocktailHour: return "Cocktail hour"
        case .reception: return "Reception"
        case .afterReception: return "After the reception"
        case .weekend: return "The rest of the weekend"
        }
    }

    /// Where each required question lives, for "take me there".
    static func index(for question: TimelineQuestionnaire.RequiredQuestion) -> Int {
        switch question {
        case .weddingDate, .ceremonyLocation: return 0
        case .ceremonyStart: return 1
        case .firstLook: return 4
        case .cocktailLength: return 6
        case .receptionEnd: return 7
        }
    }
}

struct TimelineQuestionnaireView: View {
    @ObservedObject var store: TimelineStore
    @State private var pageIndex: Int
    @State private var showMissing = false
    let onBuild: () -> Void

    init(store: TimelineStore, startPage: Int = 0, onBuild: @escaping () -> Void) {
        self.store = store
        _pageIndex = State(initialValue: min(max(startPage, 0), QuestionnairePage.all.count - 1))
        self.onBuild = onBuild
    }

    private var q: TimelineQuestionnaire { store.questionnaire }
    private var page: QuestionnairePage { QuestionnairePage.all[pageIndex] }
    private var isLastPage: Bool { pageIndex == QuestionnairePage.all.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Color.clear.frame(height: 0).id("top")
                        pageContent
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: pageIndex) { _ in
                    withAnimation { proxy.scrollTo("top", anchor: .top) }
                }
            }

            bottomBar
        }
        .background(Color(hex: Constants.Colors.background).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if q.isReadyToBuild && !isLastPage {
                    Button(store.isBuilt ? "Done" : "Build now") {
                        HapticManager.shared.buttonTap()
                        onBuild()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(TimelineStyle.rose)
                }
            }
        }
        .alert("A few required answers are missing", isPresented: $showMissing) {
            Button("Take me there") {
                if let first = q.missingRequired.first {
                    pageIndex = QuestionnairePage.index(for: first)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(q.missingRequired.map(\.title).joined(separator: ", "))
        }
    }

    // MARK: - Chrome

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STEP \(pageIndex + 1) OF \(QuestionnairePage.all.count)")
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.5)
                .foregroundColor(TimelineStyle.secondary)
            Text(page.title(q))
                .font(TimelineStyle.title(30))
                .foregroundColor(TimelineStyle.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(TimelineStyle.border)
                    Capsule()
                        .fill(TimelineStyle.accent)
                        .frame(width: proxy.size.width * CGFloat(pageIndex + 1) / CGFloat(QuestionnairePage.all.count))
                }
            }
            .frame(height: 5)
            .animation(.easeInOut(duration: 0.25), value: pageIndex)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if pageIndex > 0 {
                SecondaryButton(title: "Back") {
                    pageIndex -= 1
                }
                .frame(width: 110)
            }
            PrimaryButton(title: isLastPage ? (store.isBuilt ? "Update my timeline" : "Build my timeline") : "Next") {
                if isLastPage {
                    if q.isReadyToBuild {
                        onBuild()
                    } else {
                        showMissing = true
                    }
                } else {
                    pageIndex += 1
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            Color(hex: Constants.Colors.background)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: -2)
                .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case .basics: basicsPage
        case .ceremony: ceremonyPage
        case .gettingReady(let index): gettingReadyPage(index)
        case .photos: photosPage
        case .gettingAround: gettingAroundPage
        case .cocktailHour: cocktailPage
        case .reception: receptionPage
        case .afterReception: afterPage
        case .weekend: weekendPage
        }
    }

    // MARK: - 1. The basics

    @ViewBuilder
    private var basicsPage: some View {
        Text("Only the questions marked Required are needed. Everything else has a planner-approved default, so pick \"Not sure\" anytime.")
            .font(.system(size: 15))
            .foregroundColor(TimelineStyle.secondary)
            .padding(.horizontal, 4)

        QuestionBlock(number: "1.1", title: "What's your wedding date?", isRequired: true) {
            DateAnswerField(date: store.binding(\.weddingDate))
        }

        QuestionBlock(
            number: "1.2", title: "What are your names, and how should we refer to you?",
            notSureDefault: "Partner", isAnswered: q.partners.allSatisfy { $0.role != nil },
            onNotSure: { store.update { q in for index in q.partners.indices { q.partners[index].role = nil } } }
        ) {
            ForEach(q.partners.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    AnswerTextField(placeholder: index == 0 ? "Your first name" : "Your partner's first name",
                                    text: store.partnerBinding(index, \.name))
                    ChoiceChips(options: PartnerRole.allCases.map { ($0, $0.label) },
                                selection: store.partnerBinding(index, \.role))
                }
                .padding(.bottom, index == 0 ? 6 : 0)
            }
        }

        QuestionBlock(
            number: "1.3", title: "About how many guests are you expecting?",
            notSureDefault: "\(TimelineDefaults.guestCount) guests", isAnswered: q.guestCount != nil,
            onNotSure: { store.update { $0.guestCount = nil } }
        ) {
            NumberAnswerField(value: store.binding(\.guestCount).asDouble, range: 10...600, step: 10,
                              defaultValue: Double(TimelineDefaults.guestCount)) { "\(Int($0)) guests" }
        }

        QuestionBlock(number: "1.4", title: "Where is your ceremony?", isRequired: true,
                      hint: "We use the city to find sunset and your time zone.") {
            SubLabel(text: "Venue name")
            AnswerTextField(placeholder: "e.g. Holy Redeemer Church", text: store.binding(\.ceremonyVenue).orEmpty)
            SubLabel(text: "City")
            PlacesAutocompleteField(
                placeholder: "Start typing a city",
                selectedPlace: store.binding(\.ceremonyCity).orEmpty,
                latitude: store.binding(\.ceremonyLatitude),
                longitude: store.binding(\.ceremonyLongitude)
            )
            if let sunset = store.sunset {
                Label("Sunset that day: \(sunset.formatted)", systemImage: "sun.horizon.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: Constants.Colors.goldMid))
            } else if q.ceremonyLatitude == nil {
                Text("Pick your city from the list so we can time your sunset photos.")
                    .font(.system(size: 13))
                    .foregroundColor(TimelineStyle.secondary)
            }
        }

        QuestionBlock(
            number: "1.5", title: "Is your reception at the same place?",
            hint: "If not, how long is the drive?",
            notSureDefault: "same place", isAnswered: q.receptionSameVenue != nil,
            onNotSure: { store.update { $0.receptionSameVenue = nil; $0.receptionDriveMinutes = nil } }
        ) {
            YesNoChips(selection: store.binding(\.receptionSameVenue))
            if q.receptionSameVenue == false {
                SubLabel(text: "Drive between them")
                NumberAnswerField(value: store.binding(\.receptionDriveMinutes).asDouble, range: 5...180, step: 5,
                                  defaultValue: Double(TimelineDefaults.receptionDriveMinutes)) { "\(Int($0)) min" }
                Text("Not sure of the drive? We'll plan \(TimelineDefaults.receptionDriveMinutes) min.")
                    .font(.system(size: 13))
                    .foregroundColor(TimelineStyle.secondary)
            }
        }

        QuestionBlock(
            number: "1.6", title: "Which of these vendors are you working with?",
            notSureDefault: "photographer, hair, makeup, florist, officiant and DJ", isAnswered: q.vendors != nil,
            onNotSure: { store.update { $0.vendors = nil } }
        ) {
            MultiChoiceChips(options: TimelineVendor.allCases.map { ($0, $0.label) }, selection: store.binding(\.vendors))
        }

        QuestionBlock(
            number: "1.7", title: "What time can vendors start setting up at your reception?",
            hint: "Check with your venue.",
            notSureDefault: "3 hrs before cocktail hour", isAnswered: q.vendorSetupTime != nil,
            onNotSure: { store.update { $0.vendorSetupTime = nil } }
        ) {
            TimeAnswerField(time: store.binding(\.vendorSetupTime), suggested: TimeOfDay(hour: 12))
        }

        QuestionBlock(
            number: "1.8", title: "Is any part of your day outdoors?",
            hint: "If so, what's the backup if it rains?",
            notSureDefault: "no rain plan notes", isAnswered: q.hasOutdoorPortion != nil,
            onNotSure: { store.update { $0.hasOutdoorPortion = nil; $0.rainPlan = nil } }
        ) {
            YesNoChips(selection: store.binding(\.hasOutdoorPortion))
            if q.hasOutdoorPortion == true {
                AnswerTextField(placeholder: "Rain plan, e.g. move into the tent", text: store.binding(\.rainPlan).orEmpty)
            }
        }
    }

    // MARK: - 2. Ceremony

    @ViewBuilder
    private var ceremonyPage: some View {
        QuestionBlock(number: "2.1", title: "What time does your ceremony start?", isRequired: true,
                      hint: "Everything else in your day is timed from this.") {
            TimeAnswerField(time: store.binding(\.ceremonyStart), suggested: TimeOfDay(hour: 16))
        }

        QuestionBlock(
            number: "2.2", title: "What kind of ceremony are you having?",
            notSureDefault: "civil, 30 min", isAnswered: q.ceremonyType != nil,
            onNotSure: { store.update { $0.ceremonyType = nil } }
        ) {
            ChoiceChips(options: CeremonyType.allCases.map { ($0, "\($0.label) · \(TimelineRules.ceremonyMinutes($0)) min") },
                        selection: store.binding(\.ceremonyType))
        }

        QuestionBlock(
            number: "2.3", title: "Any traditions you'd like to include?",
            notSureDefault: "none", isAnswered: q.traditions != nil,
            onNotSure: { store.update { $0.traditions = nil } }
        ) {
            MultiChoiceChips(options: CeremonyTradition.allCases.map { ($0, $0.label) }, selection: store.binding(\.traditions))
        }

        QuestionBlock(
            number: "2.4", title: "How will you exit the ceremony?",
            notSureDefault: "walk out", isAnswered: q.ceremonyExit != nil,
            onNotSure: { store.update { $0.ceremonyExit = nil } }
        ) {
            ChoiceChips(options: CeremonyExit.allCases.map { ($0, $0.label) }, selection: store.binding(\.ceremonyExit))
        }
    }

    // MARK: - 3. Getting ready (per partner)

    @ViewBuilder
    private func gettingReadyPage(_ index: Int) -> some View {
        if q.partners.indices.contains(index) {
            let partner = q.partners[index]
            let name = partner.displayName

            Text("Answer for \(name). Each of you gets your own getting-ready schedule.")
                .font(.system(size: 15))
                .foregroundColor(TimelineStyle.secondary)
                .padding(.horizontal, 4)

            QuestionBlock(
                number: "3.1", title: "Where is \(name) getting ready?",
                notSureDefault: "no address on the timeline", isAnswered: partner.gettingReadyLocation != nil,
                onNotSure: { store.update { $0.partners[index].gettingReadyLocation = nil } }
            ) {
                AnswerTextField(placeholder: "Address or hotel", text: store.partnerBinding(index, \.gettingReadyLocation).orEmpty)
            }

            QuestionBlock(
                number: "3.2", title: "Do you know \(name)'s hair and makeup start and end times?",
                hint: "If not, we'll estimate them from how many people are getting ready."
            ) {
                let knowsTimes = partner.hairMakeupStart != nil || partner.hairMakeupEnd != nil
                ChoiceChips(
                    options: [(true, "Yes, we have times"), (false, "No, estimate them")],
                    selection: Binding(
                        get: { knowsTimes },
                        set: { knows in
                            store.update {
                                if knows == true {
                                    $0.partners[index].hairMakeupStart = $0.partners[index].hairMakeupStart ?? TimeOfDay(hour: 9)
                                    $0.partners[index].hairMakeupEnd = $0.partners[index].hairMakeupEnd ?? TimeOfDay(hour: 13)
                                } else {
                                    $0.partners[index].hairMakeupStart = nil
                                    $0.partners[index].hairMakeupEnd = nil
                                }
                            }
                        }
                    )
                )
                if knowsTimes {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            SubLabel(text: "Start")
                            TimeAnswerField(time: store.partnerBinding(index, \.hairMakeupStart), suggested: TimeOfDay(hour: 9))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            SubLabel(text: "End")
                            TimeAnswerField(time: store.partnerBinding(index, \.hairMakeupEnd), suggested: TimeOfDay(hour: 13))
                        }
                    }
                }
            }

            if partner.hairMakeupStart == nil && partner.hairMakeupEnd == nil {
                QuestionBlock(
                    number: "3.3", title: "How many people, including \(name), are getting hair done? How many are getting makeup?",
                    hint: "Set both to 0 if \(name) isn't getting hair or makeup done.",
                    notSureDefault: partner.resolvedRole == .bride ? "just \(name)" : "no hair & makeup",
                    isAnswered: partner.hairCount != nil || partner.makeupCount != nil,
                    onNotSure: { store.update { $0.partners[index].hairCount = nil; $0.partners[index].makeupCount = nil } }
                ) {
                    SubLabel(text: "Hair")
                    NumberAnswerField(value: store.partnerBinding(index, \.hairCount).asDouble, range: 0...30,
                                      defaultValue: 1) { "\(Int($0)) \(Int($0) == 1 ? "person" : "people")" }
                    SubLabel(text: "Makeup")
                    NumberAnswerField(value: store.partnerBinding(index, \.makeupCount).asDouble, range: 0...30,
                                      defaultValue: 1) { "\(Int($0)) \(Int($0) == 1 ? "person" : "people")" }
                }

                if partner.hasHairAndMakeupTrack {
                    QuestionBlock(
                        number: "3.4", title: "How many hair artists and how many makeup artists are coming?",
                        notSureDefault: "\(TimelineDefaults.hairArtists) of each",
                        isAnswered: partner.hairArtists != nil || partner.makeupArtists != nil,
                        onNotSure: { store.update { $0.partners[index].hairArtists = nil; $0.partners[index].makeupArtists = nil } }
                    ) {
                        SubLabel(text: "Hair artists")
                        NumberAnswerField(value: store.partnerBinding(index, \.hairArtists).asDouble, range: 1...10,
                                          defaultValue: Double(TimelineDefaults.hairArtists)) { "\(Int($0))" }
                        SubLabel(text: "Makeup artists")
                        NumberAnswerField(value: store.partnerBinding(index, \.makeupArtists).asDouble, range: 1...10,
                                          defaultValue: Double(TimelineDefaults.makeupArtists)) { "\(Int($0))" }
                        Label(hairMakeupEstimate(partner), systemImage: "sparkles")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(TimelineStyle.rose)
                    }
                }
            }

            QuestionBlock(
                number: "3.5", title: "Should we plan time for lunch while \(name) gets ready?",
                notSureDefault: "yes", isAnswered: partner.plansLunch != nil,
                onNotSure: { store.update { $0.partners[index].plansLunch = nil } }
            ) {
                YesNoChips(selection: store.partnerBinding(index, \.plansLunch))
            }

            QuestionBlock(
                number: "3.6", title: "Are \(name)'s flowers (bouquets, boutonnières) being delivered to them?",
                notSureDefault: "yes", isAnswered: partner.flowersDelivered != nil,
                onNotSure: { store.update { $0.partners[index].flowersDelivered = nil } }
            ) {
                YesNoChips(selection: store.partnerBinding(index, \.flowersDelivered))
            }

            QuestionBlock(
                number: "3.7", title: "How long is the drive from where \(name) is getting ready to the ceremony?",
                notSureDefault: "\(TimelineDefaults.driveToCeremonyMinutes) min", isAnswered: partner.driveToCeremonyMinutes != nil,
                onNotSure: { store.update { $0.partners[index].driveToCeremonyMinutes = nil } }
            ) {
                ChoiceChip(title: "We're getting ready on site", isSelected: partner.driveToCeremonyMinutes == 0) {
                    store.update {
                        $0.partners[index].driveToCeremonyMinutes = $0.partners[index].driveToCeremonyMinutes == 0 ? nil : 0
                    }
                }
                if partner.driveToCeremonyMinutes != 0 {
                    NumberAnswerField(value: store.partnerBinding(index, \.driveToCeremonyMinutes).asDouble, range: 5...120, step: 5,
                                      defaultValue: Double(TimelineDefaults.driveToCeremonyMinutes)) { "\(Int($0)) min drive" }
                }
            }
        }
    }

    private func hairMakeupEstimate(_ partner: TimelinePartner) -> String {
        let hair = partner.hairCount ?? (partner.makeupCount ?? 1)
        let makeup = partner.makeupCount ?? (partner.hairCount ?? 1)
        let hairArtists = partner.hairArtists ?? TimelineDefaults.hairArtists
        let makeupArtists = partner.makeupArtists ?? TimelineDefaults.makeupArtists
        let minutes = TimelineEngine.hairAndMakeupMinutes(hairCount: hair, makeupCount: makeup,
                                                          hairArtists: hairArtists, makeupArtists: makeupArtists)
        let rounds = TimelineEngine.hairAndMakeupRounds(hairCount: hair, makeupCount: makeup,
                                                        hairArtists: hairArtists, makeupArtists: makeupArtists)
        let hours = minutes / 60
        let remainder = minutes % 60
        let duration = remainder == 0 ? "\(hours) hr" : "\(hours) hr \(remainder) min"
        return "About \(duration) of hair & makeup (\(rounds) round\(rounds == 1 ? "" : "s"))"
    }

    // MARK: - 4. Photos

    @ViewBuilder
    private var photosPage: some View {
        QuestionBlock(number: "4.1", title: "Will you see each other before the ceremony (a first look)?", isRequired: true,
                      hint: "A first look moves your couple, wedding party and family photos before the ceremony, so getting ready starts earlier. Undecided? We'll build both and show them side by side.") {
            ChoiceChips(options: FirstLookChoice.allCases.map { ($0, $0.label) }, selection: store.binding(\.firstLook))
        }

        QuestionBlock(
            number: "4.2", title: "Any other special moments before the ceremony?",
            notSureDefault: "none", isAnswered: q.preCeremonyMoments != nil,
            onNotSure: { store.update { $0.preCeremonyMoments = nil } }
        ) {
            MultiChoiceChips(options: PreCeremonyMoment.allCases.map { ($0, $0.label) }, selection: store.binding(\.preCeremonyMoments))
            Text("Each gets a 15-minute slot.")
                .font(.system(size: 13))
                .foregroundColor(TimelineStyle.secondary)
        }

        QuestionBlock(
            number: "4.3", title: "How many family photo groupings do you want?",
            notSureDefault: "10–20 (30 min)", isAnswered: q.familyPhotoGroups != nil,
            onNotSure: { store.update { $0.familyPhotoGroups = nil } }
        ) {
            ChoiceChips(options: FamilyPhotoGroups.allCases.map { ($0, "\($0.label) · \($0.minutes) min") },
                        selection: store.binding(\.familyPhotoGroups))
        }

        QuestionBlock(
            number: "4.4", title: "Would you like sunset photos?",
            hint: store.sunset.map { "Sunset on your wedding day is at \($0.formatted)." },
            notSureDefault: "yes", isAnswered: q.wantsSunsetPhotos != nil,
            onNotSure: { store.update { $0.wantsSunsetPhotos = nil } }
        ) {
            YesNoChips(selection: store.binding(\.wantsSunsetPhotos))
        }

        QuestionBlock(
            number: "4.5", title: "When does your photographer start, and for how many hours?",
            notSureDefault: "1 hr before you get dressed, 8 hrs",
            isAnswered: q.photographerStart != nil || q.photographerHours != nil,
            onNotSure: { store.update { $0.photographerStart = nil; $0.photographerHours = nil } }
        ) {
            SubLabel(text: "Start time")
            TimeAnswerField(time: store.binding(\.photographerStart), suggested: TimeOfDay(hour: 13))
            SubLabel(text: "Hours booked")
            NumberAnswerField(value: store.binding(\.photographerHours), range: 1...16, step: 0.5,
                              defaultValue: TimelineDefaults.photographerHours, label: Self.hours)
        }

        QuestionBlock(
            number: "4.6", title: "When does your videographer start, and for how many hours?",
            hint: (q.vendors ?? TimelineDefaults.vendors).contains(.videographer) ? nil : "Skip this if you don't have a videographer (add one in 1.6).",
            notSureDefault: "same as your photographer",
            isAnswered: q.videographerStart != nil || q.videographerHours != nil,
            onNotSure: { store.update { $0.videographerStart = nil; $0.videographerHours = nil } }
        ) {
            SubLabel(text: "Start time")
            TimeAnswerField(time: store.binding(\.videographerStart), suggested: TimeOfDay(hour: 13))
            SubLabel(text: "Hours booked")
            NumberAnswerField(value: store.binding(\.videographerHours), range: 1...16, step: 0.5,
                              defaultValue: q.photographerHours ?? TimelineDefaults.photographerHours, label: Self.hours)
        }
    }

    private static func hours(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value)) hrs" : String(format: "%.1f hrs", value)
    }

    // MARK: - 5. Getting around

    @ViewBuilder
    private var gettingAroundPage: some View {
        QuestionBlock(
            number: "5.1", title: "How is your wedding party getting to the ceremony?",
            notSureDefault: "already there", isAnswered: q.weddingPartyTransport != nil,
            onNotSure: { store.update { $0.weddingPartyTransport = nil } }
        ) {
            ChoiceChips(options: PartyTransport.allCases.map { ($0, $0.label) }, selection: store.binding(\.weddingPartyTransport))
        }

        QuestionBlock(
            number: "5.2", title: "Are you providing shuttles for guests? From where?",
            notSureDefault: "no", isAnswered: q.guestShuttles != nil,
            onNotSure: { store.update { $0.guestShuttles = nil; $0.shuttleHotels = nil } }
        ) {
            YesNoChips(selection: store.binding(\.guestShuttles))
            if q.guestShuttles == true {
                AnswerTextField(placeholder: "Hotels, e.g. Wequassett, Chatham Inn", text: store.binding(\.shuttleHotels).orEmpty)
            }
        }

        QuestionBlock(
            number: "5.3", title: "Will you two have a getaway car?",
            notSureDefault: "no", isAnswered: q.getawayCar != nil,
            onNotSure: { store.update { $0.getawayCar = nil } }
        ) {
            YesNoChips(selection: store.binding(\.getawayCar))
        }
    }

    // MARK: - 6. Cocktail hour

    @ViewBuilder
    private var cocktailPage: some View {
        QuestionBlock(number: "6.1", title: "How long is your cocktail hour?", isRequired: true,
                      hint: "It starts right after the ceremony (plus travel). We recommend 60 minutes with a first look and 90 without.") {
            ChoiceChips(options: [(60, "60 min"), (90, "90 min")], selection: store.binding(\.cocktailMinutes))
        }

        QuestionBlock(
            number: "6.2", title: "Do you want to spend time at cocktail hour?",
            notSureDefault: "part of it", isAnswered: q.cocktailPresence != nil,
            onNotSure: { store.update { $0.cocktailPresence = nil } }
        ) {
            ChoiceChips(options: CocktailPresence.allCases.map { ($0, $0.label) }, selection: store.binding(\.cocktailPresence))
        }
    }

    // MARK: - 7. Reception

    private var peerToasts: [String] {
        q.peerToasts ?? Array(repeating: "", count: TimelineDefaults.peerToastCount)
    }

    private func editToasts(_ change: (inout [String]) -> Void) {
        store.update { q in
            var toasts = q.peerToasts ?? Array(repeating: "", count: TimelineDefaults.peerToastCount)
            change(&toasts)
            q.peerToasts = toasts
        }
    }

    @ViewBuilder
    private var receptionPage: some View {
        QuestionBlock(number: "7.1", title: "What time does your reception end?", isRequired: true,
                      hint: "Often set by your venue.") {
            TimeAnswerField(time: store.binding(\.receptionEnd), suggested: TimeOfDay(hour: 23))
        }

        QuestionBlock(
            number: "7.2", title: "Would you like a grand entrance?",
            notSureDefault: "just us", isAnswered: q.grandEntrance != nil,
            onNotSure: { store.update { $0.grandEntrance = nil } }
        ) {
            ChoiceChips(options: GrandEntrance.allCases.map { ($0, $0.label) }, selection: store.binding(\.grandEntrance))
        }

        QuestionBlock(
            number: "7.3", title: "When do you want your first dance?",
            notSureDefault: "right after your entrance", isAnswered: q.firstDance != nil,
            onNotSure: { store.update { $0.firstDance = nil } }
        ) {
            ChoiceChips(options: FirstDanceTiming.allCases.map { ($0, $0.label) }, selection: store.binding(\.firstDance))
        }

        QuestionBlock(
            number: "7.4", title: "Who is giving toasts, and when?",
            notSureDefault: "a welcome toast + 2 toasts before dinner",
            isAnswered: q.peerToasts != nil || q.toastTiming != nil || q.hasWelcomeToast != nil || q.hasBlessing != nil,
            onNotSure: {
                store.update {
                    $0.peerToasts = nil; $0.toastTiming = nil; $0.hasWelcomeToast = nil
                    $0.welcomeToastBy = nil; $0.hasBlessing = nil
                }
            }
        ) {
            SubLabel(text: "Welcome toast")
            YesNoChips(selection: store.binding(\.hasWelcomeToast))
            if q.hasWelcomeToast ?? TimelineDefaults.hasWelcomeToast {
                AnswerTextField(placeholder: "Given by (optional), e.g. Dad", text: store.binding(\.welcomeToastBy).orEmpty)
            }

            SubLabel(text: "Toasts")
            ForEach(peerToasts.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    AnswerTextField(
                        placeholder: "Toast \(index + 1): who's giving it? (optional)",
                        text: Binding(
                            get: { peerToasts.indices.contains(index) ? peerToasts[index] : "" },
                            set: { value in editToasts { if $0.indices.contains(index) { $0[index] = value } } }
                        )
                    )
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        editToasts { if $0.indices.contains(index) { $0.remove(at: index) } }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(TimelineStyle.secondary.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            Button(action: {
                HapticManager.shared.buttonTap()
                editToasts { $0.append("") }
            }) {
                Label("Add a toast", systemImage: "plus.circle.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(TimelineStyle.rose)
            }
            .buttonStyle(PlainButtonStyle())

            SubLabel(text: "A blessing before dinner?")
            YesNoChips(selection: store.binding(\.hasBlessing))

            SubLabel(text: "When are the toasts?")
            ChoiceChips(options: ToastTiming.allCases.map { ($0, $0.label) }, selection: store.binding(\.toastTiming))
        }

        QuestionBlock(
            number: "7.5", title: "How is dinner served?",
            notSureDefault: "plated", isAnswered: q.dinnerService != nil,
            onNotSure: { store.update { $0.dinnerService = nil } }
        ) {
            ChoiceChips(options: DinnerService.allCases.map { ($0, $0.label) }, selection: store.binding(\.dinnerService))
        }

        QuestionBlock(
            number: "7.6", title: "Any special dances?",
            notSureDefault: "parent dances", isAnswered: q.specialDances != nil,
            onNotSure: { store.update { $0.specialDances = nil } }
        ) {
            MultiChoiceChips(options: SpecialDance.allCases.map { ($0, $0.label) }, selection: store.binding(\.specialDances))
        }

        QuestionBlock(
            number: "7.7", title: "Will you have a cake cutting?",
            notSureDefault: "in front of guests", isAnswered: q.cakeCutting != nil,
            onNotSure: { store.update { $0.cakeCutting = nil } }
        ) {
            ChoiceChips(options: CakeCutting.allCases.map { ($0, $0.label) }, selection: store.binding(\.cakeCutting))
        }

        QuestionBlock(
            number: "7.8", title: "Any other moments to plan for?",
            notSureDefault: "none", isAnswered: q.dancingMoments != nil,
            onNotSure: { store.update { $0.dancingMoments = nil } }
        ) {
            MultiChoiceChips(options: DancingMoment.allCases.map { ($0, $0.label) }, selection: store.binding(\.dancingMoments))
        }

        QuestionBlock(
            number: "7.9", title: "Will you change into a second outfit?",
            notSureDefault: "no", isAnswered: q.secondLook != nil,
            onNotSure: { store.update { $0.secondLook = nil } }
        ) {
            YesNoChips(selection: store.binding(\.secondLook))
        }

        QuestionBlock(
            number: "7.10", title: "Will there be a late-night snack?",
            notSureDefault: "no", isAnswered: q.lateNightSnack != nil,
            onNotSure: { store.update { $0.lateNightSnack = nil } }
        ) {
            YesNoChips(selection: store.binding(\.lateNightSnack))
        }

        QuestionBlock(
            number: "7.11", title: "How will you end the night?",
            notSureDefault: "last dance", isAnswered: q.endOfNight != nil,
            onNotSure: { store.update { $0.endOfNight = nil } }
        ) {
            ChoiceChips(options: EndOfNight.allCases.map { ($0, $0.label) }, selection: store.binding(\.endOfNight))
        }
    }

    // MARK: - 8. After the reception

    @ViewBuilder
    private var afterPage: some View {
        QuestionBlock(
            number: "8.1", title: "Is there an after party? Where, and until when?",
            notSureDefault: "no", isAnswered: q.hasAfterParty != nil,
            onNotSure: { store.update { $0.hasAfterParty = nil; $0.afterPartyPlace = nil; $0.afterPartyEnd = nil } }
        ) {
            YesNoChips(selection: store.binding(\.hasAfterParty))
            if q.hasAfterParty == true {
                AnswerTextField(placeholder: "Where, e.g. the hotel bar", text: store.binding(\.afterPartyPlace).orEmpty)
                SubLabel(text: "Ends at")
                TimeAnswerField(time: store.binding(\.afterPartyEnd), suggested: TimeOfDay(hour: 1))
            }
        }

        QuestionBlock(
            number: "8.2", title: "Who is taking gifts, cards and personal items home?",
            notSureDefault: "no end-of-night note", isAnswered: q.giftsTakenHomeBy != nil,
            onNotSure: { store.update { $0.giftsTakenHomeBy = nil } }
        ) {
            AnswerTextField(placeholder: "Name, e.g. Mom", text: store.binding(\.giftsTakenHomeBy).orEmpty)
        }
    }

    // MARK: - 9. The rest of the weekend

    @ViewBuilder
    private var weekendPage: some View {
        QuestionBlock(
            number: "9.1", title: "When is your rehearsal?",
            notSureDefault: "the day before at 4:00 PM",
            isAnswered: q.rehearsalDate != nil || q.rehearsalTime != nil,
            onNotSure: { store.update { $0.rehearsalDate = nil; $0.rehearsalTime = nil } }
        ) {
            HStack(spacing: 16) {
                DateAnswerField(date: store.binding(\.rehearsalDate),
                                suggested: dayBeforeWedding ?? Date(), prompt: "Date")
                TimeAnswerField(time: store.binding(\.rehearsalTime), suggested: TimelineDefaults.rehearsalTime, prompt: "Time")
            }
        }

        QuestionBlock(number: "9.2", title: "Are you having a rehearsal dinner or welcome party?",
                      hint: "Add each event with its date, time and place.") {
            eventList(\.weekendEvents, addTitle: "Add an event", placeholder: "e.g. Rehearsal dinner")
        }

        QuestionBlock(number: "9.3", title: "Any appointments or activities before the wedding?",
                      hint: "Nails, hair trial, golf…") {
            eventList(\.appointments, addTitle: "Add an appointment", placeholder: "e.g. Nails")
        }

        QuestionBlock(
            number: "9.4", title: "Are you having a brunch the day after?",
            notSureDefault: "no brunch", isAnswered: q.hasBrunch != nil,
            onNotSure: { store.update { $0.hasBrunch = nil; $0.brunchTime = nil; $0.brunchPlace = nil } }
        ) {
            YesNoChips(selection: store.binding(\.hasBrunch))
            if q.hasBrunch == true {
                TimeAnswerField(time: store.binding(\.brunchTime), suggested: TimelineDefaults.brunchTime)
                AnswerTextField(placeholder: "Where", text: store.binding(\.brunchPlace).orEmpty)
            }
        }
    }

    private var dayBeforeWedding: Date? {
        guard let wedding = q.weddingDate, let before = TimelineDate.adding(days: -1, to: wedding) else { return nil }
        return TimelineDate.localDate(from: before)
    }

    @ViewBuilder
    private func eventList(_ list: WritableKeyPath<TimelineQuestionnaire, [WeekendEventInput]?>,
                           addTitle: String, placeholder: String) -> some View {
        let events = q[keyPath: list] ?? []
        ForEach(events) { event in
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    AnswerTextField(placeholder: placeholder, text: eventBinding(list, event.id, \.title, fallback: ""))
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        store.update { $0[keyPath: list]?.removeAll { $0.id == event.id } }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(TimelineStyle.secondary.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                HStack(spacing: 16) {
                    DateAnswerField(date: eventBinding(list, event.id, \.date, fallback: nil),
                                    suggested: dayBeforeWedding ?? Date(), prompt: "Date")
                    TimeAnswerField(time: eventBinding(list, event.id, \.time, fallback: nil),
                                    suggested: TimeOfDay(hour: 18), prompt: "Time")
                }
                AnswerTextField(placeholder: "Place", text: eventBinding(list, event.id, \.place, fallback: nil).orEmpty)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(TimelineStyle.cream))
        }
        Button(action: {
            HapticManager.shared.buttonTap()
            store.update { q in
                var items = q[keyPath: list] ?? []
                items.append(WeekendEventInput())
                q[keyPath: list] = items
            }
        }) {
            Label(addTitle, systemImage: "plus.circle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(TimelineStyle.rose)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func eventBinding<Value>(_ list: WritableKeyPath<TimelineQuestionnaire, [WeekendEventInput]?>, _ id: String,
                                     _ field: WritableKeyPath<WeekendEventInput, Value>, fallback: Value) -> Binding<Value> {
        Binding(
            get: { store.questionnaire[keyPath: list]?.first(where: { $0.id == id })?[keyPath: field] ?? fallback },
            set: { value in
                store.update { q in
                    if let index = q[keyPath: list]?.firstIndex(where: { $0.id == id }) {
                        q[keyPath: list]?[index][keyPath: field] = value
                    }
                }
            }
        )
    }
}
