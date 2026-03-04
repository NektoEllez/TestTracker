import Foundation

protocol ConfigServiceProtocol: Sendable {
    var isRemoteConfigEnabled: Bool { get }
    var hasRemoteConfig: Bool { get }
    func fetchConfig() async throws -> URL?
}
