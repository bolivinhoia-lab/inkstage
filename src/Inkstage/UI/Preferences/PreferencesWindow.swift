import AppKit
import SwiftUI

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
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Inkstage Settings"
        window.titlebarAppearsTransparent = true
        window.center()
        window.isReleasedWhenClosed = false
        
        // Create toolbar with preference style
        let toolbar = NSToolbar(identifier: "PreferencesToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconAndLabel
        toolbar.selectedItemIdentifier = .general
        window.toolbar = toolbar
        window.toolbarStyle = .preference
        
        // Set initial view
        let hostingView = NSHostingView(rootView: GeneralSettingsView())
        window.contentView = hostingView
        
        self.window = window
    }
    
    func switchToTab(_ identifier: NSToolbarItem.Identifier) {
        guard let window = window else { return }
        
        let view: AnyView
        switch identifier {
        case .general:
            view = AnyView(GeneralSettingsView())
        case .annotate:
            view = AnyView(AnnotateSettingsView())
        case .cursor:
            view = AnyView(CursorSettingsView())
        case .shortcuts:
            view = AnyView(ShortcutsSettingsView())
        case .about:
            view = AnyView(AboutSettingsView())
        default:
            return
        }
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = window.contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        window.contentView = hostingView
        
        window.toolbar?.selectedItemIdentifier = identifier
    }
}

// MARK: - Toolbar Delegate
extension PreferencesWindowController: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.general, .annotate, .cursor, .shortcuts, .about]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.general, .annotate, .cursor, .shortcuts, .about]
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.general, .annotate, .cursor, .shortcuts, .about]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        switch itemIdentifier {
        case .general:
            item.label = "General"
            item.image = NSImage(systemSymbolName: "gear", accessibilityDescription: "General")
        case .annotate:
            item.label = "Annotate"
            item.image = NSImage(systemSymbolName: "pencil.line", accessibilityDescription: "Annotate")
        case .cursor:
            item.label = "Cursor"
            item.image = NSImage(systemSymbolName: "cursorarrow.click", accessibilityDescription: "Cursor")
        case .shortcuts:
            item.label = "Shortcuts"
            item.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Shortcuts")
        case .about:
            item.label = "About"
            item.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About")
        default:
            return nil
        }
        
        item.target = self
        item.action = #selector(toolbarItemClicked(_:))
        
        return item
    }
    
    @objc private func toolbarItemClicked(_ sender: NSToolbarItem) {
        switchToTab(sender.itemIdentifier)
    }
}

// MARK: - Toolbar Identifiers
extension NSToolbarItem.Identifier {
    static let general = NSToolbarItem.Identifier("general")
    static let annotate = NSToolbarItem.Identifier("annotate")
    static let cursor = NSToolbarItem.Identifier("cursor")
    static let shortcuts = NSToolbarItem.Identifier("shortcuts")
    static let about = NSToolbarItem.Identifier("about")
}

// MARK: - Settings Views
struct GeneralSettingsView: View {
    @State private var startAtLogin = false
    @State private var highlightAtLogin = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Startup Section
                SettingsSection(title: "Startup") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Start at login", isOn: $startAtLogin)
                            .font(.system(size: 13))
                        
