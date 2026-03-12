#!/usr/bin/env python3
"""Generate Inkstage app icon using Pillow or fallback to basic approach."""
import subprocess
import os
import sys
import math

BUILD_DIR = os.path.dirname(os.path.abspath(__file__))
ICONSET_DIR = os.path.join(BUILD_DIR, "Inkstage.iconset")
ICNS_PATH = os.path.join(BUILD_DIR, "Inkstage.icns")

SIZES = [
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

def generate_with_pillow():
    from PIL import Image, ImageDraw, ImageFont, ImageFilter

    def draw_icon(size):
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        s = size  # shorthand

        # Background: rounded rectangle with gradient-like effect
        margin = int(s * 0.08)
        radius = int(s * 0.22)

        # Dark navy base
        draw.rounded_rectangle(
            [margin, margin, s - margin, s - margin],
            radius=radius,
            fill=(20, 25, 50, 255)
        )

        # Subtle gradient overlay (lighter at top)
        for i in range(s // 2):
            alpha = int(40 * (1 - i / (s / 2)))
            y = margin + i
            if y < s - margin:
                draw.line([(margin + radius // 2, y), (s - margin - radius // 2, y)],
                         fill=(100, 120, 200, alpha))

        # Draw a stylized pen/pencil
        cx, cy = s // 2, s // 2
        pen_length = int(s * 0.5)
        pen_width = int(s * 0.08)

        # Pen body (angled 45 degrees, bottom-left to top-right)
        angle = -45
        rad = math.radians(angle)

        # Calculate pen endpoints
        dx = math.cos(rad) * pen_length / 2
        dy = math.sin(rad) * pen_length / 2

        x1, y1 = cx - dx, cy - dy  # tip (bottom-left)
        x2, y2 = cx + dx, cy + dy  # top (top-right)

        # Pen body - yellow/gold
        perp_dx = math.cos(rad + math.pi/2) * pen_width / 2
        perp_dy = math.sin(rad + math.pi/2) * pen_width / 2

        body_points = [
            (x1 + perp_dx + dx * 0.3, y1 + perp_dy + dy * 0.3),
            (x2 + perp_dx, y2 + perp_dy),
            (x2 - perp_dx, y2 - perp_dy),
            (x1 - perp_dx + dx * 0.3, y1 - perp_dy + dy * 0.3),
        ]
        draw.polygon(body_points, fill=(255, 210, 60, 255))

        # Pen tip - darker
        tip_points = [
            (x1, y1),
            (x1 + perp_dx + dx * 0.3, y1 + perp_dy + dy * 0.3),
            (x1 - perp_dx + dx * 0.3, y1 - perp_dy + dy * 0.3),
        ]
        draw.polygon(tip_points, fill=(60, 60, 60, 255))

        # Ink dot at tip
        dot_size = max(int(s * 0.03), 2)
        draw.ellipse(
            [x1 - dot_size, y1 - dot_size, x1 + dot_size, y1 + dot_size],
            fill=(255, 80, 80, 255)
        )

        # Ink trail / scribble line from the pen tip
        trail_points = []
        for i in range(20):
            t = i / 19
            tx = x1 - int(s * 0.02) + t * int(s * 0.15)
            ty = y1 + int(s * 0.02) + math.sin(t * math.pi * 3) * int(s * 0.04)
            trail_points.append((tx, ty))

        if len(trail_points) > 1:
            draw.line(trail_points, fill=(255, 80, 80, 200), width=max(int(s * 0.015), 1))

        # Subtle stage/platform at bottom
        platform_y = s - margin - int(s * 0.15)
        platform_margin = margin + int(s * 0.1)
        draw.rounded_rectangle(
            [platform_margin, platform_y, s - platform_margin, s - margin - int(s * 0.04)],
            radius=int(s * 0.03),
            fill=(255, 255, 255, 30)
        )

        return img

    os.makedirs(ICONSET_DIR, exist_ok=True)

    for px_size, filename in SIZES:
        icon = draw_icon(px_size)
        icon.save(os.path.join(ICONSET_DIR, filename))

    # Convert to icns
    subprocess.run(["iconutil", "-c", "icns", ICONSET_DIR, "-o", ICNS_PATH], check=True)
    print(f"Icon created: {ICNS_PATH}")

def generate_with_swift():
    """Fallback: use Swift/AppKit to generate the icon."""
    swift_code = '''
    import AppKit

    let size = 1024
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext
    let s = CGFloat(size)
    let margin = s * 0.08
    let rect = CGRect(x: margin, y: margin, width: s - 2*margin, height: s - 2*margin)
    let radius = s * 0.22

    // Background
    let bgPath = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.setFillColor(CGColor(red: 0.08, green: 0.1, blue: 0.2, alpha: 1.0))
    ctx.addPath(bgPath)
    ctx.fillPath()

    // Pencil icon using SF Symbol
    if let symbol = NSImage(systemSymbolName: "pencil.tip", accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: s * 0.45, weight: .medium)
        let configured = symbol.withSymbolConfiguration(config)!
        let symSize = configured.size
        let symRect = CGRect(
            x: (s - symSize.width) / 2,
            y: (s - symSize.height) / 2 + s * 0.02,
            width: symSize.width,
            height: symSize.height
        )
        configured.draw(in: symRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    image.unlockFocus()

    // Save as PNG
    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        try! pngData.write(to: URL(fileURLWithPath: "ICONSET_DIR/icon_512x512@2x.png"))
    }
    '''.replace("ICONSET_DIR", ICONSET_DIR)

    # Just use a simpler approach - create a basic colored square icon
    os.makedirs(ICONSET_DIR, exist_ok=True)

    # Generate using sips from a base image
    # Create the 1024 icon first using Swift
    swift_icon_script = f'''
import AppKit

func createIcon(size: Int) -> NSImage {{
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {{
        image.unlockFocus()
        return image
    }}

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

    if let symbol = NSImage(systemSymbolName: "pencil.tip", accessibilityDescription: nil) {{
        let config = NSImage.SymbolConfiguration(pointSize: s * 0.4, weight: .medium)
        if let configured = symbol.withSymbolConfiguration(config) {{
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
        }}
    }}

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
}}

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

let iconsetDir = "{ICONSET_DIR}"

for (px, name) in sizes {{
    let icon = createIcon(size: px)
    if let tiffData = icon.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {{
        let url = URL(fileURLWithPath: iconsetDir + "/" + name)
        try! pngData.write(to: url)
    }}
}}

print("All icon sizes generated")
'''

    script_path = os.path.join(BUILD_DIR, "gen_icon.swift")
    with open(script_path, "w") as f:
        f.write(swift_icon_script)

    result = subprocess.run(["swift", script_path], capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Swift icon gen failed: {result.stderr}")
        return False

    # Convert to icns
    result = subprocess.run(["iconutil", "-c", "icns", ICONSET_DIR, "-o", ICNS_PATH],
                          capture_output=True, text=True)
    if result.returncode != 0:
        print(f"iconutil failed: {result.stderr}")
        return False

    print(f"Icon created: {ICNS_PATH}")
    return True

if __name__ == "__main__":
    try:
        generate_with_pillow()
    except ImportError:
        print("Pillow not available, using Swift/AppKit...")
        if not generate_with_swift():
            print("Failed to generate icon")
            sys.exit(1)
