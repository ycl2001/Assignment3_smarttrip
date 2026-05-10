//
//  CreateTripView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import SwiftUI

// MARK: - Create Trip View
// This screen allows users to create a new trip by entering:
// 1. Destination
// 2. Trip name
// 3. Start and end dates

struct CreateTripView: View {

    // Dismiss current page and return to previous screen
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form States

    // Stores trip name input
    @State private var tripName = ""

    // Stores destination input
    @State private var destination = ""

    // Stores selected trip start date
    @State private var startDate = Date()

    // Stores selected trip end date
    @State private var endDate =
        Calendar.current.date(
            byAdding: .day,
            value: 3,
            to: Date()
        ) ?? Date()

    // Controls validation alert visibility
    @State private var showError = false

    // Sends created trip data back to homepage/dashboard
    var onCreate: (Trip) -> Void

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                // MARK: - Header Section

                Text("About your upcoming trip")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 8)

                // Trip information section
                tripDetailsCard

                // Date selection section
                datesCard

                // Confirm button
                createButton
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))

        // MARK: - Navigation Bar

        .navigationTitle("Create Trip")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Error Alert

        .alert(
            "Invalid Trip Details",
            isPresented: $showError
        ) {

            Button(
                "OK",
                role: .cancel
            ) {}

        } message: {

            Text(
                "Please enter a trip name, destination, and make sure the end date is not before the start date."
            )
        }
    }

    // MARK: - Reusable Card Component
    // Creates reusable white rounded cards for cleaner UI design

    private func card<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            content()
        }
        .padding()

        // White card background
        .background(Color.white)

        // Rounded corner styling
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )

        // Soft shadow effect
        .shadow(
            color: .black.opacity(0.06),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Trip Details Card
    // Handles destination and trip name input fields

    private var tripDetailsCard: some View {

        card {

            // Destination section
            Text("Where are we going?")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(
                "Insert the Place of Destination",
                text: $destination
            )

            Divider()

            // Trip name section
            Text("Trip name")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(
                "Insert Title of the Trip",
                text: $tripName
            )
        }
    }

    // MARK: - Date Selection Card
    // Allows users to choose travel dates

    private var datesCard: some View {

        card {

            Text("When")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Start date picker
            DatePicker(
                "Start date",
                selection: $startDate,
                displayedComponents: .date
            )

            // End date picker
            DatePicker(
                "End date",
                selection: $endDate,
                displayedComponents: .date
            )
        }
    }

    // MARK: - Confirm Button
    // Creates and validates trip data before proceeding

    private var createButton: some View {

        Button {

            createTrip()

        } label: {

            Text("Confirm")
                .fontWeight(.semibold)

                // Expand button width
                .frame(maxWidth: .infinity)

                .padding()

                // App theme button color
                .background(
                    Color(
                        red: 0.02,
                        green: 0.22,
                        blue: 0.15
                    )
                )

                .foregroundStyle(.white)

                // Capsule button shape
                .clipShape(Capsule())

                // Button shadow
                .shadow(
                    color: .black.opacity(0.25),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .padding(.top, 8)
    }

    // MARK: - Trip Creation Logic
    // Validates user input and creates a new trip object

    private func createTrip() {

        // Remove accidental spaces
        let trimmedTripName =
            tripName.trimmingCharacters(
                in: .whitespaces
            )

        let trimmedDestination =
            destination.trimmingCharacters(
                in: .whitespaces
            )

        // Validation rules
        guard
            !trimmedTripName.isEmpty,
            !trimmedDestination.isEmpty,
            endDate >= startDate
        else {

            // Show validation error alert
            showError = true
            return
        }

        // Create new trip model
        let newTrip = Trip(
            name: trimmedTripName,
            destination: trimmedDestination,
            startDate: startDate,
            endDate: endDate,

            // Current user automatically becomes trip host
            members: [
                TripMember(
                    name: "You",
                    role: "Host"
                )
            ],

            itineraryItems: []
        )

        // Send trip back to homepage/dashboard
        onCreate(newTrip)
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        CreateTripView { trip in
            print(trip.name)
        }
    }
}
