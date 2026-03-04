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
        static let moduleDecisionType = "module_decision_type"
        static let browserConfigURL = "browser_config_url"
        static let lastBrowserURL = "last_browser_url"
        static let selectedCurrencyCode = "selected_currency_code"
        static let preferredColorScheme = "preferred_color_scheme"
    }
    
    // MARK: - Onboarding
    
    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Keys.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Keys.onboardingCompleted) }
    }
    
    // MARK: - Module Decision (from JSON)
    
    var moduleDecisionType: String? {
        get { defaults.string(forKey: Keys.moduleDecisionType) }
        set { defaults.set(newValue, forKey: Keys.moduleDecisionType) }
    }
    
    var browserConfigURL: URL? {
        get {
            guard let string = defaults.string(forKey: Keys.browserConfigURL) else { return nil }
            return URL(string: string)
        }
        set {
            defaults.set(newValue?.absoluteString, forKey: Keys.browserConfigURL)
        }
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
    
    /// Effective language from current system locale. Used when browser loads.
    var effectiveContentLanguageCode: String {
        let system = Locale.preferredLanguages.first ?? Locale.current.identifier
        let code = system.components(separatedBy: "-").first ?? system.components(separatedBy: "_").first ?? "en"
        return ContentLanguageCatalog.normalizedCode(code)
    }
    
    var preferredColorSchemeRaw: String {
        get { defaults.string(forKey: Keys.preferredColorScheme) ?? "system" }
        set { defaults.set(newValue, forKey: Keys.preferredColorScheme) }
    }
}
