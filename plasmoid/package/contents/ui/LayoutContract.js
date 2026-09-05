.pragma library

/**
 * @fileoverview Pure visual-layout decisions shared by the Plasma UI and tests.
 *
 * Keeping edge geometry here makes the rendered fan direction testable without
 * a live desktop or user input device.
 */

/**
 * Normalizes a persisted fan direction to one of the supported values.
 * @param {string} direction Stored configuration value.
 * @returns {string} `rightToLeft` by default, otherwise `leftToRight`.
 */
function fanDirection(direction) {
    return direction === "leftToRight" ? "leftToRight" : "rightToLeft"
}

/**
 * Normalizes an edge placement, preserving the legacy left/right preference.
 * @param {string} edge Configured edge placement.
 * @param {string} legacyDirection Previous direction-only setting.
 * @returns {string} One of `right`, `left`, `top` or `bottom`.
 */
function stickEdge(edge, legacyDirection) {
    if (edge === "left" || edge === "top" || edge === "bottom") {
        return edge
    }
    return fanDirection(legacyDirection) === "leftToRight" ? "left" : "right"
}

/**
 * Reports whether the chosen edge uses a horizontal stick layout.
 * @param {string} edge Normalized edge placement.
 * @returns {boolean} True for top and bottom edges.
 */
function horizontalSticks(edge) {
    return edge === "top" || edge === "bottom"
}

/**
 * Normalizes the closed-state presentation selected in widget settings.
 * @param {string} mode Persisted presentation value.
 * @returns {string} One of `trafficLight`, `sticks` or `hidden`.
 */
function idleDisplayMode(mode) {
    if (mode === "sticks" || mode === "hidden") {
        return mode
    }
    return "trafficLight"
}

/**
 * Reports whether the fan should remain visible after it loses focus.
 * @param {string} mode Persisted or normalized closed-state presentation.
 * @returns {boolean} True only for the always-visible sticks mode.
 */
function keepsFanVisible(mode) {
    return idleDisplayMode(mode) === "sticks"
}

/**
 * Reports whether focus loss should close the whole edge dialog.
 * @param {string} mode Persisted or normalized closed-state presentation.
 * @returns {boolean} False for persistent sticks so desktop menus keep focus.
 */
function hidesDialogOnDeactivate(mode) {
    return !keepsFanVisible(mode)
}

/**
 * Returns the stacking layer for a normal, selected or hovered stick.
 * @param {number} index Position in the visible deck.
 * @param {boolean} selected Whether this stick owns the open card.
 * @param {boolean} hovered Whether the pointer is over this stick.
 * @returns {number} Layer with hover above selection and selection above peers.
 */
function stickLayer(index, selected, hovered) {
    if (hovered) {
        return 300
    }
    if (selected) {
        return 200
    }
    return 100 - index
}

/**
 * Calculates the inward pull used to lift a selected or hovered stick.
 * @param {string} edge Normalized edge placement.
 * @param {boolean} selected Whether this stick owns the open card.
 * @param {boolean} hovered Whether the pointer is over this stick.
 * @returns {{x: number, y: number}} Translation toward the desktop content.
 */
function stickLift(edge, selected, hovered) {
    const distance = hovered ? 8 : (selected ? 4 : 0)
    if (edge === "right") {
        return { x: -distance, y: 0 }
    }
    if (edge === "left") {
        return { x: distance, y: 0 }
    }
    if (edge === "top") {
        return { x: 0, y: distance }
    }
    return { x: 0, y: -distance }
}

/**
 * Distributes every stick along the full currently available fan axis.
 * @param {number} containerLength Current fan width or height.
 * @param {number} tabLength Length of one stick along that axis.
 * @param {number} count Number of visible sticks.
 * @param {number} inset Empty space reserved at both ends of the axis.
 * @returns {number} Compact pitch which keeps the last stick inside the fan.
 */
