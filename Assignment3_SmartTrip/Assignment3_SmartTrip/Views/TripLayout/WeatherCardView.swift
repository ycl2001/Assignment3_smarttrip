//
//  WeatherCardView.swift
//  Assignment3_SmartTrip
//
//  Created by Leo on 2026/5/3.
//

import SwiftUI

struct WeatherCardView: View {
    @StateObject private var viewModel = WeatherViewModel()
    let location: String

    // Gradient shifts based on current weather condition
    private var cardGradient: LinearGradient {
        guard let symbol = viewModel.weatherInfo?.symbolName else {
            // Loading state — calm blue
            return LinearGradient(
                colors: [Color(red: 0.25, green: 0.50, blue: 0.82),
                         Color(red: 0.18, green: 0.38, blue: 0.70)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
        if symbol.contains("sun") {
            // Sunny — warm amber/orange
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.62, blue: 0.18),
                         Color(red: 0.94, green: 0.40, blue: 0.10)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        } else if symbol.contains("rain") {
            // Rainy — deep blue
            return LinearGradient(
                colors: [Color(red: 0.28, green: 0.45, blue: 0.72),
                         Color(red: 0.18, green: 0.32, blue: 0.58)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        } else if symbol.contains("snow") {
            // Snowy — icy blue
            return LinearGradient(
                colors: [Color(red: 0.58, green: 0.74, blue: 0.92),
                         Color(red: 0.42, green: 0.60, blue: 0.82)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        } else if symbol.contains("cloud") {
            // Cloudy — steel blue-grey
            return LinearGradient(
                colors: [Color(red: 0.42, green: 0.53, blue: 0.68),
                         Color(red: 0.30, green: 0.40, blue: 0.56)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
        // Default — blue
        return LinearGradient(
            colors: [Color(red: 0.25, green: 0.50, blue: 0.82),
                     Color(red: 0.18, green: 0.38, blue: 0.70)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // 1. Gradient background
            cardGradient

            // 2. Large decorative icon — bottom-right, very soft
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: viewModel.weatherInfo?.symbolName ?? "cloud.sun.fill")
                        .font(.system(size: 110))
                        .foregroundStyle(.white.opacity(0.18))
                        .offset(x: 28, y: 28)
                }
            }

            // 3. Main content
            VStack(alignment: .leading, spacing: 6) {

                // Top row: "Weather" label + loading spinner
                HStack {
                    Label("Weather", systemImage: "location.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.80))
                    Spacer()
                    if viewModel.weatherInfo == nil {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.75)
                    }
                }

                Spacer()

                // Temperature — large, rounded
                Text(viewModel.weatherInfo.map { "\($0.temperature)°" } ?? "--°")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // City · Condition
                HStack(spacing: 5) {
                    Text(viewModel.weatherInfo?.locationName ?? location)
                        .fontWeight(.semibold)
                    if let condition = viewModel.weatherInfo?.condition {
                        Text("·").foregroundStyle(.white.opacity(0.55))
                        Text(condition)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.90))
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 152)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.14), radius: 10, x: 0, y: 4)
        .task {
            await viewModel.fetchWeather(for: location)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        WeatherCardView(location: "Tokyo")
        WeatherCardView(location: "Sydney")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
