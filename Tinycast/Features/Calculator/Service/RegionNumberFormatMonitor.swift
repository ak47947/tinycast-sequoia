import Foundation

/// Follows Language & Region's number format, so a change there applies without a relaunch.
@MainActor
@Observable
final class RegionNumberFormatMonitor {
    private(set) var system = RegionNumberFormatMonitor.read()
    @ObservationIgnored private var token: ObserverToken?

    init() {
        token = ObserverToken(
            NotificationCenter.default.addObserver(
                forName: Notification.Name("NSCurrentLocaleDidChangeNotification"),
                object: nil, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.system = Self.read() }
            })
    }

    deinit { token?.remove() }

    func format(for style: CalcNumberStyle) -> CalcNumberFormat {
        style == .system ? system : .english
    }

    /// Separators the parser can't take, such as the Arabic `٫`, fall back to English.
    private static func read() -> CalcNumberFormat {
        let locale = Locale.autoupdatingCurrent
        return CalcNumberFormat(
            decimalSeparator: locale.decimalSeparator ?? ".", groupingSeparator: locale.groupingSeparator)
            ?? .english
    }
}

private struct ObserverToken: @unchecked Sendable {
    private let raw: any NSObjectProtocol
    init(_ raw: any NSObjectProtocol) { self.raw = raw }
    func remove() { NotificationCenter.default.removeObserver(raw) }
}
