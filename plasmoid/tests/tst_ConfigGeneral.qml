pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import org.kde.kirigami as Kirigami

/**
 * @brief Smoke-tests the real Plasma configuration category without an applet host.
 *
 * This catches QML API regressions in the system-font, Adaptive/Plasma mode and
 * icon-theme controls before a package is copied into the live shell.
 */
Item {
    id: harness
    width: 720
    height: 1080

    /** @brief Real configuration surface used for deterministic visual review. */
    Rectangle {
        id: settingsSnapshotSurface
        width: 720
        height: 1080
        color: Kirigami.Theme.backgroundColor

        Loader {
            id: settingsPreview
            anchors.fill: parent
            source: "../package/contents/ui/configGeneral.qml"
        }
    }

    TestCase {
        name: "ConfigGeneral"

        function test_system_appearance_controls_load() {
            const component = Qt.createComponent("../package/contents/ui/configGeneral.qml")
            compare(component.status, Component.Ready, component.errorString())

            const settings = component.createObject(harness)
            verify(settings !== null, component.errorString())
            compare(settings.cfg_appearanceMode, "adaptive")
            verify(settings.cfg_useSystemNoteFont)
            verify(!settings.cfg_usePlasmaIconTheme)
            verify(settings.systemNoteFontSize >= 12)
            compare(settings.actionIconName("archive-insert"), "")
            compare(settings.paletteEntries.length, 8)

            settings.cfg_usePlasmaIconTheme = true
            compare(settings.actionIconName("archive-insert"), "archive-insert")
            compare(settings.actionIconSource("icons/text-aa.svg"), "")
            settings.destroy()
        }

        function test_export_system_appearance_snapshot() {
            tryVerify(function() { return settingsPreview.status === Loader.Ready }, 1000)
            wait(100)

            const rendered = grabImage(settingsSnapshotSurface)
            compare(rendered.width, settingsSnapshotSurface.width)
            compare(rendered.height, settingsSnapshotSurface.height)
            rendered.save("build/visual-snapshots/appearance-settings.png")
        }
    }
}
