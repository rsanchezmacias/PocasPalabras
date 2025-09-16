//
//  ContentView.swift
//  PocasPalabras
//
//  Created by Ricardo Sanchez-Macias on 6/13/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // MARK: - Properties
    
    /// Access to the SwiftData model context
    @Environment(\.modelContext) private var modelContext
    
    /// The date service that manages our date tracking logic
    @State private var dateService: DateService?
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "calendar")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                // Display the days count or loading state
                if let service = dateService {
                    Text(service.getDaysDisplayText())
                        .font(.title2)
                        .fontWeight(.medium)
                } else {
                    Text("Loading...")
                        .font(.title2)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gridBackground()
            .ignoresSafeArea()
            
            // Bottom right button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("Button tapped!")
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    }
                    .glassEffect()
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            // Initialize the date service when the view appears
            setupDateService()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh the days count when the app comes back to foreground
            dateService?.refreshDaysCount()
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up the date service with the model context
    private func setupDateService() {
        if dateService == nil {
            dateService = DateService(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
