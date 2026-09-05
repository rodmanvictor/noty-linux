# Noty Linux für KDE Plasma 6

Noty Linux ist ein lokales Notiz-Widget für KDE Plasma 6. Es hält kleine Tabs
am Bildschirmrand bereit und öffnet eine Notiz nur bei Bedarf.

## Installation

Repository klonen und das lokale Plasma-Paket aktualisieren:

```bash
git clone https://github.com/rodmanvictor/noty-linux.git
cd noty-linux
kpackagetool6 --type Plasma/Applet --upgrade plasmoid/package
```

Den Bearbeitungsmodus des Plasma-Desktops öffnen, **Widgets hinzufügen**
wählen, nach **Noty** suchen und das Widget an einem Bildschirmrand platzieren.

## Enthaltene Funktionen

- Lokale Notizen, Rand-Tabs, eine bearbeitbare Karte und Markdown mit
  interaktiven Checklistenaufgaben.
- Eine bearbeitbare, umsortierbare Pastellpalette, optionales liniertes Papier
  sowie die Stile Noty, Adaptive und Plasma.
- Ein Archiv mit Wiederherstellung, vollständigem Leeren und konfigurierbarer
  Aufbewahrung.
- Ein integrierter Phosphor-Regular-Iconsatz und ein optionaler Modus für das
  Plasma-Icon-Theme.
- Benutzeroberfläche auf Englisch, Russisch, Spanisch, Indonesisch, Deutsch,
  Französisch, Portugiesisch, Chinesisch, Japanisch und Hindi.

## Aktuelle Einschränkungen

Die verfügbare Desktop-Integration ist KDE Plasma 6. GNOME-Unterstützung ist
geplant, aber noch nicht verfügbar. Notizen bleiben in der lokalen Plasma-
Widget-Konfiguration; es gibt keine Gerätesynchronisierung und keinen
Cloud-Dienst.

## Checkout prüfen

```bash
npm run docs:check
npm run test:site
npm run test:plasmoid
```

`test:plasmoid` benötigt den QML-Test-Runner von Qt 6 und erzeugt visuelle
Aufnahmen in einer KDE/Qt-Entwicklungsumgebung.

Diese Anleitung gibt es auch auf [English](guide.en.md), [Русский](guide.ru.md),
[Español](guide.es.md) und [Français](guide.fr.md).
