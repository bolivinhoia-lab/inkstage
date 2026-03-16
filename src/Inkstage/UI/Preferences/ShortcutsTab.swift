import SwiftUI

struct ShortcutsTab: View {
    var body: some View {
        VStack {
            Text("Shortcuts Configuration")
                .font(.headline)
                .padding()
            Text("In this tab, you will be able to customize global and application shortcuts.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}
