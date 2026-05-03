import Foundation
import OSLog
import SwiftData

@Observable
final class ReminderListViewModel {
    var reminders: [Reminder] = []
    var showForm = false

    private let modelContext: ModelContext
    private let completionService: ReminderCompletionService

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.completionService = ReminderCompletionService(modelContext: modelContext, date: Date())
    }

    func fetchReminders() {
        let descriptor = FetchDescriptor<Reminder>(
            predicate: #Predicate<Reminder> { $0.deletedAt == nil && $0.active },
            sortBy: [SortDescriptor(\Reminder.nextTriggerAt)]
        )
        do {
            reminders = try modelContext.fetch(descriptor)
        } catch {
            AppLogger.dataAccess.error("Failed to fetch reminders: \(error)")
            reminders = []
        }
        completionService.refreshCompletionStates(for: reminders)
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

    func isCompletedToday(_ reminder: Reminder) -> Bool {
        completionService.isCompleted(reminder)
    }

    func toggleCompletionToday(_ reminder: Reminder) {
        completionService.toggleCompletion(reminder)
    }
}
