import SwiftUI

struct WebViewScreen: View {
    @StateObject private var viewModel: WebViewModel

    init(initialURL: URL) {
        _viewModel = StateObject(wrappedValue: WebViewModel(initialURL: initialURL))
    }

    var body: some View {
        ZStack(alignment: .top) {
            WebViewRepresentable(viewModel: viewModel)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

            progressBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            OrientationManager.shared.unlockAll()
        }
        .onDisappear {
            OrientationManager.shared.lockPortrait()
        }
    }

    @ViewBuilder
    private var progressBar: some View {
        if viewModel.isLoading {
            ProgressView(value: viewModel.estimatedProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .appAccent))
        }
    }
}
