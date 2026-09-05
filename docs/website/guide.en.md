# Noty Linux for KDE Plasma 6

Noty Linux is a local-first notes widget for KDE Plasma 6. It keeps small tabs
at a screen edge and opens a note only when you need it.

## Install

Clone the repository and upgrade the local Plasma package:

```bash
git clone https://github.com/rodmanvictor/noty-linux.git
cd noty-linux
kpackagetool6 --type Plasma/Applet --upgrade plasmoid/package
```

Open Plasma desktop edit mode, select **Add Widgets**, search for **Noty**, and
place it against a screen edge.

## What is included

- Local notes, edge tabs, an editable note card, and Markdown display with
  inline checklist tasks.
- A reorderable pastel palette, optional ruled paper, and the Noty, Adaptive,
  and Plasma appearance styles.
- An archive with restore, permanent clear, and configurable retention.
- A bundled Phosphor Regular icon set and an optional Plasma icon-theme mode.
- Interface translations in English, Russian, Spanish, Indonesian, German,
  French, Portuguese, Chinese, Japanese, and Hindi.

## Current limits

The shipping desktop integration is KDE Plasma 6. GNOME support is planned but
is not available today. Notes stay in the local Plasma widget configuration;
they are not synchronized between devices or offered as a cloud service.

## Check a checkout

```bash
npm run docs:check
npm run test:site
npm run test:plasmoid
```

`test:plasmoid` requires the Qt 6 QML test runner and generates visual
snapshots in a KDE/Qt development environment.

Read this guide in [Русский](guide.ru.md), [Español](guide.es.md),
[Deutsch](guide.de.md), or [Français](guide.fr.md).
