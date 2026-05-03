import SwiftUI
import SwiftData

struct DayDetailView: View {
    let date: Date

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) var theme

    @State private var showReminderForm = false

    private var dateTitle: String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: date)
    }

    var body: some View {
        ViewModelView({
            let vm = DayDetailViewModel(modelContext: modelContext, date: date)
            vm.loadEntry()
            return vm
        }) { viewModel in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        ViewModelView({
                            let wcvm = WeekColorViewModel(modelContext: modelContext, date: date)
                            wcvm.loadWeekColor()
                            return wcvm
                        }) { weekColorVM in
                            WeekColorPicker(selectedHex: Bindable(weekColorVM).selectedColorHex) {
                                weekColorVM.saveWeekColor()
                            }
                        }

                        NoteEditorView(text: Bindable(viewModel).noteText) {
                            viewModel.saveNote()
                        }

                        TodoListView(date: date, entry: viewModel.entry) { newEntry in
                            viewModel.entry = newEntry
                        }

                        ReminderListSection(date: date, showForm: $showReminderForm)
                    }
                    .padding(AppTheme.spacingMD)
                }
                .gridBackground()
                .navigationTitle(dateTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                            .foregroundStyle(theme.accent)
                    }
                }
                .sheet(isPresented: $showReminderForm) {
                    ReminderFormView()
                }
            }
        }
    }
}
