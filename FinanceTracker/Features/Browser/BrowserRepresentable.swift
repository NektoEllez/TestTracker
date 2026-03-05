import SwiftUI
import WebKit
import UIKit

struct BrowserRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: BrowserViewModel
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
        applyAppearance(to: browser)
        
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
        applyAppearance(to: uiView)
        guard uiView.url != viewModel.currentURL else { return }
        uiView.load(URLRequest(url: viewModel.currentURL))
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: BrowserCoordinator) {
        coordinator.cleanup()
    }

    private func applyAppearance(to browser: WKWebView) {
        if #available(iOS 17.0, *) {
            let style: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
            browser.overrideUserInterfaceStyle = style
            browser.backgroundColor = .systemBackground
            browser.scrollView.backgroundColor = .systemBackground
        } else {
            let style: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
            browser.overrideUserInterfaceStyle = style
            browser.backgroundColor = UIColor { trait in
                trait.userInterfaceStyle == .dark ? .black : .white
            }
            browser.scrollView.backgroundColor = UIColor { trait in
                trait.userInterfaceStyle == .dark ? .black : .white
            }
        }
    }
}
