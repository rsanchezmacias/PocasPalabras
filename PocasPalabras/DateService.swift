//
//  DateService.swift
//  PocasPalabras
//
//  Created by Ricardo Sanchez-Macias on 6/13/25.
//

import Foundation
import SwiftData

/// Service class responsible for managing date tracking operations
/// This follows the Service Layer pattern to separate business logic from UI
@Observable
final class DateService {
    
    // MARK: - Properties
    
    /// The model context for SwiftData operations
    private let modelContext: ModelContext
    
    /// The current date tracker instance
    private var dateTracker: DateTracker?
    
    /// The number of days since the initial date
    var daysSinceInitial: Int = 0
    
    // MARK: - Initialization
    
    /// Initializes the date service with a model context
    /// - Parameter modelContext: The SwiftData model context for database operations
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateDateTracker()
        calculateDaysSinceInitial()
    }
    
    // MARK: - Public Methods
    
    /// Refreshes the days count calculation
    /// This can be called when the app becomes active to update the count
    func refreshDaysCount() {
        calculateDaysSinceInitial()
    }
    
    /// Returns a formatted string for display
    /// - Returns: A string like "5 days" or "1 day"
    func getDaysDisplayText() -> String {
        if daysSinceInitial == 1 {
            return "1 day"
        } else {
            return "\(daysSinceInitial) days"
        }
    }
    
    // MARK: - Private Methods
    
    /// Loads existing date tracker or creates a new one if none exists
    private func loadOrCreateDateTracker() {
        // Try to fetch existing date tracker
        let descriptor = FetchDescriptor<DateTracker>()
        
        do {
            let trackers = try modelContext.fetch(descriptor)
            
            if let existingTracker = trackers.first {
                // Use existing tracker
                self.dateTracker = existingTracker
            } else {
                // Create new tracker with current date
                let newTracker = DateTracker(initialDate: Date())
                modelContext.insert(newTracker)
                
                // Save the context
                try modelContext.save()
                
                self.dateTracker = newTracker
            }
        } catch {
            // Handle error by creating a fallback tracker
            print("Error loading/creating date tracker: \(error)")
            let fallbackTracker = DateTracker(initialDate: Date())
            modelContext.insert(fallbackTracker)
            self.dateTracker = fallbackTracker
            
            // Attempt to save, but don't crash if it fails
            try? modelContext.save()
        }
    }
    
    /// Calculates the number of days between the initial date and now
    private func calculateDaysSinceInitial() {
        guard let tracker = dateTracker else {
            daysSinceInitial = 0
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate the difference in days
        let components = calendar.dateComponents([.day], from: tracker.initialDate, to: now)
        daysSinceInitial = components.day ?? 0
        
        // Ensure we don't show negative days
        if daysSinceInitial < 0 {
            daysSinceInitial = 0
        }
    }
}
