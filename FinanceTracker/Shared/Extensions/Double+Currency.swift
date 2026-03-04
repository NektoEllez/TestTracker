import Foundation

extension Decimal {
    func formattedCurrency(code: String = "USD", maximumFractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "$0"
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

extension Double {
    func formattedCurrency(code: String = "USD", maximumFractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
}
