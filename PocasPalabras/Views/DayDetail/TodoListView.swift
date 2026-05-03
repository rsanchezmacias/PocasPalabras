import SwiftUI
import SwiftData

struct TodoListView: View {
    let date: Date
    var entry: DayEntry?
    var onEntryCreated: ((DayEntry) -> Void)?

    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme

    var body: some View {
        ViewModelView({ TodoListViewModel(modelContext: modelContext, entry: entry, date: date) }) { vm in
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                Text("Todos")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(theme.textPrimary)

                ForEach(vm.activeTodos) { todo in
                    TodoRow(
                        todo: todo,
                        onToggle: { vm.toggleTodo($0) },
                        onDelete: { vm.deleteTodo($0) }
                    )
                }

                HStack(spacing: AppTheme.spacingSM) {
                    TextField("Add a todo...", text: Bindable(vm).newTodoText)
                        .font(AppTheme.bodyFont)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            let hadNoEntry = vm.entry == nil
                            vm.addTodo()
                            if hadNoEntry, let newEntry = vm.entry {
                                onEntryCreated?(newEntry)
                            }
                        }

                    if !vm.newTodoText.isEmpty {
                        Button {
                            let hadNoEntry = vm.entry == nil
                            vm.addTodo()
                            if hadNoEntry, let newEntry = vm.entry {
                                onEntryCreated?(newEntry)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(theme.accent)
                        }
                    }
                }
                .padding(AppTheme.spacingSM + 4)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
            }
            .onChange(of: entry) { _, newEntry in
                vm.updateEntry(newEntry)
            }
        }
    }
}

struct TodoRow: View {
    let todo: Todo
    let onToggle: (Todo) -> Void
    let onDelete: (Todo) -> Void

    @Environment(ThemeManager.self) var theme

    var body: some View {
        HStack(spacing: AppTheme.spacingSM) {
            Button {
                onToggle(todo)
            } label: {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.completed ? theme.success : theme.textTertiary)
                    .font(.system(size: 20))
            }

            Text(todo.text)
                .font(AppTheme.bodyFont)
                .foregroundStyle(todo.completed ? theme.textTertiary : theme.textPrimary)
                .strikethrough(todo.completed, color: theme.textTertiary)

            Spacer()

            Button {
                onDelete(todo)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.textTertiary)
            }
        }
        .padding(AppTheme.spacingSM + 4)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
    }
}
