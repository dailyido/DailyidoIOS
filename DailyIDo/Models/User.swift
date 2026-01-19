import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var email: String?
    var name: String?
    var partnerName: String?
    var weddingDate: Date?
    var weddingTown: String?
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

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case partnerName = "partner_name"
        case weddingDate = "wedding_date"
        case weddingTown = "wedding_town"
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
    }

    init(id: UUID = UUID(),
         email: String? = nil,
         name: String? = nil,
         partnerName: String? = nil,
         weddingDate: Date? = nil,
         weddingTown: String? = nil,
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
         createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.partnerName = partnerName
        self.weddingDate = weddingDate
        self.weddingTown = weddingTown
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
    }

    var daysUntilWedding: Int? {
        guard let weddingDate = weddingDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let wedding = calendar.startOfDay(for: weddingDate)
        return calendar.dateComponents([.day], from: today, to: wedding).day
    }
}
