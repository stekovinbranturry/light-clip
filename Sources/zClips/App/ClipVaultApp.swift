import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotKeyService = GlobalHotKeyService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        hotKeyService.registerOptionSpace()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyService.unregister()
    }

    func applicationDidResignActive(_ notification: Notification) {
        HistoryPanelWindowController.closeHistoryWindows()
    }
}

@main
struct zClipsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.openWindow) private var openWindow
    @StateObject private var store = ClipboardStore()

    var body: some Scene {
        MenuBarExtra {
            StatusMenuView(store: store)
                .onAppear {
                    store.startMonitoring()
                }
        } label: {
            Label("zClips", systemImage: "doc.on.clipboard")
                .onReceive(NotificationCenter.default.publisher(for: .showHistoryWindow)) { _ in
                    showHistoryWindow()
                }
        }
        .menuBarExtraStyle(.menu)

        Window("zClips History", id: "history") {
            ContentView(store: store)
                .frame(minWidth: 520, minHeight: 380)
                .background(HistoryPanelWindowConfigurator())
                .onAppear {
                    store.startMonitoring()
                }
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .pasteboard) {
                Button("Copy") {
                    store.copySelectedItemToPasteboard()
                }
                .keyboardShortcut("c")
                .disabled(store.selectedItem == nil)
            }

            CommandGroup(after: .pasteboard) {
                Button("Find") {
                    NotificationCenter.default.post(name: .focusClipboardSearch, object: nil)
                }
                .keyboardShortcut("f")
            }
        }
    }

    private func showHistoryWindow() {
        if HistoryPanelWindowController.isHistoryWindowVisible {
            HistoryPanelWindowController.closeHistoryWindows()
            return
        }

        store.selectLatestItem()
        openWindow(id: "history")
        NSApp.activate(ignoringOtherApps: true)
    }
}
