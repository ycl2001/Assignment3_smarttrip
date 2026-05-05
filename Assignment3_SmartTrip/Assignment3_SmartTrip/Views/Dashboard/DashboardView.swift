//
//  DashboardView.swift
//  Assignment3_SmartTrip
//
//  Created by Ziying Zhao on 30/4/2026.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: TripViewModel
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddMember = false
    @State private var newMemberName    = ""

    private var trip: Trip? { viewModel.currentTrip }

    private var tripBinding: Binding<Trip> {
        Binding(
            get: { viewModel.currentTrip ?? Trip(name: "", destination: "", startDate: .now, endDate: .now, members: [], itineraryItems: []) },
            set: { viewModel.currentTrip = $0 }
        )
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        NavigationStack {
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
            .navigationBarHidden(true)
            // Sync trip members into ExpenseViewModel whenever they change
            .onAppear {
                expenseViewModel.members = trip?.members ?? []
            }
            .onChange(of: viewModel.currentTrip?.members) { _, updated in
                expenseViewModel.members = updated ?? []
            }
            .sheet(isPresented: $showingAddMember) {
                addMemberSheet
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.black)
                }
                Spacer()
                Button { showingAddMember = true } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color(.darkGray), in: RoundedRectangle(cornerRadius: 10))
                }
            }

            Text(trip?.destination ?? "Your Trip")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            if let trip {
                HStack(alignment: .center) {
                    Text("\(dateFormatter.string(from: trip.startDate)) – \(dateFormatter.string(from: trip.endDate))")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                    Spacer()
                    // Show member count badge
                    if !trip.members.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                            Text("\(trip.members.count)")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Feature Grid

    private var featureGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
            spacing: 16
        ) {
            NavigationLink {
                Text("Flight Page Coming Soon")
            } label: {
                FeatureCard(icon: "airplane.departure", title: "Flight", subtitle: "Not added yet")
            }

            NavigationLink {
                Text("Locations Page Coming Soon")
            } label: {
                FeatureCard(icon: "scope", title: "Locations", subtitle: "0 locations added")
            }

            NavigationLink {
                ItineraryView(trip: tripBinding)
            } label: {
                FeatureCard(
                    icon: "point.topleft.down.to.point.bottomright.curvepath",
                    title: "Itinerary",
                    subtitle: "\(trip?.numberOfDays ?? 0) days · \(trip?.activityCount ?? 0) activities"
                )
            }

            NavigationLink {
                ExpenseView(viewModel: expenseViewModel)
            } label: {
                FeatureCard(
                    icon: "cylinder.split.1x2",
                    title: "Expenses",
                    subtitle: expenseViewModel.expenses.isEmpty
                        ? "No expenses yet"
                        : "Total: AUD \(String(format: "%.2f", expenseViewModel.totalSpending))"
                )
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Add Member Sheet

    private var addMemberSheet: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Sarah", text: $newMemberName)
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
                        let name = newMemberName.trimmingCharacters(in: .whitespaces)
                        guard !name.isEmpty else { return }
                        viewModel.currentTrip?.members.append(
                            TripMember(name: name, role: "Member")
                        )
                        newMemberName = ""
                        showingAddMember = false
                    }
                    .disabled(newMemberName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - FeatureCard

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.black)
                .padding(.top, 7)

            Spacer().frame(height: 6)

            Text(title)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color.black)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    let vm = TripViewModel()
    vm.currentTrip = Trip(
        name: "Summer Trip",
        destination: "Tokyo, Japan",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        members: [
            TripMember(name: "Jimmy", role: "Host"),
            TripMember(name: "Leo",   role: "Member")
        ],
        itineraryItems: []
    )
    return DashboardView(viewModel: vm, expenseViewModel: ExpenseViewModel())
}
