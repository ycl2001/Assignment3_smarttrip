//
//  TripSample.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import Foundation

struct TripSampleData {
    static var sampleTrip = Trip(
        name: "Tokyo Spring Trip",
        destination: "Tokyo, Japan",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
        members: [
            TripMember(name: "Selina", role: "Host"),
            TripMember(name: "Jimmy", role: "Member"),
            TripMember(name: "Zoe", role: "Member"),
            TripMember(name: "Leo", role: "Member"),
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
