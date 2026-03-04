import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        ZStack {
            switch viewModel.appState {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .onboarding:
                OnboardingView(onComplete: {
                    viewModel.completeOnboarding()
                })
                .transition(.opacity)
            case .finance:
                FinanceContainerView()
                    .transition(.opacity)
            case .webView(let url):
                WebViewScreen(initialURL: url)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.4), value: viewModel.appState)
        .task {
            // Brief delay to show splash (iOS 15 compatible)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await viewModel.determineModule()
        }
    }
}

#Preview("Root") {
    RootView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
