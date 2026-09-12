---
name: ClaudeHP
description: A fighting game health bar for your Claude quota, drawn at HUD scale on a matte black desktop.
colors:
  ground: "#0a0b0e"
  ground-2: "#121419"
  edge: "#2e3238"
  track-lo: "#101216"
  track-hi: "#272b32"
  chrome-hi: "#d8dee7"
  chrome-lo: "#5a606b"
  health-lo: "#ff8a14"
  health-hi: "#ffe968"
  danger-lo: "#e01b0c"
  danger-hi: "#ff6b3d"
  trail-lo: "#9e1a11"
  trail-hi: "#ff3b2f"
  tip: "#fff6d6"
  text: "#f2f4f7"
  dim: "#8e96a3"
  warn: "#ff7a5c"
typography:
  display:
    fontFamily: "Barlow Condensed, system-ui, sans-serif"
    fontSize: "clamp(72px, 9vw, 124px)"
    fontWeight: 800
    lineHeight: 1
    letterSpacing: "-0.01em"
    fontStyle: "italic"
    fontFeature: "tabular-nums"
  headline:
    fontFamily: "Barlow Condensed, system-ui, sans-serif"
    fontSize: "clamp(44px, 5vw, 68px)"
    fontWeight: 800
    lineHeight: 0.92
    letterSpacing: "-0.01em"
    fontStyle: "italic"
  title:
    fontFamily: "Barlow Condensed, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "0.12em"
    fontStyle: "italic"
  body:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "normal"
  label:
    fontFamily: "Barlow Condensed, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "0.3em"
    fontStyle: "italic"
  mono:
    fontFamily: "ui-monospace, SF Mono, Menlo, Consolas, monospace"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.75
    letterSpacing: "normal"
rounded:
  none: "0px"
  panel: "5px"
  block: "6px"
  window: "9px"
spacing:
  hair: "6px"
  xs: "14px"
  sm: "22px"
  md: "26px"
  lg: "48px"
  xl: "56px"
  gutter: "clamp(20px, 5vw, 72px)"
components:
  health-bar:
    backgroundColor: "{colors.track-lo}"
    height: "44px"
    rounded: "{rounded.none}"
  health-bar-compact:
    backgroundColor: "{colors.track-lo}"
    height: "22px"
    width: "314px"
    rounded: "{rounded.none}"
  health-bar-danger:
    backgroundColor: "{colors.danger-lo}"
    textColor: "{colors.warn}"
    rounded: "{rounded.none}"
  plate:
    textColor: "{colors.text}"
    typography: "{typography.title}"
  plate-dim:
    textColor: "{colors.dim}"
    typography: "{typography.label}"
  key-tag:
    textColor: "{colors.dim}"
    typography: "{typography.mono}"
    size: "0.72rem"
  widget-panel:
    backgroundColor: "{colors.ground}"
    textColor: "{colors.text}"
    rounded: "{rounded.panel}"
    width: "500px"
    height: "82px"
  install-block:
    backgroundColor: "{colors.ground-2}"
    textColor: "#e6e9ee"
    typography: "{typography.mono}"
    rounded: "{rounded.block}"
    padding: "22px 24px 22px 26px"
  copy-button:
    backgroundColor: "transparent"
    textColor: "{colors.health-hi}"
    rounded: "{rounded.none}"
    padding: "8px 12px"
  copy-button-hover:
    backgroundColor: "{colors.health-hi}"
    textColor: "{colors.ground}"
  terminal-window:
    backgroundColor: "#15171d"
    textColor: "#c9cfd8"
    typography: "{typography.mono}"
    rounded: "{rounded.window}"
    padding: "14px 18px"
  fact-row:
    backgroundColor: "{colors.ground}"
    textColor: "#cfd5de"
    rounded: "{rounded.none}"
    padding: "26px 0"
---

# Design System: ClaudeHP

## Overview

**Creative North Star: "The Versus Screen"**

