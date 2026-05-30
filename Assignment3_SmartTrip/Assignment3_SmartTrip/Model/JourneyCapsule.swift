//
//  JourneyCapsule.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/5/2026.
//

import Foundation

struct JourneyCapsule: Identifiable {
    let id = UUID()
    var title: String
    var caption: String
    var placeName: String
    var location: String
    var date: Date
    var suggestedPrompt: String
}
