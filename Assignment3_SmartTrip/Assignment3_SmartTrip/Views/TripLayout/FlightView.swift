//
//  FlightView.swift
//  Assignment3_SmartTrip
//

import SwiftUI

struct FlightView: View {
    @Binding var trip: Trip

    @State private var localFlights: [Flight] = []
    @State private var showingAddFlight = false
    @State private var flightToEdit: Flight?

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM · HH:mm"
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Manage your flights for this trip")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)

                if localFlights.isEmpty {
                    emptyCard
                } else {
                    ForEach(localFlights) { flight in
                        flightCard(flight)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Flight")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddFlight = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear  { localFlights = trip.flights }
        .onDisappear { trip.flights = localFlights }
        .sheet(isPresented: $showingAddFlight) {
            AddFlightView(flightToEdit: nil) { newFlight in
                localFlights.append(newFlight)
            }
        }
        .sheet(item: $flightToEdit) { flight in
            AddFlightView(flightToEdit: flight) { updated in
                if let i = localFlights.firstIndex(where: { $0.id == flight.id }) {
                    localFlights[i] = updated
                }
            }
        }
    }

    // MARK: - Empty state

    private var emptyCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No flights yet")
                .font(.headline)
            Text("Tap + to add your first flight")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }

    // MARK: - Flight card

    private func flightCard(_ flight: Flight) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            // Airline + flight number + seat class badge
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.airline)
                        .font(.headline)
                    Text(flight.flightNumber)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(flight.seatClass.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.02, green: 0.22, blue: 0.15).opacity(0.12))
                    .foregroundStyle(Color(red: 0.02, green: 0.22, blue: 0.15))
                    .clipShape(Capsule())
            }

            Divider()

            // Route row
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.departureAirport)
                        .font(.title2.bold())
                    Text(timeFormatter.string(from: flight.departureTime))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color(.systemGray4))
                        .frame(maxWidth: 60)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.arrivalAirport)
                        .font(.title2.bold())
                    Text(timeFormatter.string(from: flight.arrivalTime))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Confirmation code (if present)
            if !flight.confirmationCode.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "ticket.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Booking: \(flight.confirmationCode)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Notes (if present)
            if !flight.notes.isEmpty {
                Text(flight.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Edit button
            Button {
                flightToEdit = flight
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit flight")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.02, green: 0.22, blue: 0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var trip = DemoCardData.trip
    NavigationStack {
        FlightView(trip: $trip)
    }
}
