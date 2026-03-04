import SwiftUI
import Combine

private enum ToastStoreKey: EnvironmentKey {
    static let defaultValue: ToastStore? = nil
}

extension EnvironmentValues {
    var toastStore: ToastStore? {
        get { self[ToastStoreKey.self] }
        set { self[ToastStoreKey.self] = newValue }
    }
}

@MainActor
final class ToastStore: ObservableObject {
    @Published var message: ToastMessage?
    
    private var dismissTask: Task<Void, Never>?
    private let animation = Animation.easeInOut(duration: 0.25)
    
    func show(_ message: ToastMessage, autoDismissAfter seconds: Double = 3) {
        dismissTask?.cancel()
        
        withAnimation(animation) {
            self.message = message
        }
        
        triggerHaptic(for: message.style)
        
        let safeDelay = max(0, seconds)
        dismissTask = Task { [weak self] in
            do {
                let nanoseconds = UInt64(safeDelay * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanoseconds)
                guard !Task.isCancelled else { return }
                self?.dismiss()
            } catch {
                return
            }
        }
    }
    
    private func triggerHaptic(for style: ToastStyle) {
        switch style {
            case .default:
                break
            case .success:
                Haptics.success()
            case .warning:
                Haptics.warning()
            case .error:
                Haptics.error()
        }
    }
    
    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        
        withAnimation(animation) {
            message = nil
        }
    }
}

struct ToastMessage: Equatable {
    let text: String
    let icon: String?
    let style: ToastStyle
    
    init(text: String, icon: String? = nil, style: ToastStyle = .default) {
        self.text = text
        self.icon = icon
        self.style = style
    }
}

enum ToastStyle {
    case `default`
    case success
    case warning
    case error
}
