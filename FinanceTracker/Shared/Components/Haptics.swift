import UIKit

@MainActor
enum Haptics {
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    private static var isEnabled: Bool {
#if targetEnvironment(simulator)
        false
#else
        true
#endif
    }
    
    static func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
    
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func success() {
        notification(.success)
    }
    
    static func warning() {
        notification(.warning)
    }
    
    static func error() {
        notification(.error)
    }
    
    private static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(type)
        notificationGenerator.prepare()
    }
}
