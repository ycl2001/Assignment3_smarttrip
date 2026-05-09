//
//  BudgetListView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import SwiftUI

struct BudgetListView: View {
    var body: some View {
        ContentUnavailableView(
            "No Budget Yet",
            systemImage: "list.bullet.rectangle",
            description: Text("Create a trip and add expenses to view budgets.")
        )
        .navigationTitle("Budget")
    }
}
