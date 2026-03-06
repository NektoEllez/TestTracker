import SwiftUI

// MARK: - Preference Key for Scroll Reader
struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Scroll Effect Modifiers
extension ViewModifiers {
    struct ScrollReader: ViewModifier {
        func body(content: Content) -> some View {
            content
                .overlay(GeometryReader { scrollGeometry in
                    Color.clear.preference(
                        key: OffsetPreferenceKey.self,
                        value: scrollGeometry.frame(in: .global).minY
                    )
                })
        }
    }
}

// MARK: - Scroll Effect View Extensions
extension View {
    // MARK: - Scroll Reader
    func scrollReader() -> some View {
        modifier(ViewModifiers.ScrollReader())
    }

    // MARK: - Legacy Bottom Bar
    func legacySystemBottomBar(showDivider: Bool = true) -> some View {
        self
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.bar)
                    .frame(height: 44)
                    .overlay(
                        showDivider ? Divider().opacity(0.25) : nil,
                        alignment: .top
                    )
            }
    }

    // MARK: - Scroll Edge Effect with Bottom Bar
    func scrollEdgeWithBottomBar() -> some View {
        apply { base in
            if #available(iOS 26.0, *) {
                base
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .scrollEdgeEffectStyle(.soft, for: .top)
                    .scrollEdgeEffectStyle(.soft, for: .bottom)
                    .safeAreaBar(edge: .bottom) {
                        Rectangle()
                            .fill(.bar)
                            .frame(height: 1)
                            .opacity(0.3)
                    }
            } else if #available(iOS 16.0, *) {
                base
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .legacySystemBottomBar()
            } else {
                base.legacySystemBottomBar()
            }
        }
    }

    // Compatibility alias for existing callsites.
    func appBottomSystemBar() -> some View {
        scrollEdgeWithBottomBar()
    }
}
