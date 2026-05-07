//
//  ItineraryItem.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Represents one place or activity in the trip itinerary.
// Each item includes schedule, location, notes, and category information.
import Foundation

struct ItineraryItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var location: String
    var date: Date
    var startTime: Date
    var notes: String
    var category: ItineraryCategory
}

// Defines fixed category options for itinerary items.
// Using an enum prevents inconsistent category names across the app.
enum ItineraryCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case attraction = "Attraction"
    case transport = "Transport"
    case shopping = "Shopping"
    case accommodation = "Accommodation"
    case other = "Other"

    var id: String { rawValue }
}
