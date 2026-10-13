import AppKit
import SwiftUI

/// Floating always-on-top panel that shows over every app and Space, including full-screen ones.
final class NagPanel {
    static let autoDismiss: TimeInterval = 30
    private var panel: NSPanel?
    private var dismissTimer: Timer?

    func show(message: String, minutesToday: Int) {
        close()
        let view = NagView(message: message, minutes: minutesToday,
                           closeTab: { [weak self] in Monitor.closeActiveTab(); self?.close() },
                           dismiss: { [weak self] in self?.close() })
        let host = NSHostingView(rootView: view)
        host.setFrameSize(host.fittingSize)

        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: host.fittingSize),
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.contentView = host
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .screenSaver
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.center()
        panel.orderFrontRegardless()
        NSSound(named: "Basso")?.play()
        self.panel = panel

        dismissTimer = Timer.scheduledTimer(withTimeInterval: Self.autoDismiss, repeats: false) { [weak self] _ in
            self?.close()
        }
    }

    private func close() {
        dismissTimer?.invalidate()
        panel?.orderOut(nil)
        panel = nil
    }
}

private struct NagView: View {
    let message: String
    let minutes: Int
    let closeTab: () -> Void
    let dismiss: () -> Void

    @State private var pulse = false
    @State private var remaining: Double = 1

    private let red = Color(red: 1.0, green: 0.23, blue: 0.19)

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().stroke(.white.opacity(0.12), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: remaining)
                    .stroke(red, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "exclamationmark")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(red)
                    .scaleEffect(pulse ? 1.15 : 0.9)
            }
            .frame(width: 84, height: 84)

            VStack(spacing: 6) {
                Text("BACK TO WORK")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white)
                Text(message)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("\(minutes) min on distractions today")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(red)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(red.opacity(0.15), in: Capsule())

            VStack(spacing: 8) {
                Button(action: closeTab) {
                    Text("Close the tab")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(red, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                Button("I'll do it myself", action: dismiss)
                    .buttonStyle(.plain)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(28)
        .frame(width: 360)
        .background(
            LinearGradient(colors: [Color(red: 0.16, green: 0.05, blue: 0.07), Color(red: 0.05, green: 0.05, blue: 0.09)],
                           startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(red.opacity(pulse ? 0.9 : 0.35), lineWidth: 2))
        .shadow(color: red.opacity(pulse ? 0.55 : 0.15), radius: pulse ? 28 : 12)
        .padding(36)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { pulse = true }
            withAnimation(.linear(duration: NagPanel.autoDismiss)) { remaining = 0 }
        }
    }
}
