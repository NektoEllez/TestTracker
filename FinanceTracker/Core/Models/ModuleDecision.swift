import Foundation

enum ModuleDecision: Equatable {
    case finance
    case browser(URL)
    
    // MARK: - Save / Load

    func save(in storage: AppStorageManager, clearBrowserURL: Bool = true) {
        switch self {
            case .finance:
                storage.moduleDecisionType = "finance"
                if clearBrowserURL { storage.browserConfigURL = nil }
            case .browser(let url):
                storage.moduleDecisionType = "browser"
                storage.browserConfigURL = url
        }
    }

    static func load(from storage: AppStorageManager) -> ModuleDecision? {
        let defaults = UserDefaults.standard
        
        // Migration: old key module_decision_url → browser_config_url
        if storage.browserConfigURL == nil,
           let legacyURL = defaults.string(forKey: "module_decision_url"),
           let url = URL(string: legacyURL) {
            storage.browserConfigURL = url
        }
        
        guard let type = storage.moduleDecisionType else { return nil }
        
        switch type {
            case "finance":
                return .finance
            case "browser", "webView":
                if let url = storage.browserConfigURL {
                    return .browser(url)
                }
                return nil
            default:
                return nil
        }
    }

    // MARK: - Backward Compatible Wrappers

    func save(clearBrowserURL: Bool = true) {
        save(in: .shared, clearBrowserURL: clearBrowserURL)
    }

    static func load() -> ModuleDecision? {
        load(from: .shared)
    }
}
