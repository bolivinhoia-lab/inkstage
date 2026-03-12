# Inkstage UI Redesign - Modern Apple Style

**Versão:** 2.0  
**Estilo:** Modern macOS (Sonoma/Sequoia)  
**Data:** 2026-03-12

---

## 🎨 Design Philosophy

### Apple Modern Principles
1. **Frosted Glass (Vibrancy)** - NSVisualEffectView com material .hudWindow
2. **SF Symbols** - Ícones consistentes com o sistema
3. **Smooth Animations** - 0.2s-0.3s com ease-in-out
4. **Generous Corner Radius** - 12-16px para botões, 20px+ para painéis
5. **Subtle Shadows** - Soft, difusa, elevation-based
6. **Accent Colors** - System accent color awareness
7. **Minimal Chrome** - Remove bordas desnecessárias

---

## 🎯 Toolbar Redesign

### Conceito: "Floating Glass Pill"

```
Layout:
[≡] │ [○○○○○] │ [✏️→ ▭ ○ T] │ [⌫ ✕]
```

#### Visual Design

**Container:**
```swift
// Frosted Glass Background
let visualEffectView = NSVisualEffectView()
visualEffectView.material = .hudWindow  // Frosted glass dark
visualEffectView.state = .active
visualEffectView.blendingMode = .behindWindow

// Container styling
layer?.cornerRadius = 20  // Generoso, pill-like
layer?.shadowColor = NSColor.black.cgColor
layer?.shadowOpacity = 0.25
layer?.shadowRadius = 20
layer?.shadowOffset = CGSize(width: 0, height: 8)

// Border sutil
layer?.borderWidth = 0.5
layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
```

**Dimensões:**
- Height: 56px (modern, compacto)
- Padding: 16px horizontal, 12px vertical
- Corner radius: 20px

#### Seções

**1. Drag Handle (Left)**
```
Icon: SF Symbol "line.3.horizontal"
Size: 20x20pt
Color: .secondaryLabelColor (cinza suave)
Hover: .labelColor
```

**2. Colors (Center-Left)**
```
5 círculos coloridos:
- Cyan: #00D9FF (systemCyan)
- Rose: #FF375F (systemPink)  
- Lime: #30D158 (systemGreen)
- Yellow: #FFD60A (systemYellow)
- Violet: #BF5AF2 (systemPurple)

Tamanho: 28x28pt
Corner radius: 14pt (círculo perfeito)
Border: 2pt white quando selecionado
Shadow: pequena sombra colorida quando selecionado
```

**3. Separator**
```
SF Symbol: "line.vertical"
Color: .separatorColor
Opacity: 0.3
```

**4. Tools (Center)**
```
Ícones SF Symbols:
- Pen: "pencil.line"
- Arrow: "arrow.up.right"
- Rectangle: "rectangle"
- Circle: "circle"
- Text: "textformat"

Tamanho: 24x24pt
Color default: .secondaryLabelColor
Color selected: .white + background .white.withAlpha(0.2)
Corner radius: 8pt
```

**5. Actions (Right)**
```
- Undo: "arrow.uturn.backward"
- Clear: "trash"
- Auto-fade: "timer" / "timer.slash"
- Close: "xmark"

Tamanho: 22x22pt
Spacing: 12px
```

#### Interactions

**Hover States:**
```swift
// Todos os botões
button.alpha = 1.0  // Normal
button.alpha = 0.7  // Hover (quick fade)

// Scale animation on hover
NSAnimationContext.runAnimationGroup { context in
    context.duration = 0.15
    button.animator().scale = 1.1
}
```

**Selection:**
```swift
// Background highlight
button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
button.layer?.cornerRadius = 10

// Scale bounce
let animation = CASpringAnimation(keyPath: "transform.scale")
animation.fromValue = 0.9
animation.toValue = 1.0
animation.damping = 10
animation.duration = 0.3
button.layer?.add(animation, forKey: "bounce")
```

**Drag Behavior:**
- Handle (≡) responde a drag para mover toolbar
- Animação suave de follow no cursor
- Magnetic snap para edges da tela

---

## ⚡ Shortcuts System

### Global Shortcuts (⌃ based - igual Presentify)

```swift
enum InkstageShortcut {
    case annotateScreen          // ⌃A (Control+A)
    case annotateNoControls      // ⌃⌥A (Control+Option+A)
    case highlightCursor         // ⌃S (Control+S)
    case spotlightCursor         // ⌃L (Control+L)
    case zoomCursor             // ⌃Z (Control+Z)
    case showShortcuts          // / (slash)
    
    var keyCombo: String {
        switch self {
        case .annotateScreen: return "⌃A"
        case .annotateNoControls: return "⌃⌥A"
        case .highlightCursor: return "⌃S"
        case .spotlightCursor: return "⌃L"
        case .zoomCursor: return "⌃Z"
        case .showShortcuts: return "/"
        }
    }
}
```

### Annotation Mode Shortcuts

