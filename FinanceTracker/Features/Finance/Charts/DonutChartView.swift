import SwiftUI
import DGCharts
import UIKit

struct DonutChartView: View {
    let segments: [ChartSegment]
    let centerText: String
    let centerSubtext: String
    let isLoading: Bool
    
    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let chartSize = max(160, side)
            
            ZStack {
                if isLoading {
                    loadingState
                } else if segments.isEmpty {
                    emptyState
                } else {
                    DGDonutChartRepresentable(
                        segments: segments
                    )
                    centerLabel(chartSize: chartSize)
                }
            }
            .frame(width: chartSize, height: chartSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var emptyState: some View {
        Circle()
            .stroke(Color.gray.opacity(0.18), lineWidth: 28)
    }
    
    private var loadingState: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 28)
            
            DotArcLoaderView(size: 78, dotSize: 14)
        }
    }
    
    private func centerLabel(chartSize: CGFloat) -> some View {
        let innerDiameter = chartSize * 0.54
        let amountFontSize = min(max(16, chartSize * 0.105), 42)
        let subtitleFontSize = min(max(10, chartSize * 0.055), 18)
        let horizontalInset = max(10, innerDiameter * 0.12)
        let verticalInset = max(6, innerDiameter * 0.09)
        
        return VStack(spacing: 2) {
            Text(centerText)
                .font(.system(size: amountFontSize, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
            
            Text(centerSubtext)
                .font(.system(size: subtitleFontSize, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, horizontalInset)
        .padding(.vertical, verticalInset)
        .frame(width: innerDiameter, height: innerDiameter)
        .background(
            Circle()
                .fill(Color.cardBackground.opacity(0.82))
        )
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.24), lineWidth: 1)
        )
    }
}

private struct DGDonutChartRepresentable: UIViewRepresentable {
    let segments: [ChartSegment]
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> PieChartView {
        let chartView = PieChartView()
        
        chartView.backgroundColor = .clear
        chartView.legend.enabled = false
        chartView.usePercentValuesEnabled = false
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.drawEntryLabelsEnabled = false
        chartView.minOffset = 0
        chartView.setExtraOffsets(left: 6, top: 6, right: 6, bottom: 6)
        
        chartView.drawHoleEnabled = true
        chartView.holeRadiusPercent = 0.64
        chartView.holeColor = UIColor(Color.cardBackground.opacity(0.82))
        chartView.transparentCircleColor = .clear
        chartView.drawCenterTextEnabled = false
        
        return chartView
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        let signature = segmentsSignature()
        let entries = segments.map { segment in
            PieChartDataEntry(value: segment.amount, label: segment.label)
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = segments.map { UIColor($0.color) }
        dataSet.sliceSpace = 5
        dataSet.selectionShift = 0
        dataSet.drawValuesEnabled = false
        
        let data = PieChartData(dataSet: dataSet)
        data.setDrawValues(false)
        uiView.data = data
        
        context.coordinator.animateIfNeeded(
            chartView: uiView,
            signature: signature
        )
    }
    
    private func segmentsSignature() -> String {
        segments
            .map { "\($0.id):\($0.amount)" }
            .joined(separator: "|")
    }
    
    final class Coordinator {
        private var lastAnimatedSignature: String?
        private var animationToken: Int = 0
        
        func animateIfNeeded(chartView: PieChartView, signature: String) {
            guard !signature.isEmpty else { return }
            guard lastAnimatedSignature != signature else { return }
            lastAnimatedSignature = signature
            animationToken += 1
            let token = animationToken
            
            animateWhenReady(chartView: chartView, token: token, attempt: 0)
        }
        
        private func animateWhenReady(
            chartView: PieChartView,
            token: Int,
            attempt: Int
        ) {
            guard token == animationToken else { return }
            
            if chartView.window != nil {
                chartView.highlightValues(nil)
                chartView.animate(yAxisDuration: 0.55, easingOption: .easeOutCubic)
                return
            }
            
            guard attempt < 8 else { return }
            Task { @MainActor [weak self, weak chartView] in
                try? await Task.sleep(nanoseconds: 50_000_000)
                guard let self, let chartView else { return }
                self.animateWhenReady(
                    chartView: chartView,
                    token: token,
                    attempt: attempt + 1
                )
            }
        }
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
        centerSubtext: "Total",
        isLoading: false
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
