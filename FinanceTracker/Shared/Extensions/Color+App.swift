import SwiftUI

extension Color {
    static let appBackground = Color(
        UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.06, green: 0.10, blue: 0.12, alpha: 1)
            }
            return UIColor(red: 0.94, green: 0.96, blue: 0.96, alpha: 1)
        }
    )
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let appGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let appRed = Color(red: 0.95, green: 0.3, blue: 0.3)
    static let appBlue = Color(red: 0.2, green: 0.5, blue: 0.95)
    static let appAccent = Color(red: 0.35, green: 0.45, blue: 0.95)
    static var appBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(
                    UIColor { trait in
                        if trait.userInterfaceStyle == .dark {
                            return UIColor(red: 0.05, green: 0.09, blue: 0.11, alpha: 1)
                        }
                        return UIColor(red: 0.95, green: 0.96, blue: 0.95, alpha: 1)
                    }
                ),
                Color(
                    UIColor { trait in
                        if trait.userInterfaceStyle == .dark {
                            return UIColor(red: 0.08, green: 0.16, blue: 0.18, alpha: 1)
                        }
                        return UIColor(red: 0.87, green: 0.94, blue: 0.93, alpha: 1)
                    }
                ),
                Color(
                    UIColor { trait in
                        if trait.userInterfaceStyle == .dark {
                            return UIColor(red: 0.10, green: 0.22, blue: 0.24, alpha: 1)
                        }
                        return UIColor(red: 0.80, green: 0.90, blue: 0.90, alpha: 1)
                    }
                )
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
