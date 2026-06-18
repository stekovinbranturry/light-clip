import AppKit
import Foundation

extension String {
    func singleLinePreview(limit: Int) -> String {
        let collapsed = components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        guard collapsed.count > limit else { return collapsed }
        return String(collapsed.prefix(max(0, limit - 3))) + "..."
    }
}

extension Date {
    var shortTimeString: String {
        Self.shortTimeFormatter.string(from: self)
    }

    var fullString: String {
        Self.fullFormatter.string(from: self)
    }

    var relativeString: String {
        Self.relativeFormatter.localizedString(for: self, relativeTo: Date())
    }

    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let fullFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
}
