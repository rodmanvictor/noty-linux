pragma ComponentBehavior: Bound

import QtQuick
import QtTest

/**
 * @brief Captures and measures the readable pastel-card baseline used by Noty and Adaptive.
 *
 * Adaptive deliberately keeps a palette entry's paired ink instead of placing
 * a light system text colour over a light paper colour. The source contract
 * verifies main.qml follows this rule; this snapshot makes the result reviewable.
 */
Item {
    id: harness
    width: 680
    height: 500

    readonly property color paper: "#beddfa"
    readonly property color ink: "#13293a"
    readonly property color spine: Qt.darker(paper, 1.14)

    Rectangle {
        anchors.fill: parent
        color: "#252525"
    }

    Rectangle {
        id: card
        x: 18
        y: 16
        width: parent.width - 36
        height: parent.height - 32
        radius: 14
        color: harness.paper

        Rectangle {
            width: 40
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: harness.spine

            Rectangle {
                anchors.right: parent.right
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Qt.darker(harness.paper, 1.34)
                opacity: 0.88
            }
        }

        Text {
            x: 64
            y: 26
            text: "Untitled note"
            color: harness.ink
            font.pixelSize: 16
            font.bold: true
        }

        Text {
            x: 64
            y: 72
            text: "A readable note remains calm on pastel paper."
            color: harness.ink
            font.pixelSize: 12
        }

        Rectangle {
            x: 64
            y: 108
            width: parent.width - 100
            height: 1
            color: Qt.darker(harness.paper, 1.32)
            opacity: 0.18
        }

        Row {
            x: 64
            y: parent.height - 42
            spacing: 8

            Repeater {
                model: ["#e0ad08", "#e2762a", "#dc4570", "#7c4dee", "#2280d6", "#0e9b6e"]
                delegate: Rectangle {
                    required property string modelData
                    width: 16
                    height: 16
                    radius: 8
                    color: modelData
                }
            }
        }
    }

    TestCase {
        name: "PastelCardContrast"
        when: windowShown

        /** @brief Converts an sRGB channel to relative luminance. */
        function linearChannel(value) {
            return value <= 0.04045 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4)
        }

        /** @brief Returns WCAG contrast ratio for the card paper and ink pair. */
        function contrastRatio(foreground, background) {
            const foregroundLuminance = 0.2126 * linearChannel(foreground.r)
                + 0.7152 * linearChannel(foreground.g) + 0.0722 * linearChannel(foreground.b)
            const backgroundLuminance = 0.2126 * linearChannel(background.r)
                + 0.7152 * linearChannel(background.g) + 0.0722 * linearChannel(background.b)
            return (Math.max(foregroundLuminance, backgroundLuminance) + 0.05)
                / (Math.min(foregroundLuminance, backgroundLuminance) + 0.05)
        }

        function test_pastel_card_uses_dark_paired_ink() {
            verify(contrastRatio(harness.ink, harness.paper) >= 4.5,
                "Adaptive paper and ink must retain readable body-text contrast")
        }

        function test_export_pastel_card_snapshot() {
            wait(100)
            const rendered = grabImage(harness)
            compare(rendered.width, harness.width)
            compare(rendered.height, harness.height)
            verify(rendered.red(400, 20) > 170 && rendered.blue(400, 20) > 200,
                "the card paper must remain visibly blue rather than a muted system overlay")
            rendered.save("build/visual-snapshots/pastel-card-contrast.png")
        }
    }
}
