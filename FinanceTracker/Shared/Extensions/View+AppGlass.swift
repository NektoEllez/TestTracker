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
    
    func appGlassSurface(cornerRadius: CGFloat = 16, style: AppGlassStyle = .regular) -> some View {
        modifier(AppGlassSurfaceModifier(cornerRadius: cornerRadius, style: style))
    }
}

private struct AppGlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let style: AppGlassStyle

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.modifier(ModernGlassSurfaceModifier(cornerRadius: cornerRadius, style: style))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

@available(iOS 26, *)
private struct ModernGlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let style: AppGlassStyle

    @ViewBuilder
    func body(content: Content) -> some View {
        switch style {
            case .regular:
                content
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            case .interactive:
                content
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}
