/**
 * @fileoverview Stable Breeze/FreeDesktop icon-name fallbacks for Noty actions.
 *
 * The user-facing semantic names remain the selected Phosphor names. This map
 * is used only after opting in to the current Plasma icon theme, so a missing
 * theme icon can safely fall back to the bundled Phosphor vector.
 */

/**
 * @brief Maps a selected Noty glyph to a broadly available KDE icon name.
 * @param {string} glyph Selected Phosphor Regular glyph identifier.
 * @returns {string} Breeze/FreeDesktop icon name, or an empty string when none exists.
 */
function forGlyph(glyph) {
    const names = {
        "plus": "list-add",
        "plus-circle": "list-add",
        // The plain archive glyph communicates the action without the tiny
        // plus badge rendered by archive-insert in MacTahoe/Breeze themes.
        "archive": "archive",
        "folder-open": "folder-open",
        "arrow-counter-clockwise": "edit-undo",
        "trash-simple": "edit-delete",
        "check-square": "task-complete",
        "text-b": "format-text-bold",
        "text-italic": "format-text-italic",
        "text-aa": "format-text-symbol",
        "palette": "color-picker",
        "quotes": "format-text-blockquote",
        // Ruled paper is a text-row affordance, not an unordered-list action.
        "list": "view-list-text",
        "x": "window-close"
    }
    return names[glyph] || ""
}
