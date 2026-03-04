import Foundation
import Combine

@MainActor
final class AddTransactionViewModel: ObservableObject {
    @Published var amountText: String = ""
    @Published var selectedType: TransactionType = .expense
    @Published var selectedCategory: TransactionCategory = .food
    @Published var date: Date = Date()
    @Published var note: String = ""

    var availableCategories: [TransactionCategory] {
        switch selectedType {
        case .income:
            return TransactionCategory.incomeCategories
        case .expense:
            return TransactionCategory.expenseCategories
        }
    }

    var isValid: Bool {
        guard let amount = parsedAmount else { return false }
        return amount > .zero
    }

    var parsedAmount: Decimal? {
        let normalized = amountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !normalized.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true

        if let number = formatter.number(from: normalized) as? NSDecimalNumber {
            return number.decimalValue
        }

        return Decimal(string: normalized)
    }

    func buildTransaction() -> Transaction? {
        guard let amount = parsedAmount, amount > .zero else { return nil }

        return Transaction(
            amount: amount,
            type: selectedType,
            category: selectedCategory,
            date: date,
            note: note.isEmpty ? nil : note
        )
    }

    func onTypeChanged() {
        if let first = availableCategories.first {
            selectedCategory = first
        }
    }
}
