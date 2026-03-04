import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.websiteDataStore = WKWebsiteDataStore.default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        context.coordinator.configure(webView)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(WebViewCoordinator.handleRefresh(_:)),
            for: .valueChanged
        )
        webView.scrollView.refreshControl = refreshControl

        webView.load(URLRequest(url: viewModel.currentURL))

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard uiView.url != viewModel.currentURL else { return }
        uiView.load(URLRequest(url: viewModel.currentURL))
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: WebViewCoordinator) {
        coordinator.cleanup()
    }
}
