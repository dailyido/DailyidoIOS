import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure subscription services
        SubscriptionService.shared.configure()

        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Load streak milestones
        Task {
            try? await StreakService.shared.loadMilestones()
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
