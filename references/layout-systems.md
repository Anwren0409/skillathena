# Layout systems

## Contents
1. Archetype priorities · 2. Composition strategies · 3. Hierarchy tools · 4. Spacing system · 5. Grids · 6. Common structures in Roblox · 7. Layout failure modes

## 1. Archetype priorities (starting considerations, never fixed templates)
| Type | Priority | Notes |
|---|---|---|
| HUD | Glanceable info, zero gameplay obstruction | Dock to edges/corners, respect safe areas and the Roblox topbar/chat/mobile controls; low-opacity surfaces |
| Inventory | Item presentation, filtering, spatial memory | Detail pane for selected item; empty slots styled, not hidden; sort/filter discoverable |
| Shop | Product art, price clarity, selection state, purchase action | One dominant CTA; owned/locked/insufficient states; never fake a purchase |
| Settings | Discoverability, grouping | Group by task; labels left, controls right; immediate feedback |
| Dialogue | Readable text, speaker identity | Name plate + portrait; text width ≈ 45–70 chars; advance affordance |
| Full-screen menu | Brand moment, navigation, focal hero | Strong single focal point; navigation secondary and consistent |
| Notification/toast | Brevity, transient | Stack logic, auto-dismiss, don't steal focus |
| Leaderboard | Scannability | Rank, name, value columns aligned; self row highlighted |
| Loading | Branding + progress honesty | Real progress or indeterminate, never fake percentages |

## 2. Composition strategies (pick one deliberately)
- **Hero + rail:** large focal element (item art/character) + narrow list/rail. Strong hierarchy.
- **Split asymmetry:** 60/40 or 2/3–1/3 — avoids symmetrical "dialog box" feel.
- **Edge-docked drawer:** panel hugs a screen edge, keeps the game visible.
- **Radial / cluster:** for ability wheels, emote pickers; center-weighted.
- **Stacked bands:** horizontal strips (leaderboard, quest log), strong rhythm.
- **Free-form collage:** for stylized menus; deliberate overlap with clear z-order — only if hierarchy stays obvious.
- **Floating minimal:** no container at all; text and shapes over scene with shadows/scrims for legibility.
Ask: where does the eye land first, second, third? If you can't answer, recompose.

## 3. Hierarchy tools (strongest → weakest)
Size/scale · Contrast against surface · Position (top-left/center for primary on LTR) · Weight/typeface · Color saturation · Whitespace isolation · Motion · Ornament. Use at most two or three per tier; stacking all on one element looks shouty.
Target ratios: title : section : body : caption ≈ 2.0 : 1.4 : 1.0 : 0.8 (before device scaling). Primary CTA at least 1.5× the area of secondary actions.

## 4. Spacing system
Base unit u = 4 (pixels at design size, applied via UIPadding/UIListLayout.Padding offsets scaled by UIScale — or scale values for fluid layouts). Scale: 4 · 8 · 12 · 16 · 24 · 32 · 48. Rules:
- Inner padding ≤ outer margin; gutter ≤ padding.
- Related items 8–12 apart; groups 24+ apart (proximity = grouping).
- Optical alignment beats mathematical: round icons need slightly more margin than boxes.
- Same container type → same padding everywhere.
Pick values once as tokens; do not eyeball new numbers per element.

## 5. Grids
- Item grids: `UIGridLayout` with `CellSize` as scale or driven by script computing columns from available width (target min cell ≈ 72–96 px design size touch-friendly), `FillDirectionMaxCells` for column caps, `SortOrder = LayoutOrder`.
- Keep cell aspect locked with `UIAspectRatioConstraint` on cell content.
- Lists: `UIListLayout` with `Padding`, `HorizontalFlex/VerticalFlex` and `AutomaticSize` on rows when content varies.
- Prefer `UIListLayout` Flex modes and `UIFlexItem` for proportional rows over hand-computed sizes where available (verify in the engine class reference via `http_get`).

## 6. Common Roblox structure
```
ScreenGui "<FeatureName>" (ResetOnSpawn=false, ZIndexBehavior=Sibling, ScreenInsets as needed)
 ├─ Scrim (modals only: full-screen, Active to eat input)
 ├─ Root (anchored, sized by scale + UISizeConstraint)  [UIScale for density]
 │   ├─ Header | Nav | Content | Footer (UIListLayout or explicit anchors)
 │   └─ Overlays (tooltips, toasts) at higher ZIndex / own DisplayOrder
 └─ Controller (LocalScript) + Modules
```
Modal panels: scrim + panel, `Active = true` to block click-through, focus trap for gamepad.

## 7. Failure modes (check in screenshots)
Equal-weight everything · centered-everything dialogs · text touching edges · uneven gutters · orphan buttons · hairline scrollbars with no affordance · giant empty panel bottoms · panel covering the player's view on mobile · overlap with Roblox topbar, chat, jump button, thumbstick.
