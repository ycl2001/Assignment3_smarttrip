import SwiftUI

// MARK: - ExpenseView

struct ExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel

    @State private var showingAddExpense = false
    @State private var expenseToEdit: Expense?

    // group by day so the list is easier to read, newest first
    private var groupedExpenses: [(dateLabel: String, items: [Expense])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true  // "Today", "Yesterday" etc.

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
        NavigationStack {
            List {
                summarySection
                balanceSection
                expenseListSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Expenses")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(item: $expenseToEdit) { expense in
                AddExpenseView(viewModel: viewModel, editingExpense: expense)
            }
        }
    }

    // MARK: - Sections

    private var summarySection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.totalSpending, format: .currency(code: "AUD"))
                        .font(.title2.bold())
                }
                Spacer()
                NavigationLink("See Balances") {
                    SplitResultView(viewModel: viewModel)
                }
                .font(.subheadline)
            }
            .padding(.vertical, 4)
        }
    }

    private var balanceSection: some View {
        Section("Quick Balance") {
            if viewModel.members.isEmpty {
                Text("No members yet")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.members) { member in
                    BalanceRowView(
                        memberName: member.name,
                        balance:    viewModel.balance(for: member.id)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var expenseListSection: some View {
        if viewModel.expenses.isEmpty {
            Section {
                EmptyExpenseView()
            }
        } else {
            ForEach(groupedExpenses, id: \.dateLabel) { group in
                Section(group.dateLabel) {
                    ForEach(group.items) { expense in
                        ExpenseRowView(expense: expense, viewModel: viewModel)
                            .contentShape(Rectangle())
                            .onTapGesture { expenseToEdit = expense }
                    }
                    .onDelete { offsets in
                        viewModel.deleteExpenses(at: offsets, in: group.items)
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddExpense = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Sub-views

private struct BalanceRowView: View {
    let memberName: String
    let balance:    Double

    var body: some View {
        HStack {
            Text(memberName)
            Spacer()
            Text(balance, format: .currency(code: "AUD"))
                .fontWeight(.semibold)
                .foregroundStyle(balance >= 0 ? Color.green : Color.red)
        }
    }
}

private struct ExpenseRowView: View {
    let expense:   Expense
    let viewModel: ExpenseViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.systemImage)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.body)
                if let payer = viewModel.member(for: expense.payerId) {
                    Text("Paid by \(payer.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(expense.category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(expense.amount, format: .currency(code: "AUD"))
                .font(.body.bold())
        }
        .padding(.vertical, 2)
    }
}

private struct EmptyExpenseView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "receipt")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No expenses yet")
                .font(.headline)
            Text("Tap + to record your first expense")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - Preview

#Preview {
    let vm = ExpenseViewModel()
    vm.members = [
        Member(name: "Alice"),
        Member(name: "Bob"),
        Member(name: "Carol")
    ]
    let a = vm.members[0], b = vm.members[1], c = vm.members[2]
    vm.addExpense(Expense(
        title: "Dinner", amount: 90,
        payerId: a.id, participantIds: [a.id, b.id, c.id],
        category: .food
    ))
    vm.addExpense(Expense(
        title: "Taxi", amount: 30,
        payerId: b.id, participantIds: [a.id, b.id],
        category: .transport
    ))
    return ExpenseView(viewModel: vm)
}
