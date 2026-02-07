import Foundation
import AppKit
import Combine

class KeyboardShortcutManager: ObservableObject {
    static let shared = KeyboardShortcutManager()
    
    @Published var currentShortcut: KeyboardShortcut {
        didSet {
            saveShortcut()
        }
    }
    
    private let storageKey = "com.sticky.keyboardShortcut"
    private var lastTapTime: Date?
    private let doubleTapThreshold: TimeInterval = 0.3
    
    var onShortcutTriggered: (() -> Void)?
    
    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) {
            self.currentShortcut = saved
        } else {
            self.currentShortcut = .defaultShortcut
        }
    }
    
    private func saveShortcut() {
        if let data = try? JSONEncoder().encode(currentShortcut) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func handleEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let keyCode = Int(event.keyCode)
        
        if keyCode == currentShortcut.keyCode && flags.rawValue == currentShortcut.modifiers {
            if currentShortcut.isDoubleTap {
                let now = Date()
                if let last = lastTapTime, now.timeIntervalSince(last) < doubleTapThreshold {
                    lastTapTime = nil
                    onShortcutTriggered?()
                    return true
                } else {
                    lastTapTime = now
                    return false
                }
            } else {
                onShortcutTriggered?()
                return true
            }
        } else {
            // Reset last tap time if a different key is pressed
            lastTapTime = nil
        }
        
        return false
    }
}
