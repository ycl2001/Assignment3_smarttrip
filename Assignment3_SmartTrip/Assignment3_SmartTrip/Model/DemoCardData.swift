//
//  DemoCardData.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import Foundation

struct DemoCardData {
    static let members = [
        TripMember(name: "Selina", role: "Host"),
        TripMember(name: "Jimmy", role: "Member"),
        TripMember(name: "Leo", role: "Member")
    ]

    static let trip = Trip(
        name: "Japan Spring Trip",
        destination: "Tokyo, Japan",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
        members: members,
        itineraryItems: [
            ItineraryItem(
                title: "Shibuya Sky",
                location: "Shibuya",
                date: Date(),
                startTime: Date(),
                notes: "Book tickets before visiting.",
                category: .attraction
            ),
            ItineraryItem(
                title: "Ichiran Ramen",
                location: "Shinjuku",
                date: Date(),
                startTime: Date(),
                notes: "Good dinner option.",
                category: .food
            )
        ]
    )

    static let expenses = [
        Expense(
            title: "Dinner",
            amount: 90,
            payerId: members[0].id,
            participantIds: members.map { $0.id },
            category: .food
        )
    ]
}
