import Foundation
import WebKit

@MainActor
final class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var viewModel: WebViewModel
    weak var webView: WKWebView?
    weak var refreshControl: UIRefreshControl?
    
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
        refreshControl?.endRefreshing()
        publish { model in
            model.isLoading = false
            model.errorMessage = nil
        }
        updateNavigationState(from: webView)
        persistCurrentURL(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshControl?.endRefreshing()
        publish { model in
            model.isLoading = false
            model.errorMessage = error.localizedDescription
        }
        updateNavigationState(from: webView)
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        refreshControl?.endRefreshing()
        publish { model in
            model.isLoading = false
            model.errorMessage = error.localizedDescription
        }
        updateNavigationState(from: webView)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url,
           shouldOpenInSafari(
            url: url,
            navigationType: navigationAction.navigationType,
            isMainFrame: navigationAction.targetFrame?.isMainFrame ?? false
           ) {
            publish { model in
                model.safariDestination = WebViewModel.SafariDestination(url: url)
            }
            decisionHandler(.cancel)
            return
        }
        
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
            if shouldOpenInSafari(
                url: url,
                navigationType: navigationAction.navigationType,
                isMainFrame: false
            ) {
                publish { model in
                    model.safariDestination = WebViewModel.SafariDestination(url: url)
                }
            } else {
                webView.load(URLRequest(url: url))
            }
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
    
    /// Routes coordinator callbacks through a single MainActor hop and
    /// keeps mutation points centralized for easier state auditing.
    private func publish(_ update: @escaping (WebViewModel) -> Void) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            update(self.viewModel)
        }
    }
    
    private func shouldOpenInSafari(
        url: URL,
        navigationType: WKNavigationType,
        isMainFrame: Bool
    ) -> Bool {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            return false
        }
        guard let targetHost = url.host?.lowercased(),
              let initialHost = viewModel.initialURL.host?.lowercased() else {
            return false
        }
        guard !isSameHostOrSubdomain(targetHost, of: initialHost) else {
            return false
        }
        
        // External top-level links open in SFSafariViewController.
        // Redirect chains and non-main-frame navigations stay in WKWebView to preserve auth/session flows.
        return navigationType == .linkActivated || !isMainFrame
    }
    
    private func isSameHostOrSubdomain(_ host: String, of baseHost: String) -> Bool {
        host == baseHost || host.hasSuffix("." + baseHost)
    }
}
