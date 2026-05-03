import SwiftUI
import SwiftData

struct ReminderListSection: View {
    let date: Date
    @Binding var showForm: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme
    @State private var reminderToDelete: Reminder?

    var body: some View {
        ViewModelView({
            let vm = ReminderListSectionViewModel(modelContext: modelContext, date: date)
            vm.fetchReminders()
            return vm
        }) { viewModel in
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                HStack {
                    Text("Reminders")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    Button {
                        showForm = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(theme.accent)
                    }
                }

                if viewModel.remindersForDate.isEmpty {
                    Text("No reminders for this day")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(theme.textTertiary)
                } else {
                    ForEach(viewModel.remindersForDate) { reminder in
                        ReminderRow(
                            reminder: reminder,
                            completed: viewModel.isCompleted(reminder),
                            onToggle: { viewModel.toggleCompletion($0) },
                            onDelete: { reminderToDelete = $0 }
                        )
                    }
                }
            }
            .confirmDeleteReminder($reminderToDelete) { reminder in
                viewModel.deleteReminder(reminder)
            }
        }
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    var completed: Bool = false
    var onToggle: ((Reminder) -> Void)?
    let onDelete: (Reminder) -> Void

    @Environment(ThemeManager.self) var theme

    var body: some View {
        HStack(spacing: AppTheme.spacingSM) {
            if let onToggle {
                Button {
                    onToggle(reminder)
                } label: {
                    Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(completed ? theme.success : theme.textTertiary)
                        .font(.system(size: 20))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(completed ? theme.textTertiary : theme.textPrimary)
                    .strikethrough(completed, color: theme.textTertiary)
                if let desc = reminder.descriptionText, !desc.isEmpty {
                    Text(desc)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(theme.textSecondary)
                }
                Text(reminder.recurrenceType.displayName)
                    .font(AppTheme.monoFont)
                    .foregroundStyle(theme.textTertiary)
            }
            Spacer()
            Button {
                onDelete(reminder)
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(theme.textTertiary)
            }
        }
        .padding(AppTheme.spacingSM + 4)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
    }
}
