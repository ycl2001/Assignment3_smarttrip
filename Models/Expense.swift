import Foundation

// MARK: - SplitMethod

// equal = split evenly, custom = each person enters their own amount
// adding a new split type only needs a new case here, nothing else changes
enum SplitMethod: String, CaseIterable, Codable, Identifiable {
    case equal  = "Equal Split"
    case custom = "Custom Split"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .equal:  return "Divide equally among all participants"
        case .custom: return "Enter a specific amount for each participant"
        }
    }
}

// MARK: - ExpenseCategory

// same idea — new categories can be added here without touching any view code
enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case food          = "Food & Drinks"
    case transport     = "Transport"
    case accommodation = "Accommodation"
    case activities    = "Activities"
    case shopping      = "Shopping"
    case other         = "Other"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .food:          return "fork.knife"
        case .transport:     return "car.fill"
        case .accommodation: return "house.fill"
        case .activities:    return "ticket.fill"
        case .shopping:      return "bag.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Expense

struct Expense: Identifiable, Codable, Equatable {

    // id and date are let so they never change after creation
    let id:   UUID
    let date: Date

    var title:          String
    var amount:         Double
    var payerId:        UUID
    var participantIds: [UUID]
    var splitMethod:    SplitMethod
    // string keys because Dictionary<UUID, Double> isn't directly Codable
    var customShares:   [String: Double]
    var category:       ExpenseCategory

    init(
        id:             UUID             = UUID(),
        title:          String,
        amount:         Double,
        payerId:        UUID,
        participantIds: [UUID],
        splitMethod:    SplitMethod      = .equal,
        customShares:   [String: Double] = [:],
        category:       ExpenseCategory  = .other,
        date:           Date             = Date()
    ) {
        self.id             = id
        self.title          = title
        self.amount         = amount
        self.payerId        = payerId
        self.participantIds = participantIds
        self.splitMethod    = splitMethod
        self.customShares   = customShares
        self.category       = category
        self.date           = date
    }

    // MARK: Calculations

    // returns how much this participant owes for this expense
    func shareAmount(for participantId: UUID) -> Double {
        switch splitMethod {
        case .equal:
            guard !participantIds.isEmpty else { return 0 }
            return ((amount / Double(participantIds.count)) * 100).rounded() / 100
        case .custom:
            return ((customShares[participantId.uuidString] ?? 0) * 100).rounded() / 100
        }
    }

    // used to block saving if custom amounts don't add up
    var hasValidCustomShares: Bool {
        guard splitMethod == .custom else { return true }
        let total = customShares.values.reduce(0, +)
        return abs(total - amount) < 0.01
    }
}

// MARK: - Settlement

// one "X pays Y $Z" instruction
struct Settlement: Identifiable, Equatable {
    let id:           UUID
    let fromMemberId: UUID
    let toMemberId:   UUID
    let amount:       Double

    init(fromMemberId: UUID, toMemberId: UUID, amount: Double) {
        self.id           = UUID()
        self.fromMemberId = fromMemberId
        self.toMemberId   = toMemberId
        self.amount       = amount
    }
}
