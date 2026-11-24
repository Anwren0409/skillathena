# Responsive & multi-input design

Source of truth: https://create.roblox.com/docs/production/publishing/adaptive-design.md (principles: input fluidity, responsive layout, dynamic sizing, legibility). Cross-platform workflows: https://create.roblox.com/docs/projects/cross-platform.md

## Contents
1. Targets · 2. Sizing strategy · 3. Safe areas · 4. Recomposition · 5. Input · 6. Testing without lying · 7. Checklist

## 1. Targets
Desktop landscape (≈1920×1080, 1366×768) · Tablet · Phone landscape (≈ 844×390, small height!) · Phone portrait (≈ 390×844, if the experience supports it) · Console/gamepad on TV (distance legibility). The shortest phone dimension (≈ 390) is the design constraint — if it works there, it works larger.

## 2. Sizing strategy
- Scale-first: root panels sized with Scale + `UISizeConstraint(Min/Max)` + `UIAspectRatioConstraint` when proportions matter.
- Density: one `UIScale` on the root driven by script from viewport (`workspace.CurrentCamera.ViewportSize`), e.g. `scale = clamp(min(vp.X/1280, vp.Y/720), 0.6, 1.4)` — then **recompose** at breakpoints rather than only shrinking.
- Content-driven: `AutomaticSize`, `TextWrapped`, list/grid layouts that reflow.
- Keep touch targets ≥ 44×44 effective px (see performance-accessibility.md). Text ≥ 12 px effective on phones.
- Respect user text-size/accessibility preferences where available.

## 3. Safe areas
Use `ScreenGui.ScreenInsets` (e.g. `DeviceSafeInsets`, `CoreUISafeInsets`, `TopbarSafeInsets`, `None`) deliberately instead of hard-coded topbar offsets; verify enum names in the ScreenGui class reference. HUD elements near edges usually want device-safe insets; full-bleed backgrounds may ignore insets while content respects them. Avoid overlap with the Roblox topbar/menu, chat, mobile jump button & thumbstick zones, and notches. `GuiService:GetGuiInset()` only if needed.

## 4. Recomposition patterns
| Desktop | Compact (phone) |
|---|---|
| Left nav rail + content + detail pane | Top tabs or bottom bar; detail becomes bottom sheet/overlay |
| 6–8 column grid | 3–4 columns, larger cells; or single list |
| Full stat strip | Primary stat + collapsible rest |
| Floating side panels | Drawer from edge, fewer simultaneous panels |
| Hover tooltips | Tap-to-select detail / long-press |
| Persistent HUD cluster | Minimal essentials; secondary behind a menu button |
Implement with a `layoutMode` computed from viewport (e.g. `"wide" | "compact"`), applied by one function that changes visibility, layout direction, and sizes — not scattered ad-hoc checks. Listen to `ViewportSize` changes (`GetPropertyChangedSignal`) and re-apply (debounced).

## 5. Input
- Detect and adapt: `UserInputService.LastInputTypeChanged` (or `PreferredInput` where available — verify). Swap prompts/glyphs (`E`, `A`, tap) per input.
- Every action reachable with keyboard shortcut, touch, and gamepad. Gamepad focus order logical; visible selection; no dead ends.
- Never require hover; never require right-click/two-finger gestures.

## 6. Testing without lying
Use the connected tooling: ask the `skill` tool for device simulation guidance, or `http_get` the docs; if Studio's device emulator can't be driven via MCP, instead test layout by setting `ViewportSize`-driven logic with `execute_luau` or building a virtual-viewport harness, and **report exactly what you tested** ("verified at emulated 844×390 via X" vs "layout logic reviewed but not rendered at that size"). Capture screenshots per viewport you claim, and run every playtest-ledger row whose behavior differs in that layout mode (playtest-protocol.md §3 category H).

## 7. Checklist
[ ] no fixed-pixel root that overflows 844×390  [ ] recomposed (not just shrunk) for compact  [ ] insets respected  [ ] touch targets ok  [ ] gamepad path works  [ ] text legible at smallest  [ ] no overlap with Roblox core UI/mobile controls  [ ] tested viewports listed in report
