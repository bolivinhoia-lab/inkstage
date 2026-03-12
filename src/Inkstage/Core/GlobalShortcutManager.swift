import AppKit

class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var localMonitor: Any?
    private var globalMonitor: Any?

    func setup() {
        print("🔧 GlobalShortcutManager.setup() called")

        // Remove any existing monitors first
        removeMonitors()

        // Setup local monitor (works when app is active)
        // IMPORTANT: Use .keyDown only to avoid conflicts with flagsChanged
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            print("⌨️ Local monitor - keyCode: \(event.keyCode), modifiers: \(event.modifierFlags)")
            if self?.handleEvent(event) == true {
                // Event was handled, don't propagate
                return nil
            }
            return event
        }

        // Setup global monitor (works even when app is not key)
        // Note: global monitor only receives events, cannot block them
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            print("🌍 Global monitor - keyCode: \(event.keyCode)")
            _ = self?.handleEvent(event)
        }

        print("✅ Monitors registered - local: \(localMonitor != nil), global: \(globalMonitor != nil)")
    }

    func removeMonitors() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
    }

    /// Returns true if the event was handled and should not propagate
    @discardableResult
    private func handleEvent(_ event: NSEvent) -> Bool {
        // ESC key (keyCode 53)
        if event.keyCode == 53 {
            // If a text field is active, let it handle ESC first
            if OverlayWindowManager.shared.isTextFieldActive {
                print("📝 ESC ignored - text field active")
                return false
            }

            print("🎯 ESC pressed - deactivating all modes")
            DispatchQueue.main.async {
                AppStateManager.shared.handleEscape()
            }
            return true
        }
        
        // Only handle tool shortcuts if in drawing mode
        guard AppStateManager.shared.isDrawing else { return false }

        switch event.characters?.lowercased() {
        case "p":
            AppStateManager.shared.selectTool(.pen)
            return true
        case "m":
            AppStateManager.shared.selectTool(.marker)
            return true
        case "l":
            AppStateManager.shared.selectTool(.line)
            return true
        case "r":
            AppStateManager.shared.selectTool(.rectangle)
            return true
        case "o":
            AppStateManager.shared.selectTool(.circle)
            return true
        case "t":
            AppStateManager.shared.selectTool(.text)
            return true
        case "e":
            AppStateManager.shared.selectTool(.eraser)
            return true
        default:
            return false
        }
    }
}

// MARK: - NSEvent Key Codes
extension NSEvent {
    static let escKeyCode: UInt16 = 53
}
