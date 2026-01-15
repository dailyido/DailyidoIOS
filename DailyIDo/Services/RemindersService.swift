import EventKit
import Foundation

final class RemindersService {
    static let shared = RemindersService()

    private let eventStore = EKEventStore()

    private init() {}

    /// Check if we have permission to access reminders
    var hasPermission: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
    }

    /// Request permission to access reminders
    func requestPermission() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToReminders()
            } else {
                return try await eventStore.requestAccess(to: .reminder)
            }
        } catch {
            print("Error requesting reminders permission: \(error)")
            return false
        }
    }

    /// Create a reminder with the given title and notes
    func createReminder(title: String, notes: String, dueDate: Date? = nil) async -> Result<Void, RemindersError> {
        // Check/request permission first
        guard hasPermission || await requestPermission() else {
            return .failure(.permissionDenied)
        }

        // Get the default reminders calendar
        guard let calendar = eventStore.defaultCalendarForNewReminders() else {
            return .failure(.noDefaultCalendar)
        }

        // Create the reminder
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = calendar

        // Set due date if provided (default to tomorrow at 9am)
        if let dueDate = dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        } else {
            // Default to tomorrow at 9am
            var components = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: Date().addingTimeInterval(86400)
            )
            components.hour = 9
            components.minute = 0
            reminder.dueDateComponents = components
        }

        // Add an alarm for the due date
        if reminder.dueDateComponents != nil {
            let alarm = EKAlarm(relativeOffset: 0) // Alert at due time
            reminder.addAlarm(alarm)
        }

        // Save the reminder
        do {
            try eventStore.save(reminder, commit: true)
            return .success(())
        } catch {
            print("Error saving reminder: \(error)")
            return .failure(.saveFailed(error))
        }
    }
}

enum RemindersError: Error, LocalizedError {
    case permissionDenied
    case noDefaultCalendar
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission to access Reminders was denied. Please enable it in Settings."
        case .noDefaultCalendar:
            return "No default reminders list found. Please set up Reminders app first."
        case .saveFailed(let error):
            return "Failed to save reminder: \(error.localizedDescription)"
        }
    }
}
