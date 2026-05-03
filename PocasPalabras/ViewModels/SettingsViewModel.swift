import Foundation
import OSLog
import SwiftData

@Observable
final class SettingsViewModel {
    let profile: UserProfile
    private let modelContext: ModelContext

    var engine: LifeCalendarEngine {
        LifeCalendarEngine(dateOfBirth: profile.dateOfBirth, lifeExpectancy: profile.lifeExpectancy)
    }

    var dobFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }

    var lifeExpectancy: Int {
        get { profile.lifeExpectancy }
        set {
            profile.lifeExpectancy = newValue
            do {
                try modelContext.save()
            } catch {
                AppLogger.dataAccess.error("Failed to save life expectancy: \(error)")
            }
        }
    }

    init(modelContext: ModelContext, profile: UserProfile) {
        self.modelContext = modelContext
        self.profile = profile
    }
}
