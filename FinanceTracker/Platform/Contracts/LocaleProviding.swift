import Foundation

/// Abstraction for extracting language code from a Locale.
/// iOS 16+ uses Locale.language.languageCode; iOS 15 uses legacy languageCode.
protocol LocaleProviding: Sendable {
    /// Returns normalized language code string from the given locale (e.g. "en", "ru", "de").
    func languageCode(from locale: Locale) -> String
}
