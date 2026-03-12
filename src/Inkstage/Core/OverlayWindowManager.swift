import AppKit
import SwiftUI

class OverlayWindowManager: NSObject, NSWindowDelegate {
    static let shared = OverlayWindowManager()

    private var annotationWindow: NSPanel?
    private var drawingView: DrawingView?

    var isTextFieldActive: Bool {
        // Check if any text field is currently being edited
        return drawingView?.isEditingText ?? false
    }

    func setupAnnotationWindow() {
        let screenRect = NSScreen.main?.frame ?? .zero

        let panel = NSPanel(
            contentRect: screenRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .screenSaver
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Create drawing view
        let drawingView = DrawingView(frame: screenRect)
        drawingView.isDrawingEnabled = false

        // Callbacks
        drawingView.onEscapePressed = {
            AppStateManager.shared.handleEscape()
        }
        drawingView.onRightClick = { [weak self] in
            self?.showContextMenu()
        }

        self.drawingView = drawingView
        panel.contentView = drawingView

        self.annotationWindow = panel
        panel.makeKeyAndOrderFront(nil)
    }

    func activateDrawingMode(showToolbar: Bool = true) {
        annotationWindow?.ignoresMouseEvents = false
        drawingView?.isDrawingEnabled = true

        if let window = annotationWindow {
            window.makeKey()
            window.makeFirstResponder(drawingView)
            print("🔑 Annotation window made key, drawingView is first responder")
        }

        if showToolbar {
            FloatingToolbarController.shared.show()
        }

        NSCursor.crosshair.push()
        ToastManager.shared.show(message: "✏️ Drawing Mode - ESC to exit")
    }

    func deactivateDrawingMode() {
        annotationWindow?.ignoresMouseEvents = true
        drawingView?.isDrawingEnabled = false
        drawingView?.clearCurrentTextField()

        // Hide toolbar
        FloatingToolbarController.shared.hide()

        NSCursor.pop()
    }

    func clearAnnotations() {
        drawingView?.clear()
    }

    func undo() {
        drawingView?.undo()
    }

    func redo() {
        drawingView?.redo()
    }

    func setInteractiveMode(_ interactive: Bool) {
        // When in interactive mode, allow mouse events to pass through
        annotationWindow?.ignoresMouseEvents = interactive
        if interactive {
            NSCursor.pop()
        } else {
            NSCursor.crosshair.push()
        }
    }

    // MARK: - Context Menu
    private func showContextMenu() {
        let menu = NSMenu()

        let statusTitle = AppStateManager.shared.isDrawing ? "✏️ Drawing Mode" : "👁️ Pass-through"
        menu.addItem(withTitle: statusTitle, action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())

        let clearItem = NSMenuItem(title: "Clear All", action: #selector(menuClear), keyEquivalent: "")
        clearItem.target = self
        menu.addItem(clearItem)

        let prefsItem = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: "")
        prefsItem.target = self
        menu.addItem(prefsItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(menuQuit), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: drawingView!)
        }
    }

    @objc private func menuClear() {
        drawingView?.clear()
    }

    @objc private func menuQuit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Preferences Window
    @objc func openPreferences() {
        PreferencesWindowController.shared.show()
    }
}
