# macOS 15 (Sequoia) channel

This branch tracks upstream `v0.12.11` and targets macOS 15.0+. The compatibility work lives in the
sources themselves — there is no patch to apply and no second tree to keep in sync.

## What differs from upstream

- `MACOSX_DEPLOYMENT_TARGET` and `LSMinimumSystemVersion` are 15.0. The CI build still uses Xcode 26's
  SDK and ships universal `arm64 x86_64`; see `.github/workflows/release-sequoia.yml`.
- Liquid Glass is replaced: SwiftUI surfaces use `frosted(in:)` / `frostedMenu(in:)` in
  `Tinycast/DesignSystem/Theme.swift`, and AppKit-backed floating panels use `GlassEffectView`, an
  `NSVisualEffectView` that samples behind the window. No macOS 26-only symbol is linked.
- Apple Intelligence (`FoundationModels`) is macOS 26 only: `AppleIntelligenceProvider` reports
  `.deviceNotEligible` and `AIProviderFactory` rejects that route.
- macOS 26's Observation-based NotificationCenter API and `posix_spawn_file_actions_addchdir` are
  replaced with their macOS 15 equivalents.
- Three macOS 26-only integrations are disabled rather than emulated. MCP OAuth loopback sign-in and
  the Quick Actions text translator report a channel-specific error. OpenCode runs without MCP tools:
  its bridge returns a tool-free configuration, so turns still complete. AI chat, stdio/HTTP MCP
  tools, dictation, camera, calendar, window switcher and the rest work.

Everything else tracks upstream `v0.12.11`; the Sequoia-only edits are listed above.

## Build & install

Push a `v<version>-sequoia` tag. The workflow builds, asserts `minos 15.0` on both slices, packages a
DMG and publishes a prerelease. Install it by dragging `Tinycast.app` into `/Applications`, then:

```sh
xattr -dr com.apple.quarantine "/Applications/Tinycast.app"
```

The bundle id stays `com.tinycast.app`, so upgrading from an older Sequoia build keeps settings,
clipboard history, the login item and the Accessibility grant. The in-app updater points at this
repository but never offers anything: this channel publishes prereleases with DMG-only assets, the
stable channel rejects prereleases, and the feed only accepts `.zip` archives. Automatic checking
defaults to off as well. Never point the feed back at upstream — those builds require macOS 26.
Download the next `-sequoia` DMG to update.

## Verification scope

A green workflow proves the app compiles, links and declares a 15.0 floor. Runtime behaviour on real
Sequoia — the fallback material's appearance, Accessibility paste focus restoration, dictation and
camera prompts, emoji and clipboard image rendering — is checked on the machine that installs it.

Two harnesses assert the disabled contract instead of upstream's loopback behaviour: `mcp-oauth-test`
checks `MCPOAuth.Failure.listenerUnavailable`, and `opencode-mcp-test` checks the tool-free
configuration and that an OpenCode turn still completes.
