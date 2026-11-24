# Visual QA loop

## Contents
1. Capturing · 2. How to actually look · 3. Critique checklist · 4. LOOKS score · 5. Refinement procedure · 6. Loop exit & honesty · 7. Templates

This file covers how to *judge what you see*. How to *drive the GUI and observe actions and animations* is `playtest-protocol.md`. How to *treat every flaw* is `perfection-standard.md`. All three run together in Phase 8.

## 1. Capturing
1. `start_stop_play` (check schema) → poll `get_studio_state` until running; wait for GUI init (`execute_luau` Client: confirm the root ScreenGui exists in `PlayerGui` and is `Enabled`).
2. Put the GUI in the state you're judging (opened, item selected, empty, minimized, etc.) with real input via `user_mouse_input`/`user_keyboard_input`; use `execute_luau` (Client) only for what input tools cannot reach, and say so.
3. `screen_capture` (use camera args only for world views; UI captures are of the viewport). Capture **every** key state: default, open/closed, minimized/restored, selected, hover/pressed, disabled, empty/loading/error, long-text/many-items, and every viewport you claim to have tested.
4. Capture over a bright and a dark part of the scene — always, not only for translucent UI.
5. `get_console_output` after each round.
If `screen_capture` fails or returns nothing viewable, say so; do not score unseen output. Fall back to structural audit (`scripts/audit_gui.luau`) and label results as non-visual — and treat the visual gate as blocked.

## 2. How to actually look
Treat each screenshot as a design review of someone else's work. Describe what you see in concrete terms before judging (what is largest? what's brightest? where does the eye go first?). Then squint: blur mentally — does hierarchy hold? Compare to the art brief and to the reference's defining traits. Zoom mentally into edges: alignment, clipping, kerning, stroke consistency, image fuzziness. Never infer quality from code.

## 3. Critique checklist
Composition (balance, focal point, eye path, negative space) · Hierarchy (primary/secondary clarity) · Typography (readability, scale ratios, alignment, truncation) · Color (cohesion, contrast, accent restraint, surface separation) · Geometry (radius/stroke/spacing consistency, proportions, alignment) · Visual richness (identity vs clutter; materials/imagery fit) · Polish (gaps, collisions, clipping, orphan/empty areas, placeholder remnants, blurry images) · Context (belongs in this game; matches reference) · Responsive (per viewport) · Anti-template check (art-direction.md §5) · Motion (per playtest-protocol.md §4) · the ick test (perfection-standard.md §2).

## 4. LOOKS score (judgment aid, 0–100)
| Criterion | Weight |
|---|---|
| Visual identity & distinctiveness | 20 |
| Composition & hierarchy | 15 |
| Geometry & spacing | 15 |
| Typography & readability | 10 |
| Color & contrast | 10 |
| Asset selection & integration | 10 |
| Visual polish & motion | 10 |
| Responsive quality & context | 10 |
Score each subcriterion from the render; write one sentence of evidence per line. Calibration: 70 = functional but generic/template; 80 = competent, minor issues; 90 = intentional, cohesive, polished with a clear identity; 95+ = distinctive and refined at detail level. Be skeptical: first builds rarely exceed 75. Any **critical defect** (unreadable text, overlap hiding controls, broken images, off-screen controls, console errors, non-working primary action, layout drift) caps the score at 85 until fixed. **Completion requires ≥ 95, zero open defects, and a clean final pass.** The score never substitutes for the defect list: a 96 with an open defect is not done.

## 5. Refinement procedure (per round)
1. List **every** open defect (perfection-standard.md §3), then name the most damaging one first (rank: composition/hierarchy > identity > geometry/spacing > readability > color > polish). All of them get fixed; the ranking is only the order.
2. Diagnose the cause (not the symptom), consulting the docs.
3. Pick one targeted change (layout change before tweaking pixels; structure before decoration; subtraction before addition).
4. Apply (small `execute_luau` patch or `multi_edit`), preserving the rest.
5. Recapture the same state/viewport.
6. Compare before/after explicitly. If worse or equal, revert that change. Update the score and the defect list.
7. Run regression (playtest-protocol.md §9).
Don't polish details while a composition problem remains. After the composition holds, run the subtraction pass (remove 10–20% of decoration, re-judge) and the hostile art director pass (perfection-standard.md §6).

## 6. Loop exit & honesty
There is no round cap. Stop when ≥ 95, zero open defects, and the full ledger pass is clean — or when blocked by a **proven** limit (tool limit, engine limitation), reported with what you tried. If you cannot reach the bar, report the score, what blocks it, and what you tried. Never present an unfinished UI as passing. Never report a score you didn't derive from a render you viewed.

## 7. Templates
Round log (keep in notes):
```
Round N | state/viewport | score | open defects | top issue | cause | change | result (↑/↓/=)
```
Technical vs visual validation are separate verdicts: report both.
