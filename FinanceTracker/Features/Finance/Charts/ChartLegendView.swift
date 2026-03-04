import SwiftUI

struct ChartLegendView: View {
    let segments: [ChartSegment]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(segments) { segment in
                legendRow(segment)
            }
        }
    }

    private func legendRow(_ segment: ChartSegment) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(segment.color)
                .frame(width: 10, height: 10)

            Text(segment.label)
                .font(.caption)
                .foregroundColor(.primary)

            Spacer()

            Text(String(format: "%.1f%%", segment.percentage * 100))
                .font(.caption)
                .foregroundColor(.secondary)

            Text(segment.amount.formattedCurrency(maximumFractionDigits: 0))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview("Chart Legend") {
    let segments = [ChartSegment].from(categoryAmounts: [
        (TransactionCategory.food, 120),
        (TransactionCategory.transport, 80)
    ])
    return ChartLegendView(segments: segments)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
