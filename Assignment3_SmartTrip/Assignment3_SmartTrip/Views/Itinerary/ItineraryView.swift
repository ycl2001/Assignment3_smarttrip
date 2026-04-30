//
//  ItineraryView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import SwiftUI

struct ItineraryView: View {
    @Binding var trip: Trip

    @State private var showAddPlace = false
    @State private var selectedItem: ItineraryItem?

    var body: some View {
        List {
            if trip.itineraryItems.isEmpty {
                ContentUnavailableView(
                    "No places yet",
                    systemImage: "map",
                    description: Text("Add your first itinerary place to start planning.")
                )
            } else {
                ForEach(trip.itineraryItems) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.headline)

                            Text(item.location)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(item.category.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteItem)
            }
        }
        .navigationTitle("Itinerary")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddPlace = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddPlace) {
            AddEditItineraryItemView(itemToEdit: nil) { newItem in
                trip.itineraryItems.append(newItem)
            }
        }
        .sheet(item: $selectedItem) { item in
            AddEditItineraryItemView(itemToEdit: item) { updatedItem in
                if let index = trip.itineraryItems.firstIndex(where: { $0.id == item.id }) {
                    trip.itineraryItems[index] = updatedItem
                }
            }
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        trip.itineraryItems.remove(atOffsets: offsets)
    }
}

#Preview {
    NavigationStack {
        ItineraryView(trip: .constant(TripSampleData.sampleTrip))
    }
}
