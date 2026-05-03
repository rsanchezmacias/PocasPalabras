import SwiftUI
import SwiftData

@main
struct PocasPalabrasApp: App {
    @State private var themeManager = ThemeManager()
    private let notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .task {
                    await notificationManager.requestPermission()
                }
        }
        .modelContainer(for: [
            UserProfile.self,
            DayEntry.self,
            Todo.self,
            Reminder.self,
            ReminderOccurrence.self,
            WeekColor.self,
        ])
    }
}
