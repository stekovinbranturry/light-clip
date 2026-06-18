import AppKit
import SwiftUI

enum HistoryPanelWindowController {
    static let title = "zClips History"

    static var isHistoryWindowVisible: Bool {
        NSApp.windows.contains { window in
            window.title == title && window.isVisible
        }
    }

    static func closeHistoryWindows() {
        NSApp.windows
            .filter { $0.title == title }
            .forEach { $0.close() }
    }
}

struct HistoryPanelWindowConfigurator: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            context.coordinator.configure(window)
        }
    }

    final class Coordinator {
        private weak var configuredWindow: NSWindow?
        private var resignObserver: NSObjectProtocol?

        func configure(_ window: NSWindow) {
            guard configuredWindow !== window else { return }

            configuredWindow = window
            window.title = HistoryPanelWindowController.title
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.isMovableByWindowBackground = true
            window.level = .floating
            window.collectionBehavior.insert(.transient)
            window.collectionBehavior.insert(.moveToActiveSpace)
            window.backgroundColor = .white
            window.hasShadow = true
            window.setContentSize(NSSize(width: 560, height: 420))
            window.center()

            resignObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didResignKeyNotification,
                object: window,
                queue: .main
            ) { _ in
                window.close()
            }
        }

        deinit {
            if let resignObserver {
                NotificationCenter.default.removeObserver(resignObserver)
            }
        }
    }
}
