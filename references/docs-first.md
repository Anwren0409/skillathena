# Docs-first: the Roblox documentation is the manual

## Contents
1. The rule · 2. Mandatory reading at the start of every task · 3. Look up before you use · 4. When behavior surprises you · 5. Docs vs this skill · 6. If the docs can't be reached · 7. The docs ledger

## 1. The rule
Treat the official Roblox documentation the way a technician treats a service manual: open it, find the exact page, follow it. Memory is not a source — not for a property name, not for an enum member, not for a default value, not for a method you "definitely know". APIs change, get deprecated, and have remarks that change how you must use them.

This applies **every task** (every new user request), even if you read the same page earlier in the conversation for a different GUI. Within one task, one read per page is enough.

"Read" means you retrieved the page content in this task and used it. Having seen the page in an earlier task, or being confident, does not count.

## 2. Mandatory reading at the start of every task
Fetch and read in full (use `http_get` for allowed Roblox doc URLs, or the `skill` tool's docs search — check the tool schemas):
- Studio MCP: https://create.roblox.com/docs/studio/mcp.md
- UI/UX design: https://create.roblox.com/docs/production/game-design/ui-ux-design.md
- Adaptive design: https://create.roblox.com/docs/production/publishing/adaptive-design.md
- Cross-platform workflows: https://create.roblox.com/docs/projects/cross-platform.md

Then read the pages for what this specific GUI needs. Use the docs search tool when you don't know the URL. The reference pages follow this pattern (if a URL fails, search for the page and use the URL the search returns — never guess further):
- Classes: `https://create.roblox.com/docs/reference/engine/classes/<ClassName>`
- Enums: `https://create.roblox.com/docs/reference/engine/enums/<EnumName>`
- Data types: `https://create.roblox.com/docs/reference/engine/datatypes/<TypeName>`
- Libraries/globals: `https://create.roblox.com/docs/reference/engine/libraries/<LibraryName>`

## 3. Look up before you use
Before a class, property, method, event, enum, data type, service, or library function appears in any code you write — build code, controllers, test harnesses, audit scripts — read its documentation page and note: the exact name and spelling, value type, default, whether it is read-only or has security restrictions, thread/replication notes, remarks, and any deprecation notice with its replacement.

One page read covers every member of that class. So at the start of Phase 6, list every class you will instantiate or touch (ScreenGui, Frame, CanvasGroup, UIListLayout, UIStroke, TweenService, UserInputService, GuiService, ContextActionService, …) and read each page. When you add a new class later, read it before using it.

Also read the docs for **decisions**, not only syntax: input handling, safe areas, gamepad selection, text rendering, fonts, TweenInfo behavior, layout object interplay. If a design rule in a reference file here touches a specific behavior, confirm the behavior in the docs.

## 4. When behavior surprises you
Docs first, before trial and error. If a property read-back differs from what you set, an animation behaves oddly, a layout reflows unexpectedly, or an event doesn't fire: re-read the relevant page (remarks, notes, deprecations, interplay with other classes) and find the documented cause before changing code. Fix the cause the docs reveal, not the symptom.

## 5. Docs vs this skill
If the documentation and a reference file here disagree, **the documentation wins**. Use the documented behavior, and list the discrepancy in the report so the skill can be corrected.

## 6. If the docs can't be reached
Try both routes (`http_get` and the `skill` docs search), and retry once. If neither works, say so plainly. Then restrict yourself to API members you can confirm by other means in this Studio session (for example, a read-back with `execute_luau` or `inspect_instance` showing the property exists with the expected type), and mark everything unconfirmed as "unverified by docs" in the report. Never present memory as documentation.

## 7. The docs ledger
Keep a running list in your notes:
```
page URL | what it was read for | members used (with any notes: defaults, deprecations, restrictions)
```
The ledger is checked at the finish gate: every class, property, method, event, and enum in your final code must trace to a ledger entry. The final report lists the pages consulted.
