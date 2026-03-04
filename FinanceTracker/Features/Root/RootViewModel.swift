import Foundation
import Combine

enum AppState: Equatable, Sendable {
    case splash
    case onboarding
    case finance
    case webView(URL)
}

@MainActor
class RootViewModel: ObservableObject {
    @Published var appState: AppState = .splash

    private let configService: ConfigServiceProtocol
    private let storageManager: AppStorageManager

    init(
        configService: ConfigServiceProtocol,
        storageManager: AppStorageManager
    ) {
        self.configService = configService
        self.storageManager = storageManager
    }

    convenience init() {
        self.init(
            configService: ConfigService(),
            storageManager: .shared
        )
    }

    func determineModule() async {
        // 1. Onboarding not completed → always show onboarding first
        if !storageManager.isOnboardingCompleted {
            appState = .onboarding
            return
        }

        // 2. Onboarding done — check saved decision
        if let saved = ModuleDecision.load() {
            switch saved {
            case .finance:
                appState = .finance
                return
            case .webView(let url):
                OrientationManager.shared.unlockAll()
                appState = .webView(url)
                return
            }
        }

        // 3. First time after onboarding — no saved decision, fetch config
        do {
            if let url = try await configService.fetchConfig() {
                ModuleDecision.webView(url).save()
                OrientationManager.shared.unlockAll()
                appState = .webView(url)
            } else {
                ModuleDecision.finance.save()
                appState = .finance
            }
        } catch {
            ModuleDecision.finance.save()
            appState = .finance
        }
    }

    func completeOnboarding() {
        storageManager.isOnboardingCompleted = true
        Task {
            await determineModule()
        }
    }
}
