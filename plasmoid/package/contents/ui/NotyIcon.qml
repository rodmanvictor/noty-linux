import QtQuick
import QtQuick.Shapes

import org.kde.kirigami as Kirigami

import "PhosphorPaths.js" as PhosphorPaths
import "PlasmaIconNames.js" as PlasmaIconNames

/**
 * @brief A consistently tinted local Phosphor Regular icon.
 *
 * Qt Quick Shapes renders the original SVG path data as a real vector and colours
 * only that path. This avoids both Kirigami.Icon's texture-mask path, which can
 * flatten a local SVG into an opaque square, and one raster effect texture per
 * icon. Source assets are Phosphor Icons Core 2.1.1 under `icons/LICENSE`.
 * An explicit Plasma-theme opt-in swaps only the source icon while retaining
 * Noty's fixed optical size and tint.
 */
Item {
    id: root

    /** @brief Phosphor Regular filename without the `.svg` suffix. */
    property string glyph: "archive"
    /** @brief Tint applied to the rendered SVG while preserving its alpha. */
    property color color: "#596978"
    /** @brief Uses the user's active Plasma icon theme instead of bundled vectors. */
    property bool usePlasmaIconTheme: false
    /** @brief True when the requested glyph exists in the bundled path map. */
    readonly property bool valid: glyphPath.path.length > 0
    /** @brief FreeDesktop icon identifier equivalent to the selected semantic glyph. */
    readonly property string plasmaIconName: PlasmaIconNames.forGlyph(glyph)
    /**
     * @brief Optical correction for glyphs whose source path has a shallow silhouette.
     *
     * Phosphor's archive path occupies considerably less vertical space than the
     * cross and ruled-paper paths inside the shared 256 x 256 viewBox.  Keeping
     * one hit target while enlarging only the painted archive glyph preserves the
     * icon grid without making the archive action look undersized.
     */
    readonly property real opticalScale: glyph === "archive" ? 1.16 : 1.0
    /** @brief Width of the aspect-fitted glyph inside this item. */
    readonly property real paintedWidth: Math.min(width, height)
    /** @brief Height of the aspect-fitted glyph inside this item. */
    readonly property real paintedHeight: paintedWidth

    Kirigami.Icon {
        anchors.centerIn: parent
        width: root.width * root.opticalScale
        height: root.height * root.opticalScale
        visible: root.usePlasmaIconTheme && root.plasmaIconName.length > 0
        source: root.plasmaIconName
        color: root.color
    }

    Shape {
        id: vectorShape
        visible: !root.usePlasmaIconTheme || root.plasmaIconName.length === 0
        width: 256
        height: 256
        x: (root.width - width * scale) / 2
        y: (root.height - height * scale) / 2
        scale: Math.min(root.width / width, root.height / height) * root.opticalScale
        transformOrigin: Item.TopLeft
        asynchronous: false
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"

            PathSvg {
                id: glyphPath
                path: PhosphorPaths.forGlyph(root.glyph)
            }
        }
    }
}
