# Playtest like a real player

## Contents
1. Principle · 2. Setup · 3. The action ledger · 4. Observing visuals and animations · 5. Drift tests · 6. Real input vs programmatic · 7. Console · 8. Evidence rule · 9. Regression and the final clean pass

## 1. Principle
You are the player and the code is a black box. Test through input; observe through captures. Reading code, structural audits, and programmatic calls never replace actually seeing the result. **Every single action gets tested, and for every action you look at the visual and, if there is one, the animation.** Nothing is assumed to work because a sibling works.

## 2. Setup
1. `start_stop_play` (check the schema) → poll `get_studio_state` until running. Confirm via `execute_luau` (Client) that the GUI exists in `PlayerGui`, is `Enabled`, and has finished initializing.
2. Fix the viewport you are testing and note its size. Repeat the relevant rows for each target viewport (see responsive-design.md).
3. Check the schemas of `user_mouse_input` and `user_keyboard_input`: coordinate space, button names, key names, press/release/hold/move support. Compute click points from live data: read the target's `AbsolutePosition`/`AbsoluteSize` through `execute_luau` (Client) and click its center. Account for GUI inset/safe-area offsets as the docs and schema describe.
4. Take a settled baseline capture of the world with the GUI closed.

## 3. The action ledger
Before testing, build the ledger from the **real built hierarchy** (not from memory of what you meant to build): enumerate every `GuiButton`, `TextBox`, `ScrollingFrame`, toggle, slider, tab, draggable, keybind, gamepad binding, and every animated or ambient element. Merge with the Phase 2 action inventory. One or more rows per item.

```
ID | element / action | input method(s) | start state | expected visual | expected animation | observed (capture refs) | console | verdict
```

Mandatory row categories — a category is "N/A" only with a written reason that the element truly doesn't exist:
- **A. Lifecycle:** first appearance on spawn (no flash of default/unstyled state), open, close, reopen ×3, toggle key, character respawn/reset, UI present at the right layer with the right DisplayOrder.
- **B. Every button:** hover (mouse), press, release inside, release outside (cancel), activate, activate while disabled, double-click, rapid spam ×10.
- **C. Selection and navigation:** select, change selection, deselect, tab switch, back, paging, keyboard path, gamepad traversal in all directions including edges and dead ends, Esc/B to close.
- **D. Window behavior:** minimize, unminimize, maximize/restore, drag, resize, snap, close — each repeated ×5 as a cycle, with a drift test (§5) per cycle.
- **E. Scrolling:** top, bottom, fast flick, wheel, with 0 / 1 / many / extreme item counts; scrollbar visibility and overlap.
- **F. Text input:** focus, type, long text, empty, submit, cancel, `ReleaseFocus`.
- **G. Data states:** empty, loading, error, one item, max items, very long strings, zero/huge numbers, live updates arriving while open, disabled / locked / owned / insufficient.
- **H. Responsiveness:** every target viewport; resizing while open; orientation change; rows that differ per layout mode.
- **I. Input switching:** mouse → touch → gamepad mid-session; prompts and glyphs swap; no hover-stuck states after touch.
- **J. Animations:** every tween, transition, stagger, and ambient loop, each observed per §4.
- **K. Interruptions:** close during the open animation, open during the close animation, select/press during a transition, re-trigger mid-flight, destroy/respawn mid-flight.
- **L. World context:** over a bright and a dark part of the scene, with Roblox core UI visible (topbar, chat, backpack, mobile controls), while the camera moves.

## 4. Observing visuals and animations
A single screenshot cannot show an animation. For every animated action:
1. **Before:** capture the settled state.
2. **Trigger** the action through real input.
3. **Slow-motion pass.** Set the `MotionScale` attribute on the GUI's root ScreenGui (client datamodel, via `execute_luau`) to 6–10 so durations stretch (the tween helper in motion.md multiplies by it). Re-trigger and capture at least three points: start, middle, end. Capture quickly and repeatedly; if captures are too slow for mid-flight frames, raise the scale.
4. **Numeric pass.** Run `scripts/animation_sampler.luau` on the animated properties to get per-frame values, measured duration, overshoot, snaps, stalls, reversals, and end-state accuracy. The sampler uses a programmatic trigger — say so in the report, and pair it with the real-input pass above.
5. **Real-speed pass.** Reset `MotionScale` to 1 (or remove the attribute), trigger once more with real input, and capture the settled result. Judge timing against motion.md ranges using the measured duration.
6. **Judge concretely.** Describe what you saw frame by frame. Then ask:
   - Does it start from the right place (no pop, no flash of the default state)?
   - Does the easing feel right for the direction (enter = out, exit = in)?
   - Any overshoot, jitter, flicker, or double movement that the design didn't intend?
   - Do staggered items arrive in the right order and rhythm?
   - Is anything on the wrong layer in transit, clipped, or briefly overlapping?
   - Does it land exactly on the canonical values and stay there?
   - Does the reverse animation mirror the forward one properly?
   - Is text blurry or shimmering mid-scale; do fades reveal overlapping parts?
   - Does it feel sluggish or abrupt? Does it delay the player's primary action?
7. If `screen_capture` cannot capture mid-flight at all, say so, rely on sampler + settled captures, and label that animation as numerically verified only.
8. **Remove** the `MotionScale` override when finished and confirm it is gone.

## 5. Drift tests
Anything that goes away and comes back (minimize/unminimize, close/reopen, maximize/restore, viewport resize and back, respawn) must return **exactly** to where it was.
1. Run `scripts/layout_snapshot.luau` → keep the text.
2. Perform the cycle with real input.
3. Wait for settle, run the script again with the text in `PREVIOUS`.
4. Any move, resize, rotation, or visibility change beyond 0.5 px that the design doesn't intend is a defect.
5. Repeat the cycle ×5 (drift often accumulates), in each target viewport, and once after a resize.

## 6. Real input vs programmatic
Use real input (`user_mouse_input`, `user_keyboard_input`) for every row it can express. Programmatic simulation (`execute_luau` firing handlers or setting state) is allowed only for what the input tools can't express (for example, gamepad buttons), and must be labeled as programmatic in the report. Where a programmatic test stands in, also verify the closest real input path.

## 7. Console
Call `get_console_output` after every action or tight group of actions. Any error or warning attributable to the GUI is a defect.

## 8. Evidence rule
Every ledger verdict cites evidence: a capture you viewed, a sampler result, a snapshot diff, a read-back. No evidence = not tested = the row is open. Open rows block completion. Report anything that genuinely could not be tested as untested (only for proven blockers).

## 9. Regression and the final clean pass
Any fix can break something else. After every fix: re-run the affected rows, then re-run the smoke subset (categories A, B, D, J). When the defect list is empty, run the **entire ledger from scratch in one uninterrupted pass** with no fixes in between. If anything needs fixing during that pass, fix it and start the full pass again. Only a full pass with zero fixes counts.
