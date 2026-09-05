import QtQuick
import QtQuick.Controls
import QtTest

/**
 * @brief Verifies Qt's built-in Markdown task editing used by the note card.
 *
 * The test deliberately imports no Noty editor helper. It exercises the same
 * stock TextArea.MarkdownText component that is embedded in main.qml.
 */
Item {
    id: harness
    width: 420
    height: 120
    /** @brief Markdown value observed by the note store's normal text-change binding. */
    property string persistedBody: ""

    TextArea {
        id: editor
        x: 16
        y: 16
        width: 360
        height: 72
        textFormat: TextEdit.MarkdownText
        text: "- [ ] Ship it"
        onTextChanged: harness.persistedBody = text
    }

    TestCase {
        name: "NativeMarkdownTasks"
        when: windowShown

        function init() {
            editor.text = "- [ ] Ship it"
            wait(40)
        }

        /**
         * @brief Clicks the native task marker lane left of the rendered label.
         * @returns {boolean} True when TextArea toggles the stored task Markdown.
         */
        function clickNativeMarkerLane() {
            const labelRect = editor.positionToRectangle(editor.getText(0, editor.length).indexOf("Ship it"))
            const y = editor.y + labelRect.y + labelRect.height / 2
            for (let x = editor.x; x < editor.x + labelRect.x; x += 2) {
                editor.text = "- [ ] Ship it"
                mouseClick(harness, x, y)
                if (editor.text.indexOf("- [x] Ship it") !== -1) {
                    return true
                }
            }
            return false
        }

        /** Confirms the reader sees prose while Qt retains Markdown as the source. */
        function test_markdown_markers_are_not_exposed_as_editor_text() {
            compare(editor.getText(0, editor.length), "Ship it")
            compare(editor.text, "- [ ] Ship it\n")
        }

        /** Confirms one native pointer click both toggles and emits the persisted Markdown body. */
        function test_native_markdown_task_click_persists_through_text_changed() {
            verify(clickNativeMarkerLane())
            compare(harness.persistedBody, "- [x] Ship it\n")
        }
    }
}
