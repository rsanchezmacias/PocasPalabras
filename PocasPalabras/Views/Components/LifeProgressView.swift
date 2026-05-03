import SwiftUI

struct LifeProgressView: View {
    let engine: LifeCalendarEngine

    @Environment(ThemeManager.self) var theme

    private var percentString: String {
        String(format: "%.1f%%", engine.progressPercentage * 100)
    }

    var body: some View {
        VStack(spacing: AppTheme.spacingSM) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.futureDay)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.accent)
                        .frame(width: geo.size.width * engine.progressPercentage, height: 8)
                }
            }
            .frame(height: 8)

            // Stats row
            HStack {
                statItem(value: formatNumber(engine.daysLived), label: "days lived")
                Spacer()
                statItem(value: percentString, label: "complete")
                Spacer()
                statItem(value: formatNumber(engine.daysRemaining), label: "days ahead")
            }
        }
        .padding(AppTheme.spacingMD)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppTheme.headlineFont)
                .foregroundStyle(theme.textPrimary)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(theme.textSecondary)
        }
    }

    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}
