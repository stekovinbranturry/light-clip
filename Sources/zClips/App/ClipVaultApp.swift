import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotKeyService = GlobalHotKeyService()
    private var hotKeyObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        hotKeyService.registerSavedShortcut()
        hotKeyObserver = NotificationCenter.default.addObserver(
            forName: .hotKeyShortcutDidChange,
            object: nil,
            queue: .main
        ) { [hotKeyService] _ in
            hotKeyService.registerSavedShortcut()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyObserver {
            NotificationCenter.default.removeObserver(hotKeyObserver)
        }
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
            StatusBarIconView()
                .onReceive(NotificationCenter.default.publisher(for: .showHistoryWindow)) { _ in
                    showHistoryWindow()
                }
        }
        .menuBarExtraStyle(.menu)

        Window("zClips History", id: "history") {
            ContentView(store: store)
                .frame(width: 780, height: 540)
                .background(HistoryPanelWindowConfigurator())
                .onAppear {
                    store.startMonitoring()
                }
        }
        .windowResizability(.contentSize)

        Window("偏好设置", id: "preferences") {
            PreferencesView()
                .frame(width: 520, height: 260)
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

private struct StatusBarIconView: View {
    var body: some View {
        Image(nsImage: .statusBarIcon)
            .resizable()
            .interpolation(.high)
            .frame(width: 19, height: 19)
            .frame(width: 22, height: 18)
            .accessibilityLabel("zClips")
    }
}

private extension NSImage {
    static var statusBarIcon: NSImage {
        if let image = NSImage(named: "StatusBarIconTemplate") {
            image.isTemplate = true
            image.size = NSSize(width: 19, height: 19)
            return image
        }

        let fallback = NSImage(systemSymbolName: "z.square", accessibilityDescription: "zClips") ?? NSImage()
        fallback.isTemplate = true
        fallback.size = NSSize(width: 19, height: 19)
        return fallback
    }
}
