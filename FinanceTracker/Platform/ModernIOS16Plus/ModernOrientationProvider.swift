import UIKit

/// iOS 16+ orientation lock: uses Scene geometry update API.
@available(iOS 16.0, *)
struct ModernOrientationProvider: OrientationProviding {
    func lockPortrait() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
    }
}
