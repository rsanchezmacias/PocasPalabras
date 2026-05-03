import SwiftUI
import SwiftData

/// Renders the entire life as a grid of weeks using Canvas for performance.
/// Each row = 1 year, each column = 1 week (52 columns x ~85 rows = ~4,420 cells).
///
/// Approach: No ScrollView (it eats pinch gestures). Instead, manual pan via
/// DragGesture + zoom via MagnifyGesture, with the canvas drawn at base size
/// and transformed via scaleEffect + offset. Clipped to the container bounds.
struct LifeGridCanvasView: View {
    let engine: LifeCalendarEngine
    var onSelectDate: ((Date) -> Void)?

    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) var theme

    var body: some View {
        ViewModelView({
            let vm = LifeGridCanvasViewModel(modelContext: modelContext, engine: engine)
            vm.fetchWeekColors()
            return vm
        }) { viewModel in
            VStack(spacing: AppTheme.spacingSM) {
                header(viewModel: viewModel)

                GeometryReader { geo in
                    let availableWidth = geo.size.width - viewModel.padding * 2
                    let baseSpacing: CGFloat = 1.5
                    let baseCellSize = (availableWidth / CGFloat(viewModel.columnsPerRow)) - baseSpacing
                    let baseStep = baseCellSize + baseSpacing
                    let baseCanvasWidth = CGFloat(viewModel.columnsPerRow) * baseStep
                    let baseCanvasHeight = CGFloat(viewModel.rows) * baseStep
                    let viewSize = geo.size
                    let lookup = viewModel.colorLookup

                    Canvas { context, _ in
                        let weeksLived = viewModel.engine.weeksLived
                        let totalWeeks = viewModel.engine.totalWeeks

                        for row in 0..<viewModel.rows {
                            for col in 0..<viewModel.columnsPerRow {
                                let weekIndex = row * viewModel.columnsPerRow + col
                                guard weekIndex < totalWeeks else { continue }

                                let x = CGFloat(col) * baseStep
                                let y = CGFloat(row) * baseStep
                                let rect = CGRect(x: x, y: y, width: baseCellSize, height: baseCellSize)
                                let cornerR = max(0.5, baseCellSize * 0.15)
                                let path = Path(roundedRect: rect, cornerRadius: cornerR)

                                if weekIndex == weeksLived {
                                    context.fill(path, with: .color(theme.todayHighlight))
                                } else if let hex = lookup[weekIndex] {
                                    context.fill(path, with: .color(Color(hexString: hex)))
                                } else if weekIndex < weeksLived {
                                    context.fill(path, with: .color(theme.pastDay))
                                } else {
                                    context.fill(path, with: .color(theme.futureDay))
                                }
                            }
                        }
                    }
                    .frame(width: baseCanvasWidth, height: baseCanvasHeight)
                    .scaleEffect(viewModel.zoom, anchor: .topLeading)
                    .offset(x: viewModel.pan.width + viewModel.padding, y: viewModel.pan.height)
                    .frame(width: viewSize.width, height: viewSize.height, alignment: .topLeading)
                    .clipped()
                    .contentShape(Rectangle())
                    .gesture(pinchGesture(viewModel: viewModel, canvasSize: CGSize(width: baseCanvasWidth, height: baseCanvasHeight), viewSize: viewSize))
                    .simultaneousGesture(panGesture(viewModel: viewModel, canvasSize: CGSize(width: baseCanvasWidth, height: baseCanvasHeight), viewSize: viewSize))
                    .simultaneousGesture(tapGesture(viewModel: viewModel, baseStep: baseStep))
                }

                legend(viewModel: viewModel)
            }
        }
    }

    // MARK: - Header

    private func header(viewModel: LifeGridCanvasViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your life in weeks")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(theme.textPrimary)
                Text("Pinch to zoom. Tap a week to open it.")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            if viewModel.zoom > 1.05 {
                Button {
                    viewModel.resetZoom()
                } label: {
                    Text("Reset")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .padding(.horizontal, viewModel.padding)
    }

    // MARK: - Legend

    private func legend(viewModel: LifeGridCanvasViewModel) -> some View {
        HStack(spacing: AppTheme.spacingMD) {
            legendItem(color: theme.todayHighlight, label: "Now")
            legendItem(color: theme.futureDay, label: "Ahead")
        }
        .padding(.horizontal, viewModel.padding)
        .padding(.bottom, AppTheme.spacingXS)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(theme.textSecondary)
        }
    }

    // MARK: - Gestures

    private func pinchGesture(viewModel: LifeGridCanvasViewModel, canvasSize: CGSize, viewSize: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                viewModel.handlePinchChanged(magnification: value.magnification)
            }
            .onEnded { _ in
                viewModel.handlePinchEnded(canvasSize: canvasSize, viewSize: viewSize)
            }
    }

    private func panGesture(viewModel: LifeGridCanvasViewModel, canvasSize: CGSize, viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.handleDragChanged(translation: value.translation)
            }
            .onEnded { _ in
                viewModel.handleDragEnded(canvasSize: canvasSize, viewSize: viewSize)
            }
    }

    private func tapGesture(viewModel: LifeGridCanvasViewModel, baseStep: CGFloat) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                if let weekIndex = viewModel.weekIndexForTap(location: value.location, baseStep: baseStep) {
                    onSelectDate?(viewModel.engine.dateForWeek(weekIndex))
                }
            }
    }
}
