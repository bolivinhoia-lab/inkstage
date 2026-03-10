import AppKit

class CursorHighlighter {
    static let shared = CursorHighlighter()
    
    private var highlightWindow: NSWindow?
    private var trackingTimer: Timer?
    private(set) var isActive = false
    
    private let ringColor: NSColor = .systemYellow
    private let ringSize: CGFloat = 50.0
    
    func activate() {
        guard highlightWindow == nil else { return }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: ringSize, height: ringSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.level = .screenSaver
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        
        // View nativa do anel
        let ringView = HighlightRingView(frame: NSRect(x: 0, y: 0, width: ringSize, height: ringSize))
        window.contentView = ringView
        
        highlightWindow = window
        window.makeKeyAndOrderFront(nil)
        
        // Inicia tracking do cursor
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in
            self?.updatePosition()
        }
        
        isActive = true
    }
    
    func deactivate() {
        trackingTimer?.invalidate()
        trackingTimer = nil
        
        highlightWindow?.orderOut(nil)
        highlightWindow = nil
        
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
        guard let window = highlightWindow else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        let newOrigin = NSPoint(
            x: mouseLocation.x - ringSize / 2,
            y: mouseLocation.y - ringSize / 2
        )
        
        window.setFrameOrigin(newOrigin)
    }
}

// MARK: - Highlight Ring View
class HighlightRingView: NSView {
    private let ringColor: NSColor = .systemYellow
    private let ringSize: CGFloat = 50.0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        let ringRect = bounds.insetBy(dx: 3, dy: 3)
        let path = CGPath(ellipseIn: ringRect, transform: nil)
        
        // Desenha anel
        context.setStrokeColor(ringColor.withAlphaComponent(0.9).cgColor)
        context.setLineWidth(4.0)
        context.addPath(path)
        context.strokePath()
        
        // Preenche centro
        context.setFillColor(ringColor.withAlphaComponent(0.2).cgColor)
        context.addPath(path)
        context.fillPath()
    }
}
