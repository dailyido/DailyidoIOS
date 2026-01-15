import Foundation
import SwiftUI

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

    // Velocity tracking
    private var lastDragOffset: CGFloat = 0
    private var lastDragTime: Date = Date()
    private var resistanceHapticTimer: Timer?

    private let tipService = TipService.shared
    private let authService = AuthService.shared
    private let streakService = StreakService.shared
    private let subscriptionService = SubscriptionService.shared

    var user: User? { authService.currentUser }

    // MARK: - Computed Properties

    // The actual days until wedding from TODAY
    var actualDaysUntilWedding: Int {
        guard let weddingDate = user?.weddingDate else { return 0 }
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
    // Users can always browse backwards through available tips
    var canGoBack: Bool {
        // Can go back as long as there are more tips available (up to 365 days out)
        return displayedDaysOut < 365
    }

    // Number of pages that can be torn to catch up
    var pagesToCatchUp: Int {
        max(0, displayedDaysOut - actualDaysUntilWedding)
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

        do {
            try await tipService.loadTips()
            try await streakService.updateStreak()

            calculateInitialPosition()
            updateCurrentTip()
        } catch {
            print("Error loading calendar data: \(error)")
        }

        isLoading = false
    }

    private func calculateInitialPosition() {
        guard let user = user else { return }

        if let lastViewedDay = user.lastViewedDay {
            displayedDaysOut = lastViewedDay
            isFirstDay = false
        } else {
            // First time user - start 3 days back so they can swipe through a few tips
            displayedDaysOut = actualDaysUntilWedding + 3
            isFirstDay = true

            Task {
                await saveLastViewedDay(displayedDaysOut)
            }
        }
    }

    func updateCurrentTip() {
        guard let user = user else { return }

        currentTip = tipService.getTipForDay(
            daysUntilWedding: displayedDaysOut,
            isTentedWedding: user.isTentedWedding
        )
    }

    // Get tip for preview (when dragging to see next/previous)
    func previewTip(for daysOut: Int) -> Tip? {
        guard let user = user else { return nil }
        return tipService.getTipForDay(
            daysUntilWedding: daysOut,
            isTentedWedding: user.isTentedWedding
        )
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
            (translation > minSwipeDistance || velocity > velocityThreshold)

        if shouldCompleteTear {
            completeTear()
        } else if shouldGoBack {
            completeGoBack()
        } else {
            cancelTear()
        }
    }

    // MARK: - Tear Completion

    private func completeTear() {
        guard !isTearing else { return }
        isTearing = true

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

            Task {
                await self.tearPage()
                await MainActor.run {
                    // Reset all state immediately WITHOUT animation
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        self.dragOffset = 0
                        self.tearOpacity = 1.0
                        self.backgroundCardRise = 0
                        self.hasSnapped = false
                        self.isDragging = false
                        self.lastDragOffset = 0
                        self.isTearing = false
                    }
                }
            }
        }
    }

    // MARK: - Go Back Completion

    private func completeGoBack() {
        guard !isTearing else { return }
        isTearing = true

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

            self.goBack()

            // Reset all state immediately WITHOUT animation
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.dragOffset = 0
                self.tearOpacity = 1.0
                self.backgroundCardRise = 0
                self.hasSnapped = false
                self.isDragging = false
                self.lastDragOffset = 0
                self.isTearing = false
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

    // MARK: - Page Actions

    func tearPage() async {
        guard canTear else { return }
        guard let user = user else { return }

        let nextDay = displayedDaysOut - 1
        let mostAdvancedDay = user.lastViewedDay ?? actualDaysUntilWedding

        // Check if this is a NEW tip (a day number lower than their most advanced position)
        let isNewTip = nextDay < mostAdvancedDay

        if isNewTip && !user.isSubscribed && !subscriptionService.isSubscribed {
            let newTearsCount = user.tipsViewedCount + 1

            if newTearsCount > Constants.freeTipLimit {
                // Hard paywall - show and wait for user response
                await subscriptionService.showTipLimitPaywall()

                // After paywall dismisses, check if they subscribed
                // If not, block the swipe
                if !subscriptionService.isSubscribed {
                    return
                }
            }

            await updateTearsCount(newTearsCount)
        }

        // Move forward in time (decrease days out by 1)
        displayedDaysOut -= 1

        // Only update lastViewedDay if this is a new most-advanced position
        if isNewTip {
            await saveLastViewedDay(displayedDaysOut)
        }

        updateCurrentTip()

        if isFirstDay {
            isFirstDay = false
        }
    }

    func goBack() {
        guard canGoBack else { return }

        displayedDaysOut += 1
        updateCurrentTip()

        // User has interacted, so they're no longer on "first day" restriction
        if isFirstDay {
            isFirstDay = false
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
            createdAt: user.createdAt
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
            createdAt: user.createdAt
        )

        try? await authService.updateUser(updatedUser, silent: true)
    }

    // MARK: - Other Actions

    func shareToInstagram() {
        guard let tip = currentTip else { return }
        print("Sharing tip to Instagram: \(tip.title)")
    }
}
