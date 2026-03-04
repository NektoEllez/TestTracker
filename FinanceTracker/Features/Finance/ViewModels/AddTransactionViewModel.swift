import Foundation
import Combine

@MainActor
final class AddTransactionViewModel: ObservableObject {
    @Published var amountText: String = "" {
        didSet {
            validateAmountInput()
        }
    }
    @Published var selectedType: TransactionType = .expense
    @Published var selectedCategory: TransactionCategory = .food
    @Published var date: Date = Date()
    @Published var note: String = "" {
        didSet {
            enforceNoteLimit()
        }
    }
    @Published private(set) var amountErrorMessage: String?
    @Published var selectedCurrencyCode: String
    
    let noteLimit = 120
    
    private let storageManager: AppStorageManager
    
    init(storageManager: AppStorageManager) {
        self.storageManager = storageManager
        self.selectedCurrencyCode = CurrencyCatalog.normalizedCode(storageManager.selectedCurrencyCode)
    }
    
    convenience init() {
        self.init(storageManager: .shared)
    }
    
    var availableCategories: [TransactionCategory] {
        switch selectedType {
            case .income:
                return TransactionCategory.incomeCategories
            case .expense:
                return TransactionCategory.expenseCategories
        }
    }
    
    var isValid: Bool {
        amountValidationError == nil
    }
    
    var parsedAmount: Decimal? {
        AmountInputValidator.parseAmount(from: amountText)
    }
    
    func buildTransaction() -> Transaction? {
        guard validateForm(), let amount = parsedAmount else { return nil }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Transaction(
            amount: amount,
            type: selectedType,
            category: selectedCategory,
            date: date,
            note: trimmedNote.isEmpty ? nil : trimmedNote
        )
    }
    
    func onTypeChanged() {
        if let first = availableCategories.first {
            selectedCategory = first
        }
    }
    
    func setCurrencyCode(_ code: String) {
        let normalizedCode = CurrencyCatalog.normalizedCode(code)
        guard selectedCurrencyCode != normalizedCode else { return }
        selectedCurrencyCode = normalizedCode
        storageManager.selectedCurrencyCode = normalizedCode
    }
    
    private var amountValidationError: AmountValidationError? {
        AmountInputValidator.validationError(for: amountText)
    }
    
    private func validateForm() -> Bool {
        amountErrorMessage = amountValidationError?.errorDescription
        return amountErrorMessage == nil
    }
    
    private func validateAmountInput() {
        if amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            amountErrorMessage = nil
            return
        }
        
        if let validationError = amountValidationError, validationError != .empty {
            amountErrorMessage = validationError.errorDescription
        } else {
            amountErrorMessage = nil
        }
    }
    
    private func enforceNoteLimit() {
        if note.count > noteLimit {
            note = String(note.prefix(noteLimit))
        }
    }
}
