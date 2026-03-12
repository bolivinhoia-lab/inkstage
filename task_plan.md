# Inkstage Task Plan

## 🚨 Bugs Críticos (Para Opus Resolver)

### Issue #1: ESC não fecha modos
**Status:** Aguardando Coder (Opus)  
**Branch:** `fix/esc-global-handler`
**Arquivos:** `GlobalShortcutManager.swift`, `AppStateManager.swift`
**Descrição:** ESC não sai dos modos ativos (drawing, whiteboard, etc.)

### Issue #2: Shortcuts globais não funcionam
**Status:** Aguardando Coder (Opus)
**Branch:** `fix/global-shortcuts`
**Arquivos:** `GlobalShortcutManager.swift`
**Descrição:** ⌘⇧A, ⌘⇧C, etc só funcionam após abrir Preferences

### Issue #3: Toolbar não responde a cliques  
**Status:** Aguardando Coder (Opus)
**Branch:** `fix/toolbar-interactivity`
**Arquivos:** `FloatingToolbar.swift`
**Descrição:** Toolbar aparece mas não expande/seleciona ferramentas

### Issue #4: Ferramentas invisíveis no whiteboard
**Status:** Aguardando Coder (Opus)
**Branch:** `fix/toolbar-contrast`
**Arquivos:** `FloatingToolbar.swift`
**Descrição:** Fundo branco + ícones brancos = invisível

### Issue #5: Auto-fade de desenhos (Feature)
**Status:** Aguardando Coder (Opus)
**Branch:** `feat/auto-fade-annotations`
**Arquivos:** `AnnotationCanvas.swift`
**Descrição:** Desenhos devem sumir automaticamente após X segundos

---

## 📋 Backlog - MVP v1.0

### Core Features (Já Implementadas)
- [x] Screen Annotation - Drawing tools
- [x] Cursor Highlight - Halo ao redor do mouse
- [x] Spotlight - Foco em área
- [x] Whiteboard - Modo tela cheia
- [x] Zoom - Ampliação de área
- [x] Floating Toolbar - Frosted glass, SF Symbols

### Em Correção (Bugs)
- [ ] ESC handler global
- [ ] Global shortcuts funcionando
- [ ] Toolbar interativa
- [ ] Toolbar visível em todos os fundos
- [ ] Auto-fade toggle

### Future Features
- [ ] Screen recording
- [ ] AI shape recognition
- [ ] Custom shortcuts
- [ ] Multiple monitors support
- [ ] Export to PDF

---

## 🏭 Fábrica Status

**Agente Atual:** Aguardando Opus  
**Tarefa:** Resolver bugs críticos (Issues #1-5)  
**Documentação:**
- `ISSUES.md` - Detalhes dos bugs reportados
- `BRIEF_OPUS.md` - Brief técnico completo

---

## 📝 Referências

**Benchmark:** Presentify (https://presentifyapp.com/)

**Features do Presentify para estudar:**
- ESC behavior (como fecha anotações)
- Global shortcut implementation
- Toolbar design e interatividade
- Auto-fade de desenhos

---

*Last updated: 2026-03-12*
