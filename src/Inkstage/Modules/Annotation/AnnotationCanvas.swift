import SwiftUI
import AppKit
import Combine

// MARK: - Drawing Path with Style
class DrawingStroke {
    let id = UUID()
    let path: NSBezierPath
    let color: NSColor
    let width: CGFloat
    let isMarker: Bool
    let markerOpacity: CGFloat
    var creationTime: Date
    
    init(path: NSBezierPath, color: NSColor, width: CGFloat, isMarker: Bool, markerOpacity: CGFloat, creationTime: Date) {
        self.path = path
        self.color = color
        self.width = width
        self.isMarker = isMarker
        self.markerOpacity = markerOpacity
        self.creationTime = creationTime
    }
}

// MARK: - Drawing View (NSView)
class DrawingView: NSView {
    var isDrawingEnabled: Bool = false
    var onEscapePressed: (() -> Void)?
    var onRightClick: (() -> Void)?
    
    private var strokes: [DrawingStroke] = []
    private var currentStroke: DrawingStroke?
    private var shapeStartPoint: NSPoint?
    private var activeTextField: NSTextField?
    
    private var settings: ToolSettings { ToolSettings.shared }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return isDrawingEnabled ? self : nil
    }
    
    // MARK: - Mouse Events
    override func mouseDown(with event: NSEvent) {
        if event.type == .rightMouseDown || event.modifierFlags.contains(.control) {
            onRightClick?()
            return
        }
        
        guard isDrawingEnabled else { return }
        
        let location = convert(event.locationInWindow, from: nil)
        
        switch settings.currentTool {
        case .pen, .marker:
            startFreehand(at: location)
        case .line, .rectangle, .circle:
            startShape(at: location)
        case .text:
            createText(at: location)
        case .eraser:
            erase(at: location)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isDrawingEnabled else { return }
        
        let location = convert(event.locationInWindow, from: nil)
        
        switch settings.currentTool {
        case .pen, .marker:
            continueFreehand(at: location)
        case .line, .rectangle, .circle:
            continueShape(at: location)
        case .eraser:
            erase(at: location)
        default:
            break
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard isDrawingEnabled else { return }
        currentStroke = nil
        shapeStartPoint = nil
    }
    
    // MARK: - Freehand Drawing
    private func startFreehand(at point: NSPoint) {
        let path = NSBezierPath()
        path.lineWidth = settings.currentWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: point)
        
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
    
    private func continueFreehand(at point: NSPoint) {
        guard let stroke = currentStroke else { return }
        stroke.path.line(to: point)
        needsDisplay = true
    }
    
    // MARK: - Shape Drawing
    private func startShape(at point: NSPoint) {
        shapeStartPoint = point
        
        let path = NSBezierPath()
        path.lineWidth = settings.penWidth
        
        let stroke = DrawingStroke(
            path: path,
            color: SettingsManager.shared.penColor,
            width: settings.penWidth,
            isMarker: false,
            markerOpacity: 1.0,
            creationTime: Date()
        )
        
        currentStroke = stroke
        strokes.append(stroke)
    }
    
    private func continueShape(at point: NSPoint) {
        guard let start = shapeStartPoint else { return }
        guard currentStroke != nil else { return }
        
        // Remove o stroke anterior e cria um novo com o path atualizado
        strokes.removeLast()
        
        let path = createShapePath(start: start, end: point)
        let stroke = DrawingStroke(
            path: path,
            color: SettingsManager.shared.penColor,
            width: settings.penWidth,
            isMarker: false,
            markerOpacity: 1.0,
            creationTime: Date()
        )
        
        currentStroke = stroke
        strokes.append(stroke)
        needsDisplay = true
    }
    
    private func createShapePath(start: NSPoint, end: NSPoint) -> NSBezierPath {
        let path = NSBezierPath()
        path.lineWidth = settings.penWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        switch settings.currentTool {
        case .line:
            path.move(to: start)
            path.line(to: end)
        case .rectangle:
            let rect = NSRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            path.append(NSBezierPath(rect: rect))
        case .circle:
            let centerX = (start.x + end.x) / 2
            let centerY = (start.y + end.y) / 2
            let radius = hypot(end.x - start.x, end.y - start.y) / 2
            let rect = CGRect(
                x: centerX - radius,
                y: centerY - radius,
                width: radius * 2,
                height: radius * 2
            )
            path.append(NSBezierPath(ovalIn: rect))
        default:
            break
        }
        
        return path
    }
    
    // MARK: - Text
    private func createText(at point: NSPoint) {
        activeTextField?.removeFromSuperview()
        
        let textField = NSTextField(frame: NSRect(x: point.x, y: point.y - 15, width: 200, height: 30))
        textField.font = NSFont.systemFont(ofSize: settings.fontSize)
        textField.textColor = SettingsManager.shared.penColor
        textField.backgroundColor = .clear
        textField.isBordered = false
        textField.placeholderString = "Type..."
        textField.delegate = self
        
        addSubview(textField)
        window?.makeFirstResponder(textField)
        activeTextField = textField
    }
    
    func clearCurrentTextField() {
        activeTextField?.removeFromSuperview()
        activeTextField = nil
    }
    
    // MARK: - Eraser
    private func erase(at point: NSPoint) {
        let eraserRadius = settings.eraserSize / 2
        strokes.removeAll { stroke in
            stroke.path.bounds.insetBy(dx: -eraserRadius, dy: -eraserRadius).contains(point)
        }
        needsDisplay = true
    }
    
    // MARK: - Keyboard
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC
            onEscapePressed?()
            return
        }
        super.keyDown(with: event)
    }
    
    override var acceptsFirstResponder: Bool { true }
    
    // MARK: - Rendering
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        for stroke in strokes {
            if stroke.isMarker {
                stroke.color.withAlphaComponent(stroke.markerOpacity).setStroke()
            } else {
                stroke.color.setStroke()
            }
            stroke.path.stroke()
        }
    }
    
    // MARK: - Actions
    func clear() {
        strokes.removeAll()
        clearCurrentTextField()
        needsDisplay = true
    }
    
    func undo() {
        guard !strokes.isEmpty else { return }
        strokes.removeLast()
        needsDisplay = true
    }
}

// MARK: - NSTextFieldDelegate
extension DrawingView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        clearCurrentTextField()
        needsDisplay = true
    }
}
