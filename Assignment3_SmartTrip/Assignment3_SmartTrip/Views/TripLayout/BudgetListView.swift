//
//  BudgetListView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import SwiftUI

struct BudgetListView: View {

    // Shared expense data from homepage
    @ObservedObject var viewModel: ExpenseViewModel

    // Calculates total spending amount
    private var totalBudget: Double {
        viewModel.expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 18) {

                // MARK: - Budget Summary Card

                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {

                    Text("Current Expenses")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    Text(
                        "AUD \(totalBudget, specifier: "%.2f")"
                    )
                    .font(
                        .system(
                            size: 34,
                            weight: .bold
                        )
                    )

                    Text("In total this year")
                        .foregroundStyle(
                            .white.opacity(0.85)
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.85),
                            Color.orange.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )

                // MARK: - Expense Cards

                ForEach(viewModel.expenses) { expense in

                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        HStack {

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text(expense.title)
                                    .font(.headline)

                                Text(
                                    expense.category.rawValue
                                        .capitalized
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(
                                "AUD \(expense.amount, specifier: "%.2f")"
                            )
                            .fontWeight(.semibold)
                        }

                        Divider()

                        HStack {

                            Label(
                                "Shared Expense",
                                systemImage: "person.fill"
                            )

                            Spacer()

                            Label(
                                "\(expense.participantIds.count) members",
                                systemImage: "person.2.fill"
                            )
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
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
        .navigationTitle("Budget")
    }
}

#Preview {

    NavigationStack {

        BudgetListView(
            viewModel: ExpenseViewModel()
        )
    }
}
