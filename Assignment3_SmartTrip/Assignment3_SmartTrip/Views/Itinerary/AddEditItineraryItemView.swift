//
//  AddEditItineraryItemView.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Reusable screen for both adding and editing itinerary places.
// If itemToEdit is nil, the screen works as Add Place.
// If itemToEdit has a value, the screen works as Edit Place.
import SwiftUI

struct AddEditItineraryItemView: View {
    @Environment(\.dismiss) private var dismiss

    // Optional existing item. Nil means the user is creating a new itinerary item.
    let itemToEdit: ItineraryItem?
    
    // Sends the new or updated itinerary item back to the itinerary list.
    var onSave: (ItineraryItem) -> Void

    @State private var placeName = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var category = "Attraction"
    @State private var notes = ""

    let categories = ["Attraction", "Food", "Shopping", "Transport", "Hotel", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Place Details") {
                    TextField("Place name", text: $placeName)
                    TextField("Location", text: $location)
                }

                Section("Schedule") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            Text(item)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle(itemToEdit == nil ? "Add Place" : "Edit Place")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlace()
                        dismiss()
                    }
                }
            }
            // Pre-fills the form when editing an existing itinerary item.
            .onAppear {
                if let item = itemToEdit {
                    placeName = item.title
                    location = item.location
                    date = item.date
                    time = item.startTime
                    notes = item.notes
                    category = item.category.rawValue
                }
            }
        }
    }
    
    // Creates an ItineraryItem from the form input and sends it back using onSave.
    private func savePlace() {
        // Prevents empty place names or locations from being saved.
        guard !placeName.isEmpty, !location.isEmpty else {
            return
        }

        let newItem = ItineraryItem(
            title: placeName,
            location: location,
            date: date,
            startTime: time,
            notes: notes,
            category: ItineraryCategory(rawValue: category) ?? .other
        )

        onSave(newItem)
    }
}
