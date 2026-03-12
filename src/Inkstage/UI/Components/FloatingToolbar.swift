import AppKit
import SwiftUI
import Combine

// MARK: - Floating Toolbar Controller
class FloatingToolbarController {
    static let shared = FloatingToolbarController()

    private var toolbarWindow: NSPanel?
    private var toolbarView: ModernToolbarView?
    
    // Drag state
    private var dragStartLocation: NSPoint?
    private var dragStartFrame: NSRect?

    func show() {
        // Close existing
        hide()

        let toolbarWidth: CGFloat = 580
        let toolbarHeight: CGFloat = 56

        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let x = (screenFrame.width - toolbarWidth) / 2
        let y: CGFloat = 60  // 60px from bottom for modern feel

        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: toolbarWidth, height: toolbarHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Window configuration for modern floating toolbar
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false  // We'll add custom shadow
        panel.ignoresMouseEvents = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.becomesKeyOnlyIfNeeded = true

        // Create modern toolbar view
        let toolbarView = ModernToolbarView(frame: NSRect(x: 0, y: 0, width: toolbarWidth, height: toolbarHeight))
        toolbarView.onDragStart = { [weak self] location in
            self?.dragStartLocation = location
            self?.dragStartFrame = panel.frame
        }
        toolbarView.onDragMove = { [weak self] location in
            self?.handleDragMove(to: location, in: screenFrame)
        }
        toolbarView.onDragEnd = { [weak self] in
            self?.snapToEdge(in: screenFrame)
        }
        panel.contentView = toolbarView
        self.toolbarView = toolbarView

        toolbarWindow = panel
        panel.orderFrontRegardless()

        // Entry animation: fade + slide up
        panel.alphaValue = 0
        let finalY = y
        panel.setFrameOrigin(NSPoint(x: x, y: finalY - 20))
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrameOrigin(NSPoint(x: x, y: finalY))
        }
    }
    
    private func handleDragMove(to location: NSPoint, in screenFrame: NSRect) {
        guard let dragStart = dragStartLocation,
              let startFrame = dragStartFrame else { return }
        
        let deltaX = location.x - dragStart.x
        let deltaY = location.y - dragStart.y
        
        var newFrame = startFrame
        newFrame.origin.x += deltaX
        newFrame.origin.y += deltaY
        
        // Constrain to screen bounds
        newFrame.origin.x = max(10, min(newFrame.origin.x, screenFrame.width - newFrame.width - 10))
        newFrame.origin.y = max(10, min(newFrame.origin.y, screenFrame.height - newFrame.height - 10))
        
        toolbarWindow?.setFrame(newFrame, display: true)
    }
    
    private func snapToEdge(in screenFrame: NSRect) {
        guard let frame = toolbarWindow?.frame else { return }
        
        let margin: CGFloat = 20
        let centerX = frame.midX
        let centerY = frame.midY
        
        var newX = frame.origin.x
        var newY = frame.origin.y
        
        // Snap to horizontal edges if close
        if centerX < screenFrame.width * 0.25 {
            newX = margin
        } else if centerX > screenFrame.width * 0.75 {
            newX = screenFrame.width - frame.width - margin
        }
        
        // Snap to vertical edges if close
        if centerY < screenFrame.height * 0.25 {
            newY = margin
        } else if centerY > screenFrame.height * 0.75 {
            newY = screenFrame.height - frame.height - margin
        }
        
        // Animate to snapped position
        if newX != frame.origin.x || newY != frame.origin.y {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                toolbarWindow?.animator().setFrameOrigin(NSPoint(x: newX, y: newY))
            }
        }
    }

    func hide() {
        guard let panel = toolbarWindow else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            panel.orderOut(nil)
            self?.toolbarWindow = nil
            self?.toolbarView = nil
        }
    }

    func updateAutoFadeButton() {
        toolbarView?.updateAutoFadeButton()
    }
    
    func updateToolSelection(_ tool: DrawingToolType) {
        toolbarView?.updateToolSelection(tool)
    }
    
    func updateColorSelection(_ color: NSColor) {
        toolbarView?.updateColorSelection(color)
    }
}

