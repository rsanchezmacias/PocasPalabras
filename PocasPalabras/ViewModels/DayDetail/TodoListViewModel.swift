import Foundation
import OSLog
import SwiftData

@Observable
final class TodoListViewModel {
    var newTodoText = ""
    var entry: DayEntry?

    var activeTodos: [Todo] {
        (entry?.todos ?? []).filter { $0.deletedAt == nil }
    }

    private let modelContext: ModelContext
    private let date: Date

    init(modelContext: ModelContext, entry: DayEntry?, date: Date) {
        self.modelContext = modelContext
        self.entry = entry
        self.date = date
    }

    func updateEntry(_ newEntry: DayEntry?) {
        entry = newEntry
    }

    func addTodo() {
        let trimmed = newTodoText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let dayEntry = ensureEntry()
        let todo = Todo(text: trimmed)
        todo.dayEntry = dayEntry
        dayEntry.todos.append(todo)
        modelContext.insert(todo)
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save new todo: \(error)")
        }
        newTodoText = ""
    }

    func toggleTodo(_ todo: Todo) {
        todo.completed.toggle()
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save todo toggle: \(error)")
        }
    }

    func deleteTodo(_ todo: Todo) {
        todo.deletedAt = Date()
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save todo deletion: \(error)")
        }
    }

    private func ensureEntry() -> DayEntry {
        if let entry { return entry }
        let newEntry = DayEntry(date: date)
        modelContext.insert(newEntry)
        entry = newEntry
        return newEntry
    }
}