function distributedTabPitch(containerLength, tabLength, count, inset) {
    if (count <= 1) {
        return 0
    }
    const available = Math.max(1, containerLength - 2 * inset - tabLength)
    return Math.max(1, Math.floor(available / (count - 1)))
}

/**
 * Normalizes one shared fixed card dimension from widget settings.
 * @param {number} value Persisted configuration value.
 * @param {number} minimum Lowest usable card dimension.
 * @param {number} fallback Default dimension when no valid value exists.
 * @returns {number} A fixed dimension that is never below the usable minimum.
 */
function fixedNoteDimension(value, minimum, fallback) {
    const candidate = typeof value === "number" && isFinite(value) ? Math.round(value) : fallback
    return Math.max(minimum, candidate)
}

/**
 * Limits a shingled stick's hit target to its non-overlapping pitch.
 * @param {number} tabLength Full visual length of one stick.
 * @param {number} pitch Distance between neighbouring stick starts.
 * @param {number} index Position of the current stick.
 * @param {number} count Number of sticks in the deck.
 * @returns {number} Stable clickable length; the last stick keeps its full tail.
 */
function stickHitLength(tabLength, pitch, index, count) {
    return index < count - 1 ? Math.min(tabLength, pitch) : tabLength
}

/**
 * Returns whether a fan is anchored to the right and opens toward the left.
 * @param {string} direction Stored or normalized fan direction.
 * @returns {boolean} True for the default right-to-left direction.
 */
function opensRightToLeft(direction) {
    return fanDirection(direction) === "rightToLeft"
}

/**
 * Calculates the horizontal position of an edge tab within the fan surface.
 * @param {number} containerWidth Width of the fan surface.
 * @param {number} tabWidth Width of one tab.
 * @param {string} direction Fan direction.
 * @returns {number} Left coordinate of the tab.
 */
function fanTabX(containerWidth, tabWidth, direction) {
    return opensRightToLeft(direction) ? containerWidth - tabWidth : 0
}

/**
 * Calculates a horizontal stack's vertical attachment coordinate.
 * @param {number} containerHeight Height of the fan surface.
 * @param {number} tabHeight Height of one horizontal tab.
 * @param {string} edge Stick edge placement.
 * @returns {number} Top coordinate of the tab.
 */
function horizontalTabY(containerHeight, tabHeight, edge) {
    return edge === "bottom" ? containerHeight - tabHeight : 0
}

/**
 * Places a horizontal stick on the same side of the deck as its add control.
 *
 * A top deck begins after the left add lane and grows to the right. A bottom
 * deck mirrors that arrangement: its add lane is on the right and sticks grow
 * to the left. Mirroring keeps the creation affordance on the visual edge
 * where a new tab joins the deck.
 * @param {number} containerWidth Current fan width.
 * @param {number} tabWidth Width of one horizontal stick.
 * @param {number} index Position of the stick in the deck.
 * @param {number} pitch Distance between neighbouring stick starts.
 * @param {number} addLaneWidth Reserved outer lane for the add button.
 * @param {string} edge Normalized stick edge.
 * @returns {number} Left coordinate of the horizontal stick.
 */
function horizontalTabX(containerWidth, tabWidth, index, pitch, addLaneWidth, edge) {
    if (edge === "bottom") {
        return containerWidth - addLaneWidth - tabWidth - index * pitch
    }
    return addLaneWidth + index * pitch
}

/**
 * Positions a horizontal deck's add button on its visual creation edge.
 * @param {number} containerWidth Current fan width.
 * @param {number} buttonSize Square add-button size.
 * @param {string} edge Normalized stick edge.
 * @returns {number} Left coordinate of the button.
 */
function horizontalAddButtonX(containerWidth, buttonSize, edge) {
    return edge === "bottom" ? containerWidth - buttonSize - 4 : 4
}

/**
 * Positions the compact traffic light against its configured outer edge.
 * @param {number} containerWidth Width reserved by Plasma's desktop grid.
 * @param {number} itemWidth Width of the visible traffic light.
 * @param {string} edge Normalized edge placement.
 * @returns {number} Left coordinate within the reserved grid cell.
 */
