# Noty Linux landing page

The static website lives in `website/`. The `.github/workflows/pages.yml`
workflow publishes it after a push to `main`; it requires neither Vercel, a
build system, nor server-side code. The public URL is
`https://rodmanvictor.github.io/noty-linux/`.

The page uses approved full-frame captures from the running KDE Plasma widget:
`assets/screenshots/edge-tabs-full.png`,
`assets/screenshots/open-note-full.png`,
`assets/screenshots/colour-change-full.png`, and
`assets/demo/noty-workflow-full.mp4`. They retain the coloured tabs at the
right edge; CSS must not crop, squeeze or recreate the interaction. The
loopable `assets/demo/noty-workflow-full.gif` is downloadable for contexts
without video playback. Do not imply that the current Plasma build also ships
for GNOME or another desktop.

`npm run test:site` validates the title, installation command, and all local
assets. Keep the claims limited to the currently shipped KDE Plasma 6 widget;
the page must not imply a released GNOME integration or a hosted service.
