import Foundation

/// User-editable settings, persisted in UserDefaults.
enum Settings {
    static let defaults = UserDefaults.standard

    enum Key {
        static let enabled = "enabled"
        static let message = "message"
        static let grace = "graceSeconds"
        static let cooldown = "cooldownSeconds"
        static let domains = "domains"
        static let allowlist = "allowlist"
    }

    static let defaultMessage = "You have work to do. Close YouTube."
    static let defaultDomains = "youtube.com"
    static let defaultAllowlist = "lecture, tutorial, course, eecs, walkthrough"

    static func register() {
        defaults.register(defaults: [
            Key.enabled: true,
            Key.message: defaultMessage,
            Key.grace: 45,
            Key.cooldown: 600,
            Key.domains: defaultDomains,
            Key.allowlist: defaultAllowlist,
        ])
    }

    static var enabled: Bool {
        get { defaults.bool(forKey: Key.enabled) }
        set { defaults.set(newValue, forKey: Key.enabled) }
    }
    static var message: String { defaults.string(forKey: Key.message) ?? defaultMessage }
    static var grace: TimeInterval { max(0, defaults.double(forKey: Key.grace)) }
    static var cooldown: TimeInterval { max(0, defaults.double(forKey: Key.cooldown)) }
    static var domains: [String] { terms(defaults.string(forKey: Key.domains)) }
    static var allowlist: [String] { terms(defaults.string(forKey: Key.allowlist)) }

    /// Seconds spent on distracting sites today; resets when the date changes.
    static func addDistractedTime(_ seconds: TimeInterval) {
        let today = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        if defaults.double(forKey: "distractedDay") != today {
            defaults.set(today, forKey: "distractedDay")
            defaults.set(0.0, forKey: "distractedSeconds")
        }
        defaults.set(defaults.double(forKey: "distractedSeconds") + seconds, forKey: "distractedSeconds")
    }
    static var distractedMinutesToday: Int { Int(defaults.double(forKey: "distractedSeconds") / 60) }

    /// Splits on commas/newlines, lowercases, drops blanks.
    private static func terms(_ raw: String?) -> [String] {
        (raw ?? "")
            .split(whereSeparator: { $0 == "," || $0.isNewline })
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
    }
}
