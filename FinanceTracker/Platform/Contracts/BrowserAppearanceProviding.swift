import UIKit
import WebKit
import SwiftUI

/// Abstraction for applying color scheme appearance to WKWebView.
/// Handles iOS-version differences in dynamic color resolution.
@MainActor
protocol BrowserAppearanceProviding: Sendable {
    /// Applies the color scheme to a WKWebView (overrideUserInterfaceStyle + background colors).
    func applyAppearance(to webView: WKWebView, colorScheme: ColorScheme)
}