ClaudeHP borrows the one interface every player reads without thinking: the fighting game health bar above the arena. The world is a matte black cabinet, and the only lit object on it is a sheared amber gauge with a chrome bevel and a red trail lagging behind the damage. Everything else in the system, body copy, terminal text, install block, is instrumentation around that gauge. The bar is not decoration on top of a product page; it is the page's first sentence.

Ground truth lives in the native app. `main.swift`'s `enum Ink` and `SHEAR = 0.30` define the palette and the geometry; the web tokens in `site/index.html`'s `:root` were derived from them and agree value for value. Where the app and the web disagree, the app is the source of truth. One divergence stands on purpose: the app draws lettering in DINCondensed-Bold (a macOS system face, with a heavy system fallback), while the web ships Barlow Condensed 700/800 italic as a webfont because DIN Condensed is not available on the open web. Both read as the same condensed italic HUD voice; new web surfaces use Barlow Condensed.

Density is arcade, not editorial: the top band is loud and oversized, then the page drops to quiet system-UI prose at 17-19px with a 62ch measure. The system refuses the dev-tool landing grammar it was built against, headline over subtitle over screenshot card over three feature columns. Here the mechanism runs first, live, at full width, and the words arrive afterward.

**Key Characteristics:**
- Matte black ground (#0a0b0e), no page-level gradient, no ambient glow
- Sheared parallelogram gauges (shear 0.30, equal to skewX(-16.7deg)), never rounded
- One amber-to-yellow light source: the gauge and its near-white leading edge
- Red trail that lags the drain; red-orange pulse under 20 percent
- Condensed italic uppercase plates for every label and number; system UI for prose; system mono for commands and data keys
- Every number carries the key it came from (`limits[kind=session]`)

## Colors

A black cabinet with one lit gauge: amber and yellow carry all the energy, red is reserved for damage and danger, and everything else is graphite and chrome.

### Primary
- **Ember Amber** (`{colors.health-lo}`): the left end of every healthy fill. Owns the top band of the first viewport through the full-width bar and through the small skewed chip that heads each fact row.
- **Signal Yellow** (`{colors.health-hi}`): the right end of every healthy fill, and the system's only interactive accent: links, focus rings, the copy control's text, the emphasized word in the headline.
- **Filament White** (`{colors.tip}`): the 3px leading edge riding the head of the fill, with a soft 12px bloom. The single light source in the world.

### Secondary
- **Damage Red** (`{colors.trail-lo}`) to **Hot Red** (`{colors.trail-hi}`): the lagging trail exposed between the old level and the new one. Visible only while the bar is falling.
- **Alarm Red** (`{colors.danger-lo}`) to **Flare Orange** (`{colors.danger-hi}`): the fill replaces amber entirely under 20 percent and pulses.
- **Warn Coral** (`{colors.warn}`): the percentage number's color in the app when a gauge is in danger.

### Neutral
- **Cabinet Black** (`{colors.ground}`): the page and the app panel. Also the text color on any amber-filled surface.
- **Recessed Graphite** (`{colors.ground-2}`): the install block's inset well. The only raised-from-black surface in flat prose regions.
- **Hairline Edge** (`{colors.edge}`): every 1px divider, section rule, and panel stroke.
- **Track Graphite** (`{colors.track-lo}` to `{colors.track-hi}`): the depleted part of a gauge, bottom-dark to top-light, carrying 45-degree hairline stripes at 5 percent white.
- **Bevel Chrome** (`{colors.chrome-lo}`) and **Bevel Highlight** (`{colors.chrome-hi}`): the gauge's inner casing stroke and its 1.6px top highlight. Chrome never appears as a fill, only as an edge.
- **Readout White** (`{colors.text}`) and **Readout Dim** (`{colors.dim}`): all lettering. Dim carries labels, keys, captions, and secondary numerals.

### Named Rules
**The One Light Source Rule.** The gauge's leading edge is the only thing in this world that glows. Every other shadow is diffuse black. No accent glow, no colored drop shadow, no neon outline anywhere else.

**The Red Means Damage Rule.** Red is never a brand color, a link, a button, or an error chrome. Red appears only where health was just lost (the trail) or is about to run out (the sub-20-percent fill). If a surface has no draining quantity, it has no red.

**The Amber Floor Rule.** Amber and yellow are confined to the gauge, the fact-row chips, and single-word emphasis. Amber never fills a card, a section band, or a page background.

## Typography

**Display Font:** Barlow Condensed (with system-ui fallback); the native app draws the same voice in DINCondensed-Bold
**Body Font:** system UI stack (`system-ui, -apple-system, Segoe UI, Roboto`)
**Label/Mono Font:** system mono stack (`ui-monospace, SF Mono, Menlo, Consolas`)

**Character:** Condensed italic uppercase for anything the HUD says about itself, a plain unstyled system face for anything said to a human, and mono for anything a machine said first. The three never blend; the register switch is how the page signals whether you are reading the game or the documentation.

### Hierarchy
- **Display** (800 italic, `clamp(72px, 9vw, 124px)`, line-height 1, tabular): the reset countdown only. Its seconds ride as a dim `small` at roughly 38 percent of the parent size.
- **Headline** (800 italic uppercase, `clamp(44px, 5vw, 68px)`, line-height 0.92): the single page headline, and it sits *below* the stage, never above the bar.
- **Title** (700 italic uppercase, 22px, +0.12em): the plates. Gauge names, product name, fact titles (26px).
- **Body** (400, 17px page / 19px pitch paragraph, line-height 1.5): prose, capped at 62ch (`--measure`).
- **Label** (700 italic uppercase, 11-14px, +0.24em to +0.3em, dim): RESET, INSTALL, macOS · Swift. Wide tracking is what separates a label from a plate.
- **Mono** (400, 12-14px): commands, terminal output, captions marked demo, and data keys at 0.72rem.

### Named Rules
**The Plate Rule.** Every HUD word is a plate: condensed, italic, uppercase, tracked, with a `0 1px 2px rgba(0,0,0,.85)` shadow so it survives sitting directly on a gauge. Sentence-case condensed italic is not part of this system.

**The Receipt Rule.** A displayed number is followed by the key it came from, set in mono at 0.72rem in dim (`limits[kind=session]`). The claim and its source ship together or the number does not ship.

**The Voice Rule.** Copy is short and human. No dashes as connectors, no marketing formulas, no adjective stacking. Commands are the call to action; the install block is the button.

## Layout

A full-bleed HUD band, a full-bleed stage, then a centered document. The HUD is a three-column grid (`minmax(0,1.35fr) auto minmax(0,.5fr)`) aligned to baseline-end with a 48px column gap, capped at 1440px, with a `clamp(20px, 5vw, 72px)` gutter that every band shares. The gauge occupies the left cell at roughly 60 percent of the viewport and 44px tall; the countdown sits center-right; the name plate far right.

The stage below breaks the 1440px cap: the desktop background is edge-to-edge with hairline rules top and bottom, and only its contents are re-centered to 1440px. Prose bands narrow to 1120px. Vertical rhythm runs 56px into the HUD, 40px to the stage, 64px to the pitch, 56px to the facts, 32px to the footer rule; inside a component the steps are 6, 14, 22, 26.

Responsive: at 1100px the HUD tightens to a 32px gap, the widget scales to 0.82 from its top-right corner, and the pitch collapses to one column. At 760px the gauge takes the full row and drops to 34px tall, the countdown moves beneath it and left-aligns at `clamp(64px, 22vw, 96px)`, the terminal stretches to the gutters, the widget scales to 0.68, and fact rows stack. The first viewport's order never changes: gauge, then numbers, then stage.

### Named Rules
**The Bar First Rule.** Nothing renders above the health bar. No nav, no logo row, no announcement strip, no headline. The first painted object on any ClaudeHP surface is the gauge.

**The Measure Rule.** Prose never exceeds 62ch, no matter how wide the band is.

## Elevation & Depth

Depth here is bevel, not elevation. The world is flat black; objects gain body from inset strokes that model a metal casing, and only two things actually cast a shadow, both diffuse and black. Nothing is lifted by a colored or offset shadow.

### Shadow Vocabulary
- **Gauge casing** (`inset 0 1.6px 0 #d8dee7, inset 0 0 0 2px #5a606b, inset 0 -6px 12px rgba(0,0,0,.55)`, plus a 2.5px solid black outer border): the full anatomy of a bar. The compact 22px variant uses 1.2px / 1.5px / -4px 8px and a 2px border.
- **Floating panel** (`0 3px 12px rgba(0,0,0,.55), inset 0 0 0 1px #2e3238`): the widget, matching the app's 12px black shadow at -3 offset.
- **Window drop** (`0 22px 50px rgba(0,0,0,.6), inset 0 0 0 1px #262a32`): the terminal on the desktop stage. The deepest shadow in the system, and it exists to say "this is a real window on a real desktop".
- **Text shadow** (`0 1px 2px rgba(0,0,0,.85)`): on every plate and numeral.

### Named Rules
**The Bevel Not Elevation Rule.** Surfaces get depth from inset chrome strokes. Drop shadows are reserved for things that are literally floating in the depicted desktop: the widget and the terminal window. Cards, rows, and blocks stay flat on black with a hairline edge.

**The No Hard Offset Rule.** Every shadow in this world is blurred and black. Hard offset shadows belong to a neobrutalist world; this one is a machined cabinet.

## Shapes

Two form languages, deliberately separate. Gauges and anything that speaks for a gauge are **sheared parallelograms**: shear 0.30 in the app (top edge displaced by 0.30 × height), `skewX(-16.7deg)` on the web, zero corner radius, sharp corners. The shear applies to the bar, to its plates and numerals, to the copy control, to the fact-row chips, and to the ROUND marker. Content inside a skewed control is counter-skewed so the text reads level.

Everything that depicts real software is **soft-cornered**: the widget panel at 5px (the app's `xRadius: 5`), the install block at 6px, the terminal window at 9px. Documents, dividers, and rows are square with 1px hairline edges and no fill.

### Named Rules
**The Shear Rule.** 0.30 is the only shear in this system. Nothing is skewed at a different angle, and nothing sheared is ever given a corner radius.

## Components

### Health Bar (signature component)
The system's reason to exist. Anatomy, bottom to top: a graphite track running dark at the bottom to light at the top, overlaid with 45-degree hairline stripes at 5 percent white and darkened toward the bottom; the lagging red trail clipped to the previous level; the amber-to-yellow fill clipped to the current level, with a top-half white gloss falling 30 percent to 2 percent; a 3px near-white leading edge with a soft bloom; a 2.5px black outer border with the chrome bevel inset inside it. The hero adds a single 20 percent notch with a small triangular tick.
- **Sizes:** 44px hero, 34px hero on mobile, 22px in the widget row (314px wide).
- **Danger:** under 20 percent the fill swaps to alarm-red-to-flare-orange and pulses brightness 1 to 1.22 over 1.1s. The app runs the same rule as a 10 percent white blend driven by a sine.
- **Motion:** the fill eases toward its target (0.16 per frame on the web, 0.18 in the app) and the trail follows far slower (0.045 web, 0.055 app). That gap is the effect; do not equalize them.

### Widget Panel
The real macOS window, rendered at 1:1 (500 × 82 compact, 62px per extra row). Near-opaque black at 5px radius with a top white 6 percent wash, a 1px edge stroke, and a soft black drop. Collapsed it clips to one row; clicking expands the clip over 0.28s on `cubic-bezier(.2,.8,.2,1)` and fades rows 2 and 3 in. Hover and focus brighten the inset stroke from edge to chrome; focus-visible adds a 2px yellow ring inset 4px.

### Copy Control
The only button in the system, and it is deliberately not a big filled CTA. Skewed, transparent, yellow condensed italic uppercase at 13px with +0.14em, framed by a 1.5px chrome inset stroke, label counter-skewed. On hover it inverts: yellow fill, black text, no stroke. Its label swaps to "Copied" for 1.6s, or "Select it" when the clipboard is unavailable.

### Install Block
The primary action. Recessed graphite well at 6px radius with a hairline inset stroke, mono at 14px/1.75, with `$ ` prompts in dim and marked unselectable so a copy picks up commands only. Headed by a dim tracked INSTALL label whose rule line pushes the copy control to the right end.

### Terminal Window
The proof surface. 9px radius, #15171d body, a 34px centered title bar with the three macOS traffic dots drawn as one 12px circle plus two box-shadow copies. Output uses green prompts, white headings, dim reset lines, and a periwinkle block-character meter that mirrors the same numbers as the gauges.

### Fact Row
A 280px plate column beside a 62ch prose column, separated by hairline rules only. Each plate is preceded by a 22 × 11px skewed amber chip with a chrome top highlight and a black outline: a health bar reduced to a bullet.

### Round Marker
On reset, a skewed plate at `clamp(56px, 7vw, 104px)` fades and scales from 0.92 to 1 over the stage, underlined by an amber-to-yellow bar with a black outline, then leaves after 1.5s. It is announced politely to assistive tech.

### Named Rules
**The Shared Clock Rule.** The hero gauge, the widget, and the terminal read from one state object and repaint in one frame. If a surface shows a number that also exists elsewhere on the page, it is the same number from the same tick or it does not ship.

**The One Authored Moment Rule.** This system has exactly one motion idea: the drain, with its lagging trail, its red pulse under 20 percent, and its ROUND marker on reset. Under `prefers-reduced-motion` the drain stops, the pulse stops, the widget's expand transition drops, and the countdown keeps ticking on a 1s interval. No scroll reveals, no parallax, no entrance animations.

## Do's and Don'ts

### Do:
- **Do** open every surface with the gauge. The bar is the first painted object, full width, before any word.
- **Do** derive palette and geometry from `main.swift` (`enum Ink`, `SHEAR = 0.30`). The app is the source of truth; the web `:root` mirrors it.
- **Do** pair every displayed number with its source key in dim mono (`limits[kind=session]`).
- **Do** keep the trail slower than the fill (0.045 vs 0.16 web, 0.055 vs 0.18 app). The lag is the effect.
- **Do** swap the fill to alarm-red and pulse below 20 percent, and nowhere else.
- **Do** label simulated data plainly, in mono, next to the thing it describes ("demo · numbers are simulated").
- **Do** use the skewed chrome-stroked control as the button form, with counter-skewed label text.
- **Do** cap prose at 62ch and set it in the plain system UI face at 17-19px.
- **Do** honor `prefers-reduced-motion` by freezing the drain and the widget transition while the countdown keeps ticking.

### Don't:
- **Don't** put a headline, nav, logo bar, or announcement strip above the health bar.
- **Don't** round a sheared shape or shear anything at an angle other than 0.30.
- **Don't** use red for links, buttons, brand marks, or error chrome. Red is damage.
- **Don't** add a second light source. The leading edge glows; nothing else does.
- **Don't** ship hard offset shadows. Shadows are blurred, black, and reserved for the widget and the terminal window.
- **Don't** fill a card, band, or background with amber.
- **Don't** float a tracked plate above a headline as a kicker or eyebrow. Plates label data, controls, and gauges.
- **Don't** add a second motion idea. No scroll reveals, no parallax, no entrance animations.
- **Don't** set condensed italic in sentence case, and don't set prose in the display face.
- **Don't** use glyph icons or icon fonts. This system draws its own shapes (the chip, the notch, the traffic dots).
- **Don't** mix languages in shipped copy. Web surfaces are English.
