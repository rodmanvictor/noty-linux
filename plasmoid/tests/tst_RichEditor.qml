import QtQuick
import QtQuick.Controls
import QtTest

import "../package/contents/ui/EditorContract.js" as EditorContract

/**
 * @brief Verifies the native WYSIWYG Markdown path used by the note card.
 *
 * These tests exercise the same Qt 6 `TextEdit.MarkdownText` and
 * `cursorSelection` APIs as the live Plasmoid. They prove that formatting is
 * rendered without exposing markup while the persisted value remains Markdown.
 */
TestCase {
    name: "RichEditor"
    width: 480
    height: 240
    when: windowShown

    Component {
        id: editorComponent

        Item {
            id: editorHarness
            property alias editor: testEditor
            property alias boldAction: testBoldAction
            property alias italicAction: testItalicAction
            property alias quoteAction: testQuoteAction
            property alias checklistAction: testChecklistAction
            property alias quoteButton: testQuoteButton
            property alias checklistButton: testChecklistButton

            width: 420
            height: 180

            /**
             * @brief Applies a Markdown block marker to complete selected paragraphs.
             * @param marker Quote or unchecked-task prefix.
             */
            function formatSelectionAsBlock(marker) {
                const plainText = testEditor.getText(0, testEditor.length)
                const range = EditorContract.visualBlockRange(
                    plainText,
                    testEditor.selectionStart,
                    testEditor.selectionEnd
                )
                const markdown = testEditor.getFormattedText(range.start, range.end)
                const replacement = EditorContract.withBlockMarker(markdown, marker)
                testEditor.remove(range.start, range.end)
                testEditor.insert(range.start, replacement)
            }

            TextEdit {
                id: testEditor
                width: parent.width
                height: 120
                textFormat: TextEdit.MarkdownText
                selectByMouse: true
                persistentSelection: true
            }

            Action {
                id: testBoldAction
                enabled: testEditor.selectedText.length > 0
                checkable: true
                checked: testEditor.cursorSelection.font.bold
                onTriggered: testEditor.cursorSelection.font.bold = checked
            }

            Action {
                id: testItalicAction
                enabled: testEditor.selectedText.length > 0
                checkable: true
                checked: testEditor.cursorSelection.font.italic
                onTriggered: testEditor.cursorSelection.font.italic = checked
            }


            Action {
                id: testQuoteAction
                enabled: testEditor.selectedText.length > 0
                onTriggered: editorHarness.formatSelectionAsBlock("> ")
            }

            Action {
                id: testChecklistAction
                enabled: testEditor.selectedText.length > 0
                onTriggered: editorHarness.formatSelectionAsBlock("- [ ] ")
            }

            ToolButton {
                id: testQuoteButton
                y: 132
                width: 32
                height: 32
                focusPolicy: Qt.NoFocus
                action: testQuoteAction
                onPressed: editorHarness.formatSelectionAsBlock("> ")
            }

            ToolButton {
                id: testChecklistButton
                x: 40
                y: 132
                width: 32
                height: 32
                focusPolicy: Qt.NoFocus
                action: testChecklistAction
                onPressed: editorHarness.formatSelectionAsBlock("- [ ] ")
            }
        }
    }

    function test_markdown_renders_without_showing_source_markers() {
        const harness = createTemporaryObject(editorComponent, this)
        verify(harness !== null)
        const editor = harness.editor
        editor.text = "**Bold** and *italic*\n\n- [ ] Task"

        compare(editor.getText(0, editor.length), "Bold and italic\u2029Task")
        compare(editor.getFormattedText(0, editor.length), "**Bold** and *italic*\n\n- [ ] Task\n")
    }

    function test_selection_formatting_remains_markdown() {
        const harness = createTemporaryObject(editorComponent, this)
        verify(harness !== null)
        const editor = harness.editor
        editor.text = "Bold and italic"
        editor.select(0, 4)
        harness.boldAction.trigger()

        compare(editor.getText(0, editor.length), "Bold and italic")
        compare(editor.text.trim(), "**Bold** and italic")

        editor.select(9, 15)
        harness.italicAction.trigger()
        compare(editor.text.trim(), "**Bold** and *italic*")
    }

    function test_checklist_can_be_inserted_in_visual_mode() {
        const harness = createTemporaryObject(editorComponent, this)
        verify(harness !== null)
        const editor = harness.editor
        editor.text = "Plan"
        editor.insert(editor.length, "\n- [ ] Ship it")

        compare(editor.getText(0, editor.length), "Plan\u2029\u2029Ship it")
        compare(editor.text, "Plan\n\n- [ ] Ship it\n")
    }

    function test_partial_word_selection_becomes_a_complete_checklist_block() {
        const harness = createTemporaryObject(editorComponent, this)
        verify(harness !== null)
        const editor = harness.editor
        editor.text = "First paragraph\n\nSecond paragraph"
        const plainText = editor.getText(0, editor.length)
        const wordStart = plainText.indexOf("Second") + 2
        editor.select(wordStart, wordStart + 3)
        harness.checklistAction.trigger()

        verify(editor.text.indexOf("First paragraph") === 0)
        verify(editor.text.indexOf("- [ ] Second paragraph") !== -1)
        verify(editor.text.indexOf("- [ ] First paragraph") === -1)
        compare(editor.getText(0, editor.length), "First paragraph\u2029\u2029Second paragraph")
    }

    function test_partial_word_selection_becomes_a_complete_quote_block() {
        const harness = createTemporaryObject(editorComponent, this)
        verify(harness !== null)
        const editor = harness.editor
        editor.text = "First paragraph\n\nSecond paragraph"
        editor.select(2, 5)
        harness.quoteAction.trigger()

        verify(editor.text.indexOf("> First paragraph") === 0)
        verify(editor.text.indexOf("> Second paragraph") === -1)
        compare(editor.getText(0, editor.length), "First paragraph\u2029Second paragraph")
    }

    function test_checklist_entries_follow_rendered_labels_and_completion_state() {
        const markdown = "Intro\n\n- [ ] **Ship** it\n- [x] Review\n- [ ] Review"
        const rendered = "Intro\u2029\u2029Ship it\u2029Review\u2029Review"
        const entries = EditorContract.checklistEntries(markdown, rendered)

        compare(entries.length, 3)
        compare(entries[0].taskIndex, 0)
        compare(entries[0].position, rendered.indexOf("Ship it"))
        verify(!entries[0].checked)
        verify(entries[1].checked)
        verify(!entries[2].checked)
        verify(entries[2].position > entries[1].position)
    }

    function test_context_button_press_preserves_selection_and_triggers_block_actions() {
        const harness = createTemporaryObject(editorComponent, this)
        verify(harness !== null)
        const editor = harness.editor
        editor.text = "Alpha paragraph\n\nBeta paragraph"
        editor.select(2, 6)
        verify(harness.quoteAction.enabled)
        verify(harness.quoteButton.enabled)
        harness.quoteButton.click()
        verify(editor.text.indexOf("> Alpha paragraph") === 0)

        const betaStart = editor.getText(0, editor.length).indexOf("Beta") + 1
        editor.select(betaStart, betaStart + 3)
        verify(harness.checklistAction.enabled)
        harness.checklistButton.click()
        verify(editor.text.indexOf("- [ ] Beta paragraph") !== -1)
    }
}
