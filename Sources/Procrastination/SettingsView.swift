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
            Section {
                Toggle("Enabled", isOn: $enabled)
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { on in
                        do {
                            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
                        } catch {
                            launchAtLogin = SMAppService.mainApp.status == .enabled
                        }
                    }
            }

            Section("Popup") {
                TextField("Message", text: $message, axis: .vertical)
                    .lineLimit(1...3)
                Stepper("Show after \(grace) seconds", value: $grace, in: 5...3600, step: 5)
                Stepper("Wait \(cooldown / 60) min between popups", value: $cooldown, in: 60...7200, step: 60)
            }

            Section {
                TextField("Distracting domains", text: $domains, axis: .vertical)
                    .lineLimit(1...3)
            } header: {
                Text("Sites")
            } footer: {
                Text("Comma-separated, e.g. youtube.com, reddit.com")
            }

            Section {
                TextField("Allowed title words", text: $allowlist, axis: .vertical)
                    .lineLimit(1...4)
            } header: {
                Text("Study allowlist")
            } footer: {
                Text("A tab is ignored if its title contains any of these. Keep it tight: \"Joe Rogan lecture\" would slip through.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 520)
        .fixedSize(horizontal: false, vertical: true)
    }
}
