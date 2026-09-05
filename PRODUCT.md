# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Static HTML, CSS, and JavaScript published with GitHub Pages. This is confirmed by the existing Pages workflow and landing-page source.

## Users

Linux desktop users who want a quick, local place for short notes while they work. The first shipped desktop integration targets KDE Plasma 6. Future desktop integrations are an explicit product ambition, not a current availability claim.

## Product Purpose

Noty Linux keeps small notes at a desktop edge, available without turning the desktop into a permanent notes application. The public website should let a Linux user understand the interaction, trust the implementation, and install the current Plasma widget.

## Positioning

The product is local-first, edge-resident desktop notes: individual notes appear as compact coloured tabs and expand only when selected.

## Operating Context

Users add the Plasma widget to a KDE Plasma 6 desktop, create and archive notes locally, and manage colours, typography, visual style, and archive retention in the widget settings. The public site is deployed through GitHub Pages from this repository.

## Capabilities and Constraints

- The shipping integration is a KDE Plasma 6 widget written in Qt/QML.
- Notes are stored locally; the website must not promise cloud sync or a GNOME build before either exists.
- The UI is localised; public captures are full, real frames from the running desktop widget.
- The website must use real desktop screenshots rather than reconstructed or illustrative widget scenes.

## Brand Commitments

- Public product name: **Noty Linux**.
- The name deliberately leaves room for later GNOME and other Linux desktop integrations.
- The landing page uses English copy and links to public guides in English,
  Russian, Spanish, German and French.

## Evidence on Hand

- Real KDE Plasma screenshots supplied for this landing page: `/tmp/codex-clipboard-7b7dd447-bf61-4bc7-bd5c-53cc8fc7a270.png` and `/tmp/codex-clipboard-d82edd8f-be6c-4f31-b635-692e1f4b09ec.png`.
- A real interaction recording supplied for the page: `/home/victor/Videos/Screencasts/noty.mp4`. Published MP4, GIF, and stills preserve the complete visible note deck; they are not CSS mockups or cropped reconstructions.
- The running Plasma widget and its public source are in this repository.
- There are no approved testimonials, user numbers, benchmarks, GNOME builds, or cloud-sync integrations; the site must not fabricate any.

## Product Principles

- Let the desktop stay quiet until a note is needed.
- Use the real working product as proof.
- Keep ownership local and reversible.
- Be precise about what ships today and what remains future work.

## Accessibility & Inclusion

The site must retain semantic headings, keyboard-visible focus, readable contrast, reduced-motion support, descriptive image alt text, and responsive layouts.
