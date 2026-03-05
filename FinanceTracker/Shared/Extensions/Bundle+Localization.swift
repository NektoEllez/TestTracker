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
        let provider = localeProvider ?? PlatformResolver.makeLocaleProvider()
        let langCode = provider.languageCode(from: locale)
        guard let path = path(forResource: langCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return localizedString(forKey: key, value: key, table: table)
        }
        return bundle.localizedString(forKey: key, value: key, table: table)
    }
}
