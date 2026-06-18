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
        ZStack {
            RoundedRectangle(cornerRadius: 3.4, style: .continuous)
                .stroke(.primary, lineWidth: 1.65)
                .frame(width: 17, height: 17)

            ZMark()
                .stroke(.primary, style: StrokeStyle(lineWidth: 2.05, lineCap: .round, lineJoin: .round))
                .frame(width: 10, height: 10)
        }
        .frame(width: 22, height: 18)
        .accessibilityLabel("zClips")
    }
}

private struct ZMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.12))
        return path
    }
}
