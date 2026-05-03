import Foundation
import OSLog
import SwiftData

@Observable
final class ReminderFormViewModel {
    var title = ""
    var descriptionText = ""
    var recurrenceType: RecurrenceType = .daily
    var customInterval = Constants.ReminderDefaults.defaultCustomInterval
    var selectedWeekday = Constants.ReminderDefaults.defaultWeekday
    var selectedDayOfMonth = Constants.ReminderDefaults.defaultDayOfMonth
    var triggerDate = Date()

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private let modelContext: ModelContext
    private let notificationManager: NotificationScheduling

    init(modelContext: ModelContext, notificationManager: NotificationScheduling) {
        self.modelContext = modelContext
        self.notificationManager = notificationManager
    }

    func save() {
        let reminder = Reminder(
            title: title.trimmingCharacters(in: .whitespaces),
            description: descriptionText.isEmpty ? nil : descriptionText,
            nextTriggerAt: triggerDate,
            recurrenceType: recurrenceType,
            recurrenceInterval: recurrenceType == .custom ? customInterval : nil,
            weekday: recurrenceType == .weekly ? selectedWeekday : nil,
            dayOfMonth: recurrenceType == .monthly ? selectedDayOfMonth : nil
        )

        modelContext.insert(reminder)
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save new reminder: \(error)")
        }

        notificationManager.scheduleNotification(for: reminder)
    }
}
