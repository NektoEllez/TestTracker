import Foundation
import Combine

struct TransactionGroup: Identifiable, Sendable {
    let id: Date
    let date: Date
    let transactions: [Transaction]

    var sectionTitle: String { date.sectionTitle }
}

@MainActor
final class FinanceViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var showingAddTransaction = false

    private let store: TransactionStoreProtocol

    init(store: TransactionStoreProtocol) {
        self.store = store
        loadData()
    }

    convenience init() {
        self.init(store: TransactionStore())
    }

    var totalIncome: Decimal {
        transactions
            .filter { $0.type == .income }
            .reduce(.zero) { $0 + $1.amount }
    }

    var totalExpenses: Decimal {
        transactions
            .filter { $0.type == .expense }
            .reduce(.zero) { $0 + $1.amount }
    }

    var balance: Decimal {
        totalIncome - totalExpenses
    }

    var groupedTransactions: [TransactionGroup] {
        let grouped = Dictionary(grouping: transactions) { $0.date.startOfDay }
        return grouped
            .map { TransactionGroup(id: $0.key, date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    var expenseByCategory: [(category: TransactionCategory, amount: Double)] {
        categoryBreakdown(for: .expense)
    }

    var incomeByCategory: [(category: TransactionCategory, amount: Double)] {
        categoryBreakdown(for: .income)
    }

    func loadData() {
        transactions = store.loadTransactions()
    }

    func addTransaction(_ transaction: Transaction) {
        store.addTransaction(transaction)
        loadData()
    }

    func deleteTransaction(_ transaction: Transaction) {
        store.deleteTransaction(id: transaction.id)
        loadData()
    }

    func deleteTransactions(in group: TransactionGroup, at offsets: IndexSet) {
        for index in offsets {
            store.deleteTransaction(id: group.transactions[index].id)
        }
        loadData()
    }

    private func categoryBreakdown(for type: TransactionType) -> [(category: TransactionCategory, amount: Double)] {
        let filtered = transactions.filter { $0.type == type }
        let grouped = Dictionary(grouping: filtered) { $0.category }

        return grouped
            .map {
                let total = $0.value.reduce(.zero) { $0 + $1.amount }
                return (category: $0.key, amount: total.doubleValue)
            }
            .sorted { $0.amount > $1.amount }
    }
}

#if DEBUG
extension FinanceViewModel {
    static var preview: FinanceViewModel {
        FinanceViewModel(store: PreviewData.previewStore)
    }
}
#endif
