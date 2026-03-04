import SwiftUI

enum AppGlassStyle {
    case regular
    case interactive
}

extension View {
    @ViewBuilder
    func appGlassSurface(cornerRadius: CGFloat = 16, style: AppGlassStyle = .regular) -> some View {
        if #available(iOS 26, *) {
            switch style {
            case .regular:
                self
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            case .interactive:
                self
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
        }
    }
}
