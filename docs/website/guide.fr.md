# Noty Linux pour KDE Plasma 6

Noty Linux est un widget de notes local pour KDE Plasma 6. Il conserve de petits
onglets au bord de l’écran et n’ouvre une note que lorsque vous en avez besoin.

## Installation

Clonez le dépôt puis mettez à jour le paquet Plasma local :

```bash
git clone https://github.com/rodmanvictor/noty-linux.git
cd noty-linux
kpackagetool6 --type Plasma/Applet --upgrade plasmoid/package
```

Ouvrez le mode d’édition du bureau Plasma, choisissez **Ajouter des widgets**,
recherchez **Noty** et placez-le contre un bord de l’écran.

## Fonctionnalités incluses

- Notes locales, onglets de bord, carte modifiable et Markdown avec tâches de
  checklist interactives.
- Palette pastel modifiable et réorganisable, papier ligné facultatif et styles
  Noty, Adaptive et Plasma.
- Archive avec restauration, effacement complet et durée de conservation
  configurable.
- Icônes Phosphor Regular incluses et mode facultatif utilisant le thème
  d’icônes Plasma.
- Interface en anglais, russe, espagnol, indonésien, allemand, français,
  portugais, chinois, japonais et hindi.

## Limites actuelles

L’intégration de bureau disponible est KDE Plasma 6. La prise en charge de
GNOME est prévue, mais n’est pas encore disponible. Les notes restent dans la
configuration locale du widget Plasma : il n’y a ni synchronisation entre
appareils ni service cloud.

## Vérifier un checkout

```bash
npm run docs:check
npm run test:site
npm run test:plasmoid
```

`test:plasmoid` requiert l’exécuteur de tests QML de Qt 6 et produit des
captures visuelles dans un environnement de développement KDE/Qt.

Cette documentation existe aussi en [English](guide.en.md), [Русский](guide.ru.md),
[Español](guide.es.md) et [Deutsch](guide.de.md).
