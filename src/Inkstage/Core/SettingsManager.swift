import Foundation
import AppKit

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var penColor: NSColor {
        didSet { saveColor(penColor, forKey: "penColor") }
    }
    
    @Published var penWidth: CGFloat {
        didSet { UserDefaults.standard.set(penWidth, forKey: "penWidth") }
    }
    
    @Published var autoEraseDelay: Double {
        didSet { UserDefaults.standard.set(autoEraseDelay, forKey: "autoEraseDelay") }
    }
    
    @Published var autoEraseEnabled: Bool {
        didSet { UserDefaults.standard.set(autoEraseEnabled, forKey: "autoEraseEnabled") }
    }
    
    // Cores disponíveis
    @Published var startAtLogin: Bool = false { didSet { UserDefaults.standard.set(startAtLogin, forKey: "startAtLogin") } }
    @Published var highlightAtLogin: Bool = false { didSet { UserDefaults.standard.set(highlightAtLogin, forKey: "highlightAtLogin") } }
    @Published var whiteboardColor: NSColor = .white { didSet { saveColor(whiteboardColor, forKey: "whiteboardColor") } }
    @Published var cursorHighlightOpacity: Double = 0.5 { didSet { UserDefaults.standard.set(cursorHighlightOpacity, forKey: "cursorHighlightOpacity") } }
    @Published var cursorHighlightSize: Double = 50.0 { didSet { UserDefaults.standard.set(cursorHighlightSize, forKey: "cursorHighlightSize") } }
    @Published var cursorHighlightColor: NSColor = .systemYellow { didSet { saveColor(cursorHighlightColor, forKey: "cursorHighlightColor") } }
    @Published var spotlightSize: Double = 150.0 { didSet { UserDefaults.standard.set(spotlightSize, forKey: "spotlightSize") } }
    @Published var spotlightOpacity: Double = 0.5 { didSet { UserDefaults.standard.set(spotlightOpacity, forKey: "spotlightOpacity") } }
    @Published var zoomLevel: Double = 2.0 { didSet { UserDefaults.standard.set(zoomLevel, forKey: "zoomLevel") } }
    @Published var zoomWindowSize: Double = 200.0 { didSet { UserDefaults.standard.set(zoomWindowSize, forKey: "zoomWindowSize") } }
    @Published var zoomShape: String = "circle" { didSet { UserDefaults.standard.set(zoomShape, forKey: "zoomShape") } }

    let availableColors: [(name: String, color: NSColor)] = [
        ("Yellow", .systemYellow),
        ("Red", .systemRed),
        ("Blue", .systemBlue),
        ("Green", .systemGreen),
        ("Purple", .systemPurple),
        ("Orange", .systemOrange),
        ("Pink", .systemPink),
        ("Cyan", .systemCyan),
        ("White", .white),
        ("Black", .black)
    ]
    
    private init() {
        let defaults = UserDefaults.standard
        
        // Pen Color
        if let colorData = defaults.data(forKey: "penColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            self.penColor = color
        } else {
            self.penColor = .systemYellow
        }
        
        // Pen Width
        self.penWidth = defaults.object(forKey: "penWidth") as? CGFloat ?? 4.0
        
        // Auto Erase
        self.autoEraseDelay = defaults.object(forKey: "autoEraseDelay") as? Double ?? 3.0
        self.autoEraseEnabled = defaults.object(forKey: "autoEraseEnabled") as? Bool ?? true
    }
    
    private func saveColor(_ color: NSColor, forKey key: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func colorForName(_ name: String) -> NSColor {
        return availableColors.first { $0.name == name }?.color ?? .systemYellow
    }
    
    func setColorByName(_ name: String) {
        penColor = colorForName(name)
    }
}
