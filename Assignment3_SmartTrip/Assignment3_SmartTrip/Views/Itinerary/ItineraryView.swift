//
//  ItineraryView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import SwiftUI

struct ItineraryView: View {
    @Binding var trip: Trip

    // Local copy of items so mutations update the list immediately
    // without causing DashboardView to re-render (which resets the NavigationStack).
    // Synced back to trip.itineraryItems on disappear.
    @State private var localItems:   [ItineraryItem] = []
    @State private var showAddPlace  = false
    @State private var selectedItem: ItineraryItem?

    var body: some View {
        List {
            if localItems.isEmpty {
                ContentUnavailableView(
                    "No places yet",
                    systemImage: "map",
                    description: Text("Add your first itinerary place to start planning.")
                )
            } else {
                ForEach(localItems) { item in
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
                    .foregroundStyle(.primary)
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
        // Load from the trip binding once when the view appears
        .onAppear {
            localItems = trip.itineraryItems
        }
        // Write changes back to the binding only when leaving,
        // so DashboardView doesn't re-render while we're navigated here
        .onDisappear {
            trip.itineraryItems = localItems
        }
        .sheet(isPresented: $showAddPlace) {
            AddEditItineraryItemView(itemToEdit: nil) { newItem in
                localItems.append(newItem)
            }
        }
        .sheet(item: $selectedItem) { item in
            AddEditItineraryItemView(itemToEdit: item) { updatedItem in
                if let index = localItems.firstIndex(where: { $0.id == item.id }) {
                    localItems[index] = updatedItem
                }
            }
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        localItems.remove(atOffsets: offsets)
    }
}

#Preview {
    NavigationStack {
        ItineraryView(trip: .constant(TripSampleData.sampleTrip))
    }
}
