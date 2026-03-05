import UIKit

/// iOS 15+ appearance provider. Applies UIUserInterfaceStyle to all connected windows.
struct LegacyAppearanceProvider: AppearanceProviding {
    func applyTheme(_ mode: ThemeMode) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = mode.uiStyle }
    }
}
