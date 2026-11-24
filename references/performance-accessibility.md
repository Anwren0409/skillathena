# Performance & accessibility

## Contents
1. Performance · 2. Legibility · 3. Touch · 4. Gamepad & keyboard · 5. Color/motion safety · 6. Localization & content · 7. Checklist

## 1. Performance
- Instance budget: lists > ~50 items → build rows lazily/pooled (virtualize for hundreds); reuse clones; destroy what you create when it's discarded.
- Avoid: per-frame loops, `RenderStepped` for UI, polling, creating instances every update, tweening layout-driving sizes, many `UIGradient`/`UIStroke` on hundreds of items, nested `CanvasGroup`s, huge unsliced images (use right-sized assets; 9-slice for frames), `ClipsDescendants` everywhere.
- Hidden UI: `Visible=false` / `Enabled=false` the ScreenGui when closed.
- Measure: after playtest, check the console for warnings, and read the docs for the performance tools the connected Studio exposes (Stats, MicroProfiler guidance via the `skill`/docs tools) and use what applies — don't invent numbers.
- Event hygiene: disconnect on teardown; no duplicate connections on re-open (bind once, or clear in `setOpen(false)`).

## 2. Legibility
- Contrast: 4.5:1 body, 3:1 large/UI components, measured against the real rendered surface.
- Minimum effective text: 14 px body desktop, ≥ 12 px phone absolute minimum; prefer 16+ for primary reading.
- Avoid thin/decorative fonts at small sizes; no all-caps paragraphs; line length 45–70 chars.
- Text over the world: scrim or thin stroke; don't depend on scene brightness.
- Don't encode meaning in color alone.

## 3. Touch
- Targets ≥ 44×44 effective px (≥ 48 preferred for primary), ≥ 8 px spacing between adjacent targets.
- Primary actions within thumb reach in landscape (lower corners / sides).
- Avoid placing tap targets under the thumbstick/jump zones.
- No hover-only information; no precision dragging requirement.

## 4. Gamepad & keyboard
- `Selectable` on all interactables; visible, high-contrast selection indicator (SelectionImageObject) distinct from hover.
- Set initial `GuiService.SelectedObject` when opening; trap focus in modals; restore on close; B/Escape closes.
- Logical navigation order (set `NextSelection*` where auto-nav is wrong); no focus loss into hidden elements.
- Show input-appropriate prompts; keyboard shortcuts documented in UI where it matters.
- TextBox focus: `ReleaseFocus` on submit/close.

## 5. Color/motion safety
Respect reduced motion (motion.md). No flashing > 3 Hz. Test key states under a grayscale view (squint test) and consider common color-vision deficiencies for semantic colors.

## 6. Localization & content robustness
Design for text growth ≈ +30–40%: `TextWrapped`/`AutomaticSize`/truncation. Don't bake text into images. Numbers formatted. Handle long names, zero items, many items, missing images (placeholder style that's designed, then verify none remain).

## 7. Checklist
[ ] contrast measured  [ ] min sizes ok  [ ] 44px touch  [ ] gamepad traversal ok  [ ] no hover dependence  [ ] reduced-motion path  [ ] no leaked connections  [ ] lists scale  [ ] empty/long-text cases handled
