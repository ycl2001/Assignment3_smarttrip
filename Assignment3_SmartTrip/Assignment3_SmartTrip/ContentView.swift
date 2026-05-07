//
//  ContentView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tripViewModel    = TripViewModel()
    @StateObject private var expenseViewModel = ExpenseViewModel()

    var body: some View {
        CreateTripView { trip in
            tripViewModel.createTrip(trip)
        }
        // When a trip exists, slide DashboardView up full-screen.
        // Dismissing DashboardView clears the trip and returns here.
        .fullScreenCover(
            isPresented: Binding(
                get: { tripViewModel.hasTrip },
                set: { if !$0 { tripViewModel.clearTrip() } }
            )
        ) {
            DashboardView(viewModel: tripViewModel, expenseViewModel: expenseViewModel)
        }
    }
}

#Preview {
    ContentView()
}
