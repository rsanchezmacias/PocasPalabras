import SwiftUI

enum ThemeName: String, CaseIterable {
    case slate = "Slate"
    case earth = "Earth"

    var palette: ColorPalette {
        switch self {
        case .slate: .slate
        case .earth: .earth
        }
    }
}

@Observable
final class ThemeManager {
    var selectedTheme: ThemeName {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme") }
    }

    var background: Color { selectedTheme.palette.background }
    var surface: Color { selectedTheme.palette.surface }
    var surfaceHover: Color { selectedTheme.palette.surfaceHover }
    var textPrimary: Color { selectedTheme.palette.textPrimary }
    var textSecondary: Color { selectedTheme.palette.textSecondary }
    var textTertiary: Color { selectedTheme.palette.textTertiary }
    var accent: Color { selectedTheme.palette.accent }
    var accentLight: Color { selectedTheme.palette.accentLight }
    var pastDay: Color { selectedTheme.palette.pastDay }
    var todayHighlight: Color { selectedTheme.palette.todayHighlight }
    var futureDay: Color { selectedTheme.palette.futureDay }
    var futureDayStroke: Color { selectedTheme.palette.futureDayStroke }
    var destructive: Color { selectedTheme.palette.destructive }
    var success: Color { selectedTheme.palette.success }

    init() {
        let raw = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeName.slate.rawValue
        selectedTheme = ThemeName(rawValue: raw) ?? .slate
    }
}
