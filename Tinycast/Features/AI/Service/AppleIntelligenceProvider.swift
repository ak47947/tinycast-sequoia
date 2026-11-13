import Foundation

/// FoundationModels is macOS 26 only, so this channel reports the route as unsupported.
enum AppleIntelligenceGuardrails {
    case `default`
    case permissiveContentTransformations
}

struct AppleIntelligenceProvider {
    static func status() -> AppleIntelligenceStatus { .deviceNotEligible }
}
