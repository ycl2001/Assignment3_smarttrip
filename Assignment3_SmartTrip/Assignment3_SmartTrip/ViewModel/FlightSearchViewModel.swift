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
    @Published var results:            [FlightSearchResult] = []
    @Published var isSearching         = false
    @Published var errorMessage:       String?
    /// Resolved IATA codes shown as a hint under the search fields
    @Published var resolvedFrom:       String?
    @Published var resolvedTo:         String?

    // ─── Replace with your own key from https://rapidapi.com ───
    // Sign up free → search "AeroDataBox" → subscribe to "Free" plan → copy API key
    private let rapidAPIKey = "c322f7069amsh46e326bf882bcaep17e524jsn362d7ce2eb03"
    private let host        = "aerodatabox.p.rapidapi.com"

    // MARK: - City → IATA lookup table
    // Major cities worldwide. Keys are lowercase; partial matching also applied.

    private static let cityToIATA: [String: String] = [
        // ── Australia & Pacific ──
        "sydney": "SYD", "melbourne": "MEL", "brisbane": "BNE", "perth": "PER",
        "adelaide": "ADL", "gold coast": "OOL", "cairns": "CNS", "hobart": "HBA",
        "darwin": "DRW", "canberra": "CBR", "auckland": "AKL", "wellington": "WLG",
        "christchurch": "CHC", "fiji": "NAN", "nadi": "NAN", "guam": "GUM",
        "tahiti": "PPT", "papeete": "PPT", "port moresby": "POM",
        // ── Japan ──
        "tokyo": "NRT", "osaka": "KIX", "nagoya": "NGO", "fukuoka": "FUK",
        "sapporo": "CTS", "okinawa": "OKA",
        // ── Korea ──
        "seoul": "ICN", "busan": "PUS",
        // ── China ──
        "beijing": "PEK", "shanghai": "PVG", "guangzhou": "CAN", "shenzhen": "SZX",
        "chengdu": "CTU", "chongqing": "CKG", "xiamen": "XMN", "kunming": "KMG",
        "xi'an": "XIY", "xian": "XIY", "wuhan": "WUH", "hangzhou": "HGH",
        "nanjing": "NKG", "qingdao": "TAO", "dalian": "DLC", "tianjin": "TSN",
        "sanya": "SYX", "guilin": "KWL", "harbin": "HRB", "urumqi": "URC",
        // ── Greater China ──
        "hong kong": "HKG", "macau": "MFM", "taipei": "TPE", "taichung": "RMQ",
        // ── Southeast Asia ──
        "bangkok": "BKK", "phuket": "HKT", "chiang mai": "CNX", "krabi": "KBV",
        "singapore": "SIN", "kuala lumpur": "KUL", "kl": "KUL", "penang": "PEN",
        "jakarta": "CGK", "bali": "DPS", "denpasar": "DPS", "surabaya": "SUB",
        "manila": "MNL", "cebu": "CEB", "hanoi": "HAN", "ho chi minh city": "SGN",
        "saigon": "SGN", "da nang": "DAD", "phnom penh": "PNH", "siem reap": "REP",
        "yangon": "RGN", "vientiane": "VTE", "luang prabang": "LPQ",
        // ── South Asia ──
        "delhi": "DEL", "new delhi": "DEL", "mumbai": "BOM", "bombay": "BOM",
        "bangalore": "BLR", "bengaluru": "BLR", "chennai": "MAA", "madras": "MAA",
        "kolkata": "CCU", "calcutta": "CCU", "hyderabad": "HYD", "goa": "GOI",
        "ahmedabad": "AMD", "pune": "PNQ", "kochi": "COK", "cochin": "COK",
        "colombo": "CMB", "kathmandu": "KTM", "dhaka": "DAC",
        "islamabad": "ISB", "karachi": "KHI", "lahore": "LHE",
        "male": "MLE", "maldives": "MLE",
        // ── Central Asia ──
        "ulaanbaatar": "ULN", "almaty": "ALA", "tashkent": "TAS",
        // ── Middle East ──
        "dubai": "DXB", "abu dhabi": "AUH", "sharjah": "SHJ",
        "doha": "DOH", "riyadh": "RUH", "jeddah": "JED",
        "kuwait city": "KWI", "kuwait": "KWI", "muscat": "MCT",
        "bahrain": "BAH", "manama": "BAH", "amman": "AMM",
        "beirut": "BEY", "tel aviv": "TLV", "tehran": "IKA",
        "istanbul": "IST", "ankara": "ESB",
        // ── Europe ──
        "london": "LHR", "manchester": "MAN", "edinburgh": "EDI",
        "birmingham": "BHX", "glasgow": "GLA", "dublin": "DUB",
        "paris": "CDG", "nice": "NCE", "lyon": "LYS", "marseille": "MRS",
        "amsterdam": "AMS", "brussels": "BRU", "luxembourg": "LUX",
        "frankfurt": "FRA", "munich": "MUC", "berlin": "BER",
        "hamburg": "HAM", "dusseldorf": "DUS", "cologne": "CGN",
        "zurich": "ZRH", "geneva": "GVA", "basel": "BSL",
        "vienna": "VIE", "salzburg": "SZG", "innsbruck": "INN",
        "rome": "FCO", "milan": "MXP", "venice": "VCE",
        "florence": "FLR", "naples": "NAP", "palermo": "PMO",
        "madrid": "MAD", "barcelona": "BCN", "seville": "SVQ",
        "valencia": "VLC", "bilbao": "BIO", "malaga": "AGP",
        "lisbon": "LIS", "porto": "OPO", "faro": "FAO",
        "copenhagen": "CPH", "stockholm": "ARN", "oslo": "OSL",
        "helsinki": "HEL", "reykjavik": "KEF",
        "athens": "ATH", "thessaloniki": "SKG", "heraklion": "HER",
        "warsaw": "WAW", "krakow": "KRK", "prague": "PRG",
        "budapest": "BUD", "bucharest": "OTP", "sofia": "SOF",
        "belgrade": "BEG", "zagreb": "ZAG", "sarajevo": "SJJ",
        "riga": "RIX", "tallinn": "TLL", "vilnius": "VNO",
        "kyiv": "KBP", "kiev": "KBP", "lviv": "LWO",
        "moscow": "SVO", "st. petersburg": "LED", "saint petersburg": "LED",
        // ── Africa ──
        "cairo": "CAI", "alexandria": "HBE", "luxor": "LXR",
        "casablanca": "CMN", "marrakech": "RAK", "tunis": "TUN",
        "johannesburg": "JNB", "cape town": "CPT", "durban": "DUR",
        "nairobi": "NBO", "mombasa": "MBA", "kampala": "EBB",
        "addis ababa": "ADD", "lagos": "LOS", "accra": "ACC",
        "dar es salaam": "DAR", "zanzibar": "ZNZ",
        "mauritius": "MRU", "reunion": "RUN",
        // ── North America ──
        "new york": "JFK", "nyc": "JFK", "los angeles": "LAX", "la": "LAX",
        "chicago": "ORD", "san francisco": "SFO", "miami": "MIA",
        "toronto": "YYZ", "vancouver": "YVR", "montreal": "YUL",
        "seattle": "SEA", "boston": "BOS", "dallas": "DFW",
        "houston": "IAH", "atlanta": "ATL", "washington": "IAD",
        "denver": "DEN", "las vegas": "LAS", "phoenix": "PHX",
        "honolulu": "HNL", "hawaii": "HNL", "anchorage": "ANC",
        "minneapolis": "MSP", "detroit": "DTW", "orlando": "MCO",
        "tampa": "TPA", "charlotte": "CLT", "san diego": "SAN",
        "portland": "PDX", "salt lake city": "SLC", "nashville": "BNA",
        "calgary": "YYC", "edmonton": "YEG", "ottawa": "YOW",
        "winnipeg": "YWG", "halifax": "YHZ", "quebec city": "YQB",
        "mexico city": "MEX", "cancun": "CUN", "guadalajara": "GDL",
        "monterrey": "MTY", "puerto vallarta": "PVR", "los cabos": "SJD",
        // ── Caribbean & Central America ──
        "havana": "HAV", "cuba": "HAV", "san jose": "SJO",
        "panama city": "PTY", "belize city": "BZE", "kingston": "KIN",
        "santo domingo": "SDQ", "san juan": "SJU", "nassau": "NAS",
        "montego bay": "MBJ", "barbados": "BGI", "port of spain": "POS",
        // ── South America ──
        "sao paulo": "GRU", "rio de janeiro": "GIG", "brasilia": "BSB",
        "buenos aires": "EZE", "lima": "LIM", "bogota": "BOG",
        "santiago": "SCL", "caracas": "CCS", "quito": "UIO",
        "medellin": "MDE", "cartagena": "CTG", "montevideo": "MVD",
        "asuncion": "ASU", "la paz": "VVI", "sucre": "SRE",
        "guayaquil": "GYE", "cusco": "CUZ"
    ]

    /// Returns the IATA code for a given city name (case-insensitive, partial match supported).
    func resolveIATA(for city: String) -> String? {
        let key = city.trimmingCharacters(in: .whitespaces).lowercased()
        if key.isEmpty { return nil }
        // 1. Direct match
        if let code = Self.cityToIATA[key] { return code }
        // 2. The input IS already a valid 3-letter IATA code
        if key.count == 3 && key.allSatisfy({ $0.isLetter }) {
            return key.uppercased()
        }
        // 3. Partial match — key is a substring of a known city name
        for (name, code) in Self.cityToIATA where name.contains(key) || key.contains(name) {
            return code
        }
        return nil
    }

    // MARK: - Search

    func search(fromCity: String, toCity: String, date: Date) async {
        // Resolve city names to IATA
        guard let fromIATA = resolveIATA(for: fromCity) else {
            errorMessage = "City not recognised: \"\(fromCity)\""
            resolvedFrom = nil
            return
        }
        guard let toIATA = resolveIATA(for: toCity) else {
            errorMessage = "City not recognised: \"\(toCity)\""
            resolvedTo = nil
            return
        }

        resolvedFrom = fromIATA
        resolvedTo   = toIATA

        let fromDT = isoDateTime(date, hour: 0,  minute: 0)
        let toDT   = isoDateTime(date, hour: 23, minute: 59)

        let urlStr = "https://\(host)/flights/airports/iata/\(fromIATA)/\(fromDT)/\(toDT)?direction=Departure&withLeg=true&withCodeshared=true"

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
                    isSearching = false; return
                case 404:
                    errorMessage = "Airport \(fromIATA) not found in database"
                    isSearching = false; return
                case 429:
                    errorMessage = "Too many requests — try again later"
                    isSearching = false; return
                default: break
                }
            }

            let parsed     = try JSONDecoder().decode(AeroAirportFlightsResponse.self, from: data)
            let departures = parsed.departures ?? []

            let matched = departures.filter {
                $0.arrival?.airport?.iata?.uppercased() == toIATA
            }

            if matched.isEmpty {
                errorMessage = "No direct flights \(fromIATA)→\(toIATA) on this date"
            } else {
                results = matched.compactMap { flight in
                    guard let num = flight.number else { return nil }
                    return FlightSearchResult(
                        flightNumber:     num,
                        airline:          flight.airline?.name ?? "Unknown Airline",
                        departureAirport: flight.departure?.airport?.iata ?? fromIATA,
                        arrivalAirport:   flight.arrival?.airport?.iata   ?? toIATA,
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

    private func parseTime(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm'Z'"
        f.timeZone   = TimeZone(identifier: "UTC")
        f.locale     = Locale(identifier: "en_US_POSIX")
        return f.date(from: raw)
    }
}
