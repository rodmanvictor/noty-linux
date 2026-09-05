import QtQuick
import QtQuick.Controls

import "EditorContract.js" as EditorContract

/**
 * @brief A compact, native Qt Markdown editor with Notion-like block affordances.
 *
 * Qt's `TextArea` remains the document engine: it owns selection, keyboard input,
 * Markdown persistence, and formatted rendering. This component adds only three
 * presentation layers that Qt does not expose for QML customization: a selection
 * bubble, rounded task controls, and the visual rule for quote blocks.
 *
 * @property noteId Stable identifier of the currently open note.
 * @property markdown Markdown value stored by the caller.
 * @property paperColor Current note paper used to cover Qt's stock task marker.
 * @property inkColor Readable text and control colour for the current note.
 * @property selectionColor Current theme selection fill.
 * @property usePlasmaIconTheme Whether semantic icons resolve through Plasma.
 * @signal markdownEdited Emitted only after the Qt document changes through input
 *     or formatting.
 * @signal checklistToggled Requests a Markdown task mutation from the note store.
 */
Item {
    id: control

    property string noteId: ""
    property string markdown: ""
    property color paperColor: "#fff4c7"
    property color inkColor: "#27323a"
    property color selectionColor: Qt.rgba(0.16, 0.14, 0.11, 0.22)
    property color actionIconColor: "#667784"
    property color actionIconOnDarkColor: "#c8d1d8"
    property color actionIconBorder: "#d3dce3"
    property string noteFontFamily: "Noto Sans"
    property int noteFontSize: 12
    property bool ruled: false
    property bool usePlasmaIconTheme: false
    property string placeholderText: "Start writing…"
    property string boldText: "Bold"
    property string italicText: "Italic"
    property string quoteText: "Quote"
    property string checklistText: "Checklist"
    property string toggleTaskPrefix: "Toggle task: "

    /** @brief Exposes the stock Qt document for focused tests and accessibility tooling. */
    property alias textEditor: editor
    /** @brief Exposes the number of custom rounded controls, not the Markdown source. */
    readonly property int taskControlCount: editor.renderedChecklistEntries.length
    /** @brief Reports whether the contextual bubble is visible for an actual selection. */
    readonly property bool bubbleVisible: formatBubble.hasSelection

    signal markdownEdited(string markdown)
    signal checklistToggled(int taskIndex)

    clip: true

    /**
     * @brief Loads the caller-owned Markdown into Qt without echoing a save signal.
     * @param forceReload Reloads even when the note identity is unchanged.
     * @returns {void}
     * @sideeffect Replaces the in-memory QTextDocument.
     */
    function loadMarkdown(forceReload) {
        if (!forceReload && editor.loadedNoteId === noteId && editor.text === markdown) {
            return
        }
        editor.loadingStoredText = true
        editor.text = markdown
        editor.loadedNoteId = noteId
        editor.loadingStoredText = false
    }

    /**
     * @brief Converts complete selected visual paragraphs into one Markdown block type.
     * @param marker Markdown prefix for a quote or unchecked task row.
     * @returns {void}
     * @sideeffect Replaces only the selected paragraphs in Qt's document.
     */
    function applyBlockMarker(marker) {
        if (editor.selectedText.length === 0) {
            return
        }
        const plainText = editor.getText(0, editor.length)
        const range = EditorContract.visualBlockRange(plainText, editor.selectionStart, editor.selectionEnd)
        const renderedMarkdown = editor.getFormattedText(range.start, range.end)
        const replacement = EditorContract.withBlockMarker(renderedMarkdown, marker)
        if (replacement.length === 0) {
            return
        }
        editor.forceActiveFocus()
        editor.remove(range.start, range.end)
        editor.insert(range.start, replacement)
    }

    /** @brief Applies a quote before the action button consumes the selection. */
    function applyQuoteOnPress() {
        if (!quoteAction.enabled) {
            return
        }
        quoteAction.appliedOnPress = true
        applyBlockMarker("> ")
    }

    /** @brief Applies a checklist before the action button consumes the selection. */
    function applyChecklistOnPress() {
        if (!checklistAction.enabled) {
            return
        }
        checklistAction.appliedOnPress = true
        applyBlockMarker("- [ ] ")
    }

    /**
     * @brief Applies Qt's bold action to the current selection.
     * @returns {void}
     * @sideeffect Changes the underlying Markdown document when text is selected.
     */
    function applyBold() {
        if (boldAction.enabled) {
            boldAction.trigger()
        }
    }

    /**
     * @brief Applies Qt's italic action to the current selection.
     * @returns {void}
     * @sideeffect Changes the underlying Markdown document when text is selected.
     */
    function applyItalic() {
        if (italicAction.enabled) {
            italicAction.trigger()
        }
    }

    /**
     * @brief Converts the selected visual paragraph or paragraphs into a quote.
     * @returns {void}
     * @sideeffect Inserts the standard Markdown quote marker into Qt's document.
     */
    function quoteSelection() {
        applyBlockMarker("> ")
    }

    /**
     * @brief Converts the selected visual paragraph or paragraphs into tasks.
     * @returns {void}
     * @sideeffect Inserts the standard unchecked Markdown task marker into Qt's document.
     */
    function checklistSelection() {
        applyBlockMarker("- [ ] ")
    }

    /**
     * @brief Forwards a custom task-control activation to the caller's note store.
     * @param taskIndex Zero-based index among rendered Markdown task rows.
     * @returns {void}
     * @sideeffect Emits a task-toggle intent without mutating a second task model.
     */
    function requestChecklistToggle(taskIndex) {
        checklistToggled(taskIndex)
    }

    onNoteIdChanged: loadMarkdown(true)
    onMarkdownChanged: {
        if (!editor.loadingStoredText && editor.text !== markdown) {
            loadMarkdown(true)
        }
    }
    Component.onCompleted: loadMarkdown(true)

    /** @brief Optional notebook guides sit below the document and never catch input. */
    Item {
        id: ruledPaper
        anchors.fill: parent
        visible: control.ruled
        clip: true

        Repeater {
            model: Math.ceil(ruledPaper.height / 28)
            delegate: Rectangle {
                required property int index
                x: 0
                y: 24 + index * 28
                width: ruledPaper.width
                height: 1
                color: Qt.darker(control.paperColor, 1.32)
                opacity: 0.18
            }
        }
    }

    /**
     * @brief Qt's official Markdown document and selection implementation.
     *
     * GitHub task-list source is preserved in `text`, while the rendered surface
     * hides markers and stays fully editable with Qt's input, undo, and IME paths.
     */
    TextArea {
        id: editor
        anchors.fill: parent
        z: 1
        textFormat: TextEdit.MarkdownText
        wrapMode: TextEdit.Wrap
        selectByMouse: true
        selectByKeyboard: true
        persistentSelection: true
        font.pixelSize: control.noteFontSize
        font.family: control.noteFontFamily
        leftPadding: 0
        rightPadding: 0
        topPadding: 8
        bottomPadding: 8
        placeholderText: control.placeholderText
        color: control.inkColor
        selectionColor: control.selectionColor
        selectedTextColor: color
        background: Rectangle { color: "transparent" }

        /** @brief Guards caller persistence while a new note body is loaded. */
        property bool loadingStoredText: false
        /** @brief Identity whose body is currently resident in the QTextDocument. */
        property string loadedNoteId: ""
        /**
         * @brief Invalidates overlay geometry after Qt finishes a document layout pass.
         *
         * `positionToRectangle()` is a method rather than a notifying property;
         * without this revision, a delegate created while the document is still
         * laying out can retain its provisional (and wrong) coordinates.
         */
        property int documentLayoutRevision: 0
        /** @brief Markdown rows positioned against the rendered Qt document. */
        readonly property var renderedChecklistEntries: EditorContract.checklistEntries(
            text,
            getText(0, length)
        )
        /** @brief Quote rows positioned against the rendered Qt document. */
        readonly property var renderedQuoteEntries: EditorContract.quoteEntries(
            text,
            getText(0, length)
        )

        onTextChanged: {
            if (!loadingStoredText && loadedNoteId === control.noteId) {
                control.markdownEdited(text)
            }
        }
        onContentHeightChanged: documentLayoutRevision += 1
    }

    /**
     * @brief Quiet vertical rules that make Qt's quote blocks read as actual blocks.
     *
     * The overlay is visual only; input and Markdown structure remain owned by the
     * TextArea underneath it.
     */
    Item {
        anchors.fill: parent
        clip: true
        z: 4

        Repeater {
            model: editor.renderedQuoteEntries

            delegate: Rectangle {
                required property var modelData
                /** @brief Scalars avoid stale QRect bindings after a TextArea selection moves. */
                readonly property real textX: {
                    editor.documentLayoutRevision
                    return editor.positionToRectangle(modelData.position).x
                }
                readonly property real textY: {
                    editor.documentLayoutRevision
                    return editor.positionToRectangle(modelData.position).y
                }
                readonly property real textHeight: {
                    editor.documentLayoutRevision
                    return editor.positionToRectangle(modelData.position).height
                }
                x: Math.max(1, textX - 12)
                y: textY + 1
                width: 3
                height: Math.max(16, textHeight - 2)
                radius: 2
                color: Qt.darker(control.inkColor, 1.14)
                opacity: 0.52
                visible: y + height >= 0 && y <= parent.height
            }
        }
    }

    /**
     * @brief Rounded Notion-like controls that cover Qt's fixed square markers.
     *
     * The controls deliberately do not own a second task model: every toggle is
     * requested from the caller, which changes the same Markdown source that Qt
     * renders. Their larger hit target works with mouse, keyboard and assistive
     * technology.
     */
    Item {
        anchors.fill: parent
        clip: true
        z: 8

        Repeater {
            model: editor.renderedChecklistEntries

            delegate: FocusScope {
                id: taskBlock
                required property var modelData
                objectName: "notionTaskBlock-" + modelData.taskIndex
                /** @brief Scalar coordinates keep task controls in the TextArea's visual line. */
                readonly property real textX: {
                    editor.documentLayoutRevision
                    return editor.positionToRectangle(taskBlock.modelData.position).x
                }
                readonly property real textY: {
                    editor.documentLayoutRevision
                    return editor.positionToRectangle(taskBlock.modelData.position).y
                }
                readonly property real textHeight: {
                    editor.documentLayoutRevision
                    return editor.positionToRectangle(taskBlock.modelData.position).height
                }
                /** @brief Stable row height used by both the control and its vertical centring. */
                readonly property real rowHeight: Math.max(22, textHeight + 4)
                x: Math.max(0, textX - 40)
                y: textY - Math.max(1, (rowHeight - textHeight) / 2)
                width: 36
                height: rowHeight
                activeFocusOnTab: true
                visible: y + height >= 0 && y <= parent.height
                Accessible.role: Accessible.CheckBox
                Accessible.name: control.toggleTaskPrefix + taskBlock.modelData.label
                Accessible.checked: taskBlock.modelData.checked
                Accessible.onPressAction: control.requestChecklistToggle(taskBlock.modelData.taskIndex)

                /** @brief Covers only the Qt-owned stock marker, never its label. */
                Rectangle {
                    anchors.fill: parent
                    color: control.paperColor
                }

                /** @brief Notion-like rounded-square visual and full 36 px target. */
                Rectangle {
                    id: taskToggle
                    width: 19
                    height: 19
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 5
                    color: taskBlock.modelData.checked ? control.inkColor : "transparent"
                    border.width: taskBlock.activeFocus ? 2 : 1
                    border.color: control.inkColor
                    scale: taskPointer.containsMouse ? 1.08 : 1

                    Behavior on color { ColorAnimation { duration: 130 } }
                    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

                    NotyIcon {
                        anchors.centerIn: parent
                        width: 11
                        height: 11
                        visible: taskBlock.modelData.checked
                        glyph: "check-square"
                        color: control.actionIconOnDarkColor
                        usePlasmaIconTheme: control.usePlasmaIconTheme
                    }
                }

                MouseArea {
                    id: taskPointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: taskBlock.forceActiveFocus()
                    onClicked: control.requestChecklistToggle(taskBlock.modelData.taskIndex)
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        control.requestChecklistToggle(taskBlock.modelData.taskIndex)
                        event.accepted = true
                    }
                }
            }
        }
    }

    /** @brief Qt's official cursorSelection pattern for bold text. */
    Action {
        id: boldAction
        text: control.boldText
        enabled: editor.selectedText.length > 0
        checkable: true
        checked: editor.cursorSelection.font.bold
        onTriggered: {
            editor.cursorSelection.font.bold = checked
            editor.forceActiveFocus()
        }
    }

    /** @brief Qt's official cursorSelection pattern for italic text. */
    Action {
        id: italicAction
        text: control.italicText
        enabled: editor.selectedText.length > 0
        checkable: true
        checked: editor.cursorSelection.font.italic
        onTriggered: {
            editor.cursorSelection.font.italic = checked
            editor.forceActiveFocus()
        }
    }

    /** @brief Creates a Markdown quote from the selected rendered paragraphs. */
    Action {
        id: quoteAction
        property bool appliedOnPress: false
        text: control.quoteText
        enabled: editor.selectedText.length > 0
        onTriggered: {
            if (!appliedOnPress) {
                control.applyBlockMarker("> ")
            }
            appliedOnPress = false
        }
    }

    /** @brief Creates Markdown task rows from the selected rendered paragraphs. */
    Action {
        id: checklistAction
        property bool appliedOnPress: false
        text: control.checklistText
        enabled: editor.selectedText.length > 0
        onTriggered: {
            if (!appliedOnPress) {
                control.applyBlockMarker("- [ ] ")
            }
            appliedOnPress = false
        }
    }

    /**
     * @brief A transient bubble anchored to selection, never hover or caret focus.
     *
     * It deliberately contains only the four document actions supported by the
     * current Markdown contract, so a small note keeps its writing area quiet.
     */
    Rectangle {
        id: formatBubble
        readonly property rect anchorRect: {
            editor.documentLayoutRevision
            return editor.positionToRectangle(editor.selectionStart)
        }
        readonly property bool hasSelection: editor.selectedText.length > 0
        visible: opacity > 0
        enabled: hasSelection
        opacity: hasSelection ? 1 : 0
        scale: hasSelection ? 1 : 0.94
        x: Math.max(6, Math.min(control.width - width - 6, anchorRect.x))
        y: anchorRect.y >= height + 8 ? anchorRect.y - height - 8 : anchorRect.y + anchorRect.height + 8
        z: 20
        width: formatActions.implicitWidth + 10
        height: 34
        radius: 9
        color: Qt.lighter(control.paperColor, 1.03)
        border.width: 1
        border.color: Qt.rgba(control.inkColor.r, control.inkColor.g, control.inkColor.b, 0.22)

        Behavior on opacity { NumberAnimation { duration: 110 } }
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

        Row {
            id: formatActions
            anchors.centerIn: parent
            spacing: 1

            NotyActionButton {
                width: 30
                height: 30
                focusPolicy: Qt.NoFocus
                action: boldAction
                glyph: "text-b"
                glyphSize: 15
                glyphColor: control.actionIconColor
                outlineColor: control.actionIconBorder
                usePlasmaIconTheme: control.usePlasmaIconTheme
                onPressed: editor.forceActiveFocus()
            }
            NotyActionButton {
                width: 30
                height: 30
                focusPolicy: Qt.NoFocus
                action: italicAction
                glyph: "text-italic"
                glyphSize: 15
                glyphColor: control.actionIconColor
                outlineColor: control.actionIconBorder
                usePlasmaIconTheme: control.usePlasmaIconTheme
                onPressed: editor.forceActiveFocus()
            }
            Rectangle {
                width: 1
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(control.inkColor.r, control.inkColor.g, control.inkColor.b, 0.15)
            }
            NotyActionButton {
                width: 30
                height: 30
                focusPolicy: Qt.NoFocus
                action: quoteAction
                glyph: "quotes"
                glyphSize: 15
                glyphColor: control.actionIconColor
                outlineColor: control.actionIconBorder
                usePlasmaIconTheme: control.usePlasmaIconTheme
                onPressed: control.applyQuoteOnPress()
            }
            NotyActionButton {
                width: 30
                height: 30
                focusPolicy: Qt.NoFocus
                action: checklistAction
                glyph: "check-square"
                glyphSize: 15
                glyphColor: control.actionIconColor
                outlineColor: control.actionIconBorder
                usePlasmaIconTheme: control.usePlasmaIconTheme
                onPressed: control.applyChecklistOnPress()
            }
        }
    }
}
