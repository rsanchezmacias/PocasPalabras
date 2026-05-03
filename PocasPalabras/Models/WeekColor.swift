import Foundation
import SwiftData

@Model
final class WeekColor {
    var weekIndex: Int
    var colorHex: String
    var createdAt: Date

    init(weekIndex: Int, colorHex: String) {
        self.weekIndex = weekIndex
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
