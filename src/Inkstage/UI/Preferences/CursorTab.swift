import SwiftUI

struct CursorTab: View {
    @ObservedObject var settings = SettingsManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Highlight")) {
                VStack(alignment: .leading) {
                    Text("Opacity")
                    Slider(value: $settings.cursorHighlightOpacity, in: 0...1)
                }
                
                ColorPicker("Color", selection: Binding(
                    get: { Color(settings.cursorHighlightColor) },
                    set: { settings.cursorHighlightColor = NSColor($0) }
                ))
                
                VStack(alignment: .leading) {
                    Text("Size")
                    Slider(value: $settings.cursorHighlightSize, in: 20...100)
                }
            }
            
            Section(header: Text("Spotlight")) {
                VStack(alignment: .leading) {
                    Text("Size")
                    Slider(value: $settings.spotlightSize, in: 50...300)
                }
                VStack(alignment: .leading) {
                    Text("Opacity")
                    Slider(value: $settings.spotlightOpacity, in: 0.2...0.9)
                }
            }
            
            Section(header: Text("Zoom")) {
                VStack(alignment: .leading) {
                    Text("Zoom Level")
                    Slider(value: $settings.zoomLevel, in: 1.5...5, step: 0.5)
                }
                VStack(alignment: .leading) {
                    Text("Size")
                    Slider(value: $settings.zoomWindowSize, in: 100...400)
                }
                Picker("Shape", selection: $settings.zoomShape) {
                    Text("Circle").tag("circle")
                    Text("Rectangle").tag("rectangle")
                }
            }
        }
        .padding()
    }
}
