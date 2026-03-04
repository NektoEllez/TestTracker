protocol TransactionStoreProtocol {
    func loadTransactions() throws -> [Transaction]
    func loadTransactionsPage(offset: Int, limit: Int) throws -> [Transaction]
    func transactionsCount() throws -> Int
    func saveTransactions(_ transactions: [Transaction]) throws
    func addTransaction(_ transaction: Transaction) throws
    func deleteTransaction(id: TransactionID) throws
}
