import Foundation

/// iOS 16+ locale: uses modern `Locale.language.languageCode` API
/// with fallback to legacy property.
struct ModernLocaleProvider: LocaleProviding {
    func languageCode(from locale: Locale) -> String {
        if #available(iOS 16.0, *) {
            return locale.language.languageCode?.identifier
                ?? locale.languageCode
                ?? "en"
        }
        // Unreachable when resolver picks this provider correctly,
        // but keeps the compiler happy.
        return locale.languageCode ?? "en"
    }
}
