import UIKit

/// iOS 15 orientation lock fallback.
/// Avoids private API usage that can trigger App Store rejection.
struct LegacyOrientationProvider: OrientationProviding {
    func lockPortrait() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        if #available(iOS 16.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }
}
