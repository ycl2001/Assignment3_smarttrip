//
//  DashboardView.swift
//  Assignment3_SmartTrip
//

//  Created by Ziying Zhao on 30/4/2026.

import SwiftUI

struct DashboardView: View {

    @ObservedObject var viewModel: TripViewModel
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddMember = false
    @State private var newMemberName = ""

    private var trip: Trip? {
        viewModel.selectedTrip
    }

    private var tripBinding: Binding<Trip> {
        Binding(
            get: {
                viewModel.selectedTrip ?? Trip(
                    name: "",
                    destination: "",
                    startDate: .now,
                    endDate: .now,
                    members: [],
                    itineraryItems: []
                )
            },
            set: { updatedTrip in
                viewModel.updateTrip(updatedTrip)
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                headerSection

                WeatherCardView(location: trip?.destination ?? "")
                    .padding(.horizontal, 16)

                featureGrid
            }
            .padding(.top, 7)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddMember = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .foregroundStyle(.black)
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            addMemberSheet
        }
        .onAppear {
            if let trip {
                expenseViewModel.members = trip.members
                expenseViewModel.currentTripName = trip.name
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(trip?.destination ?? "Trip")
                        .font(.system(size: 28, weight: .bold))

                    Text(dateRangeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                    Text("\(trip?.members.count ?? 0)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
    }

    private var dateRangeText: String {
        guard let trip else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"

        return "\(formatter.string(from: trip.startDate)) – \(formatter.string(from: trip.endDate))"
    }

    // MARK: - Feature Grid

    private var featureGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 14
        ) {
            FeatureCard(
                icon: "airplane",
                title: "Flight",
                subtitle: "Not added yet"
            )

            NavigationLink {
                LocationView(trip: tripBinding)
            } label: {
                FeatureCard(
                    icon: "location",
                    title: "Locations",
                    subtitle: "Suggested places"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ItineraryView(trip: tripBinding)
            } label: {
                FeatureCard(
                    icon: "point.topleft.down.curvedto.point.bottomright.up",
                    title: "Itinerary",
                    subtitle: "\(trip?.numberOfDays ?? 0) days · \(trip?.activityCount ?? 0) activities"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ExpenseView(viewModel: expenseViewModel)
            } label: {
                FeatureCard(
                    icon: "cylinder.split.1x2",
                    title: "Expense",
                    subtitle: expenseViewModel.expenses.isEmpty
                    ? "Not set up yet"
                    : "Total: AUD \(String(format: "%.2f", expenseViewModel.totalSpending))"
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Add Member Sheet

    private var addMemberSheet: some View {
        NavigationStack {
            Form {
                Section("Name of Participants") {
                    TextField(
                        "e.g. Sarah, Leo, Zoe",
                        text: $newMemberName
                    )
                }

                if let members = trip?.members, !members.isEmpty {
                    Section("Current Members") {
                        ForEach(members) { member in
                            HStack {
                                Text(member.name)

                                Spacer()

                                Text(member.role)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newMemberName = ""
                        showingAddMember = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMembers()
                    }
                    .disabled(
                        newMemberName
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    )
                }
            }
        }
    }

    private func addMembers() {
        let names = newMemberName
            .split(separator: ",")
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter {
                !$0.isEmpty
            }

        guard !names.isEmpty else { return }

        if let selectedTrip = viewModel.selectedTrip,
           let index = viewModel.trips.firstIndex(where: { $0.id == selectedTrip.id }) {

            for name in names {
                viewModel.trips[index].members.append(
                    TripMember(name: name, role: "Member")
                )
            }

            expenseViewModel.members = viewModel.trips[index].members
        }

        newMemberName = ""
        showingAddMember = false
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.black)

            Text(title)
                .font(.headline)
                .foregroundStyle(.black)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    let tripVM = TripViewModel()
    let expenseVM = ExpenseViewModel()

    tripVM.createTrip(DemoCardData.trip)
    tripVM.selectTrip(DemoCardData.trip)

    expenseVM.members = DemoCardData.members
    expenseVM.currentTripName = DemoCardData.trip.name

    return NavigationStack {
        DashboardView(
            viewModel: tripVM,
            expenseViewModel: expenseVM
        )
    }
}
