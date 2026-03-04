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
    
    /// Resolves app entry module and persists decision for next launches.
    /// Flow:
    /// 1) Use saved `ModuleDecision` when available.
    /// 2) On first launch, fetch remote config during splash and persist result.
    /// 3) Any parsing/network error falls back to finance module.
    func determineModule() async -> AppState {
        if let saved = ModuleDecision.load() {
            switch saved {
                case .finance:
                    return module1State()
                case .webView(let url):
                    OrientationManager.shared.unlockAll()
                    return .webView(url)
            }
        }
        
        do {
            if let url = try await configService.fetchConfig() {
                ModuleDecision.webView(url).save()
                OrientationManager.shared.unlockAll()
                return .webView(url)
            } else {
                ModuleDecision.finance.save()
                return module1State()
            }
        } catch {
            ModuleDecision.finance.save()
            return module1State()
        }
    }
    
    func completeOnboarding() {
        storageManager.isOnboardingCompleted = true
        appState = .finance
    }
    
    private func module1State() -> AppState {
        if !storageManager.isOnboardingCompleted {
            return .onboarding
        } else {
            return .finance
        }
    }
}
