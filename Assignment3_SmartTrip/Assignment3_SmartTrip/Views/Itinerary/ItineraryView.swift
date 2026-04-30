//
//  ItineraryView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Displays all itinerary items for the current trip.
// Users can add, edit, and delete itinerary places from this screen.

import SwiftUI

struct ItineraryView: View {
    // Binding allows this view to directly update the selected trip's itinerary items.
    @Binding var trip: Trip

    @State private var showAddPlace = false
    @State private var selectedItem: ItineraryItem?

    var body: some View {
        List {
            // Shows a friendly empty state when no itinerary items have been added yet.
            if trip.itineraryItems.isEmpty {
                ContentUnavailableView(
                    "No places yet",
                    systemImage: "map",
                    description: Text("Add your first itinerary place to start planning.")
                )
            } else {
                // Displays each itinerary item as a tappable row for editing.
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
        // Opens the Add Place form and appends the saved item to the trip itinerary.
        .sheet(isPresented: $showAddPlace) {
            AddEditItineraryItemView(itemToEdit: nil) { newItem in
                trip.itineraryItems.append(newItem)
            }
        }
        // Opens the same form in Edit mode and replaces the selected itinerary item.
        .sheet(item: $selectedItem) { item in
            AddEditItineraryItemView(itemToEdit: item) { updatedItem in
                if let index = trip.itineraryItems.firstIndex(where: { $0.id == item.id }) {
                    trip.itineraryItems[index] = updatedItem
                }
            }
        }
    }

    // Deletes itinerary items from the trip based on the selected list row.
    private func deleteItem(at offsets: IndexSet) {
        trip.itineraryItems.remove(atOffsets: offsets)
    }
}

#Preview {
    NavigationStack {
        ItineraryView(trip: .constant(TripSampleData.sampleTrip))
    }
}
