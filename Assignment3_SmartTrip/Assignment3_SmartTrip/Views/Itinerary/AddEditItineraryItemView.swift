//
//  AddEditItineraryItemView.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//
import SwiftUI

struct AddEditItineraryItemView: View {
    @Environment(\.dismiss) private var dismiss

    let itemToEdit: ItineraryItem?
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

    private func savePlace() {
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
