import Foundation
import OSLog

/// Computes the next trigger date for a reminder based on its recurrence rule.
///
/// Recurrence logic:
/// - **Daily**: next day from `fromDate`
/// - **Weekly**: next occurrence of the specified weekday after `fromDate`
/// - **Monthly**: next occurrence of the specified day-of-month after `fromDate`.
///   If the day exceeds the month's length, it rolls to the last valid day.
/// - **Custom**: `fromDate` + `recurrenceInterval` days
///
/// This is a pure, deterministic function with no side effects.
enum RecurrenceEngine {
    
    static func calculateNextTrigger(for reminder: Reminder, from fromDate: Date) -> Date {
        let calendar = Calendar.current
        let from = calendar.startOfDay(for: fromDate)
        let reminderHourAndMinutes = calendar.dateComponents([.hour, .minute], from: reminder.nextTriggerAt)
        let fromWithTime = calendar.date(byAdding: reminderHourAndMinutes, to: from)
        
        guard let fromWithTime else {
            AppLogger.notifications.warning("Failed to calculate next reminder date for \(reminder.title)")
            return reminder.nextTriggerAt
        }
        
        switch reminder.recurrenceType {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: fromWithTime)!

        case .weekly:
            return nextWeeklyOccurrence(weekday: reminder.weekday, from: fromWithTime, calendar: calendar)

        case .monthly:
            return nextMonthlyOccurrence(dayOfMonth: reminder.dayOfMonth, from: fromWithTime, calendar: calendar)

        case .custom:
            let interval = max(1, reminder.recurrenceInterval ?? 1)
            return calendar.date(byAdding: .day, value: interval, to: fromWithTime)!
        }
    }

    private static func nextWeeklyOccurrence(weekday: Int?, from: Date, calendar: Calendar) -> Date {
        guard let targetWeekday = weekday else {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: from)!
        }

        // Walk forward day-by-day (max 7 iterations) to find the next matching weekday.
        var candidate = calendar.date(byAdding: .day, value: 1, to: from)!
        for _ in 0..<7 {
            if calendar.component(.weekday, from: candidate) == targetWeekday {
                return candidate
            }
            candidate = calendar.date(byAdding: .day, value: 1, to: candidate)!
        }
        // Fallback — shouldn't reach here.
        return calendar.date(byAdding: .weekOfYear, value: 1, to: from)!
    }

    private static func nextMonthlyOccurrence(dayOfMonth: Int?, from: Date, calendar: Calendar) -> Date {
        guard let targetDay = dayOfMonth else {
            return calendar.date(byAdding: .month, value: 1, to: from)!
        }

        let currentComponents = calendar.dateComponents([.year, .month, .day], from: from)
        let currentDay = currentComponents.day ?? 1
        let fromHourAndMinutes = calendar.dateComponents([.hour, .minute], from: from)
        let fallbackDate = calendar.date(byAdding: .month, value: 1, to: from)!
        
        // Try current month first (if the target day hasn't passed yet).
        if targetDay > currentDay {
            if let candidate = dateWithDay(targetDay, year: currentComponents.year!, month: currentComponents.month!, calendar: calendar) {
                return calendar.date(byAdding: fromHourAndMinutes, to: candidate) ?? fallbackDate
            }
        }

        // Otherwise, move to next month.
        var year = currentComponents.year!
        var month = currentComponents.month! + 1
        if month > 12 {
            month = 1
            year += 1
        }

        if let candidate = dateWithDay(targetDay, year: year, month: month, calendar: calendar) {
            return calendar.date(byAdding: fromHourAndMinutes, to: candidate) ?? fallbackDate
        }

        // Final fallback.
        return fallbackDate
    }

    /// Returns `true` when the reminder's recurrence pattern includes `date`.
    ///
    /// Unlike `calculateNextTrigger` (which looks forward), this checks whether a
    /// given date is one of the recurring occurrences — regardless of the current
    /// value of `nextTriggerAt`.
    static func reminderApplies(_ reminder: Reminder, toDate date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        let createdDay = calendar.startOfDay(for: reminder.createdAt)

        // Don't match dates before the reminder existed.
        guard targetDay >= createdDay else { return false }

        switch reminder.recurrenceType {
        case .daily:
            return true
        case .weekly:
            let targetWeekday = calendar.component(.weekday, from: date)
            let reminderWeekday = reminder.weekday ?? calendar.component(.weekday, from: reminder.createdAt)
            return targetWeekday == reminderWeekday
        case .monthly:
            let targetDayOfMonth = calendar.component(.day, from: date)
            let reminderDayOfMonth = reminder.dayOfMonth ?? calendar.component(.day, from: reminder.createdAt)
            return targetDayOfMonth == reminderDayOfMonth
        case .custom:
            let interval = max(1, reminder.recurrenceInterval ?? 1)
            let daysBetween = calendar.dateComponents([.day], from: createdDay, to: targetDay).day ?? 0
            return daysBetween % interval == 0
        }
    }

    /// Creates a date for a given day/month/year, clamping to the last valid day of the month.
    private static func dateWithDay(_ day: Int, year: Int, month: Int, calendar: Calendar) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let firstOfMonth = calendar.date(from: components) else { return nil }
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let clampedDay = min(day, range.upperBound - 1)

        components.day = clampedDay
        return calendar.date(from: components)
    }
}
