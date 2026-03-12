import AppKit
import SwiftUI

// MARK: - Shortcut Helper Overlay
class ShortcutOverlay {
    static let shared = ShortcutOverlay()
    
    private var overlayWindow: NSPanel?
    private var dismissTimer: Timer?
    
    func show() {
        // Don't show if already visible
        guard overlayWindow == nil else {
            hide()
            return
        }
        
        // Cancel any existing timer
        dismissTimer?.invalidate()
        
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        
        // Calculate size based on content
        let width: CGFloat = 480
        let height: CGFloat = 580
        
        let x = (screenFrame.width - width) / 2
        let y = (screenFrame.height - height) / 2
        
        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: width, height: height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .statusBar + 100
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Create the SwiftUI hosting view
        let contentView = NSHostingView(rootView: ShortcutOverlayView(onDismiss: { [weak self] in
            self?.hide()
        }))
        
        // Wrap in a visual effect view for frosted glass
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 16
        visualEffectView.layer?.borderWidth = 0.5
        visualEffectView.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
        
        // Add shadow
        visualEffectView.layer?.shadowColor = NSColor.black.cgColor
        visualEffectView.layer?.shadowOpacity = 0.4
        visualEffectView.layer?.shadowRadius = 30
        visualEffectView.layer?.shadowOffset = CGSize(width: 0, height: 10)
        
        contentView.frame = visualEffectView.bounds
        visualEffectView.addSubview(contentView)
        
        panel.contentView = visualEffectView
        
        overlayWindow = panel
        panel.makeKeyAndOrderFront(nil)
        
        // Fade in animation
        panel.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
        
        // Auto-dismiss after 8 seconds or keep until ESC/click
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            self?.hide()
        }
        
        // Dismiss on click outside
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.hide()
        }
    }
    
    func hide() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        guard let panel = overlayWindow else { return }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            panel.orderOut(nil)
            self?.overlayWindow = nil
        }
    }
}

// MARK: - Shortcut Overlay View
struct ShortcutOverlayView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Global Shortcuts
                    ShortcutSection(title: "Global Shortcuts") {
                        HelpShortcutRow(key: "⌃A", description: "Annotate Screen")
                        HelpShortcutRow(key: "⌃⌥A", description: "Annotate Without Controls")
                        HelpShortcutRow(key: "⌃S", description: "Highlight Cursor")
                        HelpShortcutRow(key: "⌃L", description: "Spotlight Cursor")
                        HelpShortcutRow(key: "⌃Z", description: "Zoom Cursor")
                        HelpShortcutRow(key: "/", description: "Show This Help")
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Colors
                    ShortcutSection(title: "Colors") {
                        HStack(spacing: 12) {
                            HelpColorDot(color: .cyan)
                            HelpShortcutRow(key: "1", description: "Cyan")
                        }
                        HStack(spacing: 12) {
                            HelpColorDot(color: .pink)
                            HelpShortcutRow(key: "2", description: "Rose")
                        }
                        HStack(spacing: 12) {
                            HelpColorDot(color: .green)
                            HelpShortcutRow(key: "3", description: "Lime")
                        }
                        HStack(spacing: 12) {
                            HelpColorDot(color: .yellow)
                            HelpShortcutRow(key: "4", description: "Yellow")
                        }
                        HStack(spacing: 12) {
                            HelpColorDot(color: .purple)
                            HelpShortcutRow(key: "5", description: "Violet")
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Tools
                    ShortcutSection(title: "Drawing Tools") {
                        HelpShortcutRow(key: "F", description: "Free Hand")
                        HelpShortcutRow(key: "A", description: "Arrow")
                        HelpShortcutRow(key: "R", description: "Rectangle")
                        HelpShortcutRow(key: "C", description: "Circle")
                        HelpShortcutRow(key: "T", description: "Text")
                        HelpShortcutRow(key: "H", description: "Highlighter")
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Actions
                    ShortcutSection(title: "Actions") {
                        HelpShortcutRow(key: "⌫", description: "Clear All")
                        HelpShortcutRow(key: "⌘Z", description: "Undo")
                        HelpShortcutRow(key: "⇧⌘Z", description: "Redo")
                        HelpShortcutRow(key: "W", description: "Toggle Whiteboard")
                        HelpShortcutRow(key: "Fn (hold)", description: "Interactive Mode")
                        HelpShortcutRow(key: "ESC", description: "Exit Mode")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .frame(width: 480, height: 580)
    }
}

// MARK: - View Components
struct ShortcutSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(0.5)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
    }
}

struct HelpShortcutRow: View {
    let key: String
    let description: String
    
    var body: some View {
        HStack {
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 2) {
                ForEach(key.components(separatedBy: " "), id: \.self) { component in
                    HelpKeyBadge(text: component)
                }
            }
        }
    }
}

struct HelpKeyBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
    }
}

struct HelpColorDot: View {
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .shadow(color: color.opacity(0.5), radius: 4)
    }
}

// MARK: - Preview
#Preview {
    ShortcutOverlayView(onDismiss: {})
        .background(Color.black.opacity(0.8))
}
