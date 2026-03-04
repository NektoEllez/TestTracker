import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let code: String
    let name: String
    
    var id: String { code }
    
    var title: String {
        "\(code) • \(name)"
    }
}

enum CurrencyCatalog {
    static let popular: [CurrencyOption] = [
        CurrencyOption(code: "USD", name: "US Dollar"),
        CurrencyOption(code: "EUR", name: "Euro"),
        CurrencyOption(code: "GBP", name: "British Pound"),
        CurrencyOption(code: "JPY", name: "Japanese Yen"),
        CurrencyOption(code: "CNY", name: "Chinese Yuan"),
        CurrencyOption(code: "RUB", name: "Russian Ruble"),
        CurrencyOption(code: "UAH", name: "Ukrainian Hryvnia"),
        CurrencyOption(code: "KZT", name: "Kazakhstani Tenge"),
        CurrencyOption(code: "TRY", name: "Turkish Lira"),
        CurrencyOption(code: "AED", name: "UAE Dirham")
    ]
    
    static func isSupported(_ code: String) -> Bool {
        popular.contains { $0.code == code }
    }
    
    static func normalizedCode(_ code: String) -> String {
        let uppercaseCode = code.uppercased()
        return isSupported(uppercaseCode) ? uppercaseCode : "USD"
    }
    
    static func displayName(for code: String) -> String {
        popular.first(where: { $0.code == code })?.title ?? code
    }
}
