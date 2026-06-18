import AppKit
import Carbon
import Foundation

struct HotKeyShortcut: Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var keyEquivalent: String

    static let defaultShortcut = HotKeyShortcut(
        keyCode: UInt32(kVK_Space),
        modifiers: UInt32(optionKey),
        keyEquivalent: "Space"
    )

    static var saved: HotKeyShortcut {
        get {
            let defaults = UserDefaults.standard
            guard defaults.object(forKey: keyCodeKey) != nil else {
                return .defaultShortcut
            }

            let keyCode = UInt32(defaults.integer(forKey: keyCodeKey))
            let modifiers = UInt32(defaults.integer(forKey: modifiersKey))
            let keyEquivalent = defaults.string(forKey: keyEquivalentKey) ?? "Space"

            guard modifiers != 0, !keyEquivalent.isEmpty else {
                return .defaultShortcut
            }

            return HotKeyShortcut(keyCode: keyCode, modifiers: modifiers, keyEquivalent: keyEquivalent)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(Int(newValue.keyCode), forKey: keyCodeKey)
            defaults.set(Int(newValue.modifiers), forKey: modifiersKey)
            defaults.set(newValue.keyEquivalent, forKey: keyEquivalentKey)
            NotificationCenter.default.post(name: .hotKeyShortcutDidChange, object: nil)
        }
    }

    var displayText: String {
        "\(modifierDisplay)\(keyEquivalent)"
    }

    private var modifierDisplay: String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("^") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        return parts.joined()
    }

    private static let keyCodeKey = "HotKeyShortcut.keyCode"
    private static let modifiersKey = "HotKeyShortcut.modifiers"
    private static let keyEquivalentKey = "HotKeyShortcut.keyEquivalent"
}

extension Notification.Name {
    static let hotKeyShortcutDidChange = Notification.Name("zClipsHotKeyShortcutDidChange")
}

extension NSEvent.ModifierFlags {
    var carbonHotKeyModifiers: UInt32 {
        var result: UInt32 = 0
        if contains(.control) { result |= UInt32(controlKey) }
        if contains(.option) { result |= UInt32(optionKey) }
        if contains(.shift) { result |= UInt32(shiftKey) }
        if contains(.command) { result |= UInt32(cmdKey) }
        return result
    }
}
