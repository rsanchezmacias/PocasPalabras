import SwiftUI

struct MainTabView: View {
    let profile: UserProfile

    @Environment(ThemeManager.self) var theme

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    HomeView(profile: profile)
                }
            }

            Tab("Calendar", systemImage: "calendar") {
                NavigationStack {
                    LifeCalendarView(profile: profile)
                }
            }

            Tab("Reminders", systemImage: "bell") {
                NavigationStack {
                    ReminderListView()
                }
            }

            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView(profile: profile)
                }
            }
        }
        .tint(theme.accent)
        .onAppear { applyNavBarAppearance() }
        .onChange(of: theme.selectedTheme) { applyNavBarAppearance() }
    }

    private func applyNavBarAppearance() {
        let titleColor = UIColor(theme.textPrimary)

        let large = UINavigationBarAppearance()
        large.configureWithTransparentBackground()
        large.largeTitleTextAttributes = [.foregroundColor: titleColor]
        large.titleTextAttributes = [.foregroundColor: titleColor]

        let inline = UINavigationBarAppearance()
        inline.configureWithDefaultBackground()
        inline.titleTextAttributes = [.foregroundColor: titleColor]

        UINavigationBar.appearance().standardAppearance = inline
        UINavigationBar.appearance().scrollEdgeAppearance = large

        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(theme.background)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(theme.textPrimary)], for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(theme.textSecondary)], for: .normal
        )
    }
}
