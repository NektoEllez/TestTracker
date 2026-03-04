import Foundation
import Combine

enum AppState: Equatable, Sendable {
    case splash
    case onboarding
    case finance
    case browser(URL)
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
                case .browser(let url):
                    OrientationManager.shared.unlockAll()
                    return .browser(url)
            }
        }
        
        // Race: fetch config vs 6s timeout. No internet / no URL / timeout → finance.
        let service = configService
        let url: URL? = await withTaskGroup(of: URL?.self) { group in
            group.addTask {
                do {
                    return try await service.fetchConfig()
                } catch {
                    return nil
                }
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                return nil as URL?
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first ?? nil
        }

        if let url {
            ModuleDecision.browser(url).save()
            OrientationManager.shared.unlockAll()
            return .browser(url)
        }
        ModuleDecision.finance.save()
        return module1State()
    }
    
    func completeOnboarding() {
        storageManager.isOnboardingCompleted = true
        appState = .finance
    }

    func fallbackToFinance() {
        ModuleDecision.finance.save(clearBrowserURL: false)
        OrientationManager.shared.lockPortrait()
        appState = module1State()
    }

    func openBrowser() {
        guard let url = storageManager.browserConfigURL else { return }
        OrientationManager.shared.unlockAll()
        appState = .browser(url)
    }
    
    private func module1State() -> AppState {
        if !storageManager.isOnboardingCompleted {
            return .onboarding
        } else {
            return .finance
        }
    }
}
