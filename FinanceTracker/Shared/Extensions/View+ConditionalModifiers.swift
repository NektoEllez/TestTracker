import SwiftUI

extension View {
    /// Applies a transform to the current view.
    func apply<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
