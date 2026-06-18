import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount: Int
    private let onNewItem: (ClipboardItem) -> Void

    init(onNewItem: @escaping (ClipboardItem) -> Void) {
        self.onNewItem = onNewItem
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let item = readCurrentItem() {
            onNewItem(item)
        }
    }

    private func readCurrentItem() -> ClipboardItem? {
        if let filePaths = pasteboard.propertyList(forType: .fileNames) as? [String],
           !filePaths.isEmpty {
            return ClipboardItem(
                id: UUID(),
                kind: .file,
                filePaths: filePaths,
                createdAt: Date()
            )
        }

        if let fileURLs = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        ) as? [NSURL],
           !fileURLs.isEmpty {
            return ClipboardItem(
                id: UUID(),
                kind: .file,
                filePaths: fileURLs.compactMap(\.path),
                createdAt: Date()
            )
        }

        if let image = NSImage(pasteboard: pasteboard),
           let pngData = image.pngData {
            let bitmap = NSBitmapImageRep(data: pngData)
            return ClipboardItem(
                id: UUID(),
                kind: .image,
                text: nil,
                imageData: pngData,
                imagePixelWidth: bitmap?.pixelsWide,
                imagePixelHeight: bitmap?.pixelsHigh,
                createdAt: Date()
            )
        }

        if let text = pasteboard.string(forType: .string),
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ClipboardItem(
                id: UUID(),
                kind: .text,
                text: text,
                imageData: nil,
                createdAt: Date()
            )
        }

        return nil
    }
}
