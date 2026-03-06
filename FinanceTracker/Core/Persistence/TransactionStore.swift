import Foundation
import os

final class TransactionStore: TransactionStoreProtocol {
    private static let logger = Logger(subsystem: "Legacy.FinanceTracker", category: "TransactionStore")
    
    private let fileURL: URL
    private let queue = DispatchQueue(label: "Legacy.FinanceTracker.TransactionStore")
    
    init() {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            preconditionFailure("Documents directory is unavailable")
        }
        self.fileURL = documentsDirectory.appendingPathComponent("transactions.json")
    }
    
    func loadTransactions() throws -> [Transaction] {
        try queue.sync {
            try loadTransactionsUnlocked()
        }
    }
    
    func loadTransactionsPage(offset: Int, limit: Int) throws -> [Transaction] {
        try queue.sync {
            guard offset >= 0 else {
                throw TransactionStoreError.invalidPagination(offset: offset, limit: limit)
            }
            guard limit > 0 else {
                throw TransactionStoreError.invalidPagination(offset: offset, limit: limit)
            }
            
            let allTransactions = try loadTransactionsUnlocked()
            guard offset < allTransactions.count else { return [] }
            
            let endIndex = min(offset + limit, allTransactions.count)
            return Array(allTransactions[offset..<endIndex])
        }
    }
    
    func transactionsCount() throws -> Int {
        try queue.sync {
            try loadTransactionsUnlocked().count
        }
    }
    
    func saveTransactions(_ transactions: [Transaction]) throws {
        try queue.sync {
            try saveTransactionsUnlocked(transactions)
        }
    }
    
    func addTransaction(_ transaction: Transaction) throws {
        try queue.sync {
            var transactions = try loadTransactionsUnlocked()
            transactions.append(transaction)
            try saveTransactionsUnlocked(transactions)
        }
    }
    
    func deleteTransaction(id: TransactionID) throws {
        try queue.sync {
            var transactions = try loadTransactionsUnlocked()
            transactions.removeAll { $0.id == id }
            try saveTransactionsUnlocked(transactions)
        }
    }

    private func loadTransactionsUnlocked() throws -> [Transaction] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let transactions = try decoder.decode([Transaction].self, from: data)
            return transactions.sorted { $0.date > $1.date }
        } catch {
            let wrappedError = TransactionStoreError.readFailed(error)
            Self.logger.error("\(wrappedError.localizedDescription, privacy: .public)")
            throw wrappedError
        }
    }

    private func saveTransactionsUnlocked(_ transactions: [Transaction]) throws {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(transactions)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            let wrappedError = TransactionStoreError.writeFailed(error)
            Self.logger.error("\(wrappedError.localizedDescription, privacy: .public)")
            throw wrappedError
        }
    }
}

enum TransactionStoreError: Error {
    case readFailed(Error)
    case writeFailed(Error)
    case invalidPagination(offset: Int, limit: Int)
}

extension TransactionStoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .readFailed(let error):
                return "Failed to load transactions: \(error.localizedDescription)"
            case .writeFailed(let error):
                return "Failed to save transactions: \(error.localizedDescription)"
            case let .invalidPagination(offset, limit):
                return "Invalid pagination settings (offset: \(offset), limit: \(limit))."
        }
    }
}
