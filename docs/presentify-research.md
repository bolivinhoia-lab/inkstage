# Presentify Research

## Features Overview

### Core Features (from App Store & Website)

#### 1. Screen Annotation
- **Free Hand Drawing**: Draw freely with mouse/trackpad
- **Arrow Tool**: Create arrows to point at specific elements  
- **Rectangle**: Draw rectangles to highlight areas
- **Circle/Ellipse**: Draw circles or ellipses
- **Text**: Add text annotations anywhere on screen
- **Highlighter**: Highlight portions of text without obscuring it
- **Auto-erase**: Drawings fade after a set time automatically
- **Gradient Colors**: Draw with random gradient colors instead of plain colors
- **Works on any screen**: Images, videos, PDFs, code, presentations
- **Full-screen support**: Works even when other apps are in full-screen mode
- **Video call compatible**: Works with Zoom, Google Meet, Skype, Microsoft Teams, etc.
- **Presentation compatible**: Works with Keynote (even in Presentation mode), PowerPoint, OBS

#### 2. Whiteboard Mode
- Draw on a whiteboard instead of over other apps
- Customizable whiteboard color (whiteboard/greenboard/redboard)
- Toggle with **W** key while annotating

#### 3. Cursor Highlight
- **Shapes**: Circle, squircle (rounded square), or rhombus around cursor
- **Click animations**: Left/right click animations
- **Customizable**: Color, opacity, size, animation style
- **Highlight only when moving**: Option to highlight only during cursor movement
- **Global shortcut**: ⌃ + S to toggle

#### 4. Spotlight
- **Effect**: Dims everything except area around cursor
- **Shapes**: Circular or rectangular focus area
- **Customizable**: Size, shape, and opacity of dimmed area
- **Global shortcut**: ⌃ + L to toggle
- **Use cases**: Theatre spotlight effect, focus attention on specific UI elements

#### 5. Zoom
- **Effect**: Magnifies area where cursor is pointing
- **Customizable**: Zoom level, size, shape, border
- **Global shortcut**: ^ + Z to toggle
- **Note**: Only feature requiring Screen Recording permission

#### 6. Interactive Mode
- Presentify stays in background
- Activates only when holding Fn key
- Allows interaction with underlying apps without toggling
- Alternative: Hold Fn key temporarily to interact while annotating

### Unique Differentiators
1. **Lightweight**: Only 1MB download, ~25MB memory usage
2. **Native macOS app**: Built specifically for macOS with native performance
3. **Multi-screen support**: Can annotate on multiple screens
4. **iPad/Drawing Tablet support**: Works with Sidecar, Astropad, Duet, Wacom, XP-Pen
5. **Stream Deck integration**: All shortcuts can be mapped to Stream Deck
6. **Privacy-focused**: No data collection, works offline
7. **Zero crashes**: Rock-solid stability reputation

---

## Keyboard Shortcuts

### Global Shortcuts (System-wide)
| Shortcut | Action |
|----------|--------|
| ⌃ + A | Annotate Screen |
| ⌃ + ⌥ + A | Annotate Without Controls |
| ⌃ + S | Highlight Cursor |
| ⌃ + L | Spotlight Cursor |
| ^ + Z | Zoom Cursor |
| / | Show Annotate Key Shortcuts |

### Color Shortcuts (while annotating)
| Shortcut | Action |
|----------|--------|
| 1 | First Favorite Color |
| 2 | Second Favorite Color |
| 3 | Third Favorite Color |
| 4 | Fourth Favorite Color |
| 5 | Fifth Favorite Color |
| 6 | Random Colors |

### Drawing Tools (while annotating)
| Shortcut | Action |
|----------|--------|
| F | Free Hand |
| A | Arrow |
| R | Rectangle |
| C | Circle |
| T | Text |
| ⌫ (Delete) | Clear Annotations |