// MARK: - Modern Toolbar View
class ModernToolbarView: NSView {
    
    // MARK: - Callbacks
    var onDragStart: ((NSPoint) -> Void)?
    var onDragMove: ((NSPoint) -> Void)?
    var onDragEnd: (() -> Void)?
    
    // MARK: - UI Components
    private var visualEffectView: NSVisualEffectView!
    private var contentView: NSView!
    private var dragHandle: NSButton!
    private var colorButtons: [ToolbarColorButton] = []
    private var toolButtons: [ToolButton] = []
    private var actionButtons: [NSButton] = []
    private var autoFadeButton: NSButton?
    private var separators: [NSBox] = []
    
    // MARK: - State
    private var selectedTool: DrawingToolType = .pen
    private var selectedColor: NSColor = .systemCyan
    private var cancellables = Set<AnyCancellable>()
    
    // Modern color palette (matching design spec)
    private let favoriteColors: [NSColor] = [
        .systemCyan,    // 1 - Cyan
        .systemPink,    // 2 - Rose
        .systemGreen,   // 3 - Lime
        .systemYellow,  // 4 - Yellow
        .systemPurple   // 5 - Violet
    ]
    
    private let tools: [(type: DrawingToolType, icon: String)] = [
        (.pen, "pencil.line"),
        (.line, "arrow.up.right"),  // Using arrow as line tool
        (.rectangle, "rectangle"),
        (.circle, "circle"),
        (.text, "textformat")
    ]
    
    // MARK: - Initialization
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        
        // Subscribe to settings changes
        SettingsManager.shared.$autoEraseEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAutoFadeButton()
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = .clear
        
        // Create frosted glass background
        visualEffectView = NSVisualEffectView(frame: bounds)
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 20  // Pill shape
        
        // Add subtle border
        visualEffectView.layer?.borderWidth = 0.5
        visualEffectView.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
        
        // Add soft shadow
        visualEffectView.layer?.shadowColor = NSColor.black.cgColor
        visualEffectView.layer?.shadowOpacity = 0.25
        visualEffectView.layer?.shadowRadius = 20
        visualEffectView.layer?.shadowOffset = CGSize(width: 0, height: 8)
        
        addSubview(visualEffectView)
        
