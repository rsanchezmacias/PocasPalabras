import SwiftUI

struct QuoteOfTheDayView: View {
    let quote: Quote

    @Environment(ThemeManager.self) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("\"\(quote.text)\"")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundStyle(theme.textPrimary)

            Text("-- \(quote.author)")
                .font(AppTheme.captionFont)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(AppTheme.spacingMD)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}
