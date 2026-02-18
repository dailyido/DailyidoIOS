import Foundation
import SwiftUI
import StoreKit

@MainActor
final class CalendarViewModel: ObservableObject {
    // Current view state - this is what day the user is LOOKING at
    // Represents "days until wedding" for the currently displayed tip
    @Published var displayedDaysOut: Int = 0

    @Published var currentTip: Tip?
    @Published var isLoading = true
    @Published var showPaywall = false
    @Published var isFirstDay = false  // True if user just started, can't tear yet

    // MARK: - Tear Animation State
    @Published var dragOffset: CGFloat = 0
    @Published var isDragging = false
    @Published var hasSnapped = false           // True when perforations "break"
    @Published var backgroundCardRise: CGFloat = 0  // 0 to 1 for background animation
    @Published var tearOpacity: Double = 1.0    // For fade out during tear
    @Published var isTearing = false            // True during tear completion animation

    // MARK: - Tip Cache
    private var tipCache: [Int: Tip] = [:]
    private var cacheCreatedAtDay: Int?  // Track when cache was created to invalidate on day change
    private var cachedWeddingDate: Date?  // Track wedding date to detect changes from settings

    // Velocity tracking
    private var lastDragOffset: CGFloat = 0
    private var lastDragTime: Date = Date()
    private var resistanceHapticTimer: Timer?

    private let tipService = TipService.shared
    private let authService = AuthService.shared
    private let streakService = StreakService.shared
    private let subscriptionService = SubscriptionService.shared

    var user: User? { authService.currentUser }

    // MARK: - Free Trial Logic

