import SwiftUI
import SwiftData

struct SettingsView: View {
    
    struct Constants {
        static let lifeExpectancyRange: ClosedRange<Int> = 30...101
    }
    
    let profile: UserProfile

    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme

    @State private var showingEditProfile = false

    var body: some View {
        @Bindable var theme = theme
        ViewModelView({ SettingsViewModel(modelContext: modelContext, profile: profile) }) { viewModel in
            Form {
                Section {
                    LabeledContent("Name", value: viewModel.profile.name)
                        .foregroundStyle(theme.textPrimary, theme.textSecondary)
                    LabeledContent("Date of Birth", value: viewModel.dobFormatter.string(from: viewModel.profile.dateOfBirth))
                        .foregroundStyle(theme.textPrimary, theme.textSecondary)
                } header: {
                    HStack {
                        Text("Profile")
                        Spacer()
                        Button { showingEditProfile = true } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }
                        }
                        .foregroundStyle(theme.accent)
                        .textCase(nil)
                    }
                }
                .foregroundStyle(theme.textSecondary)
                .listRowBackground(theme.surface)

                Section("Life Expectancy") {
                    Stepper(
                        "\(viewModel.lifeExpectancy) years",
                        value: Bindable(viewModel).lifeExpectancy,
                        in: Constants.lifeExpectancyRange
                    )
                    .foregroundStyle(theme.textPrimary)
                }
                .foregroundStyle(theme.textSecondary)
                .listRowBackground(theme.surface)

                Section("Theme") {
                    Picker("Color palette", selection: $theme.selectedTheme) {
                        ForEach(ThemeName.allCases, id: \.self) { name in
                            Text(name.rawValue).tag(name)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(theme.accent)
                    .foregroundStyle(theme.textPrimary)
                }
                .foregroundStyle(theme.textSecondary)
                .listRowBackground(theme.surface)

                Section("Statistics") {
                    LabeledContent("Days lived", value: "\(viewModel.engine.daysLived)")
                    LabeledContent("Days remaining", value: "\(viewModel.engine.daysRemaining)")
                    LabeledContent("Weeks lived", value: "\(viewModel.engine.weeksLived)")
                    LabeledContent("Progress", value: String(format: "%.1f%%", viewModel.engine.progressPercentage * 100))
                }
                .foregroundStyle(theme.textPrimary, theme.textSecondary)
                .listRowBackground(theme.surface)

                Section("About") {
                    Link(destination: URL(string: "https://rsanchezmacias.com/pocas-palabras/support/")!) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "https://rsanchezmacias.com/pocas-palabras/privacy/")!) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                }
                .foregroundStyle(theme.textPrimary)
                .listRowBackground(theme.surface)

                Section {
                    Text("En pocas palabras v1.0")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(theme.textTertiary)
                }
                .listRowBackground(theme.surface)
            }
            .scrollContentBackground(.hidden)
            .gridBackground()
            .navigationTitle("Settings")
            .sheet(isPresented: $showingEditProfile) {
                OnboardingView(profile: viewModel.profile, onComplete: { showingEditProfile = false })
            }
        }
    }
}
