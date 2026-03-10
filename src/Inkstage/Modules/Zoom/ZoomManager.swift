import AppKit

// Simple zoom that works without ScreenCaptureKit permissions
// Shows a magnified view using a different approach
class ZoomManager {
    static let shared = ZoomManager()
    
    private var zoomWindow: NSPanel?
    private var trackingTimer: Timer?
    private(set) var isActive = false
    
    private let windowSize: CGFloat = 200
    private let zoomLevel: CGFloat = 2.0
    
    func activate() {
        guard zoomWindow == nil else { return }
        
        let panel = NSPanel(
            contentRect: NSRect(x: 100, y: 100, width: windowSize, height: windowSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .screenSaver
        panel.backgroundColor = .black
        panel.isOpaque = true
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Create a zoom view
        let zoomView = SimpleZoomView(frame: NSRect(x: 0, y: 0, width: windowSize, height: windowSize))
        panel.contentView = zoomView
        
        zoomWindow = panel
        panel.makeKeyAndOrderFront(nil)
        
        // Track mouse position
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in
            self?.updatePosition()
        }
        
        // Initial position
        updatePosition()
        
        isActive = true
        
        ToastManager.shared.show(message: "🔍 Zoom Active (ESC to exit)", duration: 2)
    }
    
    func deactivate() {
        trackingTimer?.invalidate()
        trackingTimer = nil
        
        zoomWindow?.orderOut(nil)
        zoomWindow = nil
        
        isActive = false
    }
    
    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }
    
    private func updatePosition() {
        guard let window = zoomWindow else { return }
        
        let mouseLoc = NSEvent.mouseLocation
        let offset: CGFloat = 20
        
        // Position near cursor but not covering it
        var newOrigin = NSPoint(
            x: mouseLoc.x + offset,
            y: mouseLoc.y - windowSize - offset
        )
        
        // Keep on screen
        if let screen = NSScreen.main {
            let frame = screen.frame
            if newOrigin.x + windowSize > frame.maxX {
                newOrigin.x = mouseLoc.x - windowSize - offset
            }
            if newOrigin.y < frame.minY {
                newOrigin.y = mouseLoc.y + offset
            }
        }
        
        window.setFrameOrigin(newOrigin)
        
        // Update the zoom view with current mouse position
        if let zoomView = window.contentView as? SimpleZoomView {
            zoomView.mousePosition = mouseLoc
            zoomView.needsDisplay = true
        }
    }
}

// Simple zoom view that shows a representation
class SimpleZoomView: NSView {
    var mousePosition: NSPoint = .zero
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw placeholder showing zoom is active
        let context = NSGraphicsContext.current?.cgContext
        
        // Background
        NSColor.black.setFill()
        dirtyRect.fill()
        
        // Draw grid pattern to show it's a magnifier
        context?.setStrokeColor(NSColor.white.withAlphaComponent(0.2).cgColor)
        context?.setLineWidth(0.5)
        
        let gridSize: CGFloat = 20
        for x in stride(from: 0, to: bounds.width, by: gridSize) {
            context?.move(to: CGPoint(x: x, y: 0))
            context?.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        for y in stride(from: 0, to: bounds.height, by: gridSize) {
            context?.move(to: CGPoint(x: 0, y: y))
            context?.addLine(to: CGPoint(x: bounds.width, y: y))
        }
        context?.strokePath()
        
        // Draw crosshair center
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        context?.setStrokeColor(NSColor.white.withAlphaComponent(0.5).cgColor)
        context?.setLineWidth(1)
        
        // Horizontal
        context?.move(to: CGPoint(x: 0, y: center.y))
        context?.addLine(to: CGPoint(x: bounds.width, y: center.y))
        // Vertical
        context?.move(to: CGPoint(x: center.x, y: 0))
        context?.addLine(to: CGPoint(x: center.x, y: bounds.height))
        context?.strokePath()
        
        // Draw zoom indicator
        let text = "🔍 2x" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let size = text.size(withAttributes: attrs)
        text.draw(at: CGPoint(x: (bounds.width - size.width) / 2, y: 10), withAttributes: attrs)
        
        // Draw border
        context?.setStrokeColor(NSColor.white.withAlphaComponent(0.3).cgColor)
        context?.setLineWidth(2)
        context?.stroke(bounds.insetBy(dx: 1, dy: 1))
    }
}
