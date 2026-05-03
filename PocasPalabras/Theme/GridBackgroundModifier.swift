import SwiftUI

struct GridBackgroundModifier: ViewModifier {
    @Environment(ThemeManager.self) var theme

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    theme.background
                        .ignoresSafeArea()
                    GeometryReader { geometry in
                        Path { path in
                            let gridSize: CGFloat = 20
                            for x in stride(from: 0, through: geometry.size.width, by: gridSize) {
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                            }
                            for y in stride(from: 0, through: geometry.size.height, by: gridSize) {
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                            }
                        }
                        .stroke(theme.textTertiary.opacity(0.12), lineWidth: 0.5)
                    }
                }
            )
    }
}

extension View {
    func gridBackground() -> some View {
        modifier(GridBackgroundModifier())
    }
}
