//
//  DashboardView.swift
//  Assignment3_SmartTrip
//

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
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.primary)
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
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip?.destination ?? "Your Trip")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    if let trip {
                        Text("\(dateFormatter.string(from: trip.startDate)) – \(dateFormatter.string(from: trip.endDate))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    )
                    .overlay(Circle().stroke(Color(.label), lineWidth: 2))
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
                    .fill(Color.orange.opacity(0.9))
                    .frame(width: 180, height: 180)
                    .offset(x: 70)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("During your trip, the average temperature is")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))

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
                        .foregroundStyle(.orange)
                }
            }
            .padding(20)
        }
        .frame(height: 140)
        .background(
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.3, blue: 0.85), Color(red: 0.25, green: 0.55, blue: 0.95)],
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

            FeatureCard(icon: "scope", title: "Locations", subtitle: "0 locations added")
                .opacity(0.5)

            NavigationLink {
                ItineraryView(trip: tripBinding)
            } label: {
                FeatureCard(
                    icon: "point.topleft.down.to.point.bottomright.curvepath",
                    title: "Itinerary",
                    subtitle: "\(trip?.numberOfDays ?? 0) days"
                )
            }

            NavigationLink {
                ExpenseView(viewModel: expenseViewModel)
            } label: {
                FeatureCard(icon: "cylinder.split.1x2", title: "Finance", subtitle: "Not setup yet")
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
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.primary)

            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let vm = TripViewModel()
    vm.currentTrip = Trip(
        name: "Summer Trip",
        destination: "Tokyo",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        members: [],
        itineraryItems: []
    )
    return DashboardView(viewModel: vm, expenseViewModel: ExpenseViewModel())
}
