import Foundation

@Observable
final class LifeCalendarViewModel {
    var viewMode: CalendarViewMode = .month
    var selectedDate: Date?

    let engine: LifeCalendarEngine

    init(engine: LifeCalendarEngine) {
        self.engine = engine
    }
}