function compactX(containerWidth, itemWidth, edge) {
    if (horizontalSticks(edge)) {
        return Math.round((containerWidth - itemWidth) / 2)
    }
    return edge === "right" ? containerWidth - itemWidth : 0
}

/**
 * Positions the compact traffic light against its configured outer edge.
 * @param {number} containerHeight Height reserved by Plasma's desktop grid.
 * @param {number} itemHeight Height of the visible traffic light.
 * @param {string} edge Normalized edge placement.
 * @returns {number} Top coordinate within the reserved grid cell.
 */
function compactY(containerHeight, itemHeight, edge) {
    if (horizontalSticks(edge)) {
        return edge === "bottom" ? containerHeight - itemHeight : 0
    }
    return Math.round((containerHeight - itemHeight) / 2)
}

/**
 * Returns the horizontal attachment boundary for a one-pixel popup anchor.
 *
 * The right coordinate intentionally equals `containerWidth`: the compact
 * parent still supplies a stable transient parent for the tool window.
 * @param {number} containerWidth Width reserved by Plasma's desktop grid.
 * @param {string} edge Normalized edge placement.
 * @returns {number} Left coordinate of the popup anchor.
 */
function popupAnchorX(containerWidth, edge) {
    if (edge === "right") {
        return containerWidth
    }
    if (edge === "left") {
        return 0
    }
    return Math.round((containerWidth - 1) / 2)
}

/**
 * Returns the vertical attachment boundary for a one-pixel popup anchor.
 * @param {number} containerHeight Height reserved by Plasma's desktop grid.
 * @param {string} edge Normalized edge placement.
 * @returns {number} Top coordinate of the popup anchor.
 */
function popupAnchorY(containerHeight, edge) {
    if (edge === "bottom") {
        return containerHeight
    }
    if (edge === "top") {
        return 0
    }
    return Math.round((containerHeight - 1) / 2)
}

/**
 * Pins one dialog axis to the requested usable screen edge.
 *
 * A desktop Plasmoid's compact grid cell can remain wherever it was dropped
 * while its Dock dialog is showing. Horizontal stick layouts must therefore
 * explicitly use the screen's usable vertical bounds: selecting `top` means
 * the deck starts at the workspace top, and `bottom` means it ends at the
 * workspace bottom.
 * @param {number} screenOrigin Start coordinate of the usable screen axis.
 * @param {number} screenLength Usable length of that screen axis.
 * @param {number} dialogLength Current dialog length on the same axis.
 * @param {string} edge Normalized edge placement.
 * @returns {number} Coordinate flush with `top`/`left` or `bottom`/`right`.
 */
function dialogEdgeAxisPosition(screenOrigin, screenLength, dialogLength, edge) {
    if (edge === "top" || edge === "left") {
        return screenOrigin
    }
    return screenOrigin + Math.max(0, screenLength - dialogLength)
}

/**
 * Centers the add button on the short axis of the fan's stick lane.
 * @param {number} tabX Horizontal coordinate of a vertical stick lane.
 * @param {number} tabWidth Width of a vertical stick.
 * @param {number} buttonSize Square add-button size.
 * @param {boolean} horizontal True for top and bottom placements.
 * @returns {number} Left coordinate of the button.
 */
function addButtonX(tabX, tabWidth, buttonSize, horizontal) {
    return horizontal ? 4 : tabX + Math.round((tabWidth - buttonSize) / 2)
}

/**
 * Centers the add button on the short axis of the fan's stick lane.
 * @param {number} tabY Vertical coordinate of a horizontal stick lane.
 * @param {number} tabHeight Height of a horizontal stick.
 * @param {number} buttonSize Square add-button size.
 * @param {boolean} horizontal True for top and bottom placements.
 * @returns {number} Top coordinate of the button.
 */
function addButtonY(tabY, tabHeight, buttonSize, horizontal) {
    return horizontal ? tabY + Math.round((tabHeight - buttonSize) / 2) : 4
}
