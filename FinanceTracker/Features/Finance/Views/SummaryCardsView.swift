import SwiftUI

struct SummaryCardsView: View {
    let income: Decimal
    let expenses: Decimal
    let balance: Decimal

    private var metrics: [SummaryMetric] {
        [
            SummaryMetric(title: "Income", amount: income, color: .appGreen, icon: "arrow.down.circle.fill"),
            SummaryMetric(title: "Expenses", amount: expenses, color: .appRed, icon: "arrow.up.circle.fill"),
            SummaryMetric(title: "Balance", amount: balance, color: .appBlue, icon: "equal.circle.fill")
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
        HStack(spacing: 12) {
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

            Text(metric.title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(metric.amount.formattedCurrency(maximumFractionDigits: 0))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.cardBackground.opacity(0.35))
        .appGlassSurface(cornerRadius: 12)
    }
}

private struct SummaryMetric: Identifiable {
    let title: String
    let amount: Decimal
    let color: Color
    let icon: String

    var id: String { title }
}

#Preview("Summary Cards") {
    SummaryCardsView(
        income: 1500,
        expenses: 245,
        balance: 1255
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
}
