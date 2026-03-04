import UIKit

@MainActor
final class OrientationManager {
    static let shared = OrientationManager()
    
    var orientationLock: UIInterfaceOrientationMask = .portrait
    
    private init() {}
    
    func lockPortrait() {
        orientationLock = .portrait
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    func unlockAll() {
        orientationLock = .allButUpsideDown
    }
}
