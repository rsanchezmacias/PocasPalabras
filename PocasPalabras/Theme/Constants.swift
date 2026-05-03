import Foundation

enum Constants {
    enum LifeCalendar {
        static let weeksPerYear = 52
        static let daysPerWeek = 7
        static let canvasPadding: CGFloat = 16
        static let minZoom: CGFloat = 1.0
        static let maxZoom: CGFloat = 8.0
    }
    enum ReminderDefaults {
        static let defaultCustomInterval = 7
        static let defaultWeekday = 2       // Monday
        static let defaultDayOfMonth = 1
    }
}
