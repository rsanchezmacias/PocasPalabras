import SwiftUI

struct ViewToggle: View {
    @Binding var selection: CalendarViewMode

    @Environment(ThemeManager.self) var theme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(AppTheme.captionFont)
                        .fontWeight(selection == mode ? .semibold : .regular)
                        .foregroundStyle(selection == mode ? .white : theme.textSecondary)
                        .padding(.horizontal, AppTheme.spacingSM + 4)
                        .padding(.vertical, AppTheme.spacingXS + 2)
                        .background(selection == mode ? theme.accent : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM))
                }
            }
        }
        .padding(3)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}
