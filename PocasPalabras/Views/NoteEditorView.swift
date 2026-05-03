import SwiftUI

struct NoteEditorView: View {
    @Binding var text: String
    var onSave: () -> Void

    @Environment(ThemeManager.self) var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("Notes")
                .font(AppTheme.headlineFont)
                .foregroundStyle(theme.textPrimary)

            TextEditor(text: $text)
                .font(AppTheme.bodyFont)
                .foregroundStyle(theme.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .padding(AppTheme.spacingSM)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        onSave()
                    }
                }

            if isFocused {
                HStack {
                    Spacer()
                    Button("Save") {
                        isFocused = false
                        onSave()
                    }
                    .font(AppTheme.captionFont)
                    .foregroundStyle(theme.accent)
                }
            }
        }
    }
}
