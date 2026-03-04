import SwiftUI

enum AppGlassStyle {
    case regular
    case interactive
}

extension View {
    /// Card background + glass border — shared across Finance views and skeletons.
    func cardSurface(cornerRadius: CGFloat) -> some View {
        self
            .background(
                Color.cardBackground.opacity(0.35),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .appGlassSurface(cornerRadius: cornerRadius)
    }

    @ViewBuilder
    func appGlassSurface(cornerRadius: CGFloat = 16, style: AppGlassStyle = .regular) -> some View {
        if #available(iOS 26, *) {
            switch style {
            case .regular:
                self
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            case .interactive:
                self
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
        } else {
            self
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}
