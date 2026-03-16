# Inkstage Task Plan - v2.0 Modern Redesign

**Data:** 2026-03-12  
**Foco:** UI Moderna com toque Apple

---

## ✅ COMPLETED (Opus entregou)

### Bug Fixes
- [x] ESC handler global
- [x] Global shortcuts ⌘⇧A/C/S/Z/W
- [x] Toolbar interactivity (clicks funcionando)
- [x] Toolbar contrast (fundo escuro)
- [x] Auto-fade feature com botão na toolbar

---

## 🚧 IN PROGRESS - UI Redesign Moderno

### Phase 1: Toolbar Redesign (CRÍTICO)
**Estilo:** Frosted Glass Pill + SF Symbols

**Tarefas:**
- [x] Implementar NSVisualEffectView com .hudWindow
- [x] Adicionar drag handle (≡) com SF Symbol
- [x] Reorganizar layout: [handle] | [colors] | [separator] | [tools] | [separator] | [actions]
- [x] 5 cores favoritas (ciano, rose, lime, amarelo, violeta)
- [x] Ferramentas: Pen, Arrow, Rectangle, Circle, Text
- [x] Ações: Undo, Clear, Auto-fade, Close
- [x] Animações de hover (scale 1.1, opacity)
- [x] Animações de press (scale 0.92 bounce)
- [x] Cantos arredondados generosos (20px)
- [x] Sombra suave (blur 20, offset 0,8)
- [x] Magnetic snap para edges

**Arquivos:**
- `src/Inkstage/UI/Components/FloatingToolbar.swift`

---

### Phase 2: Shortcuts System (CRÍTICO)
**Base:** Presentify shortcuts

**Tarefas:**
- [x] Implementar ⌃A (Annotate Screen)
- [x] Implementar ⌃⌥A (Annotate No Controls)
- [x] Implementar ⌃S (Highlight Cursor)
- [x] Implementar ⌃L (Spotlight Cursor)
- [x] Implementar ⌃Z (Zoom Cursor)
- [x] Implementar / (Show Shortcuts Helper)
- [x] Implementar 1-5 (Color shortcuts)
- [x] Implementar F, A, R, C, T (Tool shortcuts)
- [x] Implementar W (Toggle Whiteboard)
- [x] Implementar ESC (Exit Mode)
- [x] Implementar Fn hold (Interactive Mode)
- [x] Criar Shortcut Helper Overlay (pressionar "/")
- [x] Persistir shortcuts customizados

**Arquivos:**
- `src/Inkstage/Core/GlobalShortcutManager.swift`
- Novo: `src/Inkstage/UI/Shortcuts/ShortcutOverlay.swift`

---

### Phase 3: Preferences Window (ALTA)
**Estilo:** macOS Settings App

**Tarefas:**
- [ ] Criar janela 700x500 com toolbarStyle .preference
- [ ] Tab: General (Start at login, About, Restore Defaults)
- [ ] Tab: Annotate (Colors, Line Weight, Whiteboard Color, Text settings, Auto-erase)
- [ ] Tab: Cursor (Highlight, Spotlight, Zoom settings)
- [ ] Tab: Shortcuts (Lista de shortcuts configuráveis)
- [ ] Tab: About (Logo, version, links)
- [ ] Conectar tudo com UserDefaults
- [ ] Adicionar preview ao vivo das configurações

**Arquivos:**
- `src/Inkstage/UI/Preferences/PreferencesWindow.swift`
- `src/Inkstage/UI/Preferences/GeneralTab.swift`
- `src/Inkstage/UI/Preferences/AnnotateTab.swift`
- `src/Inkstage/UI/Preferences/CursorTab.swift`
- `src/Inkstage/UI/Preferences/ShortcutsTab.swift`

---

### Phase 4: Animations & Polish (MÉDIA)

**Tarefas:**
- [ ] Toolbar entry animation (fade + slide up)
- [ ] Button press animations (scale bounce)
- [ ] Color selection glow effect
- [ ] Mode transition cross-fade
- [ ] Toast notifications estilizadas
- [ ] Loading states sutis

**Arquivos:**
- `src/Inkstage/Core/AnimationManager.swift` (novo)

---

### Phase 5: DMG Installer Moderno (BAIXA)

**Tarefas:**
- [ ] Criar background com gradiente escuro
- [ ] Ícone do app com sombra suave
- [ ] Seta animada entre app e Applications
- [ ] Texto "Drag to install"

**Arquivos:**
- `build/dmg-background.png`
- Atualizar `create_dmg.sh`

---

## 📋 Backlog - Features Futuras

### v2.1
- [ ] Screen Recording
- [ ] Export to GIF/MP4
- [ ] AI Shape Recognition
- [ ] iPad/Apple Pencil support (Sidecar)
- [ ] Stream Deck integration

### v2.2
- [ ] Multiple monitor support
- [ ] Cloud sync settings
- [ ] Team templates
- [ ] OBS plugin

### v2.3
- [ ] Collaboration/multi-cursor
- [ ] Voice control
- [ ] Eye tracking support

---

## 📁 Documentação Disponível

1. `docs/presentify-research.md` - Análise do concorrente
2. `docs/UI_SPECIFICATION.md` - Especificação baseada no Presentify
3. `docs/UI_REDESIGN_MODERN.md` - Especificação do redesign moderno Apple
4. `ISSUES.md` - Bugs reportados (resolvidos)
5. `BRIEF_OPUS.md` - Brief técnico original
6. `FIXES_SUMMARY.md` - Resumo das correções do Opus

---

## 🎯 Próximo Agente a Ativar

**Recomendação:** Ativar Opus novamente para implementar:
1. **Phase 1: Toolbar Redesign** (mais importante)
2. **Phase 2: Shortcuts System**

Ou posso implementar eu mesmo (Gemini Pro) se preferir mais velocidade/custo.

**O que você prefere?**
- A) Opus (melhor qualidade de código, mais caro)
- B) Eu mesmo (mais rápido, mais barato)
- C) Aguardar teste da DMG atual antes de prosseguir

---

*Atualizado: 2026-03-12*
