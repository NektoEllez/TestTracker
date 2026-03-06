import SwiftUI

struct FinanceScreen: View {
    var viewModel: FinanceViewModel
    @Environment(\.toastStore) private var toastStore
    @Environment(\.locale) private var locale
    @State private var contentOffsetY: CGFloat = 0
    let onScrollOffsetChange: ((CGFloat) -> Void)?
    
    init(
        viewModel: FinanceViewModel,
        onScrollOffsetChange: ((CGFloat) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onScrollOffsetChange = onScrollOffsetChange
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            modernBody
        } else {
            legacyBody
        }
    }
    
    private var modernBody: some View {
        applySharedScreenModifiers(
            to: ScrollView {
                contentBody
            }
                .refreshable {
                    await viewModel.refreshWithFakeDelay()
                }
                .onPreferenceChange(OffsetPreferenceKey.self) { value in
                    contentOffsetY = value
                    onScrollOffsetChange?(value)
                }
        )
    }
    
    private var legacyBody: some View {
        applySharedScreenModifiers(
            to: DotRefreshScrollView {
                await viewModel.refreshWithFakeDelay()
            } content: {
                contentBody
            }
        )
    }
    
    private func applySharedScreenModifiers<Content: View>(to content: Content) -> some View {
        content
            .scrollEdgeWithBottomBar()
            .screenContainerStyle()
            .onChange(of: viewModel.contentErrorMessage) { newValue in
                showToastIfNeeded(
                    newValue,
                    icon: FinanceScreenDesignTokens.Toast.contentErrorIcon,
                    style: .error
                )
            }
            .onChange(of: viewModel.paginationErrorMessage) { newValue in
                showToastIfNeeded(
                    newValue,
                    icon: FinanceScreenDesignTokens.Toast.paginationErrorIcon,
                    style: .warning
                )
            }
    }
    
    @ViewBuilder
    private var contentBody: some View {
        VStack(spacing: FinanceScreenDesignTokens.Layout.contentSpacing) {
            if shouldShowGlobalLoader {
                FinanceSkeletonView(showTopLoader: !viewModel.isPullToRefreshing)
            } else {
                summarySection
                chartSection
                transactionsSection
            }
        }
        .padding(.horizontal, FinanceScreenDesignTokens.Layout.horizontalPadding)
        .padding(.top, FinanceScreenDesignTokens.Layout.topPadding)
        .padding(.bottom, bottomContentPadding)
    }
    
