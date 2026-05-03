import SwiftUI

struct WeekColorPicker: View {
    @Binding var selectedHex: String?
    var onSave: () -> Void

    @Environment(ThemeManager.self) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("Color this week")
                .font(AppTheme.headlineFont)
                .foregroundStyle(theme.textPrimary)

            HStack(spacing: AppTheme.spacingSM) {
                // "None" button to clear color
                Button {
                    selectedHex = nil
                    onSave()
                } label: {
                    Circle()
                        .strokeBorder(theme.textTertiary, lineWidth: selectedHex == nil ? 2 : 1)
                        .frame(width: 28, height: 28)
                        .overlay {
                            if selectedHex == nil {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(theme.textTertiary)
                            }
                        }
                }

                ForEach(AppTheme.weekColorPalette, id: \.hex) { item in
                    Button {
                        selectedHex = item.hex
                        onSave()
                    } label: {
                        Circle()
                            .fill(Color(hexString: item.hex))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if selectedHex == item.hex {
                                    Circle()
                                        .strokeBorder(.white, lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                }
                            }
                    }
                }
            }
        }
    }
}
