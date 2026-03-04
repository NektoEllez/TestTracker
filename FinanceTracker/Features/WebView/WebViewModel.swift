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

    let initialURL: URL

    init(initialURL: URL) {
        // Restore last visited URL or use initial
        if let lastURL = AppStorageManager.shared.lastWebViewURL {
            self.currentURL = lastURL
        } else {
            self.currentURL = initialURL
        }
        self.initialURL = initialURL
    }

    func saveCurrentURL() {
        AppStorageManager.shared.lastWebViewURL = currentURL
    }
}
