import UIKit

/// iOS 15 orientation lock: uses legacy KVC on UIDevice.
struct LegacyOrientationProvider: OrientationProviding {
    func lockPortrait() {
        UIDevice.current.setValue(
            UIInterfaceOrientation.portrait.rawValue,
            forKey: "orientation"
        )
    }
}
