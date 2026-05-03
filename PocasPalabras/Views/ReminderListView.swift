import SwiftUI
import SwiftData

struct ReminderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme
    @State private var reminderToDelete: Reminder?

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ViewModelView({
            let vm = ReminderListViewModel(modelContext: modelContext)
            vm.fetchReminders()
            return vm
        }) { viewModel in
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    if viewModel.reminders.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.reminders) { reminder in
                            reminderCard(reminder, viewModel: viewModel)
                        }
                    }
                }
                .padding(AppTheme.spacingLG)
            }
            .gridBackground()
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: Bindable(viewModel).showForm, onDismiss: {
                viewModel.fetchReminders()
            }) {
                ReminderFormView()
            }
            .confirmDeleteReminder($reminderToDelete) { reminder in
                viewModel.deleteReminder(reminder)
            }
            .onAppear {
                viewModel.fetchReminders()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingSM) {
            Image(systemName: "bell.slash")
                .font(.system(size: 36))
                .foregroundStyle(theme.textTertiary)
            Text("No active reminders")
                .font(AppTheme.bodyFont)
                .foregroundStyle(theme.textSecondary)
            Text("Tap + to create one")
                .font(AppTheme.captionFont)
                .foregroundStyle(theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingXL)
    }

    private func reminderCard(_ reminder: Reminder, viewModel: ReminderListViewModel) -> some View {
        let completed = viewModel.isCompletedToday(reminder)
        return HStack(alignment: .top, spacing: AppTheme.spacingSM) {
            Button {
                viewModel.toggleCompletionToday(reminder)
            } label: {
                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(completed ? theme.success : theme.textTertiary)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(AppTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundStyle(completed ? theme.textTertiary : theme.textPrimary)
                    .strikethrough(completed, color: theme.textTertiary)

                if let desc = reminder.descriptionText, !desc.isEmpty {
                    Text(desc)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(theme.textSecondary)
                }

                HStack(spacing: AppTheme.spacingSM) {
                    Label(reminder.recurrenceType.displayName, systemImage: "arrow.trianglehead.2.counterclockwise")
                        .font(AppTheme.monoFont)
                        .foregroundStyle(theme.textTertiary)

                    Text("Next: \(timeFormatter.string(from: reminder.nextTriggerAt))")
                        .font(AppTheme.monoFont)
                        .foregroundStyle(theme.textTertiary)
                }
            }

            Spacer()

            Button {
                reminderToDelete = reminder
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(theme.destructive.opacity(0.6))
            }
        }
        .padding(AppTheme.spacingMD)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}
