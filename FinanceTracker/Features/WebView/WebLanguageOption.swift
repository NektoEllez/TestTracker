import Foundation

struct WebLanguageOption: Identifiable, Equatable, Sendable {
    let code: String
    let title: String
    let flag: String

    var id: String { code }
    var shortLabel: String { code.prefix(1).uppercased() + code.dropFirst() }
}

enum WebLanguageCatalog {
    static let supported: [WebLanguageOption] = [
        WebLanguageOption(code: "en", title: "English", flag: "🇬🇧"),
        WebLanguageOption(code: "ru", title: "Russian", flag: "🇷🇺"),
        WebLanguageOption(code: "az", title: "Azerbaijani", flag: "🇦🇿"),
        WebLanguageOption(code: "de", title: "German", flag: "🇩🇪"),
        WebLanguageOption(code: "es", title: "Spanish", flag: "🇪🇸")
    ]

    static func normalizedCode(_ code: String) -> String {
        let normalized = code.lowercased()
        return supported.contains(where: { $0.code == normalized }) ? normalized : "en"
    }

    static func option(for code: String) -> WebLanguageOption {
        let normalized = normalizedCode(code)
        return supported.first(where: { $0.code == normalized }) ?? supported[0]
    }
}
