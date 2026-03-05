import UIKit

/// iOS 16+ appearance provider. Same window override approach (no API change here),
/// but kept as a separate type so the resolver decides once at startup.
struct ModernAppearanceProvider: AppearanceProviding {
    func applyTheme(_ mode: ThemeMode) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = mode.uiStyle }
    }
}
