//
//  HomePageView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 8/5/2026.
//

import SwiftUI

struct HomePageView: View {

    @StateObject private var tripViewModel = TripViewModel()
    @StateObject private var itineraryViewModel = ItineraryViewModel()
    @StateObject private var expenseViewModel = ExpenseViewModel()

    @State private var showCreateTrip = false
    @State private var showDashboard = false

    // Used to open EditTripView
    @State private var editingTrip: Trip?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    headerSection

                    if tripViewModel.hasTrip {
                        activeTripsSection
                    } else {
                        emptyTripCard
                    }

                    bottomNavigation
                        .padding(.top, 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }

            // Navigate to create trip page
            .navigationDestination(isPresented: $showCreateTrip) {
                CreateTripView { newTrip in
                    tripViewModel.createTrip(newTrip)
                    tripViewModel.selectTrip(newTrip)

                    expenseViewModel.currentTripName = newTrip.name
                    expenseViewModel.members = newTrip.members

                    let today = Calendar.current.startOfDay(for: Date())
                    let tripEndDate = Calendar.current.startOfDay(for: newTrip.endDate)

                    if tripEndDate >= today {
                        showDashboard = true
                    } else {
                        showCreateTrip = false
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

            // Edit selected trip page
            .sheet(item: $editingTrip) { trip in
                EditTripView(
                    trip: trip,
                    onSave: { updatedTrip in
                        tripViewModel.updateTrip(updatedTrip)
                        editingTrip = nil
                    },
                    onDelete: {
                        tripViewModel.deleteTrip(trip)
                        editingTrip = nil
                    }
                )
            }
        }
    }

    // MARK: - Demo Data Loader

    private func loadDemoCardData() {
        if tripViewModel.trips.isEmpty {
            tripViewModel.createTrip(DemoCardData.trip)
        }

        if let selectedTrip = tripViewModel.selectedTrip {
            expenseViewModel.members = selectedTrip.members
            expenseViewModel.currentTripName = selectedTrip.name
        } else {
            expenseViewModel.members = DemoCardData.members
            expenseViewModel.currentTripName = DemoCardData.trip.name
        }

        if expenseViewModel.expenses.isEmpty {
            expenseViewModel.currentTripName = DemoCardData.trip.name

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
                    .foregroundStyle(Color(red: 0.02, green: 0.30, blue: 0.22))

                Spacer()

                Button {
                    // Notification placeholder
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                }

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
                    .font(.system(size: 36, weight: .medium))

                Text("You have \(tripViewModel.activeTrips.count) upcoming trips")
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
                .font(.system(size: 32, weight: .medium))
                .multilineTextAlignment(.center)

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

            Spacer()
        }
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity, minHeight: 460)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    // MARK: - Active Trips Section

    private var activeTripsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                ForEach(tripViewModel.activeTrips) { trip in
                    activeTripCard(trip)
                }
            }
        }
    }

    // MARK: - Active Trip Card

    private func activeTripCard(_ trip: Trip) -> some View {
        Button {
            tripViewModel.selectTrip(trip)
            expenseViewModel.currentTripName = trip.name
            expenseViewModel.members = trip.members
            showDashboard = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.35, blue: 0.28),
                                    Color(red: 0.98, green: 0.55, blue: 0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)

                    VStack {
                        HStack {
                            Spacer()

                            Menu {
                                Button {
                                    editingTrip = trip
                                } label: {
                                    Label("Edit Trip", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    tripViewModel.deleteTrip(trip)
                                } label: {
                                    Label("Delete Trip", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.black.opacity(0.25))
                                    .clipShape(Circle())
                            }
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 6) {
                            Text(trip.name)
                                .font(.title.bold())
                                .foregroundStyle(.white)

                            Text(trip.destination)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))

                            Text("\(formattedDate(trip.startDate)) - \(formattedDate(trip.endDate)) · \(trip.activityCount) activities")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                }

                HStack {
                    Label("\(trip.members.count) members", systemImage: "person.2.fill")

                    Spacer()

                    Label("Open trip", systemImage: "arrow.right.circle.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Date Formatter

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
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
                    BudgetListView(viewModel: expenseViewModel)
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
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

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

    // MARK: - Bottom Item

    private func bottomItem(icon: String, title: String) -> some View {
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
