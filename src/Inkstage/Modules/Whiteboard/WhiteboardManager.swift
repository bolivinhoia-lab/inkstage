import AppKit

class WhiteboardManager {
    static let shared = WhiteboardManager()
    
    private var whiteboardWindow: NSPanel?
    private(set) var isActive = false
    
    func activate() {
        guard whiteboardWindow == nil else { return }
        
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.frame
        
        let panel = NSPanel(
            contentRect: screenRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .screenSaver
        panel.backgroundColor = .white
        panel.isOpaque = true
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // View de desenho para whiteboard
        let drawingView = WhiteboardDrawingView(frame: screenRect)
        panel.contentView = drawingView
        
        whiteboardWindow = panel
        panel.makeKeyAndOrderFront(nil)
        
        isActive = true
    }
    
    func deactivate() {
        whiteboardWindow?.orderOut(nil)
        whiteboardWindow = nil
        isActive = false
    }
}

// MARK: - Whiteboard Drawing View
class WhiteboardDrawingView: NSView {
    private var strokes: [DrawingStroke] = []
    private var currentStroke: DrawingStroke?
    private var settings = ToolSettings.shared
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        
        let path = NSBezierPath()
        path.lineWidth = settings.currentWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: location)
        
        let stroke = DrawingStroke(
            path: path,
            color: SettingsManager.shared.penColor,
            width: settings.currentWidth,
            isMarker: settings.currentTool == .marker,
            markerOpacity: settings.markerOpacity,
            creationTime: Date()
        )
        
        currentStroke = stroke
        strokes.append(stroke)
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let stroke = currentStroke else { return }
        let location = convert(event.locationInWindow, from: nil)
        stroke.path.line(to: location)
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        currentStroke = nil
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Fundo branco
        NSColor.white.setFill()
        dirtyRect.fill()
        
        // Desenha strokes
        for stroke in strokes {
            if stroke.isMarker {
                stroke.color.withAlphaComponent(stroke.markerOpacity).setStroke()
            } else {
                stroke.color.setStroke()
            }
            stroke.path.stroke()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC
            AppStateManager.shared.deactivateAll()
        }
        super.keyDown(with: event)
    }
    
    override var acceptsFirstResponder: Bool { true }
}