    private var bottomContentPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return FinanceScreenDesignTokens.Layout.bottomPaddingModern
        }
        return FinanceScreenDesignTokens.Layout.bottomPaddingLegacy
    }
    
    private var shouldShowGlobalLoader: Bool {
        viewModel.isPullToRefreshing || viewModel.isLoadingContent || viewModel.isChartLoading
    }
    
    @ViewBuilder
    private var summarySection: some View {
        Spacer(minLength: FinanceScreenDesignTokens.Layout.summaryTopSpacer)
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
            VStack(spacing: FinanceScreenDesignTokens.Section.chartTitleSpacing) {
                sectionHeader(localized(FinanceScreenDesignTokens.Localization.expenseBreakdownKey))
                
                let segments = [ChartSegment].from(categoryAmounts: viewModel.expenseByCategory, locale: locale)
                chartContent(segments, isLoading: viewModel.isChartLoading)
                    .cardSurface(cornerRadius: FinanceScreenDesignTokens.Chart.cardCornerRadius)
            }
        }
    }
    
    private func chartContent(_ segments: [ChartSegment], isLoading: Bool) -> some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.width < FinanceScreenDesignTokens.Chart.compactThreshold
            
            Group {
                if isLoading {
                    LoadingIndicatorView(message: localized(FinanceScreenDesignTokens.Localization.loadingChartKey))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if isCompact {
                    VStack(spacing: FinanceScreenDesignTokens.Chart.compactSpacing) {
                        donutChart(segments)
                            .frame(maxWidth: FinanceScreenDesignTokens.Chart.compactMaxWidth)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        chartLegend(segments)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    HStack(alignment: .top, spacing: FinanceScreenDesignTokens.Chart.regularSpacing) {
                        donutChart(segments)
                            .frame(
                                width: min(
                                    FinanceScreenDesignTokens.Chart.regularMaxWidth,
                                    proxy.size.width * FinanceScreenDesignTokens.Chart.regularWidthRatio
                                )
                            )
                        
                        chartLegend(segments)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(
            height: segments.isEmpty
            ? FinanceScreenDesignTokens.Chart.emptyHeight
            : FinanceScreenDesignTokens.Chart.filledHeight
        )
        .padding(.horizontal, FinanceScreenDesignTokens.Chart.innerHorizontalPadding)
        .padding(.vertical, FinanceScreenDesignTokens.Chart.innerVerticalPadding)
    }
    
    private var transactionsSection: some View {
        VStack(spacing: FinanceScreenDesignTokens.Section.transactionsTitleSpacing) {
            sectionHeader(localized(FinanceScreenDesignTokens.Localization.transactionsKey))
            
            if let contentErrorMessage = viewModel.contentErrorMessage {
                transactionsErrorState(message: contentErrorMessage)
                    .cardSurface(cornerRadius: FinanceScreenDesignTokens.Transactions.cardCornerRadius)
            } else {
                TransactionListView(
                    groups: viewModel.groupedTransactions,
                    currencyCode: viewModel.selectedCurrencyCode,
                    isLoadingNextPage: viewModel.isLoadingNextPage,
                    canLoadMore: viewModel.canLoadMoreTransactions,
                    paginationErrorMessage: viewModel.paginationErrorMessage,
                    onLoadMore: {
                        viewModel.loadNextPageIfNeeded()
                    },
                    onRetryLoadMore: {
                        viewModel.retryLoadNextPage()
                    }
                )
                .cardSurface(cornerRadius: FinanceScreenDesignTokens.Transactions.cardCornerRadius)
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func localized(_ key: String) -> String {
        Bundle.main.localizedString(for: key, locale: locale)
    }
    
    private func showToastIfNeeded(_ message: String?, icon: String, style: ToastStyle) {
        guard let message else { return }
        toastStore?.show(ToastMessage(text: message, icon: icon, style: style))
    }
    
    private func donutChart(_ segments: [ChartSegment]) -> some View {
        DonutChartView(
            segments: segments,
            centerText: viewModel.totalExpenses.formattedCurrency(
                code: viewModel.selectedCurrencyCode,
                maximumFractionDigits: 0
            ),
            centerSubtext: localized(FinanceScreenDesignTokens.Localization.totalKey),
            isLoading: false
        )
    }
    
    private func chartLegend(_ segments: [ChartSegment]) -> some View {
        ChartLegendView(
            segments: segments,
            currencyCode: viewModel.selectedCurrencyCode
        )
    }
    
    private func transactionsErrorState(message: String) -> some View {
        VStack(spacing: FinanceScreenDesignTokens.ErrorState.verticalSpacing) {
            Image(systemName: FinanceScreenDesignTokens.ErrorState.iconName)
                .font(.title3)
                .foregroundColor(.orange)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(FinanceScreenDesignTokens.ErrorState.retryKey) {
                Haptics.selection()
                viewModel.retryLoadingContent()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.vertical, FinanceScreenDesignTokens.ErrorState.verticalPadding)
        .padding(.horizontal, FinanceScreenDesignTokens.ErrorState.horizontalPadding)
        .frame(maxWidth: .infinity)
    }
}

private extension View {
    func screenContainerStyle() -> some View {
        modifier(FinanceScreenContainerStyle())
    }
}

private struct FinanceScreenContainerStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .ignoresSafeArea(.container, edges: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
        } else {
            content
                .ignoresSafeArea(.container, edges: [.top, .bottom])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
        }
    }
}

#Preview("Finance Screen") {
    FinanceScreen(viewModel: .preview)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
