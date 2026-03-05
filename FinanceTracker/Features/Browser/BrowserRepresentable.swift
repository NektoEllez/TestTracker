import SwiftUI
import WebKit
import UIKit

struct BrowserRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: BrowserViewModel
    @Environment(\.browserAppearanceProvider) private var appearanceProvider
    let colorScheme: ColorScheme
    var onFallbackToFinance: (() -> Void)?

    func makeCoordinator() -> BrowserCoordinator {
        BrowserCoordinator(viewModel: viewModel, onFallbackToFinance: onFallbackToFinance)
    }

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.websiteDataStore = WKWebsiteDataStore.default()

        let browser = WKWebView(frame: .zero, configuration: configuration)
        browser.scrollView.contentInsetAdjustmentBehavior = .never
        browser.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        browser.isOpaque = false
        appearanceProvider?.applyAppearance(to: browser, colorScheme: colorScheme)

        browser.navigationDelegate = context.coordinator
        browser.uiDelegate = context.coordinator
        browser.allowsBackForwardNavigationGestures = true

        context.coordinator.configure(browser)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(BrowserCoordinator.handleRefresh(_:)),
            for: .valueChanged
        )
        browser.scrollView.refreshControl = refreshControl
        context.coordinator.refreshControl = refreshControl

        browser.load(URLRequest(url: viewModel.currentURL))

        return browser
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        appearanceProvider?.applyAppearance(to: uiView, colorScheme: colorScheme)
        guard uiView.url != viewModel.currentURL else { return }
        uiView.load(URLRequest(url: viewModel.currentURL))
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: BrowserCoordinator) {
        coordinator.cleanup()
    }
}
