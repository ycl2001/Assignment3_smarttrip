import SwiftUI

struct ExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingAddExpense = false
    @State private var expenseToEdit: Expense?

    // group expenses by day, newest first
    private var groupedExpenses: [(dateLabel: String, items: [Expense])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true

        let sorted = viewModel.expenses.sorted { $0.date > $1.date }
        var groups: [(dateLabel: String, items: [Expense])] = []
        var current: (dateLabel: String, items: [Expense])? = nil

        for expense in sorted {
            let label = formatter.string(from: expense.date)
            if current?.dateLabel == label {
                current?.items.append(expense)
            } else {
                if let existing = current { groups.append(existing) }
                current = (label, [expense])
            }
        }
        if let last = current { groups.append(last) }
        return groups
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summaryCard
                if !viewModel.members.isEmpty { balanceCard }
                expenseListSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Expenses")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddExpense = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(viewModel: viewModel)
        }
        .sheet(item: $expenseToEdit) { expense in
            AddExpenseView(viewModel: viewModel, editingExpense: expense)
        }
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

    private var summaryCard: some View {
        card {
            Text("Total Spent")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(viewModel.totalSpending, format: .currency(code: "AUD"))
                .font(.title2.bold())
            Divider()
            NavigationLink {
                SplitResultView(viewModel: viewModel)
            } label: {
                HStack {
                    Text("See how to settle up")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(Color(red: 0.02, green: 0.22, blue: 0.15))
            }
        }
    }

    private var balanceCard: some View {
        card {
            Text("Quick Balance")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(viewModel.members) { member in
                HStack {
                    Text(member.name)
                    Spacer()
                    Text(viewModel.balance(for: member.id), format: .currency(code: "AUD"))
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.balance(for: member.id) >= 0 ? Color.green : Color.red)
                }
                if member.id != viewModel.members.last?.id { Divider() }
            }
        }
    }

    @ViewBuilder
    private var expenseListSection: some View {
        if viewModel.expenses.isEmpty {
            card {
                VStack(spacing: 12) {
                    Image(systemName: "receipt")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("No expenses yet")
                        .font(.headline)
                    Text("Tap + to record your first expense")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        } else {
            ForEach(groupedExpenses, id: \.dateLabel) { group in
                card {
                    Text(group.dateLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(group.items) { expense in
                        ExpenseRowView(expense: expense, viewModel: viewModel)
                            .contentShape(Rectangle())
                            .onTapGesture { expenseToEdit = expense }
                        if expense.id != group.items.last?.id { Divider() }
                    }
                }
            }
        }
    }
}

private struct ExpenseRowView: View {
    let expense: Expense
    let viewModel: ExpenseViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.systemImage)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color(red: 0.02, green: 0.22, blue: 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title).font(.body)
                if let payer = viewModel.member(for: expense.payerId) {
                    Text("Paid by \(payer.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(expense.amount, format: .currency(code: "AUD"))
                .font(.body.bold())
        }
        .padding(.vertical, 2)
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
            participantIds: [a.id, b.id, c.id, d.id], category: .food))
        vm.addExpense(Expense(title: "Taxi", amount: 30, payerId: d.id,
            participantIds: [c.id, d.id], category: .transport))
        return vm
    }()
    NavigationStack { ExpenseView(viewModel: vm) }
}
