import Foundation

/// Wrapper around UserDefaults for app-level flags and small values
@MainActor
final class AppStorageManager {
    static let shared = AppStorageManager()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Keys

    private enum Keys {
        static let onboardingCompleted = "onboarding_completed"
        static let lastWebViewURL = "last_webview_url"
        static let selectedCurrencyCode = "selected_currency_code"
    }

    // MARK: - Onboarding

    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Keys.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Keys.onboardingCompleted) }
    }

    // MARK: - WebView Last URL

    var lastWebViewURL: URL? {
        get {
            guard let string = defaults.string(forKey: Keys.lastWebViewURL) else { return nil }
            return URL(string: string)
        }
        set {
            defaults.set(newValue?.absoluteString, forKey: Keys.lastWebViewURL)
        }
    }

    // MARK: - Currency

    var selectedCurrencyCode: String {
        get { defaults.string(forKey: Keys.selectedCurrencyCode) ?? "USD" }
        set { defaults.set(newValue, forKey: Keys.selectedCurrencyCode) }
    }
}
