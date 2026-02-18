import Foundation
import StoreKit
import UIKit

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var name = ""
    @Published var partnerName = ""
    @Published var couplePhoto: UIImage?
    @Published var weddingDate = Date().adding(months: 12)
    @Published var doesntKnowDate = false
    @Published var weddingTown = ""
    @Published var weddingVenue = ""
    @Published var weddingLatitude: Double?
    @Published var weddingLongitude: Double?
    @Published var doesntKnowLocation = false
    @Published var isTentedWedding = false
    @Published var feelsPrepered = false
    @Published var referralSource = ""
    @Published var isLoading = false
    @Published var sunsetTime: String?
    @Published var daysUntilWedding: Int = 0

    @Published var showError = false
    @Published var errorMessage = ""

    private let authService = AuthService.shared
    private let notificationService = NotificationService.shared
    private let subscriptionService = SubscriptionService.shared

    private static let couplePhotoKey = "couplePhotoPath"

    let totalSteps = 15

    let loadingMessages = [
        "Creating custom countdown...",
        "Looking up the sunset on your wedding day...",
        "Creating tip calendar...",
        "Organizing wedding checklist..."
    ]

    var canContinue: Bool {
        switch currentStep {
        case 2: return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3: return !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 6: return doesntKnowLocation || (!weddingTown.isEmpty && weddingLatitude != nil && weddingLongitude != nil)
        default: return true
        }
    }

    func nextStep() {
        guard currentStep < totalSteps - 1 else { return }
        HapticManager.shared.buttonTap()
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func selectTentedOption(_ isTented: Bool) {
        isTentedWedding = isTented
        nextStep()
    }

    func selectPreparedness(_ prepared: Bool) {
        feelsPrepered = prepared
    }

    func saveCouplePhoto() {
        guard let photo = couplePhoto else { return }

        // Save to documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("couple_photo.jpg")

        if let data = photo.jpegData(compressionQuality: 0.8) {
            try? data.write(to: photoPath)
            UserDefaults.standard.set(photoPath.path, forKey: Self.couplePhotoKey)
        }
    }

    static func loadCouplePhoto() -> UIImage? {
        // First try loading from saved path in UserDefaults
        if let path = UserDefaults.standard.string(forKey: couplePhotoKey),
           FileManager.default.fileExists(atPath: path),
           let image = UIImage(contentsOfFile: path) {
            return image
        }

        // Fallback: check default location in documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("couple_photo.jpg")
        if FileManager.default.fileExists(atPath: photoPath.path),
           let image = UIImage(contentsOfFile: photoPath.path) {
            // Update UserDefaults with correct path
            UserDefaults.standard.set(photoPath.path, forKey: couplePhotoKey)
            return image
        }

        return nil
    }

    func requestNotificationPermission() async {
        _ = await notificationService.requestAuthorization()
        nextStep()
    }

    func requestAppRating() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        nextStep()
    }

    func startLoadingProcess() async {
        isLoading = true

        // Calculate sunset time
        if let lat = weddingLatitude, let lon = weddingLongitude {
            sunsetTime = SunsetService.shared.formattedSunsetTime(
                for: weddingDate,
                latitude: lat,
                longitude: lon
            )
        }

        // Calculate days until wedding
        daysUntilWedding = Date().daysUntil(weddingDate)

        // Minimum 8 seconds loading time so users can read messages
        try? await Task.sleep(nanoseconds: 8_000_000_000)

        isLoading = false
        nextStep()
    }

    func completeOnboarding() async {
        do {
            // Create local user if not authenticated
            if !authService.isAuthenticated {
                await authService.createLocalUser()
            }

            // Update user profile
            guard var user = authService.currentUser else { return }

            // Calculate initial days until wedding for long engagement logic
            let initialDays = doesntKnowDate ? nil : Date().daysUntil(weddingDate)

            print("📍 [Onboarding] Creating user profile with:")
            print("📍 [Onboarding] - weddingTown: \(weddingTown)")
            print("📍 [Onboarding] - weddingVenue: \(weddingVenue)")
            print("📍 [Onboarding] - weddingLatitude: \(weddingLatitude ?? 0)")
            print("📍 [Onboarding] - weddingLongitude: \(weddingLongitude ?? 0)")

            // If user doesn't know their date, save nil
            let dateToSave: Date? = doesntKnowDate ? nil : weddingDate

            // If user doesn't know their location, save nil
            let townToSave: String? = doesntKnowLocation ? nil : (weddingTown.isEmpty ? nil : weddingTown)
            let latToSave: Double? = doesntKnowLocation ? nil : weddingLatitude
            let lonToSave: Double? = doesntKnowLocation ? nil : weddingLongitude

            // Track when date/location were added (only if they provided them)
            let dateAddedAt: Date? = doesntKnowDate ? nil : Date()
            let locationAddedAt: Date? = doesntKnowLocation ? nil : Date()

            user = User(
                id: user.id,
                email: user.email,
                name: name,
                partnerName: partnerName,
                weddingDate: dateToSave,
                weddingTown: townToSave,
                weddingVenue: weddingVenue.isEmpty ? nil : weddingVenue,
                weddingLatitude: latToSave,
                weddingLongitude: lonToSave,
                isTentedWedding: isTentedWedding,
                timezone: TimeZone.current.identifier,
                lastViewedDay: user.lastViewedDay,
                currentStreak: user.currentStreak,
                longestStreak: user.longestStreak,
                lastStreakDate: user.lastStreakDate,
                tipsViewedCount: user.tipsViewedCount,
                onboardingComplete: true,
                isSubscribed: user.isSubscribed,
                initialDaysUntilWedding: initialDays,
                createdAt: user.createdAt ?? Date(),
                doesntKnowDate: doesntKnowDate,
                doesntKnowLocation: doesntKnowLocation,
                dateAddedAt: dateAddedAt,
                locationAddedAt: locationAddedAt
            )

            try await authService.updateUser(user)

            // Schedule daily notifications if permission granted
            if notificationService.isAuthorized {
                notificationService.scheduleDailyNotification(tipTitle: "Check out your personalized tip!")
                notificationService.scheduleStreakReminder()
            }

            // Identify user in subscription service
            subscriptionService.identifyUser(userId: user.id.uuidString)
            subscriptionService.setUserAttributes(name: name, partnerName: partnerName, weddingDate: weddingDate, weddingVenue: weddingVenue, weddingTown: weddingTown, referralSource: referralSource)
            print("🎯 [Onboarding] Identified user: \(user.id.uuidString) (\(name) & \(partnerName))")
        } catch {
            print("🎯 [Onboarding] Error during profile save: \(error)")
            showError = true
            errorMessage = error.localizedDescription
        }

        // Always show paywall regardless of profile save success/failure
        print("🎯 [Onboarding] About to show onboarding paywall...")
        await subscriptionService.showOnboardingPaywall()
        print("🎯 [Onboarding] Onboarding paywall flow completed")

        HapticManager.shared.success()
    }
}
