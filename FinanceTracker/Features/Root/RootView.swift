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
                    FinanceContainerView(onOpenBrowser: { viewModel.openBrowser() })
                        .transition(.opacity)
                case .browser(let url):
                    BrowserScreen(
                        initialURL: url,
                        onFallbackToFinance: { viewModel.fallbackToFinance() }
                    )
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackgroundGradient.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.4), value: viewModel.appState)
        .task {
            async let initialState = viewModel.determineModule()
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            viewModel.appState = await initialState
        }
    }
}

#Preview("Root") {
    RootView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
