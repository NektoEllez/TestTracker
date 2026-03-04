import Foundation

enum ModuleDecision: Equatable {
    case finance
    case browser(URL)
    
    // MARK: - Persistence Keys
    
    private static let typeKey = "module_decision_type"
    private static let urlKey = "module_decision_url"
    
    // MARK: - Save / Load
    
    func save() {
        let defaults = UserDefaults.standard
        switch self {
            case .finance:
                defaults.set("finance", forKey: Self.typeKey)
                defaults.removeObject(forKey: Self.urlKey)
            case .browser(let url):
                defaults.set("browser", forKey: Self.typeKey)
                defaults.set(url.absoluteString, forKey: Self.urlKey)
        }
    }
    
    static func load() -> ModuleDecision? {
        let defaults = UserDefaults.standard
        guard let type = defaults.string(forKey: typeKey) else { return nil }
        
        switch type {
            case "finance":
                return .finance
            case "browser", "webView": // "webView" for migration from old key
                if let urlString = defaults.string(forKey: urlKey),
                   let url = URL(string: urlString) {
                    return .browser(url)
                }
                return nil
            default:
                return nil
        }
    }
}
