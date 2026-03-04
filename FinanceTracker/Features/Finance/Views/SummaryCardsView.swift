import SwiftUI

struct SummaryCardsView: View {
    let income: Decimal
    let expenses: Decimal
    let balance: Decimal
    let currencyCode: String
    
    private var metrics: [SummaryMetric] {
        [
            SummaryMetric(titleKey: "income", amount: income, color: .appGreen, icon: "arrow.down.circle.fill"),
            SummaryMetric(titleKey: "expenses", amount: expenses, color: .appRed, icon: "arrow.up.circle.fill"),
            SummaryMetric(titleKey: "balance", amount: balance, color: .appBlue, icon: "equal.circle.fill")
        ]
    }
    
    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: 12) {
                cardsContent
            }
        } else {
            cardsContent
        }
    }
    
    private var cardsContent: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 120), spacing: 12)],
            spacing: 12
        ) {
            ForEach(metrics) { metric in
                summaryCard(metric)
            }
        }
    }
    
    private func summaryCard(_ metric: SummaryMetric) -> some View {
        VStack(spacing: 6) {
            Image(systemName: metric.icon)
                .font(.title3)
                .foregroundColor(metric.color)
            
            Text(metric.titleKey)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(metric.amount.formattedCurrency(code: currencyCode, maximumFractionDigits: 0))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            Color.cardBackground.opacity(0.35),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .appGlassSurface(cornerRadius: 12)
    }
}

private struct SummaryMetric: Identifiable {
    let titleKey: LocalizedStringKey
    let amount: Decimal
    let color: Color
    let icon: String
    
    var id: String { icon }
}

#Preview("Summary Cards") {
    SummaryCardsView(
        income: 1500,
        expenses: 245,
        balance: 1255,
        currencyCode: "USD"
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
}
