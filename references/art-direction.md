# Art direction

## Contents
1. Brief template · 2. Deriving identity · 3. Reference analysis · 4. Taste principles · 5. Anti-template checks · 6. Worked contrasts

## 1. Brief template (internal, ~15 lines)
```
Identity:    <3 adjectives that imply decisions, e.g. "weathered, cartographic, hushed">
Language:    shapes (radius/ratios), surfaces, borders, motifs, depth model
Palette:     bg / surface / surface-raised / text / text-muted / accent / accent-2 / ok / warn / danger
Type:        display face+weight, body face, numeric face, size scale
Composition: focal point, reading path, grid, margins, negative space
Assets:      what imagery/icons/textures would materially help (or "none")
Motion:      entry, press, select, ambient (or none) + easing family
Responsive:  desktop / phone-landscape / phone-portrait recomposition
Exclusions:  3+ things that would break this direction
```

## 2. Deriving identity
Answer in order: What is it for? What should the player notice first (one thing)? What world does it live in (genre, lighting, palette of the 3D scene)? Who plays (age, device)? How often is it opened (HUD = always visible, must recede; shop = occasional, may be rich)? What emotion should it carry (calm, urgency, reward, mystery)?
Map to decisions, not moods:
- Frequency high → low contrast chrome, small footprint, edges of screen, minimal motion.
- Frequency low / ceremonial → permitted richer surfaces, larger type, staged entrance.
- Young audience / chunky genre → larger touch targets, thicker shapes, rounder geometry, saturated accents.
- Sim/tactical/competitive → tight grid, tabular numerals, restrained color, sharp or small radii.
- World palette: sample the scene (lighting Ambient, dominant terrain/sky colors via baseline screenshot). Pick accent that either harmonizes (analogous) or deliberately contrasts for key actions only.

## 3. Reference analysis (mandatory when an image is supplied)
Actually view it (image in conversation, or fetched/inserted and captured). Write down:
1. Composition: where mass sits, focal point, margins, alignment axes, grid.
2. Hierarchy: size/contrast ranking of elements.
3. Geometry: radii, aspect ratios, stroke weights, angle language (chamfer/notch/pill).
4. Spacing rhythm: base unit, gutter-to-padding ratios.
5. Color: 5–7 dominant values, accent frequency (typically <10% area), value structure (light-on-dark ordering).
6. Type: classification, weight contrast, case, tracking, number style.
7. Material: flat / layered / textured / glass / paper; light direction; shadow behavior.
8. Iconography & ornament: line weight, fill style, corner style, decorative motifs.
9. Interaction cues: hover/selected/disabled looks implied.
Then split **defining** (removing it kills the look) from **incidental** (this screenshot's content). Rebuild the defining traits with Roblox-native means. Do not trace pixels; do not copy logos, characters, or distinctive artwork of third-party IP. Capture your result and compare side by side against the reference's defining traits in QA.

## 4. Taste principles (operational)
- **One idea, pushed.** Choose one dominant visual idea (e.g. "stamped brass plates", "torn paper tabs", "monochrome with one hot accent") and let every decision defer to it.
- **Contrast of scale.** Great layouts have a big thing, a medium thing, a small thing. Three near-equal sizes read as noise.
- **Restraint of accent.** One accent hue doing one job (primary action/selection/active data). Second accent only for semantic states.
- **Alignment is the cheapest luxury.** Shared left edges, shared baselines, consistent gutters. Misalignment of 2–4 px reads as cheap.
- **Negative space is a material.** Give the focal element room; dense is not rich.
- **Edge treatment tells the story.** Radius, stroke, bevel, notch — pick one edge vocabulary and keep proportions related (e.g. inner radius = outer radius − padding).
- **Depth with a logic.** Choose one light direction; shadows/highlights obey it, or use none (flat) deliberately.
- **Details at the end of hierarchy.** Ornament sits in secondary/tertiary zones, never competes with the focal point.
- **Typographic voice.** Pair a characterful display face (titles, numbers) with a quiet body face. Mono/tabular feel for stats where available.
- **Subtraction pass.** After the first build remove 10–20% of decoration and re-judge.

## 5. Anti-template checks (run before building and at QA)
Fail if ≥2 apply and no reason exists:
- Layout is title bar + X button + 3–4 equal cards in a grid with a gradient button.
- Single hue glow/neon stroke on everything.
- Every surface is the same rounded rectangle with the same corner radius.
- Palette is dark-navy + cyan/purple by default.
- Icons are mixed styles or emoji used as icons.
- Typography is one font at one weight (usually GothamBold) everywhere.
- Decoration doesn't relate to the game's world.
Remedy by changing structure (asymmetry, a hero element, different grid, split layout, off-axis header, edge-docked panel), not just recoloring.

## 6. Worked contrasts (illustrative, not templates)
- *Fantasy RPG inventory*: parchment/leather/brass material language, doll-silhouette hero on the left, item grid with slot frames of subtly irregular border (stroke + inner stroke), serif display for item names, rarity as border treatment not neon glow.
- *Competitive shooter HUD*: almost no chrome; thin 1–2px strokes, tabular condensed numerals, health as a slim bar at bottom-left with large number, ammo bottom-right, everything ≤ 10–15% opacity surfaces so the scene reads; accent only for low-health/low-ammo.
- *Cozy farming shop*: warm paper surfaces, rounded-chunky geometry, hand-drawn style icons, large product art, price as a stitched tag, soft spring-eased hover.
- *Sci-fi shop*: chamfered corners (via UICorner 0 + image/frames or UIGradient bevel cuts), uppercase tracked small-caps labels, hairline strokes, data-readout numerals; may use a restrained glow on one element only.
