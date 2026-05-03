import Foundation
import OSLog
import SwiftData

@Observable
final class MonthGridViewModel {
    var displayedMonth = Date()

    let engine: LifeCalendarEngine
    private let modelContext: ModelContext

    private var calendar: Calendar { Calendar.current }

    private(set) var contentDates: Set<Date> = []

    var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: displayedMonth)
    }

    var daysInMonth: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps) else { return [] }
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range {
            var dc = comps
            dc.day = day
            days.append(calendar.date(from: dc))
        }
        return days
    }

    init(modelContext: ModelContext, engine: LifeCalendarEngine) {
        self.modelContext = modelContext
        self.engine = engine
    }

    func fetchContentDates() {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let monthStart = calendar.date(from: comps),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return }

        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate<DayEntry> {
                $0.deletedAt == nil && $0.date >= monthStart && $0.date < monthEnd
            }
        )

        let entries: [DayEntry]
        do {
            entries = try modelContext.fetch(descriptor)
        } catch {
            AppLogger.dataAccess.error("Failed to fetch content dates for month grid: \(error)")
            contentDates = []
            return
        }

        var dates = Set<Date>()
        for entry in entries {
            let hasNote = !entry.note.isEmpty
            let hasTodos = entry.todos.contains(where: { $0.deletedAt == nil })
            if hasNote || hasTodos {
                dates.insert(calendar.startOfDay(for: entry.date))
            }
        }
        contentDates = dates
    }

    func hasContent(on date: Date) -> Bool {
        contentDates.contains(calendar.startOfDay(for: date))
    }

    func previousMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
        fetchContentDates()
    }

    func nextMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
        fetchContentDates()
    }

}
