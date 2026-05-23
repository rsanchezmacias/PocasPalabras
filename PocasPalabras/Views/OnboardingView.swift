import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme

    private let profile: UserProfile?
    var onComplete: () -> Void

    init(profile: UserProfile? = nil, onComplete: @escaping () -> Void) {
        self.profile = profile
        self.onComplete = onComplete
    }

    var body: some View {
        ViewModelView(makeViewModel) { viewModel in
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                    Spacer().frame(height: AppTheme.spacingXL)

                    Text(viewModel.title)
                        .font(AppTheme.titleFont)
                        .foregroundStyle(theme.textPrimary)

                    Text(viewModel.subtitle)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(theme.textSecondary)

                    Spacer().frame(height: AppTheme.spacingSM)

                    // Name
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Your name")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(theme.textSecondary)

                        TextField("Name", text: Bindable(viewModel).name)
                            .textFieldStyle(.plain)
                            .font(AppTheme.bodyFont)
                            .padding(AppTheme.spacingSM + 4)
                            .background(theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
                    }

                    // Date of Birth
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Date of birth")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(theme.textSecondary)

                        DatePicker(
                            "Date of birth",
                            selection: Bindable(viewModel).dateOfBirth,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(theme.accent)
                    }

                    // Life Expectancy
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Life expectancy (years): \(viewModel.lifeExpectancy)")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(theme.textSecondary)

                        Slider(
                            value: Binding(
                                get: { Double(viewModel.lifeExpectancy) },
                                set: { viewModel.lifeExpectancy = Int($0) }
                            ),
                            in: 50...120,
                            step: 1
                        )
                        .tint(theme.accent)
                    }

                    Spacer().frame(height: AppTheme.spacingMD)

                    Button {
                        viewModel.save()
                        onComplete()
                    } label: {
                        Text(viewModel.actionLabel)
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingSM + 4)
                            .background(viewModel.isValid ? theme.accent : theme.pastDay)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
                    }
                    .disabled(!viewModel.isValid)
                }
                .padding(.horizontal, AppTheme.spacingLG)
            }
            .gridBackground()
        }
    }

    private func makeViewModel() -> OnboardingViewModel {
        OnboardingViewModel(modelContext: modelContext, profile: profile)
    }
}