        // Content container
        contentView = NSView(frame: bounds.insetBy(dx: 12, dy: 0))
        addSubview(contentView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        let buttonHeight: CGFloat = 32
        let colorSize: CGFloat = 28
        let spacing: CGFloat = 8
        let sectionSpacing: CGFloat = 12
        
        var xOffset: CGFloat = 0
        
        // 1. Drag Handle
        dragHandle = createDragHandle()
        dragHandle.frame = NSRect(x: xOffset, y: (bounds.height - 24) / 2, width: 28, height: 24)
        contentView.addSubview(dragHandle)
        xOffset += 28 + spacing
        
        // 2. Separator
        addSeparator(at: xOffset, height: 24)
        xOffset += 1 + sectionSpacing
        
        // 3. Color Buttons (5 circles)
        for (index, color) in favoriteColors.enumerated() {
            let button = createColorButton(color: color, tag: index)
            button.frame = NSRect(x: xOffset, y: (bounds.height - colorSize) / 2, width: colorSize, height: colorSize)
            contentView.addSubview(button)
            colorButtons.append(button)
            xOffset += colorSize + 6
        }
        xOffset += sectionSpacing - 6
        
        // 4. Separator
        addSeparator(at: xOffset, height: 24)
        xOffset += 1 + sectionSpacing
        
        // 5. Tool Buttons (Pen, Arrow, Rect, Circle, Text)
        for (index, tool) in tools.enumerated() {
            let button = createToolButton(icon: tool.icon, tag: index, tool: tool.type)
            button.frame = NSRect(x: xOffset, y: (bounds.height - buttonHeight) / 2, width: 36, height: buttonHeight)
            contentView.addSubview(button)
            toolButtons.append(button)
            xOffset += 36 + 4
        }
        xOffset += sectionSpacing - 4
        
        // 6. Separator
        addSeparator(at: xOffset, height: 24)
        xOffset += 1 + sectionSpacing
        
        // 7. Action Buttons (Clear, Timer, Close)
        let clearButton = createActionButton(icon: "eraser", action: #selector(clearClicked), tag: 0)
        clearButton.frame = NSRect(x: xOffset, y: (bounds.height - 30) / 2, width: 32, height: 30)
        contentView.addSubview(clearButton)
        actionButtons.append(clearButton)
        xOffset += 32 + 4
        
        let fadeButton = createAutoFadeButton()
        fadeButton.frame = NSRect(x: xOffset, y: (bounds.height - 30) / 2, width: 32, height: 30)
        contentView.addSubview(fadeButton)
        autoFadeButton = fadeButton
        xOffset += 32 + 4
        
        let closeButton = createActionButton(icon: "xmark", action: #selector(closeClicked), tag: 2)
        closeButton.frame = NSRect(x: xOffset, y: (bounds.height - 30) / 2, width: 32, height: 30)
        contentView.addSubview(closeButton)
        actionButtons.append(closeButton)
        
        // Set initial selection
        updateToolSelection(.pen)
        updateColorSelection(.systemCyan)
    }
    
    // MARK: - Component Creation
    private func createDragHandle() -> NSButton {
        let button = NSButton(frame: .zero)
        button.bezelStyle = .recessed
        button.image = NSImage(systemSymbolName: "line.3.horizontal", accessibilityDescription: "Drag")
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyUpOrDown
        button.contentTintColor = .secondaryLabelColor
        button.wantsLayer = true
        button.isEnabled = true
        
        // Drag handling
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        button.addGestureRecognizer(panGesture)
        
        // Hover effect
        button.addTrackingArea(NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: ["button": button, "type": "handle"]
        ))
        
        return button
    }
    
    private func createColorButton(color: NSColor, tag: Int) -> ToolbarColorButton {
        let button = ToolbarColorButton(color: color)
        button.tag = tag
        button.target = self
        button.action = #selector(colorClicked(_:))
        
        // Add hover animation tracking
        button.addTrackingArea(NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: ["button": button, "type": "color", "color": color]
        ))
        
        return button
    }
    
    private func createToolButton(icon: String, tag: Int, tool: DrawingToolType) -> ToolButton {
        let button = ToolButton(icon: icon, tool: tool)
        button.tag = tag
        button.target = self
        button.action = #selector(toolClicked(_:))
        
        // Add hover animation tracking
        button.addTrackingArea(NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: ["button": button, "type": "tool"]
        ))
        
