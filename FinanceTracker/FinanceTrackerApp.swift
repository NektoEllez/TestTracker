import SwiftUI

@MainActor
@main
struct FinanceTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let dependencies: AppDependencies
    @AppStorage("selected_content_language_code") private var selectedLanguageCode = "en"

    init() {
        dependencies = AppDependencies.makeDefault()
    }

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
                .environmentObject(dependencies.themeSettings)
                .environment(\.locale, Locale(identifier: selectedLanguageCode))
                .id(selectedLanguageCode)
                .environment(\.toastStore, dependencies.toastStore)
                .environment(\.browserAppearanceProvider, dependencies.browserAppearanceProvider)
                .environment(\.localeProvider, dependencies.localeProvider)
                .toastOverlay(alignment: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackgroundGradient.ignoresSafeArea())
                .preferredColorScheme(dependencies.themeSettings.colorScheme)
        }
    }
}
