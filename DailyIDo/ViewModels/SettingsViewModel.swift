import Foundation
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var name = ""
    @Published var partnerName = ""
    @Published var weddingDate = Date()
    @Published var weddingTown = ""
    @Published var weddingLatitude: Double?
    @Published var weddingLongitude: Double?
    @Published var isTentedWedding = false
    @Published var email = ""

    @Published var isSaving = false
    @Published var isRestoringPurchases = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false

    // Original values to track changes
    private var originalName = ""
    private var originalPartnerName = ""
    private var originalWeddingDate = Date()
    private var originalWeddingTown = ""
    private var originalIsTentedWedding = false
    private var originalEmail = ""

    private let authService = AuthService.shared
    private let subscriptionService = SubscriptionService.shared

    var user: User? { authService.currentUser }

    var hasUnsavedChanges: Bool {
        name != originalName ||
        partnerName != originalPartnerName ||
        !Calendar.current.isDate(weddingDate, inSameDayAs: originalWeddingDate) ||
        weddingTown != originalWeddingTown ||
        isTentedWedding != originalIsTentedWedding ||
        email != originalEmail
    }

    func loadUserData() {
        guard let user = user else {
            print("⚠️ [Settings] loadUserData - NO USER FOUND")
            return
        }

        print("📍 [Settings] loadUserData - user.weddingTown: \(user.weddingTown ?? "nil")")
        print("📍 [Settings] loadUserData - user.weddingLatitude: \(user.weddingLatitude ?? 0)")
        print("📍 [Settings] loadUserData - user.weddingLongitude: \(user.weddingLongitude ?? 0)")

        name = user.name ?? ""
        partnerName = user.partnerName ?? ""
        weddingDate = user.weddingDate ?? Date()
        weddingTown = user.weddingTown ?? ""
        weddingLatitude = user.weddingLatitude
        weddingLongitude = user.weddingLongitude
        isTentedWedding = user.isTentedWedding
        email = user.email ?? ""

        print("📍 [Settings] loadUserData - loaded weddingTown: \(weddingTown)")

        // Store original values to track changes
        originalName = name
        originalPartnerName = partnerName
        originalWeddingDate = weddingDate
        originalWeddingTown = weddingTown
        originalIsTentedWedding = isTentedWedding
        originalEmail = email
    }

    func saveChanges() async {
        guard var user = user else { return }

        isSaving = true

        user = User(
            id: user.id,
            email: email.isEmpty ? user.email : email,
            name: name,
            partnerName: partnerName,
            weddingDate: weddingDate,
            weddingTown: weddingTown,
            weddingLatitude: weddingLatitude,
            weddingLongitude: weddingLongitude,
            isTentedWedding: isTentedWedding,
            timezone: user.timezone,
            lastViewedDay: user.lastViewedDay,
            currentStreak: user.currentStreak,
            longestStreak: user.longestStreak,
            lastStreakDate: user.lastStreakDate,
            tipsViewedCount: user.tipsViewedCount,
            onboardingComplete: user.onboardingComplete,
            isSubscribed: user.isSubscribed,
            initialDaysUntilWedding: user.initialDaysUntilWedding,
            createdAt: user.createdAt
        )

        do {
            try await authService.updateUser(user)
            HapticManager.shared.settingsSave()
            showSuccess = true

            // Track profile update analytics
            AnalyticsService.shared.logProfileUpdated()

            // Hide success message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showSuccess = false
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    func restorePurchases() async {
        isRestoringPurchases = true

        // Track restore purchases analytics
        AnalyticsService.shared.logRestorePurchasesTapped()

        do {
            try await subscriptionService.restorePurchases()
            HapticManager.shared.success()
        } catch {
            showError = true
            errorMessage = "Unable to restore purchases. Please try again."
        }

        isRestoringPurchases = false
    }

    func shareApp() {
        // Track share app analytics
        AnalyticsService.shared.logShareAppTapped()

        let shareText = "I'm using Daily I Do to plan my wedding one tip at a time! Check it out."
        let shareURL = URL(string: "https://apps.apple.com/us/app/daily-i-do/id6757710079")!

        let activityVC = UIActivityViewController(
            activityItems: [shareText, shareURL],
            applicationActivities: nil
        )

        // For iPad
        activityVC.popoverPresentationController?.sourceView = UIView()

        // Get the topmost view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           var topVC = window.rootViewController {
            // Traverse to the topmost presented view controller
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(activityVC, animated: true)
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }

    func restartOnboarding() async {
        guard var user = user else { return }

        // Reset onboarding flag
        user = User(
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
            lastViewedDay: nil,  // Reset last viewed day
            currentStreak: 0,
            longestStreak: user.longestStreak,
            lastStreakDate: nil,
            tipsViewedCount: 0,  // Reset tips viewed
            onboardingComplete: false,  // Reset onboarding
            isSubscribed: user.isSubscribed,
            initialDaysUntilWedding: user.initialDaysUntilWedding,
            createdAt: user.createdAt
        )

        do {
            try await authService.updateUser(user)
            // Clear local onboarding flag
            UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
            // Clear tutorial seen flag so it shows again
            UserDefaults.standard.set(false, forKey: "hasSeenTutorial")
            HapticManager.shared.success()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
}
