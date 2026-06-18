import AppKit
import Foundation

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []
    @Published var selectedItemID: ClipboardItem.ID?

    private let maximumItems = 80
    private var monitor: ClipboardMonitor?
    private let persistenceURL: URL

    init() {
        let supportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("zClips", isDirectory: true)

        self.persistenceURL = supportDirectory.appendingPathComponent("history.json")
        load()
    }

    var selectedItem: ClipboardItem? {
        guard let selectedItemID else { return items.first }
        return items.first { $0.id == selectedItemID } ?? items.first
    }

    func startMonitoring() {
        if monitor == nil {
            monitor = ClipboardMonitor { [weak self] item in
                self?.insert(item)
            }
        }
        monitor?.start()
    }

    func selectLatestItem() {
        selectedItemID = items.first?.id
    }

    func copyToPasteboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.kind {
        case .text:
            pasteboard.setString(item.text ?? "", forType: .string)
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        case .file:
            copyFilePathsToPasteboard(item.filePaths, pasteboard: pasteboard)
        }
    }

    func copySelectedItemToPasteboard() {
        guard let selectedItem else { return }
        copyToPasteboard(selectedItem)
    }

    func previewImage(_ item: ClipboardItem) {
        guard item.kind == .image, let imageData = item.imageData else { return }

        do {
            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("zClipsPreviews", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

            let url = directory.appendingPathComponent("\(item.id.uuidString).png")
            try imageData.write(to: url, options: [.atomic])
            NSWorkspace.shared.open(url)
        } catch {
            assertionFailure("Failed to preview image: \(error)")
        }
    }

    func delete(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        if selectedItemID == item.id {
            selectedItemID = items.first?.id
        }
        save()
    }

    func toggleFavorite(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isFavorite.toggle()
        save()
    }

    func clear() {
        items.removeAll()
        selectedItemID = nil
        save()
    }

    private func insert(_ item: ClipboardItem) {
        if isDuplicateOfMostRecent(item) {
            return
        }

        items.insert(item, at: 0)
        if items.count > maximumItems {
            items.removeLast(items.count - maximumItems)
        }
        selectedItemID = item.id
        save()
    }

    private func isDuplicateOfMostRecent(_ item: ClipboardItem) -> Bool {
        guard let first = items.first, first.kind == item.kind else { return false }

        switch item.kind {
        case .text:
            return first.text == item.text
        case .image:
            return first.imageData == item.imageData
        case .file:
            return first.filePaths == item.filePaths
        }
    }

    private func copyFilePathsToPasteboard(_ filePaths: [String], pasteboard: NSPasteboard) {
        let urls = filePaths.map { URL(fileURLWithPath: $0) }
        let pasteboardItems = urls.map { url in
            let item = NSPasteboardItem()
            item.setString(url.absoluteString, forType: .fileURL)
            return item
        }

        pasteboard.writeObjects(pasteboardItems)
        pasteboard.setPropertyList(filePaths, forType: .fileNames)
    }

    private func load() {
        do {
            let data = try Data(contentsOf: persistenceURL)
            items = try JSONDecoder().decode([ClipboardItem].self, from: data)
            selectedItemID = items.first?.id
        } catch {
            items = []
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: persistenceURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(items)
            try data.write(to: persistenceURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save clipboard history: \(error)")
        }
    }
}
