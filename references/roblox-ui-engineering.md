# Roblox UI engineering

## Contents
1. Placement & hierarchy · 2. Building via MCP · 3. Core classes · 4. Layout objects · 5. Scripting patterns · 6. Interaction · 7. Client/server · 8. Verification · 9. Pitfalls · 10. Naming

Every class, property, method, event, and enum you use must be read from the Roblox documentation first (docs-first.md) — e.g. https://create.roblox.com/docs/reference/engine/classes/ScreenGui and .../GuiObject — and recorded in the docs ledger. Never rely on memory for property names, defaults, or deprecations.

## 1. Placement & hierarchy
- New GUI: `StarterGui/<FeatureName>` (ScreenGui; a descriptive, role-based name such as `ShopMenu` — see §10). Controller `LocalScript` as a child of the ScreenGui (runs when cloned to PlayerGui) or under `StarterPlayer/StarterPlayerScripts` if it must outlive a ScreenGui with ResetOnSpawn. Shared tokens: `ModuleScript` child of the ScreenGui or `ReplicatedStorage`, matching project conventions you observed in Phase 0.
- Redesign: modify the existing GUI in place; keep names/paths/attributes other scripts reference (`script_grep` for names before renaming anything).
- ScreenGui defaults: `ResetOnSpawn=false` (for persistent UI), `ZIndexBehavior=Sibling`, `DisplayOrder` set intentionally, `IgnoreGuiInset`/`ScreenInsets` chosen deliberately (see responsive-design.md).
- Keep depth ≤ 5–6 for common cases. Name by role (`Header`, `ItemGrid`, `Slot_01`), no `Frame1`.
- Group visuals vs logic: visuals are instances; logic in scripts; avoid scripts parenting inside many small elements.

## 2. Building via MCP
- Create the tree with `execute_luau` (`datamodel_type` Edit) in a small number of deterministic batches: helper functions + construction, returning a summary (paths created). Make scripts with `multi_edit` (creates if path missing) or by setting `Source` in `execute_luau` — use whichever the schema supports; read back with `script_read`.
- Make builds **idempotent**: destroy only the root you created earlier this session (its recorded path) before recreating; never wipe StarterGui, and never overwrite an instance you didn't create (redesign it in place or pick another descriptive name).
- Set properties in a data-driven way; use `scripts/ui_helpers.luau` patterns.
- After building, `inspect_instance` the root to confirm structure; use `search_game_tree` to confirm nothing stray was created.
- Edit-mode ScreenGuis may render in the viewport; if not, rely on play-mode captures.

## 3. Core classes (choose, don't use all)
ScreenGui (screen) · BillboardGui/SurfaceGui (world-anchored UI) · Frame · CanvasGroup (group fade; costs more — use only for fade/mask) · TextLabel/TextButton/TextBox · ImageLabel/ImageButton · ScrollingFrame (`AutomaticCanvasSize`, `ScrollBarImageTransparency`, `ScrollingDirection`) · ViewportFrame (3D previews; needs camera + lights) · VideoFrame if needed.
Buttons: use `TextButton`/`ImageButton` with `AutoButtonColor=false` when you implement custom states. Set `Selectable` for gamepad.

## 4. Layout objects
UIListLayout (Padding, FillDirection, HorizontalAlignment, VerticalAlignment, SortOrder, Wraps, Flex modes) · UIGridLayout (CellSize, CellPadding, FillDirectionMaxCells) · UIPageLayout (paged nav, animated) · UITableLayout · UIPadding · UICorner · UIStroke (`ApplyStrokeMode`, `Thickness`, `Transparency`, `LineJoinMode`) · UIGradient · UIScale · UISizeConstraint · UIAspectRatioConstraint · UITextSizeConstraint · UIFlexItem. Prefer layout objects + constraints over manual offset math. Set `LayoutOrder` explicitly.

