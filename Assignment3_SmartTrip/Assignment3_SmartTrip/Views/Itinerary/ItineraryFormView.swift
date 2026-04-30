//
//  ItineraryFormView.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import SwiftUI

struct ItineraryFormView: View {
    @Binding var title: String
    @Binding var location: String
    @Binding var date: Date
    @Binding var startTime: Date
    @Binding var notes: String
    @Binding var category: ItineraryCategory

    var body: some View {
        Form {
            Section("Place Details") {
                TextField("Place or activity name", text: $title)
                TextField("Location", text: $location)
            }

            Section("Schedule") {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
            }

            Section("Category") {
                Picker("Category", selection: $category) {
                    ForEach(ItineraryCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            }

            Section("Notes") {
                TextField("Optional notes", text: $notes, axis: .vertical)
                    .lineLimit(3...5)
            }
        }
    }
}
