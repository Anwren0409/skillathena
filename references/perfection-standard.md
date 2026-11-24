# The perfection standard

## Contents
1. Zero tolerance · 2. The ick test · 3. Defect catalog · 4. Fix procedure · 5. Loop exit · 6. Hostile art director pass · 7. Perfection is not decoration

## 1. Zero tolerance
A defect is **any** deviation from the intended design that you notice — in a capture, a sampler result, a snapshot diff, a console line, or in how an interaction feels. There is no "minor" bucket you may ship. The examples in this file are illustrations, not the boundary: if something is off, it is a defect, whether or not it appears here.

Banned reasoning: "good enough", "probably fine", "barely noticeable", "players won't notice", "edge case", "I'll mention it in the limitations". Limitations are for proven blockers only (see the mandatory contract in SKILL.md).

Flaky is a defect too. If something goes wrong once in five tries, it is broken.

## 2. The ick test
After every action, every capture, every animation, ask. Any "yes" is a defect:
- Did anything move, resize, flash, pop, jump, or shift that I didn't design?
- Did anything feel late, abrupt, floaty, sluggish, or mechanical?
- Is anything a pixel off, uneven, or slightly inconsistent with its siblings?
- Does the second time differ from the first (reopen, re-select, re-minimize)?
- Does anything look unfinished, default, placeholder-ish, or borrowed from another style?
- Would an art director, a player, or a QA engineer wince at this?
- Do I feel the urge to explain something away? That is the ick.

## 3. Defect catalog (non-exhaustive)
**Layout & geometry:** drift or offset after minimize/unminimize/maximize/resize/reopen · 1 px misalignment · uneven gutters · inconsistent radius/stroke · blur from odd-size centering · content touching edges · overlap with Roblox core UI · UIStroke/shadow clipped by `ClipsDescendants` · `AutomaticSize` jumps · layout reflow flash on open · distorted aspect ratios · stretched or fuzzy images · scrollbar overlapping content · `UIScale` pop when the viewport changes.

**Animation:** pop or snap at start/end · starts from the wrong position · unintended overshoot · double animation (two tweens fighting) · jitter · stuck half-state after interruption · open/close that don't mirror · easing wrong for direction · stagger off · too slow or too fast against motion.md · animation delaying the primary action · blurry text mid-scale · fades that reveal overlapping parts · ambient loops that distract · animation continuing while hidden.

**State & interaction:** stuck hover after touch · stuck pressed · selection indicator misfit · gamepad focus lost into hidden elements · double-fire · click-through to the world or under a modal · works on one input type only · disabled that looks enabled · missing feedback · Esc/B inconsistent · first open differs from re-open · state not reset on close or respawn.

**Visual:** low contrast · text clipped or truncated unexpectedly · font fallback · placeholder remnants · the default gray Roblox button flashing · blank or missing images · halos/fringes on asset edges · mixed icon styles · dead whitespace · unclear hierarchy · accent overuse · ornament competing with the focal point.

**Technical:** console error or warning · leaked connections · duplicate listeners after reopen · instance growth on repeated open · default or branded names · Z-order flicker · orphaned tweens · temp objects left behind.

## 4. Fix procedure (root cause, always)
1. **Reproduce** with the exact action, five times. Note whether it is consistent.
2. **Capture evidence** of the defect (capture, sampler output, snapshot diff) so the fix can be compared.
3. **Find the root cause** — use the documentation (docs-first.md §4) and read-backs, not guesses.
4. **Fix at the cause.** Do not mask: no `task.wait` to hide a race, no hand-tuned offset to cancel a drift, no toggling visibility to hide a glitch, no clamping to cover a bad value. Prefer structural fixes (canonical states, single source of truth, layout objects over manual math).
5. **Recapture the same state** and compare before/after explicitly. If it's worse or equal, revert that change.
6. **Regression** per playtest-protocol.md §9.
7. If three genuinely different fixes fail on the same defect, stop patching: re-architect that component cleanly and re-test it fully.

## 5. Loop exit
There is **no round cap.** The loop ends only when one full uninterrupted ledger pass (playtest-protocol.md §9) finds zero defects, every state looks right in captures you viewed, and LOOKS ≥ 95. The other exit is a proven blocker, reported honestly with what was tried. If you run out of working budget, stop and report exactly which ledger rows are unverified and which defects are open; never claim perfection you did not verify.

## 6. Hostile art director pass
Before declaring done, recapture every key state fresh and review it as a hostile art director reviewing someone else's work: write down the three things you'd criticize most. Fix them. Repeat until you can't find three. Your first impression of "this is fine" is not evidence.

## 7. Perfection is not decoration
Perfectionism means everything that exists is flawless and intentional. It does not mean adding more. Run the subtraction pass (remove 10–20% of decoration, re-judge) and keep whatever survives only if it earns its place.
