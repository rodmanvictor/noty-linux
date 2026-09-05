pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import "../package/contents/ui"

/**
 * @brief Verifies that bundled action assets become real rendered icons.
 *
 * Source-level filename checks cannot detect a renderer that colours the whole
 * SVG texture instead of the glyph. This test waits for the decoded source,
 * verifies its size and samples both an opaque X pixel and a transparent corner.
 */
Item {
    id: harness
    width: 664
    height: 176
    readonly property color systemIconColour: "#667784"
    readonly property var systemGlyphs: [
        "plus", "plus-circle", "archive", "folder-open", "arrow-counter-clockwise",
        "trash-simple", "check-square", "text-b", "text-italic", "text-aa",
        "palette", "quotes", "list", "x"
    ]

    Rectangle {
        id: snapshotSurface
        width: 620
        height: 176
        radius: 12
        color: "#f5f6f7"

        Text {
            x: 14
            y: 10
            text: "Noty · Phosphor Regular · actions 16 · add 22"
            color: "#27323a"
            font.pixelSize: 12
            font.bold: true
        }

        Flow {
            x: 12
            y: 34
            width: parent.width - 24
            spacing: 4

            Repeater {
                id: iconRepeater
                model: harness.systemGlyphs

                delegate: Item {
                    id: iconCell
                    required property string modelData
                    required property int index
                    property alias icon: previewIcon
                    width: 81
                    height: 64

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 32
                        height: 32
                        radius: 16
                        color: iconCell.index % 2 === 0 ? "#fce795" : "#b9daf5"

                        NotyIcon {
                            id: previewIcon
                            anchors.centerIn: parent
                            width: iconCell.modelData === "plus" || iconCell.modelData === "plus-circle" ? 22 : 16
                            height: width
                            glyph: iconCell.modelData
                            color: harness.systemIconColour
                        }
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 36
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 4
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: iconCell.modelData
                        color: "#48555e"
                        font.pixelSize: 8
                    }
                }
            }
        }
    }

    Rectangle {
        id: iconSurface
        x: 632
        y: 0
        width: 24
        height: 24
        color: "#ff00ff"

        NotyIcon {
            id: closeIcon
            anchors.fill: parent
            glyph: "x"
            color: harness.systemIconColour
        }
    }

    NotyIcon {
        id: themedArchiveIcon
        x: 632
        y: 40
        width: 24
        height: 24
        glyph: "archive"
        color: harness.systemIconColour
        usePlasmaIconTheme: true
    }

    NotyIcon {
        id: themedRuledPaperIcon
        x: 632
        y: 72
        width: 24
        height: 24
        glyph: "list"
        color: harness.systemIconColour
        usePlasmaIconTheme: true
    }

    NotyIcon {
        id: archiveOpticalIcon
        x: 632
        y: 104
        width: 16
        height: 16
        glyph: "archive"
        color: harness.systemIconColour
    }

    TestCase {
        name: "NotyIcon"
        when: windowShown

        function test_local_phosphor_svg_is_rendered() {
            tryVerify(function() { return closeIcon.valid }, 1000)
            verify(closeIcon.paintedWidth > 0)
            verify(closeIcon.paintedHeight > 0)
            wait(100)

            const rendered = grabImage(iconSurface)
            verify(rendered.green(12, 12) > rendered.red(12, 12),
                "the X centre must receive its blue-grey tint; got " + rendered.red(12, 12) + "," + rendered.green(12, 12) + "," + rendered.blue(12, 12))
            verify(rendered.red(1, 1) > 240 && rendered.blue(1, 1) > 240 && rendered.green(1, 1) < 20,
                "the transparent SVG corner must preserve the magenta test surface instead of becoming a square")
        }

        function test_export_icon_system_snapshot() {
            compare(iconRepeater.count, harness.systemGlyphs.length)
            wait(100)

            const rendered = grabImage(snapshotSurface)
            compare(rendered.width, snapshotSurface.width)
            compare(rendered.height, snapshotSurface.height)
            rendered.save("build/visual-snapshots/icon-system.png")
        }

        function test_plasma_icon_mapping_keeps_noty_semantics() {
            compare(themedArchiveIcon.plasmaIconName, "archive")
            compare(themedRuledPaperIcon.plasmaIconName, "view-list-text")
            verify(themedArchiveIcon.valid,
                "the bundled vector remains a safe fallback for the themed archive action")
        }

        function test_archive_uses_optical_correction_inside_the_same_hit_grid() {
            compare(archiveOpticalIcon.width, 16)
            compare(archiveOpticalIcon.height, 16)
            compare(archiveOpticalIcon.opticalScale, 1.16)
        }
    }
}
