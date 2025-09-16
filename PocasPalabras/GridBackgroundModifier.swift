import SwiftUI

// MARK: - Grid Background Modifier
/// A custom ViewModifier that applies a soft white background with grid lines to any view
/// ViewModifiers are reusable components that can transform views by adding styling, behavior, or layout changes
struct GridBackgroundModifier: ViewModifier {
    
    /// The main function that defines how this modifier transforms the content view
    /// - Parameter content: The original view that this modifier is applied to
    /// - Returns: The modified view with the grid background applied
    func body(content: Content) -> some View {
        content
            // Apply the background behind the content view
            .background(
                // ZStack layers views on top of each other (z-axis stacking)
                // First view goes to the back, last view goes to the front
                ZStack {
                    
                    // MARK: - Base Background Color
                    // Create a soft white background color (0.98 = very light gray, almost white)
                    // Color(white:) creates a grayscale color where 0.0 = black, 1.0 = white
                    Color(white: 0.98)
                        // Make the background extend beyond safe areas (notch, home indicator, etc.)
                        .ignoresSafeArea()
                    
                    // MARK: - Grid Pattern Layer
                    // GeometryReader: A container view that gives you access to the size and position
                    // of its parent view. It's like asking "How big is the space I have to work with?"
                    // The closure receives a GeometryProxy that contains size and coordinate space info
                    GeometryReader { geometry in
                        
                        // Path: A shape that you can draw by specifying points and lines
                        // Think of it like drawing with a pen - you move to points and draw lines between them
                        Path { path in
                            // Define the spacing between grid lines (20 points apart)
                            let gridSize: CGFloat = 20
                            
                            // MARK: - Draw Vertical Lines
                            // stride(from:through:by:) creates a sequence of numbers
                            // from 0 to the full width, incrementing by gridSize each time
                            // Example: if width is 100 and gridSize is 20, we get: 0, 20, 40, 60, 80, 100
                            for x in stride(from: 0, through: geometry.size.width, by: gridSize) {
                                // move(to:) lifts the "pen" and moves to a new position without drawing
                                path.move(to: CGPoint(x: x, y: 0))
                                // addLine(to:) draws a straight line from current position to the specified point
                                path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                            }
                            
                            // MARK: - Draw Horizontal Lines
                            // Same concept as vertical lines, but going across the width
                            for y in stride(from: 0, through: geometry.size.height, by: gridSize) {
                                // Start at the left edge of the current y position
                                path.move(to: CGPoint(x: 0, y: y))
                                // Draw line to the right edge at the same y position
                                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                            }
                        }
                        // Apply visual styling to the path we just created
                        // .stroke() makes the path visible by drawing lines along it
                        // Color.gray.opacity(0.2) = light gray with 20% opacity (very subtle)
                        // lineWidth: 0.5 = very thin lines (half a point thick)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                    }
                }
            )
    }
}

// MARK: - View Extension for Easy Usage
/// Extension to add a convenient method to any SwiftUI View
/// This allows us to write .gridBackground() instead of .modifier(GridBackgroundModifier())
extension View {
    /// Applies the grid background modifier to any view
    /// - Returns: The view with the grid background applied
    func gridBackground() -> some View {
        // modifier() applies a ViewModifier to the current view
        modifier(GridBackgroundModifier())
    }
}
