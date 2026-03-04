import SwiftUI

struct TransactionListView: View {
    let groups: [TransactionGroup]
    let currencyCode: String
    let isLoadingNextPage: Bool
    let canLoadMore: Bool
    let paginationErrorMessage: String?
    let onDelete: (TransactionGroup, IndexSet) -> Void
    let onLoadMore: () -> Void
    let onRetryLoadMore: () -> Void

    var body: some View {
        if groups.isEmpty {
            emptyState
        } else {
            transactionSections
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No transactions yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Tap + to add your first transaction")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var transactionSections: some View {
        VStack(spacing: 0) {
            ForEach(groups) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        TransactionRowView(
                            transaction: transaction,
                            currencyCode: currencyCode
                        )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    }
                } header: {
                    sectionHeader(group.sectionTitle)
                }
                .onAppear {
                    if group.id == groups.last?.id {
                        onLoadMore()
                    }
                }
            }

            paginationFooter
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.appBackground)
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if isLoadingNextPage {
            VStack(spacing: 8) {
                DotArcLoaderView(size: 52, dotSize: 10)
                Text("Loading more...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        } else if let error = paginationErrorMessage {
            VStack(spacing: 8) {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry", action: onRetryLoadMore)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        } else if canLoadMore {
            Color.clear
                .frame(height: 1)
        }
    }
}

#Preview("Transaction List - Empty") {
    TransactionListView(
        groups: [],
        currencyCode: "USD",
        isLoadingNextPage: false,
        canLoadMore: false,
        paginationErrorMessage: nil,
        onDelete: { _, _ in },
        onLoadMore: {},
        onRetryLoadMore: {}
    )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

#Preview("Transaction List - With Data") {
    TransactionListView(
        groups: PreviewData.sampleGroups,
        currencyCode: "USD",
        isLoadingNextPage: false,
        canLoadMore: true,
        paginationErrorMessage: nil,
        onDelete: { _, _ in },
        onLoadMore: {},
        onRetryLoadMore: {}
    )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
