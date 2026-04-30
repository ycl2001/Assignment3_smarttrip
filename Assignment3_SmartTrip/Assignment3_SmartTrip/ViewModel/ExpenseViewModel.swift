import Foundation
import Combine

// MARK: - ExpenseViewModel

@MainActor
final class ExpenseViewModel: ObservableObject {

    @Published private(set) var expenses: [Expense] = []

    // set this from the trip's member list so balance calculations work
    @Published var members: [TripMember] = []

    // MARK: Computed

    var totalSpending: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    // positive balance = they're owed money, negative = they owe money
    var balances: [UUID: Double] {
        var result: [UUID: Double] = [:]
        members.forEach { result[$0.id] = 0 }

        for expense in expenses {
            result[expense.payerId, default: 0] += expense.amount
            for pid in expense.participantIds {
                result[pid, default: 0] -= expense.shareAmount(for: pid)
            }
        }

        // round to 2dp so we don't get $0.000000001 weirdness
        return result.mapValues { ($0 * 100).rounded() / 100 }
    }

    var settlements: [Settlement] {
        minimiseSettlements(from: balances)
    }

    // MARK: CRUD

    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }

    func updateExpense(_ updated: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == updated.id }) else { return }
        expenses[index] = updated
    }

    func deleteExpense(id: UUID) {
        expenses.removeAll { $0.id == id }
    }

    func deleteExpenses(at offsets: IndexSet, in group: [Expense]) {
        offsets.forEach { deleteExpense(id: group[$0].id) }
    }

    // MARK: Helpers

    func member(for id: UUID) -> TripMember? {
        members.first { $0.id == id }
    }

    func balance(for memberId: UUID) -> Double {
        balances[memberId] ?? 0
    }

    // MARK: - Settlement

    // greedy approach: keep pairing the person who owes the most
    // with the person who is owed the most until everyone's square
    private func minimiseSettlements(from balanceMap: [UUID: Double]) -> [Settlement] {
        var creditors = balanceMap
            .filter  { $0.value >  0.005 }
            .map     { (id: $0.key, amount:  $0.value) }
            .sorted  { $0.amount > $1.amount }

        var debtors = balanceMap
            .filter  { $0.value < -0.005 }
            .map     { (id: $0.key, amount: -$0.value) }
            .sorted  { $0.amount > $1.amount }

        var result: [Settlement] = []
        var ci = 0, di = 0

        while ci < creditors.count && di < debtors.count {
            let settle = min(creditors[ci].amount, debtors[di].amount)

            if settle > 0.005 {
                result.append(Settlement(
                    fromMemberId: debtors[di].id,
                    toMemberId: creditors[ci].id,
                    amount: (settle * 100).rounded() / 100
                ))
            }

            creditors[ci].amount -= settle
            debtors[di].amount   -= settle

            if creditors[ci].amount < 0.005 { ci += 1 }
            if debtors[di].amount   < 0.005 { di += 1 }
        }

        return result
    }
}
