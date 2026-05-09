//
//  PastTripsView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import SwiftUI

struct PastTripsView: View {
    var body: some View {
        ContentUnavailableView(
            "No Past Trips",
            systemImage: "clock.arrow.circlepath",
            description: Text("Completed trips will appear here.")
        )
        .navigationTitle("Past Trips")
    }
}