    /// Days since the user first opened the app
    var daysSinceFirstUse: Int {
        guard let firstOpenDate = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.firstAppOpenDate) as? Date else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: firstOpenDate, to: Date()).day ?? 0
    }

    /// Whether the free trial has ended (after 3 days of use)
    var isFreeTrialEnded: Bool {
        // If subscribed, trial doesn't matter
        if user?.isSubscribed == true || subscriptionService.isSubscribed {
            return false
        }
        return daysSinceFirstUse > Constants.freeTrialDays
    }

    /// Whether the user is subscribed (for UI elements like crown badge)
    var isUserSubscribed: Bool {
        user?.isSubscribed == true || subscriptionService.isSubscribed
    }

    // MARK: - Computed Properties

    // Whether the user has set a wedding date
    var hasWeddingDate: Bool {
        user?.weddingDate != nil
    }

    // The actual days until wedding from TODAY
    // Returns 500 as default for users without a wedding date (puts them on long engagement track)
    var actualDaysUntilWedding: Int {
        guard let weddingDate = user?.weddingDate else { return 500 }
        return Date().daysUntil(weddingDate)
    }

    // Days until wedding for the currently displayed tip
    var daysUntilWedding: Int {
        displayedDaysOut
    }

    // Can tear (swipe left) if we're behind today - there are pages to catch up on
    var canTear: Bool {
        // Simply check if we're viewing a day further from wedding than today
        return displayedDaysOut > actualDaysUntilWedding
    }

    // Can go back (swipe right) to see tips for days further from wedding
    var canGoBack: Bool {
        // Subscribed users can go back up to 800 days
        if user?.isSubscribed == true || subscriptionService.isSubscribed {
            return displayedDaysOut < 800
        }

        // Free users can only see 7 days back from signup day
        // Use initialDaysUntilWedding if available, otherwise use actualDaysUntilWedding as fallback
        let startingDay = user?.initialDaysUntilWedding ?? actualDaysUntilWedding
        let maxDaysBack = startingDay + Constants.freeUserMaxDaysBack

        print("📋 [CanGoBack] displayedDaysOut: \(displayedDaysOut), startingDay: \(startingDay), maxDaysBack: \(maxDaysBack), canGoBack: \(displayedDaysOut < maxDaysBack)")

        return displayedDaysOut < maxDaysBack
    }

    // Check if free user is at the swipe back limit (for showing paywall)
    var isAtSwipeBackLimit: Bool {
        // Subscribed users have no limit
        if user?.isSubscribed == true || subscriptionService.isSubscribed {
            return false
        }

        let startingDay = user?.initialDaysUntilWedding ?? actualDaysUntilWedding
        let maxDaysBack = startingDay + Constants.freeUserMaxDaysBack

        return displayedDaysOut >= maxDaysBack
    }

    // Number of pages that can be torn to catch up
    var pagesToCatchUp: Int {
        max(0, displayedDaysOut - actualDaysUntilWedding)
    }

    // Should show "Go to Today" button (more than 5 days back)
    var shouldShowGoToToday: Bool {
        displayedDaysOut > actualDaysUntilWedding + 5
    }

    // Jump directly to today's tip
    func jumpToToday() {
        displayedDaysOut = actualDaysUntilWedding
        updateCurrentTip()
        Task {
            await saveLastViewedDay(displayedDaysOut)
        }
    }

    /// Check if user can swipe (free trial still active or subscribed)
    /// Shows hard paywall if trial ended
    func checkAndShowPaywallIfNeeded() async -> Bool {
        // If subscribed, always allow
        if user?.isSubscribed == true || subscriptionService.isSubscribed {
            return true
        }

        // Check if free trial has ended
        if isFreeTrialEnded {
            print("📋 [Paywall] Free trial ended! Days since first use: \(daysSinceFirstUse)")
            await subscriptionService.showHardPaywall()

            // After paywall, check if they subscribed
            if subscriptionService.isSubscribed {
                return true
            }
            return false
        }

        print("📋 [Paywall] Free trial active. Day \(daysSinceFirstUse + 1) of \(Constants.freeTrialDays + 1)")
        return true
    }

    // Message shown when user can't tear (on current day)
    var statusMessage: String {
        if !canTear {
            return "Check in tomorrow for your next tip!"
        }
        return ""
    }

    // MARK: - Tear Animation Computed Properties

    // Progress from 0-1 with non-linear resistance curve
    var tearProgress: CGFloat {
        let absOffset = abs(dragOffset)
        let snapThreshold = Constants.TearAnimation.snapThreshold

        if absOffset < snapThreshold {
            // Pre-snap: logarithmic dampening (rubber-band effect)
            // Progress grows slower than input - creates resistance feel
            return pow(absOffset / snapThreshold, 0.6) * 0.5
        } else {
            // Post-snap: linear release
            let postSnapProgress = min((absOffset - snapThreshold) / 80, 0.5)
            return 0.5 + postSnapProgress
        }
    }

    // Whether we're in the pre-snap (resistance) phase
    var isPreSnap: Bool {
        abs(dragOffset) < Constants.TearAnimation.snapThreshold && !hasSnapped
    }

    // Direction of the tear
    var tearDirection: TearDirection {
        dragOffset < 0 ? .left : .right
    }

    enum TearDirection {
        case left, right
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true

        // Clear tip cache on each load to ensure fresh calculations
        // This is important when the actual day has changed since last session
        tipCache.removeAll()
        IllustrationURLCache.shared.clear()
        cacheCreatedAtDay = actualDaysUntilWedding
        cachedWeddingDate = user?.weddingDate

        print("DEBUG CalendarVM: 🔴🔴🔴 loadData started - CACHE CLEARED, cacheCreatedAtDay=\(actualDaysUntilWedding) 🔴🔴🔴")
        print("DEBUG CalendarVM: user = \(String(describing: user))")
        print("DEBUG CalendarVM: user.weddingDate = \(String(describing: user?.weddingDate))")
        print("DEBUG CalendarVM: actualDaysUntilWedding = \(actualDaysUntilWedding)")

        do {
            try await tipService.loadTips()
            print("DEBUG CalendarVM: tips loaded, count = \(tipService.tips.count)")
            try await streakService.updateStreak()

            // Load fun tip history for smart tip selection
            if let user = user {
                await tipService.loadUserFunTipHistory(userId: user.id)
            }

            calculateInitialPosition()
            print("DEBUG CalendarVM: after calculateInitialPosition, displayedDaysOut = \(displayedDaysOut)")
            updateCurrentTip()
            print("DEBUG CalendarVM: after updateCurrentTip, currentTip = \(String(describing: currentTip?.title))")
        } catch {
            print("Error loading calendar data: \(error)")
        }

        isLoading = false
    }

    private func calculateInitialPosition() {
        guard let user = user else {
            print("DEBUG CalendarVM: calculateInitialPosition - NO USER, returning early")
            return
        }

        print("DEBUG CalendarVM: calculateInitialPosition - user.lastViewedDay = \(String(describing: user.lastViewedDay))")
        print("DEBUG CalendarVM: calculateInitialPosition - actualDaysUntilWedding = \(actualDaysUntilWedding)")

        // Check if this is a new calendar day since last use
        let isNewDay: Bool
        if let lastDate = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.lastViewedDate) as? Date {
            isNewDay = !Calendar.current.isDateInToday(lastDate)
            print("DEBUG CalendarVM: lastViewedDate = \(lastDate), isNewDay = \(isNewDay)")
        } else {
            isNewDay = true  // First time use
            print("DEBUG CalendarVM: no lastViewedDate found, treating as new day")
        }

        // Check if this is a first-time user (never viewed any day)
        let isFirstTimeUser = user.lastViewedDay == nil

        if isFirstTimeUser {
            // First-time user: start 3 days back so they can experience swiping
            // This gives them content to explore without landing with nothing to do
            displayedDaysOut = actualDaysUntilWedding + 3
            isFirstDay = true
            print("DEBUG CalendarVM: first-time user - starting 3 days back = \(displayedDaysOut)")

            Task {
                await saveLastViewedDay(displayedDaysOut)
            }
        } else if isNewDay {
            // Returning user on a new day: reset to yesterday so they swipe once to see today
            displayedDaysOut = actualDaysUntilWedding + 1
            isFirstDay = false
            print("DEBUG CalendarVM: returning user, new day - resetting to yesterday = \(displayedDaysOut)")

            Task {
                await saveLastViewedDay(displayedDaysOut)
            }
        } else if let lastViewedDay = user.lastViewedDay {
            // Same day: restore saved position
            displayedDaysOut = lastViewedDay
            isFirstDay = false
            print("DEBUG CalendarVM: same day - using lastViewedDay = \(lastViewedDay)")
        } else {
            // Fallback: start 3 days back
            displayedDaysOut = actualDaysUntilWedding + 3
            isFirstDay = true
            print("DEBUG CalendarVM: fallback - setting displayedDaysOut = \(displayedDaysOut)")

            Task {
                await saveLastViewedDay(displayedDaysOut)
            }
        }
    }

    /// Call this when the app becomes active to refresh if needed
    func refreshIfNeeded() {
        // Check if the wedding date changed (user updated in settings)
        if let currentWeddingDate = user?.weddingDate,
           let cachedDate = cachedWeddingDate,
           !Calendar.current.isDate(currentWeddingDate, inSameDayAs: cachedDate) {
            print("DEBUG CalendarVM: 🔴 refreshIfNeeded - wedding date changed from \(cachedDate) to \(currentWeddingDate), jumping to today")
            tipCache.removeAll()
            IllustrationURLCache.shared.clear()
            cachedWeddingDate = currentWeddingDate
            cacheCreatedAtDay = actualDaysUntilWedding
            // Jump to today based on new wedding date
            displayedDaysOut = actualDaysUntilWedding
            updateCurrentTip()
            Task {
                await saveLastViewedDay(displayedDaysOut)
            }
            return
        }

        // Check if the actual day has changed since cache was created (midnight crossing)
        if let cacheDay = cacheCreatedAtDay, cacheDay != actualDaysUntilWedding {
            print("DEBUG CalendarVM: 🔴 refreshIfNeeded - day changed from \(cacheDay) to \(actualDaysUntilWedding), clearing cache")
            tipCache.removeAll()
            IllustrationURLCache.shared.clear()
            cacheCreatedAtDay = actualDaysUntilWedding
            updateCurrentTip()
        }
    }

    func updateCurrentTip() {
        guard let user = user else {
            print("DEBUG CalendarVM: updateCurrentTip - NO USER")
            return
        }


        // Use the new user-aware tip selection that handles long engagements
        // Pass actualDaysUntilWedding so first-time users get priority 1 tip when caught up
        let tip = tipService.getTipForDay(
            user: user,
            daysUntilWedding: displayedDaysOut,
            actualDaysUntilWedding: actualDaysUntilWedding
        )
        currentTip = tip

        // Cache current tip and pre-cache nearby tips
        if let tip = tip {
            tipCache[displayedDaysOut] = tip

            // Track tip viewed analytics
            AnalyticsService.shared.logTipViewed(
                tipId: tip.id,
                dayNumber: displayedDaysOut,
                isFunTip: tip.funTip
            )
        }
        precacheNearbyTips()
    }

    // Get tip from cache (used for preview pages)
    func cachedTip(for daysOut: Int) -> Tip? {
        // Return from cache if available
        if let cached = tipCache[daysOut] {
            return cached
        }

        // Otherwise fetch and cache it
        guard let user = user else { return nil }
        let tip = tipService.getTipForDay(
            user: user,
            daysUntilWedding: daysOut,
            actualDaysUntilWedding: actualDaysUntilWedding
        )
        if let tip = tip {
            tipCache[daysOut] = tip
            precacheImage(for: tip)
        }
        return tip
    }

    // Get tip for preview (when dragging to see next/previous)
    func previewTip(for daysOut: Int) -> Tip? {
        return cachedTip(for: daysOut)
    }

    // Pre-cache tips for nearby days (previous 1, next 3)
    private func precacheNearbyTips() {
        guard let user = user else { return }

        print("DEBUG CalendarVM: precacheNearbyTips - displayedDaysOut=\(displayedDaysOut), actualDaysUntilWedding=\(actualDaysUntilWedding)")

        let daysToCache = [
            displayedDaysOut - 3,
            displayedDaysOut - 2,
            displayedDaysOut - 1,
            displayedDaysOut + 1
        ]

        for day in daysToCache where day > 0 {
            if tipCache[day] == nil {
                print("DEBUG CalendarVM: precaching day \(day) (actual=\(actualDaysUntilWedding), isCaughtUp=\(day == actualDaysUntilWedding))")
                // Use the new user-aware tip selection
                // Pass actualDaysUntilWedding for first-time user experience
                if let tip = tipService.getTipForDay(
                    user: user,
                    daysUntilWedding: day,
                    actualDaysUntilWedding: actualDaysUntilWedding
                ) {
                    tipCache[day] = tip
                    print("DEBUG CalendarVM: precached day \(day) -> \(tip.title)")
                    precacheImage(for: tip)
                }
            } else {
                print("DEBUG CalendarVM: day \(day) already in cache")
            }
        }
    }

    // Pre-cache illustration image for a tip
    private func precacheImage(for tip: Tip) {
        // First, cache the URL in IllustrationURLCache to ensure stability
        IllustrationURLCache.shared.preCache(tip: tip)

        guard let urlString = IllustrationURLCache.shared.getURL(for: tip),
              let url = URL(string: urlString) else {
            return
        }

        // Check if already cached
        if ImageCache.shared.get(for: url) != nil {
            return
        }

        // Fetch and cache in background
        Task.detached(priority: .low) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        ImageCache.shared.set(image, for: url)
                    }
                }
            } catch {
                // Silently fail - will load on demand
            }
        }
    }

    // MARK: - Drag Handling with Snap Detection

    func updateDrag(offset: CGFloat) {
        let now = Date()
        let snapThreshold = Constants.TearAnimation.snapThreshold

        // Detect snap point crossing (only once per drag)
        let wasPreSnap = abs(lastDragOffset) < snapThreshold
        let isNowPostSnap = abs(offset) >= snapThreshold

        if wasPreSnap && isNowPostSnap && !hasSnapped {
            triggerSnap()
        }

        // Update background card rise based on tear progress
        if hasSnapped {
            let tearProgress = min((abs(offset) - snapThreshold) / 80, 1.0)
            backgroundCardRise = tearProgress
        } else {
            backgroundCardRise = 0
        }

        lastDragOffset = offset
        lastDragTime = now
        dragOffset = offset
    }

    private func triggerSnap() {
        hasSnapped = true
        HapticManager.shared.perforationSnap()
        stopResistanceHaptics()
    }

    /// Force reset all gesture state - used when a new gesture starts while previous animation was still running
    func forceResetForNewGesture() {
        isTearing = false
        isDragging = false
        hasSnapped = false
        dragOffset = 0
        tearOpacity = 1.0
        backgroundCardRise = 0
        lastDragOffset = 0
        stopResistanceHaptics()
    }

    func startDrag() {
        // Reset isTearing if it got stuck from a previous gesture
        if isTearing {
            isTearing = false
        }

        isDragging = true
        HapticManager.shared.lightImpact()
        startResistanceHaptics()
    }

    // MARK: - Resistance Haptics

    private func startResistanceHaptics() {
        stopResistanceHaptics()
        resistanceHapticTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.TearAnimation.resistanceHapticInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.isDragging, self.isPreSnap else { return }
                HapticManager.shared.tearResistance()
            }
        }
    }

    private func stopResistanceHaptics() {
        resistanceHapticTimer?.invalidate()
        resistanceHapticTimer = nil
    }

    // MARK: - Drag End Handling

    func handleDragEnd(translation: CGFloat, velocity: CGFloat, screenWidth: CGFloat) {
        stopResistanceHaptics()

        let minSwipeDistance: CGFloat = 50  // Minimum pixels to complete action
        let velocityThreshold: CGFloat = 300  // Fast flick threshold

        // TEAR (swipe left): translation is negative
        // Complete if: swiped far enough left OR fast enough left
        let shouldCompleteTear = translation < 0 && canTear &&
            (abs(translation) > minSwipeDistance || abs(velocity) > velocityThreshold)

        // GO BACK (swipe right): translation is positive
        // Complete if: swiped far enough right OR fast enough right
        let shouldGoBack = translation > 0 && canGoBack &&
            (abs(translation) > minSwipeDistance || abs(velocity) > velocityThreshold)

        // Check if user is trying to go back but hit the free user limit
        let tryingToGoBackPastLimit = translation > 0 && !canGoBack && isAtSwipeBackLimit &&
            (abs(translation) > minSwipeDistance || abs(velocity) > velocityThreshold)

        if shouldCompleteTear {
            // Check paywall before completing tear
            Task {
                let canProceed = await checkAndShowPaywallIfNeeded()
                await MainActor.run {
                    if canProceed {
                        completeTear()
                    } else {
                        cancelTear()
                    }
                }
            }
        } else if shouldGoBack {
            completeGoBack()
        } else if tryingToGoBackPastLimit {
            // Show paywall for free users hitting swipe back limit
            Task {
                await subscriptionService.showSwipeBackLimitPaywall()
                await MainActor.run {
                    // If they subscribed, allow the swipe
                    if subscriptionService.isSubscribed {
                        completeGoBack()
                    } else {
                        cancelTear()
                    }
                }
            }
        } else {
            cancelTear()
        }
    }

    // MARK: - Tear Completion

    private func completeTear() {
        guard !isTearing else { return }
        isTearing = true

        // Track calendar swipe analytics
        let fromDay = displayedDaysOut
        let toDay = displayedDaysOut - 1
        AnalyticsService.shared.logCalendarSwiped(direction: "left", fromDay: fromDay, toDay: toDay)

        HapticManager.shared.tearComplete()

        // Animate card off screen to the left
        withAnimation(.spring(
            response: Constants.TearAnimation.tearResponse,
            dampingFraction: Constants.TearAnimation.tearDamping
        )) {
            dragOffset = -Constants.TearAnimation.tearOffsetDistance
            tearOpacity = 0
        }

        // After animation, update state and reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }

            // Pre-fetch the next tip before any state changes
            let nextDaysOut = self.displayedDaysOut - 1
            let nextTip = self.cachedTip(for: nextDaysOut)

            // Reset all state immediately WITHOUT animation, including the tip update
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                // Update displayed day and tip synchronously
                self.displayedDaysOut = nextDaysOut
                self.currentTip = nextTip

                // Reset animation state
                self.dragOffset = 0
                self.tearOpacity = 1.0
                self.backgroundCardRise = 0
                self.hasSnapped = false
                self.isDragging = false
                self.lastDragOffset = 0
                self.isTearing = false
            }

            // Pre-cache nearby tips for future swipes
            self.precacheNearbyTips()

            // Handle async operations (paywall, database) in background
            Task {
                await self.handleTearPageAsync(nextDaysOut: nextDaysOut)
            }
        }
    }

    // Handle async tear operations separately to avoid blocking UI
    private func handleTearPageAsync(nextDaysOut: Int) async {
        guard let user = user else {
            print("📋 [Calendar] No user found")
            return
        }

        let mostAdvancedDay = user.lastViewedDay ?? actualDaysUntilWedding
        let isNewTip = nextDaysOut < mostAdvancedDay

        print("📋 [Calendar] ========================================")
        print("📋 [Calendar] nextDaysOut: \(nextDaysOut)")
        print("📋 [Calendar] mostAdvancedDay: \(mostAdvancedDay)")
        print("📋 [Calendar] isNewTip: \(isNewTip)")
        print("📋 [Calendar] daysSinceFirstUse: \(daysSinceFirstUse)")
        print("📋 [Calendar] freeTrialDays: \(Constants.freeTrialDays)")
        print("📋 [Calendar] ========================================")

        // Save progress
        if isNewTip {
            await saveLastViewedDay(nextDaysOut)

            // Track new days swiped for rating request
            let newDaysCount = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.newDaysSwipedCount) + 1
            UserDefaults.standard.set(newDaysCount, forKey: Constants.UserDefaultsKeys.newDaysSwipedCount)

            // Request rating after 2 new days (only once)
            let hasRequestedRating = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.hasRequestedRating)
            if newDaysCount >= 2 && !hasRequestedRating {
                UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasRequestedRating)
                await requestAppRating()
            }
        }

        if isFirstDay {
            await MainActor.run {
                isFirstDay = false
            }
        }
    }

    // MARK: - App Rating

    private func requestAppRating() async {
        // Small delay to let the UI settle after swipe
        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }

    // MARK: - Go Back Completion

    private func completeGoBack() {
        guard !isTearing else { return }
        isTearing = true

        // Track calendar swipe analytics
        let fromDay = displayedDaysOut
        let toDay = displayedDaysOut + 1
        AnalyticsService.shared.logCalendarSwiped(direction: "right", fromDay: fromDay, toDay: toDay)

        HapticManager.shared.buttonTap()

        // Animate card off screen to the right
        withAnimation(.spring(
            response: Constants.TearAnimation.tearResponse,
            dampingFraction: Constants.TearAnimation.tearDamping
        )) {
            dragOffset = Constants.TearAnimation.tearOffsetDistance
            tearOpacity = 0
        }

        // After animation, update state and reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }

            // Pre-fetch the previous tip before any state changes
            let prevDaysOut = self.displayedDaysOut + 1
            let prevTip = self.cachedTip(for: prevDaysOut)

            // Reset all state immediately WITHOUT animation, including the tip update
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                // Update displayed day and tip synchronously
                self.displayedDaysOut = prevDaysOut
                self.currentTip = prevTip

                // Reset animation state
                self.dragOffset = 0
                self.tearOpacity = 1.0
                self.backgroundCardRise = 0
                self.hasSnapped = false
                self.isDragging = false
                self.lastDragOffset = 0
                self.isTearing = false
            }

            // Pre-cache nearby tips for future swipes
            self.precacheNearbyTips()

            // User has interacted, so they're no longer on "first day" restriction
            if self.isFirstDay {
                self.isFirstDay = false
            }
        }
    }

    // MARK: - Tap Navigation

    func tapNext() {
        guard canTear, !isTearing else { return }
        Task {
            let canProceed = await checkAndShowPaywallIfNeeded()
            await MainActor.run {
                if canProceed {
                    completeTear()
                }
            }
        }
    }

    func tapPrevious() {
        guard !isTearing else { return }
        if canGoBack {
            completeGoBack()
        } else if isAtSwipeBackLimit {
            Task {
                await subscriptionService.showSwipeBackLimitPaywall()
                await MainActor.run {
                    if subscriptionService.isSubscribed {
                        completeGoBack()
                    }
                }
            }
        }
    }

    private func cancelTear() {
        HapticManager.shared.tearCancel()

        withAnimation(.spring(
            response: Constants.TearAnimation.cancelResponse,
            dampingFraction: Constants.TearAnimation.cancelDamping
        )) {
            dragOffset = 0
            backgroundCardRise = 0
        }

        resetTearState()
    }

    private func resetTearState() {
        isDragging = false
        hasSnapped = false
        tearOpacity = 1.0
        lastDragOffset = 0

        // Ensure offset is reset (in case animation didn't complete)
        if !isTearing {
            dragOffset = 0
            backgroundCardRise = 0
        }
    }

    // MARK: - User Data Updates

    private func updateTearsCount(_ count: Int) async {
        guard let user = user else { return }

        let updatedUser = User(
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
            currentStreak: user.currentStreak,
            longestStreak: user.longestStreak,
            lastStreakDate: user.lastStreakDate,
            tipsViewedCount: count,
            onboardingComplete: user.onboardingComplete,
            isSubscribed: user.isSubscribed,
            initialDaysUntilWedding: user.initialDaysUntilWedding,
            createdAt: user.createdAt,
            doesntKnowDate: user.doesntKnowDate,
            doesntKnowLocation: user.doesntKnowLocation,
            dateAddedAt: user.dateAddedAt,
            locationAddedAt: user.locationAddedAt
        )

        try? await authService.updateUser(updatedUser, silent: true)
    }

    private func saveLastViewedDay(_ daysOut: Int) async {
        guard let user = user else { return }

        let updatedUser = User(
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
            lastViewedDay: daysOut,
            currentStreak: user.currentStreak,
            longestStreak: user.longestStreak,
            lastStreakDate: user.lastStreakDate,
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

        try? await authService.updateUser(updatedUser, silent: true)

        // Save the date when position was saved (for new-day reset logic)
        UserDefaults.standard.set(Date(), forKey: Constants.UserDefaultsKeys.lastViewedDate)
    }

    // MARK: - Other Actions

    func shareToInstagram() {
        guard let tip = currentTip else { return }
        print("Sharing tip to Instagram: \(tip.title)")
    }
}
