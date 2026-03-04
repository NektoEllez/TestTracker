import SwiftUI

struct WebViewScreen: View {
    @StateObject private var viewModel: WebViewModel
    @Environment(\.toastStore) private var toastStore

    init(initialURL: URL) {
        _viewModel = StateObject(wrappedValue: WebViewModel(initialURL: initialURL))
    }

    var body: some View {
        ZStack {
            WebViewRepresentable(viewModel: viewModel)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

            loadingOverlay
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            OrientationManager.shared.unlockAll()
        }
        .onDisappear {
            OrientationManager.shared.lockPortrait()
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            guard let message = newValue else { return }
            toastStore?.show(
                ToastMessage(
                    text: "Web error: \(message)",
                    icon: "wifi.exclamationmark",
                    style: .warning
                ),
                autoDismissAfter: 3
            )
            viewModel.errorMessage = nil
        }
        .sheet(item: $viewModel.safariDestination, onDismiss: {
            viewModel.safariDestination = nil
        }) { destination in
            SafariWebViewRepresentable(url: destination.url)
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ZStack {
                Color.black.opacity(0.08)

                VStack(spacing: 10) {
                    DotArcLoaderView(size: 70, dotSize: 14)
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    Color.cardBackground.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .appGlassSurface(cornerRadius: 14)
            }
            .transition(.opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}
