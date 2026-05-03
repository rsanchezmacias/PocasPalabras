import Foundation
import SwiftData

enum RecurrenceType: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .custom: "Custom"
        }
    }
}

@Model
final class Reminder {
    var title: String
    var descriptionText: String?
    var nextTriggerAt: Date
    var recurrenceTypeRaw: String
    var recurrenceInterval: Int?
    var weekday: Int?
    var dayOfMonth: Int?
    var active: Bool
    var createdAt: Date
    var deletedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \ReminderOccurrence.reminder)
    var occurrences: [ReminderOccurrence] = []

    var recurrenceType: RecurrenceType {
        get { RecurrenceType(rawValue: recurrenceTypeRaw) ?? .daily }
        set { recurrenceTypeRaw = newValue.rawValue }
    }

    init(
        title: String,
        description: String? = nil,
        nextTriggerAt: Date,
        recurrenceType: RecurrenceType,
        recurrenceInterval: Int? = nil,
        weekday: Int? = nil,
        dayOfMonth: Int? = nil
    ) {
        self.title = title
        self.descriptionText = description
        self.nextTriggerAt = nextTriggerAt
        self.recurrenceTypeRaw = recurrenceType.rawValue
        self.recurrenceInterval = recurrenceInterval
        self.weekday = weekday
        self.dayOfMonth = dayOfMonth
        self.active = true
        self.createdAt = Date()
    }
}
