import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @AppStorage(Settings.Key.enabled) private var enabled = true
    @AppStorage(Settings.Key.message) private var message = Settings.defaultMessage
    @AppStorage(Settings.Key.grace) private var grace = 45
    @AppStorage(Settings.Key.cooldown) private var cooldown = 600
    @AppStorage(Settings.Key.domains) private var domains = Settings.defaultDomains
    @AppStorage(Settings.Key.allowlist) private var allowlist = Settings.defaultAllowlist
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Toggle("Enabled", isOn: $enabled)
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { on in
                    do {
                        if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
                    } catch {
                        launchAtLogin = SMAppService.mainApp.status == .enabled
                    }
                }
            TextField("Message", text: $message)
            Stepper("Grace period: \(grace)s", value: $grace, in: 5...3600, step: 5)
            Stepper("Cooldown between popups: \(cooldown / 60)m", value: $cooldown, in: 60...7200, step: 60)
            VStack(alignment: .leading) {
                Text("Distracting domains (comma-separated)")
                TextField("", text: $domains)
            }
            VStack(alignment: .leading) {
                Text("Allowed if tab title contains (comma-separated)")
                TextField("", text: $allowlist)
                Text("Keep this tight: \"Joe Rogan lecture\" would slip through.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(width: 440)
    }
}