        return button
    }
    
    private func createActionButton(icon: String, action: Selector, tag: Int) -> NSButton {
        let button = NSButton(frame: .zero)
        button.bezelStyle = .recessed
        button.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyUpOrDown
        button.contentTintColor = .secondaryLabelColor
        button.wantsLayer = true
        button.layer?.cornerRadius = 8
        button.tag = tag
        button.isEnabled = true
        button.target = self
        button.action = action
        
        // Add hover animation tracking
        button.addTrackingArea(NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: ["button": button, "type": "action"]
        ))
        
        return button
    }
    
    private func createAutoFadeButton() -> NSButton {
        let isEnabled = SettingsManager.shared.autoEraseEnabled
        let button = NSButton(frame: .zero)
        button.bezelStyle = .recessed
        button.image = NSImage(systemSymbolName: isEnabled ? "timer" : "timer.slash", accessibilityDescription: "Auto Fade")
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyUpOrDown
        button.wantsLayer = true
        button.layer?.cornerRadius = 8
        button.isEnabled = true
        button.target = self
        button.action = #selector(autoFadeClicked(_:))
        button.toolTip = isEnabled ? "Auto-fade ON (Click to disable)" : "Auto-fade OFF (Click to enable)"
        
        updateAutoFadeButtonAppearance(button)
        
        // Add hover animation tracking
        button.addTrackingArea(NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: ["button": button, "type": "action"]
        ))
        
        return button
    }
    
    private func addSeparator(at x: CGFloat, height: CGFloat) {
        let separator = NSBox()
        separator.boxType = .separator
        separator.fillColor = NSColor.white.withAlphaComponent(0.15)
        separator.frame = NSRect(x: x, y: (bounds.height - height) / 2, width: 1, height: height)
        contentView.addSubview(separator)
        separators.append(separator)
    }
    
    // MARK: - Event Handling
    @objc private func handlePan(_ gesture: NSPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            onDragStart?(location)
        case .changed:
            onDragMove?(location)
        case .ended:
            onDragEnd?()
        default:
            break
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        guard let userInfo = event.trackingArea?.userInfo else { return }
        
        if let button = userInfo["button"] as? NSButton,
           let type = userInfo["type"] as? String {
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                
                if type == "color" {
                    button.animator().layer?.transform = CATransform3DMakeScale(1.15, 1.15, 1)
                } else {
                    button.animator().layer?.transform = CATransform3DMakeScale(1.1, 1.1, 1)
                    button.animator().alphaValue = 1.0
                }
            }
            
            if type == "handle" {
                button.contentTintColor = .controlTextColor
            } else if type == "tool" || type == "action" {
                button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.1).cgColor
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        guard let userInfo = event.trackingArea?.userInfo else { return }
        
        if let button = userInfo["button"] as? NSButton,
           let type = userInfo["type"] as? String {
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                button.animator().layer?.transform = CATransform3DMakeScale(1.0, 1.0, 1)
            }
            
            if type == "handle" {
                button.contentTintColor = .secondaryLabelColor
            } else if type == "tool" {
                let toolButton = button as? ToolButton
                if toolButton?.tool != selectedTool {
                    button.layer?.backgroundColor = NSColor.clear.cgColor
                } else {
                    button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
                }
            } else if type == "action" {
                if button != autoFadeButton {
                    button.layer?.backgroundColor = NSColor.clear.cgColor
                } else {
                    updateAutoFadeButtonAppearance(button)
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func colorClicked(_ sender: ToolbarColorButton) {
        let color = sender.color
        selectedColor = color
        SettingsManager.shared.penColor = color
        
        // Update visual selection
        updateColorSelection(color)
        
        // Bounce animation
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1.15
        animation.damping = 10
        animation.duration = 0.3
        sender.layer?.add(animation, forKey: "bounce")
        
        // Haptic feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        
        print("🎨 Color: \(colorName(for: color))")
    }
    
    @objc private func toolClicked(_ sender: ToolButton) {
        selectedTool = sender.tool
        ToolSettings.shared.currentTool = sender.tool
        
        // Update visual selection
        updateToolSelection(sender.tool)
        
        // Press animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.1
            sender.animator().layer?.transform = CATransform3DMakeScale(0.92, 0.92, 1)
        } completionHandler: {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                sender.animator().layer?.transform = CATransform3DMakeScale(1.0, 1.0, 1)
            }
        }
        
        // Haptic feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        
        print("🛠️ Tool: \(sender.tool.rawValue)")
    }
    
    @objc private func clearClicked() {
        OverlayWindowManager.shared.clearAnnotations()
        
        // Haptic feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        
        print("🧹 Clear all annotations")
    }
    
    @objc private func closeClicked() {
        AppStateManager.shared.handleEscape()
        
        // Haptic feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
    
    @objc private func autoFadeClicked(_ sender: NSButton) {
        let newValue = !SettingsManager.shared.autoEraseEnabled
        SettingsManager.shared.autoEraseEnabled = newValue
        
        updateAutoFadeButton()
        
        // Haptic feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        
        // Show toast notification
        ToastManager.shared.show(message: newValue ? "⏱️ Auto-fade ON" : "⏱️ Auto-fade OFF")
        
        print("⏱️ Auto-fade: \(newValue ? "ON" : "OFF")")
    }
    
    // MARK: - Updates
    func updateToolSelection(_ tool: DrawingToolType) {
        selectedTool = tool
        for button in toolButtons {
            if button.tool == tool {
                button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
                button.contentTintColor = .white
                button.isSelected = true
            } else {
                button.layer?.backgroundColor = NSColor.clear.cgColor
                button.contentTintColor = .secondaryLabelColor
                button.isSelected = false
            }
        }
    }
    
    func updateColorSelection(_ color: NSColor) {
        selectedColor = color
        for button in colorButtons {
            if colorsEqual(button.color, color) {
                button.setSelected(true)
                button.layer?.borderWidth = 2
                button.layer?.borderColor = NSColor.white.cgColor
                button.addGlow(color)
            } else {
                button.setSelected(false)
                button.layer?.borderWidth = 0
                button.removeGlow()
            }
        }
    }
    
    func updateAutoFadeButton() {
        guard let button = autoFadeButton else { return }
        let isEnabled = SettingsManager.shared.autoEraseEnabled
        button.image = NSImage(systemSymbolName: isEnabled ? "timer" : "timer.slash", accessibilityDescription: "Auto Fade")
        button.toolTip = isEnabled ? "Auto-fade ON (Click to disable)" : "Auto-fade OFF (Click to enable)"
        updateAutoFadeButtonAppearance(button)
    }
    
    private func updateAutoFadeButtonAppearance(_ button: NSButton) {
        let isEnabled = SettingsManager.shared.autoEraseEnabled
        if isEnabled {
            button.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.4).cgColor
            button.contentTintColor = .controlTextColor
        } else {
            button.layer?.backgroundColor = NSColor.clear.cgColor
            button.contentTintColor = .secondaryLabelColor
        }
    }
    
    // MARK: - Helpers
    private func colorName(for color: NSColor) -> String {
        if colorsEqual(color, .systemCyan) { return "Cyan" }
        if colorsEqual(color, .systemPink) { return "Rose" }
        if colorsEqual(color, .systemGreen) { return "Lime" }
        if colorsEqual(color, .systemYellow) { return "Yellow" }
        if colorsEqual(color, .systemPurple) { return "Violet" }
        return "Custom"
    }
    
    private func colorsEqual(_ c1: NSColor, _ c2: NSColor) -> Bool {
        let rgb1 = c1.usingColorSpace(.sRGB) ?? c1
        let rgb2 = c2.usingColorSpace(.sRGB) ?? c2
        return abs(rgb1.redComponent - rgb2.redComponent) < 0.01 &&
               abs(rgb1.greenComponent - rgb2.greenComponent) < 0.01 &&
               abs(rgb1.blueComponent - rgb2.blueComponent) < 0.01
    }
}

