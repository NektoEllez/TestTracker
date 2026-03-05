import UIKit

/// Abstraction for applying app-wide appearance (theme) to UIKit windows.
/// Implementations handle iOS-version-specific APIs.
@MainActor
protocol AppearanceProviding: Sendable {
    /// Applies the given theme mode to all connected window scenes.
    func applyTheme(_ mode: ThemeMode)
}

enum ThemeMode: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    var uiStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
