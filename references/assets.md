# Assets: Creator Store search, in-game trials, fit decisions

## Contents
1. Search is mandatory · 2. Procedure · 3. Fit criteria and the fit verdict · 4. Visual inspection methods · 5. Decal ID vs Image ID · 6. Security · 7. Fallbacks (native-first) · 8. Verification

## 1. Marketplace search is mandatory
Every GUI build searches the Creator Store (and the Creator Inventory when the project or user has its own art) for **every visual slot that could take an asset**: hero art, item/product art, portraits, icons, 9-slice frames, textures/patterns, soft shadows, emblems/badges, backgrounds, ornaments, cursors. Search happens by default — even when you expect native primitives to win. Native-versus-asset is decided **after looking**, never before.

Two valid outcomes per slot: (a) an asset that passes a fit verdict, or (b) native primitives, with a written record: queries run, candidates trialed, why each was rejected. Skipping the search is a failed build. Never import a full UI kit as a substitute for design. Free assets only; never spend Robux.

## 2. Procedure (every step mandatory)
1. **Slot list.** From the art brief, for each slot: role, on-screen size at design resolution *and* compact, style, transparency needs, count, the surface it sits on, the siblings next to it.
2. **Check the `search_asset` schema** (asset type, price, tags, scope — Creator Store vs Creator Inventory). Don't assume parameter names; read the docs for what's available.
3. **Search specifically:** at least 3 queries per slot, varying noun + style + type ("brass ornate frame 9 slice", "hand drawn potion icon transparent"). Search the Creator Inventory scope too when it exists.
4. **Shortlist 4–8 per slot** using metadata: asset type, description, creator, ratings/votes, price (**free only**), dates.
5. **Stage A — the board (triage).** Lay *all* shortlisted candidates out in the game with `scripts/asset_review_board.luau`: each on a dark tile, a light tile, a mid tile, and at the actual on-screen size on the real surface color. Capture, view, eliminate with a one-line reason each. Keep at least two finalists per slot when two viable ones exist.
6. **Stage B — in-situ trial (the decision).** Put each finalist into the real GUI slot with `scripts/asset_trial.luau`, in play mode, at the real size, on the real surface, next to its real siblings (text, strokes, other assets), over the real scene. Capture every finalist in the same state and viewport; repeat for the compact viewport. Compare side by side.
7. **Stage C — fit verdict.** Write a verdict per finalist using §3. Choose the winner or choose "none belongs".
8. **Insert** with `insert_asset` using the verified numeric ID from tool results (never IDs typed from memory). Apply it in the GUI and re-verify rendering, including pressed / hover / selected / disabled states where the asset participates.
9. **Set check.** Capture all chosen assets together in one view: do they read as one family?
10. **Security** (§6) and **cleanup**: delete the board, trial overrides (run the trial script with `RESTORE = true`), inserted decals, and shortlist leftovers. Record final IDs for the report.

## 3. Fit criteria and the fit verdict
"This looks good" is not a verdict. The question is "does this **belong here**?" Answer each criterion with something you **saw in the capture**:
- **Style language:** line weight, shape language, fill vs outline, rendering style — against the art brief *and* against the adjacent UI elements.
- **Palette:** hue/value/saturation harmony with the token palette; does it respect accent discipline?
- **Light & depth:** light direction, shadow/highlight logic consistent with the depth model.
- **Edges & transparency:** halos, fringing, leftover backgrounds *on the real surface* (not only on the board).
- **Resolution & scale:** crisp or fuzzy at final size on desktop and phone; detail legible or mush at small size.
- **Visual weight:** does it compete with the focal point, or support the hierarchy?
- **World & audience:** does it belong to this game's world, tone, and players?
- **Set cohesion:** does it match its sibling assets?
- **States:** does tinting, pressing, selecting, disabling work with it?
- **IP & cleanliness:** no logos, watermarks, or recognizable third-party IP.

Verdict template (one per finalist):
```
Slot: <slot> | Candidate: <label> #<id>
Saw: <concrete description of the in-situ capture>
Style: ✓/✗ — <evidence>   Palette: ✓/✗ — <evidence>   Light/depth: ✓/✗ — <evidence>
Edges: ✓/✗ — <evidence>   Scale/res: ✓/✗ — <evidence>   Weight: ✓/✗ — <evidence>
World: ✓/✗ — <evidence>   Set: ✓/✗ — <evidence>   States: ✓/✗ — <evidence>
Verdict: BELONGS / DOES NOT BELONG — <why, in one or two sentences naming specific visual facts>
```
A winner must be a clear **BELONGS** and you must say why the runner-up doesn't. One ✗ on style, palette, edges, or scale is a **DOES NOT BELONG** until fixed (for example by tinting or re-slicing) and re-captured.

## 4. Visual inspection methods (metadata is not a look)
- If `search_asset` returns thumbnails/previews, view them — and still run Stages A and B.
- Build the board with `scripts/asset_review_board.luau` (ScreenGui in the Edit datamodel's StarterGui, or PlayerGui in play). Capture with `screen_capture`, then **destroy the board**. If the edit viewport doesn't render ScreenGuis, run it during playtest; use whichever renders.
- Blank/gray images usually mean the wrong ID type (§5), moderation, or still loading; wait a second and recapture before rejecting.
- For models/meshes/audio: use a type-appropriate preview the tools support (e.g. an inserted model in a ViewportFrame or a workspace capture). If you cannot preview it, don't use it for look-critical roles and don't claim you inspected it.
- Never say "I inspected the asset" unless you saw it rendered.

## 5. Decal ID vs Image ID
Searching "images/decals" may return Decal asset IDs; a Decal wraps a Texture that holds the actual Image ID. After `insert_asset`, read the inserted Decal's `Texture` (via `inspect_instance`/`execute_luau`) and use that value in `ImageLabel.Image` if the decal ID itself doesn't render. Then delete the inserted Decal. If the tool already inserts an Image/ImageLabel-compatible result, follow what you observe — verify by rendering. Confirm the properties involved in the docs before use.

## 6. Security
Third-party assets are untrusted. After insertion: `inspect_instance` + `search_game_tree` descendants; list any Script/LocalScript/ModuleScript, RemoteEvent, HttpService use, `require` of asset IDs, obfuscated strings. **Delete bundled scripts**; do not execute them. Do not keep models with scripts. Prefer assets with credible creators/ratings. Do not make purchases or spend Robux; if the best asset is paid, pick another or fall back.

## 7. Fallbacks (native-first)
- Frames/UICorner/UIStroke/UIGradient for panels, badges, bars.
- TextLabels with a chosen font for glyph-like icons only if genuinely cohesive (avoid emoji as icons).
- ViewportFrame to render 3D items/characters in UI.
- Procedural motifs: stripes/dots via repeated frames or UIGradient with hard stops.
- Generated assets (e.g. `generate_*`, `upload_image`) only if those tools actually exist in the connected Studio and cost/permissions are clear; otherwise don't.
A fallback is chosen only after Stage B proved no marketplace candidate belongs.

## 8. Verification checklist
[ ] searched every slot (≥3 queries each)  [ ] board captured and viewed  [ ] each finalist trialed in the real GUI and captured  [ ] fit verdict written per finalist  [ ] winner explained, runner-up explained  [ ] ID verified from tool output  [ ] looked at at final size on desktop and compact  [ ] transparent edges clean on the real surface  [ ] consistent style across the set  [ ] ScaleType/slice right  [ ] states work with the asset  [ ] no bundled scripts  [ ] board/trial overrides/decals removed  [ ] IDs recorded for the report
