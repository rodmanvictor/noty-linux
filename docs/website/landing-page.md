# Noty Linux landing page

The static website lives in `website/`. The `.github/workflows/pages.yml`
workflow publishes it after a push to `main`; it requires neither Vercel, a
build system, nor server-side code. The public URL is
`https://rodmanvictor.github.io/noty-linux/`.

The page uses approved real captures from the running KDE Plasma widget:
`assets/screenshots/live-note-editor.png`,
`assets/screenshots/live-note-colour.png`, and
`assets/demo/noty-workflow.mp4`. The public captures crop the real interaction
to its English note card, so neighbouring personal note titles never become
website content. `assets/demo/noty-workflow.gif` is the derived, loopable
version for contexts without video playback; it is downloadable rather than
autoplayed a second time on the page. Do not replace these with a CSS mockup or
imply that the current Plasma build also ships for GNOME or another desktop.

`npm run test:site` validates the title, installation command, all local assets,
and the honest upstream credit. The page must call this an independent Linux
desktop implementation inspired by Noty for macOS, not an official upstream
product.
