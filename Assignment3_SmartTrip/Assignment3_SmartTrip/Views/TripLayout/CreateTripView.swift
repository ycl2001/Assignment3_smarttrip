//
//  CreateTripView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Screen for creating a new trip.
// The user enters basic trip details, and the view returns a Trip object through onCreate.
import SwiftUI

struct CreateTripView: View {
    @Environment(\.dismiss) private var dismiss

// Local form state used to temporarily store user input before creating a Trip.
    @State private var tripName = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var hostName = ""
    @State private var showError = false

// Closure used to pass the newly created Trip back to the parent view.
    var onCreate: (Trip) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Tell us about your trip")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)

                    tripDetailsCard
                    datesCard
                    hostCard
                    createButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Create Trip")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Invalid Trip Details", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a trip name, destination, host name, and make sure the end date is not before the start date.")
            }
        }
    }

    // Reusable card style to match the soft rounded layout.
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var tripDetailsCard: some View {
        card {
            Text("Where")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Shibuya, Japan", text: $destination)

            Divider()

            Text("Trip name")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Spring trip with friends", text: $tripName)
        }
    }

    private var datesCard: some View {
        card {
            Text("When")
                .font(.caption)
                .foregroundStyle(.secondary)

            DatePicker("Start date", selection: $startDate, displayedComponents: .date)

            DatePicker("End date", selection: $endDate, displayedComponents: .date)
        }
    }

    private var hostCard: some View {
        card {
            Text("Who")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Your name", text: $hostName)
        }
    }

    private var createButton: some View {
        Button {
            createTrip()
        } label: {
            Text("Confirm")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.02, green: 0.22, blue: 0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 8)
    }

// Validates required fields and creates a new Trip if the input is valid.
    private func createTrip() {
        let trimmedTripName = tripName.trimmingCharacters(in: .whitespaces)
        let trimmedDestination = destination.trimmingCharacters(in: .whitespaces)
        let trimmedHostName = hostName.trimmingCharacters(in: .whitespaces)

        // Prevents users from creating incomplete or invalid trips.
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
