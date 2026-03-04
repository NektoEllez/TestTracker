import Foundation

struct AppConfig {
    /// Priority keys used when config JSON is an object.
    private static let priorityKeys = ["url", "link", "redirect"]
    
    /// Extracts first valid HTTP(S) URL from the config payload.
    /// Supports:
    /// - root dictionary: checks `priorityKeys`, then scans string values,
    /// - root string: validates directly.
    static func extractURL(from data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        
        if let dict = json as? [String: Any] {
            for key in priorityKeys {
                if let urlString = dict[key] as? String,
                   let url = validatedURL(from: urlString) {
                    return url
                }
            }
            for (_, value) in dict {
                if let urlString = value as? String,
                   let url = validatedURL(from: urlString) {
                    return url
                }
            }
        }
        
        if let urlString = json as? String,
           let url = validatedURL(from: urlString) {
            return url
        }
        
        return nil
    }
    
    /// Validates HTTP(S) URLs with non-empty host only.
    private static func validatedURL(from string: String) -> URL? {
        guard let url = URL(string: string),
              let scheme = url.scheme?.lowercased(),
              (scheme == "http" || scheme == "https"),
              url.host != nil else {
            return nil
        }
        return url
    }
}
