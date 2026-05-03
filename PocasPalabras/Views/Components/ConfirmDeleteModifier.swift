import SwiftUI

struct ConfirmDeleteModifier: ViewModifier {
    let title: String
    @Binding var item: Reminder?
    let onConfirm: (Reminder) -> Void

    func body(content: Content) -> some View {
        content
            .alert("Delete Reminder", isPresented: Binding(
                get: { item != nil },
                set: { if !$0 { item = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let reminder = item {
                        onConfirm(reminder)
                        item = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    item = nil
                }
            } message: {
                if let reminder = item {
                    Text("Are you sure you want to delete \"\(reminder.title)\"?")
                }
            }
    }
}

extension View {
    func confirmDeleteReminder(_ item: Binding<Reminder?>, onConfirm: @escaping (Reminder) -> Void) -> some View {
        modifier(ConfirmDeleteModifier(title: "Delete Reminder", item: item, onConfirm: onConfirm))
    }
}
