import AppKit
import Carbon
import SwiftUI

struct PreferencesView: View {
    @State private var shortcut = HotKeyShortcut.saved

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("偏好设置")
                .font(.system(size: 22, weight: .semibold))

            HStack(spacing: 14) {
                Text("唤醒快捷键")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(width: 96, alignment: .leading)

                HotKeyRecorder(shortcut: $shortcut)
                    .frame(width: 320, height: 32)
            }

            Text("点击输入框后按下新的组合键。建议使用 ⌥、⌘ 或 ⌃ 搭配一个按键。")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(28)
        .onChange(of: shortcut) { newValue in
            HotKeyShortcut.saved = newValue
        }
    }
}

private struct HotKeyRecorder: NSViewRepresentable {
    @Binding var shortcut: HotKeyShortcut

    func makeNSView(context: Context) -> HotKeyRecorderField {
        let field = HotKeyRecorderField()
        field.onShortcutChange = { shortcut in
            self.shortcut = shortcut
        }
        field.stringValue = shortcut.displayText
        return field
    }

    func updateNSView(_ nsView: HotKeyRecorderField, context: Context) {
        nsView.stringValue = shortcut.displayText
    }
}

private final class HotKeyRecorderField: NSView {
    var onShortcutChange: ((HotKeyShortcut) -> Void)?
    var stringValue = "" {
        didSet {
            needsDisplay = true
        }
    }

    init() {
        super.init(frame: .zero)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func resignFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let bounds = bounds.insetBy(dx: 0.5, dy: 0.5)
        let backgroundPath = NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6)
        NSColor.controlBackgroundColor.setFill()
        backgroundPath.fill()

        let strokeColor: NSColor = window?.firstResponder === self ? .controlAccentColor : .separatorColor
        strokeColor.setStroke()
        backgroundPath.lineWidth = window?.firstResponder === self ? 1.5 : 1
        backgroundPath.stroke()

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.labelColor
        ]
        let attributed = NSAttributedString(string: stringValue, attributes: attributes)
        let textSize = attributed.size()
        let textRect = NSRect(
            x: bounds.midX - textSize.width / 2,
            y: bounds.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        attributed.draw(in: textRect)
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.carbonHotKeyModifiers
        guard modifiers != 0, !isModifierOnly(event.keyCode) else {
            NSSound.beep()
            return
        }

        let shortcut = HotKeyShortcut(
            keyCode: UInt32(event.keyCode),
            modifiers: modifiers,
            keyEquivalent: keyEquivalent(for: event)
        )
        stringValue = shortcut.displayText
        onShortcutChange?(shortcut)
    }

    private func isModifierOnly(_ keyCode: UInt16) -> Bool {
        [54, 55, 56, 57, 58, 59, 60, 61, 62, 63].contains(keyCode)
    }

    private func keyEquivalent(for event: NSEvent) -> String {
        switch Int(event.keyCode) {
        case kVK_Space:
            return "Space"
        case kVK_Return:
            return "Return"
        case kVK_Tab:
            return "Tab"
        case kVK_Escape:
            return "Esc"
        case kVK_Delete:
            return "Delete"
        case kVK_ForwardDelete:
            return "Forward Delete"
        case kVK_LeftArrow:
            return "←"
        case kVK_RightArrow:
            return "→"
        case kVK_UpArrow:
            return "↑"
        case kVK_DownArrow:
            return "↓"
        default:
            let text = event.charactersIgnoringModifiers?.uppercased() ?? ""
            return text.isEmpty ? "Key \(event.keyCode)" : text
        }
    }
}
