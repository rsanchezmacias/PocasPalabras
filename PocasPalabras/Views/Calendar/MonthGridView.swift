import SwiftUI
import SwiftData

/// Standard calendar month grid. Each day cell is tappable.
struct MonthGridView: View {
    let engine: LifeCalendarEngine
    let onSelect: (Date) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme

    private var calendar: Calendar { Calendar.current }

    private let weekdaySymbols: [String] = {
        let f = DateFormatter()
        return f.veryShortWeekdaySymbols
    }()

    var body: some View {
        ViewModelView({
            let vm = MonthGridViewModel(modelContext: modelContext, engine: engine)
            vm.fetchContentDates()
            return vm
        }) { viewModel in
            VStack(spacing: AppTheme.spacingSM) {
                // Month navigation
                HStack {
                    Button {
                        viewModel.previousMonth()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(theme.textSecondary)
                    }

                    Spacer()
                    Text(viewModel.monthTitle)
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(theme.textPrimary)
                    Spacer()

                    Button {
                        viewModel.nextMonth()
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                .padding(.horizontal, AppTheme.spacingMD)

                // Weekday header
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: AppTheme.spacingXS) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(theme.textTertiary)
                    }
                }
                .padding(.horizontal, AppTheme.spacingSM)

                // Day cells
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: AppTheme.spacingXS) {
                    ForEach(Array(viewModel.daysInMonth.enumerated()), id: \.offset) { _, date in
                        if let date {
                            let status = viewModel.engine.statusForDate(date)
                            Button {
                                onSelect(date)
                            } label: {
                                VStack(spacing: 2) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(AppTheme.captionFont)
                                        .fontWeight(status == .today ? .bold : .regular)
                                        .foregroundStyle(status == .today ? .white : theme.textPrimary)

                                    Circle()
                                        .fill(status == .today ? .white.opacity(0.6) : theme.accent.opacity(0.5))
                                        .frame(width: 4, height: 4)
                                        .opacity(viewModel.hasContent(on: date) ? 1 : 0)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(dayCellColor(for: status))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        } else {
                            Color.clear.frame(height: 36)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.spacingSM)

                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.vertical, AppTheme.spacingMD)
        }
    }

    private func dayCellColor(for status: LifeCalendarEngine.DayStatus) -> Color {
        switch status {
        case .past: return theme.pastDay.opacity(0.3)
        case .today: return theme.todayHighlight
        case .future: return theme.futureDay.opacity(0.5)
        }
    }
}
