import SwiftUI

struct ChartSegment: Identifiable {
    let category: TransactionCategory
    let amount: Double
    let percentage: Double
    let startAngle: Double
    let endAngle: Double
    
    var id: String { category.rawValue }
    var color: Color { category.color }
    var label: String { category.displayName }
}

extension Array where Element == ChartSegment {
    static func from(
        categoryAmounts: [(category: TransactionCategory, amount: Double)]
    ) -> [ChartSegment] {
        let total = categoryAmounts.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        
        var segments: [ChartSegment] = []
        var currentAngle: Double = -90
        
        for item in categoryAmounts {
            let percentage = item.amount / total
            let sweepAngle = percentage * 360
            
            segments.append(ChartSegment(
                category: item.category,
                amount: item.amount,
                percentage: percentage,
                startAngle: currentAngle,
                endAngle: currentAngle + sweepAngle
            ))
            
            currentAngle += sweepAngle
        }
        
        return segments
    }
}
