import SwiftUI
import Combine

/// Single source of truth for app theme.
/// Persists preference to UserDefaults, applies to UIKit windows
/// via the injected `AppearanceProviding` implementation, and
/// exposes `colorScheme` for SwiftUI's `.preferredColorScheme()`.
@MainActor
final class ThemeSettings: ObservableObject {

    static let shared = ThemeSettings()

    @Published private(set) var mode: ThemeMode

    /// SwiftUI color scheme derived from current mode.
    var colorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    /// Injected by the app at startup via `PlatformResolver`.
    var appearanceProvider: (any AppearanceProviding)?

    private let defaults: UserDefaults
    private let storageKey = "preferred_color_scheme"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedMode = defaults.string(forKey: storageKey)
        self.mode = ThemeMode(rawValue: storedMode ?? "") ?? .system
    }

    /// Call after injecting the appearance provider to apply the persisted theme.
    func applyCurrentTheme() {
        appearanceProvider?.applyTheme(mode)
    }

    /// Updates theme with persistence and immediate UIKit bridge.
    func updateMode(_ newMode: ThemeMode) {
        guard mode != newMode else { return }
        mode = newMode
        defaults.set(newMode.rawValue, forKey: storageKey)
        appearanceProvider?.applyTheme(newMode)
    }

    /// Convenient binding for SwiftUI pickers, keeps side effects centralized.
    var modeBinding: Binding<ThemeMode> {
        Binding(
            get: { self.mode },
            set: { [weak self] in self?.updateMode($0) }
        )
    }
}
