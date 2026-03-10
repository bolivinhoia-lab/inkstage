import AppKit

class SpotlightManager {
    static let shared = SpotlightManager()
    
    private var spotlightWindow: NSWindow?
    private var trackingTimer: Timer?
    private(set) var isActive = false
    private var isPinned = false
    private var spotlightCenter: NSPoint = .zero
    
    private let spotlightSize: CGFloat = 250.0
    private let darknessOpacity: CGFloat = 0.7
    
    func activate() {
        guard spotlightWindow == nil else { return }
        
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.frame
        
        let window = NSWindow(
            contentRect: screenRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.level = .screenSaver
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        
        // View nativa do spotlight
        let spotlightView = SpotlightView(frame: screenRect)
        window.contentView = spotlightView
        
        spotlightWindow = window
        window.makeKeyAndOrderFront(nil)
        
        // Inicia tracking do cursor
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in
            self?.updatePosition()
        }
        
        // Animação de fade in
        window.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().alphaValue = 1
        }
        
        isActive = true
    }
    
    func deactivate() {
        guard let window = spotlightWindow else { return }
        
        // Animação de fade out
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.trackingTimer?.invalidate()
            self?.trackingTimer = nil
            self?.spotlightWindow?.orderOut(nil)
            self?.spotlightWindow = nil
            self?.isActive = false
        }
    }
    
    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }
    
    func togglePin() {
        isPinned.toggle()
    }
    
    private func updatePosition() {
        guard let window = spotlightWindow else { return }
        guard !isPinned else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        spotlightCenter = mouseLocation
        
        if let view = window.contentView as? SpotlightView {
            view.spotlightCenter = mouseLocation
            view.needsDisplay = true
        }
    }
}

// MARK: - Spotlight View
class SpotlightView: NSView {
    var spotlightCenter: NSPoint = .zero
    private let spotlightSize: CGFloat = 250.0
    private let darknessOpacity: CGFloat = 0.7
    
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
        
        // Preenche tudo com escuridão
        context.setFillColor(NSColor.black.withAlphaComponent(darknessOpacity).cgColor)
        context.fill(bounds)
        
        // Cria o path do spotlight (círculo)
        let spotlightRect = CGRect(
            x: spotlightCenter.x - spotlightSize / 2,
            y: spotlightCenter.y - spotlightSize / 2,
            width: spotlightSize,
            height: spotlightSize
        )
        let spotlightPath = CGPath(ellipseIn: spotlightRect, transform: nil)
        
        // Cria máscara: limpa a área do spotlight
        context.saveGState()
        context.addPath(spotlightPath)
        context.clip()
        context.clear(bounds)
        context.restoreGState()
        
        // Adiciona borda sutil no spotlight
        context.setStrokeColor(NSColor.white.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(2.0)
        context.addPath(spotlightPath)
        context.strokePath()
    }
}
