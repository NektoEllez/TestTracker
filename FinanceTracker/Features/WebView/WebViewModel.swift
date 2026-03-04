import Foundation
import Combine
import WebKit

@MainActor
class WebViewModel: ObservableObject {
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
        let resolvedLanguageCode = WebLanguageCatalog.normalizedCode(
            AppStorageManager.shared.selectedWebLanguageCode
        )
        self.selectedLanguageCode = resolvedLanguageCode
        self.initialURL = initialURL

        // Restore last visited URL or use initial
        let baseURL = AppStorageManager.shared.lastWebViewURL ?? initialURL
        self.currentURL = WebViewModel.applyingLanguage(code: resolvedLanguageCode, to: baseURL)
    }

    func saveCurrentURL() {
        AppStorageManager.shared.lastWebViewURL = currentURL
    }

    func selectLanguage(_ code: String) {
        let normalized = WebLanguageCatalog.normalizedCode(code)
        guard selectedLanguageCode != normalized else { return }

        selectedLanguageCode = normalized
        AppStorageManager.shared.selectedWebLanguageCode = normalized

        let updatedURL = Self.applyingLanguage(code: normalized, to: currentURL)
        guard updatedURL != currentURL else { return }
        currentURL = updatedURL
    }

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
}
