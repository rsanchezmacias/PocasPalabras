//
//  ContentView.swift
//  PocasPalabras
//
//  Created by Ricardo Sanchez-Macias on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
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
    }
}

#Preview {
    ContentView()
}
