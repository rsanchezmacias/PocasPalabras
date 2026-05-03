import SwiftUI

/// Design tokens inspired by Moon Design System: warm, minimal, notebook-like.
/// Colors are provided by ThemeManager; only non-color tokens live here.
enum AppTheme {
    // MARK: - Typography

    static let titleFont: Font = .system(.largeTitle, design: .default, weight: .bold)
    static let headlineFont: Font = .system(.headline, design: .default, weight: .semibold)
    static let bodyFont: Font = .system(.body, design: .default, weight: .regular)
    static let captionFont: Font = .system(.caption, design: .default, weight: .regular)
    static let monoFont: Font = .system(.caption2, design: .monospaced, weight: .regular)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    static let cornerRadius: CGFloat = 12
    static let cornerRadiusSM: CGFloat = 8

    // MARK: - Week Color Palette

    static let weekColorPalette: [(name: String, hex: String)] = [
        ("Rose", "D4726A"),
        ("Coral", "E08A5E"),
        ("Amber", "C9A84C"),
        ("Sage", "7BA07B"),
        ("Teal", "5E9B9B"),
        ("Sky", "6B8EB5"),
        ("Lavender", "9B8BB5"),
        ("Plum", "A06B8E"),
    ]
}

// MARK: - Color hex initializer

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        self.init(hex: UInt(value))
    }
}
