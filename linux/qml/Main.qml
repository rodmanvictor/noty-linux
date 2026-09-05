import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * @brief The edge-deck shell for the KDE port of Noty.
 *
 * It intentionally stays narrow while resting, fans its tabs when the pointer
 * enters the edge pill, and grows into an editor only after a tab is selected.
 * QML owns presentation; all note mutations are delegated to the C++ store.
 */
ApplicationWindow {
    id: window
    visible: true
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    title: "Noty"

    property int deckState: 0 // 0: pill, 1: fanned deck, 2: expanded editor
    property string selectedId: ""
    property var selectedNote: null
    readonly property var palette: [
        { paper: "#fce795", dash: "#e0ad08", ink: "#3a3008" },
        { paper: "#fbcfa6", dash: "#e2762a", ink: "#422413" },
        { paper: "#fac4d1", dash: "#dc4570", ink: "#40161f" },
        { paper: "#d9c7fa", dash: "#7c4dee", ink: "#2a1b44" },
        { paper: "#beddFA", dash: "#2280d6", ink: "#13293a" },
        { paper: "#b4e8d0", dash: "#0e9b6e", ink: "#0f2e23" },
        { paper: "#e3d3b4", dash: "#a37b3c", ink: "#372c18" },
        { paper: "#cbd6e2", dash: "#4e6579", ink: "#1a242e" }
    ]

    width: deckState === 0 ? 12 : deckState === 1 ? 76 : 540
    height: deckState === 0 ? 126 : deckState === 1 ? Math.min(550, Math.max(190, store.activeNotes.length * 72 + 64)) : 460
    function colour(index) {
        return palette[((index % palette.length) + palette.length) % palette.length]
    }

    function openNote(note) {
        selectedId = note.id
        selectedNote = note
        deckState = 2
    }

    function newNote() {
        const id = store.create("")
        for (const note of store.activeNotes) {
            if (note.id === id) {
                openNote(note)
                return
            }
        }
        deckState = 1
    }

    function closeEditor() {
        selectedId = ""
        selectedNote = null
        deckState = 1
    }

    /**
     * @brief Returns the entire interaction back to its edge pill.
     *
     * @sideeffect Clears the selected editor note and cancels pending idle work.
     * A focus dismissal is different from Esc: the source application's normal
     * click-away behaviour collapses the deck rather than leaving its tabs out.
     */
    function collapseToPill() {
        idleTimer.stop()
        selectedId = ""
        selectedNote = null
        deckState = 0
    }

    onActiveChanged: {
        if (!active && deckState !== 0 && !(selectedNote && selectedNote.pinned)
                && !captureDialog.visible && !libraryDialog.visible) {
            focusLossTimer.restart()
        } else if (active) {
            focusLossTimer.stop()
        }
    }

    Connections {
        target: appController
        function onNewNoteRequested() { window.newNote() }
        function onQuickCaptureRequested() { captureDialog.open() }
        function onAllNotesRequested() { libraryDialog.showArchive = false; libraryDialog.open() }
        function onArchiveRequested() { libraryDialog.showArchive = true; libraryDialog.open() }
        function onQuitRequested() { Qt.quit() }
    }

    Timer {
        id: idleTimer
        interval: 4000
        repeat: false
        onTriggered: if (window.deckState === 1) window.deckState = 0
    }

    Timer {
        // A click that opens a tab can briefly flip focus while XWayland hands
        // the event over. Waiting one short interval distinguishes it from a
        // genuine click in another application.
        id: focusLossTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (!window.active && window.deckState !== 0
                    && !(window.selectedNote && window.selectedNote.pinned)
                    && !captureDialog.visible && !libraryDialog.visible) {
                window.collapseToPill()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            id: pillArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: window.deckState === 0
            onEntered: window.deckState = 1
        }

        Rectangle {
            visible: window.deckState === 0
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: Math.min(112, Math.max(20, store.activeNotes.length * 10 + 8))
            radius: 6
            color: "#1d1d20"
            opacity: 0.94
            Column {
                anchors.centerIn: parent
                spacing: 3
                Repeater {
                    model: store.activeNotes.slice(0, 8)
                    Rectangle {
                        required property var modelData
                        width: 6
                        height: 6
                        radius: 3
                        color: window.colour(modelData.color).dash
                    }
                }
            }
        }

        Item {
            // The edge deck always keeps its own narrow footprint. When an
            // editor is open, stretching this item to the editor width would
            // turn a vertical tab into a floating card.
            visible: window.deckState !== 0
            anchors.right: parent.right
            anchors.top: parent.top
            width: 56
            height: parent.height

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: idleTimer.stop()
                onExited: idleTimer.restart()
            }

            Column {
                anchors.right: parent.right
                anchors.top: parent.top
                width: parent.width
                spacing: -20
                Repeater {
                    model: store.activeNotes.slice(0, 5)
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: parent.width
                        height: 86
                        radius: 10
                        color: window.colour(modelData.color).paper
                        border.color: "#33202020"
                        z: 8 - index
                        rotation: -1.5 + index * 0.7

                        Text {
                            anchors.centerIn: parent
                            width: 72
                            rotation: -90
                            text: modelData.pinned ? "• " + modelData.title : modelData.title
                            color: window.colour(modelData.color).ink
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: window.openNote(modelData)
                        }
                    }
                }
                Rectangle {
                    visible: store.activeNotes.length > 5
                    width: parent.width
                    height: 38
                    radius: 9
                    color: "#28282c"
                    Text { anchors.centerIn: parent; text: "+" + (store.activeNotes.length - 5); color: "white"; font.bold: true }
                    MouseArea { anchors.fill: parent; onClicked: { libraryDialog.showArchive = false; libraryDialog.open() } }
                }
                Button {
                    width: parent.width
                    text: "+"
                    font.pixelSize: 22
                    onClicked: window.newNote()
                }
            }
        }

        Rectangle {
            visible: window.deckState === 2 && window.selectedNote !== null
            anchors.fill: parent
            radius: 16
            color: window.selectedNote ? window.colour(window.selectedNote.color).paper : "white"
            border.color: "#33202020"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12
                Item {
                    // The selected tab stays attached to the sheet as a quiet
                    // gutter, matching the original note-pulled-from-deck cue.
                    Layout.fillHeight: true
                    Layout.preferredWidth: 30
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: window.selectedNote ? window.colour(window.selectedNote.color).dash : "transparent"
                        opacity: 0.20
                    }
                    Text {
                        anchors.centerIn: parent
                        width: parent.height - 42
                        rotation: 90
                        text: window.selectedNote ? window.selectedNote.title.toUpperCase() : ""
                        color: window.selectedNote ? window.colour(window.selectedNote.color).ink : "black"
                        opacity: 0.68
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Column {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        Repeater {
                            model: Math.floor(parent.height / 7)
                            Rectangle {
                                width: 1
                                height: 3
                                color: window.selectedNote ? window.colour(window.selectedNote.color).ink : "black"
                                opacity: 0.22
                            }
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    RowLayout {
                        Layout.fillWidth: true
                        Label { text: window.selectedNote ? window.selectedNote.title : ""; font.bold: true; color: window.selectedNote ? window.colour(window.selectedNote.color).ink : "black"; Layout.fillWidth: true; elide: Text.ElideRight }
                        ToolButton { text: "●"; onClicked: { store.cycleColor(window.selectedId); window.selectedNote = store.allNotes.find(note => note.id === window.selectedId) } }
                        ToolButton { text: window.selectedNote && window.selectedNote.pinned ? "⌖" : "⌖"; onClicked: { store.togglePinned(window.selectedId); window.selectedNote = store.allNotes.find(note => note.id === window.selectedId) } }
                        ToolButton { text: "↥"; onClicked: { store.setArchived(window.selectedId, true); window.closeEditor() } }
                        ToolButton { text: "×"; onClicked: window.closeEditor() }
                    }
                    TextArea {
                        id: editor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: window.selectedNote ? window.selectedNote.body : ""
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                        color: window.selectedNote ? window.colour(window.selectedNote.color).ink : "black"
                        font.pixelSize: 16
                        background: Rectangle { color: "transparent" }
                        onTextChanged: if (window.selectedId !== "") store.updateBody(window.selectedId, text)
                        Keys.onEscapePressed: window.closeEditor()
                    }
                    Label { text: "Автосохранение включено"; font.pixelSize: 11; opacity: 0.55; color: window.selectedNote ? window.colour(window.selectedNote.color).ink : "black" }
                }
            }
        }
    }

    Dialog {
        id: captureDialog
        title: "Быстрая заметка"
        modal: false
        x: window.screen ? window.screen.virtualX + (window.screen.desktopAvailableWidth - width) / 2 : 0
        y: window.screen ? window.screen.virtualY + window.screen.desktopAvailableHeight * 0.55 - height / 2 : 0
        width: 470
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: { if (captureText.text.trim().length > 0) store.create(captureText.text); captureText.text = "" }
        onOpened: captureText.forceActiveFocus()
        contentItem: TextArea { id: captureText; placeholderText: "Напишите заметку…"; wrapMode: TextEdit.Wrap; implicitHeight: 120 }
    }

    Dialog {
        id: libraryDialog
        property bool showArchive: false
        title: showArchive ? "Архив" : "Все заметки"
        width: 680
        height: 500
        x: window.screen ? window.screen.virtualX + (window.screen.desktopAvailableWidth - width) / 2 : 0
        y: window.screen ? window.screen.virtualY + (window.screen.desktopAvailableHeight - height) / 2 : 0
        standardButtons: Dialog.Close
        contentItem: ColumnLayout {
            anchors.fill: parent
            TextField { id: filter; Layout.fillWidth: true; placeholderText: "Поиск по заметкам" }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                model: libraryDialog.showArchive ? store.archivedNotes : store.activeNotes
                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: 72
                    radius: 10
                    color: window.colour(modelData.color).paper
                    visible: filter.text.length === 0 || (modelData.title + "\n" + modelData.body).toLowerCase().includes(filter.text.toLowerCase())
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10
                        Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 5; radius: 3; color: window.colour(modelData.color).dash }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Label {
                                text: modelData.title
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Label {
                                text: modelData.body.replace(/\n/g, " ")
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                opacity: 0.65
                            }
                        }
                        Button { text: libraryDialog.showArchive ? "Вернуть" : "Открыть"; onClicked: { if (libraryDialog.showArchive) store.setArchived(modelData.id, false); else { libraryDialog.close(); window.openNote(modelData) } } }
                    }
                }
            }
        }
    }
}
