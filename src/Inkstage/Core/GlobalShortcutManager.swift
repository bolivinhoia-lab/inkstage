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

        // Global mode shortcuts (⌘⇧A, ⌘⇧C, ⌘⇧S, ⌘⇧Z, ⌘⇧W)
        // Note: These require the app to be active OR use CGEventTap for true global
        // For now, we handle them when app is active via local monitor
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isCmdShift = modifiers == [.command, .shift]

        if isCmdShift {
            switch event.keyCode {
            case 0: // A - Drawing
                print("🎯 ⌘⇧A pressed - toggle drawing")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleDrawing()
                }
                return true
            case 8: // C - Cursor Highlight
                print("🎯 ⌘⇧C pressed - toggle cursor highlight")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleCursorHighlight()
                }
                return true
            case 1: // S - Spotlight
                print("🎯 ⌘⇧S pressed - toggle spotlight")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleSpotlight()
                }
                return true
            case 6: // Z - Zoom
                print("🎯 ⌘⇧Z pressed - toggle zoom")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleZoom()
                }
                return true
            case 13: // W - Whiteboard
                print("🎯 ⌘⇧W pressed - toggle whiteboard")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleWhiteboard()
                }
                return true
            default:
                break
            }
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

    // Modifier flags
    static let cmdShift: NSEvent.ModifierFlags = [.command, .shift]

    // Key codes for global shortcuts
    static let aKeyCode: UInt16 = 0
    static let cKeyCode: UInt16 = 8
    static let sKeyCode: UInt16 = 1
    static let zKeyCode: UInt16 = 6
    static let wKeyCode: UInt16 = 13
}
