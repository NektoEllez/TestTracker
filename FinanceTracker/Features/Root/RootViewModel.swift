import Foundation
import Combine

enum AppState: Equatable, Sendable {
    case splash
    case onboarding
    case finance
    case browser(URL)
}

enum RootEvent: Sendable {
    case appLaunched
    case onboardingCompleted
    case browserFallbackToFinance
}

@MainActor
class RootViewModel: ObservableObject {
    @Published var appState: AppState = .splash

    private let configService: ConfigServiceProtocol
    private let storageManager: AppStorageManager
    private let orientationManager: OrientationManager
    private var didBootstrap = false
    private let firstLaunchSplashDelayNanoseconds: UInt64 = 1_500_000_000
    
    init(
        configService: ConfigServiceProtocol,
        storageManager: AppStorageManager,
        orientationManager: OrientationManager
    ) {
        self.configService = configService
        self.storageManager = storageManager
        self.orientationManager = orientationManager
    }

    func send(_ event: RootEvent) async {
        switch event {
        case .appLaunched:
            await bootstrapIfNeeded()
        case .onboardingCompleted:
            storageManager.isOnboardingCompleted = true
            appState = .finance
        case .browserFallbackToFinance:
            ModuleDecision.finance.save(in: storageManager, clearBrowserURL: false)
            orientationManager.lockPortrait()
            appState = module1State()
        }
    }

    func completeOnboarding() {
        Task { await send(.onboardingCompleted) }
    }

    func fallbackToFinance() {
        Task { await send(.browserFallbackToFinance) }
    }

    private func bootstrapIfNeeded() async {
        guard !didBootstrap else { return }
        didBootstrap = true

        appState = .splash
        let savedDecision = ModuleDecision.load(from: storageManager)
        let shouldShowFirstLaunchDelay = savedDecision == nil

        async let resolvedState = resolveInitialState(savedDecision: savedDecision)
        if shouldShowFirstLaunchDelay {
            try? await Task.sleep(nanoseconds: firstLaunchSplashDelayNanoseconds)
        }
        appState = await resolvedState
    }

    private func resolveInitialState(savedDecision: ModuleDecision?) async -> AppState {
        if let savedDecision {
            return state(for: savedDecision)
        }

        do {
            if let url = try await configService.fetchConfig() {
                ModuleDecision.browser(url).save(in: storageManager)
                return state(for: .browser(url))
            }
            ModuleDecision.finance.save(in: storageManager)
            return module1State()
        } catch {
            ModuleDecision.finance.save(in: storageManager)
            return module1State()
        }
    }

    private func state(for decision: ModuleDecision) -> AppState {
        switch decision {
        case .finance:
            orientationManager.lockPortrait()
            return module1State()
        case .browser(let url):
            orientationManager.unlockAll()
            return .browser(url)
        }
    }

    private func module1State() -> AppState {
        if !storageManager.isOnboardingCompleted {
            return .onboarding
        } else {
            return .finance
        }
    }
}
