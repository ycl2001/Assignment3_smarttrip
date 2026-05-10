//
//  LocationView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 10/5/2026.
//

import SwiftUI

struct LocationView: View {

    @Binding var trip: Trip

    private var suggestedPlaces: [SuggestedPlace] {
        DemoLocationData.places(
            for: trip.destination,
            members: trip.members.map { $0.name }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if suggestedPlaces.isEmpty {
                    ContentUnavailableView(
                        "No Suggested Locations",
                        systemImage: "location.slash",
                        description: Text("Add trip members first to see their suggested places.")
                    )
                } else {
                    ForEach(suggestedPlaces) { place in
                        placeCard(place)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Locations")
    }

    private func placeCard(_ place: SuggestedPlace) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.headline)

                    Text(place.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(place.category.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
            }

            HStack(spacing: 6) {
                Image(systemName: "person.fill")
                Text("Suggested by \(place.suggestedBy)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(place.note)
                .font(.subheadline)
                .foregroundStyle(.black)

            Divider()

            Button {
                let item = ItineraryItem(
                    title: place.name,
                    location: place.location,
                    date: Date(),
                    startTime: Date(),
                    notes: "Suggested by \(place.suggestedBy): \(place.note)",
                    category: place.category
                )

                trip.itineraryItems.append(item)
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to itinerary")
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
    }
}

#Preview {
    @Previewable @State var trip = DemoCardData.trip

    NavigationStack {
        LocationView(trip: $trip)
    }
}
