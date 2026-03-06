import Foundation

extension Bundle {
    /// Returns localized string for the given key using the specified locale.
    /// Falls back to the key if no translation is found.
    /// Uses `LocaleProviding` from the platform layer for language code extraction.
    func localizedString(
        for key: String,
        locale: Locale,
        table: String? = nil,
        localeProvider: (any LocaleProviding)? = nil
    ) -> String {
        let langCode: String
        if let localeProvider {
            langCode = localeProvider.languageCode(from: locale)
        } else {
            langCode = locale.languageCode
                ?? locale.identifier.components(separatedBy: "-").first
                ?? locale.identifier.components(separatedBy: "_").first
                ?? "en"
        }
        guard let path = path(forResource: langCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return localizedString(forKey: key, value: key, table: table)
        }
        return bundle.localizedString(forKey: key, value: key, table: table)
    }
}
