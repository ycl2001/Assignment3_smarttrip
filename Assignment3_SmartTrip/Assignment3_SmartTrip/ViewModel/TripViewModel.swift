//
//  TripViewModel.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Manages the currently active trip and archived trips to prevent overwriting log.
// This separates trip state management from the UI layer.
import Foundation
import Combine

class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var selectedTripId: UUID?

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    // All trips that are today or in the future.
    // Example: Tokyo May 10–13 and Fiji May 13–18 both show as active on May 10.
    var activeTrips: [Trip] {
        trips
            .filter {
                Calendar.current.startOfDay(for: $0.endDate) >= today
            }
            .sorted {
                $0.startDate < $1.startDate
            }
    }

    // The first active trip, used as fallback if no selected trip exists.
    var currentTrip: Trip? {
        activeTrips.first
    }

    // The trip currently opened in Dashboard.
    var selectedTrip: Trip? {
        guard let selectedTripId else {
            return currentTrip
        }

        return trips.first { $0.id == selectedTripId } ?? currentTrip
    }

    // Trips that ended before today.
    var pastTrips: [Trip] {
        trips
            .filter {
                Calendar.current.startOfDay(for: $0.endDate) < today
            }
            .sorted {
                $0.endDate > $1.endDate
            }
    }

    var hasTrip: Bool {
        !activeTrips.isEmpty
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
    
    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }

        if selectedTripId == trip.id {
            selectedTripId = currentTrip?.id
        }
    }

    func updateTrip(_ updatedTrip: Trip) {
        guard let index = trips.firstIndex(where: {
            $0.id == updatedTrip.id
        }) else { return }

        trips[index] = updatedTrip
    }
}
