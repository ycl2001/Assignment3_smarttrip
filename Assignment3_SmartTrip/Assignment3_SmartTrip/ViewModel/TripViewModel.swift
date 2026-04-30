//
//  TripViewModel.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Manages the currently active trip.
// This separates trip state management from the UI layer.
import Foundation
import Combine

class TripViewModel: ObservableObject {
    // Stores the trip currently being created or viewed in the app.
    @Published var currentTrip: Trip?

    // Saves a newly created trip as the current active trip.
    func createTrip(_ trip: Trip) {
        currentTrip = trip
    }

    // Clears the current trip, useful when returning to the start flow.
    func clearTrip() {
        currentTrip = nil
    }

    var hasTrip: Bool {
        currentTrip != nil
    }
}