                        Toggle("Highlight cursor at login", isOn: $highlightAtLogin)
                            .font(.system(size: 13))
                    }
                }
                
                // Restore Section
                SettingsSection(title: "Settings") {
                    Button(action: restoreDefaults) {
                        Text("Restore Defaults")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func restoreDefaults() {
        SettingsManager.shared.penColor = .systemCyan
        SettingsManager.shared.penWidth = 4.0
        SettingsManager.shared.autoEraseEnabled = true
        SettingsManager.shared.autoEraseDelay = 3.0
        
        // Show confirmation
        ToastManager.shared.show(message: "Settings restored to defaults")
    }
}

struct AnnotateSettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var toolSettings = ToolSettings.shared
    
    let favoriteColors: [NSColor] = [
        .systemCyan,
        .systemPink,
        .systemGreen,
        .systemYellow,
        .systemPurple
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Colors Section
                SettingsSection(title: "Favorite Colors") {
                    HStack(spacing: 12) {
                        ForEach(0..<favoriteColors.count, id: \.self) { index in
                            AnnotateColorButton(
                                color: favoriteColors[index],
                                isSelected: colorsEqual(settings.penColor, favoriteColors[index]),
                                onTap: {
                                    settings.penColor = favoriteColors[index]
                                }
                            )
                        }
                    }
                }
                
                // Line Weight Section
                SettingsSection(title: "Line Weight") {
                    Picker("", selection: $toolSettings.penWidth) {
                        Text("Light (2pt)").tag(CGFloat(2.0))
                        Text("Medium (4pt)").tag(CGFloat(4.0))
                        Text("Heavy (8pt)").tag(CGFloat(8.0))
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                
                // Text Settings
                SettingsSection(title: "Text") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Size: \(Int(toolSettings.fontSize))pt")
                                .font(.system(size: 13))
                            Spacer()
                        }
                        
                        Slider(value: $toolSettings.fontSize, in: 12...72, step: 1)
                    }
                }
                
                // Behavior Section
                SettingsSection(title: "Behavior") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Auto-erase annotations", isOn: $settings.autoEraseEnabled)
                            .font(.system(size: 13))
                        
                        if settings.autoEraseEnabled {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fade after: \(Int(settings.autoEraseDelay)) seconds")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Slider(value: $settings.autoEraseDelay, in: 1...10, step: 0.5)
                            }
                            .padding(.leading, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func colorsEqual(_ c1: NSColor, _ c2: NSColor) -> Bool {
        let rgb1 = c1.usingColorSpace(.sRGB) ?? c1
        let rgb2 = c2.usingColorSpace(.sRGB) ?? c2
        return abs(rgb1.redComponent - rgb2.redComponent) < 0.01 &&
               abs(rgb1.greenComponent - rgb2.greenComponent) < 0.01 &&
               abs(rgb1.blueComponent - rgb2.blueComponent) < 0.01
    }
}

struct CursorSettingsView: View {
    @State private var highlightEnabled = true
    @State private var highlightColor = Color.yellow
    @State private var highlightSize: CGFloat = 40
    @State private var highlightOpacity: Double = 0.5
    @State private var spotlightSize: CGFloat = 150
    @State private var spotlightOpacity: Double = 0.7
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Cursor Highlight Section
                SettingsSection(title: "Cursor Highlight") {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Enable cursor highlight", isOn: $highlightEnabled)
                            .font(.system(size: 13))
                        
                        if highlightEnabled {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Color")
                                        .font(.system(size: 13))
                                    Spacer()
                                    ColorPicker("", selection: $highlightColor)
                                        .labelsHidden()
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Size: \(Int(highlightSize))px")
                                        .font(.system(size: 12))
                                    Slider(value: $highlightSize, in: 20...100)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Opacity: \(Int(highlightOpacity * 100))%")
                                        .font(.system(size: 12))
                                    Slider(value: $highlightOpacity, in: 0.1...1.0)
                                }
                            }
                            .padding(.leading, 20)
                        }
                    }
                }
                
                // Spotlight Section
                SettingsSection(title: "Spotlight") {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Spotlight Size: \(Int(spotlightSize))px")
                                .font(.system(size: 12))
                            Slider(value: $spotlightSize, in: 50...300)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Background Opacity: \(Int(spotlightOpacity * 100))%")
                                .font(.system(size: 12))
                            Slider(value: $spotlightOpacity, in: 0.2...0.95)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ShortcutsSettingsView: View {
    let globalShortcuts = [
        ("Annotate Screen", "⌃A"),
        ("Annotate Without Controls", "⌃⌥A"),
        ("Highlight Cursor", "⌃S"),
        ("Spotlight Cursor", "⌃L"),
        ("Zoom Cursor", "⌃Z"),
        ("Show Shortcuts", "/")
    ]
    
    let annotationShortcuts = [
        ("Free Hand", "F"),
        ("Arrow", "A"),
        ("Rectangle", "R"),
        ("Circle", "C"),
        ("Text", "T"),
        ("Highlighter", "H"),
        ("Clear All", "⌫"),
        ("Undo", "⌘Z"),
        ("Redo", "⇧⌘Z"),
        ("Exit Mode", "ESC")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Global Shortcuts
                SettingsSection(title: "Global Shortcuts") {
                    VStack(spacing: 8) {
                        ForEach(globalShortcuts, id: \.0) { shortcut in
                            ShortcutListRow(name: shortcut.0, keyCombo: shortcut.1)
                        }
                    }
                }
                
                // Annotation Shortcuts
                SettingsSection(title: "Annotation Mode") {
                    VStack(spacing: 8) {
                        ForEach(annotationShortcuts, id: \.0) { shortcut in
                            ShortcutListRow(name: shortcut.0, keyCombo: shortcut.1)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
            }
            
            // App Name
            Text("Inkstage")
                .font(.system(size: 24, weight: .semibold))
            
            // Version
            Text("Version 1.0 (Build 100)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            // Description
            Text("Modern screen annotation tool for macOS")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Links
            HStack(spacing: 20) {
                Link("Website", destination: URL(string: "https://inkstage.app")!)
                Link("Support", destination: URL(string: "https://inkstage.app/support")!)
                Link("Privacy Policy", destination: URL(string: "https://inkstage.app/privacy")!)
            }
            .font(.system(size: 12))
            
            Text("© 2026 Inkstage. All rights reserved.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Helper Views
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            
            content
        }
    }
}

struct AnnotateColorButton: View {
    let color: NSColor
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(Color(color))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
                .shadow(color: Color(color).opacity(0.5), radius: isSelected ? 6 : 0)
        }
        .buttonStyle(.plain)
    }
}

struct ShortcutListRow: View {
    let name: String
    let keyCombo: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 13))
            
            Spacer()
            
            HStack(spacing: 2) {
                ForEach(keyCombo.components(separatedBy: " "), id: \.self) { key in
                    Text(key)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
            }
        }
        .padding(.vertical, 4)
    }
}
