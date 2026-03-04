import Foundation
import WebKit

@MainActor
final class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var viewModel: WebViewModel
    weak var webView: WKWebView?

    private var progressObservation: NSKeyValueObservation?

    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
    }

    func configure(_ webView: WKWebView) {
        self.webView = webView

        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            let progress = webView.estimatedProgress
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.viewModel.estimatedProgress != progress else { return }
                self.viewModel.estimatedProgress = progress
            }
        }
    }

    func cleanup() {
        progressObservation = nil
        webView = nil
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        publish { model in
            model.isLoading = true
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        publish { model in
            model.isLoading = false
        }
        updateNavigationState(from: webView)
        persistCurrentURL(from: webView)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        publish { model in
            model.isLoading = false
        }
        updateNavigationState(from: webView)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        publish { model in
            model.isLoading = false
        }
        updateNavigationState(from: webView)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }

    // MARK: - WKUIDelegate

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(.prompt)
    }

    // MARK: - Actions

    @objc func handleRefresh(_ sender: UIRefreshControl) {
        webView?.reload()
        sender.endRefreshing()
    }

    private func updateNavigationState(from webView: WKWebView) {
        let canGoBack = webView.canGoBack
        let canGoForward = webView.canGoForward

        publish { model in
            model.canGoBack = canGoBack
            model.canGoForward = canGoForward
        }
    }

    private func persistCurrentURL(from webView: WKWebView) {
        guard let url = webView.url else { return }

        publish { model in
            guard model.currentURL != url else { return }
            model.currentURL = url
            model.saveCurrentURL()
        }
    }

    private func publish(_ update: @escaping (WebViewModel) -> Void) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            update(self.viewModel)
        }
    }
}
