import SwiftUI

struct SplitResultView: View {
    @ObservedObject var viewModel: ExpenseViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                overviewCard
                balancesCard
                settlementsCard
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Split Result")
        .navigationBarTitleDisplayMode(.large)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var overviewCard: some View {
        card {
            Text("Trip Summary")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text("Total Spent")
                Spacer()
                Text(viewModel.totalSpending, format: .currency(code: "AUD")).bold()
            }
            Divider()
            HStack {
                Text("Expenses recorded")
                Spacer()
                Text("\(viewModel.expenses.count)").foregroundStyle(.secondary)
            }
            Divider()
            HStack {
                Text("Members")
                Spacer()
                Text("\(viewModel.members.count)").foregroundStyle(.secondary)
            }
        }
    }

    private var balancesCard: some View {
        card {
            Text("Balances")
                .font(.caption)
                .foregroundStyle(.secondary)
            if viewModel.members.isEmpty {
                Text("No members in this trip")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.members) { member in
                    let balance = viewModel.balance(for: member.id)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name).font(.body)
                            Text(abs(balance) < 0.01 ? "settled" : balance > 0 ? "gets back" : "owes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if abs(balance) < 0.01 {
                            Text("Settled").font(.subheadline).foregroundStyle(.secondary)
                        } else {
                            Text(abs(balance), format: .currency(code: "AUD"))
                                .font(.body.bold())
                                .foregroundStyle(balance >= 0 ? Color.green : Color.red)
                        }
                    }
                    if member.id != viewModel.members.last?.id { Divider() }
                }
            }
            Text("Green = owed money · Red = owes money")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var settlementsCard: some View {
        let settlements = viewModel.settlements
        return card {
            Text("How to Settle Up")
                .font(.caption)
                .foregroundStyle(.secondary)
            if settlements.isEmpty {
                HStack {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                    Text("Everyone is settled up!")
                }
            } else {
                ForEach(settlements) { s in
                    let fromName = viewModel.member(for: s.fromMemberId)?.name ?? "Unknown"
                    let toName   = viewModel.member(for: s.toMemberId)?.name ?? "Unknown"
                    HStack(spacing: 6) {
                        Text(fromName).fontWeight(.semibold).foregroundStyle(.red)
                        Image(systemName: "arrow.right").font(.caption).foregroundStyle(.secondary)
                        Text(toName).fontWeight(.semibold).foregroundStyle(.green)
                        Spacer()
                        Text(s.amount, format: .currency(code: "AUD")).bold()
                    }
                    if s.id != settlements.last?.id { Divider() }
                }
                Text("\(settlements.count) transaction(s) needed to clear all debts")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    let vm: ExpenseViewModel = {
        let vm = ExpenseViewModel()
        vm.members = [
            TripMember(name: "Jimmy", role: "Host"),
            TripMember(name: "Leo", role: "Member"),
            TripMember(name: "Zoe", role: "Member"),
            TripMember(name: "Selina", role: "Member")
        ]
        let a = vm.members[0]; let b = vm.members[1]
        let c = vm.members[2]; let d = vm.members[3]
        vm.addExpense(Expense(title: "Dinner", amount: 90, payerId: a.id,
            participantIds: [a.id, b.id, c.id], category: .food))
        vm.addExpense(Expense(title: "Taxi", amount: 30, payerId: d.id,
            participantIds: [c.id, d.id], category: .transport))
        return vm
    }()
    NavigationStack { SplitResultView(viewModel: vm) }
}
