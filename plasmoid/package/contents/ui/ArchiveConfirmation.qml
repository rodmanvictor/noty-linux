import QtQuick

import "I18n.js" as I18n

/**
 * @brief Compact, theme-independent confirmation for clearing the note archive.
 *
 * The overlay inherits the note surface colours supplied by its parent instead
 * of opening a native dialog with an unrelated Plasma colour scheme. It blocks
 * archive interaction while open and emits one explicit destructive action.
 */
Item {
    id: control

    /** @brief Whether the confirmation can be seen and interacted with. */
    property bool opened: false
    /** @brief Current interface language inherited from the parent widget. */
    property string language: ""
    /** @brief Legacy compatibility switch for isolated tests and older callers. */
    property bool russian: false
    /** @brief Paper colour inherited from the archive surface. */
    property color surfaceColor: "#fce795"
    /** @brief Primary text colour inherited from the first palette entry. */
    property color inkColor: "#392f22"
    /** @brief Shared neutral action colour from the Noty icon system. */
    property color actionColor: "#667784"
    /** @brief Shared subtle outline colour from the Noty icon system. */
    property color actionBorder: "#d3dce3"
    /** @brief Opt-in for resolving action glyphs through Plasma's icon theme. */
    property bool usePlasmaIconTheme: false
    /** @brief Typeface selected for all notes. */
    property string fontFamily: "sans-serif"

    /** @brief Emitted after the user confirms permanent archive removal. */
    signal clearRequested()

    /**
     * @brief Resolves confirmation copy through the shared widget dictionary.
     * @param {string} english English source string and translation key.
     * @param {string} russian Russian fallback retained for compatibility.
     * @returns {string} Localized confirmation text.
     */
    function text(english, russian) {
        return I18n.text(language || (russian ? "ru" : "en"), english, russian)
    }

    anchors.fill: parent
    visible: opacity > 0
    enabled: opened
    opacity: opened ? 1 : 0

    /** @brief Shows the confirmation layer. */
    function open() {
        opened = true
    }

    /** @brief Hides the confirmation without modifying notes. */
    function close() {
        opened = false
    }

    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.10, 0.13, 0.16, 0.2)

        MouseArea {
            anchors.fill: parent
            onClicked: control.close()
        }
    }

    Rectangle {
        id: confirmationCard
        anchors.centerIn: parent
        width: Math.min(312, parent.width - 32)
        height: 164
        radius: 14
        color: Qt.lighter(control.surfaceColor, 1.035)
        border.width: 1
        border.color: Qt.darker(control.surfaceColor, 1.2)
        scale: control.opened ? 1 : 0.96

        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

        MouseArea {
            anchors.fill: parent
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.right: confirmationCloseButton.left
            anchors.rightMargin: 8
            text: control.text("Clear archive?", "Очистить архив?")
            color: control.inkColor
            font.family: control.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        NotyActionButton {
            id: confirmationCloseButton
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8
            width: 28
            height: 28
            focusPolicy: Qt.NoFocus
            onClicked: control.close()
            Accessible.name: control.text("Cancel", "Отмена")
            glyph: "x"
            glyphSize: 16
            glyphColor: control.actionColor
            outlineColor: control.actionBorder
            usePlasmaIconTheme: control.usePlasmaIconTheme
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.top: parent.top
            anchors.topMargin: 52
            wrapMode: Text.Wrap
            text: control.text(
                "All archived notes will be deleted permanently.",
                "Все архивированные заметки будут удалены без возможности восстановления."
            )
            color: control.inkColor
            opacity: 0.66
            font.family: control.fontFamily
            font.pixelSize: 11
            lineHeight: 1.15
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
            spacing: 8

            Rectangle {
                width: 76
                height: 32
                radius: 16
                color: cancelArea.containsMouse ? Qt.rgba(1, 1, 1, 0.38) : "transparent"
                border.width: 1
                border.color: control.actionBorder

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: control.text("Cancel", "Отмена")
                    color: control.inkColor
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: cancelArea
                    objectName: "cancelArchiveAction"
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: control.close()
                }
            }

            Rectangle {
                width: 116
                height: 32
                radius: 16
                color: clearAllArea.containsMouse
                    ? Qt.lighter(control.actionColor, 1.12)
                    : control.actionColor

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: control.text("Clear archive", "Очистить архив")
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: clearAllArea
                    objectName: "clearArchiveAction"
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        control.clearRequested()
                        control.close()
                    }
                }
            }
        }
    }
}
