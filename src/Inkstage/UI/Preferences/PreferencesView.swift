import SwiftUI
import AppKit

struct PreferencesView: View {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var toolSettings = ToolSettings.shared
    
    var body: some View {
        TabView {
            // MARK: - Aba Anotação
            annotationTab
                .tabItem {
                    Label("Annotation", systemImage: "pencil.tip.crop.circle")
                }
            
            // MARK: - Aba Ferramentas
            toolsTab
                .tabItem {
                    Label("Tools", systemImage: "paintbrush")
                }
            
            // MARK: - Aba Atalhos
            shortcutsTab
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .frame(width: 550, height: 450)
        .padding()
    }
    
    // MARK: - Annotation Tab
    private var annotationTab: some View {
        Form {
            Section(header: Text("Pen Settings").font(.headline)) {
                VStack(alignment: .leading, spacing: 16) {
                    // Color Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pen Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                            ForEach(settings.availableColors, id: \.name) { colorInfo in
                                ColorButton(
                                    name: colorInfo.name,
                                    color: Color(colorInfo.color),
                                    isSelected: settings.penColor == colorInfo.color
                                ) {
                                    settings.penColor = colorInfo.color
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Line Width
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Line Width")
                                .font(.subheadline)
                            Spacer()
                            Text("\(settings.penWidth, specifier: "%.1f")pt")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $settings.penWidth, in: 1...20, step: 0.5)
                        
                        // Preview
                        HStack {
                            Spacer()
                            Canvas { context, size in
                                let path = Path { path in
                                    path.move(to: CGPoint(x: 0, y: size.height/2))
                                    path.addLine(to: CGPoint(x: size.width, y: size.height/2))
                                }
                                context.stroke(path, with: .color(Color(settings.penColor)), lineWidth: settings.penWidth)
                            }
                            .frame(height: max(20, settings.penWidth + 10))
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Section(header: Text("Auto Erase").font(.headline)) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Auto Erase", isOn: $settings.autoEraseEnabled)
                    
                    if settings.autoEraseEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Delay")
                                Spacer()
                                Text("\(settings.autoEraseDelay, specifier: "%.1f")s")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.autoEraseDelay, in: 0.5...10, step: 0.5)
                            Text("Drawings will disappear after this time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Tools Tab
    private var toolsTab: some View {
        Form {
            Section(header: Text("Marker Settings").font(.headline)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Marker Width")
                        Spacer()
                        Text("\(toolSettings.markerWidth, specifier: "%.1f")pt")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $toolSettings.markerWidth, in: 5...30, step: 1)
                    
                    HStack {
                        Text("Marker Opacity")
                        Spacer()
                        Text("\(Int(toolSettings.markerOpacity * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $toolSettings.markerOpacity, in: 0.1...1.0, step: 0.1)
                }
            }
            
            Section(header: Text("Shape Settings").font(.headline)) {
                Toggle("Fill Shapes", isOn: $toolSettings.fillShape)
                Toggle("Show Arrow on Lines", isOn: $toolSettings.showArrow)
            }
            
            Section(header: Text("Text Settings").font(.headline)) {
                HStack {
                    Text("Font Size")
                    Spacer()
                    Text("\(Int(toolSettings.fontSize))pt")
                        .foregroundColor(.secondary)
                }
                Slider(value: $toolSettings.fontSize, in: 12...72, step: 2)
            }
            
            Section(header: Text("Eraser Settings").font(.headline)) {
                HStack {
                    Text("Eraser Size")
                    Spacer()
                    Text("\(Int(toolSettings.eraserSize))pt")
                        .foregroundColor(.secondary)
                }
                Slider(value: $toolSettings.eraserSize, in: 10...50, step: 5)
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Shortcuts Tab
    private var shortcutsTab: some View {
        Form {
            Section(header: Text("Global Shortcuts").font(.headline)) {
                ShortcutRow(key: "⌘⇧A", description: "Toggle Drawing Mode")
                ShortcutRow(key: "⌘⇧C", description: "Toggle Cursor Highlight")
                ShortcutRow(key: "⌘⇧S", description: "Toggle Spotlight")
                ShortcutRow(key: "⌘⇧Z", description: "Toggle Zoom")
                ShortcutRow(key: "⌘Q", description: "Quit Inkstage")
            }
            
            Section(header: Text("Drawing Mode Shortcuts").font(.headline)) {
                ShortcutRow(key: "ESC", description: "Exit Drawing Mode")
                ShortcutRow(key: "P", description: "Pen Tool")
                ShortcutRow(key: "M", description: "Marker Tool")
                ShortcutRow(key: "L", description: "Line Tool")
                ShortcutRow(key: "R", description: "Rectangle Tool")
                ShortcutRow(key: "O", description: "Circle Tool")
                ShortcutRow(key: "T", description: "Text Tool")
                ShortcutRow(key: "E", description: "Eraser Tool")
                ShortcutRow(key: "⌘Z", description: "Undo")
                ShortcutRow(key: "1-5", description: "Quick Color Switch")
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .shadow(radius: 1)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
        .help(name)
    }
}

// MARK: - Shortcut Row
struct ShortcutRow: View {
    let key: String
    let description: String
    
    var body: some View {
        HStack {
            Text(description)
            Spacer()
            Text(key)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 2)
    }
}
