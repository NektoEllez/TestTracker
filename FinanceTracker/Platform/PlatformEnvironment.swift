import SwiftUI

// MARK: - Appearance Provider

private struct AppearanceProviderKey: EnvironmentKey {
    @MainActor static let defaultValue: (any AppearanceProviding)? = nil
}

extension EnvironmentValues {
    var appearanceProvider: (any AppearanceProviding)? {
        get { self[AppearanceProviderKey.self] }
        set { self[AppearanceProviderKey.self] = newValue }
    }
}

// MARK: - Browser Appearance Provider

private struct BrowserAppearanceProviderKey: EnvironmentKey {
    @MainActor static let defaultValue: (any BrowserAppearanceProviding)? = nil
}

extension EnvironmentValues {
    var browserAppearanceProvider: (any BrowserAppearanceProviding)? {
        get { self[BrowserAppearanceProviderKey.self] }
        set { self[BrowserAppearanceProviderKey.self] = newValue }
    }
}

// MARK: - Orientation Provider

private struct OrientationProviderKey: EnvironmentKey {
    @MainActor static let defaultValue: (any OrientationProviding)? = nil
}

extension EnvironmentValues {
    var orientationProvider: (any OrientationProviding)? {
        get { self[OrientationProviderKey.self] }
        set { self[OrientationProviderKey.self] = newValue }
    }
}

// MARK: - Locale Provider

private struct LocaleProviderKey: EnvironmentKey {
    @MainActor static let defaultValue: (any LocaleProviding)? = nil
}

extension EnvironmentValues {
    var localeProvider: (any LocaleProviding)? {
        get { self[LocaleProviderKey.self] }
        set { self[LocaleProviderKey.self] = newValue }
    }
}
