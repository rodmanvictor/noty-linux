pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import org.kde.kirigami as Kirigami

/**
 * @brief Renders the local Plasma theme candidates used for the two semantic actions.
 *
 * The snapshot is intentionally kept next to the icon-system snapshot: a theme
 * can resolve the same FreeDesktop name to a very different visual at 16 px.
 */
Item {
    id: harness
    width: 760
    height: 260

    readonly property color iconColour: "#667784"
    readonly property var archiveCandidates: [
        "archive", "archive-insert", "archive-extract", "archive-remove", "document-preview-archive"
    ]
    readonly property var ruledPaperCandidates: [
        "view-list", "view-list-text", "view-list-details", "format-list-unordered", "view-list-tree"
    ]

    Rectangle {
        id: snapshotSurface
        width: parent.width
        height: parent.height
        radius: 14
        color: "#f5f6f7"

        Text {
            x: 20
            y: 16
            text: "Plasma theme · 5 candidates · 16 px"
            color: "#27323a"
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            x: 20
            y: 50
            text: "Archive"
            color: "#48555e"
            font.pixelSize: 12
            font.bold: true
        }

        Row {
            x: 20
            y: 72
            spacing: 14

            Repeater {
                model: harness.archiveCandidates

                delegate: Column {
                    id: archiveCandidate
                    required property string modelData
                    width: 126
                    spacing: 7

                    Rectangle {
                        width: 48
                        height: 48
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 12
                        color: "#fce795"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: parent.parent.modelData
                            color: harness.iconColour
                        }
                    }

                    Text {
                        width: parent.width
                        text: archiveCandidate.modelData
                        horizontalAlignment: Text.AlignHCenter
                        color: "#48555e"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Text {
            x: 20
            y: 152
            text: "Ruled paper"
            color: "#48555e"
            font.pixelSize: 12
            font.bold: true
        }

        Row {
            x: 20
            y: 174
            spacing: 14

            Repeater {
                model: harness.ruledPaperCandidates

                delegate: Column {
                    id: ruledPaperCandidate
                    required property string modelData
                    width: 126
                    spacing: 7

                    Rectangle {
                        width: 48
                        height: 48
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 12
                        color: "#b9daf5"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: parent.parent.modelData
                            color: harness.iconColour
                        }
                    }

                    Text {
                        width: parent.width
                        text: ruledPaperCandidate.modelData
                        horizontalAlignment: Text.AlignHCenter
                        color: "#48555e"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    TestCase {
        name: "PlasmaIconCandidates"
        when: windowShown

        function test_export_candidates_snapshot() {
            wait(100)
            const rendered = grabImage(snapshotSurface)
            compare(rendered.width, snapshotSurface.width)
            compare(rendered.height, snapshotSurface.height)
            rendered.save("build/visual-snapshots/plasma-icon-candidates.png")
        }
    }
}