// MARK: - Custom Button Classes
class ToolbarColorButton: NSButton {
    let color: NSColor
    private var glowLayer: CALayer?
    private(set) var isSelected: Bool = false
    
    init(color: NSColor) {
        self.color = color
        super.init(frame: .zero)
        
        bezelStyle = .recessed
        title = ""
        wantsLayer = true
        layer?.cornerRadius = 14  // Half of 28 = circle
        layer?.backgroundColor = color.cgColor
        isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
    }
    
    func addGlow(_ color: NSColor) {
        removeGlow()
        
        let glow = CALayer()
        glow.frame = bounds.insetBy(dx: -4, dy: -4)
        glow.cornerRadius = 18
        glow.backgroundColor = color.withAlphaComponent(0.3).cgColor
        glow.shadowColor = color.cgColor
        glow.shadowRadius = 10
        glow.shadowOpacity = 0.6
        glow.shadowOffset = .zero
        
        layer?.insertSublayer(glow, at: 0)
        glowLayer = glow
    }
    
    func removeGlow() {
        glowLayer?.removeFromSuperlayer()
        glowLayer = nil
    }
}

class ToolButton: NSButton {
    let tool: DrawingToolType
    var isSelected: Bool = false
    
    init(icon: String, tool: DrawingToolType) {
        self.tool = tool
        super.init(frame: .zero)
        
        bezelStyle = .recessed
        image = NSImage(systemSymbolName: icon, accessibilityDescription: tool.rawValue)
        imagePosition = .imageOnly
        imageScaling = .scaleProportionallyUpOrDown
        contentTintColor = .secondaryLabelColor
        wantsLayer = true
        layer?.cornerRadius = 10
        isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
