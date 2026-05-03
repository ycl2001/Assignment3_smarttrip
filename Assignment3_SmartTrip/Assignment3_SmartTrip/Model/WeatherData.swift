//
//  WeatherData.swift
//  Assignment3_SmartTrip
//
//  Created by Leo on 2026/5/3.
//

import Foundation

struct WeatherInfo: Identifiable {
    let id = UUID()
    let condition: String    // Like "Sunny"
    let symbolName: String   // SF Symbols "sun.max.fill"
    let temperature: Int     // temp
    let locationName: String // city name
}
