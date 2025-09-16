//
//  PocasPalabrasApp.swift
//  PocasPalabras
//
//  Created by Ricardo Sanchez-Macias on 6/13/25.
//

import SwiftUI
import SwiftData

@main
struct PocasPalabrasApp: App {
    
    // MARK: - SwiftData Configuration
    
    /// The SwiftData model container that manages our data models
    /// This container is responsible for setting up the persistent store
    var modelContainer: ModelContainer = {
        let schema = Schema([DateTracker.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Provide the model container to the view hierarchy
                // This allows any view in the app to access SwiftData functionality
                .modelContainer(modelContainer)
        }
    }
}
