import Foundation
import OSLog
import SwiftUI
import SwiftData

struct YearProgress {
    let daysPassed: Int
    let totalDays: Int
    let progress: Double

    var daysRemaining: Int { totalDays - daysPassed }
}

@Observable
final class YearGridViewModel {
    var displayedYear: Int = Calendar.current.component(.year, from: Date())

    let engine: LifeCalendarEngine
    private let modelContext: ModelContext

    private var calendar: Calendar { Calendar.current }

    private var weekColors: [WeekColor] = []

    var colorLookup: [Int: String] {
        Dictionary(weekColors.map { ($0.weekIndex, $0.colorHex) }, uniquingKeysWith: { _, last in last })
    }

    init(modelContext: ModelContext, engine: LifeCalendarEngine) {
        self.modelContext = modelContext
        self.engine = engine
    }

    func fetchWeekColors() {
        let descriptor = FetchDescriptor<WeekColor>()
        do {
            weekColors = try modelContext.fetch(descriptor)
        } catch {
            AppLogger.dataAccess.error("Failed to fetch week colors for year grid: \(error)")
            weekColors = []
        }
    }

    func colorForDate(_ date: Date) -> Color? {
        let index = engine.weekIndex(for: date)
        guard let hex = colorLookup[index] else { return nil }
        return Color(hexString: hex)
    }

    var yearProgress: YearProgress {
        let yearStart = calendar.date(from: DateComponents(year: displayedYear, month: 1, day: 1))!
        let yearEnd = calendar.date(from: DateComponents(year: displayedYear + 1, month: 1, day: 1))!
        let today = calendar.startOfDay(for: Date())
        let totalDays = calendar.dateComponents([.day], from: yearStart, to: yearEnd).day ?? 365
        let daysPassed: Int
        if today < yearStart {
            daysPassed = 0
        } else if today >= yearEnd {
            daysPassed = totalDays
        } else {
            daysPassed = calendar.dateComponents([.day], from: yearStart, to: today).day ?? 0
        }
        let progress = Double(daysPassed) / Double(totalDays)
        return YearProgress(daysPassed: daysPassed, totalDays: totalDays, progress: progress)
    }

    func previousYear() {
        displayedYear -= 1
    }

    func nextYear() {
        displayedYear += 1
    }
}
