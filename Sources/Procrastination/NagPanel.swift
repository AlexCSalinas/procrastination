import AppKit
import SwiftUI

/// Floating always-on-top panel that shows over every app and Space, including full-screen ones.
final class NagPanel {
    private static let autoDismiss: TimeInterval = 30
    private var panel: NSPanel?
    private var dismissTimer: Timer?

    func show(message: String) {
        close()
        let view = NagView(message: message, dismiss: { [weak self] in self?.close() })
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
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("Back to work")
                .font(.system(size: 24, weight: .bold))
            Text(message)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button("Okay, okay", action: dismiss)
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)
        }
        .padding(28)
        .frame(width: 380)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.red.opacity(0.6), lineWidth: 2))
        .padding(16)
    }
}
