import Foundation
import SwiftData

protocol NotificationScheduling {
    func requestPermission() async
    func scheduleNotification(for reminder: Reminder)
    func cancelNotification(for reminder: Reminder)
}
