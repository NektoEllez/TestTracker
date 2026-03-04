import SwiftUI

struct DonutChartView: View {
    let segments: [ChartSegment]
    let centerText: String
    let centerSubtext: String

    private let lineWidth: CGFloat = 32

    var body: some View {
        ZStack {
            if segments.isEmpty {
                emptyState
            } else {
                chartRing
            }
            centerLabel
        }
        .frame(width: 200, height: 200)
    }

    private var emptyState: some View {
        Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
    }

    private var chartRing: some View {
        ForEach(segments) { segment in
            DonutSegmentShape(
                startAngle: .degrees(segment.startAngle),
                endAngle: .degrees(segment.endAngle),
                lineWidth: lineWidth
            )
            .fill(segment.color)
        }
    }

    private var centerLabel: some View {
        VStack(spacing: 2) {
            Text(centerText)
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(centerSubtext)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}

// MARK: - Donut Segment Shape

struct DonutSegmentShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        return path.strokedPath(
            StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
        )
    }
}

#Preview("Donut Chart") {
    let segments = [ChartSegment].from(categoryAmounts: [
        (TransactionCategory.food, 120),
        (TransactionCategory.transport, 80),
        (TransactionCategory.entertainment, 50)
    ])
    return DonutChartView(
        segments: segments,
        centerText: "$250",
        centerSubtext: "Total"
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