```swift
// Colors (1-5)
"1" = Color 1 (Cyan)
"2" = Color 2 (Rose)
"3" = Color 3 (Lime)
"4" = Color 4 (Yellow)
"5" = Color 5 (Violet)
"6" = Random Gradient

// Tools
"F" = Free Hand
"A" = Arrow
"R" = Rectangle
"C" = Circle
"T" = Text
"H" = Highlighter

// Modifiers
"⌫" = Clear All
"⌘Z" = Undo
"⇧⌘Z" = Redo

// Special
"W" = Toggle Whiteboard
"ESC" = Exit Mode
"Fn" (hold) = Interactive Mode
```

### Shortcut Helper Overlay

Quando pressionar "/", mostrar overlay semitransparente:

```
┌─────────────────────────────────┐
│     Keyboard Shortcuts          │
├─────────────────────────────────┤
│  Annotate Screen        ⌃A      │
│  Highlight Cursor       ⌃S      │
│  Spotlight              ⌃L      │
│  Zoom                   ⌃Z      │
│  ─────────────────────────────  │
│  Pen                    F       │
│  Arrow                  A       │
│  Rectangle              R       │
│  Circle                 C       │
│  Text                   T       │
│  ─────────────────────────────  │
│  Clear All              ⌫       │
│  Exit Mode              ESC     │
└─────────────────────────────────┘
```

---

## 🪟 Preferences Window Redesign

### Style: macOS Settings App

```swift
// Window style
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
    styleMask: [.titled, .closable, .miniaturizable],
    backing: .buffered,
    defer: false
)
window.title = "Inkstage Settings"
window.toolbarStyle = .preference  // Estilo moderno de preferências
```

### Toolbar Tabs (Icon + Label)

```
[⚙️ General] [✏️ Annotate] [👆 Cursor] [🔦 Spotlight] [⌨️ Shortcuts] [ℹ️ About]
```

**SF Symbols por tab:**
- General: "gear"
- Annotate: "pencil.line"
- Cursor: "cursorarrow.click"
- Spotlight: "flashlight.on.fill"
- Shortcuts: "keyboard"
- About: "info.circle"

### Tab: General

```swift
// Seção: Startup
GroupBox("Startup") {
    Toggle("Start at login", isOn: $startAtLogin)
    Toggle("Highlight cursor at login", isOn: $cursorAtLogin)
}

// Seção: About
GroupBox("About Inkstage") {
    HStack {
        Image(appIcon)
        VStack(alignment: .leading) {
            Text("Inkstage")
                .font(.headline)
            Text("Version \(version) (Build \(build))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    Button("Restore Defaults") {
        // Reset all settings
    }
    .buttonStyle(.bordered)
}
```

### Tab: Annotate

```swift
GroupBox("Favorite Colors") {
    LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
        ForEach(0..<5) { index in
            ColorCircle(
                color: favoriteColors[index],
                isSelected: selectedColor == index
            )
            .onTapGesture {
                selectedColor = index
            }
        }
    }
}

GroupBox("Drawing") {
    Picker("Line Weight", selection: $lineWeight) {
        Text("Light").tag(LineWeight.light)
        Text("Medium").tag(LineWeight.medium)
        Text("Heavy").tag(LineWeight.heavy)
    }
    .pickerStyle(.segmented)
    
    ColorPicker("Whiteboard Color", selection: $whiteboardColor)
}

GroupBox("Text") {
    Picker("Font", selection: $textFont) {
        Text("System Default").tag(Font.system)
        Text("Monospaced").tag(Font.monospaced)
    }
    
    Stepper("Size: \(textSize)", value: $textSize, in: 12...72)
}

GroupBox("Behavior") {
    Toggle("Auto-erase annotations", isOn: $autoErase)
        .help("Automatically fade annotations after 3 seconds")
    
    Toggle("Save session on exit", isOn: $saveSession)
}
```

### Tab: Cursor

```swift
GroupBox("Highlight") {
    Slider("Opacity", value: $cursorOpacity, in: 0...1)
    
    ColorPicker("Color", selection: $cursorColor)
    
    Slider("Size", value: $cursorSize, in: 20...100)
    
    Picker("Shape", selection: $cursorShape) {
        Image(systemName: "circle").tag(Shape.circle)
        Image(systemName: "square.fill").tag(Shape.squircle)
        Image(systemName: "square").tag(Shape.square)
    }
    .pickerStyle(.segmented)
    
    Picker("Click Animation", selection: $clickAnimation) {
        Text("Scale").tag(Animation.scale)
        Text("Ripple").tag(Animation.ripple)
        Text("Pulse").tag(Animation.pulse)
    }
    
    Toggle("Glow effect", isOn: $glowEffect)
    Toggle("Turn off when inactive", isOn: $inactiveHide)
}

GroupBox("Spotlight") {
    Slider("Size", value: $spotlightSize, in: 50...300)
    Slider("Opacity", value: $spotlightOpacity, in: 0.2...0.9)
}

GroupBox("Zoom") {
    Slider("Zoom Level", value: $zoomLevel, in: 1.5...5, step: 0.5)
    Slider("Size", value: $zoomSize, in: 100...400)
    Picker("Shape", selection: $zoomShape) {
        Text("Circle").tag(Shape.circle)
        Text("Rectangle").tag(Shape.rectangle)
    }
    ColorPicker("Border Color", selection: $zoomBorderColor)
}
```

