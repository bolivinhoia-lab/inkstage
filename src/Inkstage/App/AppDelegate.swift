import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup managers
        _ = SettingsManager.shared
        _ = ToolSettings.shared
        
        // Setup global ESC handler FIRST
        GlobalShortcutManager.shared.setup()
        
        // Initialize UI
        OverlayWindowManager.shared.setupAnnotationWindow()
        MenuBarController.shared.setupMenuBar()
        
        // Configure state manager
        AppStateManager.shared.configure(
            overlay: OverlayWindowManager.shared,
            cursor: CursorHighlighter.shared,
            spotlight: SpotlightManager.shared,
            zoom: ZoomManager.shared,
            whiteboard: WhiteboardManager.shared
        )
        
        print("🚀 Inkstage Started")
        print("   Press ⌘⇧A for Drawing, ⌘⇧C Cursor, ⌘⇧S Spotlight, ⌘⇧Z Zoom, ⌘⇧W Whiteboard")
        print("   Press ESC anytime to exit any mode")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("👋 Inkstage shutting down...")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
}
