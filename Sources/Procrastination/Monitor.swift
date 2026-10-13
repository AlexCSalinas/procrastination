import AppKit

/// Polls Chrome's active tab and fires the nag after sustained time on a distracting site.
final class Monitor {
    private static let chromeBundleID = "com.google.Chrome"
    private static let pollInterval: TimeInterval = 5

    private var timer: Timer?
    private var distractedSince: Date?
    private var lastNag: Date = .distantPast
    private let onNag: (String, Int) -> Void

    init(onNag: @escaping (String, Int) -> Void) { self.onNag = onNag }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: Self.pollInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// Re-arm so a fresh nag can fire immediately (used by the menu's "Test popup").
    func resetCooldown() { lastNag = .distantPast }

    private func tick() {
        guard Settings.enabled, let tab = activeChromeTab(), Self.isDistracting(tab) else {
            distractedSince = nil
            return
        }
        Settings.addDistractedTime(Self.pollInterval)
        let now = Date()
        let since = distractedSince ?? now
        distractedSince = since
        if now.timeIntervalSince(since) >= Settings.grace,
           now.timeIntervalSince(lastNag) >= Settings.cooldown {
            lastNag = now
            distractedSince = nil
            onNag(Settings.message, Settings.distractedMinutesToday)
        }
    }

    static func isDistracting(_ tab: (url: String, title: String)) -> Bool {
        guard let host = URL(string: tab.url)?.host?.lowercased() else { return false }
        let onBadSite = Settings.domains.contains { host == $0 || host.hasSuffix("." + $0) }
        let title = tab.title.lowercased()
        return onBadSite && !Settings.allowlist.contains { title.contains($0) }
    }

    /// Closes the active tab in Chrome's front window.
    static func closeActiveTab() {
        let source = """
        tell application id "\(chromeBundleID)"
            if (count of windows) > 0 then close active tab of front window
        end tell
        """
        var error: NSDictionary?
        NSAppleScript(source: source)?.executeAndReturnError(&error)
    }

    /// Returns nil unless Chrome is frontmost. Checking via NSWorkspace first means we never
    /// message Chrome when it's closed (which would launch it).
    private func activeChromeTab() -> (url: String, title: String)? {
        guard NSWorkspace.shared.frontmostApplication?.bundleIdentifier == Self.chromeBundleID else { return nil }
        let source = """
        tell application id "\(Self.chromeBundleID)"
            if (count of windows) is 0 then return ""
            set t to active tab of front window
            return (URL of t) & "|||" & (title of t)
        end tell
        """
        var error: NSDictionary?
        guard let result = NSAppleScript(source: source)?.executeAndReturnError(&error).stringValue,
              !result.isEmpty else { return nil }
        let parts = result.components(separatedBy: "|||")
        return (parts[0], parts.count > 1 ? parts[1...].joined(separator: "|||") : "")
    }
}
