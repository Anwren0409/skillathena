# Motion

## Contents
1. Principles · 2. Timing & easing · 3. Patterns · 4. Canonical-state animation · 5. TweenService code · 6. Interruptions · 7. Reduced motion & motion scale · 8. Performance · 9. Don'ts · 10. Animation QA

Read the TweenService, TweenInfo, Tween, and relevant Enum pages in the docs before writing any tween (docs-first.md).

## 1. Principles
Motion explains state change and reinforces identity. If removing an animation loses no information and no personality, remove it. Match the art direction: restrained UI → short, linear/quad, no overshoot; energetic UI → Back/Elastic sparingly, still bounded; ceremonial UI → longer staged entrance.

## 2. Timing & easing (defaults to adapt per art direction)
Press feedback 80–120 ms · hover 120–160 ms · selection 160–220 ms · panel open 220–320 ms · close ~70% of open · stagger 20–40 ms/item, max ~8 items · toast in 200 ms, hold 2.5–4 s, out 200 ms.
Easing: enter = `Out` (Quad/Cubic/Quint), exit = `In`, move = `InOut`. One easing family per interface. `Back`/`Elastic` only if the direction is playful, and overshoot small.

## 3. Patterns
- Open: fade (via CanvasGroup.GroupTransparency or per-element transparency) + 8–16 px slide from the dock edge; scrim fades.
- Press: scale 0.96–0.98 via UIScale or size, plus value shift.
- Select: border/accent transition + subtle raise; deselect reverse.
- Number change: quick tween of displayed value (stepped via NumberValue/`task` stepping) — avoid per-frame loops.
- Loading: a single indeterminate element; stop when done.
- Ambient: at most one slow, low-amplitude loop, only on non-critical decor, off when UI hidden.

## 4. Canonical-state animation (prevents drift and "offset for no reason")
Every window/panel/element that changes state (open, closed, minimized, maximized, selected…) has a **state table of absolute target values**, defined once from tokens and recomputed when the layout mode or viewport changes:
```lua
local States = {
  open      = { Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0 },
  closed    = { Position = UDim2.fromScale(0.5, 0.54), GroupTransparency = 1 },
  minimized = { Position = UDim2.fromScale(0.5, 0.95), GroupTransparency = 0 },
}
```
Rules:
- Transitions tween **to** the target table. Never compute "current position + delta" and never read a mid-flight value as the base for the next move.
- Set `AnchorPoint` once at build time and never animate it. Don't change `AnchorPoint`, `Size` mode (Scale vs Offset), or parent while a tween runs.
- Opening from any interrupted state still lands exactly on `States.open`; minimize → unminimize lands exactly where it started.
- A single function (`setState(name)`) owns visibility, `Active`, selection restoration, and the tween. No other code writes these properties.
- When `layoutMode`/viewport changes, recompute the tables, then snap (no animation) to the current state's values.
- Verify with the drift test (playtest-protocol.md §5).

## 5. TweenService code
```lua
local TweenService = game:GetService("TweenService")
local active: {[Instance]: Tween} = {}
local function scaled(seconds: number): number
  -- MotionScale: attribute on the root ScreenGui (default 1). Used for slow-motion playtests and accessibility.
  return seconds * (gui:GetAttribute("MotionScale") or 1)
end
local function tween(obj: Instance, t: number, props: {[string]: any}, style, dir)
  if active[obj] then active[obj]:Cancel() end
  local tw = TweenService:Create(obj, TweenInfo.new(scaled(t), style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
  active[obj] = tw
  tw.Completed:Once(function() if active[obj] == tw then active[obj] = nil end end)
  tw:Play()
  return tw
end
```
Read durations from the token table at call time (never cached at load) so scale and reduced-motion changes take effect. Hide after the close tween completes (`Completed:Once` → check the state is still "closed" → `Visible=false`) so hidden UI costs nothing and can't catch input — and so a re-open during the close tween doesn't get hidden by a stale callback.

## 6. Interruptions
Every animation must survive being interrupted: close during open, open during close, press during a transition, rapid re-trigger. Cancel the conflicting tween, tween to the new canonical state from wherever the object currently is, and guard completion callbacks against stale state. Stagger sequences must be cancelable as a unit.

## 7. Reduced motion & motion scale
Expose a `Theme.reducedMotion` flag (default from any available player/system preference if the API exists — verify in the docs; otherwise provide a code-level toggle). When on: durations → 0–80 ms, no slides/bounces/loops, keep crossfades. `MotionScale` (attribute, default 1) multiplies every duration; the playtest sets it to 6–10 to capture mid-flight frames and must restore it afterward.

## 8. Performance
Tween properties, don't step them manually. Avoid tweening `Size` of layouts with many children (reflow) — prefer transparency/position/UIScale. Cancel tweens on destroy. Don't run tweens on hidden UI.

## 9. Don'ts
Everything bouncing · infinite pulsing glows · parallax for its own sake · flashing (photosensitivity) · blocking input during long transitions · animations that delay the player's primary action · delta-based movement · animating AnchorPoint.

## 10. Animation QA (mandatory for every animation)
Observe it per playtest-protocol.md §4: slow-motion captures (start/middle/end), the sampler, a real-speed pass. Confirm: correct start, right easing for direction, no overshoot unless designed, lands on canonical values, reverses cleanly, survives interruption, no pop/jitter/flash, duration within range, no leftover state after ×5 repeats.
