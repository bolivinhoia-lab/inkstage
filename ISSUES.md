# Inkstage - Issues & Bugs Report

**Relatório de problemas para Opus resolver**

---

## 🐛 Bugs Críticos

### Issue #1: ESC não fecha os modos (Drawing/Whiteboard)
**Status:** Reportado
**Severidade:** Crítica
**Módulo:** GlobalShortcutManager, AppStateManager

**Descrição:**
Ao abrir o modo de desenho (pen) ou whiteboard, não é possível fechar/sair do modo pressionando ESC. O overlay permanece na tela.

**Comportamento Esperado:**
Pressionar ESC deve sair de qualquer modo ativo (drawing, whiteboard, spotlight, etc.) e voltar ao modo normal.

**Comportamento Atual:**
ESC não tem efeito. O usuário fica "preso" no modo ativo.

**Notas Técnicas:**
- Verificar `GlobalShortcutManager.handleEvent()` - keyCode 53 (ESC)
- Verificar se `AppStateManager.handleEscape()` está sendo chamado
- Possível problema: evento não sendo capturado globalmente ou callback não executando

---

### Issue #2: Shortcuts globais não funcionam
**Status:** Reportado  
**Severidade:** Crítica
**Módulo:** GlobalShortcutManager, MenuBarController

**Descrição:**
Os atalhos de teclado (⌘⇧A, ⌘⇧C, ⌘⇧S, ⌘⇧Z, ⌘⇧W) só funcionam se o usuário abrir o menu e clicar em Preferences primeiro. Sem isso, nenhum shortcut funciona.

**Comportamento Esperado:**
Shortcuts globais devem funcionar imediatamente após o app iniciar, sem necessidade de abrir preferences.

**Comportamento Atual:**
Shortcuts inativos até abrir preferences.

**Notas Técnicas:**
- Verificar `GlobalShortcutManager.setup()` - `addGlobalMonitorForEvents` vs `addLocalMonitorForEvents`
- Verificar se o app precisa de permissões de Acessibilidade (Accessibility API)
- Possível problema: NSEvent monitors não registrados corretamente na inicialização

---

### Issue #3: Toolbar não responde a cliques
**Status:** Reportado
**Severidade:** Crítica
**Módulo:** FloatingToolbar, PillToolbarView

**Descrição:**
A toolbar aparece na tela (canto inferior) mas não responde a interações. Não é possível:
- Clicar nas ferramentas
- Expandir a toolbar
- Selecionar outras cores (só amarelo funciona)

**Comportamento Esperado:**
- Clicar na toolbar deve expandir e mostrar todas as ferramentas
- Cada ferramenta deve ser clicável e selecionável
- Cores devem ser selecionáveis

**Comportamento Atual:**
Toolbar aparece mas é "inerte". Ferramentas em branco (invisíveis no fundo branco do whiteboard).

**Notas Técnicas:**
- Verificar `hitTest()` em `PillToolbarView` - pode estar interceptando eventos incorretamente
- Verificar nível da janela (`panel.level`) - pode estar atrás de outra janela
- Verificar `ignoresMouseEvents` nas views
- Cores: problema de contraste - fundo branco + ícones brancos = invisível

---

### Issue #4: Ferramentas invisíveis no Whiteboard (fundo branco)
**Status:** Reportado
**Severidade:** Alta
**Módulo:** FloatingToolbar, UI/UX

**Descrição:**
Quando o whiteboard está ativo (fundo branco), as ferramentas da toolbar também são brancas, tornando-se invisíveis.

**Comportamento Esperado:**
Toolbar deve adaptar cores baseado no fundo, ou sempre ter contraste adequado (ex: fundo escuro translúcido).

**Comportamento Atual:**
Fundo branco + ícones brancos = toolbar invisível.

**Notas Técnicas:**
- Toolbar usa `NSVisualEffectView` com material `.hudWindow` - pode não ter contraste suficiente
- Ícones usam `contentTintColor = .white` - sempre branco
- Solução: Adicionar sombra ou garantir fundo escuro suficiente na toolbar

---

### Issue #5: Desenho não desaparece automaticamente
**Status:** Reportado (Feature Request)
**Severidade:** Média
**Módulo:** AnnotationCanvas, Auto-fade feature

**Descrição:**
Não há opção de fading automático - os desenhos deveriam sumir magicamente após alguns segundos (como no Presentify).

**Comportamento Esperado:**
- Opção para desenhos sumirem automaticamente após X segundos
- Deve ser toggle rápido (não escondido em preferences)
- Deve ser acessível via shortcut ou toolbar

**Comportamento Atual:**
Desenhos são permanentes até manualmente limpar.

**Notas Técnicas:**
- Adicionar `Timer` em `AnnotationCanvas`
- Implementar fade-out com `NSAnimationContext`
- Adicionar toggle na toolbar (ex: ícone de ampulheta/timer)

---

## 📊 Resumo por Prioridade

### Crítico (Bloqueante)
1. ✅ ESC não fecha modos
2. ✅ Shortcuts globais não funcionam  
3. ✅ Toolbar não responde a cliques

### Alta (UX ruim)
4. ✅ Ferramentas invisíveis no whiteboard

### Média (Feature)
5. ✅ Auto-fade dos desenhos

---

## 🔍 Benchmark: Presentify

**URLs de Referência:**
- https://presentifyapp.com/
- https://presentifyapp.com/faq#miscellaneous

**Features a analisar:**
- Como o Presentify lida com ESC/exit
- Como os shortcuts são implementados (global vs local)
- Design da toolbar (contrastes, cores, interatividade)
- Auto-fade de anotações
- Integração com sistemas de apresentação

**Próximos Passos:**
1. [ ] Pesquisar documentação do Presentify
2. [ ] Analisar features que precisamos copiar/implementar
3. [ ] Criar especificação técnica para Opus

---

## ✅ Task List para Opus

- [ ] Fix: ESC handler global
- [ ] Fix: Global shortcuts (Accessibility permissions)
- [ ] Fix: Toolbar interactivity (hitTest, window level)
- [ ] Fix: Toolbar contrast/visibility
- [ ] Feature: Auto-fade toggle
- [ ] Research: Presentify features
- [ ] Test: Todos os fixes integrados
- [ ] Criar nova build

---

*Última atualização: 2026-03-12*
*Reportado por: Rob*
