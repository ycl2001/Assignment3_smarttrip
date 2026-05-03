//
//  WeatherViewModel.swift
//  Assignment3_SmartTrip
//
//  Created by Leo on 2026/5/3.
//

import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherInfo: WeatherInfo?
    
    // Paste personal OpenWeather API Key here
    private let apiKey = "fc1c39d25ce649e0f1462a29c50bf7d6"
    
    func fetchWeather(for location: String) async {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(location)&appid=\(apiKey)&units=metric"
        
        // Ensure the URL is valid (handles spaces in city names like "New York")
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            print("Invalid URL format")
            return
        }
        
        do {
            // Fetch data from OpenWeather
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check if the API key is active yet (helps with debugging)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                print("API Key not activated yet. Please wait a few more minutes.")
                return
            }
            
            // Decode the JSON data
            let decodedResponse = try JSONDecoder().decode(OWMResponse.self, from: data)
            
            // Map the API data safely
            let conditionCode = decodedResponse.weather.first?.id ?? 800
            let conditionName = decodedResponse.weather.first?.main ?? "Clear"
            
            // Update our UI Model
            self.weatherInfo = WeatherInfo(
                condition: conditionName,
                symbolName: getSymbolName(for: conditionCode),
                temperature: Int(decodedResponse.main.temp),
                locationName: decodedResponse.name
            )
        } catch {
            print("Failed to fetch weather data: \(error.localizedDescription)")
        }
    }
    
    // Helper function to map OpenWeatherMap codes to Apple's SF Symbols
    private func getSymbolName(for code: Int) -> String {
        switch code {
        case 200...232: return "cloud.bolt.rain.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...531: return "cloud.heavyrain.fill"
        case 600...622: return "cloud.snow.fill"
        case 701...781: return "cloud.fog.fill"
        case 800: return "sun.max.fill"
        case 801...804: return "cloud.sun.fill"
        default: return "cloud.sun.fill"
        }
    }
}

// MARK: - OpenWeatherMap JSON Decoding Models
// We need these structs to parse the specific JSON format that OpenWeather returns
struct OWMResponse: Codable {
    let weather: [OWMWeather]
    let main: OWMMain
    let name: String
}

struct OWMWeather: Codable {
    let main: String
    let id: Int
}

struct OWMMain: Codable {
    let temp: Double
}
