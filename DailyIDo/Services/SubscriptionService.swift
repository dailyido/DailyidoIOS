import Foundation
import RevenueCat
import SuperwallKit

final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    @Published var isSubscribed = false
    @Published var isLoading = true

    private var purchaseController: RCPurchaseController?

    private init() {}

    func configure() {
        // Configure RevenueCat first
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constants.revenueCatAPIKey)

        // Create purchase controller for Superwall + RevenueCat integration
        let controller = RCPurchaseController()
        self.purchaseController = controller

        // Configure Superwall with the purchase controller and debug logging
        let options = SuperwallOptions()
        options.logging.level = .debug

        Superwall.configure(
            apiKey: Constants.superwallAPIKey,
            purchaseController: controller,
            options: options
        )

        // Check initial subscription status
        Task {
            await checkSubscriptionStatus()
        }
    }

    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let isPremium = customerInfo.entitlements[Constants.Entitlements.premium]?.isActive == true

            await MainActor.run {
                self.isSubscribed = isPremium
                self.isLoading = false
            }

            // Sync with user record
            if var user = AuthService.shared.currentUser, user.isSubscribed != isPremium {
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
                    lastViewedDay: user.lastViewedDay,
                    currentStreak: user.currentStreak,
                    longestStreak: user.longestStreak,
                    lastStreakDate: user.lastStreakDate,
                    tipsViewedCount: user.tipsViewedCount,
                    onboardingComplete: user.onboardingComplete,
                    isSubscribed: isPremium,
                    initialDaysUntilWedding: user.initialDaysUntilWedding,
                    createdAt: user.createdAt
                )
                try? await AuthService.shared.updateUser(user)
            }
        } catch {
            print("Error checking subscription status: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    func showPaywall(event: String) {
        Superwall.shared.register(event: event)
    }

    func showOnboardingPaywall() async {
        print("🎯 [Superwall] Triggering event: \(Constants.SuperwallEvents.onboardingComplete)")
        await withCheckedContinuation { continuation in
            Superwall.shared.register(event: Constants.SuperwallEvents.onboardingComplete) {
                print("🎯 [Superwall] Paywall dismissed or no paywall shown")
                continuation.resume()
            }
        }
        // Check subscription status after paywall dismisses
        await checkSubscriptionStatus()
    }

    func showTipLimitPaywall() async {
        await withCheckedContinuation { continuation in
            Superwall.shared.register(event: Constants.SuperwallEvents.tipLimitReached) {
                continuation.resume()
            }
        }
        // Check subscription status after paywall dismisses
        await checkSubscriptionStatus()
    }

    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        let isPremium = customerInfo.entitlements[Constants.Entitlements.premium]?.isActive == true

        await MainActor.run {
            self.isSubscribed = isPremium
        }

        // Sync with user record
        if var user = AuthService.shared.currentUser {
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
                lastViewedDay: user.lastViewedDay,
                currentStreak: user.currentStreak,
                longestStreak: user.longestStreak,
                lastStreakDate: user.lastStreakDate,
                tipsViewedCount: user.tipsViewedCount,
                onboardingComplete: user.onboardingComplete,
                isSubscribed: isPremium,
                initialDaysUntilWedding: user.initialDaysUntilWedding,
                createdAt: user.createdAt
            )
            try await AuthService.shared.updateUser(user)
        }
    }

    func identifyUser(userId: String) {
        Purchases.shared.logIn(userId) { _, _, _ in }

        // Identify user in Superwall
        Superwall.shared.identify(userId: userId)
    }
}
