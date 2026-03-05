import UIKit

/// Abstraction for orientation management.
/// iOS 16+ uses requestGeometryUpdate; iOS 15 uses legacy KVC.
@MainActor
protocol OrientationProviding: Sendable {
    /// Forces the device into portrait orientation.
    func lockPortrait()
}
