//
//  ItineraryViewModel.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Handles itinerary-related logic separately from the UI.
// This supports adding, editing, deleting, and counting itinerary items.
import Foundation
import Combine

class ItineraryViewModel: ObservableObject {
    // Published list of itinerary items so connected views can update when data changes.
    @Published var itineraryItems: [ItineraryItem] = []

    // Loads itinerary items from a selected trip into the view model.
    func loadItems(from trip: Trip) {
        itineraryItems = trip.itineraryItems
    }

    // Adds a new itinerary item to the list.
    func addItem(_ item: ItineraryItem) {
        itineraryItems.append(item)
    }

    // Finds an existing itinerary item by ID and replaces it with updated details.
    func updateItem(_ updatedItem: ItineraryItem) {
        if let index = itineraryItems.firstIndex(where: { $0.id == updatedItem.id }) {
            itineraryItems[index] = updatedItem
        }
    }

    // Removes itinerary items at the selected list positions.
    func deleteItem(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            itineraryItems.remove(at: index)
        }
    }

    var activityCount: Int {
        itineraryItems.count
    }
}
