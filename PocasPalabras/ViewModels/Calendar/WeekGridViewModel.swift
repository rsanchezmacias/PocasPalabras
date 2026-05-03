import Foundation
import OSLog
import SwiftData

@Observable
final class WeekGridViewModel {
    var focusedDate: Date = Calendar.current.startOfDay(for: Date())
    var focusedEntry: DayEntry?

    let engine: LifeCalendarEngine
    private let modelContext: ModelContext

    private var calendar: Calendar { Calendar.current }

    var weekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }

    init(modelContext: ModelContext, engine: LifeCalendarEngine) {
        self.modelContext = modelContext
        self.engine = engine
    }

    func loadEntry(for date: Date) {
        let target = calendar.startOfDay(for: date)
        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate<DayEntry> { $0.date == target && $0.deletedAt == nil }
        )
        do {
            focusedEntry = try modelContext.fetch(descriptor).first
        } catch {
            AppLogger.dataAccess.error("Failed to load entry for week grid: \(error)")
            focusedEntry = nil
        }
    }

    func hasContent(on date: Date) -> Bool {
        let target = calendar.startOfDay(for: date)
        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate<DayEntry> { $0.date == target && $0.deletedAt == nil }
        )
        do {
            guard let entry = try modelContext.fetch(descriptor).first else { return false }
            if !entry.note.isEmpty { return true }
            if entry.todos.contains(where: { $0.deletedAt == nil }) { return true }
            return false
        } catch {
            AppLogger.dataAccess.error("Failed to check content for week grid: \(error)")
            return false
        }
    }

    func selectDate(_ date: Date) {
        focusedDate = date
        loadEntry(for: date)
    }
}
