# Brief Técnico para Opus - Inkstage Fixes

## 🎯 Objetivo
Corrigir bugs críticos no Inkstage que impedem uso básico do app.

---

## 🐛 Bugs para Corrigir (Prioridade)

### 1. ESC não fecha modos (CRÍTICO)
**Arquivos:** `GlobalShortcutManager.swift`, `AppStateManager.swift`

**Problema:** ESC não sai dos modos (drawing, whiteboard, spotlight, zoom).

**Investigar:**
```swift
// GlobalShortcutManager.swift
private func handleEvent(_ event: NSEvent) {
    if event.keyCode == 53 {  // ESC
        // Verificar se este código está sendo executado
        // Possível problema: evento não chega aqui
    }
}
```

**Possíveis causas:**
- NSEvent monitor não registrado corretamente
- Evento sendo consumido por outra view antes de chegar no manager
- OverlayWindow interceptando eventos

**Solução esperada:**
- ESC deve funcionar globalmente em qualquer modo
- Deve chamar `AppStateManager.shared.handleEscape()`
- Deve desativar o modo atual e esconder overlays

---

### 2. Shortcuts globais não funcionam (CRÍTICO)
**Arquivos:** `GlobalShortcutManager.swift`, `MenuBarController.swift`

**Problema:** ⌘⇧A, ⌘⇧C, ⌘⇧S, ⌘⇧Z, ⌘⇧W só funcionam depois de abrir Preferences.

**Investigar:**
```swift
// GlobalShortcutManager.setup()
NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged])
```

**Possíveis causas:**
- App não tem permissão de Acessibilidade (Accessibility API)
- Global monitor não registrado na inicialização
- Eventos sendo tratados apenas localmente

**Solução esperada:**
- Shortcuts devem funcionar imediatamente após abrir o app
- Verificar/requester permissão de Acessibilidade no primeiro launch
- Ou usar `CGEvent.tapCreate` para monitoramento de baixo nível

---

### 3. Toolbar não responde a cliques (CRÍTICO)
**Arquivos:** `FloatingToolbar.swift`, `PillToolbarView`

**Problema:** Toolbar aparece mas é "inerte" - não expande, não seleciona ferramentas.

**Investigar:**
```swift
// PillToolbarView.hitTest()
override func hitTest(_ point: NSPoint) -> NSView? {
    // Este método pode estar retornando nil incorretamente
}
```

**Possíveis causas:**
- `hitTest()` retornando `nil` ou `self` em vez do botão correto
- `panel.level` muito alto ou muito baixo
- `ignoresMouseEvents = true` em alguma view pai
- Toolbar em outra janela (NSPanel) com eventos não propagando

**Solução esperada:**
- Clicar na toolbar deve expandir/retrair
- Botões de ferramenta devem ser clicáveis
- Seleção de cores deve funcionar

---

### 4. Ferramentas invisíveis no Whiteboard (ALTA)
**Arquivos:** `FloatingToolbar.swift`

**Problema:** Fundo branco do whiteboard + ícones brancos = invisível.

**Investigar:**
```swift
// PillToolbarView.setupUI()
effectView.material = .hudWindow  // Pode não ter contraste suficiente
button.contentTintColor = .white   // Sempre branco
```

**Solução esperada:**
- Garantir que toolbar tenha fundo escuro suficiente (usar `.sidebar` ou `.headerView`)
- Ou adicionar sombra nos ícones
- Ou detectar fundo e inverter cores automaticamente

---

### 5. Auto-fade de desenhos (FEATURE)
**Arquivos:** `AnnotationCanvas.swift`, `DrawingTools.swift`

**Problema:** Desenhos são permanentes. Não há opção de sumirem automaticamente.

**Implementação:**
- Adicionar `Timer` em cada stroke/path
- Após X segundos, iniciar fade-out com `NSAnimationContext`
- Toggle na toolbar (ícone de ampulheta)
- Não deve ser escondido em Preferences - deve ser acessível rápido

---

## 📋 Checklist de Implementação

### Phase 1: Critical Fixes
- [ ] Fix ESC handler - garantir que funciona globalmente
- [ ] Fix shortcuts - verificar permissões e registro de monitors
- [ ] Fix toolbar interactivity - debug hitTest() e event propagation

### Phase 2: UX Improvements  
- [ ] Fix toolbar contrast - fundo escuro garantido
- [ ] Implement auto-fade - Timer + fade animation
- [ ] Add toggle para auto-fade na toolbar

### Phase 3: Testing
- [ ] Testar ESC em todos os modos
- [ ] Testar shortcuts sem abrir preferences
- [ ] Testar toolbar no whiteboard (fundo branco)
- [ ] Testar auto-fade toggle
- [ ] Criar nova build

---

## 🚀 Como Proceed

1. **Analisar** código atual dos arquivos mencionados
2. **Debug** adicionando logs (`print()`) para entender fluxo de eventos
3. **Implementar** fixes um por um
4. **Testar** cada fix isoladamente
5. **Criar PR** com descrição das mudanças

**Prioridade:** Resolver bugs 1-3 primeiro (bloqueantes), depois 4-5.

---

## 📁 Arquivos Principais

```
src/Inkstage/
├── App/
│   └── AppDelegate.swift
├── Core/
│   ├── AppStateManager.swift      # handleEscape(), toggle modes
│   ├── GlobalShortcutManager.swift # ESC, shortcuts
│   └── OverlayWindowManager.swift  # Annotation window
└── UI/
    └── Components/
        └── FloatingToolbar.swift   # Toolbar interactivity
```

---

*Brief criado: 2026-03-12*
*Para: Opus (Claude 4.6)*
*Reportado por: Rob*
