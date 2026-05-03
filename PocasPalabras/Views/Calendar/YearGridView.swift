import SwiftUI
import SwiftData

/// Displays 12 mini-month calendars in a 4-row x 3-column grid.
/// Each mini-month shows a tiny 7-column day grid with past/today/future coloring.
/// Below the grid: year progress stats.
struct YearGridView: View {
    let engine: LifeCalendarEngine

    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme

    private let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        ViewModelView({
            let vm = YearGridViewModel(modelContext: modelContext, engine: engine)
            vm.fetchWeekColors()
            return vm
        }) { viewModel in
            ScrollView {
                VStack(spacing: AppTheme.spacingMD) {
                    // Year navigation
                    HStack {
                        Button {
                            viewModel.previousYear()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(theme.textSecondary)
                        }
                        Spacer()
                        Text(String(viewModel.displayedYear))
                            .font(AppTheme.titleFont)
                            .foregroundStyle(theme.textPrimary)
                        Spacer()
                        Button {
                            viewModel.nextYear()
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingMD)

                    // 4x3 mini-month grid
                    LazyVGrid(columns: monthColumns, spacing: 10) {
                        ForEach(1...12, id: \.self) { month in
                            MiniMonthView(year: viewModel.displayedYear, month: month, engine: viewModel.engine, yearViewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingSM)

                    // Year progress card
                    yearProgressCard(viewModel: viewModel)
                }
                .padding(.vertical, AppTheme.spacingSM)
            }
        }
    }

    private func yearProgressCard(viewModel: YearGridViewModel) -> some View {
        let yp = viewModel.yearProgress

        return VStack(spacing: AppTheme.spacingSM) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.futureDay)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.accent)
                        .frame(width: geo.size.width * yp.progress, height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Text("\(yp.daysPassed) days passed")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(theme.textSecondary)
                Spacer()
                Text("\(yp.daysRemaining) days remaining")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(AppTheme.spacingMD)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .padding(.horizontal, AppTheme.spacingMD)
    }
}

/// A compact single-month calendar showing day cells colored by life status.
struct MiniMonthView: View {
    let year: Int
    let month: Int
    let engine: LifeCalendarEngine
    let yearViewModel: YearGridViewModel

    @Environment(ThemeManager.self) var theme

    private var calendar: Calendar { Calendar.current }

    private let dayColumns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

    private var monthName: String {
        let f = DateFormatter()
        return f.shortMonthSymbols[month - 1]
    }

    private var isCurrentMonth: Bool {
        let now = Date()
        return calendar.component(.year, from: now) == year && calendar.component(.month, from: now) == month
    }

    /// Returns an array of optional Dates. Nil entries are leading blanks for alignment.
    private var dayCells: [Date?] {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        guard let firstOfMonth = calendar.date(from: comps) else { return [] }
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        var cells: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range {
            var dc = comps
            dc.day = day
            cells.append(calendar.date(from: dc))
        }
        return cells
    }

    var body: some View {
        VStack(spacing: 3) {
            Text(monthName)
                .font(.system(size: 11, weight: isCurrentMonth ? .bold : .medium, design: .serif))
                .foregroundStyle(isCurrentMonth ? theme.accent : theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: dayColumns, spacing: 1) {
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let status = engine.statusForDate(date)
                        let cellColor = yearViewModel.colorForDate(date) ?? miniDayColor(for: status)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(cellColor)
                            .aspectRatio(1, contentMode: .fit)
                    } else {
                        Color.clear.aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(6)
        .background(isCurrentMonth ? theme.surface : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
    }

    private func miniDayColor(for status: LifeCalendarEngine.DayStatus) -> Color {
        switch status {
        case .past: return theme.pastDay
        case .today: return theme.todayHighlight
        case .future: return theme.futureDay
        }
    }
}
