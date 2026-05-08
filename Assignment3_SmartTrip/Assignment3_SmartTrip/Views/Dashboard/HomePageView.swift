//
//  HomePageView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 8/5/2026.
//

import SwiftUI

struct HomePageView: View {
    @StateObject private var tripViewModel = TripViewModel()
    @StateObject private var expenseViewModel = ExpenseViewModel()

    @State private var showCreateTrip = false
    @State private var showDashboard = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    headerSection

                    emptyTripCard

                    Spacer()

                    bottomNavigation
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            .navigationDestination(isPresented: $showCreateTrip) {
                CreateTripView { newTrip in
                    tripViewModel.createTrip(newTrip)
                    expenseViewModel.members = newTrip.members
                    showDashboard = true
                }
            }
            .navigationDestination(isPresented: $showDashboard) {
                DashboardView(
                    viewModel: tripViewModel,
                    expenseViewModel: expenseViewModel
                )
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Color(red: 0.02, green: 0.30, blue: 0.22))

                Spacer()

                Button {} label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                        .frame(width: 52, height: 52)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                }

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.7), .orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Hello Jimmy!")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(.primary)

                Text("You have \(tripViewModel.hasTrip ? 1 : 0) upcoming trips")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyTripCard: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)

                VStack(spacing: 24) {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(Color(red: 0.95, green: 0.55, blue: 0.18))

                    Text("Thinking of going\nsomewhere?")
                        .font(.system(size: 32, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)

                    Button {
                        showCreateTrip = true
                    } label: {
                        Text("Start planning")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.02, green: 0.34, blue: 0.25))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.vertical, 48)
            }
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }

    private var bottomNavigation: some View {
        HStack(spacing: 18) {

            // Main navigation capsule
            HStack(spacing: 28) {

                // Past Trips
                VStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 20))

                    Text("Past Trips")
                        .font(.caption)
                }

                // Shared / Invited Trips
                VStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 20))

                    Text("Group")
                        .font(.caption)
                }

                // Budget List
                VStack(spacing: 4) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 20))

                    Text("Expense")
                        .font(.caption)
                }
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.95))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

            // Floating plus button
            Button {
                showCreateTrip = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(.black)
                    .frame(width: 62, height: 62)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    HomePageView()
}
