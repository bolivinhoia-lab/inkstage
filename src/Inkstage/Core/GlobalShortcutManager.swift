import AppKit
import Carbon

// MARK: - Shortcut Definitions
enum InkstageShortcut: String, CaseIterable {
    // Global shortcuts
    case annotateScreen = "annotateScreen"
    case annotateNoControls = "annotateNoControls"
    case highlightCursor = "highlightCursor"
    case spotlightCursor = "spotlightCursor"
    case zoomCursor = "zoomCursor"
    case showShortcuts = "showShortcuts"
    
    var keyCombo: String {
        switch self {
        case .annotateScreen: return "⌃A"
        case .annotateNoControls: return "⌃⌥A"
        case .highlightCursor: return "⌃S"
        case .spotlightCursor: return "⌃L"
        case .zoomCursor: return "⌃Z"
        case .showShortcuts: return "/"
        }
    }
    
    var description: String {
        switch self {
        case .annotateScreen: return "Annotate Screen"
        case .annotateNoControls: return "Annotate Without Controls"
        case .highlightCursor: return "Highlight Cursor"
        case .spotlightCursor: return "Spotlight Cursor"
        case .zoomCursor: return "Zoom Cursor"
        case .showShortcuts: return "Show Shortcuts"
        }
    }
}

// MARK: - Annotation Mode Shortcuts
enum AnnotationShortcut: String, CaseIterable {
    case color1 = "color1"
    case color2 = "color2"
    case color3 = "color3"
    case color4 = "color4"
    case color5 = "color5"
    case freeHand = "freeHand"
    case arrow = "arrow"
    case rectangle = "rectangle"
    case circle = "circle"
    case text = "text"
    case highlighter = "highlighter"
    case clearAll = "clearAll"
    case undo = "undo"
    case redo = "redo"
    case toggleWhiteboard = "toggleWhiteboard"
    case exitMode = "exitMode"
    
    var key: String {
        switch self {
        case .color1: return "1"
        case .color2: return "2"
        case .color3: return "3"
        case .color4: return "4"
        case .color5: return "5"
        case .freeHand: return "F"
        case .arrow: return "A"
        case .rectangle: return "R"
        case .circle: return "C"
        case .text: return "T"
        case .highlighter: return "H"
        case .clearAll: return "⌫"
        case .undo: return "⌘Z"
        case .redo: return "⇧⌘Z"
        case .toggleWhiteboard: return "W"
        case .exitMode: return "ESC"
        }
    }
    
    var description: String {
        switch self {
        case .color1: return "Color 1 (Cyan)"
        case .color2: return "Color 2 (Rose)"
        case .color3: return "Color 3 (Lime)"
        case .color4: return "Color 4 (Yellow)"
        case .color5: return "Color 5 (Violet)"
        case .freeHand: return "Free Hand"
        case .arrow: return "Arrow"
        case .rectangle: return "Rectangle"
        case .circle: return "Circle"
        case .text: return "Text"
        case .highlighter: return "Highlighter"
        case .clearAll: return "Clear All"
        case .undo: return "Undo"
        case .redo: return "Redo"
        case .toggleWhiteboard: return "Toggle Whiteboard"
        case .exitMode: return "Exit Mode"
        }
    }
}

