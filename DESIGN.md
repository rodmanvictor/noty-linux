---
name: Noty Linux
description: A quiet, evidence-led landing page for local edge notes on Linux.
colors:
  night: "#171925"
  night-raised: "#202331"
  ink: "#f7f2e7"
  muted: "#b6b4bc"
  note: "#b8ead5"
  sun: "#f5d46d"
  pink: "#efa4b7"
  focus: "#8dd5ff"
typography:
  display:
    fontFamily: "Noty Serif, Georgia, serif"
    fontSize: "clamp(3.25rem, 6.5vw, 6.15rem)"
    fontWeight: 700
    lineHeight: 0.9
    letterSpacing: "-0.04em"
  body:
    fontFamily: "Noto Sans, Segoe UI, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.56
rounded:
  surface: "15px"
  control: "9px"
spacing:
  compact: "10px"
  control: "16px"
  section: "clamp(74px, 10vw, 136px)"
components:
  button-primary:
    backgroundColor: "{colors.sun}"
    textColor: "{colors.night}"
    rounded: "{rounded.control}"
    padding: "11px 16px"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    padding: "11px 16px"
---

# Design System: Noty Linux

## Overview

**Creative North Star: "Quiet Desktop Field Record."**

The public page behaves like a carefully edited record of a real desktop
interaction, not a recreated app scene. A near-black work surface makes the
real pastel Plasma capture the proof and the only pictorial event. The page is
calm, direct, and deliberately honest about what currently ships.

Key characteristics:

- Evidence comes before decoration: real captures, no drawn product mockups.
- A warm serif headline gives the page editorial character; interface text
  remains a practical system sans-serif.
- Sun-yellow is scarce and reserved for the primary action and mark.

## Colors

The palette is a dusk desktop field: deep neutral ground, warm paper-white
ink, and a few purposeful note colours.

- **Night** (`#171925`): page background and the dark code surface.
- **Raised Night** (`#202331`): capture captions and contained support areas.
- **Paper Ink** (`#f7f2e7`): primary copy and high-emphasis controls.
- **Quiet Ink** (`#b6b4bc`): supporting copy and navigation at rest.
- **Paper Mint** (`#b8ead5`): live-capture marker and product evidence cue.
- **Signal Sun** (`#f5d46d`): primary action, logo, and restrained emphasis.
- **Reference Pink** (`#efa4b7`): upstream-credit underline only.
- **Focus Blue** (`#8dd5ff`): visible keyboard focus.

**The Evidence Accent Rule.** Use colourful pastel paper in the real product
capture; do not turn every webpage section into a pastel card.

## Typography

**Display Font:** self-hosted Noty Serif (Noto Serif), with Georgia fallback.
**Body Font:** Noto Sans, Segoe UI, sans-serif.
**Code Font:** system monospace only for installation commands.

The display is heavy, compact, and editorial. Body copy is plain and readable;
it should explain the interaction without sounding like marketing boilerplate.

- **Display:** 700, `clamp(3.25rem, 6.5vw, 6.15rem)`, 0.9 line height; hero only.
- **Section Heading:** the display family, `clamp(2.25rem, 4.4vw, 4rem)`, 0.96 line height.
- **Body:** 400, 16px, 1.56 line height; supporting paragraphs are kept near 44–58ch.
- **Control Label:** 700–850, 0.79–0.9rem; short and action-led.

## Layout

Use a single shell: `min(1180px, calc(100% - 48px))`, with wide, ruled
separation between major sections. The desktop hero is an asymmetric two-column
composition: editorial copy at left, the actual capture at right. At 900px the
content becomes one column; at 620px the capture moves before the hero copy so
the evidence appears in the first mobile viewport.

## Elevation & Depth

Depth is quiet and functional. Real product captures use a single ambient
shadow (`0 28px 80px rgba(0,0,0,.34)`) to lift a desktop moment from the dark
field. Other separation comes from one-pixel low-contrast rules, not stacks of
cards.

## Shapes

Large proof surfaces use a 15px radius. Buttons use a compact 9px radius;
navigation and motion controls are small, lightly bordered, and never pill-like
by default. The page uses thin, translucent lines to contain rather than
decorate.

## Components

### Buttons

- **Primary:** Signal Sun background, Night text, 46px minimum height; on hover
  it rises 2px and becomes slightly lighter.
- **Secondary:** transparent with a quiet light border; it becomes a subtle
  paper-white wash on hover.
- **Focus:** every link and button gets a 3px Focus Blue ring with a 3px offset.

### Capture Panel

The hero capture is a real 13-second Plasma recording with a descriptive label
and a Pause/Play control. It is the only autoplaying motion on the page. The
same interaction is offered as downloadable MP4 and GIF, while lower product
proof uses static crops.

### Navigation

Navigation is restrained, text-first, and visually secondary to the evidence.
On narrow viewports only the GitHub destination remains visible; semantic labels
and the skip link remain available to keyboard users.

## Do's and Don'ts

### Do:

- **Do** use only real, English-language product crops in public proof media.
- **Do** label future desktop support as future direction, never present availability.
- **Do** preserve the visible Pause/Play control and reduced-motion behaviour.
- **Do** keep upstream credit explicit and factual.

### Don't:

- **Don't** recreate Noty with CSS illustrations or invented dashboard scenes.
- **Don't** show personal neighbouring note titles in screenshots, GIFs, or video.
- **Don't** mix multiple icon systems or use emoji as interface icons.
- **Don't** use pastel panels as generic webpage containers; colour belongs to the product evidence.
