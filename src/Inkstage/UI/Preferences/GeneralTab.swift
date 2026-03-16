import SwiftUI

struct GeneralTab: View {
    @ObservedObject var settings = SettingsManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Startup")) {
                Toggle("Start at login", isOn: $settings.startAtLogin)
                Toggle("Highlight cursor at login", isOn: $settings.highlightAtLogin)
            }
            
            Section(header: Text("About Inkstage")) {
                HStack {
                    if let appIcon = NSImage(named: "AppIcon") {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 64, height: 64)
                    } else {
                        Image(systemName: "pencil.and.outline")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.accentColor)
                    }
                    VStack(alignment: .leading) {
                        Text("Inkstage")
                            .font(.headline)
                        Text("Version 2.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                Button("Restore Defaults") {
                    // Action for restore defaults
                }
            }
        }
        .padding()
    }
}