### Controls (while annotating)
| Shortcut | Action |
|----------|--------|
| H | Highlighter |
| [ | Decrease Line Weight |
| ] | Increase Line Weight |
| D | Draw with Touch |
| W | Whiteboard |
| ⌘ (hold) | Select Items (press and hold) |
| ⌘ + Z | Undo |
| ⇧ + ⌘ + Z | Redo |
| fn (hold) | Interact with underlying apps |

### Modifier Keys (while drawing)
| Modifier | Effect |
|----------|--------|
| ⇧ (Shift) | Draw straight line with Free Hand |
| ⌥ (Option) | Fill Rectangles/Circles with semi-transparent color |
| ⌃ (Control) | Toggle Auto-Erase behavior |
| ⌘ (Command) | Select and delete specific items |

### ESC Behavior
- Press ESC to exit annotation mode
- In Interactive Mode: Release Fn key to stop annotating

---

## UI/UX Analysis

### Menu Bar Architecture
- **Menu bar only**: No traditional app window
- **System tray icon**: Small icon in macOS menu bar
- **Click to activate**: Click icon for quick access to features
- **Ice app recommended**: For menu bar management when space is limited

### Toolbar Design
- **Position**: Bottom of screen when annotating
- **Draggable**: Can be moved anywhere
- **Hideable**: Can completely hide the control panel
- **Tool grouping**: Logical grouping of drawing tools

### Color System
- **5 favorite colors**: User-customizable palette
- **Random gradients**: Option for gradient effects
- **High contrast**: Emphasis on colors that stand out against content

### Design Philosophy
- **Minimal friction**: Quick activation/deactivation
- **Non-intrusive**: Toolbar doesn't block content
- **Contextual**: Tools appear only when needed
- **Consistent**: Same shortcuts work across all contexts

### Background Handling
- **Works over any content**: PDFs, videos, images, code
- **Full-screen compatible**: Works with apps in full-screen
- **Screen sharing aware**: Visible to viewers in video calls

---

## User Workflows

### Workflow 1: Live Presentation (Teaching/Tutorial)
1. Start annotation with ⌃ + A
2. Use Free Hand (F) to draw attention
3. Use Arrow (A) to point at specific elements
4. Use Text (T) for labels/annotations
5. Use Spotlight (⌃ + L) to focus on key areas
6. Use Zoom (^ + Z) for small details
7. Hold Fn to interact with slides underneath
8. Press ⌫ to clear when moving to next topic

### Workflow 2: Screen Sharing/Demo
1. Enable Cursor Highlight (⌃ + S) before sharing
2. Use Spotlight during demo to guide attention
3. Annotate directly on the app being demoed
4. Use Auto-erase for temporary emphasis
5. Use Whiteboard (W) for conceptual explanations

### Workflow 3: Content Creation (Video Tutorials)
1. Set up favorite colors matching brand
2. Customize cursor highlight style
3. Use modifier keys for precise drawing (Shift for straight lines)
4. Combine Spotlight + Cursor Highlight for clarity
5. Use KeyScreen companion app to show keystrokes

### Workflow 4: Remote Support/Troubleshooting
1. Ask user to enable annotation
2. Use Rectangle/Circle to highlight areas
3. Use Arrow to point at specific UI elements
4. Use Text to leave instructions
5. Clear and redraw as needed

### Workflow 5: Interactive Teaching
1. Enable Interactive Mode
2. Presentify stays hidden
3. Hold Fn only when need to annotate
4. Release Fn to interact with content
5. Seamless flow between annotation and interaction

### Common Patterns from Reviews
- **"Always on" cursor highlight**: Many users keep cursor highlight enabled during all screen shares
- **Quick annotations**: Users love the ⌃ + A instant access
- **iPad + Sidecar**: Popular among educators for drawing with Apple Pencil
- **Stream Deck power users**: Heavy shortcut customization for professional workflows

---

## Pricing/Model

### Purchase Options

#### 1. Mac App Store
- **Price**: $14.99 (one-time purchase)
- **License**: Tied to Apple ID, usable on multiple Macs with same Apple ID
- **Updates**: Through App Store
- **Trial**: No trial available

