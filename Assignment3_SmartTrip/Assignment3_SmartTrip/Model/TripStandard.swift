//
//  TripStandard.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import Foundation

struct Trip: Identifiable {
    let id = UUID()
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var members: [TripMember]
    var itineraryItems: [ItineraryItem]
    
    var numberOfDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    var activityCount: Int {
        itineraryItems.count
    }
}
