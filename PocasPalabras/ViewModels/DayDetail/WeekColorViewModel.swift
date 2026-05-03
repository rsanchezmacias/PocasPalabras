import Foundation
import OSLog
import SwiftData

@Observable
final class WeekColorViewModel {
    var selectedColorHex: String?
    var weekIndex: Int = 0

    private let modelContext: ModelContext
    private let date: Date

    init(modelContext: ModelContext, date: Date) {
        self.modelContext = modelContext
        self.date = date
    }

    func loadWeekColor() {
        let profileDescriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate<UserProfile> { $0.deletedAt == nil }
        )
        do {
            guard let profile = try modelContext.fetch(profileDescriptor).first else { return }
            let engine = LifeCalendarEngine(dateOfBirth: profile.dateOfBirth, lifeExpectancy: profile.lifeExpectancy)
            let birth = Calendar.current.startOfDay(for: engine.dateOfBirth)
            let target = Calendar.current.startOfDay(for: date)
            weekIndex = max(0, Calendar.current.dateComponents([.weekOfYear], from: birth, to: target).weekOfYear ?? 0)

            let wi = weekIndex
            let descriptor = FetchDescriptor<WeekColor>(
                predicate: #Predicate<WeekColor> { $0.weekIndex == wi }
            )
            if let existing = try modelContext.fetch(descriptor).first {
                selectedColorHex = existing.colorHex
            }
        } catch {
            AppLogger.dataAccess.error("Failed to load week color: \(error)")
        }
    }

    func saveWeekColor() {
        let wi = weekIndex
        let descriptor = FetchDescriptor<WeekColor>(
            predicate: #Predicate<WeekColor> { $0.weekIndex == wi }
        )
        do {
            let existing = try modelContext.fetch(descriptor).first

            if let hex = selectedColorHex {
                if let existing {
                    existing.colorHex = hex
                } else {
                    let marker = WeekColor(weekIndex: weekIndex, colorHex: hex)
                    modelContext.insert(marker)
                }
            } else {
                if let existing {
                    modelContext.delete(existing)
                }
            }
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save week color: \(error)")
        }
    }
}
