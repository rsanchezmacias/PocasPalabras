import SwiftUI
import SwiftData

struct HomeView: View {
    let profile: UserProfile

    @Environment(ThemeManager.self) var theme

    var body: some View {
        ViewModelView({ HomeViewModel(profile: profile) }) { viewModel in
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                    headerSection(viewModel: viewModel)
                    quoteSection
                    progressSection(viewModel: viewModel)
                    quickActionsSection(viewModel: viewModel)
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.vertical, AppTheme.spacingMD)
            }
            .gridBackground()
            .navigationTitle("Hello, \(viewModel.profile.name)")
            .sheet(isPresented: Bindable(viewModel).showDayDetail) {
                DayDetailView(date: viewModel.selectedDate)
            }
        }
    }

    // MARK: - Sections

    private func headerSection(viewModel: HomeViewModel) -> some View {
        Text(viewModel.dateFormatter.string(from: Date()))
            .font(AppTheme.bodyFont)
            .foregroundStyle(theme.textSecondary)
    }

    private var quoteSection: some View {
        let quote = QuoteProvider.quoteOfTheDay()
        return VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("\"\(quote.text)\"")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundStyle(theme.textPrimary)

            Text("-- \(quote.author)")
                .font(AppTheme.captionFont)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(AppTheme.spacingMD)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private func progressSection(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("Life progress")
                .font(AppTheme.headlineFont)
                .foregroundStyle(theme.textPrimary)

            LifeProgressView(engine: viewModel.engine)
        }
    }

    private func quickActionsSection(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("Today")
                .font(AppTheme.headlineFont)
                .foregroundStyle(theme.textPrimary)

            Button {
                viewModel.openToday()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notes, todos & reminders")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(theme.textPrimary)
                        Text("Tap to view or add entries for today")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(theme.textTertiary)
                }
                .padding(AppTheme.spacingMD)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
        }
    }
}
