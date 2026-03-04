import SwiftUI

struct FinanceScreen: View {
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summarySection
                chartSection
                transactionsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    private var summarySection: some View {
        SummaryCardsView(
            income: viewModel.totalIncome,
            expenses: viewModel.totalExpenses,
            balance: viewModel.balance
        )
    }

    @ViewBuilder
    private var chartSection: some View {
        if !viewModel.expenseByCategory.isEmpty {
            VStack(spacing: 12) {
                sectionHeader("Expense Breakdown")

                let segments = [ChartSegment].from(categoryAmounts: viewModel.expenseByCategory)
                chartContent(segments)
                    .cardSurface(cornerRadius: 16)
            }
        }
    }

    private func chartContent(_ segments: [ChartSegment]) -> some View {
        HStack(alignment: .top, spacing: 20) {
            DonutChartView(
                segments: segments,
                centerText: viewModel.totalExpenses.formattedCurrency(maximumFractionDigits: 0),
                centerSubtext: "Total"
            )

            ChartLegendView(segments: segments)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }

    private var transactionsSection: some View {
        VStack(spacing: 8) {
            sectionHeader("Transactions")

            TransactionListView(
                groups: viewModel.groupedTransactions,
                onDelete: { group, offsets in
                    viewModel.deleteTransactions(in: group, at: offsets)
                }
            )
            .cardSurface(cornerRadius: 12)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Finance Screen") {
    FinanceScreen(viewModel: .preview)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private extension View {
    func cardSurface(cornerRadius: CGFloat) -> some View {
        self
            .background(Color.cardBackground.opacity(0.35))
            .appGlassSurface(cornerRadius: cornerRadius)
    }
}
