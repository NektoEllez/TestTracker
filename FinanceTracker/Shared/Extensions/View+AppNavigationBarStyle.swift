import SwiftUI
import UIKit

enum AppNavigationBarBackground {
    case glass
    case clear
}

private struct AppNavigationBarStyleModifier: ViewModifier {
    let background: AppNavigationBarBackground
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            modernBody(content)
        } else {
            content.background(LegacyNavigationBarConfigurator(background: background))
        }
    }
    
        // MARK: - iOS 16+ (system SwiftUI navigation)
    
    @available(iOS 26.0, *)
    @ViewBuilder
    private func modernBody(_ content: Content) -> some View {
        switch background {
            case .glass:
                    // Let the system Liquid Glass handle everything.
                    // `.automatic` makes the bar transparent at scroll edge
                    // and shows glass when content scrolls underneath.
                content
                    .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
            case .clear:
                content
                    .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
    }
}

extension View {
    func appNavigationBarStyle(
        background: AppNavigationBarBackground = .glass
    ) -> some View {
        modifier(AppNavigationBarStyleModifier(background: background))
    }
}

    // MARK: - Legacy (iOS 15)

private struct LegacyNavigationBarConfigurator: UIViewControllerRepresentable {
    let background: AppNavigationBarBackground
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let navController = uiViewController.navigationController
        ?? findNavigationController(from: uiViewController.view)
        
        guard let navigationController = navController else { return }
        
        let appearance = UINavigationBarAppearance()
        switch background {
            case .glass:
                appearance.configureWithDefaultBackground()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.4)
                appearance.shadowColor = .clear
            case .clear:
                appearance.configureWithTransparentBackground()
                appearance.backgroundEffect = nil
                appearance.backgroundColor = .clear
                appearance.shadowColor = .clear
        }
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.isTranslucent = true
    }
    
    private func findNavigationController(from view: UIView?) -> UINavigationController? {
        var responder: UIResponder? = view
        while let next = responder {
            if let nav = next as? UINavigationController { return nav }
            if let vc = next as? UIViewController, let nav = vc.navigationController { return nav }
            responder = next.next
        }
        return nil
    }
}
