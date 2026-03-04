import Foundation

@MainActor
private enum CurrencyFormatting {
    private static var cache: [String: NumberFormatter] = [:]

    static func formatter(code: String, maximumFractionDigits: Int) -> NumberFormatter {
        let safeDigits = max(0, maximumFractionDigits)
        let uppercasedCode = code.uppercased()
        let key = "FinanceTracker.CurrencyFormatter.\(uppercasedCode).\(safeDigits)"

        if let cached = cache[key] {
            return cached
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = uppercasedCode
        formatter.locale = .current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = safeDigits

        cache[key] = formatter
        return formatter
    }
}

extension Decimal {
    @MainActor
    func formattedCurrency(code: String = "USD", maximumFractionDigits: Int) -> String {
        let formatter = CurrencyFormatting.formatter(
            code: code,
            maximumFractionDigits: maximumFractionDigits
        )
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "$0"
    }
    
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

extension Double {
    @MainActor
    func formattedCurrency(code: String = "USD", maximumFractionDigits: Int) -> String {
        let formatter = CurrencyFormatting.formatter(
            code: code,
            maximumFractionDigits: maximumFractionDigits
        )
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
}
