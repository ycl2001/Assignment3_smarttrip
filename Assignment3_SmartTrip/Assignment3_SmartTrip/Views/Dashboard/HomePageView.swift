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

                    if tripViewModel.hasTrip {
                        upcomingTripCard
                    } else {
                        emptyTripCard
                    }

                    Spacer()

                    bottomNavigation
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }

            // Navigate to create trip page
            .navigationDestination(isPresented: $showCreateTrip) {

                CreateTripView { newTrip in

                    // Save newly created trip
                    tripViewModel.createTrip(newTrip)

                    // Select newly created trip for dashboard
                    tripViewModel.selectTrip(newTrip)

                    // Sync expense members
                    expenseViewModel.members = newTrip.members

                    // Close create page first
                    showCreateTrip = false

                    // Check if trip is already completed
                    let today = Calendar.current.startOfDay(for: Date())
                    let tripEndDate = Calendar.current.startOfDay(for: newTrip.endDate)

                    if tripEndDate >= today {

                        // Open dashboard for active/upcoming trips
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + 0.1
                        ) {

                            showDashboard = true
                        }

                    } else {

                        // Past trips only go to archive
                        showDashboard = false
                    }
                }
            }

            // Navigate to dashboard page
            .navigationDestination(isPresented: $showDashboard) {
                DashboardView(
                    viewModel: tripViewModel,
                    expenseViewModel: expenseViewModel
                )
            }
        }
    }

    // MARK: - Demo Data Loader

    private func loadDemoCardData() {

        // If no trip exists, load demo trip
        if tripViewModel.currentTrip == nil {

            tripViewModel.createTrip(DemoCardData.trip)
        }

        // Sync members into expense system
        if let currentTrip = tripViewModel.currentTrip {

            expenseViewModel.members = currentTrip.members

        } else {

            expenseViewModel.members = DemoCardData.members
        }

        // Prevent duplicate expense loading
        if expenseViewModel.expenses.isEmpty {

            for expense in DemoCardData.expenses {

                expenseViewModel.addExpense(expense)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 18) {

            HStack {

                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        Color(
                            red: 0.02,
                            green: 0.30,
                            blue: 0.22
                        )
                    )

                Spacer()

                Button {

                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                // Profile button loads demo data
                Button {
                    loadDemoCardData()

                } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .green.opacity(0.7),
                                    .orange.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {

                Text("Hello Jimmy!")
                    .font(
                        .system(
                            size: 36,
                            weight: .medium
                        )
                    )

                Text("You have \(tripViewModel.hasTrip ? 1 : 0) upcoming trips")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Empty State Card

    private var emptyTripCard: some View {
        VStack(spacing: 28) {

            Spacer()

            Image(systemName: "safari.fill")
                .font(.system(size: 110))
                .foregroundStyle(.orange)

            Text("Thinking of going\nsomewhere?")
                .font(
                    .system(
                        size: 32,
                        weight: .medium
                    )
                )
                .multilineTextAlignment(.center)

            Button {
                showCreateTrip = true

            } label: {
                Text("Start planning")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color(
                            red: 0.02,
                            green: 0.34,
                            blue: 0.25
                        )
                    )
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding(.vertical, 36)
        .frame(
            maxWidth: .infinity,
            minHeight: 460
        )
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .shadow(
            color: .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Upcoming Trip Card

    private var upcomingTripCard: some View {

        Button {

            // Select current upcoming trip
            if let trip = tripViewModel.currentTrip {

                tripViewModel.selectTrip(trip)
            }

            // Open dashboard
            showDashboard = true

        } label: {

            VStack(alignment: .leading, spacing: 14) {

                if let trip = tripViewModel.currentTrip {

                    ZStack(alignment: .bottomLeading) {

                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(
                                            red: 0.05,
                                            green: 0.35,
                                            blue: 0.28
                                        ),

                                        Color(
                                            red: 0.98,
                                            green: 0.55,
                                            blue: 0.15
                                        )
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 220)

                        VStack(alignment: .leading, spacing: 6) {

                            Text(trip.destination)
                                .font(.title.bold())
                                .foregroundStyle(.white)

                            Text(
                                "\(trip.numberOfDays) days · \(trip.activityCount) activities"
                            )
                            .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding()
                    }

                    HStack {

                        Label(
                            "\(trip.members.count) members",
                            systemImage: "person.2.fill"
                        )

                        Spacer()

                        Label(
                            "Open trip",
                            systemImage: "arrow.right.circle.fill"
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 24)
            )
            .shadow(
                color: .black.opacity(0.08),
                radius: 10,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Navigation

    private var bottomNavigation: some View {

        HStack(spacing: 18) {

            HStack(spacing: 28) {

                NavigationLink {
                    PastTripsView(viewModel: tripViewModel)

                } label: {
                    bottomItem(
                        icon: "clock.arrow.circlepath",
                        title: "Past Trips"
                    )
                }

                NavigationLink {
                    GroupView()

                } label: {
                    bottomItem(
                        icon: "person.2.fill",
                        title: "Group"
                    )
                }

                NavigationLink {
                    BudgetListView(
                        viewModel: expenseViewModel
                    )
                } label: {
                    bottomItem(
                        icon: "list.bullet.rectangle",
                        title: "Budget"
                    )
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.95))
            .clipShape(Capsule())
            .shadow(
                color: .black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 4
            )

            Button {
                showCreateTrip = true

            } label: {

                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(.black)
                    .frame(width: 62, height: 62)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Bottom Item

    private func bottomItem(
        icon: String,
        title: String
    ) -> some View {

        VStack(spacing: 4) {

            Image(systemName: icon)
                .font(.system(size: 18))

            Text(title)
                .font(.caption2)
        }
        .foregroundStyle(.black)
    }
}

// MARK: - Preview

#Preview {
    HomePageView()
}
