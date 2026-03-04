import Foundation
import Combine
import WebKit

@MainActor
class BrowserViewModel: ObservableObject {
    struct SafariDestination: Identifiable, Equatable {
        let url: URL
        var id: String { url.absoluteString }
    }
    
    @Published var currentURL: URL
    @Published var isLoading: Bool = true
    @Published var estimatedProgress: Double = 0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var errorMessage: String?
    @Published var safariDestination: SafariDestination?
    @Published var selectedLanguageCode: String
    
    let initialURL: URL
    
    init(initialURL: URL) {
        let resolvedLanguageCode = Self.systemLanguageCode()
        self.selectedLanguageCode = resolvedLanguageCode
        self.initialURL = initialURL
        
        // Resume from last successful page when available, then enforce selected language.
        let baseURL = AppStorageManager.shared.lastBrowserURL ?? initialURL
        self.currentURL = BrowserViewModel.applyingLanguage(code: resolvedLanguageCode, to: baseURL)
    }
    
    func saveCurrentURL() {
        AppStorageManager.shared.lastBrowserURL = currentURL
    }
    
    func selectLanguage(_ code: String) {
        let normalized = ContentLanguageCatalog.normalizedCode(code)
        guard selectedLanguageCode != normalized else { return }
        
        selectedLanguageCode = normalized
        
        let updatedURL = Self.applyingLanguage(code: normalized, to: currentURL)
        guard updatedURL != currentURL else { return }
        currentURL = updatedURL
    }

    func syncWithSystemLanguage() {
        let systemCode = Self.systemLanguageCode()
        guard selectedLanguageCode != systemCode else { return }
        selectedLanguageCode = systemCode
        let updatedURL = Self.applyingLanguage(code: systemCode, to: currentURL)
        guard updatedURL != currentURL else { return }
        currentURL = updatedURL
    }
    
    /// Updates existing `lang` query item or appends it when missing.
    private static func applyingLanguage(code: String, to url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        
        var items = components.queryItems ?? []
        if let index = items.firstIndex(where: { $0.name.lowercased() == "lang" }) {
            items[index].value = code
        } else {
            items.append(URLQueryItem(name: "lang", value: code))
        }
        components.queryItems = items
        
        return components.url ?? url
    }

    private static func systemLanguageCode() -> String {
        let preferredIdentifier = Locale.preferredLanguages.first ?? Locale.current.identifier
        let locale = Locale(identifier: preferredIdentifier)
        let rawCode = locale.languageCode
            ?? preferredIdentifier.components(separatedBy: "-").first
            ?? preferredIdentifier.components(separatedBy: "_").first
            ?? "en"
        return ContentLanguageCatalog.normalizedCode(rawCode)
    }
}
