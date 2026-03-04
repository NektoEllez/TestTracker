import Foundation
import SwiftUI

#if DEBUG

enum PreviewData {

    static let sampleTransactions: [Transaction] = [
        Transaction(amount: 1500, type: .income, category: .salary, note: "Monthly salary"),
        Transaction(amount: 45, type: .expense, category: .food, note: "Lunch"),
        Transaction(amount: 120, type: .expense, category: .transport, note: nil),
        Transaction(amount: 80, type: .expense, category: .entertainment, note: "Cinema")
    ]

    static let sampleTransaction: Transaction = Transaction(
        amount: 45,
        type: .expense,
        category: .food,
        note: "Lunch"
    )

    static var sampleGroups: [TransactionGroup] {
        let grouped = Dictionary(grouping: sampleTransactions) { $0.date.startOfDay }
        return grouped
            .map { TransactionGroup(id: $0.key, date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    static let previewStore: TransactionStoreProtocol = {
        let store = PreviewTransactionStore()
        for t in sampleTransactions {
            try? store.addTransaction(t)
        }
        return store
    }()
}

private final class PreviewTransactionStore: TransactionStoreProtocol {
    private var transactions: [Transaction] = []

    func loadTransactions() throws -> [Transaction] { transactions.sorted { $0.date > $1.date } }

    func loadTransactionsPage(offset: Int, limit: Int) throws -> [Transaction] {
        guard offset >= 0, limit > 0 else { return [] }
        let sorted = try loadTransactions()
        guard offset < sorted.count else { return [] }
        let end = min(offset + limit, sorted.count)
        return Array(sorted[offset..<end])
    }

    func transactionsCount() throws -> Int { transactions.count }

    func saveTransactions(_ t: [Transaction]) throws { transactions = t }

    func addTransaction(_ t: Transaction) throws { transactions.append(t) }

    func deleteTransaction(id: TransactionID) throws {
        transactions.removeAll { $0.id == id }
    }
}

#endif
