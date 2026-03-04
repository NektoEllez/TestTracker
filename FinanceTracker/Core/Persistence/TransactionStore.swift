import Foundation
import os

final class TransactionStore: TransactionStoreProtocol {
    private static let logger = Logger(subsystem: "Legacy.FinanceTracker", category: "TransactionStore")

    private let fileURL: URL

    init() {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            preconditionFailure("Documents directory is unavailable")
        }
        self.fileURL = documentsDirectory.appendingPathComponent("transactions.json")
    }

    func loadTransactions() -> [Transaction] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Transaction].self, from: data)
        } catch {
            let wrappedError = TransactionStoreError.readFailed(error)
            Self.logger.error("\(wrappedError.localizedDescription, privacy: .public)")
            return []
        }
    }

    func saveTransactions(_ transactions: [Transaction]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(transactions)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            let wrappedError = TransactionStoreError.writeFailed(error)
            Self.logger.error("\(wrappedError.localizedDescription, privacy: .public)")
        }
    }

    func addTransaction(_ transaction: Transaction) {
        var transactions = loadTransactions()
        transactions.append(transaction)
        saveTransactions(transactions)
    }

    func deleteTransaction(id: TransactionID) {
        var transactions = loadTransactions()
        transactions.removeAll { $0.id == id }
        saveTransactions(transactions)
    }
}

enum TransactionStoreError: Error {
    case readFailed(Error)
    case writeFailed(Error)
}

extension TransactionStoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .readFailed(let error):
            return "Failed to load transactions: \(error.localizedDescription)"
        case .writeFailed(let error):
            return "Failed to save transactions: \(error.localizedDescription)"
        }
    }
}
