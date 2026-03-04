import Foundation
import Combine

struct TransactionGroup: Identifiable, Sendable {
    let id: Date
    let date: Date
    let transactions: [Transaction]
    
    var sectionTitle: String { date.sectionTitle }
}

enum FinanceViewModelError: LocalizedError {
    case loadFailed(Error)
    case addFailed(Error)
    case deleteFailed(Error)
    case paginationFailed(Error)
    
    var errorDescription: String? {
        switch self {
            case .loadFailed:
                return "Unable to load transactions. Pull to refresh or try again."
            case .addFailed:
                return "Unable to save transaction."
            case .deleteFailed:
                return "Unable to delete transaction."
            case .paginationFailed:
                return "Unable to load more transactions. Tap retry."
        }
    }
}

@MainActor
final class FinanceViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published private(set) var paginatedTransactions: [Transaction] = []
    @Published var showingAddTransaction = false
    @Published private(set) var isLoadingContent = false
    @Published private(set) var isLoadingNextPage = false
    @Published var contentErrorMessage: String?
    @Published var paginationErrorMessage: String?
    @Published var selectedCurrencyCode: String
    @Published private(set) var isChartLoading = false
    @Published private(set) var isPullToRefreshing = false
    
    private let store: TransactionStoreProtocol
    private let storageManager: AppStorageManager
    private let pageSize = 20
    private let pageLoadDelayNanoseconds: UInt64 = 400_000_000
    private let chartLoadingDelayNanoseconds: UInt64 = 600_000_000
    private var chartLoadingTask: Task<Void, Never>?
    
    init(
        store: TransactionStoreProtocol,
        storageManager: AppStorageManager
    ) {
        self.store = store
        self.storageManager = storageManager
        self.selectedCurrencyCode = CurrencyCatalog.normalizedCode(storageManager.selectedCurrencyCode)
        loadData()
    }
    
    convenience init() {
        self.init(
            store: TransactionStore(),
            storageManager: .shared
        )
    }
    
    deinit {
        chartLoadingTask?.cancel()
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
        let grouped = Dictionary(grouping: paginatedTransactions) { $0.date.startOfDay }
        return grouped
            .map { TransactionGroup(id: $0.key, date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    var canLoadMoreTransactions: Bool {
        paginatedTransactions.count < transactions.count
    }
    
    var expenseByCategory: [(category: TransactionCategory, amount: Double)] {
        categoryBreakdown(for: .expense)
    }
    
    func loadData() {
        startChartLoading()
        isLoadingContent = true
        defer { isLoadingContent = false }
        
        do {
            let loaded = try store.loadTransactions()
            transactions = loaded
            contentErrorMessage = nil
            paginationErrorMessage = nil
            paginatedTransactions = Array(loaded.prefix(pageSize))
        } catch {
            transactions = []
            paginatedTransactions = []
            contentErrorMessage = FinanceViewModelError.loadFailed(error).errorDescription
            paginationErrorMessage = nil
        }
    }
    
    func retryLoadingContent() {
        loadData()
    }
    
    func addTransaction(_ transaction: Transaction) throws {
        do {
            try store.addTransaction(transaction)
            loadData()
        } catch {
            let wrappedError = FinanceViewModelError.addFailed(error)
            contentErrorMessage = wrappedError.errorDescription
            throw wrappedError
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        do {
            try store.deleteTransaction(id: transaction.id)
            loadData()
        } catch {
            contentErrorMessage = FinanceViewModelError.deleteFailed(error).errorDescription
        }
    }
    
    func deleteTransactions(in group: TransactionGroup, at offsets: IndexSet) {
        do {
            for index in offsets {
                try store.deleteTransaction(id: group.transactions[index].id)
            }
            loadData()
        } catch {
            contentErrorMessage = FinanceViewModelError.deleteFailed(error).errorDescription
        }
    }
    
    func loadNextPageIfNeeded() {
        guard canLoadMoreTransactions else { return }
        guard !isLoadingNextPage else { return }
        
        Task {
            await loadNextPage()
        }
    }
    
    func retryLoadNextPage() {
        paginationErrorMessage = nil
        loadNextPageIfNeeded()
    }
    
    func refreshWithFakeDelay() async {
        isPullToRefreshing = true
        defer { isPullToRefreshing = false }
        
        do {
            startChartLoading()
            try await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            loadData()
        } catch {
            return
        }
    }
    
    func setCurrencyCode(_ code: String) {
        let normalizedCode = CurrencyCatalog.normalizedCode(code)
        guard selectedCurrencyCode != normalizedCode else { return }
        selectedCurrencyCode = normalizedCode
        storageManager.selectedCurrencyCode = normalizedCode
    }
    
    private func loadNextPage() async {
        guard canLoadMoreTransactions else { return }
        guard !isLoadingNextPage else { return }
        
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }
        
        do {
            try await Task.sleep(nanoseconds: pageLoadDelayNanoseconds)
            guard !Task.isCancelled else { return }
            
            let nextPage = try store.loadTransactionsPage(
                offset: paginatedTransactions.count,
                limit: pageSize
            )
            
            paginationErrorMessage = nil
            paginatedTransactions.append(contentsOf: nextPage)
            
            if nextPage.isEmpty {
                transactions = try store.loadTransactions()
                if paginatedTransactions.count > transactions.count {
                    paginatedTransactions = Array(paginatedTransactions.prefix(transactions.count))
                }
            }
        } catch {
            guard !Task.isCancelled else { return }
            paginationErrorMessage = FinanceViewModelError.paginationFailed(error).errorDescription
        }
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
    
    private func startChartLoading() {
        chartLoadingTask?.cancel()
        isChartLoading = true
        
        chartLoadingTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.chartLoadingDelayNanoseconds)
            guard !Task.isCancelled else { return }
            self.isChartLoading = false
        }
    }
}

#if DEBUG
extension FinanceViewModel {
    static var preview: FinanceViewModel {
        FinanceViewModel(
            store: PreviewData.previewStore,
            storageManager: .shared
        )
    }
}
#endif
