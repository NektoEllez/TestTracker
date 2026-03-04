import SwiftUI

@main
struct FinanceTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var toastStore = ToastStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.toastStore, toastStore)
                .toastOverlay(alignment: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackgroundGradient.ignoresSafeArea())
        }
    }
}
