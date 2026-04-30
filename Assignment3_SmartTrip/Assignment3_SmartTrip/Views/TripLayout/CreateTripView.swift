//
//  CreateTripView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import SwiftUI

struct CreateTripView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var tripName = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var hostName = ""
    @State private var showError = false

    var onCreate: (Trip) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip name", text: $tripName)
                    TextField("Destination", text: $destination)
                }

                Section("Dates") {
                    DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End date", selection: $endDate, displayedComponents: .date)
                }

                Section("Host") {
                    TextField("Your name", text: $hostName)
                }
            }
            .navigationTitle("Create Trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTrip()
                    }
                }
            }
            .alert("Invalid Trip Details", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a trip name, destination, host name, and make sure the end date is not before the start date.")
            }
        }
    }

    private func createTrip() {
        let trimmedTripName = tripName.trimmingCharacters(in: .whitespaces)
        let trimmedDestination = destination.trimmingCharacters(in: .whitespaces)
        let trimmedHostName = hostName.trimmingCharacters(in: .whitespaces)

        guard !trimmedTripName.isEmpty,
              !trimmedDestination.isEmpty,
              !trimmedHostName.isEmpty,
              endDate >= startDate else {
            showError = true
            return
        }

        let newTrip = Trip(
            name: trimmedTripName,
            destination: trimmedDestination,
            startDate: startDate,
            endDate: endDate,
            members: [
                TripMember(name: trimmedHostName, role: "Host")
            ],
            itineraryItems: []
        )

        onCreate(newTrip)
        dismiss()
    }
}

#Preview {
    CreateTripView { trip in
        print(trip.name)
    }
}
