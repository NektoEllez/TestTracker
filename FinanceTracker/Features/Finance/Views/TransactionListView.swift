import SwiftUI

struct TransactionListView: View {
    let groups: [TransactionGroup]
    let onDelete: (TransactionGroup, IndexSet) -> Void

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
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            ForEach(groups) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    }
                } header: {
                    sectionHeader(group.sectionTitle)
                }
            }
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
}

#Preview("Transaction List - Empty") {
    TransactionListView(groups: [], onDelete: { _, _ in })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

#Preview("Transaction List - With Data") {
    TransactionListView(groups: PreviewData.sampleGroups, onDelete: { _, _ in })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
