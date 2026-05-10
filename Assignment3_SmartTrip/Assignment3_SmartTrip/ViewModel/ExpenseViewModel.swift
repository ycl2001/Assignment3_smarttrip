import Foundation
import Combine

// MARK: - Expense View Model

@MainActor
final class ExpenseViewModel: ObservableObject {

    @Published private(set) var expenses: [Expense] = []

    // Members of the currently selected trip
    @Published var members: [TripMember] = []

    // Tracks which trip each expense belongs to
    @Published var expenseTripNames: [UUID: String] = [:]

    // Used when adding a new expense
    @Published var currentTripName: String = "Current Trip"

    // MARK: - Computed

    var totalSpending: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var balances: [UUID: Double] {
        var result: [UUID: Double] = [:]
        members.forEach { result[$0.id] = 0 }

        for expense in expenses {
            result[expense.payerId, default: 0] += expense.amount

            for pid in expense.participantIds {
                result[pid, default: 0] -= expense.shareAmount(for: pid)
            }
        }

        return result.mapValues {
            ($0 * 100).rounded() / 100
        }
    }

    var settlements: [Settlement] {
        minimiseSettlements(from: balances)
    }

    // MARK: - CRUD

    func addExpense(_ expense: Expense) {
        expenses.append(expense)

        // Save which trip this expense belongs to
        expenseTripNames[expense.id] = currentTripName
    }

    func updateExpense(_ updated: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == updated.id }) else {
            return
        }

        expenses[index] = updated

        // Keep existing trip name if already assigned
        if expenseTripNames[updated.id] == nil {
            expenseTripNames[updated.id] = currentTripName
        }
    }

    func deleteExpense(id: UUID) {
        expenses.removeAll { $0.id == id }
        expenseTripNames.removeValue(forKey: id)
    }

    func deleteExpenses(at offsets: IndexSet, in group: [Expense]) {
        offsets.forEach {
            deleteExpense(id: group[$0].id)
        }
    }

    // MARK: - Trip Helpers

    func tripName(for expense: Expense) -> String {
        expenseTripNames[expense.id] ?? "Current Trip"
    }

    func expenses(for tripName: String) -> [Expense] {
        expenses.filter {
            expenseTripNames[$0.id] == tripName
        }
    }

    func totalSpending(for tripName: String) -> Double {
        expenses(for: tripName).reduce(0) {
            $0 + $1.amount
        }
    }

    // MARK: - Member Helpers

    func member(for id: UUID) -> TripMember? {
        members.first { $0.id == id }
    }

    func balance(for memberId: UUID) -> Double {
        balances[memberId] ?? 0
    }

    // MARK: - Settlement

    private func minimiseSettlements(from balanceMap: [UUID: Double]) -> [Settlement] {
        var creditors = balanceMap
            .filter { $0.value > 0.005 }
            .map { (id: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }

        var debtors = balanceMap
            .filter { $0.value < -0.005 }
            .map { (id: $0.key, amount: -$0.value) }
            .sorted { $0.amount > $1.amount }

        var result: [Settlement] = []
        var ci = 0
        var di = 0

        while ci < creditors.count && di < debtors.count {
            let settle = min(
                creditors[ci].amount,
                debtors[di].amount
            )

            if settle > 0.005 {
                result.append(
                    Settlement(
                        fromMemberId: debtors[di].id,
                        toMemberId: creditors[ci].id,
                        amount: (settle * 100).rounded() / 100
                    )
                )
            }

            creditors[ci].amount -= settle
            debtors[di].amount -= settle

            if creditors[ci].amount < 0.005 {
                ci += 1
            }

            if debtors[di].amount < 0.005 {
                di += 1
            }
        }

        return result
    }
}
