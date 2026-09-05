.pragma library

/**
 * @fileoverview Pure visual-document helpers for the Noty Markdown editor.
 *
 * Qt exposes cursor offsets against rendered text, while block commands must
 * operate on complete Markdown paragraphs. These helpers keep that conversion
 * deterministic and independently testable.
 */

/**
 * Reports whether a rendered-text character separates visual paragraphs.
 * @param {string} character One UTF-16 character from TextEdit.getText().
 * @returns {boolean} True for Qt line or paragraph separators.
 */
function isBlockSeparator(character) {
    return character === "\u2028" || character === "\u2029" || character === "\n"
}

/**
 * Expands a selection to the complete rendered paragraph or paragraphs.
 * @param {string} plainText Rendered text returned by TextEdit.getText().
 * @param {number} selectionStart First selected document position.
 * @param {number} selectionEnd Position after the selected range.
 * @returns {{start: number, end: number}} Bounded complete-block range.
 */
function visualBlockRange(plainText, selectionStart, selectionEnd) {
    const text = plainText || ""
    let start = Math.max(0, Math.min(text.length, selectionStart))
    let end = Math.max(start, Math.min(text.length, selectionEnd))
    while (start > 0 && !isBlockSeparator(text.charAt(start - 1))) {
        start -= 1
    }
    while (end < text.length && !isBlockSeparator(text.charAt(end))) {
        end += 1
    }
    return { start: start, end: end }
}

/**
 * Prefixes every non-empty Markdown line with a quote or task marker.
 * @param {string} markdown Markdown exported from the selected visual blocks.
 * @param {string} marker Prefix such as `> ` or `- [ ] `.
 * @returns {string} Markdown ready to insert at the expanded block position.
 */
function withBlockMarker(markdown, marker) {
    const source = (markdown || "").replace(/\r\n/g, "\n").replace(/\n+$/, "")
    return source.split("\n").map(function(line) {
        return line.trim().length === 0 ? line : marker + line
    }).join("\n")
}

/**
 * Removes the inline Markdown tokens that Qt omits from rendered task labels.
 * @param {string} markdown Inline Markdown from one checklist row.
 * @returns {string} Best-effort visible label used for document positioning.
 */
function visibleInlineText(markdown) {
    return (markdown || "")
        .replace(/!\[([^\]]*)\]\([^)]*\)/g, "$1")
        .replace(/\[([^\]]+)\]\([^)]*\)/g, "$1")
        .replace(/[*_~`]/g, "")
        .replace(/\\([\\`*_{}\[\]()#+\-.!>])/g, "$1")
}

/**
 * Maps Markdown task rows to their rendered QTextDocument positions.
 *
 * Positions are resolved sequentially so repeated task labels remain distinct.
 * Empty labels are omitted until the user types visible content because Qt does
 * not expose a stable QML position for their zero-length rendered block.
 *
 * @param {string} markdown Markdown stored by the note.
 * @param {string} plainText Rendered text returned by TextEdit.getText().
 * @returns {Array<{taskIndex: number, checked: boolean, label: string, position: number}>} Positioned task controls.
 */
function checklistEntries(markdown, plainText) {
    const rendered = plainText || ""
    const entries = []
    let searchFrom = 0
    let taskIndex = 0
    ;(markdown || "").replace(/\r\n/g, "\n").split("\n").forEach(function(line) {
        const match = line.match(/^\s*[-*+]\s+\[([ xX])\]\s*(.*)$/)
        if (!match) {
            return
        }
        const label = visibleInlineText(match[2])
        const position = label.length > 0 ? rendered.indexOf(label, searchFrom) : -1
        if (position >= 0) {
            entries.push({
                taskIndex: taskIndex,
                checked: match[1].toLowerCase() === "x",
                label: label,
                position: position
            })
            searchFrom = position + Math.max(1, label.length)
        }
        taskIndex += 1
    })
    return entries
}
