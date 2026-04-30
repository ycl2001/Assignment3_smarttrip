import SwiftUI

// MARK: - AddExpenseView

struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    let editingExpense: Expense?

    // MARK: Form state
    @State private var title:          String          = ""
    @State private var amountText:     String          = ""
    @State private var category:       ExpenseCategory = .other
    @State private var selectedPayer:  UUID?           = nil
    @State private var participantIds: Set<UUID>       = []
    @State private var splitMethod:    SplitMethod     = .equal
    // stores raw text per member so the user can type freely before we parse
    @State private var customShares:   [UUID: String]  = [:]

    // nil means the field is fine, non-nil shows the error message inline
    @State private var titleError:        String? = nil
    @State private var amountError:       String? = nil
    @State private var payerError:        String? = nil
    @State private var participantsError: String? = nil
    @State private var customSharesError: String? = nil

    init(viewModel: ExpenseViewModel, editingExpense: Expense? = nil) {
        self.viewModel      = viewModel
        self.editingExpense = editingExpense
    }

    private var isEditing: Bool { editingExpense != nil }

    private var parsedAmount: Double? {
        guard let v = Double(amountText), v > 0 else { return nil }
        return v
    }

    private var customSharesTotal: Double {
        participantIds.reduce(0) { $0 + (Double(customShares[$1] ?? "") ?? 0) }
    }

    // live preview of each person's share when using equal split
    private var equalSharePreview: Double? {
        guard let amount = parsedAmount, !participantIds.isEmpty else { return nil }
        return ((amount / Double(participantIds.count)) * 100).rounded() / 100
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                paymentSection
                participantsSection
                splitMethodSection
                if splitMethod == .custom {
                    customSplitSection
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(viewModel.members.isEmpty)
                }
            }
            .onAppear(perform: populateForEditing)
        }
    }

    // MARK: - Sections

    private var detailsSection: some View {
        Section("Details") {
            VStack(alignment: .leading, spacing: 4) {
                TextField("Title (e.g. Team dinner)", text: $title)
                    .onChange(of: title) { _, _ in titleError = nil }
                if let err = titleError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("AUD $").foregroundStyle(.secondary)
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .onChange(of: amountText) { _, _ in amountError = nil }
                }
                if let err = amountError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }

            Picker("Category", selection: $category) {
                ForEach(ExpenseCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.systemImage).tag(cat)
                }
            }
        }
    }

    private var paymentSection: some View {
        Section("Who paid?") {
            if viewModel.members.isEmpty {
                Text("Add members to the trip first")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.members) { member in
                    HStack {
                        Text(member.name)
                        Spacer()
                        Image(systemName: selectedPayer == member.id
                              ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedPayer == member.id
                                             ? Color.accentColor : Color.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPayer = member.id
                        payerError = nil
                    }
                }
            }
            if let err = payerError {
                Text(err).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var participantsSection: some View {
        Section {
            ForEach(viewModel.members) { member in
                HStack {
                    Text(member.name)
                    Spacer()
                    Image(systemName: participantIds.contains(member.id)
                          ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(participantIds.contains(member.id)
                                         ? Color.accentColor : Color.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if participantIds.contains(member.id) {
                        participantIds.remove(member.id)
                    } else {
                        participantIds.insert(member.id)
                    }
                    participantsError = nil
                    customSharesError = nil
                }
            }
            if let err = participantsError {
                Text(err).font(.caption).foregroundStyle(.red)
            }
        } header: {
            HStack {
                Text("Split between")
                Spacer()
                Button("Select All") {
                    participantIds = Set(viewModel.members.map { $0.id })
                    participantsError = nil
                }
                .font(.caption)
                .buttonStyle(.borderless)
            }
        }
    }

    private var splitMethodSection: some View {
        Section("Split method") {
            Picker("Method", selection: $splitMethod) {
                ForEach(SplitMethod.allCases) { method in
                    Text(method.rawValue).tag(method)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: splitMethod) { _, _ in customSharesError = nil }

            Text(splitMethod.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            if splitMethod == .equal, let share = equalSharePreview {
                Text("Each person pays \(share, format: .currency(code: "AUD"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var customSplitSection: some View {
        Section {
            ForEach(viewModel.members.filter { participantIds.contains($0.id) }) { member in
                HStack {
                    Text(member.name)
                    Spacer()
                    Text("$").foregroundStyle(.secondary)
                    TextField("0.00", text: Binding(
                        get: { customShares[member.id] ?? "" },
                        set: { customShares[member.id] = $0; customSharesError = nil }
                    ))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                }
            }
        } header: {
            Text("Custom amounts")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                if let amount = parsedAmount {
                    let remaining = amount - customSharesTotal
                    Text("Entered: \(customSharesTotal, format: .currency(code: "AUD")) of \(amount, format: .currency(code: "AUD"))")
                    if abs(remaining) > 0.005 {
                        Text("Remaining: \(remaining, format: .currency(code: "AUD"))")
                            .foregroundStyle(remaining < 0 ? Color.red : Color.orange)
                    } else {
                        Text("Amounts balanced ✓").foregroundStyle(.green)
                    }
                }
                if let err = customSharesError {
                    Text(err).foregroundStyle(.red)
                }
            }
            .font(.caption)
        }
    }

    // MARK: - Logic

    // fill in existing values when the sheet opens in edit mode
    private func populateForEditing() {
        guard let expense = editingExpense else {
            // defaults for a new expense
            participantIds = Set(viewModel.members.map { $0.id })
            selectedPayer  = viewModel.members.first?.id
            return
        }
        title          = expense.title
        amountText     = String(format: "%.2f", expense.amount)
        category       = expense.category
        selectedPayer  = expense.payerId
        participantIds = Set(expense.participantIds)
        splitMethod    = expense.splitMethod
        customShares   = Dictionary(uniqueKeysWithValues:
            expense.customShares.compactMap { key, value in
                guard let uuid = UUID(uuidString: key) else { return nil }
                return (uuid, String(format: "%.2f", value))
            }
        )
    }

    @discardableResult
    private func validate() -> Bool {
        var valid = true

        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            titleError = "Please enter a title"; valid = false
        } else { titleError = nil }

        if parsedAmount == nil {
            amountError = "Please enter a valid amount greater than 0"; valid = false
        } else { amountError = nil }

        if selectedPayer == nil {
            payerError = "Please select who paid"; valid = false
        } else { payerError = nil }

        if participantIds.isEmpty {
            participantsError = "Please select at least one participant"; valid = false
        } else { participantsError = nil }

        if splitMethod == .custom, let amount = parsedAmount {
            if abs(customSharesTotal - amount) >= 0.01 {
                customSharesError = "Custom amounts must add up to \(String(format: "AUD %.2f", amount))"
                valid = false
            } else { customSharesError = nil }
        }

        return valid
    }

    private func save() {
        guard validate(),
              let amount  = parsedAmount,
              let payerId = selectedPayer else { return }

        // convert UUID keys back to strings for storage
        let shares: [String: Double] = splitMethod == .custom
            ? Dictionary(uniqueKeysWithValues: customShares.compactMap { id, text in
                guard let value = Double(text) else { return nil }
                return (id.uuidString, value)
              })
            : [:]

        let expense = Expense(
            id:             editingExpense?.id ?? UUID(),
            title:          title.trimmingCharacters(in: .whitespaces),
            amount:         amount,
            payerId:        payerId,
            participantIds: Array(participantIds),
            splitMethod:    splitMethod,
            customShares:   shares,
            category:       category,
            date:           editingExpense?.date ?? Date()
        )

        if isEditing {
            viewModel.updateExpense(expense)
        } else {
            viewModel.addExpense(expense)
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview("Add Expense") {
    let vm: ExpenseViewModel = {
        let vm = ExpenseViewModel()
        
        vm.members = [
            TripMember(name: "Jimmy", role: "Host"),
            TripMember(name: "Leo", role: "Member"),
            TripMember(name: "Zoe", role: "Member"),
            TripMember(name: "Selina", role: "Member")
        ]
        
        return vm
    }()

    AddExpenseView(viewModel: vm)
}
