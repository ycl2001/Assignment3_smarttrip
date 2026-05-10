//
//  PastTripsView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import SwiftUI

struct PastTripsView: View {

    @ObservedObject var viewModel: TripViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                ForEach(viewModel.pastTrips) { trip in
                    createdPastTripCard(trip)
                }

                ForEach(DemoCardData.groupTrips) { trip in
                    demoPastTripCard(trip)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Past Trips")
    }

    private func createdPastTripCard(_ trip: Trip) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.headline)
                        .foregroundStyle(.black)

                    Text(trip.destination)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Completed")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.12))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }

            Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) – \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Label("\(trip.members.count) members", systemImage: "person.2.fill")
                Spacer()
                Label("\(trip.activityCount) activities", systemImage: "map")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
    }

    private func demoPastTripCard(_ trip: DemoGroupTrip) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.title)
                        .font(.headline)
                        .foregroundStyle(.black)

                    Text(trip.destination)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(trip.status)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.12))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }

            Text(trip.dateRange)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Label("\(trip.members.count) members", systemImage: "person.2.fill")

                Spacer()

                Text("AUD \(trip.totalBudget, specifier: "%.2f")")
                    .fontWeight(.semibold)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        PastTripsView(viewModel: TripViewModel())
    }
}
