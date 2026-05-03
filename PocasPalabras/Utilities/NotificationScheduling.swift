import Foundation
import SwiftData

protocol NotificationScheduling {
    func scheduleNotification(for reminder: Reminder)
    func cancelNotification(for reminder: Reminder)
}
