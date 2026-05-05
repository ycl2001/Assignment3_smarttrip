//
//  WeatherCardView.swift
//  Assignment3_SmartTrip
//
//  Created by Leo on 2026/5/3.
//

import SwiftUI

struct WeatherCardView: View {
    // Connect to the ViewModel we just fixed
    @StateObject private var viewModel = WeatherViewModel()
    
    // Pass the destination city
    let location: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("During your trip, the average temperature is")
                    .font(.caption)
                    .opacity(0.9)
                
                // Display data if successfully fetched
                if let info = viewModel.weatherInfo {
                    Text("\(info.temperature)°C")
                        .font(.system(size: 32, weight: .bold))
                    Text("in \(info.locationName)")
                        .font(.footnote)
                        .fontWeight(.medium)
                } else {
                    // Loading state before data arrives
                    Text("--°C")
                        .font(.system(size: 32, weight: .bold))
                    Text("in \(location)")
                        .font(.footnote)
                        .fontWeight(.medium)
                    ProgressView()
                        .tint(.white)
                }
            }
            
            Spacer()
            
            // Decorative background weather icon
            Image(systemName: viewModel.weatherInfo?.symbolName ?? "cloud.sun.fill")
                .font(.system(size: 70))
                .opacity(0.2)
                .offset(x: 20, y: 15)
                .clipped()
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.teal)
        .foregroundColor(.white)
        .cornerRadius(16)
        // Automatically fetch weather when the card appears
        .task {
            await viewModel.fetchWeather(for: location)
        }
    }
}

// Preview provider to see the UI immediately in Xcode Canvas
#Preview {
    WeatherCardView(location: "Osaka")
        .padding()
}
