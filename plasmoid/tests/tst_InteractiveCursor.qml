pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import "../package/contents/ui"

/**
 * @brief Verifies that the shared icon-button component exposes a hand cursor.
 *
 * Individual palette and edge hit zones are covered by the source contract;
 * this runtime check protects the reusable button used by the remaining icons.
 */
Item {
    id: harness
    width: 48
    height: 48

    NotyActionButton {
        id: actionButton
        anchors.fill: parent
        glyph: "x"
    }

    TestCase {
        name: "InteractiveCursor"
        when: windowShown

        function test_shared_icon_button_uses_pointing_hand() {
            const cursor = findChild(actionButton, "pointerCursor")
            verify(cursor)
            compare(cursor.cursorShape, Qt.PointingHandCursor)
        }
    }
}
