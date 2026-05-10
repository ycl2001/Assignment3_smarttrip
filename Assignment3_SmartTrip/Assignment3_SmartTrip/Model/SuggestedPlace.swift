//
//  SuggestedPlace.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 10/5/2026.
//

import Foundation

struct SuggestedPlace: Identifiable {
    let id = UUID()
    let destination: String
    let name: String
    let location: String
    let suggestedBy: String
    let note: String
    let category: ItineraryCategory
}
