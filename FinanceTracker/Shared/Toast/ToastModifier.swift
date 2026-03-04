import SwiftUI

struct ToastModifier: ViewModifier {
    var alignment: Alignment = .top
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                ToastOverlayContent(alignment: alignment)
            }
    }
}

private struct ToastOverlayContent: View {
    @Environment(\.toastStore) private var toastStore
    var alignment: Alignment
    
    var body: some View {
        if let toastStore {
            ToastObservedOverlay(store: toastStore, alignment: alignment)
        }
    }
}

private struct ToastObservedOverlay: View {
    @ObservedObject var store: ToastStore
    var alignment: Alignment
    
    var body: some View {
        GeometryReader { proxy in
            if let message = store.message {
                toastView(for: message, in: proxy)
            }
        }
    }
    
    private func toastView(for message: ToastMessage, in proxy: GeometryProxy) -> some View {
        let topPadding = proxy.safeAreaInsets.top + 8
        let bottomPadding = proxy.safeAreaInsets.bottom + 8
        
        return ToastView(message: message) {
            store.dismiss()
        }
        .padding(.horizontal, 20)
        .padding(alignment == .top ? .top : .bottom, alignment == .top ? topPadding : bottomPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .transition(.asymmetric(
            insertion: .move(edge: alignment == .top ? .top : .bottom).combined(with: .opacity),
            removal: .move(edge: alignment == .top ? .top : .bottom).combined(with: .opacity)
        ))
        .zIndex(1000)
    }
}

extension View {
    func toastOverlay(alignment: Alignment = .top) -> some View {
        modifier(ToastModifier(alignment: alignment))
    }
}
