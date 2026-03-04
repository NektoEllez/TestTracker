import SwiftUI
import SafariServices

struct SafariWebViewRepresentable: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .label
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
