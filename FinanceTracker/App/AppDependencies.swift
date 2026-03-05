import Foundation

@MainActor
final class AppDependencies {
    let storageManager: AppStorageManager
    let configService: ConfigServiceProtocol
    let orientationManager: OrientationManager
    let themeSettings: ThemeSettings
    let toastStore: ToastStore
    let browserAppearanceProvider: any BrowserAppearanceProviding
    let localeProvider: any LocaleProviding

    init(
        storageManager: AppStorageManager,
        configService: ConfigServiceProtocol,
        orientationManager: OrientationManager,
        themeSettings: ThemeSettings,
        toastStore: ToastStore,
        browserAppearanceProvider: any BrowserAppearanceProviding,
        localeProvider: any LocaleProviding
    ) {
        self.storageManager = storageManager
        self.configService = configService
        self.orientationManager = orientationManager
        self.themeSettings = themeSettings
        self.toastStore = toastStore
        self.browserAppearanceProvider = browserAppearanceProvider
        self.localeProvider = localeProvider

        self.themeSettings.appearanceProvider = PlatformResolver.makeAppearanceProvider()
        self.themeSettings.applyCurrentTheme()
        self.orientationManager.orientationProvider = PlatformResolver.makeOrientationProvider()
    }

    static func makeDefault() -> AppDependencies {
        AppDependencies(
            storageManager: .shared,
            configService: ConfigService(),
            orientationManager: .shared,
            themeSettings: .shared,
            toastStore: ToastStore(),
            browserAppearanceProvider: PlatformResolver.makeBrowserAppearanceProvider(),
            localeProvider: PlatformResolver.makeLocaleProvider()
        )
    }
}