#### 2. Setapp
- **Model**: Subscription (7-day free trial available)
- **Access**: Full Presentify included in Setapp subscription
- **Benefit**: Can try Presentify for free during trial
- **Website**: setapp.com

#### 3. Direct Purchase (Polar.sh)
- **Price**: One-time purchase
- **License**: Per-device (can deactivate and move to another device)
- **Format**: .dmg installer + license key
- **For users**: Who prefer not to use App Store or Setapp

### Business/Education Discounts
- **50% discount** for purchases of 20+ copies
- **Channels**: Apple Business Manager, Apple School Manager

### Version Info
- **Current Version**: 7.2.1 (as of research date)
- **macOS Support**: macOS 10.13+ (Ventura and above)
- **App Size**: 2.8 MB (App Store), ~1MB download
- **Memory Usage**: ~25MB average

---

## Competitive Insights

### What to Copy/Iterate

#### Strong Points to Emulate:
1. **Lightweight & Fast**: 1MB download is impressive - prioritize performance
2. **Keyboard-First**: Extensive shortcut system is power-user friendly
3. **Native Feel**: macOS menu bar integration feels native
4. **No Permissions Needed**: Only Zoom needs Screen Recording - reduces friction
5. **Interactive Mode**: Fn key temporary interaction is elegant
6. **Whiteboard Toggle**: Quick switch (W key) between screen annotation and whiteboard
7. **Modifier Keys**: Shift/Option/Control modifiers add power without clutter
8. **Auto-Erase**: Self-clearing annotations reduce manual cleanup

#### Areas for Improvement/Differentiation:
1. **Trial Model**: Presentify has no direct trial - could be a differentiator
2. **iPad Dependency**: Requires Sidecar/Astropad - native iPad support could win
3. **Menu Bar Only**: Some users prefer dock apps - offer both options
4. **Recording Feature**: Presentify doesn't record - built-in recording could differentiate
5. **Collaboration**: No multi-user annotation - real-time collaboration feature
6. **Templates**: No pre-made annotation templates - could add value

#### UX Patterns to Adopt:
- **Bottom toolbar**: Non-intrusive, draggable
- **Color favorites**: Quick access to commonly used colors
- **Temporary interaction**: Fn key hold to interact underneath
- **Gradient colors**: Modern aesthetic option
- **Stream Deck integration**: Professional workflow support

#### Positioning Insights:
- Target: Teachers, content creators, remote workers, presenters
- Key value props: "Annotate anything", "Presentation skills", "Lightweight"
- Social proof: Harvard/MIT professors, 300+ App Store reviews, 4.6★
- Community: Active on Reddit, Hacker News, Product Hunt

---

## Raw Notes

### Technical Details
- Built by Softal.io (Ram Patra)
- Featured by Apple multiple times
- 230+ upvotes on Hacker News
- 210+ upvotes on Product Hunt
- 300+ upvotes on Reddit
- Companion app: FaceScreen (show face during calls)
- Related app: KeyScreen (display keystrokes on screen)

### User Testimonials Themes
- "Perfect for Discord screen sharing"
- "Great for online D&D games"
- "Colleagues always ask what app I'm using"
- "Essential for tutoring students"
- "Works great with Wacom tablet"
- "Keyboard shortcuts are a game changer"

### FAQ Common Questions
- iPad support: Yes via Sidecar/Astropad/Duet
- macOS version: 10.13+ (Ventura+)
- Trial: Only via Setapp
- Business discounts: 50% off 20+ licenses
- Works with: Zoom, Meet, Teams, OBS, Keynote, PowerPoint

### Missing Features (User Requests from Reviews)
- Direct trial version
- Built-in screen recording
- Cloud sync of settings
- More shape options
- Text formatting options
- Collaboration/multi-user
- Pre-made templates

### Development Philosophy
- Privacy-first (no data collection)
- Stability over features (zero crashes)
- Native performance
- Keyboard-centric
- Menu bar utility model
