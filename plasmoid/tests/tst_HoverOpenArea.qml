import QtQuick
import QtTest
import "../package/contents/ui"

/** @brief Exercises the actual compact trigger with mouse events and its real timer. */
Item {
    id: harness
    width: 240
    height: 160

    MouseArea {
        id: desktop
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        property int rightPresses: 0
        onPressed: rightPresses++

        HoverOpenArea {
            id: trigger
            x: 40
            y: 40
            width: 80
            height: 80
        }
    }

    SignalSpy { id: opened; target: trigger; signalName: "openRequested" }

    TestCase {
        name: "HoverOpenArea"
        when: windowShown

        /** @brief Starts each test outside the trigger with no pending interaction. */
        function init() {
            mouseMove(harness, 220, 140)
            trigger.deckVisible = false
            trigger.hoverSuppressed = false
            desktop.rightPresses = 0
            opened.clear()
        }

        /** @brief Hover waits before requesting a preview without explicit activation. */
        function test_hover_delay() {
            mouseMove(trigger, 20, 20)
            wait(250)
            compare(opened.count, 0)
            tryCompare(opened, "count", 1, 600)
            compare(opened.signalArguments[0][0], false)
            wait(550)
            compare(opened.count, 1)
        }

        /** @brief A brief visit never opens after the pointer has left. */
        function test_exit_cancels() {
            mouseMove(trigger, 20, 20)
            wait(100)
            mouseMove(harness, 220, 140)
            wait(600)
            compare(opened.count, 0)
        }

        /** @brief Left clicks open immediately and cancel the pending hover callback. */
        function test_left_click_activates() {
            mouseMove(trigger, 20, 20)
            mouseClick(trigger, 20, 20, Qt.LeftButton)
            compare(opened.count, 1)
            compare(opened.signalArguments[0][0], true)
            wait(600)
            compare(opened.count, 1)
        }

        /** @brief Right press reaches the underlying desktop and keeps the timer cancelled. */
        function test_right_click_handoff_and_reentry() {
            mouseMove(trigger, 20, 20)
            mouseClick(trigger, 20, 20, Qt.RightButton)
            compare(desktop.rightPresses, 1)
            wait(700)
            compare(opened.count, 0)
            mouseMove(harness, 220, 140)
            mouseMove(trigger, 20, 20)
            tryCompare(opened, "count", 1, 800)
            compare(opened.signalArguments[0][0], false)
        }

        /** @brief Plasma's menu notification also cancels without a delivered press. */
        function test_native_menu_notification_cancels() {
            mouseMove(trigger, 20, 20)
            trigger.suppressHover()
            wait(700)
            compare(opened.count, 0)
        }

        /** @brief Holding a button beyond the dwell never opens a hover preview. */
        function test_held_press_cancels() {
            mouseMove(trigger, 20, 20)
            mousePress(trigger, 20, 20, Qt.LeftButton)
            wait(600)
            compare(opened.count, 0)
            mouseRelease(trigger, 20, 20, Qt.LeftButton)
            compare(opened.count, 1)
        }

        /** @brief An already shown deck cancels pending opening and activation. */
        function test_visible_deck_cancels() {
            mouseMove(trigger, 20, 20)
            trigger.deckVisible = true
            wait(600)
            compare(opened.count, 0)
        }
    }
}
