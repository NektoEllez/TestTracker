import SwiftUI

struct FinanceAnalyticsScreen: View {
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summarySection
                dailyFlowSection
                categoriesSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.appBackgroundGradient.ignoresSafeArea())
        .navigationTitle("analytics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summarySection: some View {
        VStack(spacing: 12) {
            sectionHeader(String(localized: "overview"))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                analyticsCard(
                    title: String(localized: "average_income"),
                    value: averageAmount(for: .income).formattedCurrency(
                        code: viewModel.selectedCurrencyCode,
                        maximumFractionDigits: 0
                    ),
                    icon: "arrow.down.circle.fill",
                    tint: .appGreen
                )
                analyticsCard(
                    title: String(localized: "average_expense"),
                    value: averageAmount(for: .expense).formattedCurrency(
                        code: viewModel.selectedCurrencyCode,
                        maximumFractionDigits: 0
                    ),
                    icon: "arrow.up.circle.fill",
                    tint: .appRed
                )
                analyticsCard(
                    title: String(localized: "operations"),
                    value: "\(viewModel.transactions.count)",
                    icon: "list.bullet.rectangle",
                    tint: .appBlue
                )
                analyticsCard(
                    title: String(localized: "savings_rate"),
                    value: String(format: "%.1f%%", savingsRate * 100),
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    tint: .appAccent
                )
            }
        }
    }

    private var dailyFlowSection: some View {
        VStack(spacing: 12) {
            sectionHeader(String(localized: "daily_net_flow"))

            VStack(spacing: 10) {
                ForEach(recentFlows) { flow in
                    dailyFlowRow(flow)
                }
            }
            .padding(14)
            .cardSurface(cornerRadius: 14)
        }
    }

    private var categoriesSection: some View {
        VStack(spacing: 12) {
            sectionHeader(String(localized: "top_expense_categories"))

            let segments = [ChartSegment].from(categoryAmounts: viewModel.expenseByCategory)

            if segments.isEmpty {
                Text("no_expense_data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 28)
                    .cardSurface(cornerRadius: 14)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(segments.prefix(5).enumerated()), id: \.element.id) { index, segment in
                        categoryRow(index: index + 1, segment: segment)
                    }
                }
                .padding(14)
                .cardSurface(cornerRadius: 14)
            }
        }
    }

    private func analyticsCard(
        title: String,
        value: String,
        icon: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(tint)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .cardSurface(cornerRadius: 12)
    }

    private func dailyFlowRow(_ flow: DayFlow) -> some View {
        HStack(spacing: 10) {
            Text(flow.date.shortDayMonth.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .frame(width: 56, alignment: .leading)

            GeometryReader { proxy in
                let width = proxy.size.width
                let ratio = maxAbsNet == 0 ? 0 : abs(flow.net.doubleValue) / maxAbsNet
                let barWidth = max(2, width * ratio)
                let color: Color = flow.net >= .zero ? .appGreen : .appRed

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))

                    Capsule()
                        .fill(color.opacity(0.85))
                        .frame(width: barWidth)
                }
            }
            .frame(height: 14)

            Text(
                flow.net.formattedCurrency(
                    code: viewModel.selectedCurrencyCode,
                    maximumFractionDigits: 0
                )
            )
            .font(.caption.weight(.semibold))
            .monospacedDigit()
            .foregroundColor(flow.net >= .zero ? .appGreen : .appRed)
            .frame(width: 96, alignment: .trailing)
        }
        .frame(height: 18)
    }

    private func categoryRow(index: Int, segment: ChartSegment) -> some View {
        HStack(spacing: 10) {
            Text("\(index).")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                .frame(width: 18, alignment: .leading)

            Circle()
                .fill(segment.color)
                .frame(width: 10, height: 10)

            Text(segment.label)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(format: "%.1f%%", segment.percentage * 100))
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
                .frame(width: 56, alignment: .trailing)

            Text(
                segment.amount.formattedCurrency(
                    code: viewModel.selectedCurrencyCode,
                    maximumFractionDigits: 0
                )
            )
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.primary)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(width: 100, alignment: .trailing)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func averageAmount(for type: TransactionType) -> Decimal {
        let subset = viewModel.transactions.filter { $0.type == type }
        guard !subset.isEmpty else { return .zero }
        let sum = subset.reduce(Decimal.zero) { $0 + $1.amount }
        return sum / Decimal(subset.count)
    }

    private var savingsRate: Double {
        let income = viewModel.totalIncome.doubleValue
        guard income > 0 else { return 0 }
        let ratio = (viewModel.balance.doubleValue / income)
        return min(1, max(-1, ratio))
    }

    private var recentFlows: [DayFlow] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: viewModel.transactions) {
            calendar.startOfDay(for: $0.date)
        }
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let dayTransactions = byDay[day] ?? []

            let income = dayTransactions
                .filter { $0.type == .income }
                .reduce(Decimal.zero) { $0 + $1.amount }
            let expense = dayTransactions
                .filter { $0.type == .expense }
                .reduce(Decimal.zero) { $0 + $1.amount }

            return DayFlow(date: day, income: income, expense: expense)
        }
    }

    private var maxAbsNet: Double {
        recentFlows
            .map { abs($0.net.doubleValue) }
            .max() ?? 0
    }
}

private struct DayFlow: Identifiable {
    let id = UUID()
    let date: Date
    let income: Decimal
    let expense: Decimal

    var net: Decimal {
        income - expense
    }
}

#Preview("Analytics") {
    NavigationView {
        FinanceAnalyticsScreen(viewModel: .preview)
    }
}
