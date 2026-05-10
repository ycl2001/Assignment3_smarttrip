//
//  EditTripView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 10/5/2026.
//

import SwiftUI

struct EditTripView: View {

    @Environment(\.dismiss) private var dismiss

    let originalTrip: Trip
    let onSave: (Trip) -> Void
    let onDelete: () -> Void

    @State private var tripName: String
    @State private var destination: String
    @State private var startDate: Date
    @State private var endDate: Date

    init(
        trip: Trip,
        onSave: @escaping (Trip) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.originalTrip = trip
        self.onSave = onSave
        self.onDelete = onDelete

        _tripName = State(initialValue: trip.name)
        _destination = State(initialValue: trip.destination)
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
    }

    var body: some View {

        NavigationStack {

            Form {

                Section("Trip Details") {

                    TextField(
                        "Trip name",
                        text: $tripName
                    )

                    TextField(
                        "Destination",
                        text: $destination
                    )
                }

                Section("Travel Dates") {

                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: .date
                    )
                }

                Section {

                    Button(role: .destructive) {

                        onDelete()
                        dismiss()

                    } label: {

                        Text("Delete Trip")
                    }
                }
            }
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {

                    Button("Save") {

                        let updatedTrip = Trip(
                            id: originalTrip.id,
                            name: tripName,
                            destination: destination,
                            startDate: startDate,
                            endDate: endDate,
                            members: originalTrip.members,
                            itineraryItems: originalTrip.itineraryItems
                        )

                        onSave(updatedTrip)
                        dismiss()
                    }
                }
            }
        }
    }
}
