//
//  BudgetListView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 9/5/2026.
//

import SwiftUI

struct BudgetListView: View {

    @ObservedObject var viewModel: ExpenseViewModel

    @State private var expenseToEdit: Expense? = nil

    private var totalBudget: Double {
        viewModel.expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                budgetSummaryCard

                if viewModel.expenses.isEmpty {
                    emptyBudgetCard
                } else {
                    ForEach(viewModel.expenses) { expense in
                        Button {
                            // Restore the correct members for this expense's trip
                            // so AddExpenseView shows the right people
                            let tripName = viewModel.tripName(for: expense)
                            if let savedMembers = viewModel.tripMembersMap[tripName] {
                                viewModel.currentTripName = tripName
                                viewModel.members = savedMembers
                            }
                            expenseToEdit = expense
                        } label: {
                            expenseCard(expense)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Budget")
        // Opens AddExpenseView directly — Cancel returns straight to this screen (no P2)
        .sheet(item: $expenseToEdit) { expense in
            AddExpenseView(viewModel: viewModel, editingExpense: expense)
        }
    }

    private var budgetSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Expenses")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))

            Text("AUD \(totalBudget, specifier: "%.2f")")
                .font(.system(size: 34, weight: .bold))

            Text("In total this year")
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var emptyBudgetCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text("No budget yet")
                .font(.headline)

            Text("Load demo data or add expenses to see your budget list.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
    }

    private func expenseCard(_ expense: Expense) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.title)
                        .font(.headline)
                        .foregroundStyle(.black)

                    Text(expense.category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("AUD \(expense.amount, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
            }

            Divider()

            HStack {
                Label("Shared Expense", systemImage: "person.fill")

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
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        BudgetListView(viewModel: ExpenseViewModel())
    }
}
