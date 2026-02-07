import SwiftUI
import AppKit

struct SettingsView: View {
    @StateObject private var shortcutManager = KeyboardShortcutManager.shared
    @State private var isRecording = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Keyboard Shortcut")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    ShortcutRecorderView(isRecording: $isRecording)
                        .frame(maxWidth: .infinity)
                    
                    Toggle("Double Tap", isOn: $shortcutManager.currentShortcut.isDoubleTap)
                        .toggleStyle(.checkbox)
                }
                
                Text("Press keys to record a new shortcut. Double tap requires pressing the shortcut twice quickly.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(20)
        .frame(width: 400, height: 300)
        .background(.regularMaterial)
    }
}

struct ShortcutRecorderView: View {
    @Binding var isRecording: Bool
    @StateObject private var manager = KeyboardShortcutManager.shared
    
    var body: some View {
        Button {
            isRecording.toggle()
        } label: {
            HStack {
                Text(manager.currentShortcut.displayString)
                    .monospaced()
                    .frame(maxWidth: .infinity)
                
                if isRecording {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isRecording ? Color.accentColor : Color.secondary.opacity(0.2))
            .foregroundColor(isRecording ? .white : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isRecording ? Color.white.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .background(KeyEventModifier(isRecording: $isRecording))
    }
}

struct KeyEventModifier: NSViewRepresentable {
    @Binding var isRecording: Bool
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: KeyEventModifier
        var monitor: Any?
        
        init(parent: KeyEventModifier) {
            self.parent = parent
            super.init()
            
            self.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self = self, self.parent.isRecording else { return event }
                
                let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                let keyCode = Int(event.keyCode)
                
                // Avoid recording modifier-only presses
                if keyCode == 54 || keyCode == 55 || keyCode == 56 || keyCode == 57 || keyCode == 59 || keyCode == 60 || keyCode == 61 || keyCode == 62 {
                    return event
                }
                
                DispatchQueue.main.async {
                    KeyboardShortcutManager.shared.currentShortcut = KeyboardShortcut(
                        keyCode: keyCode,
                        modifiers: flags.rawValue,
                        isDoubleTap: KeyboardShortcutManager.shared.currentShortcut.isDoubleTap
                    )
                    self.parent.isRecording = false
                }
                
                return nil
            }
        }
        
        deinit {
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }
}
