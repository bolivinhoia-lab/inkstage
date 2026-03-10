import AppKit

class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    func setup() {
        // Setup local monitor (works when app is active)
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            self?.handleEvent(event)
            return event
        }
        
        // Setup global monitor (works even when app is not key)
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleEvent(event)
        }
    }
    
    private func handleEvent(_ event: NSEvent) {
        // ESC key (keyCode 53)
        if event.keyCode == 53 {
            DispatchQueue.main.async {
                print("🎯 ESC pressed - deactivating all modes")
                AppStateManager.shared.handleEscape()
            }
            return
        }
        
        // Only handle tool shortcuts if in drawing mode
        guard AppStateManager.shared.isDrawing else { return }
        
        switch event.characters?.lowercased() {
        case "p":
            AppStateManager.shared.selectTool(.pen)
        case "m":
            AppStateManager.shared.selectTool(.marker)
        case "l":
            AppStateManager.shared.selectTool(.line)
        case "r":
            AppStateManager.shared.selectTool(.rectangle)
        case "o":
            AppStateManager.shared.selectTool(.circle)
        case "t":
            AppStateManager.shared.selectTool(.text)
        case "e":
            AppStateManager.shared.selectTool(.eraser)
        default:
            break
        }
    }
}

// MARK: - NSEvent Key Codes
extension NSEvent {
    static let escKeyCode: UInt16 = 53
}
