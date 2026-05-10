//
//  DemoCardData.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import Foundation

// MARK: - Demo Group Trip Model
// Used by GroupView and PastTripsView for placeholder trip data.

struct DemoGroupTrip: Identifiable {
    let id = UUID()
    let title: String
    let destination: String
    let dateRange: String
    let status: String
    let members: [String]
    let totalBudget: Double
}

// MARK: - Demo Card Data
// Central demo data source used across homepage, dashboard, budget, group, and past trip pages.

struct DemoCardData {

    // MARK: - Current Demo Trip Members

    static let members = [
        TripMember(name: "Jimmy", role: "Host"),
        TripMember(name: "Selina", role: "Member"),
        TripMember(name: "Zoe", role: "Member"),
        TripMember(name: "Leo", role: "Member")
    ]

    // MARK: - Current Demo Trip

    static let trip = Trip(
        name: "Tokyo Spring Trip",
        destination: "Tokyo, Japan",
        startDate: Date(),
        endDate: Calendar.current.date(
            byAdding: .day,
            value: 5,
            to: Date()
        ) ?? Date(),
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
                notes: "Dinner option near the station.",
                category: .food
            )
        ]
    )

    // MARK: - Current Demo Budget / Expenses

    static let expenses = [
        Expense(
            title: "Sushi Dinner",
            amount: 120,
            payerId: members[0].id,
            participantIds: members.map { $0.id },
            category: .food
        ),
        Expense(
            title: "Train Pass",
            amount: 80,
            payerId: members[1].id,
            participantIds: members.map { $0.id },
            category: .transport
        ),
        Expense(
            title: "Theme Park Tickets",
            amount: 210,
            payerId: members[2].id,
            participantIds: members.map { $0.id },
            category: .activities
        )
    ]

    // MARK: - Placeholder Group / Past Trip Data

    static let groupTrips: [DemoGroupTrip] = [
        DemoGroupTrip(
            title: "Sydney Food Trip",
            destination: "Sydney, Australia",
            dateRange: "Mar 12 – Mar 15, 2026",
            status: "Completed",
            members: ["Jimmy", "Selina", "Chloe"],
            totalBudget: 420
        ),
        DemoGroupTrip(
            title: "Bali Friends Trip",
            destination: "Bali, Indonesia",
            dateRange: "Jan 8 – Jan 14, 2026",
            status: "Completed",
            members: ["Jimmy", "Zoe", "Mia", "Lucas"],
            totalBudget: 860
        ),
        DemoGroupTrip(
            title: "South Korea Family Trip",
            destination: "Seoul, South Korea",
            dateRange: "Dec 18 – Dec 24, 2025",
            status: "Completed",
            members: [
                "Jimmy",
                "Sophia",
                "Rachel",
                "Dylan",
                "Mia",
                "Asher",
                "Jake"
            ],
            totalBudget: 1320
        )
    ]
}
