import Foundation

/// The loopback MCP server needs macOS 26's Network framework, so turns here run without tools.
@MainActor
final class OpenCodeMCPBridge {
    static let hostsTools = false

    init(
        session: AIToolSession, event: @escaping (AIStreamEvent) -> Void,
        failure: @escaping (String) -> Void
    ) {}

    func start() async throws -> String {
        try OpenCodeMCPLaunch.configuration(tools: [])
    }

    func stop() {}
}
