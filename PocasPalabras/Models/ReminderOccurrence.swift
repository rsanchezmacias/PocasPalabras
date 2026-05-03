import Foundation
import SwiftData

@Model
final class ReminderOccurrence {
    var reminder: Reminder?
    var date: Date
    var completed: Bool
    var completedAt: Date?
    var createdAt: Date

    init(reminder: Reminder, date: Date) {
        self.reminder = reminder
        self.date = Calendar.current.startOfDay(for: date)
        self.completed = true
        self.completedAt = Date()
        self.createdAt = Date()
    }
}
