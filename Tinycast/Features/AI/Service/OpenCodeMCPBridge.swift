import Foundation

/// OpenCode's TCP bridge needs macOS 26's Network framework; Sequoia skips that integration.
@MainActor
final class OpenCodeMCPBridge {
    init(
        session: AIToolSession, event: @escaping (AIStreamEvent) -> Void,
        failure: @escaping (String) -> Void
    ) {}

    func start() async throws -> String {
        throw URLError(.cannotConnectToHost)
    }

    func stop() {}
}
