import Foundation

final class StreakService: ObservableObject {
    static let shared = StreakService()

    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var showingMilestone: StreakMilestone?

    private var milestones: [StreakMilestone] = []
    private let supabase = SupabaseService.shared
    private let authService = AuthService.shared

    private init() {}

    func loadMilestones() async throws {
        let fetchedMilestones = try await supabase.fetchStreakMilestones()

        await MainActor.run {
            self.milestones = fetchedMilestones.sorted { $0.days < $1.days }
        }
    }

    func updateStreak() async throws {
        guard var user = authService.currentUser else { return }

        let today = Date().startOfDay
        let lastDate = user.lastStreakDate?.startOfDay

        // Check if we've already updated today
        if let last = lastDate, last.isSameDay(as: today) {
            // Already updated today, just sync the values
            await MainActor.run {
                self.currentStreak = user.currentStreak
                self.longestStreak = user.longestStreak
            }
            return
        }

        // Store old streak to detect broken streaks
        let oldStreak = user.currentStreak

        if let last = lastDate {
            if last.isYesterday {
                // Consecutive day - increment streak
                user = User(
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    partnerName: user.partnerName,
                    weddingDate: user.weddingDate,
                    weddingTown: user.weddingTown,
                    weddingVenue: user.weddingVenue,
                    weddingLatitude: user.weddingLatitude,
                    weddingLongitude: user.weddingLongitude,
                    isTentedWedding: user.isTentedWedding,
                    timezone: user.timezone,
                    lastViewedDay: user.lastViewedDay,
                    currentStreak: user.currentStreak + 1,
                    longestStreak: max(user.longestStreak, user.currentStreak + 1),
                    lastStreakDate: today,
                    tipsViewedCount: user.tipsViewedCount,
                    onboardingComplete: user.onboardingComplete,
                    isSubscribed: user.isSubscribed,
                    initialDaysUntilWedding: user.initialDaysUntilWedding,
                    createdAt: user.createdAt,
                    doesntKnowDate: user.doesntKnowDate,
                    doesntKnowLocation: user.doesntKnowLocation,
                    dateAddedAt: user.dateAddedAt,
                    locationAddedAt: user.locationAddedAt
                )
            } else {
                // Missed a day - reset streak (silent, no negative messaging)
                user = User(
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    partnerName: user.partnerName,
                    weddingDate: user.weddingDate,
                    weddingTown: user.weddingTown,
                    weddingVenue: user.weddingVenue,
                    weddingLatitude: user.weddingLatitude,
                    weddingLongitude: user.weddingLongitude,
                    isTentedWedding: user.isTentedWedding,
                    timezone: user.timezone,
                    lastViewedDay: user.lastViewedDay,
                    currentStreak: 1,
                    longestStreak: user.longestStreak,
                    lastStreakDate: today,
                    tipsViewedCount: user.tipsViewedCount,
                    onboardingComplete: user.onboardingComplete,
                    isSubscribed: user.isSubscribed,
                    initialDaysUntilWedding: user.initialDaysUntilWedding,
                    createdAt: user.createdAt,
                    doesntKnowDate: user.doesntKnowDate,
                    doesntKnowLocation: user.doesntKnowLocation,
                    dateAddedAt: user.dateAddedAt,
                    locationAddedAt: user.locationAddedAt
                )
            }
        } else {
            // First day
            user = User(
                id: user.id,
                email: user.email,
                name: user.name,
                partnerName: user.partnerName,
                weddingDate: user.weddingDate,
                weddingTown: user.weddingTown,
                weddingVenue: user.weddingVenue,
                weddingLatitude: user.weddingLatitude,
                weddingLongitude: user.weddingLongitude,
                isTentedWedding: user.isTentedWedding,
                timezone: user.timezone,
                lastViewedDay: user.lastViewedDay,
                currentStreak: 1,
                longestStreak: max(user.longestStreak, 1),
                lastStreakDate: today,
                tipsViewedCount: user.tipsViewedCount,
                onboardingComplete: user.onboardingComplete,
                isSubscribed: user.isSubscribed,
                initialDaysUntilWedding: user.initialDaysUntilWedding,
                createdAt: user.createdAt,
                doesntKnowDate: user.doesntKnowDate,
                doesntKnowLocation: user.doesntKnowLocation,
                dateAddedAt: user.dateAddedAt,
                locationAddedAt: user.locationAddedAt
            )
        }

        try await authService.updateUser(user)

        await MainActor.run {
            self.currentStreak = user.currentStreak
            self.longestStreak = user.longestStreak
        }

        // Track streak analytics
        AnalyticsService.shared.logStreakUpdated(current: user.currentStreak, longest: user.longestStreak)

        // Check if streak was broken (reset from > 1 to 1)
        if oldStreak > 1 && user.currentStreak == 1 {
            AnalyticsService.shared.logStreakBroken(previousStreak: oldStreak)
        }

        await checkMilestone(streak: user.currentStreak)
    }

    private func checkMilestone(streak: Int) async {
        guard let milestone = milestones.first(where: { $0.days == streak }) else {
            return
        }

        // Track milestone analytics
        AnalyticsService.shared.logStreakMilestone(streak)

        await MainActor.run {
            HapticManager.shared.streakMilestone()
            self.showingMilestone = milestone
        }
    }

    func dismissMilestone() {
        showingMilestone = nil
    }
}
