import Foundation
import OSLog
import SwiftData

@Observable
final class ReminderCompletionService {
    var completionStates: [PersistentIdentifier: Bool] = [:]

    private let modelContext: ModelContext
    private let date: Date

    init(modelContext: ModelContext, date: Date) {
        self.modelContext = modelContext
        self.date = date
    }

    func isCompleted(_ reminder: Reminder) -> Bool {
        completionStates[reminder.persistentModelID] ?? false
    }

    func toggleCompletion(_ reminder: Reminder) {
        if let existing = findOccurrence(for: reminder) {
            modelContext.delete(existing)
        } else {
            let occurrence = ReminderOccurrence(reminder: reminder, date: date)
            modelContext.insert(occurrence)
        }
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save reminder completion toggle: \(error)")
        }
        completionStates[reminder.persistentModelID] = findOccurrence(for: reminder) != nil
    }

    func refreshCompletionStates(for reminders: [Reminder]) {
        var states: [PersistentIdentifier: Bool] = [:]
        for reminder in reminders {
            states[reminder.persistentModelID] = findOccurrence(for: reminder) != nil
        }
        completionStates = states
    }

    private func findOccurrence(for reminder: Reminder) -> ReminderOccurrence? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let reminderID = reminder.persistentModelID
        let descriptor = FetchDescriptor<ReminderOccurrence>(
            predicate: #Predicate<ReminderOccurrence> {
                $0.reminder?.persistentModelID == reminderID
                    && $0.date >= startOfDay
                    && $0.date < nextDay
            }
        )
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            AppLogger.dataAccess.error("Failed to fetch reminder occurrence: \(error)")
            return nil
        }
    }
}
