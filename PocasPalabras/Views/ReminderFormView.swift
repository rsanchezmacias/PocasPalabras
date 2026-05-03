import SwiftUI
import SwiftData

struct ReminderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) var theme

    private let weekdays = [
        (1, "Sunday"), (2, "Monday"), (3, "Tuesday"), (4, "Wednesday"),
        (5, "Thursday"), (6, "Friday"), (7, "Saturday")
    ]

    var body: some View {
        ViewModelView({ ReminderFormViewModel(modelContext: modelContext, notificationManager: NotificationManager()) }) { viewModel in
            NavigationStack {
                Form {
                    Section {
                        TextField("Title", text: Bindable(viewModel).title)
                        TextField("Description (optional)", text: Bindable(viewModel).descriptionText)
                    }

                    Section("Recurrence") {
                        Picker("Type", selection: Bindable(viewModel).recurrenceType) {
                            ForEach(RecurrenceType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }

                        switch viewModel.recurrenceType {
                        case .weekly:
                            Picker("Weekday", selection: Bindable(viewModel).selectedWeekday) {
                                ForEach(weekdays, id: \.0) { weekday in
                                    Text(weekday.1).tag(weekday.0)
                                }
                            }
                        case .monthly:
                            Picker("Day of month", selection: Bindable(viewModel).selectedDayOfMonth) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                        case .custom:
                            Stepper("Every \(viewModel.customInterval) days", value: Bindable(viewModel).customInterval, in: 1...365)
                        case .daily:
                            EmptyView()
                        }
                    }

                    Section("First trigger") {
                        DatePicker("Date & Time", selection: Bindable(viewModel).triggerDate)
                            .tint(theme.accent)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(theme.background)
                .navigationTitle("New Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(theme.textSecondary)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            viewModel.save()
                            dismiss()
                        }
                        .foregroundStyle(viewModel.isValid ? theme.accent : theme.textTertiary)
                        .disabled(!viewModel.isValid)
                    }
                }
            }
        }
    }
}
