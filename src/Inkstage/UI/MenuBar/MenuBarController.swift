import AppKit

class MenuBarController: NSObject {
    static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    private let appState = AppStateManager.shared
    
    func setupMenuBar() {
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let button = statusItem?.button else {
            print("❌ Failed to create status item")
            return
        }
        
        // Ícone
        if let image = NSImage(systemSymbolName: "scribble.variable", accessibilityDescription: "Inkstage") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "✏️"
        }
        
        // Configura menu
        let menu = createMenu()
        statusItem?.menu = menu
        
        print("✅ Menu Bar ready")
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Header
        let header = NSMenuItem(title: "✏️ Inkstage", action: nil, keyEquivalent: "")
        header.attributedTitle = NSAttributedString(
            string: "✏️ Inkstage",
            attributes: [.font: NSFont.boldSystemFont(ofSize: 14)]
        )
        menu.addItem(header)
        menu.addItem(NSMenuItem.separator())
        
        // Status dinâmico
        addStatusItems(to: menu)
        menu.addItem(NSMenuItem.separator())
        
        // Tools
        addToolItems(to: menu)
        menu.addItem(NSMenuItem.separator())
        
        // Colors
        addColorMenu(to: menu)
        menu.addItem(NSMenuItem.separator())
        
        // Actions
        let prefsItem = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        prefsItem.keyEquivalentModifierMask = [.command]
        prefsItem.target = self
        menu.addItem(prefsItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    private func addStatusItems(to menu: NSMenu) {
        let mode = appState.currentMode
        
        let drawingStatus = mode == .drawing ? "✅ Drawing Mode" : "⬜ Drawing Mode"
        let drawingItem = NSMenuItem(title: drawingStatus, action: #selector(toggleDrawing), keyEquivalent: "a")
        drawingItem.keyEquivalentModifierMask = [.command, .shift]
        drawingItem.target = self
        menu.addItem(drawingItem)
        
        let highlightStatus = mode == .cursorHighlight ? "✅ Cursor Highlight" : "⬜ Cursor Highlight"
        let highlightItem = NSMenuItem(title: highlightStatus, action: #selector(toggleHighlight), keyEquivalent: "c")
        highlightItem.keyEquivalentModifierMask = [.command, .shift]
        highlightItem.target = self
        menu.addItem(highlightItem)
        
        let spotlightStatus = mode == .spotlight ? "✅ Spotlight" : "⬜ Spotlight"
        let spotlightItem = NSMenuItem(title: spotlightStatus, action: #selector(toggleSpotlight), keyEquivalent: "s")
        spotlightItem.keyEquivalentModifierMask = [.command, .shift]
        spotlightItem.target = self
        menu.addItem(spotlightItem)
        
        let zoomStatus = mode == .zoom ? "✅ Zoom" : "⬜ Zoom"
        let zoomItem = NSMenuItem(title: zoomStatus, action: #selector(toggleZoom), keyEquivalent: "z")
        zoomItem.keyEquivalentModifierMask = [.command, .shift]
        zoomItem.target = self
        menu.addItem(zoomItem)
        
        let whiteboardStatus = mode == .whiteboard ? "✅ Whiteboard" : "⬜ Whiteboard"
        let whiteboardItem = NSMenuItem(title: whiteboardStatus, action: #selector(toggleWhiteboard), keyEquivalent: "w")
        whiteboardItem.keyEquivalentModifierMask = [.command, .shift]
        whiteboardItem.target = self
        menu.addItem(whiteboardItem)
    }
    
    private func addToolItems(to menu: NSMenu) {
        let undoItem = NSMenuItem(title: "Undo", action: #selector(undo), keyEquivalent: "z")
        undoItem.keyEquivalentModifierMask = [.command]
        undoItem.target = self
        menu.addItem(undoItem)
        
        let clearItem = NSMenuItem(title: "Clear All", action: #selector(clear), keyEquivalent: "")
        clearItem.target = self
        menu.addItem(clearItem)
    }
    
    private func addColorMenu(to menu: NSMenu) {
        let colorsMenu = NSMenu()
        for (name, color) in SettingsManager.shared.availableColors {
            let item = NSMenuItem(title: name, action: #selector(selectColor(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = name
            
            // Mostra preview da cor
            let image = NSImage(size: NSSize(width: 12, height: 12))
            image.lockFocus()
            color.setFill()
            NSRect(x: 0, y: 0, width: 12, height: 12).fill()
            image.unlockFocus()
            item.image = image
            
            colorsMenu.addItem(item)
        }
        let colorsItem = NSMenuItem(title: "Pen Color", action: nil, keyEquivalent: "")
        colorsItem.submenu = colorsMenu
        menu.addItem(colorsItem)
    }
    
    // MARK: - Actions
    
    @objc private func toggleDrawing() {
        appState.toggleDrawing()
        refreshMenu()
    }
    
    @objc private func toggleHighlight() {
        appState.toggleCursorHighlight()
        refreshMenu()
    }
    
    @objc private func toggleSpotlight() {
        appState.toggleSpotlight()
        refreshMenu()
    }
    
    @objc private func toggleZoom() {
        appState.toggleZoom()
        refreshMenu()
    }
    
    @objc private func toggleWhiteboard() {
        appState.toggleWhiteboard()
        refreshMenu()
    }
    
    @objc private func undo() {
        OverlayWindowManager.shared.undo()
    }
    
    @objc private func clear() {
        OverlayWindowManager.shared.clearAnnotations()
    }
    
    @objc private func selectColor(_ sender: NSMenuItem) {
        if let name = sender.representedObject as? String {
            SettingsManager.shared.setColorByName(name)
        }
    }
    
    @objc private func openPreferences() {
        OverlayWindowManager.shared.openPreferences()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    private func refreshMenu() {
        // Recria o menu para atualizar os status
        statusItem?.menu = createMenu()
    }
}
