import Foundation

/// Central factory that selects platform-specific implementations
/// based on the OS version. Called once at app startup.
@MainActor
enum PlatformResolver {

    /// Appearance provider for applying themes to UIKit windows.
    static func makeAppearanceProvider() -> any AppearanceProviding {
        if #available(iOS 16.0, *) {
            return ModernAppearanceProvider()
        } else {
            return LegacyAppearanceProvider()
        }
    }

    /// Browser appearance provider for WKWebView color scheme.
    static func makeBrowserAppearanceProvider() -> any BrowserAppearanceProviding {
        if #available(iOS 16.0, *) {
            return ModernBrowserAppearanceProvider()
        } else {
            return LegacyBrowserAppearanceProvider()
        }
    }

    /// Orientation provider for portrait lock behavior.
    static func makeOrientationProvider() -> any OrientationProviding {
        if #available(iOS 16.0, *) {
            return ModernOrientationProvider()
        } else {
            return LegacyOrientationProvider()
        }
    }

    /// Locale provider for language code extraction.
    static func makeLocaleProvider() -> any LocaleProviding {
        if #available(iOS 16.0, *) {
            return ModernLocaleProvider()
        } else {
            return LegacyLocaleProvider()
        }
    }
}
