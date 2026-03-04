import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let currencyCode: String
    
    var body: some View {
        HStack(spacing: 12) {
            categoryIcon
            transactionDetails
            Spacer()
            amountLabel
        }
        .padding(.vertical, 4)
    }
    
    private var categoryIcon: some View {
        Image(systemName: transaction.category.icon)
            .font(.body)
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(transaction.category.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var transactionDetails: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(transaction.category.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if let note = transaction.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    private var amountLabel: some View {
        Text(formattedAmount)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(transaction.type == .income ? .appGreen : .appRed)
    }
    
    private var formattedAmount: String {
        let prefix = transaction.type == .income ? "+" : "-"
        let formatted = transaction.amount.formattedCurrency(code: currencyCode, maximumFractionDigits: 2)
        return "\(prefix)\(formatted)"
    }
}

#Preview("Transaction Row") {
    TransactionRowView(
        transaction: PreviewData.sampleTransaction,
        currencyCode: "USD"
    )
    .frame(maxWidth: .infinity)
    .padding()
}
