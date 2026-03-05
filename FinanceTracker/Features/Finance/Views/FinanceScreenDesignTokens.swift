import CoreGraphics

enum FinanceScreenDesignTokens {
    enum Layout {
        static let contentSpacing: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 8
        static let bottomPaddingModern: CGFloat = 24
        static let bottomPaddingLegacy: CGFloat = 96
        static let summaryTopSpacer: CGFloat = 100
    }

    enum Section {
        static let chartTitleSpacing: CGFloat = 12
        static let transactionsTitleSpacing: CGFloat = 8
    }

    enum Chart {
        static let compactThreshold: CGFloat = 520
        static let compactSpacing: CGFloat = 16
        static let regularSpacing: CGFloat = 20
        static let compactMaxWidth: CGFloat = 300
        static let regularMaxWidth: CGFloat = 340
        static let regularWidthRatio: CGFloat = 0.5
        static let emptyHeight: CGFloat = 230
        static let filledHeight: CGFloat = 320
        static let innerHorizontalPadding: CGFloat = 12
        static let innerVerticalPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 16
    }

    enum Transactions {
        static let cardCornerRadius: CGFloat = 12
    }

    enum ErrorState {
        static let verticalSpacing: CGFloat = 10
        static let verticalPadding: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let iconName = "exclamationmark.triangle"
        static let retryKey = "retry"
    }

    enum Toast {
        static let contentErrorIcon = "xmark.octagon.fill"
        static let paginationErrorIcon = "exclamationmark.triangle.fill"
    }

    enum Localization {
        static let expenseBreakdownKey = "expense_breakdown"
        static let loadingChartKey = "loading_chart"
        static let transactionsKey = "transactions"
        static let totalKey = "total"
    }
}
