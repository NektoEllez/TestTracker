import Foundation

protocol TransactionStoreProtocol {
    func loadTransactions() -> [Transaction]
    func saveTransactions(_ transactions: [Transaction])
    func addTransaction(_ transaction: Transaction)
    func deleteTransaction(id: TransactionID)
}
