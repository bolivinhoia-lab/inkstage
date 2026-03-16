import AppKit

let width: CGFloat = 600
let height: CGFloat = 400

let image = NSImage(size: NSSize(width: width, height: height))
image.lockFocus()

let context = NSGraphicsContext.current!.cgContext
let colorSpace = CGColorSpaceCreateDeviceRGB()
let colors = [NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor,
              NSColor(calibratedRed: 0.18, green: 0.18, blue: 0.18, alpha: 1.0).cgColor] as CFArray
let locations: [CGFloat] = [0.0, 1.0]

if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: height), end: CGPoint(x: 0, y: 0), options: [])
}

let arrowPath = NSBezierPath()
let cx = width / 2
let cy = height / 2

arrowPath.move(to: NSPoint(x: cx - 20, y: cy - 10))
arrowPath.line(to: NSPoint(x: cx + 10, y: cy - 10))
arrowPath.line(to: NSPoint(x: cx + 10, y: cy - 20))
arrowPath.line(to: NSPoint(x: cx + 30, y: cy))
arrowPath.line(to: NSPoint(x: cx + 10, y: cy + 20))
arrowPath.line(to: NSPoint(x: cx + 10, y: cy + 10))
arrowPath.line(to: NSPoint(x: cx - 20, y: cy + 10))
arrowPath.close()

NSColor(white: 0.8, alpha: 1.0).setFill()
arrowPath.fill()

let text = "Drag to install" as NSString
let font = NSFont.systemFont(ofSize: 18, weight: .medium)
let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor(white: 1.0, alpha: 0.8)]
let textSize = text.size(withAttributes: attrs)
text.draw(at: NSPoint(x: (width - textSize.width) / 2, y: cy - 40), withAttributes: attrs)

image.unlockFocus()

if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: "build/dmg-background.png")
    try? pngData.write(to: url)
    print("Background generated at build/dmg-background.png")
}