### Tab: Shortcuts

```swift
List(shortcuts) { shortcut in
    HStack {
        VStack(alignment: .leading) {
            Text(shortcut.name)
                .font(.body)
            Text(shortcut.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        Spacer()
        
        KeyboardShortcutView(shortcut: shortcut.keyCombo)
            .onTapGesture {
                // Record new shortcut
            }
        
        Button(action: { shortcut.clear() }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
    .padding(.vertical, 4)
}
```

**KeyboardShortcutView:**
- Estilo: Caixa cinza arredondada
- Font: Monospaced para atalhos
- Ícone de tecla: visual typewriter

---

## 🎬 Animations & Micro-interactions

### Toolbar Entry
```swift
// Fade in + slide up
panel.alphaValue = 0
panel.setFrameOrigin(NSPoint(x: x, y: y - 20))

NSAnimationContext.runAnimationGroup { context in
    context.duration = 0.3
    context.timingFunction = CAMediaTimingFunction(name: .easeOut)
    panel.animator().alphaValue = 1
    panel.animator().setFrameOrigin(NSPoint(x: x, y: y))
}
```

### Button Press
```swift
let pressAnimation = CABasicAnimation(keyPath: "transform.scale")
pressAnimation.fromValue = 1.0
pressAnimation.toValue = 0.92
pressAnimation.duration = 0.1
pressAnimation.autoreverses = true
button.layer?.add(pressAnimation, forKey: "press")
```

### Color Selection
```swift
// Glow effect + scale
let glow = NSShadow()
glow.shadowColor = selectedColor.withAlphaComponent(0.6)
glow.shadowBlurRadius = 15
glow.shadowOffset = .zero
button.shadow = glow

// Scale up slightly
button.layer?.transform = CATransform3DMakeScale(1.15, 1.15, 1)
```

### Mode Transitions
```swift
// Cross-fade entre modos
NSAnimationContext.runAnimationGroup { context in
    context.duration = 0.25
    oldModeOverlay.animator().alphaValue = 0
    newModeOverlay.animator().alphaValue = 1
}
```

---

## 📱 DMG Installer Design

### Layout Moderno

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│      [Inkstage Icon]     ➜     [Apps]  │
│           (128pt)              (128pt)  │
│                                         │
│      Inkstage.app            Applications│
│                                         │
│                                         │
│    "Drag to install"                    │
│                                         │
└─────────────────────────────────────────┘
```

**Background:**
- Gradiente suave: #1a1a1a → #2d2d2d
- Ou wallpaper abstrato sutil
- Ícone do app com sombra suave
- Seta animada (bounce sutil)

---

## 🎯 Implementation Priority

### Phase 1: Toolbar (CRITICAL)
- [ ] Redesenhar com Frosted Glass
- [ ] Implementar drag handle
- [ ] Reorganizar layout (colors/tools/actions)
- [ ] Animações de hover/press
- [ ] Testar interatividade

### Phase 2: Shortcuts (CRITICAL)
- [ ] Implementar todos os shortcuts do Presentify
- [ ] Criar helper overlay (pressionar "/")
- [ ] Persistir shortcuts customizados

### Phase 3: Preferences Window (HIGH)
- [ ] Criar janela com toolbar estilo Settings
- [ ] Implementar todas as tabs
- [ ] Conectar com UserDefaults
- [ ] Adicionar preview ao vivo

### Phase 4: Animations (MEDIUM)
- [ ] Animações de entrada/saída
- [ ] Micro-interactions nos botões
- [ ] Transições suaves entre modos

### Phase 5: DMG (LOW)
- [ ] Criar layout moderno
- [ ] Background customizado
- [ ] Ícone com sombra

---

## 📐 Asset Specifications

### Icons (SF Symbols)
- Weight: .medium ou .semibold
- Scale: .large
- Rendering: .hierarchical ou .multicolor

### Colors
```swift
// Toolbar
let toolbarBackground = NSColor.black.withAlphaComponent(0.75)
let toolbarBorder = NSColor.white.withAlphaComponent(0.08)

// Buttons
let buttonNormal = NSColor.clear
let buttonHover = NSColor.white.withAlphaComponent(0.1)
let buttonSelected = NSColor.white.withAlphaComponent(0.2)

// Accents
let accentCyan = NSColor.systemCyan
let accentRose = NSColor.systemPink
let accentLime = NSColor.systemGreen
let accentYellow = NSColor.systemYellow
let accentViolet = NSColor.systemPurple
```

### Typography
```swift
// Toolbar
.toolbarIcon: Font.system(size: 22, weight: .medium)

// Preferences
.sectionHeader: Font.headline
.bodyText: Font.body
.captionText: Font.caption
```

---

*Especificação completa para o redesign moderno do Inkstage*
