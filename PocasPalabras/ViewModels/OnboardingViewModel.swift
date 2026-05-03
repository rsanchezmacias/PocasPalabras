import Foundation
import OSLog
import SwiftData

@Observable
final class OnboardingViewModel {
    var name = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -30, to: Date())!
    var lifeExpectancy = 85

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && dateOfBirth < Date()
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createProfile() {
        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            dateOfBirth: dateOfBirth,
            lifeExpectancy: lifeExpectancy
        )
        modelContext.insert(profile)
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save new profile: \(error)")
        }
    }
}
