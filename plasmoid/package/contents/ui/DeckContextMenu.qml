import QtQuick
import QtQuick.Controls

/**
 * @brief Exposes Plasma-owned widget actions from the separate note-deck window.
 * @sideeffect Uses a popup window so the menu is not clipped to the narrow tab fan.
 * A one-pixel parent at the click keeps compositor anchoring local to that point.
 * Action text, availability and execution remain owned by Plasma.
 */
Menu {
    id: menu
    popupType: Popup.Window
    margins: -1
    /** @brief Plasma QAction objects to display, including configure and remove. */
    property var widgetActions: []

    /** @brief A minimal popup parent, positioned inside the item receiving the click. */
    property Item clickAnchor: Item {
        width: 1
        height: 1
    }

    /**
     * @brief Opens beside a click without anchoring against the entire deck rectangle.
     * @param {Item} source Item whose local coordinate system contains the click.
     * @param {number} clickX Horizontal position in source coordinates.
     * @param {number} clickY Vertical position in source coordinates.
     * @returns {void} Reparents the anchor and opens a windowed menu.
     */
    function popupAt(source, clickX, clickY) {
        clickAnchor.parent = source
        clickAnchor.x = clickX
        clickAnchor.y = clickY
        popup(clickAnchor, 0, 0)
    }

    Instantiator {
        model: menu.widgetActions
        delegate: MenuItem {
            required property var modelData
            text: modelData.text
            enabled: modelData.enabled
            visible: modelData.visible
            height: visible ? implicitHeight : 0
            onTriggered: modelData.trigger()
        }
        onObjectAdded: (index, object) => menu.insertItem(index, object)
        onObjectRemoved: (index, object) => menu.removeItem(object)
    }
}
