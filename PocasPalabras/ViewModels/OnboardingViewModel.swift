import Foundation
import OSLog
import SwiftData

@Observable
final class OnboardingViewModel {
    var name: String
    var dateOfBirth: Date
    var lifeExpectancy: Int

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && dateOfBirth < Date()
    }

    var title: String {
        existingProfile != nil ? "Edit profile" : "En pocas palabras"
    }

    var subtitle: String {
        existingProfile != nil
            ? "Update your details below."
            : "A reflective life calendar.\nLet's begin with a few details."
    }

    var actionLabel: String {
        existingProfile != nil ? "Save" : "Begin"
    }

    private let modelContext: ModelContext
    private let existingProfile: UserProfile?

    init(modelContext: ModelContext, profile: UserProfile? = nil) {
        self.modelContext = modelContext
        self.existingProfile = profile
        self.name = profile?.name ?? ""
        self.dateOfBirth = profile?.dateOfBirth ?? Calendar.current.date(byAdding: .year, value: -30, to: Date())!
        self.lifeExpectancy = profile?.lifeExpectancy ?? 85
    }

    func save() {
        if let profile = existingProfile {
            profile.name = name.trimmingCharacters(in: .whitespaces)
            profile.dateOfBirth = dateOfBirth
            profile.lifeExpectancy = lifeExpectancy
        } else {
            let profile = UserProfile(
                name: name.trimmingCharacters(in: .whitespaces),
                dateOfBirth: dateOfBirth,
                lifeExpectancy: lifeExpectancy
            )
            modelContext.insert(profile)
        }
        do {
            try modelContext.save()
        } catch {
            AppLogger.dataAccess.error("Failed to save profile: \(error)")
        }
    }
}
