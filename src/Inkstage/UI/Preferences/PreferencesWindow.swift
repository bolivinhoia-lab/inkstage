import AppKit
import SwiftUI

// MARK: - Settings View
struct ModernPreferencesView: View {
    var body: some View {
        TabView {
            GeneralTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            AnnotateTab()
                .tabItem {
                    Label("Annotate", systemImage: "pencil.line")
                }
            CursorTab()
                .tabItem {
                    Label("Cursor", systemImage: "cursorarrow.click")
                }
            ShortcutsTab()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .frame(width: 700, height: 500)
    }
}

// MARK: - Preferences Window Controller
class PreferencesWindowController: NSObject {
    static let shared = PreferencesWindowController()
    
    private var window: NSWindow?
    
    func show() {
        if window == nil {
            createWindow()
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func createWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Inkstage Settings"
        window.toolbarStyle = .preference
        window.center()
        window.isReleasedWhenClosed = false
        
        let hostingView = NSHostingView(rootView: ModernPreferencesView())
        window.contentView = hostingView
        
        self.window = window
    }
}
