import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    let editingExpense: Expense?

    @State private var title:          String          = ""
    @State private var amountText:     String          = ""
    @State private var category:       ExpenseCategory = .other
    @State private var selectedPayer:  UUID?           = nil
    @State private var participantIds: Set<UUID>       = []
    @State private var splitMethod:    SplitMethod     = .equal
    @State private var customShares:   [UUID: String]  = [:]

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

    private var equalSharePreview: Double? {
        guard let amount = parsedAmount, !participantIds.isEmpty else { return nil }
        return ((amount / Double(participantIds.count)) * 100).rounded() / 100
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(isEditing ? "Edit your expense" : "Add a new expense")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)

                    detailsCard
                    payerCard
                    participantsCard
                    splitMethodCard
                    if splitMethod == .custom { customSplitCard }
                    saveButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Expense" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear(perform: populateForEditing)
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

    private var detailsCard: some View {
        card {
            Text("Details")
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                TextField("Title (e.g. Team dinner)", text: $title)
                    .onChange(of: title) { _, _ in titleError = nil }
                if let err = titleError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }
            Divider()
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
            Divider()
            Text("Category")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Category", selection: $category) {
                ForEach(ExpenseCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.systemImage).tag(cat)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var payerCard: some View {
        card {
            Text("Who paid?")
                .font(.caption)
                .foregroundStyle(.secondary)
            if viewModel.members.isEmpty {
                Text("Add members to the trip first")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.members) { member in
                    HStack {
                        Text(member.name)
                        Spacer()
                        Image(systemName: selectedPayer == member.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedPayer == member.id
                                ? Color(red: 0.02, green: 0.22, blue: 0.15) : Color.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedPayer = member.id; payerError = nil }
                    if member.id != viewModel.members.last?.id { Divider() }
                }
            }
            if let err = payerError {
                Text(err).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var participantsCard: some View {
        card {
            HStack {
                Text("Split between")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Select All") {
                    participantIds = Set(viewModel.members.map { $0.id })
                    participantsError = nil
                }
                .font(.caption)
                .foregroundStyle(Color(red: 0.02, green: 0.22, blue: 0.15))
            }
            ForEach(viewModel.members) { member in
                HStack {
                    Text(member.name)
                    Spacer()
                    Image(systemName: participantIds.contains(member.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(participantIds.contains(member.id)
                            ? Color(red: 0.02, green: 0.22, blue: 0.15) : Color.secondary)
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
                if member.id != viewModel.members.last?.id { Divider() }
            }
            if let err = participantsError {
                Text(err).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var splitMethodCard: some View {
        card {
            Text("Split method")
                .font(.caption)
                .foregroundStyle(.secondary)
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

    private var customSplitCard: some View {
        card {
            Text("Custom amounts")
                .font(.caption)
                .foregroundStyle(.secondary)
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
                if member.id != viewModel.members.filter({ participantIds.contains($0.id) }).last?.id {
                    Divider()
                }
            }
            if let amount = parsedAmount {
                let remaining = amount - customSharesTotal
                Divider()
                Text("Entered: \(customSharesTotal, format: .currency(code: "AUD")) of \(amount, format: .currency(code: "AUD"))")
                    .font(.caption).foregroundStyle(.secondary)
                if abs(remaining) > 0.005 {
                    Text("Remaining: \(remaining, format: .currency(code: "AUD"))")
                        .font(.caption)
                        .foregroundStyle(remaining < 0 ? Color.red : Color.orange)
                } else {
                    Text("Amounts balanced ✓").font(.caption).foregroundStyle(.green)
                }
            }
            if let err = customSharesError {
                Text(err).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Text("Save")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.02, green: 0.22, blue: 0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 8)
        .disabled(viewModel.members.isEmpty)
    }

    private func populateForEditing() {
        guard let expense = editingExpense else {
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
        guard validate(), let amount = parsedAmount, let payerId = selectedPayer else { return }
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
        if isEditing { viewModel.updateExpense(expense) } else { viewModel.addExpense(expense) }
        dismiss()
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
        return vm
    }()
    AddExpenseView(viewModel: vm)
}
