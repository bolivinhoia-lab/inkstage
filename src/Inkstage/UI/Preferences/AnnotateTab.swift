import SwiftUI

struct AnnotateTab: View {
    @ObservedObject var settings = SettingsManager.shared
    @State private var selectedColorIndex: Int = 0
    
    var favoriteColors: [NSColor] = [
        .systemCyan, .systemPink, .systemGreen, .systemYellow, .systemPurple
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Favorite Colors")) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                    ForEach(0..<favoriteColors.count, id: \.self) { index in
                        Circle()
                            .fill(Color(favoriteColors[index]))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedColorIndex == index ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedColorIndex = index
                                settings.penColor = favoriteColors[index]
                            }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Drawing")) {
                Picker("Line Weight", selection: .constant(1)) {
                    Text("Light").tag(0)
                    Text("Medium").tag(1)
                    Text("Heavy").tag(2)
                }
                .pickerStyle(.segmented)
                
                ColorPicker("Whiteboard Color", selection: Binding(
                    get: { Color(settings.whiteboardColor) },
                    set: { settings.whiteboardColor = NSColor($0) }
                ))
            }
            
            Section(header: Text("Behavior")) {
                Toggle("Auto-erase annotations", isOn: $settings.autoEraseEnabled)
                Toggle("Save session on exit", isOn: .constant(false))
            }
        }
        .padding()
    }
}
