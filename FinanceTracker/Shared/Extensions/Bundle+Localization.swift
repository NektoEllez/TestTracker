import Foundation

extension Bundle {
    /// Returns localized string for the given key using the specified locale.
    /// Falls back to the key if no translation is found.
    func localizedString(for key: String, locale: Locale, table: String? = nil) -> String {
        let langCode = locale.normalizedLanguageCode
        guard let path = path(forResource: langCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return localizedString(forKey: key, value: key, table: table)
        }
        return bundle.localizedString(forKey: key, value: key, table: table)
    }
}

private extension Locale {
    var normalizedLanguageCode: String {
        if #available(iOS 16.0, *) {
            return language.languageCode?.identifier
            ?? languageCode
            ?? "en"
        }

        return languageCode
        ?? identifier.components(separatedBy: "_").first
        ?? identifier.components(separatedBy: "-").first
        ?? "en"
    }
}
