//
//  DateTracker.swift
//  PocasPalabras
//
//  Created by Ricardo Sanchez-Macias on 6/13/25.
//

import Foundation
import SwiftData

/// SwiftData model to track the initial date when the app was first launched
/// @Model macro automatically generates the necessary SwiftData functionality
@Model
final class DateTracker {
    /// The initial date when the app was first launched
    /// This is the only stored property we need for now
    var initialDate: Date
    
    /// Initializer for creating a new DateTracker instance
    /// - Parameter initialDate: The date to track (defaults to current date)
    init(initialDate: Date = Date()) {
        self.initialDate = initialDate
    }
}
