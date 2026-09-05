/**
 * @fileoverview Pure normalization helpers for Noty's Plasma-aware appearance.
 *
 * Keeping these values in a tiny JavaScript contract makes KConfig migrations
 * deterministic: malformed and legacy values always keep the widget in the
 * adaptive mode rather than producing an unreadable mixed surface.
 */

/**
 * @brief Returns one of the three supported visual systems.
 * @param {unknown} value KConfig appearance-mode value.
 * @returns {"noty"|"adaptive"|"plasma"} A supported display mode.
 */
function appearanceMode(value) {
    return value === "noty" || value === "plasma" ? value : "adaptive"
}

/**
 * @brief Converts a Plasma point size to a readable note pixel size.
 * @param {unknown} pointSize System font point size supplied by Kirigami.
 * @returns {number} Pixel size, with 12 px retained as Noty's readability floor.
 */
function readableSystemPixelSize(pointSize) {
    const safePointSize = typeof pointSize === "number" && isFinite(pointSize) && pointSize > 0
        ? pointSize
        : 9
    return Math.max(12, Math.round(safePointSize * 96 / 72))
}

/**
 * @brief Keeps only an explicit opt-in to the experimental Plasma icon theme.
 * @param {unknown} value KConfig icon-theme value.
 * @returns {boolean} True only after the user enabled the system icon mapping.
 */
function usesPlasmaIconTheme(value) {
    return value === true
}
