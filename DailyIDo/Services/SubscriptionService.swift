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
        print("🔧 [SubscriptionService] ========================================")
        print("🔧 [SubscriptionService] Configuring...")
        print("🔧 [SubscriptionService] RevenueCat API Key: \(Constants.revenueCatAPIKey.prefix(10))...")
        print("🔧 [SubscriptionService] Superwall API Key: \(Constants.superwallAPIKey.prefix(10))...")

        // Configure RevenueCat first
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constants.revenueCatAPIKey)
        print("🔧 [SubscriptionService] RevenueCat configured")

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
        print("🔧 [SubscriptionService] Superwall configured")

        // Set initial subscription status to inactive (will be updated after check)
        // This prevents Superwall from timing out waiting for "unknown" status
        Superwall.shared.subscriptionStatus = .inactive
        print("🔧 [SubscriptionService] Set initial Superwall status to .inactive")
        print("🔧 [SubscriptionService] ========================================")

        // Check initial subscription status
        Task {
            await checkSubscriptionStatus()
        }
    }

    func checkSubscriptionStatus() async {
        print("💳 [Subscription] Checking subscription status...")
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let isPremium = customerInfo.entitlements[Constants.Entitlements.premium]?.isActive == true

            print("💳 [Subscription] Customer ID: \(customerInfo.originalAppUserId)")
            print("💳 [Subscription] Entitlement '\(Constants.Entitlements.premium)' active: \(isPremium)")
            print("💳 [Subscription] All entitlements: \(customerInfo.entitlements.all.keys)")

            // IMPORTANT: Sync subscription status to Superwall
            if isPremium {
                Superwall.shared.subscriptionStatus = .active
                print("💳 [Subscription] Set Superwall status to .active")
            } else {
                Superwall.shared.subscriptionStatus = .inactive
                print("💳 [Subscription] Set Superwall status to .inactive")
            }

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
        print("🎯 [Superwall] ========================================")
        print("🎯 [Superwall] Triggering event: \(Constants.SuperwallEvents.onboardingComplete)")
        print("🎯 [Superwall] User isSubscribed: \(isSubscribed)")
        print("🎯 [Superwall] Superwall configured: \(Superwall.shared)")
        print("🎯 [Superwall] ========================================")

        await withCheckedContinuation { continuation in
            Superwall.shared.register(event: Constants.SuperwallEvents.onboardingComplete) {
                print("🎯 [Superwall] Paywall dismissed or no paywall shown for onboarding_complete")
                continuation.resume()
            }
        }
        // Check subscription status after paywall dismisses
        await checkSubscriptionStatus()
    }

    func showTipLimitPaywall() async {
        print("🎯 [Superwall] ========================================")
        print("🎯 [Superwall] Triggering event: \(Constants.SuperwallEvents.tipLimitReached)")
        print("🎯 [Superwall] User isSubscribed: \(isSubscribed)")
        print("🎯 [Superwall] ========================================")

        await withCheckedContinuation { continuation in
            Superwall.shared.register(event: Constants.SuperwallEvents.tipLimitReached) {
                print("🎯 [Superwall] Paywall dismissed or no paywall shown for tip_limit_reached")
                continuation.resume()
            }
        }
        // Check subscription status after paywall dismisses
        await checkSubscriptionStatus()
    }

    /// Shows a hard paywall that cannot be dismissed (free trial ended after 3 days)
    func showHardPaywall() async {
        print("🎯 [Superwall] ========================================")
        print("🎯 [Superwall] Triggering HARD PAYWALL event: \(Constants.SuperwallEvents.freeTrialEnded)")
        print("🎯 [Superwall] User isSubscribed: \(isSubscribed)")
        print("🎯 [Superwall] ========================================")

        await withCheckedContinuation { continuation in
            Superwall.shared.register(event: Constants.SuperwallEvents.freeTrialEnded) {
                print("🎯 [Superwall] Hard paywall completed for free_trial_ended")
                continuation.resume()
            }
        }
        // Check subscription status after paywall interaction
        await checkSubscriptionStatus()
    }

    /// Shows paywall when pro badge/crown is tapped
    func showProBadgePaywall() async {
        print("🎯 [Superwall] ========================================")
        print("🎯 [Superwall] Triggering event: \(Constants.SuperwallEvents.proBadgeTapped)")
        print("🎯 [Superwall] User isSubscribed: \(isSubscribed)")
        print("🎯 [Superwall] ========================================")

        await withCheckedContinuation { continuation in
            Superwall.shared.register(event: Constants.SuperwallEvents.proBadgeTapped) {
                print("🎯 [Superwall] Paywall dismissed for pro_badge_tapped")
                continuation.resume()
            }
        }
        // Check subscription status after paywall dismisses
        await checkSubscriptionStatus()
    }

    /// Shows paywall when free user tries to swipe back past their limit
    func showSwipeBackLimitPaywall() async {
        print("🎯 [Superwall] ========================================")
        print("🎯 [Superwall] Triggering event: \(Constants.SuperwallEvents.swipeBackLimitReached)")
        print("🎯 [Superwall] User isSubscribed: \(isSubscribed)")
        print("🎯 [Superwall] ========================================")

        await withCheckedContinuation { continuation in
            Superwall.shared.register(event: Constants.SuperwallEvents.swipeBackLimitReached) {
                print("🎯 [Superwall] Paywall dismissed for swipe_back_limit_reached")
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

    /// Set subscriber attributes in RevenueCat for easy identification
    func setUserAttributes(name: String?, partnerName: String?, weddingDate: Date?) {
        var attributes: [String: String] = [:]

        if let name = name, !name.isEmpty {
            Purchases.shared.attribution.setDisplayName(name)
            attributes["name"] = name
        }

        if let partnerName = partnerName, !partnerName.isEmpty {
            attributes["partner_name"] = partnerName
        }

        if let weddingDate = weddingDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            attributes["wedding_date"] = formatter.string(from: weddingDate)
        }

        // Set all custom attributes
        if !attributes.isEmpty {
            Purchases.shared.attribution.setAttributes(attributes)
        }
    }
}
