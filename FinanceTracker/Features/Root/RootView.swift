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
            let initialState = await viewModel.determineModule()
            let hasSavedDecision = ModuleDecision.load() != nil
            if !hasSavedDecision {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
            }
            viewModel.appState = initialState
        }
    }
}

#Preview("Root") {
    RootView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
