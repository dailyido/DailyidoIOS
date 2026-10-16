import UIKit
import UserNotifications
import Paydirt
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure subscription services first — this calls Purchases.configure(),
        // which must run before anything reads Purchases.shared.
        SubscriptionService.shared.configure()

        // Configure Paydirt (v2). Must come after RevenueCat is configured above.
        Paydirt.shared.configure(apiKey: "pk_live_ym9a6i1cGN7zbUXLktpTfzlNqMT5kwWJ")

        // Bridge RevenueCat cancellations into Paydirt. The adapter wraps the
        // RevenueCat delegate (forwarding to SubscriptionService) and auto-presents
        // the trial or paid cancellation form on the next foreground after churn.
        PaydirtRevenueCatAdapter.shared.start(
            cancellationFormId: "6acb5d0a-9e3c-45e6-8cf9-948694ef5923",
            trialCancellationFormId: "d958b793-8e46-4478-95d9-848d6a81a664"
        )

        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Load streak milestones
        Task {
            try? await StreakService.shared.loadMilestones()
        }

        // Start analytics session
        AnalyticsService.shared.startSession()

        // Set up app lifecycle observers for analytics
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            AnalyticsService.shared.appBackgrounded()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            AnalyticsService.shared.appForegrounded()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            AnalyticsService.shared.endSession()
        }

        return true
    }

    // MARK: - Push Notification Handling

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Convert token to string for debugging
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier

        // Handle different notification types
        if identifier == Constants.NotificationIdentifiers.dailyTip {
            // Navigate to calendar view
            NotificationCenter.default.post(
                name: .navigateToCalendar,
                object: nil
            )
        }

        completionHandler()
    }
}

// MARK: - Custom Notification Names

extension Notification.Name {
    static let navigateToCalendar = Notification.Name("navigateToCalendar")
    static let navigateToChecklist = Notification.Name("navigateToChecklist")
}

// MARK: - Paydirt RevenueCat Adapter
//
// Based on Paydirt's v2 IntegrationTemplates/PaydirtRevenueCatAdapter.swift.
// Watches RevenueCat CustomerInfo, detects cancellations (active entitlement that
// won't renew and hasn't expired yet), and routes them into Paydirt, which selects
// the trial vs paid form and presents it on the next foreground (with dedup).
// Started from AppDelegate after both RevenueCat and Paydirt are configured.
final class PaydirtRevenueCatAdapter: NSObject, PurchasesDelegate {
    static let shared = PaydirtRevenueCatAdapter()

    private weak var originalDelegate: PurchasesDelegate?
    private var cancellationFormId: String?
    private var trialCancellationFormId: String?
    private var foregroundObserver: NSObjectProtocol?

    func start(
        cancellationFormId: String? = nil,
        trialCancellationFormId: String? = nil
    ) {
        self.cancellationFormId = cancellationFormId
        self.trialCancellationFormId = trialCancellationFormId
        originalDelegate = Purchases.shared.delegate
        Purchases.shared.delegate = self

        if let foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
        refresh()
    }

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        originalDelegate?.purchases?(purchases, receivedUpdated: customerInfo)
        handle(customerInfo)
    }

    private func refresh() {
        Task {
            guard let customerInfo = try? await Purchases.shared.customerInfo() else { return }
            handle(customerInfo)
        }
    }

    private func handle(_ customerInfo: CustomerInfo) {
        let cancelled = customerInfo.entitlements.active.values
            .filter { entitlement in
                guard let expirationDate = entitlement.expirationDate else { return false }
                return !entitlement.willRenew && expirationDate > Date()
            }
            .sorted { lhs, rhs in
                let left = lhs.unsubscribeDetectedAt ?? lhs.expirationDate ?? .distantPast
                let right = rhs.unsubscribeDetectedAt ?? rhs.expirationDate ?? .distantPast
                return left > right
            }

        guard let entitlement = cancelled.first else { return }

        Task {
            let product = await Purchases.shared.products([entitlement.productIdentifier]).first
            let isTrial = entitlement.periodType == .trial
            let expirationKey = entitlement.expirationDate.map {
                String(Int($0.timeIntervalSince1970))
            } ?? "unknown"

            var details: [String: Any] = [
                "store": String(describing: entitlement.store),
                "is_sandbox": entitlement.isSandbox,
                "ownership_type": String(describing: entitlement.ownershipType),
            ]
            if let value = entitlement.latestPurchaseDate {
                details["latest_purchase_date"] = ISO8601DateFormatter().string(from: value)
            }
            if let value = entitlement.originalPurchaseDate {
                details["original_purchase_date"] = ISO8601DateFormatter().string(from: value)
            }
            if !cancelled.dropFirst().isEmpty {
                details["other_cancelled_product_ids"] = cancelled.dropFirst().map(\.productIdentifier)
            }

            Paydirt.handleSubscriptionCancellation(
                PaydirtSubscriptionCancellation(
                    provider: .revenueCat,
                    productId: entitlement.productIdentifier,
                    entitlementId: entitlement.identifier,
                    userId: customerInfo.originalAppUserId,
                    isTrial: isTrial,
                    periodType: Self.periodTypeName(entitlement.periodType),
                    localizedPrice: product?.localizedPriceString,
                    catalogPrice: product.map { NSDecimalNumber(decimal: $0.price).doubleValue },
                    currencyCode: product?.currencyCode,
                    billingPeriod: product?.subscriptionPeriod.map(Self.billingPeriod),
                    expirationDate: entitlement.expirationDate,
                    cancellationDetectedAt: entitlement.unsubscribeDetectedAt,
                    deduplicationId: "revenuecat_\(entitlement.productIdentifier)_\(expirationKey)",
                    additionalMetadata: details
                ),
                cancellationFormId: cancellationFormId,
                trialCancellationFormId: trialCancellationFormId
            )
        }
    }

    private static func periodTypeName(_ type: PeriodType) -> String {
        switch type {
        case .trial: return "Trial"
        case .intro: return "Intro"
        case .normal: return "Normal"
        case .prepaid: return "Prepaid"
        @unknown default: return "Unknown"
        }
    }

    private static func billingPeriod(_ period: SubscriptionPeriod) -> String {
        let unit: String
        switch period.unit {
        case .day: unit = "day"
        case .week: unit = "week"
        case .month: unit = "month"
        case .year: unit = "year"
        @unknown default: unit = "period"
        }
        return "\(period.value) \(unit)"
    }
}
