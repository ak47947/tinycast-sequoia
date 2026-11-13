import Foundation

/// The loopback OAuth callback needs macOS 26's Network framework; Sequoia cannot host it.
@MainActor
final class MCPOAuthListener {
    nonisolated static let redirectURI = "http://127.0.0.1:4962/callback"

    func start(
        state: String, issuer: String, requiresIssuer: Bool, timeout: Duration = .seconds(300)
    ) async throws {
        throw MCPOAuth.Failure.listenerUnavailable
    }

    func code() async throws -> String { throw MCPOAuth.Failure.listenerUnavailable }

    func cancel() {}
}
