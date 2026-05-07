//
//  TripSample.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Provides sample trip data for previews and testing.
// This allows views to be tested before real user-created data is connected.
import Foundation

struct TripSampleData {
    // Example trip used in SwiftUI previews and development testing.
    static var sampleTrip = Trip(
        name: "Tokyo Spring Trip",
        destination: "Tokyo, Japan",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
        members: [
            TripMember(name: "Jimmy", role: "Host"),
            TripMember(name: "Leo", role: "Member"),
            TripMember(name: "Zoe", role: "Member"),
            TripMember(name: "Selina", role: "Member"),
        ],
        itineraryItems: [
            ItineraryItem(
                title: "Shibuya Sky",
                location: "Shibuya",
                date: Date(),
                startTime: Date(),
                notes: "Book tickets before visiting.",
                category: .attraction
            )
        ]
    )
}
