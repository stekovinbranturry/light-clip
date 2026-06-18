import AppKit
import SwiftUI

struct StatusMenuView: View {
    @ObservedObject var store: ClipboardStore
    @Environment(\.openWindow) private var openWindow

    @ViewBuilder
    var body: some View {
        if store.items.isEmpty {
            Text("No saved clips")
                .foregroundStyle(.secondary)
        } else {
            ForEach(store.items.prefix(8)) { item in
                Button {
                    store.copyToPasteboard(item)
                } label: {
                    Label(item.menuTitle, systemImage: item.menuSystemImage)
                }
            }
        }

        Divider()

        Button("Open History    ⌥ Space") {
            openHistoryWindow()
        }

        Button("Clear History", role: .destructive) {
            store.clear()
        }
        .disabled(store.items.isEmpty)

        Divider()

        Button("Quit ClipVault") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func openHistoryWindow() {
        store.selectLatestItem()
        openWindow(id: "history")
        NSApp.activate(ignoringOtherApps: true)
    }
}

private extension ClipboardItem {
    var menuSystemImage: String {
        switch kind {
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .file: return "doc"
        }
    }
}
