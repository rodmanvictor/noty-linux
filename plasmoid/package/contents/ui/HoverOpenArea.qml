import QtQuick

/**
 * @brief Compact trigger with delayed hover opening and native context-menu handoff.
 * @sideeffect Emits openRequested(false) after a 500 ms dwell, or true on left click.
 * Right clicks are rejected so the containing Plasma applet can handle them.
 * Menu opening cancels the dwell; another pointer visit is required to rearm it.
 */
MouseArea {
    id: trigger
    hoverEnabled: true
    acceptedButtons: Qt.AllButtons
    cursorShape: Qt.PointingHandCursor

    /** @brief Disables hover opening while the deck is already visible. */
    property bool deckVisible: false
    /** @brief Blocks automatic opening for the remainder of this pointer visit. */
    property bool hoverSuppressed: false
    /** @brief Requests the deck, with activation reserved for an explicit left click. */
    signal openRequested(bool activateWindow)
    /** @brief Reports entry to the owner's hidden-mode pointer handoff logic. */
    signal pointerEntered()
    /** @brief Reports exit to the owner's hidden-mode close timer. */
    signal pointerExited()

    /**
     * @brief Cancels pending hover opening before a press or native menu appears.
     * @returns {void} No value; stops the timer and suppresses this pointer visit.
     */
    function suppressHover() {
        hoverSuppressed = true
        hoverOpenTimer.stop()
    }

    onEntered: {
        pointerEntered()
        if (!hoverSuppressed && !deckVisible && !pressed) {
            hoverOpenTimer.restart()
        }
    }
    onExited: {
        hoverOpenTimer.stop()
        hoverSuppressed = false
        pointerExited()
    }
    onPressed: mouse => {
        suppressHover()
        if (mouse.button !== Qt.LeftButton) {
            mouse.accepted = false
        }
    }
    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) {
            openRequested(true)
        }
    }
    onDeckVisibleChanged: if (deckVisible) hoverOpenTimer.stop()

    Timer {
        id: hoverOpenTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (trigger.containsMouse && !trigger.pressed
                    && !trigger.hoverSuppressed && !trigger.deckVisible) {
                trigger.openRequested(false)
            }
        }
    }
}
