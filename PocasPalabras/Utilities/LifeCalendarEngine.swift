import Foundation

struct LifeCalendarEngine {
    let dateOfBirth: Date
    let lifeExpectancy: Int

    private var calendar: Calendar { Calendar.current }

    var endOfLifeDate: Date {
        calendar.date(byAdding: .year, value: lifeExpectancy, to: dateOfBirth)!
    }

    var totalDays: Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: dateOfBirth), to: calendar.startOfDay(for: endOfLifeDate)).day ?? 0
    }

    var daysLived: Int {
        let today = calendar.startOfDay(for: Date())
        let birth = calendar.startOfDay(for: dateOfBirth)
        return max(0, calendar.dateComponents([.day], from: birth, to: today).day ?? 0)
    }

    var daysRemaining: Int {
        max(0, totalDays - daysLived)
    }

    var progressPercentage: Double {
        guard totalDays > 0 else { return 0 }
        return min(1.0, Double(daysLived) / Double(totalDays))
    }

    var weeksLived: Int {
        daysLived / Constants.LifeCalendar.daysPerWeek
    }

    var totalWeeks: Int {
        totalDays / Constants.LifeCalendar.daysPerWeek
    }

    var monthsLived: Int {
        let today = calendar.startOfDay(for: Date())
        let birth = calendar.startOfDay(for: dateOfBirth)
        return max(0, calendar.dateComponents([.month], from: birth, to: today).month ?? 0)
    }

    var totalMonths: Int {
        lifeExpectancy * 12
    }

    var yearsLived: Int {
        let today = calendar.startOfDay(for: Date())
        let birth = calendar.startOfDay(for: dateOfBirth)
        return max(0, calendar.dateComponents([.year], from: birth, to: today).year ?? 0)
    }

    /// Returns the date for a given week index in the life calendar (0-based).
    func dateForWeek(_ weekIndex: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: weekIndex, to: calendar.startOfDay(for: dateOfBirth))!
    }

    /// Inverse of `dateForWeek(_:)`. Returns the week index for a given date.
    func weekIndex(for date: Date) -> Int {
        let birth = calendar.startOfDay(for: dateOfBirth)
        let target = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: birth, to: target).day ?? 0
        return days / Constants.LifeCalendar.daysPerWeek
    }

    /// Determines whether a given date falls in the past, is today, or is in the future.
    enum DayStatus {
        case past, today, future
    }

    func statusForDate(_ date: Date) -> DayStatus {
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        if target < today { return .past }
        if target == today { return .today }
        return .future
    }

    func statusForWeek(_ weekIndex: Int) -> DayStatus {
        let weekStart = dateForWeek(weekIndex)
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        let today = calendar.startOfDay(for: Date())

        if weekEnd < today { return .past }
        if weekStart <= today && today <= weekEnd { return .today }
        return .future
    }
}
