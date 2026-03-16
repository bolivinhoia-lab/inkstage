from PIL import Image, ImageDraw, ImageFont
import math

width, height = 600, 400
image = Image.new("RGBA", (width, height))
draw = ImageDraw.Draw(image)

# Gradient #1a1a1a to #2d2d2d
color1 = (26, 26, 26)
color2 = (45, 45, 45)

for y in range(height):
    r = int(color1[0] + (color2[0] - color1[0]) * y / height)
    g = int(color1[1] + (color2[1] - color1[1]) * y / height)
    b = int(color1[2] + (color2[2] - color1[2]) * y / height)
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Try to draw an arrow in the middle
cx, cy = width//2, height//2
draw.polygon([(cx - 20, cy - 10), (cx + 10, cy - 10), (cx + 10, cy - 20), (cx + 30, cy), (cx + 10, cy + 20), (cx + 10, cy + 10), (cx - 20, cy + 10)], fill=(200, 200, 200, 255))

# Draw text "Drag to install"
try:
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 16)
except:
    font = ImageFont.load_default()

text = "Drag to install"
text_w = draw.textlength(text, font=font)
draw.text(((width - text_w)/2, cy + 30), text, fill=(255, 255, 255, 200), font=font)

image.save("build/dmg-background.png")
print("Background generated at build/dmg-background.png")
