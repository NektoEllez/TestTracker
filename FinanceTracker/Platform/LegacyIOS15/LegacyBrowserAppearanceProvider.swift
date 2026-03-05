import UIKit
import WebKit
import SwiftUI

/// iOS 15-16 browser appearance: manual UIColor trait resolution for dynamic colors.
struct LegacyBrowserAppearanceProvider: BrowserAppearanceProviding {
    func applyAppearance(to webView: WKWebView, colorScheme: ColorScheme) {
        let style: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        webView.overrideUserInterfaceStyle = style

        let bgColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .black : .white
        }
        webView.backgroundColor = bgColor
        webView.scrollView.backgroundColor = bgColor
    }
}
