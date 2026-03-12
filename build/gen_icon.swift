
import AppKit

func createIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let margin = s * 0.08
    let rect = CGRect(x: margin, y: margin, width: s - 2*margin, height: s - 2*margin)
    let radius = s * 0.22

    // Dark background
    let bgPath = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(bgPath)
    ctx.clip()

    // Gradient background
    let colors = [
        CGColor(red: 0.15, green: 0.18, blue: 0.35, alpha: 1.0),
        CGColor(red: 0.08, green: 0.1, blue: 0.2, alpha: 1.0)
    ] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: s/2, y: s - margin), end: CGPoint(x: s/2, y: margin), options: [])

    ctx.resetClip()

    // Draw pencil using SF Symbol
    let tintColor = NSColor(red: 1.0, green: 0.82, blue: 0.23, alpha: 1.0)

    if let symbol = NSImage(systemSymbolName: "pencil.tip", accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: s * 0.4, weight: .medium)
        if let configured = symbol.withSymbolConfiguration(config) {
            let tinted = NSImage(size: configured.size)
            tinted.lockFocus()
            tintColor.set()
            let symRect = NSRect(origin: .zero, size: configured.size)
            configured.draw(in: symRect, from: .zero, operation: .sourceOver, fraction: 1.0)
            NSColor(red: 1.0, green: 0.82, blue: 0.23, alpha: 1.0).setFill()
            symRect.fill(using: .sourceAtop)
            tinted.unlockFocus()

            let symSize = tinted.size
            let drawRect = NSRect(
                x: (s - symSize.width) / 2,
                y: (s - symSize.height) / 2,
                width: symSize.width,
                height: symSize.height
            )
            tinted.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
    }

    // Ink dot
    let dotSize = s * 0.06
    let dotRect = CGRect(x: s * 0.35, y: s * 0.28, width: dotSize, height: dotSize)
    ctx.setFillColor(CGColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.9))
    ctx.fillEllipse(in: dotRect)

    // Small scribble line
    ctx.setStrokeColor(CGColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.7))
    ctx.setLineWidth(s * 0.015)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: s * 0.32, y: s * 0.25))
    ctx.addCurve(to: CGPoint(x: s * 0.48, y: s * 0.22), control1: CGPoint(x: s * 0.36, y: s * 0.20), control2: CGPoint(x: s * 0.42, y: s * 0.26))
    ctx.strokePath()

    image.unlockFocus()
    return image
}

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

let iconsetDir = "/Users/robsonoliveira/.openclaw/workspace/projects/Inkstage/build/Inkstage.iconset"

for (px, name) in sizes {
    let icon = createIcon(size: px)
    if let tiffData = icon.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        let url = URL(fileURLWithPath: iconsetDir + "/" + name)
        try! pngData.write(to: url)
    }
}

print("All icon sizes generated")
