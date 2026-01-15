import Foundation
import UserNotifications

final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    private let center = UNUserNotificationCenter.current()
    private let supabase = SupabaseService.shared

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()

        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])

            await MainActor.run {
                self.isAuthorized = granted
            }

            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func scheduleDailyNotification(tipTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Today's Wedding Tip"
        content.body = tipTitle
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = Constants.dailyNotificationHour
        dateComponents.minute = Constants.dailyNotificationMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Constants.NotificationIdentifiers.dailyTip,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error)")
            }
        }
    }

    func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    func syncScheduledNotifications(userId: UUID, weddingDate: Date?, signupDate: Date?) async {
        guard let weddingDate = weddingDate else { return }

        do {
            let notifications = try await supabase.fetchScheduledNotifications()
            let scheduledIds = UserDefaults.standard.stringArray(forKey: Constants.UserDefaultsKeys.scheduledNotificationIds) ?? []
            var newScheduledIds = scheduledIds

            for notification in notifications {
                let notificationId = notification.id.uuidString

                // Skip if already scheduled
                guard !scheduledIds.contains(notificationId) else { continue }

                var scheduleDate: Date?

                switch notification.triggerType {
                case NotificationTriggerType.date.rawValue:
                    scheduleDate = notification.triggerDate

                case NotificationTriggerType.daysOut.rawValue:
                    if let days = notification.triggerDays {
                        scheduleDate = weddingDate.adding(days: -days)
                    }

                case NotificationTriggerType.daysAfterSignup.rawValue:
                    if let days = notification.triggerDays, let signup = signupDate {
                        scheduleDate = signup.adding(days: days)
                    }

                default:
                    break
                }

                if let date = scheduleDate, date > Date() {
                    // Set notification time to 9 AM
                    var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    components.hour = Constants.dailyNotificationHour
                    components.minute = Constants.dailyNotificationMinute

                    if let finalDate = Calendar.current.date(from: components) {
                        scheduleNotification(
                            id: notificationId,
                            title: notification.title,
                            body: notification.body,
                            date: finalDate
                        )
                        newScheduledIds.append(notificationId)
                    }
                }
            }

            UserDefaults.standard.set(newScheduledIds, forKey: Constants.UserDefaultsKeys.scheduledNotificationIds)
        } catch {
            print("Error syncing scheduled notifications: \(error)")
        }
    }

    func scheduleStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Don't break your streak!"
        content.body = "Open the app to see today's wedding tip and keep your streak going."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20  // 8 PM reminder
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Constants.NotificationIdentifiers.streakReminder,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling streak reminder: \(error)")
            }
        }
    }
}
