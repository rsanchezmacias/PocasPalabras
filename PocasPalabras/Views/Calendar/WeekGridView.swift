import SwiftUI
import SwiftData

/// Weekly planner: a strip of tappable day cells with inline agenda for the focused day.
struct WeekGridView: View {
    let engine: LifeCalendarEngine
    let onSelect: (Date) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme

    private let dayNameFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    private let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        ViewModelView({
            let vm = WeekGridViewModel(modelContext: modelContext, engine: engine)
            vm.loadEntry(for: vm.focusedDate)
            return vm
        }) { viewModel in
            ScrollView {
                VStack(spacing: AppTheme.spacingMD) {
                    // Week strip
                    HStack(spacing: 4) {
                        ForEach(viewModel.weekDays, id: \.timeIntervalSince1970) { date in
                            let status = viewModel.engine.statusForDate(date)
                            let isFocused = calendar.isDate(date, inSameDayAs: viewModel.focusedDate)
                            Button {
                                viewModel.selectDate(date)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(dayNameFormatter.string(from: date))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(isFocused ? .white : theme.textSecondary)
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(.title3, design: .serif, weight: .semibold))
                                        .foregroundStyle(isFocused ? .white : theme.textPrimary)
                                    // Dot indicator for entries with content
                                    Circle()
                                        .fill(isFocused ? .white.opacity(0.6) : theme.accent.opacity(0.4))
                                        .frame(width: 4, height: 4)
                                        .opacity(viewModel.hasContent(on: date) ? 1 : 0)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.spacingSM)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM)
                                        .fill(isFocused ? theme.todayHighlight :
                                                status == .today ? theme.accent.opacity(0.12) : Color.clear)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingSM)

                    // Focused day header
                    HStack {
                        Text(monthDayFormatter.string(from: viewModel.focusedDate))
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(theme.textPrimary)
                        if calendar.isDateInToday(viewModel.focusedDate) {
                            Text("Today")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(theme.accent)
                                .clipShape(Capsule())
                        }
                        Spacer()
                        Button {
                            onSelect(viewModel.focusedDate)
                        } label: {
                            Label("Open", systemImage: "arrow.up.right")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(theme.accent)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingMD)

                    // Inline agenda
                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                        // Note preview
                        if let note = viewModel.focusedEntry?.note, !note.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Note", systemImage: "note.text")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(theme.textSecondary)
                                Text(note)
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(theme.textPrimary)
                                    .lineLimit(3)
                            }
                            .padding(AppTheme.spacingSM + 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
                        }

                        // Todos
                        let todos = (viewModel.focusedEntry?.todos ?? []).filter { $0.deletedAt == nil }
                        if !todos.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Todos (\(todos.filter { !$0.completed }.count) remaining)", systemImage: "checklist")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(theme.textSecondary)
                                ForEach(todos) { todo in
                                    HStack(spacing: 8) {
                                        Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 14))
                                            .foregroundStyle(todo.completed ? theme.success : theme.textTertiary)
                                        Text(todo.text)
                                            .font(AppTheme.bodyFont)
                                            .foregroundStyle(todo.completed ? theme.textTertiary : theme.textPrimary)
                                            .strikethrough(todo.completed, color: theme.textTertiary)
                                    }
                                }
                            }
                            .padding(AppTheme.spacingSM + 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
                        }

                        // Empty state
                        if viewModel.focusedEntry == nil || ((viewModel.focusedEntry?.note ?? "").isEmpty && (viewModel.focusedEntry?.todos ?? []).filter({ $0.deletedAt == nil }).isEmpty) {
                            VStack(spacing: AppTheme.spacingSM) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 28))
                                    .foregroundStyle(theme.textTertiary)
                                Text("Nothing here yet")
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(theme.textSecondary)
                                Text("Tap Open to add notes and todos")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(theme.textTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingXL)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingMD)

                    // Quote
                    QuoteOfTheDayView(quote: QuoteProvider.quoteOfTheDay())
                        .padding(.horizontal, AppTheme.spacingMD)
                }
                .padding(.vertical, AppTheme.spacingSM)
            }
        }
    }
}
