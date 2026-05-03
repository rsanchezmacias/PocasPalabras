import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var dateOfBirth: Date
    var lifeExpectancy: Int
    var createdAt: Date
    var deletedAt: Date?

    init(name: String, dateOfBirth: Date, lifeExpectancy: Int = 85) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.lifeExpectancy = lifeExpectancy
        self.createdAt = Date()
    }
}
