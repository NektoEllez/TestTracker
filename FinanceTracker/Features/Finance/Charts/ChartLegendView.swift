import SwiftUI

struct ChartLegendView: View {
    @Environment(\.locale) private var locale
    let segments: [ChartSegment]
    let currencyCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(segments) { segment in
                legendRow(segment)
            }
        }
    }
    
    private func legendRow(_ segment: ChartSegment) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .fill(segment.color)
                .frame(width: 10, height: 10)
            
            Text(Bundle.main.localizedString(for: segment.category.localizationKey, locale: locale))
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f%%", segment.percentage * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                
                Text(segment.amount.formattedCurrency(code: currencyCode, maximumFractionDigits: 0))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(minWidth: 96, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Chart Legend") {
    let segments = [ChartSegment].from(categoryAmounts: [
        (TransactionCategory.food, 120),
        (TransactionCategory.transport, 80)
    ])
    return ChartLegendView(
        segments: segments,
        currencyCode: "USD"
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
