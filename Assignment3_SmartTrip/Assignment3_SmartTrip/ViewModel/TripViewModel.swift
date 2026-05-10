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
    @Published var trips: [Trip] = []
    @Published var selectedTripId: UUID?

    var currentTrip: Trip? {
        trips
            .filter { $0.endDate >= Date() }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    var selectedTrip: Trip? {
        guard let selectedTripId else { return currentTrip }
        return trips.first { $0.id == selectedTripId }
    }

    var pastTrips: [Trip] {
        trips
            .filter { $0.endDate < Date() }
            .sorted { $0.endDate > $1.endDate }
    }

    var hasTrip: Bool {
        currentTrip != nil
    }

    func createTrip(_ trip: Trip) {
        trips.append(trip)
        selectedTripId = trip.id
    }

    func selectTrip(_ trip: Trip) {
        selectedTripId = trip.id
    }

    func clearTrips() {
        trips.removeAll()
        selectedTripId = nil
    }
}
