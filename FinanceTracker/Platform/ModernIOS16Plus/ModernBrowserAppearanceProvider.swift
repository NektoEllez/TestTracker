import UIKit
import WebKit
import SwiftUI

/// iOS 17+ browser appearance: uses `.systemBackground` directly.
/// Falls back to iOS 16 manual trait resolution when running on iOS 16.
struct ModernBrowserAppearanceProvider: BrowserAppearanceProviding {
    func applyAppearance(to webView: WKWebView, colorScheme: ColorScheme) {
        let style: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        webView.overrideUserInterfaceStyle = style

        if #available(iOS 17.0, *) {
            webView.backgroundColor = .systemBackground
            webView.scrollView.backgroundColor = .systemBackground
        } else {
            // iOS 16: manual trait resolution (same as legacy but kept in modern layer)
            let bgColor = UIColor { trait in
                trait.userInterfaceStyle == .dark ? .black : .white
            }
            webView.backgroundColor = bgColor
            webView.scrollView.backgroundColor = bgColor
        }
    }
}
