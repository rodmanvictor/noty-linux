import QtQuick
import QtQuick.Controls
import QtTest
import "../package/contents/ui"

/** @brief Checks widget actions remain usable from a narrow standalone deck. */
Item {
    id: harness
    width: 300
    height: 220

    QtObject {
        id: configureAction
        property string text: "Configure Noty"
        property bool enabled: true
        property bool visible: true
        property int calls: 0
        /** @brief Records activation without opening the real system configuration. */
        function trigger() { calls++ }
    }
    QtObject {
        id: removeAction
        property string text: "Remove Noty"
        property bool enabled: false
        property bool visible: true
        /** @brief A disabled action must never be activated by the test. */
        function trigger() { throw new Error("Disabled removal was activated") }
    }
    DeckContextMenu {
        id: menu
        widgetActions: [configureAction, removeAction]
    }

    Window {
        id: narrowWindow
        x: 200
        y: 100
        width: 58
        height: 480
        flags: Qt.FramelessWindowHint | Qt.Tool
        Item {
            id: narrowFan
            anchors.fill: parent
            DeckContextMenu {
                id: narrowMenu
                widgetActions: [configureAction, removeAction]
            }
        }
    }

    TestCase {
        name: "DeckContextMenu"
        when: windowShown

        /** @brief Verifies labels and permissions come from the supplied Plasma actions. */
        function test_action_contract() {
            compare(menu.count, 2)
            compare(menu.itemAt(0).text, "Configure Noty")
            compare(menu.itemAt(1).enabled, false)
            compare(menu.popupType, Popup.Window)
            compare(menu.margins, -1)
        }

        /** @brief Opens the real menu and activates its configuration entry with the mouse. */
        function test_open_and_configure() {
            menu.popupAt(harness, 20, 20)
            tryCompare(menu, "opened", true)
            waitForRendering(menu.contentItem)
            const rendered = grabImage(menu.contentItem)
            verify(rendered.width > 0)
            rendered.save("build/visual-snapshots/deck-context-menu.png")
            const item = menu.itemAt(0)
            mouseClick(item, item.width / 2, item.height / 2)
            compare(configureAction.calls, 1)
            tryCompare(menu, "visible", false)
        }

        /** @brief A menu wider than the fan must remain next to the clicked screen position. */
        function test_narrow_fan_position() {
            narrowWindow.show()
            tryCompare(narrowWindow, "visible", true)
            waitForRendering(narrowFan)
            const click = narrowFan.mapToGlobal(45, 120)
            narrowMenu.popupAt(narrowFan, 45, 120)
            tryCompare(narrowMenu, "opened", true)
            waitForRendering(narrowMenu.contentItem)
            compare(narrowMenu.parent, narrowMenu.clickAnchor)
            compare(narrowMenu.parent.width, 1)
            compare(narrowMenu.parent.height, 1)
            compare(narrowMenu.parent.mapToGlobal(0, 0), click)
            const actual = narrowMenu.contentItem.mapToGlobal(0, 0)
            const closeToClick = Math.abs(actual.x - click.x) < 20
                && Math.abs(actual.y - click.y) < 20
            narrowMenu.close()
            narrowWindow.hide()
            verify(closeToClick, "Click " + click + "; menu " + actual)
        }
    }
}
