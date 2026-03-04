import Foundation

protocol ConfigServiceProtocol: Sendable {
    var isRemoteConfigEnabled: Bool { get }
    func fetchConfig() async throws -> URL?
}
