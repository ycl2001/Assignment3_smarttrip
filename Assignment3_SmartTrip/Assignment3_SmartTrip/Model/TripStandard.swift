//
//  TripStandard.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Core trip model used across the app.
// This stores trip information, members, and itinerary items.
// Expenses are handled separately by the Expense model and ExpenseViewModel.

import Foundation

struct Trip: Identifiable {

    var id: UUID

    var name: String
    var destination: String

    var startDate: Date
    var endDate: Date

    var members: [TripMember]
    var itineraryItems: [ItineraryItem]

    init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        members: [TripMember],
        itineraryItems: [ItineraryItem]
    ) {

        self.id = id
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.members = members
        self.itineraryItems = itineraryItems
    }

    var numberOfDays: Int {

        Calendar.current.dateComponents(
            [.day],
            from: startDate,
            to: endDate
        ).day ?? 0
    }

    var activityCount: Int {
        itineraryItems.count
    }
}
