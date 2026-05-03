import Foundation
import SwiftData

@Model
final class Todo {
    var text: String
    var completed: Bool
    var createdAt: Date
    var deletedAt: Date?

    var dayEntry: DayEntry?

    init(text: String, completed: Bool = false) {
        self.text = text
        self.completed = completed
        self.createdAt = Date()
    }
}
