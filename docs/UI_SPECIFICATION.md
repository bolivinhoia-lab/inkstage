# Inkstage UI/UX Specification

**Baseado em:** Presentify (https://presentifyapp.com/)  
**Data:** 2026-03-12  
**Objetivo:** Replicar features + adicionar melhorias

---

## 🎨 Análise do UI do Presentify

### 1. Floating Toolbar

#### Layout (da esquerda para direita):
```
[≡] | [cyan] [red] [green] [yellow] [purple] | [|] [spline] [arrow] [rect] [circle] [text] [|] [eraser] [X]
```

**Características:**
- Fundo: Preto sólido ou escuro (#1a1a1a aprox.)
- Altura: ~50-60px
- Borda arredondada: ~8-12px radius
- Sombra suave abaixo
- Separadores verticais finos entre grupos

**Grupos:**
1. **Drag Handle** (≡) - Para mover a toolbar
2. **Colors** - 5 cores favoritas (círculos coloridos)
3. **Separator** (|)
4. **Tools** - Freehand, Arrow, Rectangle, Circle, Text
5. **Separator** (|)
6. **Actions** - Eraser, Close (X)

**Cores Default:**
- Cyan (#00BCD4 ou similar)
- Red (#F44336)
- Green (#4CAF50)
- Yellow (#FFEB3B)
- Purple (#9C27B0)

**Ícones (SF Symbols):**
- Drag: `line.3.horizontal` ou texto "≡"
- Colors: Círculos coloridos (sem ícone SF)
- Freehand: `pencil` ou ícone de spline curva
- Arrow: `arrow.up.right`
- Rectangle: `rectangle`
- Circle: `circle`
- Text: `textformat`
- Eraser: `eraser`
- Close: `xmark`

---

### 2. Preferences Window

#### Estrutura de Tabs (toolbar segmentado no topo):
```
[⚙️ General] [✏️ Annotate] [👆 Cursor] [⌨️ Shortcuts] [ℹ️ About]
```

#### Tab: General
- **Start at login** - Toggle
- **Highlight Cursor at login** - Toggle
- **App Version** - Label (Version X.X.X (Build XX))
- **Restore Defaults** - Button

#### Tab: Annotate
- **Favorite Colors** - Grid de 5 círculos coloridos clicáveis
- **Line Weight** - Dropdown (Light, Medium, Heavy)
- **Whiteboard Color** - Color picker
- **Annotation Tool Indicator** - Toggle
- **Text Font** - Dropdown
- **Text Size** - Dropdown/Number
- **Text Placeholder** - Toggle
- **Interactive Mode Key** - Dropdown (Function, Control, Option, Command)
- **Auto Erase** - Toggle + descrição
- **Save Session** - Toggle

#### Tab: Cursor
Seções com headers:

**Highlight:**
- Opacity - Slider (0% - 100%)
- Color - Color picker
- Size - Slider (Min - Max)
- Border Style - Dropdown (Solid, Dashed, etc)
- Shape - Dropdown (Circle, Squircle, Square)
- Click Animation - Dropdown (Scale, Ripple, etc)
- Glow Effect - Toggle
- Turn Off When Inactive - Toggle

**Spotlight:**
- Size - Slider
- Opacity - Slider (20% - 90%)

**Zoom:**
- Zoom Level - Slider (1.5x - 5x)
- Size - Slider
- Shape - Dropdown
- Border Color - Color picker

#### Tab: Shortcuts
Lista vertical de shortcuts configuráveis:
```
[Label]                    [Descrição]                    [Shortcut] [X]
────────────────────────────────────────────────────────────────────
Annotate Screen            Global shortcut to...          [⌃A]      [×]
Annotate Without Controls  Global shortcut to...          [⌃⌥A]     [×]
Highlight Cursor           Global shortcut to...          [⌃S]      [×]
Spotlight Cursor           Global shortcut to...          [⌃L]      [×]
Zoom Cursor                Global shortcut to...          [⌃Z]      [×]
Show Annotate Key Shortcuts Display all...                 [/]       [×]
```

**Características:**
- Cada item: Label bold, descrição cinza abaixo
- Campo de shortcut: Botão estilizado mostrando o atalho
- Botão X: Para limpar o shortcut
- Foco em acessibilidade e clareza

#### Tab: About
- Logo do app
- Nome do app
- Versão
- Copyright
- Links (Website, Support, Privacy Policy)

---

### 3. DMG Installer

**Layout:**
- Fundo branco/claro
- Ícone do app à esquerda (grande ~128px)
- Seta/arrow apontando para direita
- Ícone da pasta Applications à direita
- Texto simples abaixo de cada ícone

**Estética:**
- Minimalista
- Ícone do app em destaque
- Instrução implícita: "Arraste para Applications"

---

## 🔧 Features do Presentify para Replicar

### Core Features
1. ✅ Screen Annotation (já temos)
2. ✅ Cursor Highlight (já temos)
3. ✅ Spotlight (já temos)
4. ✅ Zoom (já temos)
5. ✅ Whiteboard (já temos)
6. ✅ Auto-fade/Erase (Opus acabou de implementar)

### UI Features
1. **Toolbar minimalista** - Fundo escuro, ícones claros
2. **Drag handle** - Mover toolbar facilmente
3. **Separadores visuais** - Entre grupos de ferramentas
4. **Cores favoritas** - Quick access (1-5 keys)
5. **Preferences completa** - Tabs organizadas
6. **Customizable shortcuts** - Cada ação pode ter shortcut
7. **Visual polish** - Sombras, cantos arredondados, espaçamento

### Settings/Configurações
1. **Start at login** - Launch agent
2. **Restore defaults** - Reset all settings
3. **Line weight** - Stroke thickness
4. **Whiteboard color** - Background color picker
5. **Interactive mode key** - Fn/Control/Option/Cmd
6. **Save session** - Persist annotations
7. **Cursor settings** - Opacity, size, shape, border, glow
8. **Spotlight settings** - Size, opacity
9. **Zoom settings** - Level, size, shape, border color

---

## 🚀 Melhorias para o Inkstage (Além do Presentify)

### 1. Toolbar Aprimorada
- **Auto-hide toolbar** - Esconder após X segundos de inatividade
- **Minimize to pill** - Botão para colapsar em pílula pequena
- **Recent colors** - Mostrar últimas cores usadas além das favoritas
- **Tool grouping** - Agrupar ferramentas relacionadas
- **Quick actions** - Undo/Redo direto na toolbar

### 2. Anotações Avançadas
- **AI Shape Recognition** - Converter rabiscos em formas perfeitas
- **Smart Arrows** - Auto-alinhar a elementos na tela
- **Text Styling** - Bold, italic, font size na toolbar
- **Emoji Support** - Adicionar emojis como anotações
- **Arrow Styles** - Diferentes pontas de seta

### 3. Gravação & Export
- **Screen Recording** - Gravar com anotações
- **Export to GIF/MP4** - Compartilhar anotações animadas
- **Export to PDF** - Salvar como documento
- **Session Save** - Salvar estado completo para continuar depois

### 4. Colaboração
- **Multi-cursor** - Suporte a múltiplos apresentadores
- **Cloud Sync** - Sincronizar settings entre devices
- **Team Templates** - Templates compartilhados

### 5. Integrações
- **Stream Deck** - Plugin nativo
- **OBS Plugin** - Source para OBS Studio
- **Zoom SDK** - Integração nativa com Zoom
- **Shortcuts.app** - Actions para Shortcuts do macOS

### 6. Acessibilidade
- **Voice Control** - Controlar por voz
- **Eye Tracking** - Suporte a eye trackers
- **High Contrast Mode** - Para visibilidade reduzida

---

## 📝 Especificação Técnica de UI

### Cores

**Toolbar:**
- Background: `NSColor.black.withAlphaComponent(0.85)` ou `#1a1a1a`
- Icons: `.white`
- Selected tool: `NSColor.white.withAlphaComponent(0.3)`
- Separators: `NSColor.white.withAlphaComponent(0.2)`

**Preferences:**
- Background: `.windowBackgroundColor` (padrão macOS)
- Section headers: `.labelColor` bold
- Descriptions: `.secondaryLabelColor`
- Dividers: `.separatorColor`

**Accent Colors (Favorite Colors):**
```swift
let favoriteColors = [
    NSColor(red: 0.0, green: 0.74, blue: 0.83, alpha: 1.0),   // Cyan
    NSColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0),   // Red
    NSColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0),   // Green
    NSColor(red: 1.0, green: 0.92, blue: 0.23, alpha: 1.0),    // Yellow
    NSColor(red: 0.61, green: 0.15, blue: 0.69, alpha: 1.0),   // Purple
]
```

### Dimensões

**Toolbar:**
- Height: 50-60px
- Padding: 12-16px horizontal
- Button size: 32-40px
- Corner radius: 8-12px
- Shadow: radius 10, offset (0, 4), opacity 0.4

**Preferences Window:**
- Size: ~600x500px (padrão macOS prefs)
- Toolbar style: .preferenceStyle
- Tab icons: 20x20pt

### Tipografia

**Toolbar:**
- Icons: SF Symbols, scale .large
- No text labels (icon-only)

**Preferences:**
- Headers: `.headline` ou `.body` bold
- Descriptions: `.caption` ou `.footnote`
- Labels: `.body`

---

## 🎯 Próximos Passos de Implementação

### Phase 1: Toolbar Redesign (PRIORITÁRIO)
1. Redesenhar FloatingToolbar para parecer com Presentify
2. Implementar drag handle
3. Reorganizar layout (colors → separator → tools → separator → actions)
4. Ajustar cores do tema escuro
5. Adicionar sombra e bordas arredondadas

### Phase 2: Preferences Window
1. Criar PreferencesView com tabs (General, Annotate, Cursor, Shortcuts, About)
2. Implementar cada tab com seus controles
3. Persistir settings usando UserDefaults
4. Adicionar "Restore Defaults"

### Phase 3: Settings Avançados
1. Implementar todas as configurações de cursor (opacity, size, shape, etc)
2. Implementar configurações de spotlight
3. Implementar configurações de zoom
4. Implementar customização de shortcuts

### Phase 4: Polish & Extras
1. Animações suaves
2. Tooltips informativos
3. DMG installer melhorado
4. Ícone do app refinado

---

## 📚 Referências Visuais

**Screenshots anexos:**
1. `toolbar.jpg` - Toolbar flutuante com cores e ferramentas
2. `shortcuts.jpg` - Tab de atalhos configuráveis
3. `cursor.jpg` - Configurações de cursor (parte 1)
4. `cursor2.jpg` - Configurações de cursor (parte 2)
5. `annotate.jpg` - Configurações de anotação
6. `general.jpg` - Configurações gerais
7. `dmg.jpg` - Instalador DMG

---

*Documento criado para guiar o redesign do Inkstage baseado no Presentify*
