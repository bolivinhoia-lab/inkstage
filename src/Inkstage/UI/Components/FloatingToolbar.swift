import AppKit
import SwiftUI

// MARK: - Floating Toolbar Controller
class FloatingToolbarController {
    static let shared = FloatingToolbarController()
    
    private var toolbarWindow: NSPanel?
    
    func show() {
        // Close existing
        hide()
        
        let toolbarWidth: CGFloat = 480
        let toolbarHeight: CGFloat = 70
        
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let x = (screenFrame.width - toolbarWidth) / 2
        let y = screenFrame.height - toolbarHeight - 50
        
        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: toolbarWidth, height: toolbarHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .statusBar + 1
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.ignoresMouseEvents = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Use native NSView instead of SwiftUI for reliability
        let toolbarView = NativeToolbarView(frame: NSRect(x: 0, y: 0, width: toolbarWidth, height: toolbarHeight))
        panel.contentView = toolbarView
        
        toolbarWindow = panel
        panel.makeKeyAndOrderFront(nil)
        
        // Animate in
        panel.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            panel.animator().alphaValue = 1
        }
    }
    
    func hide() {
        guard let panel = toolbarWindow else { return }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            panel.orderOut(nil)
            self?.toolbarWindow = nil
        }
    }
}

// MARK: - Native Toolbar View (Reliable)
class NativeToolbarView: NSView {
    
    private var toolButtons: [NSButton] = []
    private var colorButtons: [NSButton] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95).cgColor
        layer?.cornerRadius = 12
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.3
        layer?.shadowRadius = 10
        layer?.shadowOffset = CGSize(width: 0, height: 4)
        
        let tools: [(icon: String, tag: Int)] = [
            ("pencil", 0),      // Pen
            ("highlighter", 1), // Marker
            ("line.diagonal", 2), // Line
            ("rectangle", 3),   // Rectangle
            ("circle", 4),      // Circle
            ("textformat", 5),  // Text
            ("eraser", 6)       // Eraser
        ]
        
        let buttonSize: CGFloat = 40
        let spacing: CGFloat = 8
        var xOffset: CGFloat = 16
        
        // Add drag handle
        let handle = NSTextField(labelWithString: "≡")
        handle.font = NSFont.systemFont(ofSize: 20)
        handle.textColor = .secondaryLabelColor
        handle.frame = NSRect(x: xOffset, y: 15, width: 24, height: 40)
        addSubview(handle)
        xOffset += 32
        
        // Add separator
        let separator1 = NSBox()
        separator1.boxType = .separator
        separator1.frame = NSRect(x: xOffset, y: 18, width: 1, height: 34)
        addSubview(separator1)
        xOffset += 16
        
        // Tool buttons
        for (index, tool) in tools.enumerated() {
            let button = createToolButton(icon: tool.icon, tag: tool.tag, selected: index == 0)
            button.frame = NSRect(x: xOffset, y: 15, width: buttonSize, height: buttonSize)
            button.target = self
            button.action = #selector(toolClicked(_:))
            addSubview(button)
            toolButtons.append(button)
            xOffset += buttonSize + spacing
        }
        
        // Separator
        xOffset += 8
        let separator2 = NSBox()
        separator2.boxType = .separator
        separator2.frame = NSRect(x: xOffset, y: 18, width: 1, height: 34)
        addSubview(separator2)
        xOffset += 16
        
        // Color buttons
        let colors: [NSColor] = [.systemYellow, .systemRed, .systemBlue, .systemGreen, .systemPurple]
        for (index, color) in colors.enumerated() {
            let button = createColorButton(color: color, tag: index)
            button.frame = NSRect(x: xOffset, y: 20, width: 30, height: 30)
            button.target = self
            button.action = #selector(colorClicked(_:))
            addSubview(button)
            colorButtons.append(button)
            xOffset += 34
        }
        
        // Separator
        xOffset += 12
        let separator3 = NSBox()
        separator3.boxType = .separator
        separator3.frame = NSRect(x: xOffset, y: 18, width: 1, height: 34)
        addSubview(separator3)
        xOffset += 16
        
        // Action buttons
        let undoButton = createActionButton(icon: "arrow.uturn.backward")
        undoButton.frame = NSRect(x: xOffset, y: 18, width: 34, height: 34)
        undoButton.target = self
        undoButton.action = #selector(undoClicked)
        addSubview(undoButton)
        xOffset += 40
        
        let closeButton = createActionButton(icon: "xmark")
        closeButton.frame = NSRect(x: xOffset, y: 18, width: 34, height: 34)
        closeButton.target = self
        closeButton.action = #selector(closeClicked)
        addSubview(closeButton)
    }
    
    private func createToolButton(icon: String, tag: Int, selected: Bool) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .rounded
        button.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        button.imageScaling = .scaleProportionallyUpOrDown
        button.tag = tag
        button.wantsLayer = true
        button.layer?.cornerRadius = 8
        
        if selected {
            button.layer?.backgroundColor = NSColor.selectedContentBackgroundColor.cgColor
        } else {
            button.layer?.backgroundColor = NSColor.clear.cgColor
        }
        
        return button
    }
    
    private func createColorButton(color: NSColor, tag: Int) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .rounded
        button.wantsLayer = true
        button.layer?.cornerRadius = 15
        button.layer?.backgroundColor = color.cgColor
        button.layer?.borderWidth = 2
        button.layer?.borderColor = NSColor.white.cgColor
        button.tag = tag
        return button
    }
    
    private func createActionButton(icon: String) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .rounded
        button.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        button.imageScaling = .scaleProportionallyUpOrDown
        button.wantsLayer = true
        button.layer?.cornerRadius = 6
        button.layer?.backgroundColor = NSColor.secondaryLabelColor.withAlphaComponent(0.1).cgColor
        return button
    }
    
    @objc private func toolClicked(_ sender: NSButton) {
        let tools: [DrawingToolType] = [.pen, .marker, .line, .rectangle, .circle, .text, .eraser]
        if sender.tag < tools.count {
            ToolSettings.shared.currentTool = tools[sender.tag]
            print("🛠️ Tool: \(tools[sender.tag])")
            
            // Update visual selection
            for (index, button) in toolButtons.enumerated() {
                if index == sender.tag {
                    button.layer?.backgroundColor = NSColor.selectedContentBackgroundColor.cgColor
                } else {
                    button.layer?.backgroundColor = NSColor.clear.cgColor
                }
            }
        }
    }
    
    @objc private func colorClicked(_ sender: NSButton) {
        let colors: [NSColor] = [.systemYellow, .systemRed, .systemBlue, .systemGreen, .systemPurple]
        if sender.tag < colors.count {
            SettingsManager.shared.penColor = colors[sender.tag]
            print("🎨 Color: \(colors[sender.tag])")
            
            // Update visual selection
            for (index, button) in colorButtons.enumerated() {
                if index == sender.tag {
                    button.layer?.borderColor = NSColor.selectedContentBackgroundColor.cgColor
                    button.layer?.borderWidth = 3
                } else {
                    button.layer?.borderColor = NSColor.white.cgColor
                    button.layer?.borderWidth = 2
                }
            }
        }
    }
    
    @objc private func undoClicked() {
        OverlayWindowManager.shared.undo()
    }
    
    @objc private func closeClicked() {
        AppStateManager.shared.handleEscape()
    }
}
