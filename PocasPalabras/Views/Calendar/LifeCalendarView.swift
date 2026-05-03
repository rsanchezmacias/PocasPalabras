import SwiftUI
import SwiftData

struct LifeCalendarView: View {
    let profile: UserProfile

    @Environment(ThemeManager.self) var theme

    private var engine: LifeCalendarEngine {
        LifeCalendarEngine(dateOfBirth: profile.dateOfBirth, lifeExpectancy: profile.lifeExpectancy)
    }

    var body: some View {
        ViewModelView({ LifeCalendarViewModel(engine: engine) }) { viewModel in
            VStack(spacing: 0) {
                ViewToggle(selection: Bindable(viewModel).viewMode)
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.bottom, AppTheme.spacingSM)

                switch viewModel.viewMode {
                case .week:
                    WeekGridView(engine: viewModel.engine) { date in
                        viewModel.selectedDate = date
                    }
                case .month:
                    MonthGridView(engine: viewModel.engine) { date in
                        viewModel.selectedDate = date
                    }
                case .year:
                    YearGridView(engine: viewModel.engine)
                case .life:
                    LifeGridCanvasView(engine: viewModel.engine) { date in
                        viewModel.selectedDate = date
                    }
                }
            }
            .background(theme.background)
            .sheet(item: Bindable(viewModel).selectedDate) { date in
                DayDetailView(date: date)
            }
        }
    }
}
