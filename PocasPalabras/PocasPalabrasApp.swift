import SwiftUI
import SwiftData

@main
struct PocasPalabrasApp: App {
    @State private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
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
