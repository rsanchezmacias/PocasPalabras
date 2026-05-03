import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var activeProfile: UserProfile? {
        profiles.first { $0.deletedAt == nil }
    }

    var body: some View {
        Group {
            if let profile = activeProfile {
                MainTabView(profile: profile)
            } else {
                OnboardingView(onComplete: {})
            }
        }
        .task {
            let manager = NotificationManager()
            await manager.checkAndFireDueReminders(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .environment(ThemeManager())
        .modelContainer(for: [UserProfile.self, DayEntry.self, Todo.self, Reminder.self, WeekColor.self], inMemory: true)
}
