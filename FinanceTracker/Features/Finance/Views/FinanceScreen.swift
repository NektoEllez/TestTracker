import SwiftUI

struct FinanceScreen: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.toastStore) private var toastStore

    var body: some View {
        DotRefreshScrollView(onRefresh: {
            await viewModel.refreshWithFakeDelay()
        }) {
            contentBody
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onChange(of: viewModel.contentErrorMessage) { newValue in
            guard let message = newValue else { return }
            toastStore?.show(
                ToastMessage(text: message, icon: "xmark.octagon.fill", style: .error)
            )
        }
        .onChange(of: viewModel.paginationErrorMessage) { newValue in
            guard let message = newValue else { return }
            toastStore?.show(
                ToastMessage(text: message, icon: "exclamationmark.triangle.fill", style: .warning)
            )
        }
    }

    @ViewBuilder
    private var contentBody: some View {
        VStack(spacing: 20) {
            if shouldShowGlobalLoader {
                FinanceSkeletonView(showTopLoader: !viewModel.isPullToRefreshing)
            } else {
                summarySection
                chartSection
                transactionsSection
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 120)
    }

    private var shouldShowGlobalLoader: Bool {
        viewModel.isPullToRefreshing || viewModel.isLoadingContent || viewModel.isChartLoading
    }

    private var summarySection: some View {
        SummaryCardsView(
            income: viewModel.totalIncome,
            expenses: viewModel.totalExpenses,
            balance: viewModel.balance,
            currencyCode: viewModel.selectedCurrencyCode
        )
    }

    @ViewBuilder
    private var chartSection: some View {
        if viewModel.isChartLoading || !viewModel.expenseByCategory.isEmpty {
            VStack(spacing: 12) {
                sectionHeader("Expense Breakdown")

                let segments = [ChartSegment].from(categoryAmounts: viewModel.expenseByCategory)
                chartContent(segments, isLoading: viewModel.isChartLoading)
                    .cardSurface(cornerRadius: 16)
            }
        }
    }

    private func chartContent(_ segments: [ChartSegment], isLoading: Bool) -> some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.width < 520

            Group {
                if isLoading {
                    LoadingIndicatorView(message: "Loading chart...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if isCompact {
                    VStack(spacing: 16) {
                        DonutChartView(
                            segments: segments,
                            centerText: viewModel.totalExpenses.formattedCurrency(
                                code: viewModel.selectedCurrencyCode,
                                maximumFractionDigits: 0
                            ),
                            centerSubtext: "Total",
                            isLoading: false
                        )
                        .frame(maxWidth: 300)
                        .frame(maxWidth: .infinity, alignment: .center)

                        ChartLegendView(
                            segments: segments,
                            currencyCode: viewModel.selectedCurrencyCode
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    HStack(alignment: .top, spacing: 20) {
                        DonutChartView(
                            segments: segments,
                            centerText: viewModel.totalExpenses.formattedCurrency(
                                code: viewModel.selectedCurrencyCode,
                                maximumFractionDigits: 0
                            ),
                            centerSubtext: "Total",
                            isLoading: false
                        )
                        .frame(width: min(340, proxy.size.width * 0.5))

                        ChartLegendView(
                            segments: segments,
                            currencyCode: viewModel.selectedCurrencyCode
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: segments.isEmpty ? 230 : 320)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private var transactionsSection: some View {
        VStack(spacing: 8) {
            sectionHeader("Transactions")

            if let contentErrorMessage = viewModel.contentErrorMessage {
                transactionsErrorState(message: contentErrorMessage)
                    .cardSurface(cornerRadius: 12)
            } else {
                TransactionListView(
                    groups: viewModel.groupedTransactions,
                    currencyCode: viewModel.selectedCurrencyCode,
                    isLoadingNextPage: viewModel.isLoadingNextPage,
                    canLoadMore: viewModel.canLoadMoreTransactions,
                    paginationErrorMessage: viewModel.paginationErrorMessage,
                    onDelete: { group, offsets in
                        viewModel.deleteTransactions(in: group, at: offsets)
                    },
                    onLoadMore: {
                        viewModel.loadNextPageIfNeeded()
                    },
                    onRetryLoadMore: {
                        viewModel.retryLoadNextPage()
                    }
                )
                .cardSurface(cornerRadius: 12)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func transactionsErrorState(message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title3)
                .foregroundColor(.orange)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                viewModel.retryLoadingContent()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Finance Screen") {
    FinanceScreen(viewModel: .preview)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private extension View {
    func cardSurface(cornerRadius: CGFloat) -> some View {
        self
            .background(
                Color.cardBackground.opacity(0.35),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .appGlassSurface(cornerRadius: cornerRadius)
    }
}
