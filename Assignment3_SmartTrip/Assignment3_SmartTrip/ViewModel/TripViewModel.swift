//
//  TripViewModel.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import Foundation
import Combine

class TripViewModel: ObservableObject {
    @Published var currentTrip: Trip?

    func createTrip(_ trip: Trip) {
        currentTrip = trip
    }

    func clearTrip() {
        currentTrip = nil
    }

    var hasTrip: Bool {
        currentTrip != nil
    }
}
