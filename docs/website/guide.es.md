# Noty Linux para KDE Plasma 6

Noty Linux es un widget de notas local para KDE Plasma 6. Mantiene pequeñas
pestañas en el borde de la pantalla y abre una nota solo cuando la necesitas.

## Instalación

Clona el repositorio y actualiza el paquete local de Plasma:

```bash
git clone https://github.com/rodmanvictor/noty-linux.git
cd noty-linux
kpackagetool6 --type Plasma/Applet --upgrade plasmoid/package
```

Abre el modo de edición del escritorio de Plasma, elige **Añadir widgets**,
busca **Noty** y colócalo junto a un borde de la pantalla.

## Incluye

- Notas locales, pestañas en el borde, una tarjeta editable y Markdown con
  tareas de lista interactivas.
- Una paleta pastel editable y reordenable, papel rayado opcional y los estilos
  Noty, Adaptive y Plasma.
- Un archivo con restauración, borrado completo y retención configurable.
- Iconos Phosphor Regular incluidos y un modo opcional para el tema de iconos
  de Plasma.
- Interfaz en inglés, ruso, español, indonesio, alemán, francés, portugués,
  chino, japonés e hindi.

## Límites actuales

La integración disponible es KDE Plasma 6. El soporte para GNOME está previsto,
pero todavía no está disponible. Las notas se guardan en la configuración local
del widget de Plasma; no hay sincronización entre dispositivos ni servicio en
la nube.

## Comprobar una copia local

```bash
npm run docs:check
npm run test:site
npm run test:plasmoid
```

`test:plasmoid` requiere el ejecutor de pruebas QML de Qt 6 y genera capturas
visuales en un entorno de desarrollo KDE/Qt.

Lee esta guía en [English](guide.en.md), [Русский](guide.ru.md),
[Deutsch](guide.de.md) o [Français](guide.fr.md).
