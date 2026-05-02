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
                    weatherCardPlaceholder
                    featureGrid
                }
                .padding(.top, 7)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                expenseViewModel.members = trip?.members ?? []
            }
            .onChange(of: viewModel.currentTrip?.members) { _, updated in
                expenseViewModel.members = updated ?? []
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.black)
                }
                Spacer()
                Button { } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color(.darkGray), in: RoundedRectangle(cornerRadius: 10))
                }
            }

            HStack(alignment: .center) {
                Text(trip?.destination ?? "Your Trip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
            }

            if let trip {
                HStack(alignment: .center) {
                    Text("\(dateFormatter.string(from: trip.startDate)) – \(dateFormatter.string(from: trip.endDate))")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(.systemGray2))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // TODO: Replace with WeatherCardView() once teammate completes it
    private var weatherCardPlaceholder: some View {
        ZStack(alignment: .leading) {
            HStack {
                Spacer()
                Circle()
                    .fill(Color(red: 0.95, green: 0.65, blue: 0.35).opacity(0.95))
                    .frame(width: 130, height: 130)
                    .offset(x: 40, y: 40)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("During your trip, the average temperature is")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(1.0))

                Text("-- °C – -- °C")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Spacer()

                HStack(spacing: 0) {
                    Text("in ")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Text(trip?.destination ?? "City")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 30)
            .padding(.vertical, 29)
        }
        .frame(height: 140)
        .background(
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.45, blue: 0.75), Color(red: 0.30, green: 0.58, blue: 0.88)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

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
                FeatureCard(icon: "cylinder.split.1x2", title: "Expense", subtitle: expenseViewModel.expenses.isEmpty ? "Not setup yet" : "Total: $\(String(format: "%.2f", expenseViewModel.totalSpending))")
            }
        }
        .padding(.horizontal, 16)
    }
}

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

            Spacer()
                .frame(height: 6)

            Text(title)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color.black)

            Text(subtitle)
                .font(.system(size: 16))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius:16)
                .stroke(Color(.systemGray4), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let vm = TripViewModel()
    vm.currentTrip = Trip(
        name: "Summer Trip",
        destination: "Tokyo, Japan",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        members: [],
        itineraryItems: []
    )
    return DashboardView(viewModel: vm, expenseViewModel: ExpenseViewModel())
}
