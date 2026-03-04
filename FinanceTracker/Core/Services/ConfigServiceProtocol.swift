import Foundation

protocol ConfigServiceProtocol: Sendable {
    func fetchConfig() async throws -> URL?
}
