import AppKit
import Carbon

// MARK: - Global Shortcut Manager
class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()

    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var shortcutOverlay: ShortcutOverlayWindow?
    
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
        removeMonitors()
        
        // Setup local monitor (works when app is active)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            if self?.handleEvent(event) == true {
                return nil
            }
            return event
        }
        
        // Setup global monitor using NSEvent (works for app when it's key, but not truly global)
        // For true global shortcuts, we need Accessibility permissions
        // For now, rely on menu bar shortcuts which work via NSMenu
        
        print("✅ GlobalShortcutManager setup complete")
        
        // Check accessibility permissions
        checkAccessibilityPermissions()
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
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if accessibilityEnabled {
            print("✅ Accessibility permissions granted")
            setupTrueGlobalShortcuts()
        } else {
            print("⚠️ Accessibility permissions not granted - global shortcuts may not work")
            print("   Please enable Inkstage in System Preferences > Security & Privacy > Accessibility")
        }
    }
    
    private func setupTrueGlobalShortcuts() {
        // This uses NSEvent.addGlobalMonitor which works with Accessibility permissions
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            _ = self?.handleGlobalEvent(event)
        }
    }

    /// Handle local events (app is active)
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
                        // Enable interactive mode temporarily
                        print("🔓 Interactive mode ON")
                    } else {
                        print("🔒 Interactive mode OFF")
                    }
                }
            }
            return false
        }
        
        // Only handle key down from here
        guard event.type == .keyDown else { return false }
        
        // ESC key (keyCode 53)
        if event.keyCode == 53 {
            if OverlayWindowManager.shared.isTextFieldActive {
                return false
            }
            print("🎯 ESC pressed")
            DispatchQueue.main.async {
                AppStateManager.shared.handleEscape()
            }
            return true
        }
        
        // Check for Control-based shortcuts (⌃A, ⌃S, etc.)
        if modifiers.contains(.control) {
            return handleControlShortcut(event)
        }
        
        // / (slash) - Show Shortcuts Overlay
        if event.characters == "/" && modifiers.isEmpty {
            if !OverlayWindowManager.shared.isTextFieldActive {
                toggleShortcutOverlay()
                return true
            }
        }

        // Only handle annotation shortcuts if in drawing mode
        guard AppStateManager.shared.isDrawing else { return false }
        
        return handleAnnotationShortcut(event, modifiers: modifiers)
    }
    
    /// Handle global events (app not necessarily active, requires Accessibility)
    @discardableResult
    private func handleGlobalEvent(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // Only handle Control-based global shortcuts
        guard modifiers.contains(.control) else { return false }
        
        return handleControlShortcut(event)
    }
    
    private func handleControlShortcut(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isOption = modifiers.contains(.option)
        let isCommand = modifiers.contains(.command)
        let isShift = modifiers.contains(.shift)
        
        // Only pure Control shortcuts (no Option, Command, Shift unless specified)
        guard !isCommand else { return false }
        
        switch event.keyCode {
        case 0: // A key
            if isOption {
                // ⌃⌥A - Annotate without controls
                print("🎯 ⌃⌥A pressed")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleDrawing()
                    // Hide toolbar after short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        FloatingToolbarController.shared.hide()
                    }
                }
            } else if !isShift {
                // ⌃A - Annotate screen
                print("🎯 ⌃A pressed")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleDrawing()
                }
            }
            return true
            
        case 1: // S key
            if !isOption && !isShift {
                // ⌃S - Highlight cursor
                print("🎯 ⌃S pressed")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleCursorHighlight()
                }
                return true
            }
            
        case 37: // L key
            if !isOption && !isShift {
                // ⌃L - Spotlight
                print("🎯 ⌃L pressed")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleSpotlight()
                }
                return true
            }
            
        case 6: // Z key
            if !isOption && !isShift {
                // ⌃Z - Zoom
                print("🎯 ⌃Z pressed")
                DispatchQueue.main.async {
                    AppStateManager.shared.toggleZoom()
                }
                return true
            }
            
        default:
            break
        }
        
        return false
    }
    
    private func handleAnnotationShortcut(_ event: NSEvent, modifiers: NSEvent.ModifierFlags) -> Bool {
        let isCommand = modifiers.contains(.command)
        let isShift = modifiers.contains(.shift)
        
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
    
    private func toggleShortcutOverlay() {
        if shortcutOverlay != nil {
            shortcutOverlay?.close()
            shortcutOverlay = nil
        } else {
            shortcutOverlay = ShortcutOverlayWindow()
            shortcutOverlay?.show()
        }
    }
}

// MARK: - Shortcut Overlay Window
class ShortcutOverlayWindow {
    private var window: NSPanel?

