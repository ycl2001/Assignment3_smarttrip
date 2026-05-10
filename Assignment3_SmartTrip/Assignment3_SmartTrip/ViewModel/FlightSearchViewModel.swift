//
//  FlightSearchViewModel.swift
//  Assignment3_SmartTrip
//

import Foundation
import Combine

// MARK: - API Response Models (Airport FIDS endpoint)

private struct AeroAirportFlightsResponse: Decodable {
    let departures: [AeroFlightResponse]?
}

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
    @Published var results:      [FlightSearchResult] = []
    @Published var isSearching   = false
    @Published var errorMessage: String?

    // ─── Replace with your own key from https://rapidapi.com ───
    // Sign up free → search "AeroDataBox" → subscribe to "Free" plan → copy API key
    private let rapidAPIKey = "YOUR_RAPIDAPI_KEY_HERE"
    private let host        = "aerodatabox.p.rapidapi.com"

    func search(from: String, to: String, date: Date) async {
        let fromClean = from.trimmingCharacters(in: .whitespaces).uppercased()
        let toClean   = to.trimmingCharacters(in: .whitespaces).uppercased()

        guard !fromClean.isEmpty, !toClean.isEmpty else {
            errorMessage = "Enter both departure and arrival airports"
            return
        }
        guard fromClean.count == 3, toClean.count == 3 else {
            errorMessage = "Use 3-letter IATA codes (e.g. SYD, NRT)"
            return
        }

        let fromDT = isoDateTime(date, hour: 0,  minute: 0)
        let toDT   = isoDateTime(date, hour: 23, minute: 59)

        let urlStr = "https://\(host)/flights/airports/iata/\(fromClean)/\(fromDT)/\(toDT)?direction=Departure&withLeg=true&withCodeshared=true"

        guard let url = URL(string: urlStr) else {
            errorMessage = "Invalid airport code"
            return
        }

        var request = URLRequest(url: url)
        request.setValue(rapidAPIKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(host,        forHTTPHeaderField: "x-rapidapi-host")

        isSearching  = true
        errorMessage = nil
        results      = []

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 401, 403:
                    errorMessage = "Invalid API key — check FlightSearchViewModel.swift"
                    isSearching = false
                    return
                case 404:
                    errorMessage = "Airport not found — use IATA code (e.g. SYD)"
                    isSearching = false
                    return
                case 429:
                    errorMessage = "Too many requests — try again later"
                    isSearching = false
                    return
                default: break
                }
            }

            let parsed = try JSONDecoder().decode(AeroAirportFlightsResponse.self, from: data)
            let departures = parsed.departures ?? []

            // Filter by destination airport IATA
            let matched = departures.filter {
                $0.arrival?.airport?.iata?.uppercased() == toClean
            }

            if matched.isEmpty {
                errorMessage = "No direct flights \(fromClean)→\(toClean) on this date"
            } else {
                results = matched.compactMap { flight in
                    guard let num = flight.number else { return nil }
                    return FlightSearchResult(
                        flightNumber:     num,
                        airline:          flight.airline?.name ?? "Unknown Airline",
                        departureAirport: flight.departure?.airport?.iata ?? fromClean,
                        arrivalAirport:   flight.arrival?.airport?.iata   ?? toClean,
                        departureTime:    parseTime(flight.departure?.scheduledTime?.utc) ?? date,
                        arrivalTime:      parseTime(flight.arrival?.scheduledTime?.utc)   ?? date
                    )
                }
            }
        } catch {
            errorMessage = "Could not load flight data"
        }

        isSearching = false
    }

    // MARK: - Helpers

    /// "2026-05-10T00:00" format required by AeroDataBox airport endpoint
    private func isoDateTime(_ date: Date, hour: Int, minute: Int = 0) -> String {
        var comps = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: date)
        comps.hour   = hour
        comps.minute = minute
        let d = Calendar(identifier: .gregorian).date(from: comps) ?? date
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        f.locale     = Locale(identifier: "en_US_POSIX")
        return f.string(from: d)
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
