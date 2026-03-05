import SwiftUI

enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case salary
    case freelance
    case investments
    case gifts
    
    case food
    case transport
    case housing
    case entertainment
    case health
    case shopping
    case education
    case other
    
    var id: String { rawValue }
    
    var transactionType: TransactionType {
        switch self {
            case .salary, .freelance, .investments, .gifts:
                return .income
            case .food, .transport, .housing, .entertainment,
                    .health, .shopping, .education, .other:
                return .expense
        }
    }
    
    /// Localization key for the category name (e.g. "category_food").
    var localizationKey: String { "category_\(rawValue)" }
    
    var icon: String {
        switch self {
            case .salary: return "briefcase.fill"
            case .freelance: return "laptopcomputer"
            case .investments: return "chart.line.uptrend.xyaxis"
            case .gifts: return "gift.fill"
            case .food: return "fork.knife"
            case .transport: return "car.fill"
            case .housing: return "house.fill"
            case .entertainment: return "film.fill"
            case .health: return "heart.fill"
            case .shopping: return "bag.fill"
            case .education: return "book.fill"
            case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
            case .salary: return .green
            case .freelance: return Color(red: 0.2, green: 0.8, blue: 0.4)
            case .investments: return Color(red: 0.0, green: 0.6, blue: 0.8)
            case .gifts: return Color(red: 0.9, green: 0.5, blue: 0.7)
            case .food: return .orange
            case .transport: return .blue
            case .housing: return Color(red: 0.6, green: 0.4, blue: 0.8)
            case .entertainment: return .pink
            case .health: return .red
            case .shopping: return Color(red: 0.8, green: 0.6, blue: 0.2)
            case .education: return Color(red: 0.3, green: 0.5, blue: 0.9)
            case .other: return .gray
        }
    }

    
    static var incomeCategories: [TransactionCategory] {
        allCases.filter { $0.transactionType == .income }
    }
    
    static var expenseCategories: [TransactionCategory] {
        allCases.filter { $0.transactionType == .expense }
    }
}
