import Foundation
import AppKit
import Carbon

struct KeyboardShortcut: Codable, Equatable {
    var keyCode: Int
    var modifiers: NSEvent.ModifierFlags.RawValue
    var isDoubleTap: Bool
    
    var modifierFlags: NSEvent.ModifierFlags {
        return NSEvent.ModifierFlags(rawValue: modifiers)
    }
    
    static let defaultShortcut = KeyboardShortcut(
        keyCode: 46, // 'M'
        modifiers: NSEvent.ModifierFlags([.command, .control]).rawValue,
        isDoubleTap: false
    )
    
    var displayString: String {
        var str = ""
        let flags = modifierFlags
        if flags.contains(.control) { str += "⌃" }
        if flags.contains(.option) { str += "⌥" }
        if flags.contains(.shift) { str += "⇧" }
        if flags.contains(.command) { str += "⌘" }
        
        str += keyName(for: keyCode)
        
        if isDoubleTap {
            str += " (x2)"
        }
        
        return str
    }
    
    private func keyName(for keyCode: Int) -> String {
        // Simple mapping, can be expanded
        switch keyCode {
        case 36: return "↩"
        case 48: return "⇥"
        case 49: return "Space"
        case 51: return "⌫"
        case 53: return "⎋"
        case 123: return "←"
        case 124: return "→"
        case 125: return "↓"
        case 126: return "↑"
        default:
            if let scalar = UnicodeScalar(keyCode), keyCode < 128 {
                let char = String(format: "%C", UInt16(scalar.value)).uppercased()
                // This is a very rough way to get key name, for better results use TISCopyCurrentKeyboardLayoutInputSource
                // But for M, P, etc. it works mostly.
                // Let's use a more robust mapping for common keys if possible.
                return getSymbol(for: keyCode)
            }
            return "Key \(keyCode)"
        }
    }
    
    private func getSymbol(for keyCode: Int) -> String {
        guard let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue() else {
            return "Key \(keyCode)"
        }
        let layoutData = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        let dataRef = unsafeBitCast(layoutData, to: CFData.self)
        let dataPtr = CFDataGetBytePtr(dataRef)
        let keyboardLayout = unsafeBitCast(dataPtr, to: UnsafePointer<UCKeyboardLayout>.self)
        
        var deadKeys: UInt32 = 0
        let maxLen = 4
        var actualLen = 0
        var unicodeChars = [UniChar](repeating: 0, count: maxLen)
        
        UCKeyTranslate(keyboardLayout,
                       UInt16(keyCode),
                       UInt16(kUCKeyActionDisplay),
                       0,
                       UInt32(LMGetKbdType()),
                       UInt32(kUCKeyTranslateNoDeadKeysBit),
                       &deadKeys,
                       maxLen,
                       &actualLen,
                       &unicodeChars)
        
        return String(utf16CodeUnits: unicodeChars, count: actualLen).uppercased()
    }
}
