import Foundation
import SwiftData

@Model
final class DayEntry {
    var date: Date
    var note: String
    var createdAt: Date
    var deletedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \Todo.dayEntry)
    var todos: [Todo]

    init(date: Date, note: String = "") {
        self.date = Calendar.current.startOfDay(for: date)
        self.note = note
        self.createdAt = Date()
        self.todos = []
    }
}
