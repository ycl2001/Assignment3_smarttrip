//
//  GroupView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import SwiftUI

struct GroupView: View {

    // Placeholder travel groups
    let groups: [(title: String, members: [String])] = [

        (
            title: "Sydney Food Trip",
            members: [
                "Jimmy",
                "Selina",
                "Chloe"
            ]
        ),

        (
            title: "Bali Friends Trip",
            members: [
                "Jimmy",
                "Zoe",
                "Mia",
                "Lucas"
            ]
        ),

        (
            title: "South Korea Family Trip",
            members: [
                "Jimmy",
                "Sophia",
                "Rachel",
                "Dylan",
                "Mia",
                "Asher",
                "Jake"
            ]
        )
    ]

    var body: some View {

        ScrollView {

            VStack(spacing: 18) {

                ForEach(groups, id: \.title) { group in

                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        // Group title
                        Text(group.title)
                            .font(.headline)

                        // Member grid
                        LazyVGrid(
                            columns: [
                                GridItem(
                                    .adaptive(minimum: 58),
                                    spacing: 12
                                )
                            ],
                            alignment: .leading,
                            spacing: 12
                        ) {

                            ForEach(group.members, id: \.self) { member in

                                VStack(spacing: 6) {

                                    // Avatar circle
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors:
                                                    member == "Jimmy"
                                                    ? [
                                                        Color.green,
                                                        Color.teal
                                                    ]
                                                    : [
                                                        Color.orange,
                                                        Color.yellow
                                                    ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text(
                                                member == "Jimmy"
                                                ? "Y"
                                                : String(member.prefix(1))
                                            )
                                            .foregroundStyle(.white)
                                            .font(.headline)
                                        )

                                    // Member name
                                    Text(
                                        member == "Jimmy"
                                        ? "You"
                                        : member
                                    )
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .foregroundStyle(.black)
                                }
                            }
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding()
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 5,
                        x: 0,
                        y: 4
                    )
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
