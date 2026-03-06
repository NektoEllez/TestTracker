import Foundation
import os

final class ConfigService: ConfigServiceProtocol, Sendable {
    private enum Constants {
        static let defaultConfigURLString = "https://drive.google.com/uc?export=download&id=13935lF1Cs8cRQOYRp6pnkK-TalBW5EyU"
        static let timeout: TimeInterval = 12
        static let isRemoteConfigEnabled = true
        static let remoteConfigURLKey = "RemoteConfigURL"
    }
    
    private static let logger = Logger(subsystem: "Legacy.FinanceTracker", category: "ConfigService")
    
    let isRemoteConfigEnabled: Bool = Constants.isRemoteConfigEnabled
    private let configURL: URL?
    var hasRemoteConfig: Bool { configURL != nil }
    
    init(bundle: Bundle = .main) {
        self.configURL = Self.loadConfigURL(from: bundle)
    }
    
    func fetchConfig() async throws -> URL? {
        guard let configURL else {
            throw ConfigServiceError.unknown("Config URL is unavailable")
        }

        do {
            var request = URLRequest(url: configURL)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.timeoutInterval = Constants.timeout

            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ConfigServiceError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw ConfigServiceError.httpStatus(httpResponse.statusCode)
            }
            
            return AppConfig.extractURL(from: data)
        } catch let error as URLError {
            throw ConfigServiceError.network(error)
        } catch let error as ConfigServiceError {
            Self.logger.error("Config fetch failed: \(error.localizedDescription, privacy: .public)")
            throw error
        } catch {
            let wrappedError = ConfigServiceError.unknown(error.localizedDescription)
            Self.logger.error("Config fetch failed: \(wrappedError.localizedDescription, privacy: .public)")
            throw wrappedError
        }
    }

    private static func loadConfigURL(from bundle: Bundle) -> URL? {
        let urlString = (bundle.object(
            forInfoDictionaryKey: Constants.remoteConfigURLKey
        ) as? String) ?? Constants.defaultConfigURLString
        guard let url = URL(string: urlString),
              url.scheme?.lowercased() == "https",
              url.host != nil else {
            logger.error("Invalid RemoteConfigURL")
            return URL(string: Constants.defaultConfigURLString)
        }
        return url
    }
}

enum ConfigServiceError: Error, Sendable {
    case network(URLError)
    case invalidResponse
    case httpStatus(Int)
    case unknown(String)
}

extension ConfigServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .network(let urlError):
                return "Network error: \(urlError.localizedDescription)"
            case .invalidResponse:
                return "Invalid server response"
            case .httpStatus(let code):
                return "Server returned error status: \(code)"
            case .unknown(let message):
                return "Unexpected error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
            case .network:
                return "Check internet connection and try again"
            case .invalidResponse, .httpStatus:
                return "Try again later"
            case .unknown:
                return "Try restarting the app"
        }
    }
}
