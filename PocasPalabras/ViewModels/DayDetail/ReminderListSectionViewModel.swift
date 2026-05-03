import Foundation
import OSLog
import SwiftData

@Observable
final class ReminderListSectionViewModel {
    var allReminders: [Reminder] = []

    private let modelContext: ModelContext
    private let date: Date
    private let completionService: ReminderCompletionService

    var remindersForDate: [Reminder] {
        allReminders.filter { RecurrenceEngine.reminderApplies($0, toDate: date) }
    }

    init(modelContext: ModelContext, date: Date) {
        self.modelContext = modelContext
        self.date = date
        self.completionService = ReminderCompletionService(modelContext: modelContext, date: date)
    }

    func fetchReminders() {
        let descriptor = FetchDescriptor<Reminder>(
            predicate: #Predicate<Reminder> {
                $0.deletedAt == nil && $0.active
            },
            sortBy: [SortDescriptor(\Reminder.nextTriggerAt)]
        )
        do {
            allReminders = try modelContext.fetch(descriptor)
        } catch {
            AppLogger.dataAccess.error("Failed to fetch reminders for section: \(error)")
            allReminders = []
        }
        completionService.refreshCompletionStates(for: allReminders)
    }

    func isCompleted(_ reminder: Reminder) -> Bool {
        completionService.isCompleted(reminder)
    }

    func toggleCompletion(_ reminder: Reminder) {
        completionService.toggleCompletion(reminder)
    }

    func deleteReminder(_ reminder: Reminder) {
        reminder.deletedAt = Date()
        reminder.active = false
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to delete reminder: \(error)")
        }
        fetchReminders()
    }
}
