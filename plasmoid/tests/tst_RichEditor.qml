import QtQuick
import QtTest

import "../package/contents/ui" as NotyUi
import "../package/contents/ui/EditorContract.js" as EditorContract

/**
 * @brief Verifies NotionEditor uses Qt's document engine with thin visual blocks.
 *
 * The suite exercises the same QML component embedded by the note card. It keeps
 * Markdown in the underlying TextArea while proving the contextual menu, task
 * controls, and quote-rule mappings are based on one source document.
 */
Item {
    id: testSurface
    width: 520
    height: 280

    Rectangle {
        anchors.fill: parent
        color: "#20242a"
    }

    Rectangle {
        id: snapshotSurface
        anchors.centerIn: parent
        width: 480
        height: 236
        radius: 14
        color: "#d8f1e4"

        NotyUi.NotionEditor {
            id: snapshotEditor
            anchors.fill: parent
            anchors.margins: 18
            noteId: "snapshot"
            markdown: "> Keep the note quiet.\n\n- [ ] Write the release note\n- [x] Check the first build\n\nFormat this selection"
            paperColor: snapshotSurface.color
            inkColor: "#27323a"
            actionIconColor: "#667784"
            actionIconOnDarkColor: snapshotSurface.color
            actionIconBorder: "#a8bbc7"
        }

        Timer {
            interval: 80
            running: true
            repeat: false
            onTriggered: {
                const selectionStart = snapshotEditor.textEditor.getText(0, snapshotEditor.textEditor.length).indexOf("Format")
                snapshotEditor.textEditor.select(selectionStart, selectionStart + "Format this".length)
            }
        }
    }

    TestCase {
        name: "RichEditor"
        when: windowShown

    Component {
        id: editorComponent

        NotyUi.NotionEditor {
            id: editorHarness
            width: 440
            height: 200
            noteId: "note"
            paperColor: "#d8f1e4"
            inkColor: "#27323a"
            actionIconColor: "#667784"
            actionIconOnDarkColor: "#d8f1e4"
            actionIconBorder: "#a8bbc7"
            property string lastSavedMarkdown: ""
            property int toggledTaskIndex: -1
            onMarkdownEdited: function(nextMarkdown) { lastSavedMarkdown = nextMarkdown }
            onChecklistToggled: function(nextTaskIndex) { toggledTaskIndex = nextTaskIndex }
        }
    }

    /** @brief Creates a visible editor harness and lets Qt finish the initial layout. */
    function createEditor(markdown) {
        const harness = createTemporaryObject(editorComponent, testSurface)
        verify(harness !== null)
        harness.markdown = markdown
        wait(0)
        return harness
    }

    function test_markdown_renders_without_showing_source_markers() {
        const harness = createEditor("**Bold** and *italic*\n\n- [ ] Task")
        compare(harness.textEditor.getText(0, harness.textEditor.length), "Bold and italic\u2029Task")
        compare(harness.textEditor.getFormattedText(0, harness.textEditor.length), "**Bold** and *italic*\n\n- [ ] Task\n")
        compare(harness.taskControlCount, 1)
    }

    function test_task_control_forwards_one_store_intent() {
        const harness = createEditor("- [ ] First\n- [x] Second")
        compare(harness.taskControlCount, 2)
        harness.requestChecklistToggle(1)
        compare(harness.toggledTaskIndex, 1)
    }

    function test_selection_actions_keep_markdown_as_the_single_source() {
        const harness = createEditor("Bold and italic")
        const editor = harness.textEditor
        editor.select(0, 4)
        verify(harness.bubbleVisible)
        harness.applyBold()
        compare(editor.text.trim(), "**Bold** and italic")

        editor.select(9, 15)
        harness.applyItalic()
        compare(editor.text.trim(), "**Bold** and *italic*")
        compare(harness.lastSavedMarkdown.trim(), "**Bold** and *italic*")
    }

    function test_partial_selection_becomes_a_complete_checklist_block() {
        const harness = createEditor("First paragraph\n\nSecond paragraph")
        const editor = harness.textEditor
        const start = editor.getText(0, editor.length).indexOf("Second") + 2
        editor.select(start, start + 3)
        harness.checklistSelection()

        verify(editor.text.indexOf("First paragraph") === 0)
        verify(editor.text.indexOf("- [ ] Second paragraph") !== -1)
        verify(editor.text.indexOf("- [ ] First paragraph") === -1)
    }

    function test_partial_selection_becomes_a_complete_quote_block() {
        const harness = createEditor("First paragraph\n\nSecond paragraph")
        const editor = harness.textEditor
        editor.select(2, 5)
        harness.quoteSelection()

        verify(editor.text.indexOf("> First paragraph") === 0)
        verify(editor.text.indexOf("> Second paragraph") === -1)
    }

    function test_task_and_quote_entries_follow_rendered_document_positions() {
        const markdown = "> **First** quote\n> Second quote\n\n- [ ] **Ship** it\n- [x] Review\n- [ ] Review"
        const rendered = "First quote\u2028Second quote\u2029\u2029Ship it\u2029Review\u2029Review"
        const tasks = EditorContract.checklistEntries(markdown, rendered)
        const quotes = EditorContract.quoteEntries(markdown, rendered)

        compare(tasks.length, 3)
        compare(tasks[0].position, rendered.indexOf("Ship it"))
        verify(tasks[1].checked)
        verify(tasks[2].position > tasks[1].position)
        compare(quotes.length, 2)
        compare(quotes[0].position, rendered.indexOf("First quote"))
        verify(quotes[1].position > quotes[0].position)
    }

    /** @brief Guards the real overlay coordinates, not merely the Markdown mapping. */
    function test_task_controls_follow_their_rendered_rows_after_layout() {
        const harness = createEditor("- [ ] First task\n- [x] Second task")
        tryVerify(function() {
            return findChild(harness, "notionTaskBlock-0") !== null
                && findChild(harness, "notionTaskBlock-1") !== null
        }, 1000)
        wait(0)

        const rendered = harness.textEditor.getText(0, harness.textEditor.length)
        const firstLabelRect = harness.textEditor.positionToRectangle(rendered.indexOf("First task"))
        const secondLabelRect = harness.textEditor.positionToRectangle(rendered.indexOf("Second task"))
        const firstControl = findChild(harness, "notionTaskBlock-0")
        const secondControl = findChild(harness, "notionTaskBlock-1")

        verify(Math.abs(firstControl.y + firstControl.height / 2 - (firstLabelRect.y + firstLabelRect.height / 2)) <= 4)
        verify(Math.abs(secondControl.y + secondControl.height / 2 - (secondLabelRect.y + secondLabelRect.height / 2)) <= 4)
        mouseClick(secondControl, secondControl.width / 2, secondControl.height / 2, Qt.LeftButton)
        compare(harness.toggledTaskIndex, 1)
    }

    function test_export_notion_editor_snapshot() {
        tryVerify(function() { return snapshotEditor.bubbleVisible }, 1000)
        // Allow the document layout and the bubble's intentional 110 ms entrance
        // transition to finish before recording the visual regression fixture.
        wait(160)
        const rendered = grabImage(snapshotSurface)
        compare(rendered.width, snapshotSurface.width)
        compare(rendered.height, snapshotSurface.height)
        rendered.save("build/visual-snapshots/notion-editor.png")
    }
    }
}
