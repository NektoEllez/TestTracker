import Foundation

struct ContentLanguageOption: Identifiable, Equatable, Sendable {
    let code: String
    let title: String
    let flag: String
    
    var id: String { code }
    var shortLabel: String { code.prefix(1).uppercased() + code.dropFirst() }
}

enum ContentLanguageCatalog {
    static let supported: [ContentLanguageOption] = [
        ContentLanguageOption(code: "en", title: "English", flag: "🇬🇧"),
        ContentLanguageOption(code: "ru", title: "Russian", flag: "🇷🇺"),
        ContentLanguageOption(code: "az", title: "Azerbaijani", flag: "🇦🇿"),
        ContentLanguageOption(code: "de", title: "German", flag: "🇩🇪"),
        ContentLanguageOption(code: "es", title: "Spanish", flag: "🇪🇸")
    ]
    
    static func normalizedCode(_ code: String) -> String {
        let normalized = code.lowercased()
        return supported.contains(where: { $0.code == normalized }) ? normalized : "en"
    }
    
    static func option(for code: String) -> ContentLanguageOption {
        let normalized = normalizedCode(code)
        return supported.first(where: { $0.code == normalized }) ?? supported[0]
    }
}
