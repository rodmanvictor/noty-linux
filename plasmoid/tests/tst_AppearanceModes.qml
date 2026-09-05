pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import "../package/contents/ui/PaletteContract.js" as PaletteContract

/**
 * @brief Renders selected-note and archive surfaces for every appearance mode.
 *
 * The gallery intentionally uses a dark desktop surrounding surface and a
 * white Plasma text colour. That is the failure case that previously replaced
 * all note papers with a near-black system background. It verifies the card,
 * archive and their text remain distinct in Noty, Adaptive and Plasma modes.
 */
Item {
    id: harness
    width: 1080
    height: 500

    readonly property var palette: PaletteContract.fromJson("")
    /** @brief Simulated dark-theme text colour used by Plasma's contrast guard. */
    readonly property color darkThemeText: "#f5f5f5"

    /**
     * @brief Resolves the paper/ink pair that main.qml uses for a preview mode.
     * @param {string} mode Noty, Adaptive or Plasma display mode.
     * @param {number} index Stored palette index.
     * @returns {{paper: string, ink: string, dash: string}} Readable preview entry.
     */
    function entryFor(mode, index) {
        const entry = palette[index]
        return {
            paper: entry.paper,
            ink: mode === "plasma"
                ? PaletteContract.readableInk(entry.paper, darkThemeText.toString(), entry.ink)
                : entry.ink,
            dash: entry.dash
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#20242a"
    }

    Row {
        anchors.centerIn: parent
        spacing: 16

        Repeater {
            model: ["noty", "adaptive", "plasma"]

            delegate: Item {
                required property string modelData
                width: 340
                height: 462
                readonly property var selectedEntry: harness.entryFor(modelData, 4)
                readonly property var archiveEntry: harness.entryFor(modelData, 0)

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: parent.modelData === "noty" ? "Noty"
                        : parent.modelData === "adaptive" ? "Adaptive" : "Plasma"
                    color: "#e7edf2"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    id: noteCard
                    anchors.top: parent.top
                    anchors.topMargin: 28
                    width: parent.width
                    height: 224
                    radius: 14
                    color: parent.selectedEntry.paper
                    border.width: 1
                    border.color: Qt.darker(color, 1.08)

                    Rectangle {
                        width: 34
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        radius: 14
                        color: Qt.darker(noteCard.color, 1.14)
                    }

                    Text {
                        x: 54
                        y: 22
                        text: "Selected note"
                        color: parent.parent.selectedEntry.ink
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }
                    Text {
                        x: 54
                        y: 58
                        text: "Paper remains coloured\nin every appearance mode."
                        color: parent.parent.selectedEntry.ink
                        font.pixelSize: 12
                        lineHeight: 1.25
                    }
                    Rectangle {
                        x: 54
                        y: 113
                        width: parent.width - 72
                        height: 1
                        color: Qt.darker(noteCard.color, 1.32)
                        opacity: 0.25
                    }
                    Text {
                        x: 54
                        y: 176
                        text: "Archive  •  Lines  •  Close"
                        color: parent.parent.selectedEntry.ink
                        opacity: 0.7
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    id: archiveDrawer
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 192
                    radius: 14
                    color: parent.archiveEntry.paper
                    border.width: 1
                    border.color: Qt.darker(color, 1.12)

                    Text {
                        x: 14
                        y: 12
                        text: "Archive"
                        color: parent.parent.archiveEntry.ink
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    Text {
                        x: 14
                        y: 31
                        text: "Saved notes stay readable"
                        color: parent.parent.archiveEntry.ink
                        opacity: 0.6
                        font.pixelSize: 10
                    }

                    Repeater {
                        model: [2, 5]
                        delegate: Rectangle {
                            required property int modelData
                            required property int index
                            x: 10
                            y: 57 + index * 58
                            width: parent.width - 20
                            height: 50
                            radius: 9
                            color: Qt.lighter(archiveDrawer.color, 1.035)

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                color: harness.entryFor(parent.parent.parent.modelData, modelData).paper
                            }
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 31
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Archived note"
                                color: parent.parent.parent.archiveEntry.ink
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }
        }
    }

    TestCase {
        name: "AppearanceModes"
        when: windowShown

        function test_every_mode_preserves_note_paper_and_readable_ink() {
            const modes = ["noty", "adaptive", "plasma"]
            for (let index = 0; index < modes.length; index += 1) {
                const entry = harness.entryFor(modes[index], 4)
                compare(entry.paper, harness.palette[4].paper)
                verify(PaletteContract.contrastRatio(entry.paper, entry.ink) >= 4.5)
            }
        }

        function test_export_selected_note_and_archive_for_all_modes() {
            wait(100)
            const rendered = grabImage(harness)
            compare(rendered.width, harness.width)
            compare(rendered.height, harness.height)
            // The third preview is Plasma. Its selected blue card must not be black.
            verify(rendered.red(790, 70) > 150 && rendered.blue(790, 70) > 200,
                "Plasma selected-note paper must remain visibly blue on a dark theme")
            // The Plasma archive uses the default yellow paper rather than the dark desktop background.
            verify(rendered.red(1035, 330) > 220 && rendered.green(1035, 330) > 180,
                "Plasma archive must remain visibly yellow and readable")
            rendered.save("build/visual-snapshots/appearance-modes.png")
        }
    }
}
