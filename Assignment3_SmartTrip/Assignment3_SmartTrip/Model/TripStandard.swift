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
    let id = UUID()
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var members: [TripMember]
    var itineraryItems: [ItineraryItem]

// Calculates the total number of days in the trip.
// This is used by the dashboard to summarise trip duration.
    var numberOfDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

// Counts how many itinerary activities have been added to this trip.
    var activityCount: Int {
        itineraryItems.count
    }
}
