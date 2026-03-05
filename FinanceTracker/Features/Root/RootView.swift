import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: RootViewModel
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = StateObject(
            wrappedValue: RootViewModel(
                configService: dependencies.configService,
                storageManager: dependencies.storageManager,
                orientationManager: dependencies.orientationManager
            )
        )
    }
    
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
                    FinanceContainerView(storageManager: dependencies.storageManager)
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
            await viewModel.send(.appLaunched)
        }
    }
}

#Preview("Root") {
    RootView(dependencies: AppDependencies.makeDefault())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