class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var localMonitor: Any?
    private var globalMonitor: Any?
    
    // Track Fn key state for interactive mode
    private var isFnKeyPressed: Bool = false
    
    // Favorite colors for 1-5 shortcuts
    private let favoriteColors: [NSColor] = [
        .systemCyan,
        .systemPink,
        .systemGreen,
        .systemYellow,
        .systemPurple
    ]

    func setup() {
        print("🔧 GlobalShortcutManager.setup() called")

        // Remove any existing monitors first
        removeMonitors()

        // Setup local monitor (works when app is active)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            if self?.handleEvent(event) == true {
                return nil
            }
            return event
        }

        // Setup global monitor for global shortcuts (⌃A, ⌃S, etc.)
        setupGlobalEventTap()

        print("✅ Monitors registered - local: \(localMonitor != nil), eventTap: \(eventTap != nil)")
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
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            }
            eventTap = nil
        }
    }
    
    private func setupGlobalEventTap() {
        // Create event tap for global shortcuts
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                return GlobalShortcutManager.handleCGEvent(proxy: proxy, type: type, event: event, refcon: refcon)
            },
            userInfo: nil
        ) else {
            print("❌ Failed to create event tap - may need accessibility permissions")
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        }
        CGEvent.tapEnable(tap: tap, enable: true)
    }
    
    static func handleCGEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        // Only handle key down events
        guard type == .keyDown else {
            return Unmanaged.passRetained(event)
        }
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        // Check for Control-based global shortcuts
        let isControl = flags.contains(.maskControl)
        let isOption = flags.contains(.maskAlternate)
        let isCommand = flags.contains(.maskCommand)
        let isShift = flags.contains(.maskShift)
        
        // ⌃A - Annotate Screen
        if isControl && !isOption && !isCommand && !isShift && keyCode == 0 {
            DispatchQueue.main.async {
                AppStateManager.shared.toggleDrawing()
            }
            return nil // Consume event
        }
        
        // ⌃⌥A - Annotate Without Controls
        if isControl && isOption && !isCommand && !isShift && keyCode == 0 {
            DispatchQueue.main.async {
                AppStateManager.shared.toggleDrawingWithoutControls()
            }
            return nil
        }
        
        // ⌃S - Highlight Cursor
        if isControl && !isOption && !isCommand && !isShift && keyCode == 1 {
            DispatchQueue.main.async {
                AppStateManager.shared.toggleCursorHighlight()
            }
            return nil
        }
        
        // ⌃L - Spotlight
        if isControl && !isOption && !isCommand && !isShift && keyCode == 37 {
            DispatchQueue.main.async {
                AppStateManager.shared.toggleSpotlight()
            }
            return nil
        }
        
        // ⌃Z - Zoom
        if isControl && !isOption && !isCommand && !isShift && keyCode == 6 {
            DispatchQueue.main.async {
                AppStateManager.shared.toggleZoom()
            }
            return nil
        }
        
        return Unmanaged.passRetained(event)
    }

    /// Returns true if the event was handled and should not propagate
    @discardableResult
    private func handleEvent(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // Handle Fn key for interactive mode
        if event.type == .flagsChanged {
            let isFnPressed = modifiers.contains(.function)
            if isFnPressed != isFnKeyPressed {
                isFnKeyPressed = isFnPressed
                if AppStateManager.shared.isDrawing {
                    if isFnPressed {
                        AppStateManager.shared.enableInteractiveMode()
                    } else {
                        AppStateManager.shared.disableInteractiveMode()
                    }
                }
            }
            return false
        }
        
        // ESC key (keyCode 53)
        if event.keyCode == 53 {
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
        
        // / (slash) - Show Shortcuts Overlay (when not in text field)
        if event.characters == "/" && !modifiers.contains(.command) && !modifiers.contains(.control) {
            if !OverlayWindowManager.shared.isTextFieldActive {
                ShortcutOverlay.shared.show()
                return true
            }
        }

        // Only handle annotation shortcuts if in drawing mode
        guard AppStateManager.shared.isDrawing else { return false }
        
        // Check for annotation shortcuts
        return handleAnnotationShortcut(event, modifiers: modifiers)
    }
    
    private func handleAnnotationShortcut(_ event: NSEvent, modifiers: NSEvent.ModifierFlags) -> Bool {
        let isCommand = modifiers.contains(.command)
        let isShift = modifiers.contains(.shift)
        let _ = modifiers.contains(.control)
        let _ = modifiers.contains(.option)
        
        // Colors 1-5
        if let char = event.characters?.first {
            switch char {
            case "1":
                selectColor(at: 0)
                return true
            case "2":
                selectColor(at: 1)
                return true
            case "3":
                selectColor(at: 2)
                return true
            case "4":
                selectColor(at: 3)
                return true
            case "5":
                selectColor(at: 4)
                return true
            case "f", "F":
                AppStateManager.shared.selectTool(.pen)
                FloatingToolbarController.shared.updateToolSelection(.pen)
                return true
            case "a", "A":
                AppStateManager.shared.selectTool(.line)
                FloatingToolbarController.shared.updateToolSelection(.line)
                return true
            case "r", "R":
                AppStateManager.shared.selectTool(.rectangle)
                FloatingToolbarController.shared.updateToolSelection(.rectangle)
                return true
            case "c", "C":
                AppStateManager.shared.selectTool(.circle)
                FloatingToolbarController.shared.updateToolSelection(.circle)
                return true
            case "t", "T":
                AppStateManager.shared.selectTool(.text)
                FloatingToolbarController.shared.updateToolSelection(.text)
                return true
            case "h", "H":
                AppStateManager.shared.selectTool(.marker)
                FloatingToolbarController.shared.updateToolSelection(.marker)
                return true
            case "w", "W":
                AppStateManager.shared.toggleWhiteboard()
                return true
            default:
                break
            }
        }
        
        // Clear All (Delete key - keyCode 117 or 51)
        if event.keyCode == 117 || event.keyCode == 51 {
            if !isCommand && !isShift {
                OverlayWindowManager.shared.clearAnnotations()
                ToastManager.shared.show(message: "🧹 Cleared")
                return true
            }
        }
        
        // Undo: ⌘Z
        if isCommand && !isShift && event.keyCode == 6 {
            OverlayWindowManager.shared.undo()
            return true
        }
        
        // Redo: ⇧⌘Z
        if isCommand && isShift && event.keyCode == 6 {
            OverlayWindowManager.shared.redo()
            return true
        }
        
        return false
    }
    
    private func selectColor(at index: Int) {
        guard index < favoriteColors.count else { return }
        let color = favoriteColors[index]
        SettingsManager.shared.penColor = color
        FloatingToolbarController.shared.updateColorSelection(color)
        
        let colorNames = ["Cyan", "Rose", "Lime", "Yellow", "Violet"]
        ToastManager.shared.show(message: "🎨 \(colorNames[index])")
    }
}

// MARK: - Key Code References
extension NSEvent {
    static let escKeyCode: UInt16 = 53
    static let deleteKeyCode: UInt16 = 51
    static let forwardDeleteKeyCode: UInt16 = 117
    static let zKeyCode: UInt16 = 6
    static let aKeyCode: UInt16 = 0
    static let sKeyCode: UInt16 = 1
    static let lKeyCode: UInt16 = 37
}
