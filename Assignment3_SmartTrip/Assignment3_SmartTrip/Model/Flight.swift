//
//  Flight.swift
//  Assignment3_SmartTrip
//

import Foundation

enum SeatClass: String, CaseIterable, Identifiable {
    case economy      = "Economy"
    case premiumEcon  = "Premium Economy"
    case business     = "Business"
    case first        = "First"
    var id: String { rawValue }
}

struct Flight: Identifiable {
    let id: UUID
    var flightNumber:     String
    var airline:          String
    var departureAirport: String
    var arrivalAirport:   String
    var departureTime:    Date
    var arrivalTime:      Date
    var seatClass:        SeatClass
    var confirmationCode: String
    var notes:            String

    init(
        id: UUID = UUID(),
        flightNumber:     String,
        airline:          String,
        departureAirport: String,
        arrivalAirport:   String,
        departureTime:    Date,
        arrivalTime:      Date,
        seatClass:        SeatClass = .economy,
        confirmationCode: String    = "",
        notes:            String    = ""
    ) {
        self.id               = id
        self.flightNumber     = flightNumber
        self.airline          = airline
        self.departureAirport = departureAirport
        self.arrivalAirport   = arrivalAirport
        self.departureTime    = departureTime
        self.arrivalTime      = arrivalTime
        self.seatClass        = seatClass
        self.confirmationCode = confirmationCode
        self.notes            = notes
    }
}
