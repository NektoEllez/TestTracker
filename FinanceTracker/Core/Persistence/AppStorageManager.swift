import Foundation

/// Wrapper around UserDefaults for app-level flags and small values.
@MainActor
final class AppStorageManager {
    static let shared = AppStorageManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys
    
    private enum Keys {
        static let onboardingCompleted = "onboarding_completed"
        static let lastBrowserURL = "last_browser_url"
        static let selectedCurrencyCode = "selected_currency_code"
        static let selectedContentLanguageCode = "selected_content_language_code"
        static let preferredColorScheme = "preferred_color_scheme"
    }
    
    // MARK: - Onboarding
    
    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Keys.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Keys.onboardingCompleted) }
    }
    
    // MARK: - Browser Last URL
    
    var lastBrowserURL: URL? {
        get {
            guard let string = defaults.string(forKey: Keys.lastBrowserURL) else { return nil }
            return URL(string: string)
        }
        set {
            defaults.set(newValue?.absoluteString, forKey: Keys.lastBrowserURL)
        }
    }
    
    // MARK: - Currency
    
    var selectedCurrencyCode: String {
        get { defaults.string(forKey: Keys.selectedCurrencyCode) ?? "USD" }
        set { defaults.set(newValue, forKey: Keys.selectedCurrencyCode) }
    }
    
    // MARK: - Content Language
    
    var selectedContentLanguageCode: String {
        get { defaults.string(forKey: Keys.selectedContentLanguageCode) ?? "en" }
        set { defaults.set(newValue, forKey: Keys.selectedContentLanguageCode) }
    }
    
    var preferredColorSchemeRaw: String {
        get { defaults.string(forKey: Keys.preferredColorScheme) ?? "system" }
        set { defaults.set(newValue, forKey: Keys.preferredColorScheme) }
    }
}