## 5. Scripting patterns
```lua
-- Controller skeleton (LocalScript)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local gui = script.Parent
local Theme = require(gui:WaitForChild("Theme"))
local root = gui:WaitForChild("Root")

local connections: {RBXScriptConnection} = {}
local function bind(signal: RBXScriptSignal, fn) table.insert(connections, signal:Connect(fn)) end

local State = { open = false, selected = nil }
local function setOpen(v: boolean) ... end   -- single source of truth for visibility + tween

bind(root.Header.Close.Activated, function() setOpen(false) end)
gui.Destroying:Once(function() for _, c in connections do c:Disconnect() end end)
```
- One state table + render/update functions; update only changed elements.
- Build repeated rows from a **template clone** (`Template` hidden in script or ServerStorage-like holder under gui), not hundreds of manual instances.
- Tween handles: keep per-object handle, `:Cancel()` before starting a conflicting tween.
- Use `task.wait/defer/delay`, not `wait`. Use `Once` where applicable. Type-annotate (`--!strict` optional) to catch mistakes.
- Toggle key: `ContextActionService:BindAction` (with gamepad button) or `UserInputService.InputBegan` (check `gameProcessedEvent`).
- Don't poll for data; connect to attribute/value changes or remote events.

## 6. Interaction
- Activation: `Activated` (mouse, touch, gamepad A). Hover: `MouseEnter/MouseLeave` (desktop only; never gate functionality on hover). Press feedback: `InputBegan/InputEnded` on the button for `MouseButton1`/`Touch`.
- Gamepad: `Selectable=true` on interactables, `SelectionImageObject` custom (or `SelectionBehavior*`), `GuiService.SelectedObject` set when opening a modal, restore on close, `NextSelectionUp/Down/Left/Right` for custom order.
- Modals: scrim `Active=true`; Escape/B closes (`ContextActionService`, `Enum.KeyCode.ButtonB`).
- Scroll lists: mouse wheel works natively; touch drag works natively.
- Disabled: dim + `Active=false`/ignore handler; show reason in tooltip/text.
- Empty/loading/error rendered as real states.

## 7. Client/server
- Visual and local state: client. Purchases, currency, inventory changes, persistence: server only, through **existing** remotes/modules found in Phase 0. If none exist, do not fabricate them silently — build the UI to a thin adapter (`Adapter.lua` with clearly named functions returning mock-free "not connected" results) and state the gap in the report. If the user explicitly asks you to create the backend, implement server-validated remotes (validate sender, args, rate limit) in ServerScriptService.
- Never trust client values for authority. Never put secrets or admin checks in LocalScripts.
- `MarketplaceService` prompts for purchases must go through the real product IDs the user supplies; don't invent IDs.

## 8. Verification
- Syntax errors: `script_read` + run in play, then `get_console_output`.
- Runtime: inspect PlayerGui via `execute_luau` with `datamodel_type` Client during play (`game.Players.LocalPlayer.PlayerGui.<FeatureName>`).
- Simulate: `user_mouse_input` / `user_keyboard_input` for every action (real input first). Fire `Activated` handlers via `execute_luau` only for what the input tools can't express, and state it was a programmatic simulation. The full procedure is `playtest-protocol.md`.

## 9. Pitfalls
Property typos fail silently in builders → read back values. `AutomaticSize` + Scale size conflicts. TextScaled without size constraints. UIListLayout inside UIGridLayout parent. `ClipsDescendants` clipping UIStroke/shadows. ZIndex vs layout order surprises under Sibling behavior. CanvasGroup overuse. Free-model script payloads. Deprecated: `wait`, `Enum.Font` legacy-only styling where FontFace is available, `IgnoreGuiInset` vs `ScreenInsets` — check class doc. Delta-based animation ("move by +N from wherever it is") drifts after interruptions and minimize/unminimize cycles — use canonical states (motion.md §4). Changing `AnchorPoint` or Scale/Offset mode mid-tween shifts layout. Reading `Position` while a tween runs and using it as a base value. Stale tween `Completed` callbacks hiding a re-opened panel. Duplicate connections on every re-open. Default-named instances (`Frame`, `TextLabel`) left behind.

## 10. Naming
- Role-based, descriptive, PascalCase for objects (`ShopMenu`, `ItemGrid`, `CloseButton`), `Slot_01` style for repeated items, `camelCase` for locals and attributes you add. Follow the project's existing convention when it has one.
- Nothing carries a brand or tool name: not this skill's name, not "AI", "Claude", "generated", "auto" — in instances, scripts, modules, attributes, tags, remotes, comments, or filenames.
- Temporary instances use `Temp_<Purpose>` and are removed before finishing.
- No default names (`Frame`, `TextLabel`, `Frame1`) on anything you create; `scripts/audit_gui.luau` checks this.

