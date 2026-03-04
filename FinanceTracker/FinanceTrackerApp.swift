import SwiftUI

@main
struct FinanceTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var toastStore = ToastStore()
    @AppStorage("preferred_color_scheme") private var preferredColorSchemeRaw = "system"

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.toastStore, toastStore)
                .toastOverlay(alignment: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackgroundGradient.ignoresSafeArea())
                .preferredColorScheme(mappedColorScheme)
        }
    }

    private var mappedColorScheme: ColorScheme? {
        switch preferredColorSchemeRaw {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}
