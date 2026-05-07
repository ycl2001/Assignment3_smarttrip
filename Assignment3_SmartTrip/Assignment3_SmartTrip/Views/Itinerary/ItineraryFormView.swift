//
//  ItineraryFormView.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Shared form layout for itinerary place details.
// This keeps Add and Edit screens consistent and avoids duplicated UI code.
import SwiftUI

// Bindings allow the parent Add/Edit view to control and receive form input.
struct ItineraryFormView: View {
    @Binding var title: String
    @Binding var location: String
    @Binding var date: Date
    @Binding var startTime: Date
    @Binding var notes: String
    @Binding var category: ItineraryCategory

    var body: some View {
        Form {
            
            // Basic place information entered by the user.
            Section("Place Details") {
                TextField("Place or activity name", text: $title)
                TextField("Location", text: $location)
            }
            
            // Allows users to select when the activity takes place.
            Section("Schedule") {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
            }

            // Category picker limits users to predefined itinerary categories.
            Section("Category") {
                Picker("Category", selection: $category) {
                    ForEach(ItineraryCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            }

            // Optional notes for additional details (e.g., reminders, booking info).
            Section("Notes") {
                TextField("Optional notes", text: $notes, axis: .vertical)
                    .lineLimit(3...5)
            }
        }
    }
}
