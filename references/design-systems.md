# Design systems (tokens & consistency)

## Contents
1. Tokens · 2. Color · 3. Typography · 4. Geometry · 5. Surfaces & depth · 6. Components & states · 7. Token implementation

## 1. Tokens
Define once, reuse everywhere (a `Theme` ModuleScript for multi-screen UIs; a local table for a single panel). Categories: color, type, space, radius, stroke, elevation, motion durations/easings. Do not hardcode literals in build code beyond the token table.

## 2. Color
- **Structure by value first, hue second.** Squint test: convert the screenshot mentally to grayscale — hierarchy must survive.
- Roles: `bg` (scene scrim), `surface`, `surfaceRaised`, `border`, `text`, `textMuted`, `accent`, `accentText`, `ok`, `warn`, `danger`. 5–7 hues max incl. semantics.
- Accent covers ≈ 5–10% of visible area; only for primary action, selection, key data.
- Contrast: body text ≥ 4.5:1, large text/numerals ≥ 3:1 against the *actual* surface (consider transparency over a bright scene — add scrim or opaque surface). Compute with `scripts/audit_gui.luau` or by luminance formula.
- Semantic colors must not rely on hue alone (add icon/label/shape) — color-blind safety.
- Tints/shades: derive via lightness steps in Color3.fromHSV or fixed hand-picked ramps; avoid pure `#000`/`#FFF` unless a deliberate stylistic choice.
- Transparency is a material: translucent surfaces need a defined blur-less strategy (scrim underneath). Roblox UI has no native backdrop blur on GuiObjects; don't fake it with unreliable tricks — use opaque/semi-opaque surfaces plus scrim.
- Gradients: only to imply a light source or material (subtle 6–12% value shift). Rainbow/random-angle gradients are cargo cult.

## 3. Typography
- Roblox fonts: use `FontFace`/`Font.new(...)` (families/weights) or `Enum.Font`. Verify a font exists via `execute_luau` (`Font.fromEnum`, `Font.new("rbxasset://fonts/families/...")`) before relying on it. Custom font from the Creator Store: only if search_asset supports it and a preview render confirms it.
- Two families max: display + body. Weight contrast does most of the work (e.g. Bold titles / Regular-Medium body).
- Scale (design px at 1080p-ish): display 40–56, title 28–36, section 20–24, body 16–18, caption 13–14, never below 12 effective on phone.
- `TextScaled` + `UITextSizeConstraint(Min/MaxTextSize)` for fluid labels; fixed `TextSize` + `UIScale` for rigid panels. Don't mix chaotically.
- Alignment: left-align reading text; center only short headings/numbers. Avoid all-caps for long strings; tracking is unavailable natively — emulate sparingly or skip.
- Numbers: align right in columns; prefer a face with tabular figures; format with thousands separators.
- Text legibility over scenes: `UIStroke` (ApplyStrokeMode Contextual, thin) or a soft scrim; not heavy outlines on everything.
- `RichText` for inline emphasis; `TextTruncate = AtEnd` + `TextWrapped` where content varies; set `AutomaticSize` where growth is needed.

## 4. Geometry
- Choose an **edge vocabulary**: sharp (0) / small (4–6) / medium (8–12) / pill (UDim 1,0) / chamfer (image-based or composed). Keep nested radii related: `inner = outer − padding`.
- Stroke weights from a short scale (1, 2, 3 px); inner/outer double-stroke gives bevel feel when intentional.
- Aspect ratios: pick a small set (1:1 slots, 4:3 cards, 16:9 banners, 3:1 buttons) and reuse.
- Pixel hygiene: avoid odd-size centering blur — prefer even sizes and AnchorPoint 0.5 with even offsets; ImageLabel `ResampleMode` and `ScaleType` chosen deliberately (Slice for 9-slice frames; `SliceCenter`/`SliceScale`).
- Icon set: single style (line weight, corner treatment, fill) and consistent optical size (e.g. 24 in a 32 box).

## 5. Surfaces & depth
Pick one depth model:
- **Flat + stroke:** no shadow; hierarchy by value and border.
- **Layered:** surface < surfaceRaised via value step (+4–8% lightness) and 1px top highlight stroke; faux shadow via an offset darker Frame/ImageLabel with soft-shadow asset (verified) — avoid stacked huge UIStrokes.
- **Material/textured:** tileable texture ImageLabel with low opacity, vetted.
Shadows: single direction, short offset, low alpha; elevation tied to interactivity (popovers above panels).

## 6. Components & states
Every interactive component defines: default, hover (desktop), pressed, selected, focused (gamepad selection), disabled, loading, error. A component without a focus and pressed state is incomplete. Different components may differ in shape/size as long as they share tokens and edge vocabulary. Don't clone one button style for every role: primary / secondary / tertiary-ghost / destructive should be distinguishable by more than color.
Empty states: designed illustration/message + next action. Error states: specific text, no raw error strings.

## 7. Token implementation sketch
```lua
local Theme = {
  color = { surface = Color3.fromHex("#1B1712"), accent = Color3.fromHex("#D9A441"), text = Color3.fromHex("#F2E8D5") },
  space = { 4, 8, 12, 16, 24, 32 },
  radius = { sm = UDim.new(0, 4), md = UDim.new(0, 8) },
  motion = { fast = 0.12, base = 0.2, slow = 0.35 },
}
return Theme
```
(Values illustrative — derive yours from the art direction, not from this example.)
