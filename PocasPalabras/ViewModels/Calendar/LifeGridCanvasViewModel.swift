import Foundation
import OSLog
import SwiftUI
import SwiftData

@Observable
final class LifeGridCanvasViewModel {
    var zoom: CGFloat = Constants.LifeCalendar.minZoom
    var lastZoom: CGFloat = Constants.LifeCalendar.minZoom
    var pan: CGSize = .zero
    var lastPan: CGSize = .zero

    let engine: LifeCalendarEngine
    let columnsPerRow = Constants.LifeCalendar.weeksPerYear
    let padding: CGFloat = Constants.LifeCalendar.canvasPadding

    var rows: Int { engine.lifeExpectancy }

    private let modelContext: ModelContext
    private var weekColors: [WeekColor] = []

    var colorLookup: [Int: String] {
        Dictionary(weekColors.map { ($0.weekIndex, $0.colorHex) }, uniquingKeysWith: { _, last in last })
    }

    init(modelContext: ModelContext, engine: LifeCalendarEngine) {
        self.modelContext = modelContext
        self.engine = engine
    }

    func fetchWeekColors() {
        let descriptor = FetchDescriptor<WeekColor>()
        do {
            weekColors = try modelContext.fetch(descriptor)
        } catch {
            AppLogger.dataAccess.error("Failed to fetch week colors: \(error)")
            weekColors = []
        }
    }

    // MARK: - Gesture Handling

    func handlePinchChanged(magnification: CGFloat) {
        zoom = min(max(lastZoom * magnification, Constants.LifeCalendar.minZoom), Constants.LifeCalendar.maxZoom)
    }

    func handlePinchEnded(canvasSize: CGSize, viewSize: CGSize) {
        lastZoom = zoom
        clampPan(canvasSize: canvasSize, viewSize: viewSize)
    }

    func handleDragChanged(translation: CGSize) {
        pan = CGSize(
            width: lastPan.width + translation.width,
            height: lastPan.height + translation.height
        )
    }

    func handleDragEnded(canvasSize: CGSize, viewSize: CGSize) {
        clampPan(canvasSize: canvasSize, viewSize: viewSize)
        lastPan = pan
    }

    func weekIndexForTap(location: CGPoint, baseStep: CGFloat) -> Int? {
        let canvasX = (location.x - padding - pan.width) / zoom
        let canvasY = (location.y - pan.height) / zoom

        let col = Int(canvasX / baseStep)
        let row = Int(canvasY / baseStep)

        guard col >= 0, col < columnsPerRow, row >= 0, row < rows else { return nil }
        let weekIndex = row * columnsPerRow + col
        guard weekIndex >= 0, weekIndex < engine.totalWeeks else { return nil }
        return weekIndex
    }

    func resetZoom() {
        withAnimation(.easeOut(duration: 0.3)) {
            zoom = Constants.LifeCalendar.minZoom
            lastZoom = Constants.LifeCalendar.minZoom
            pan = .zero
            lastPan = .zero
        }
    }

    func clampPan(canvasSize: CGSize, viewSize: CGSize) {
        let scaledW = canvasSize.width * zoom
        let scaledH = canvasSize.height * zoom

        let minX = min(0, viewSize.width - scaledW - padding * 2)
        let minY = min(0, viewSize.height - scaledH)

        pan = CGSize(
            width: min(0, max(minX, pan.width)),
            height: min(0, max(minY, pan.height))
        )
        lastPan = pan
    }
}
