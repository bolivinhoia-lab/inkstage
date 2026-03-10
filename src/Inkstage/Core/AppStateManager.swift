import AppKit
import Combine

// MARK: - App States
enum AppMode: Equatable {
    case idle              // App rodando, nada ativo
    case drawing          // Modo desenho ativo
    case cursorHighlight  // Highlight de cursor ativo
    case spotlight        // Spotlight ativo
    case zoom             // Zoom ativo
    case whiteboard       // Whiteboard ativo
}

// MARK: - Global State Manager
class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published private(set) var currentMode: AppMode = .idle
    @Published var selectedTool: DrawingToolType = .pen
    
    private var cancellables = Set<AnyCancellable>()
    
    // Referências aos managers
    private var overlayManager: OverlayWindowManager?
    private var cursorHighlighter: CursorHighlighter?
    private var spotlightManager: SpotlightManager?
    private var zoomManager: ZoomManager?
    private var whiteboardManager: WhiteboardManager?
    
    private init() {}
    
    func configure(
        overlay: OverlayWindowManager,
        cursor: CursorHighlighter,
        spotlight: SpotlightManager,
        zoom: ZoomManager,
        whiteboard: WhiteboardManager
    ) {
        self.overlayManager = overlay
        self.cursorHighlighter = cursor
        self.spotlightManager = spotlight
        self.zoomManager = zoom
        self.whiteboardManager = whiteboard
    }
    
    // MARK: - State Transitions
    
    func toggleDrawing() {
        if currentMode == .drawing {
            deactivateAll()
        } else {
            deactivateAll()
            currentMode = .drawing
            overlayManager?.activateDrawingMode()
            showToast("✏️ Drawing Mode")
        }
    }
    
    func toggleCursorHighlight() {
        if currentMode == .cursorHighlight {
            deactivateAll()
        } else {
            deactivateAll()
            currentMode = .cursorHighlight
            cursorHighlighter?.activate()
            showToast("✨ Cursor Highlight")
        }
    }
    
    func toggleSpotlight() {
        if currentMode == .spotlight {
            deactivateAll()
        } else {
            deactivateAll()
            currentMode = .spotlight
            spotlightManager?.activate()
            showToast("🔦 Spotlight")
        }
    }
    
    func toggleZoom() {
        if currentMode == .zoom {
            deactivateAll()
        } else {
            deactivateAll()
            currentMode = .zoom
            zoomManager?.activate()
            showToast("🔍 Zoom 2x")
        }
    }
    
    func toggleWhiteboard() {
        if currentMode == .whiteboard {
            deactivateAll()
        } else {
            deactivateAll()
            currentMode = .whiteboard
            whiteboardManager?.activate()
            showToast("⬜ Whiteboard")
        }
    }
    
    func deactivateAll() {
        // Desativa tudo
        overlayManager?.deactivateDrawingMode()
        cursorHighlighter?.deactivate()
        spotlightManager?.deactivate()
        zoomManager?.deactivate()
        whiteboardManager?.deactivate()
        
        currentMode = .idle
    }
    
    func handleEscape() {
        if currentMode != .idle {
            deactivateAll()
            showToast("👁️ Normal Mode")
        }
    }
    
    func selectTool(_ tool: DrawingToolType) {
        selectedTool = tool
        ToolSettings.shared.currentTool = tool
        
        // Se não estiver em modo desenho, ativa
        if currentMode != .drawing {
            toggleDrawing()
        }
    }
    
    // MARK: - Helpers
    
    private func showToast(_ message: String) {
        ToastManager.shared.show(message: message)
    }
    
    var isDrawing: Bool { currentMode == .drawing }
    var isCursorHighlight: Bool { currentMode == .cursorHighlight }
    var isSpotlight: Bool { currentMode == .spotlight }
    var isZoom: Bool { currentMode == .zoom }
    var isWhiteboard: Bool { currentMode == .whiteboard }
}

// MARK: - Toast Manager
class ToastManager {
    static let shared = ToastManager()
    
    private var toastWindow: NSPanel?
    private var hideTimer: Timer?
    
    func show(message: String, duration: TimeInterval = 1.5) {
        // Cancela timer anterior
        hideTimer?.invalidate()
        
        // Fecha toast anterior
        toastWindow?.orderOut(nil)
        
        guard let screen = NSScreen.main else { return }
        
        let label = NSTextField(labelWithString: message)
        label.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.sizeToFit()
        
        let padding: CGFloat = 20
        let width = label.frame.width + padding * 2
        let height: CGFloat = 44
        
        let screenRect = screen.frame
        let x = (screenRect.width - width) / 2
        let y = screenRect.height - 100
        
        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: width, height: height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .statusBar + 10
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        
        // Container com fundo escuro arredondado
        let container = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.8).cgColor
        container.layer?.cornerRadius = height / 2
        
        label.frame.origin = NSPoint(x: padding, y: (height - label.frame.height) / 2)
        container.addSubview(label)
        
        panel.contentView = container
        
        toastWindow = panel
        panel.makeKeyAndOrderFront(nil)
        
        // Animação de entrada
        panel.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            panel.animator().alphaValue = 1
        }
        
        // Timer para esconder
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.hideToast()
        }
    }
    
    private func hideToast() {
        guard let window = toastWindow else { return }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.toastWindow?.orderOut(nil)
            self?.toastWindow = nil
        }
    }
}
