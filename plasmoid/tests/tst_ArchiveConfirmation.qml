pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import "../package/contents/ui"

/**
 * @brief Exercises and captures the real archive confirmation component.
 *
 * The screenshot guards against a regression back to the native dark Dialog,
 * while the interaction checks keep cancel and destructive actions distinct.
 */
Item {
    id: harness
    width: 390
    height: 420

    Rectangle {
        anchors.fill: parent
        color: "#fce795"
    }

    ArchiveConfirmation {
        id: confirmation
        opened: true
        surfaceColor: "#fce795"
        inkColor: "#392f22"
        actionColor: "#667784"
        actionBorder: "#d3dce3"
    }

    SignalSpy {
        id: clearSpy
        target: confirmation
        signalName: "clearRequested"
    }

    TestCase {
        name: "ArchiveConfirmation"
        when: windowShown

        function init() {
            confirmation.open()
            clearSpy.clear()
            wait(180)
        }

        function test_cancel_is_non_destructive() {
            const cancelAction = findChild(confirmation, "cancelArchiveAction")
            verify(cancelAction)
            mouseClick(cancelAction, cancelAction.width / 2, cancelAction.height / 2)
            compare(clearSpy.count, 0)
            compare(confirmation.opened, false)
        }

        function test_clear_emits_once_and_closes() {
            const clearAction = findChild(confirmation, "clearArchiveAction")
            verify(clearAction)
            mouseClick(clearAction, clearAction.width / 2, clearAction.height / 2)
            compare(clearSpy.count, 1)
            compare(confirmation.opened, false)
        }

        function test_export_archive_confirmation_snapshot() {
            const rendered = grabImage(harness)
            compare(rendered.width, harness.width)
            compare(rendered.height, harness.height)
            rendered.save("build/visual-snapshots/archive-confirmation.png")
        }
    }
}
