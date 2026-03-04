import Foundation

enum ModuleDecision: Equatable {
    case finance
    case browser(URL)
    
    // MARK: - Save / Load (UserDefaults via AppStorageManager)
    
    func save(clearBrowserURL: Bool = true) {
        let storage = AppStorageManager.shared
        switch self {
            case .finance:
                storage.moduleDecisionType = "finance"
                if clearBrowserURL { storage.browserConfigURL = nil }
            case .browser(let url):
                storage.moduleDecisionType = "browser"
                storage.browserConfigURL = url
        }
    }
    
    static func load() -> ModuleDecision? {
        let storage = AppStorageManager.shared
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
}
