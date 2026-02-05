import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var email: String?
    var name: String?
    var partnerName: String?
    var weddingDate: Date?
    var weddingTown: String?
    var weddingVenue: String?
    var weddingLatitude: Double?
    var weddingLongitude: Double?
    var isTentedWedding: Bool
    var timezone: String?
    var lastViewedDay: Int?
    var currentStreak: Int
    var longestStreak: Int
    var lastStreakDate: Date?
    var tipsViewedCount: Int
    var onboardingComplete: Bool
    var isSubscribed: Bool
    var initialDaysUntilWedding: Int?
    var createdAt: Date?
    var doesntKnowDate: Bool
    var doesntKnowLocation: Bool
    var dateAddedAt: Date?
    var locationAddedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case partnerName = "partner_name"
        case weddingDate = "wedding_date"
        case weddingTown = "wedding_town"
        case weddingVenue = "wedding_venue"
        case weddingLatitude = "wedding_latitude"
        case weddingLongitude = "wedding_longitude"
        case isTentedWedding = "is_tented_wedding"
        case timezone
        case lastViewedDay = "last_viewed_day"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case lastStreakDate = "last_streak_date"
        case tipsViewedCount = "tips_viewed_count"
        case onboardingComplete = "onboarding_complete"
        case isSubscribed = "is_subscribed"
        case initialDaysUntilWedding = "initial_days_until_wedding"
        case createdAt = "created_at"
        case doesntKnowDate = "doesnt_know_date"
        case doesntKnowLocation = "doesnt_know_location"
        case dateAddedAt = "date_added_at"
        case locationAddedAt = "location_added_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        partnerName = try container.decodeIfPresent(String.self, forKey: .partnerName)
        weddingDate = try container.decodeIfPresent(Date.self, forKey: .weddingDate)
        weddingTown = try container.decodeIfPresent(String.self, forKey: .weddingTown)
        weddingVenue = try container.decodeIfPresent(String.self, forKey: .weddingVenue)
        weddingLatitude = try container.decodeIfPresent(Double.self, forKey: .weddingLatitude)
        weddingLongitude = try container.decodeIfPresent(Double.self, forKey: .weddingLongitude)
        isTentedWedding = try container.decodeIfPresent(Bool.self, forKey: .isTentedWedding) ?? false
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        lastViewedDay = try container.decodeIfPresent(Int.self, forKey: .lastViewedDay)
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        longestStreak = try container.decodeIfPresent(Int.self, forKey: .longestStreak) ?? 0
        lastStreakDate = try container.decodeIfPresent(Date.self, forKey: .lastStreakDate)
        tipsViewedCount = try container.decodeIfPresent(Int.self, forKey: .tipsViewedCount) ?? 0
        onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        isSubscribed = try container.decodeIfPresent(Bool.self, forKey: .isSubscribed) ?? false
        initialDaysUntilWedding = try container.decodeIfPresent(Int.self, forKey: .initialDaysUntilWedding)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        doesntKnowDate = try container.decodeIfPresent(Bool.self, forKey: .doesntKnowDate) ?? false
        doesntKnowLocation = try container.decodeIfPresent(Bool.self, forKey: .doesntKnowLocation) ?? false
        dateAddedAt = try container.decodeIfPresent(Date.self, forKey: .dateAddedAt)
        locationAddedAt = try container.decodeIfPresent(Date.self, forKey: .locationAddedAt)
    }

    init(id: UUID = UUID(),
         email: String? = nil,
         name: String? = nil,
         partnerName: String? = nil,
         weddingDate: Date? = nil,
         weddingTown: String? = nil,
         weddingVenue: String? = nil,
         weddingLatitude: Double? = nil,
         weddingLongitude: Double? = nil,
         isTentedWedding: Bool = false,
         timezone: String? = nil,
         lastViewedDay: Int? = nil,
         currentStreak: Int = 0,
         longestStreak: Int = 0,
         lastStreakDate: Date? = nil,
         tipsViewedCount: Int = 0,
         onboardingComplete: Bool = false,
         isSubscribed: Bool = false,
         initialDaysUntilWedding: Int? = nil,
         createdAt: Date? = nil,
         doesntKnowDate: Bool = false,
         doesntKnowLocation: Bool = false,
         dateAddedAt: Date? = nil,
         locationAddedAt: Date? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.partnerName = partnerName
        self.weddingDate = weddingDate
        self.weddingTown = weddingTown
        self.weddingVenue = weddingVenue
        self.weddingLatitude = weddingLatitude
        self.weddingLongitude = weddingLongitude
        self.isTentedWedding = isTentedWedding
        self.timezone = timezone
        self.lastViewedDay = lastViewedDay
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastStreakDate = lastStreakDate
        self.tipsViewedCount = tipsViewedCount
        self.onboardingComplete = onboardingComplete
        self.isSubscribed = isSubscribed
        self.initialDaysUntilWedding = initialDaysUntilWedding
        self.createdAt = createdAt
        self.doesntKnowDate = doesntKnowDate
        self.doesntKnowLocation = doesntKnowLocation
        self.dateAddedAt = dateAddedAt
        self.locationAddedAt = locationAddedAt
    }

    var daysUntilWedding: Int? {
        guard let weddingDate = weddingDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let wedding = calendar.startOfDay(for: weddingDate)
        return calendar.dateComponents([.day], from: today, to: wedding).day
    }
}
