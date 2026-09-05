import QtQuick

import org.kde.plasma.components as PlasmaComponents

/**
 * @brief A compact, theme-independent action button for bundled Phosphor icons.
 *
 * Plasma's default ToolButton surface differs between desktop themes and made
 * local Phosphor glyphs look like a mixture of icon sets. This wrapper keeps
 * every action on the same transparent base, adding only a restrained outline
 * for hover, keyboard focus and the checked state.
 */
PlasmaComponents.ToolButton {
    id: control

    /** @brief Bundled Phosphor Regular glyph name without the `.svg` suffix. */
    property string glyph: "x"
    /** @brief Optical icon size inside this action target. */
    property int glyphSize: 16
    /** @brief Neutral action colour shared by the card and archive. */
    property color glyphColor: "#667784"
    /** @brief Subtle outline used to make icon hit areas discoverable. */
    property color outlineColor: Qt.rgba(0.18, 0.23, 0.29, 0.18)
    /** @brief Optional hover fill; transparent keeps the glyph visually primary. */
    property color hoverFill: "transparent"
    /** @brief Opt-in for resolving the same semantic glyph in Plasma's icon theme. */
    property bool usePlasmaIconTheme: false

    hoverEnabled: true
    padding: 0

    /** @brief Presents the native pointing-hand cursor for this clickable icon. */
    HoverHandler {
        id: pointerCursor
        objectName: "pointerCursor"
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        cursorShape: Qt.PointingHandCursor
    }

    contentItem: Item {
        /**
         * The control owns this full hit-area wrapper. Keeping the glyph one
         * level deeper prevents ToolButton from stretching it to 28 or 32 px.
         */
        NotyIcon {
            anchors.centerIn: parent
            width: control.glyphSize
            height: control.glyphSize
            glyph: control.glyph
            color: control.glyphColor
            usePlasmaIconTheme: control.usePlasmaIconTheme
        }
    }

    background: Rectangle {
        radius: Math.min(width, height) / 2
        color: (control.hovered || control.checked || control.activeFocus) ? control.hoverFill : "transparent"
        border.width: (control.hovered || control.checked || control.activeFocus) ? 1 : 0
        border.color: control.outlineColor

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.width { NumberAnimation { duration: 120 } }
    }
}
