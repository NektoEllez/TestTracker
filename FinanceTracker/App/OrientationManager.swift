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
        UINavigationController.attemptRotationToDeviceOrientation()
    }

    func unlockAll() {
        orientationLock = .allButUpsideDown
    }
}
