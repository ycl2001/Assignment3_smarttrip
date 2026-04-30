//
//  ItineraryViewModel.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import Foundation
import Combine

class ItineraryViewModel: ObservableObject {
    @Published var itineraryItems: [ItineraryItem] = []

    func loadItems(from trip: Trip) {
        itineraryItems = trip.itineraryItems
    }

    func addItem(_ item: ItineraryItem) {
        itineraryItems.append(item)
    }

    func updateItem(_ updatedItem: ItineraryItem) {
        if let index = itineraryItems.firstIndex(where: { $0.id == updatedItem.id }) {
            itineraryItems[index] = updatedItem
        }
    }

    func deleteItem(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            itineraryItems.remove(at: index)
        }
    }

    var activityCount: Int {
        itineraryItems.count
    }
}
