import Foundation
import OSLog
import UserNotifications
import SwiftData

/// Manages local notifications for reminders.
///
/// On each app launch, `checkAndFireDueReminders` scans active reminders,
/// fires notifications for any that are overdue, and advances their
/// `nextTriggerAt` using `RecurrenceEngine`.
///
/// iOS local notifications are scheduled via `UNUserNotificationCenter`
/// so they fire even if the app is backgrounded.
@Observable
final class NotificationManager: NotificationScheduling {

    var permissionGranted = false

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            permissionGranted = granted
        } catch {
            AppLogger.notifications.error("Failed to request notification permission: \(error)")
            permissionGranted = false
        }
    }

    func checkAndFireDueReminders(modelContext: ModelContext) async {
        let now = Date()

        let descriptor = FetchDescriptor<Reminder>(
            predicate: #Predicate<Reminder> { reminder in
                reminder.active && reminder.deletedAt == nil && reminder.nextTriggerAt <= now
            }
        )

        let dueReminders: [Reminder]
        do {
            dueReminders = try modelContext.fetch(descriptor)
        } catch {
            AppLogger.notifications.error("Failed to fetch due reminders: \(error)")
            return
        }

        for reminder in dueReminders {
            await scheduleImmediateNotification(for: reminder)

            let nextDate = RecurrenceEngine.calculateNextTrigger(for: reminder, from: now)
            reminder.nextTriggerAt = nextDate

            scheduleNotification(for: reminder)
        }

        do {
            try modelContext.save()
        } catch {
            AppLogger.notifications.error("Failed to save after firing due reminders: \(error)")
        }
    }

    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.descriptionText ?? ""
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.nextTriggerAt
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        let identifier = "reminder-\(reminder.persistentModelID.hashValue)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for reminder: Reminder) {
        let identifier = "reminder-\(reminder.persistentModelID.hashValue)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Private

    private func scheduleImmediateNotification(for reminder: Reminder) async {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.descriptionText ?? "Reminder due"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "immediate-\(reminder.persistentModelID.hashValue)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.notifications.error("Failed to schedule immediate notification: \(error)")
        }
    }
}
