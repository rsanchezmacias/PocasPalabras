import Foundation

// Make Date identifiable for sheet presentation.
extension Date: @retroactive Identifiable {
    nonisolated public var id: TimeInterval { timeIntervalSince1970 }
}
