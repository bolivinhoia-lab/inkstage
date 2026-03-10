import Foundation
import AppKit

// MARK: - Tool Types
enum DrawingToolType: String, CaseIterable {
    case pen = "Pen"
    case marker = "Marker"
    case line = "Line"
    case rectangle = "Rectangle"
    case circle = "Circle"
    case text = "Text"
    case eraser = "Eraser"
    
    var icon: String {
        switch self {
        case .pen: return "pencil"
        case .marker: return "highlighter"
        case .line: return "line.diagonal"
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        case .text: return "textformat"
        case .eraser: return "eraser"
        }
    }
    
    var shortcut: String {
        switch self {
        case .pen: return "P"
        case .marker: return "M"
        case .line: return "L"
        case .rectangle: return "R"
        case .circle: return "O"
        case .text: return "T"
        case .eraser: return "E"
        }
    }
}

// MARK: - Drawing Action
enum DrawingAction {
    case stroke(DrawingStroke)
    case text(TextAnnotation)
}

// MARK: - Text Annotation
struct TextAnnotation {
    let id = UUID()
    var text: String
    var position: NSPoint
    var color: NSColor
    var fontSize: CGFloat
    var isEditing: Bool = true
}

// MARK: - Tool Settings
class ToolSettings: ObservableObject {
    static let shared = ToolSettings()
    
    @Published var currentTool: DrawingToolType = .pen
    @Published var penWidth: CGFloat = 4.0
    @Published var markerWidth: CGFloat = 12.0
    @Published var markerOpacity: CGFloat = 0.5
    @Published var showArrow: Bool = false
    @Published var fillShape: Bool = false
    @Published var fontSize: CGFloat = 24.0
    @Published var eraserSize: CGFloat = 20.0
    
    var currentWidth: CGFloat {
        switch currentTool {
        case .pen: return penWidth
        case .marker: return markerWidth
        case .line, .rectangle, .circle: return penWidth
        case .text: return fontSize
        case .eraser: return eraserSize
        }
    }
}
