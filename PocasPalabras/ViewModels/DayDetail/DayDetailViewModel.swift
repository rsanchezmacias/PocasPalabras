import Foundation
import OSLog
import SwiftData

@Observable
final class DayDetailViewModel {
    var entry: DayEntry?
    var noteText = ""

    private let modelContext: ModelContext
    let date: Date

    init(modelContext: ModelContext, date: Date) {
        self.modelContext = modelContext
        self.date = date
    }

    func loadEntry() {
        let targetDate = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate<DayEntry> { $0.date == targetDate && $0.deletedAt == nil }
        )
        do {
            entry = try modelContext.fetch(descriptor).first
        } catch {
            AppLogger.dataAccess.error("Failed to load day entry: \(error)")
        }
        noteText = entry?.note ?? ""
    }

    func saveNote() {
        let trimmed = noteText
        if let entry {
            entry.note = trimmed
        } else if !trimmed.isEmpty {
            let newEntry = DayEntry(date: date, note: trimmed)
            modelContext.insert(newEntry)
            entry = newEntry
        }
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save note: \(error)")
        }
    }
}
