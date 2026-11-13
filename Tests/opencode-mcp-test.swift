import Foundation

@main
struct OpenCodeMCPTest {
    @MainActor
    static func main() async throws {
        let tool = AITool(
            name: "mcp_test_echo", description: "Echo", parameters: .object(["type": .string("object")]),
            origin: "Test", title: "Echo")
        var failures: [String] = []
        let session = AIToolSession(tools: [tool], maxCalls: 2) { call in
            AIToolResult(callID: call.id, content: call.arguments, isError: false)
        }
        let bridge = OpenCodeMCPBridge(session: session, event: { _ in }) {
            failures.append($0)
        }
        let configuration = try await bridge.start()
        let config = JSONValue(data: Data(configuration.utf8))!.objectValue!
        assert(config["mcp"] == nil, "this channel must not advertise an MCP server")
        let permissions = config["agents"]!.objectValue!["tinycast"]!.objectValue!["permissions"]!
            .arrayValue!
        assert(permissions.count == 1)
        assert(permissions[0].objectValue!["action"] == .string("*"))
        assert(permissions[0].objectValue!["effect"] == .string("deny"))
        assert(failures.isEmpty)
        bridge.stop()
        try await installedTurn(tool: tool)
        print("OpenCode MCP bridge disabled-path tests passed")
    }

    @MainActor
    private static func installedTurn(tool: AITool) async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let executable = directory.appending(path: "opencode")
        let script = #"""
            #!/usr/bin/python3
            import json, os, sys
            assert '--standalone' in sys.argv
            assert sys.argv[sys.argv.index('--agent') + 1] == 'tinycast'
            config = json.loads(os.environ['OPENCODE_CONFIG_CONTENT'])
            prompt = sys.stdin.read()
            rules = config['agents']['tinycast']['permissions']
            assert rules == [{'action': '*', 'resource': '*', 'effect': 'deny'}]
            assert 'mcp' not in config
            assert 'Do not invoke tools' in prompt
            print(json.dumps({'type':'text', 'part':{'text':'Complete'}}), flush=True)
            """#
        try Data(script.utf8).write(to: executable)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: executable.path)
        var invocations = 0
        let session = AIToolSession(tools: [tool], maxCalls: 1) { call in
            await MainActor.run { invocations += 1 }
            let arguments = JSONValue(data: Data(call.arguments.utf8))!.objectValue!
            return AIToolResult(
                callID: call.id, content: arguments["text"]!.stringValue!, isError: false)
        }
        for tools in [session, nil] {
            let provider = InstalledCLIProvider(
                kind: .openCode, executable: executable, model: "test/model", effort: nil,
                workspace: directory, toolSession: tools)
            var events: [AIStreamEvent] = []
            for try await event in provider.stream(
                AIRequest(messages: [AIMessage(role: .user, text: "Hello")]))
            {
                events.append(event)
            }
            assert(events.contains(.text("Complete")) && events.last == .finished)
            assert(events.count == 2)
        }
        assert(invocations == 0)
    }
}

@MainActor
enum InstalledAIManager {
    static let hasManagedMCPPolicy = false
    static let claudeWithoutMCPArguments: [String] = []
}
