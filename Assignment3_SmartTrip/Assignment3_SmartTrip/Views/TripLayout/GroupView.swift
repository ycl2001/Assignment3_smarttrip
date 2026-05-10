//
//  GroupView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import SwiftUI

struct GroupView: View {

    // Uses shared demo group trips from DemoCardData.
    private let groups = DemoCardData.groupTrips

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(groups) { group in
                    VStack(alignment: .leading, spacing: 14) {

                        Text(group.title)
                            .font(.headline)
                            .foregroundStyle(.black)

                        Text(group.destination)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 58), spacing: 12)
                            ],
                            alignment: .leading,
                            spacing: 12
                        ) {
                            ForEach(group.members, id: \.self) { member in
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: member == "Jimmy"
                                                ? [Color.green, Color.teal]
                                                : [Color.orange, Color.yellow],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text(member == "Jimmy" ? "Y" : String(member.prefix(1)))
                                                .foregroundStyle(.white)
                                                .font(.headline)
                                        )

                                    Text(member == "Jimmy" ? "You" : member)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .foregroundStyle(.black)
                                }
                            }
                        }

                        Divider()

                        HStack {
                            Label(group.dateRange, systemImage: "calendar")
                            Spacer()
                            Text("AUD \(group.totalBudget, specifier: "%.0f")")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Groups")
    }
}

#Preview {
    NavigationStack {
        GroupView()
    }
}
