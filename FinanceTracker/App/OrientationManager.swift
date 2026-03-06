import UIKit

@MainActor
final class OrientationManager {
    static let shared = OrientationManager()

    var orientationLock: UIInterfaceOrientationMask = .portrait

    /// Injected by the app at startup via `PlatformResolver`.
    var orientationProvider: (any OrientationProviding)?

    private init() {}

    func lockPortrait() {
        orientationLock = .portrait
        orientationProvider?.lockPortrait()
        refreshSupportedOrientations()
    }

    func unlockAll() {
        orientationLock = .allButUpsideDown
        refreshSupportedOrientations()
    }

    private func refreshSupportedOrientations() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.keyWindow?.rootViewController {
            if #available(iOS 16.0, *) {
                rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
