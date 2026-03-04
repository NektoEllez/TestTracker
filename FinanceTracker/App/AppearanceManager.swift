import UIKit

enum AppearanceManager {
    @MainActor
    static func apply(rawValue: String) {
        let style: UIUserInterfaceStyle
        switch rawValue {
            case "light":
                style = .light
            case "dark":
                style = .dark
            default:
                style = .unspecified
        }
        
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}
