import Foundation

struct AppConfig {

    /// Priority keys to search for a URL in the JSON config
    private static let priorityKeys = ["url", "link", "redirect"]

    /// Attempts to extract a valid URL from arbitrary JSON data.
    /// Checks priority keys first, then scans all string values.
    static func extractURL(from data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }

        // If root is a dictionary, search by priority keys first
        if let dict = json as? [String: Any] {
            for key in priorityKeys {
                if let urlString = dict[key] as? String,
                   let url = validatedURL(from: urlString) {
                    return url
                }
            }
            // Then scan all string values
            for (_, value) in dict {
                if let urlString = value as? String,
                   let url = validatedURL(from: urlString) {
                    return url
                }
            }
        }

        // If root is a string
        if let urlString = json as? String,
           let url = validatedURL(from: urlString) {
            return url
        }

        return nil
    }

    /// Validates that a string is a proper HTTP/HTTPS URL with a host
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
