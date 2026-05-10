//
//  FlightSearchViewModel.swift
//  Assignment3_SmartTrip
//

import Foundation
import Combine

// MARK: - API Response Models

private struct AeroFlightResponse: Decodable {
    let number:    String?
    let status:    String?
    let airline:   AeroAirline?
    let departure: AeroEndpoint?
    let arrival:   AeroEndpoint?
}

private struct AeroAirline: Decodable {
    let name: String?
    let iata: String?
}

private struct AeroEndpoint: Decodable {
    let airport:       AeroAirport?
    let scheduledTime: AeroScheduledTime?
}

private struct AeroAirport: Decodable {
    let iata:             String?
    let name:             String?
    let municipalityName: String?
}

private struct AeroScheduledTime: Decodable {
    let utc:   String?
    let local: String?
}

// MARK: - Result passed to the view

struct FlightSearchResult: Equatable {
    let flightNumber:     String
    let airline:          String
    let departureAirport: String
    let arrivalAirport:   String
    let departureTime:    Date
    let arrivalTime:      Date
}

// MARK: - ViewModel

@MainActor
class FlightSearchViewModel: ObservableObject {
    @Published var result:       FlightSearchResult?
    @Published var isSearching   = false
    @Published var errorMessage: String?

    // ─── Replace with your own key from https://rapidapi.com ───
    // Sign up free → search "AeroDataBox" → subscribe to "Free" plan → copy API key
    private let rapidAPIKey = "YOUR_RAPIDAPI_KEY_HERE"
    private let host        = "aerodatabox.p.rapidapi.com"

    func search(flightNumber: String, date: Date) async {
        let clean = flightNumber
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "")

        guard !clean.isEmpty else {
            errorMessage = "Enter a flight number first"
            return
        }

        let dateStr = isoDate(date)
        let urlStr  = "https://\(host)/flights/number/\(clean)/\(dateStr)"

        guard let url = URL(string: urlStr) else {
            errorMessage = "Invalid flight number"
            return
        }

        var request = URLRequest(url: url)
        request.setValue(rapidAPIKey,  forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(host,         forHTTPHeaderField: "x-rapidapi-host")

        isSearching  = true
        errorMessage = nil
        result       = nil

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 401, 403:
                    errorMessage = "Invalid API key — check FlightSearchViewModel.swift"
                    isSearching  = false
                    return
                case 404:
                    errorMessage = "Flight not found for this date"
                    isSearching  = false
                    return
                case 429:
                    errorMessage = "Too many requests — try again later"
                    isSearching  = false
                    return
                default: break
                }
            }

            let flights = try JSONDecoder().decode([AeroFlightResponse].self, from: data)

            guard let first = flights.first else {
                errorMessage = "No flight found for \(clean) on \(dateStr)"
                isSearching  = false
                return
            }

            result = FlightSearchResult(
                flightNumber:     first.number ?? clean,
                airline:          first.airline?.name ?? "Unknown Airline",
                departureAirport: first.departure?.airport?.iata ?? "???",
                arrivalAirport:   first.arrival?.airport?.iata ?? "???",
                departureTime:    parseTime(first.departure?.scheduledTime?.utc) ?? date,
                arrivalTime:      parseTime(first.arrival?.scheduledTime?.utc)   ?? date
            )
        } catch {
            errorMessage = "Could not load flight data"
        }

        isSearching = false
    }

    // MARK: - Helpers

    /// "2026-05-10" from a Date
    private func isoDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale     = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }

    /// Parse AeroDataBox UTC string: "2026-05-10 21:00Z"
    private func parseTime(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm'Z'"
        f.timeZone   = TimeZone(identifier: "UTC")
        f.locale     = Locale(identifier: "en_US_POSIX")
        return f.date(from: raw)
    }
}