    func show() {
        let width: CGFloat = 420
        let height: CGFloat = 520

        guard let screen = NSScreen.main else { return }
        let x = (screen.frame.width - width) / 2
        let y = (screen.frame.height - height) / 2

        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: width, height: height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .statusBar + 10
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true

        // Frosted glass background
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 16

        // Content
        let contentView = createContentView(frame: NSRect(x: 24, y: 24, width: width - 48, height: height - 48))
        visualEffectView.addSubview(contentView)

        panel.contentView = visualEffectView
        window = panel

        panel.orderFrontRegardless()

        // Fade in animation
        panel.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            panel.animator().alphaValue = 1
        }
        
        // Auto-dismiss after 10 seconds or on click
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.close()
        }
    }

    func close() {
        guard let panel = window else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            panel.orderOut(nil)
            self?.window = nil
        }
    }

    private func createContentView(frame: NSRect) -> NSView {
        let view = NSView(frame: frame)

        let titleLabel = NSTextField(labelWithString: "⌨️ Keyboard Shortcuts")
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.frame = NSRect(x: 0, y: frame.height - 40, width: frame.width, height: 30)
        view.addSubview(titleLabel)

        var yOffset = frame.height - 70

        // Global Shortcuts Section
        yOffset = addSectionTitle("Global Shortcuts", to: view, y: yOffset)
        yOffset = addShortcutRow("⌃A", "Annotate Screen", to: view, y: yOffset)
        yOffset = addShortcutRow("⌃⌥A", "Annotate (No Controls)", to: view, y: yOffset)
        yOffset = addShortcutRow("⌃S", "Highlight Cursor", to: view, y: yOffset)
        yOffset = addShortcutRow("⌃L", "Spotlight Cursor", to: view, y: yOffset)
        yOffset = addShortcutRow("⌃Z", "Zoom Cursor", to: view, y: yOffset)
        yOffset = addShortcutRow("/", "Show/Hide This Help", to: view, y: yOffset)
        yOffset = addShortcutRow("ESC", "Exit Current Mode", to: view, y: yOffset)

        // Drawing Tools Section
        yOffset -= 10
        yOffset = addSectionTitle("Drawing Tools", to: view, y: yOffset)
        yOffset = addShortcutRow("F", "Free Hand (Pen)", to: view, y: yOffset)
        yOffset = addShortcutRow("A", "Arrow", to: view, y: yOffset)
        yOffset = addShortcutRow("R", "Rectangle", to: view, y: yOffset)
        yOffset = addShortcutRow("C", "Circle", to: view, y: yOffset)
        yOffset = addShortcutRow("T", "Text", to: view, y: yOffset)
        yOffset = addShortcutRow("H", "Highlighter", to: view, y: yOffset)

        // Colors Section
        yOffset -= 10
        yOffset = addSectionTitle("Colors", to: view, y: yOffset)
        yOffset = addShortcutRow("1", "Cyan", to: view, y: yOffset)
        yOffset = addShortcutRow("2", "Rose", to: view, y: yOffset)
        yOffset = addShortcutRow("3", "Lime", to: view, y: yOffset)
        yOffset = addShortcutRow("4", "Yellow", to: view, y: yOffset)
        yOffset = addShortcutRow("5", "Violet", to: view, y: yOffset)

        // Actions Section
        yOffset -= 10
        yOffset = addSectionTitle("Actions", to: view, y: yOffset)
        yOffset = addShortcutRow("W", "Toggle Whiteboard", to: view, y: yOffset)
        yOffset = addShortcutRow("⌫", "Clear All", to: view, y: yOffset)
        yOffset = addShortcutRow("⌘Z", "Undo", to: view, y: yOffset)
        yOffset = addShortcutRow("⇧⌘Z", "Redo", to: view, y: yOffset)

        // Note at bottom
        let noteLabel = NSTextField(labelWithString: "Note: Global shortcuts require Accessibility permission")
        noteLabel.font = NSFont.systemFont(ofSize: 11)
        noteLabel.textColor = .secondaryLabelColor
        noteLabel.frame = NSRect(x: 0, y: 10, width: frame.width, height: 16)
        view.addSubview(noteLabel)

        return view
    }

    private func addSectionTitle(_ title: String, to view: NSView, y: CGFloat) -> CGFloat {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        label.frame = NSRect(x: 0, y: y - 18, width: view.frame.width, height: 16)
        view.addSubview(label)
        return y - 22
    }

    private func addShortcutRow(_ shortcut: String, _ description: String, to view: NSView, y: CGFloat) -> CGFloat {
        let shortcutLabel = NSTextField(labelWithString: shortcut)
        shortcutLabel.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        shortcutLabel.textColor = .labelColor
        shortcutLabel.alignment = .center
        shortcutLabel.frame = NSRect(x: 0, y: y - 18, width: 50, height: 18)
        view.addSubview(shortcutLabel)

        let descLabel = NSTextField(labelWithString: description)
        descLabel.font = NSFont.systemFont(ofSize: 13)
        descLabel.textColor = .labelColor
        descLabel.frame = NSRect(x: 60, y: y - 18, width: view.frame.width - 60, height: 18)
        view.addSubview(descLabel)

        return y - 20
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
