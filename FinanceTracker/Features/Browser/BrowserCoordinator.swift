import Foundation
import UIKit
import WebKit

@MainActor
final class BrowserCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var viewModel: BrowserViewModel
    var onFallbackToFinance: (() -> Void)?
    weak var browser: WKWebView?
    weak var refreshControl: UIRefreshControl?
    
    private var progressObservation: NSKeyValueObservation?
    private weak var backSwipeGesture: UISwipeGestureRecognizer?
    private weak var forwardSwipeGesture: UISwipeGestureRecognizer?
    private var lastRefreshTime: CFAbsoluteTime = 0
    private let throttleInterval: CFAbsoluteTime = 2.5

    init(viewModel: BrowserViewModel, onFallbackToFinance: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onFallbackToFinance = onFallbackToFinance
    }
    
    func configure(_ wkView: WKWebView) {
        self.browser = wkView
        
        progressObservation = wkView.observe(\.estimatedProgress, options: [.new]) { [weak self] wkView, _ in
            let progress = wkView.estimatedProgress
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.viewModel.estimatedProgress != progress else { return }
                self.viewModel.estimatedProgress = progress
            }
        }

        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleBackSwipe))
        backSwipe.direction = .right
        backSwipe.cancelsTouchesInView = false
        backSwipe.numberOfTouchesRequired = 1
        wkView.addGestureRecognizer(backSwipe)
        backSwipeGesture = backSwipe

        let forwardSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleForwardSwipe))
        forwardSwipe.direction = .left
        forwardSwipe.cancelsTouchesInView = false
        forwardSwipe.numberOfTouchesRequired = 1
        wkView.addGestureRecognizer(forwardSwipe)
        forwardSwipeGesture = forwardSwipe
    }
    
    func cleanup() {
        progressObservation = nil
        browser = nil
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ browser: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        publish { model in
            model.isLoading = true
        }
    }
    
    func webView(_ browser: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl?.endRefreshing()
        publish { model in
            model.isLoading = false
            model.errorMessage = nil
        }
        updateNavigationState(from: browser)
        persistCurrentURL(from: browser)
        checkForAccessRestrictedPage(in: browser)
    }
    
    func webView(_ browser: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshControl?.endRefreshing()
        publish { model in
            model.isLoading = false
            model.errorMessage = error.localizedDescription
            model.shouldFallbackToFinance = true
        }
        updateNavigationState(from: browser)
    }
    
    func webView(
        _ browser: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        refreshControl?.endRefreshing()
        publish { model in
            model.isLoading = false
            model.errorMessage = error.localizedDescription
            model.shouldFallbackToFinance = true
        }
        updateNavigationState(from: browser)
    }
    
    func webView(
        _ browser: WKWebView,
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
                model.safariDestination = BrowserViewModel.SafariDestination(url: url)
            }
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    // MARK: - WKUIDelegate
    
    func webView(
        _ browser: WKWebView,
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
                    model.safariDestination = BrowserViewModel.SafariDestination(url: url)
                }
            } else {
                browser.load(URLRequest(url: url))
            }
        }
        return nil
    }
    
    @available(iOS 15.0, *)
    func webView(
        _ browser: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(.prompt)
    }
    
    // MARK: - Actions
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastRefreshTime < throttleInterval {
            refreshControl?.endRefreshing()
            return
        }
        lastRefreshTime = now
        browser?.reload()
    }

    @objc private func handleBackSwipe() {
        guard let browser, browser.canGoBack else { return }
        browser.goBack()
    }

    @objc private func handleForwardSwipe() {
        guard let browser, browser.canGoForward else { return }
        browser.goForward()
    }
    
    private func updateNavigationState(from browser: WKWebView) {
        let canGoBack = browser.canGoBack
        let canGoForward = browser.canGoForward
        
        publish { model in
            model.canGoBack = canGoBack
            model.canGoForward = canGoForward
        }
    }
    
    private func persistCurrentURL(from browser: WKWebView) {
        guard let url = browser.url else { return }
        
        publish { model in
            guard model.currentURL != url else { return }
            model.currentURL = url
            model.saveCurrentURL()
        }
    }
    
    /// Centralized state mutation entrypoint for coordinator callbacks.
    private func publish(_ update: (BrowserViewModel) -> Void) {
        update(viewModel)
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
        // Redirect chains and non-main-frame navigations stay in WKWebView (system API) to preserve auth/session flows.
        return navigationType == .linkActivated || !isMainFrame
    }
    
    private func isSameHostOrSubdomain(_ host: String, of baseHost: String) -> Bool {
        host == baseHost || host.hasSuffix("." + baseHost)
    }

    private func checkForAccessRestrictedPage(in browser: WKWebView) {
        let script = "document.body?.innerText?.toLowerCase() ?? ''"
        browser.evaluateJavaScript(script) { [weak self] result, _ in
            Task { @MainActor in
                guard let self else { return }
                guard let text = result as? String else { return }
                let lower = text.lowercased()
                if lower.contains("доступ ограничен") || lower.contains("access restricted") {
                    self.publish { $0.shouldFallbackToFinance = true }
                }
            }
        }
    }
}
