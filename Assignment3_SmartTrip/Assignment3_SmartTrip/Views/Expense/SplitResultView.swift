import SwiftUI

// MARK: - SplitResultView
struct SplitResultView: View {
    @ObservedObject var viewModel: ExpenseViewModel

    var body: some View {
        List {
            overviewSection
            balancesSection
            settlementsSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Split Result")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var overviewSection: some View {
        Section {
            LabeledContent("Total Spent") {
                Text(viewModel.totalSpending, format: .currency(code: "AUD"))
                    .bold()
            }
            LabeledContent("Expenses recorded") {
                Text("\(viewModel.expenses.count)")
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Members") {
                Text("\(viewModel.members.count)")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Trip Summary")
        }
    }

    private var balancesSection: some View {
        Section {
            if viewModel.members.isEmpty {
                Text("No members in this trip")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.members) { member in
                    MemberBalanceRow(
                        name:    member.name,
                        balance: viewModel.balance(for: member.id)
                    )
                }
            }
        } header: {
            Text("Balances")
        } footer: {
            Text("Green means they are owed money · Red means they owe money")
                .font(.caption2)
        }
    }

    @ViewBuilder
    private var settlementsSection: some View {
        let settlements = viewModel.settlements
        Section {
            if settlements.isEmpty {
                Label("Everyone is settled up!", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else {
                ForEach(settlements) { s in
                    SettlementRow(settlement: s, viewModel: viewModel)
                }
            }
        } header: {
            Text("How to Settle Up")
        } footer: {
            if !settlements.isEmpty {
                Text("These \(settlements.count) transaction(s) are the minimum needed to clear all debts.")
                    .font(.caption2)
            }
        }
    }
}

// MARK: - Sub-views

private struct MemberBalanceRow: View {
    let name:    String
    let balance: Double

    private var statusLabel: String {
        if abs(balance) < 0.01 { return "settled" }
        return balance > 0 ? "gets back" : "owes"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.body)
                Text(statusLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if abs(balance) < 0.01 {
                Text("Settled")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text(abs(balance), format: .currency(code: "AUD"))
                    .font(.body.bold())
                    .foregroundStyle(balance >= 0 ? Color.green : Color.red)
            }
        }
    }
}

private struct SettlementRow: View {
    let settlement: Settlement
    let viewModel:  ExpenseViewModel

    private var fromName: String {
        viewModel.member(for: settlement.fromMemberId)?.name ?? "Unknown"
    }
    private var toName: String {
        viewModel.member(for: settlement.toMemberId)?.name ?? "Unknown"
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(fromName)
                .fontWeight(.semibold)
                .foregroundStyle(.red)

            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(toName)
                .fontWeight(.semibold)
                .foregroundStyle(.green)

            Spacer()

            Text(settlement.amount, format: .currency(code: "AUD"))
                .bold()
        }
    }
}

// MARK: - Preview

#Preview {
    let vm: ExpenseViewModel = {
        let vm = ExpenseViewModel()
        vm.members = [
            TripMember(name: "Jimmy", role: "Host"),
            TripMember(name: "Leo", role: "Member"),
            TripMember(name: "Zoe", role: "Member"),
            TripMember(name: "Selina", role: "Member")
        ]

        let a = vm.members[0]
        let b = vm.members[1]
        let c = vm.members[2]
        let d = vm.members[3]

        vm.addExpense(Expense(
            title: "Dinner",
            amount: 90,
            payerId: a.id,
            participantIds: [a.id, b.id, c.id],
            category: .food
        ))

        vm.addExpense(Expense(
            title: "Taxi",
            amount: 30,
            payerId: d.id,
            participantIds: [c.id, d.id],
            category: .transport
        ))

        return vm
    }()

    SplitResultView(viewModel: vm)
}
