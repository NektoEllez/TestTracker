import Foundation

/// iOS 15 locale: uses legacy `Locale.languageCode` property.
struct LegacyLocaleProvider: LocaleProviding {
    func languageCode(from locale: Locale) -> String {
        locale.languageCode
            ?? locale.identifier.components(separatedBy: "_").first
            ?? locale.identifier.components(separatedBy: "-").first
            ?? "en"
    }
}
