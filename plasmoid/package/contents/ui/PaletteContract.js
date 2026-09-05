.pragma library

/**
 * @fileoverview Pure palette persistence and reconciliation helpers for Noty.
 *
 * Palette entries keep the paper, accent and ink colours together. This avoids
 * changing the appearance of existing default notes while allowing a user to
 * add, replace, reorder or remove additional colours in Plasma settings.
 */

/**
 * Returns a new copy of Noty's initial eight-colour paper palette.
 * @returns {Array<{paper: string, dash: string, ink: string}>} Default entries.
 */
function defaultPalette() {
    return [
        { paper: "#fce795", dash: "#e0ad08", ink: "#3a3008" },
        { paper: "#fbcfa6", dash: "#e2762a", ink: "#422413" },
        { paper: "#fac4d1", dash: "#dc4570", ink: "#40161f" },
        { paper: "#d9c7fa", dash: "#7c4dee", ink: "#2a1b44" },
        { paper: "#beddfa", dash: "#2280d6", ink: "#13293a" },
        { paper: "#b4e8d0", dash: "#0e9b6e", ink: "#0f2e23" },
        { paper: "#e3d3b4", dash: "#a37b3c", ink: "#372c18" },
        { paper: "#cbd6e2", dash: "#4e6579", ink: "#1a242e" }
    ]
}

/**
 * Normalizes a CSS hex colour into lowercase six-digit form.
 * @param {unknown} value Candidate CSS colour.
 * @returns {string|null} Canonical colour, or null when unsupported.
 */
function hexColour(value) {
    if (typeof value !== "string") {
        return null
    }
    const source = value.trim().toLowerCase()
    if (/^#[0-9a-f]{6}$/.test(source)) {
        return source
    }
    if (/^#[0-9a-f]{8}$/.test(source)) {
        return "#" + source.slice(3)
    }
    if (/^#[0-9a-f]{3}$/.test(source)) {
        return "#" + source.charAt(1) + source.charAt(1)
            + source.charAt(2) + source.charAt(2)
            + source.charAt(3) + source.charAt(3)
    }
    return null
}

/**
 * Darkens a valid hex colour without relying on QML's Qt runtime object.
 * @param {string} colour Canonical six-digit colour.
 * @param {number} amount Multiplier between 0 and 1.
 * @returns {string} Darkened hex colour.
 */
function darken(colour, amount) {
    const factor = Math.max(0, Math.min(1, amount))
    const red = Math.round(parseInt(colour.slice(1, 3), 16) * factor)
    const green = Math.round(parseInt(colour.slice(3, 5), 16) * factor)
    const blue = Math.round(parseInt(colour.slice(5, 7), 16) * factor)
    return "#" + component(red) + component(green) + component(blue)
}

/**
 * Formats one 8-bit colour channel as two hexadecimal digits.
 * @param {number} value Channel value from 0 through 255.
 * @returns {string} Two-digit lowercase hexadecimal value.
 */
function component(value) {
    const hex = Math.max(0, Math.min(255, Math.round(value))).toString(16)
    return hex.length === 1 ? "0" + hex : hex
}

/**
 * Converts one sRGB channel to the linear-light value used by WCAG contrast.
 * @param {number} channel 8-bit sRGB channel.
 * @returns {number} Linear-light channel in the 0–1 range.
 */
function linearChannel(channel) {
    const normalised = Math.max(0, Math.min(255, channel)) / 255
    return normalised <= 0.04045
        ? normalised / 12.92
        : Math.pow((normalised + 0.055) / 1.055, 2.4)
}

/**
 * Calculates the WCAG relative luminance for a canonical CSS hex colour.
 * @param {string} colour CSS hex colour.
 * @returns {number} Relative luminance, or zero for an invalid value.
 */
function relativeLuminance(colour) {
    const normalized = hexColour(colour)
    if (!normalized) {
        return 0
    }
    const red = linearChannel(parseInt(normalized.slice(1, 3), 16))
    const green = linearChannel(parseInt(normalized.slice(3, 5), 16))
    const blue = linearChannel(parseInt(normalized.slice(5, 7), 16))
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue
}

/**
 * Calculates the WCAG contrast ratio between two CSS hex colours.
 * @param {string} first First CSS hex colour.
 * @param {string} second Second CSS hex colour.
 * @returns {number} Contrast ratio from 1 through 21.
 */
function contrastRatio(first, second) {
    const firstLuminance = relativeLuminance(first)
    const secondLuminance = relativeLuminance(second)
    const lighter = Math.max(firstLuminance, secondLuminance)
    const darker = Math.min(firstLuminance, secondLuminance)
    return (lighter + 0.05) / (darker + 0.05)
}

/**
 * Chooses a preferred text colour only when it remains readable on paper.
 *
 * Plasma's system text can be white in a dark desktop theme. It must not be
 * applied blindly to a light note, so this helper keeps the note's paired ink
 * whenever the preferred colour misses WCAG's normal-text contrast threshold.
 * @param {string} paper Paper CSS hex colour.
 * @param {string} preferredInk System-provided preferred ink colour.
 * @param {string} fallbackInk Palette ink known to suit the paper.
 * @returns {string} Readable preferred or fallback ink colour.
 */
function readableInk(paper, preferredInk, fallbackInk) {
    const fallback = hexColour(fallbackInk) || inkFor(paper)
    const preferred = hexColour(preferredInk)
    return preferred && contrastRatio(preferred, paper) >= 4.5 ? preferred : fallback
}

/**
 * Selects the higher-contrast ink colour for a custom paper colour.
 * @param {string} paper Canonical six-digit paper colour.
 * @returns {string} Dark or light text colour with the best WCAG contrast.
 */
function inkFor(paper) {
    const darkInk = "#201d1a"
    const lightInk = "#faf8f5"
    return contrastRatio(darkInk, paper) >= contrastRatio(lightInk, paper)
        ? darkInk : lightInk
}

/**
 * Builds one valid palette entry, deriving secondary colours for custom paper.
 * @param {Object} entry Candidate persisted entry.
 * @returns {{paper: string, dash: string, ink: string}|null} Valid entry or null.
 */
function normaliseEntry(entry) {
    const paper = entry && hexColour(entry.paper)
    if (!paper) {
        return null
    }
    return {
        paper: paper,
        dash: hexColour(entry.dash) || darken(paper, 0.84),
        ink: hexColour(entry.ink) || inkFor(paper)
    }
}

/**
 * Normalizes stored palette data, recovering the default palette if it is bad.
 * @param {unknown} entries Candidate palette list.
 * @returns {Array<{paper: string, dash: string, ink: string}>} Non-empty palette.
 */
function normalise(entries) {
    if (!Array.isArray(entries)) {
        return defaultPalette()
    }
    const normalized = entries.map(normaliseEntry).filter(function(entry) { return entry !== null })
    return normalized.length > 0 ? normalized : defaultPalette()
}

/**
 * Parses the KConfig JSON payload without exposing malformed data to QML.
 * @param {string} json Serialized palette setting.
 * @returns {Array<{paper: string, dash: string, ink: string}>} Non-empty palette.
 */
function fromJson(json) {
    if (typeof json !== "string" || json.trim().length === 0) {
        return defaultPalette()
    }
    try {
        return normalise(JSON.parse(json))
    } catch (error) {
        return defaultPalette()
    }
}

/**
 * Serializes a safe palette for its KConfig string entry.
 * @param {Array<Object>} entries Palette to persist.
 * @returns {string} Valid non-empty palette JSON.
 */
function toJson(entries) {
    return JSON.stringify(normalise(entries))
}

/**
 * Returns a copy of a palette with one user-chosen paper colour appended.
 * Duplicate paper colours are ignored to keep deletion reconciliation stable.
 * @param {Array<Object>} entries Existing palette.
 * @param {string} paper New paper colour from the colour picker.
 * @returns {Array<{paper: string, dash: string, ink: string}>} Updated palette.
 */
function append(entries, paper) {
    const next = normalise(entries)
    const normalizedPaper = hexColour(paper)
    if (!normalizedPaper || next.some(function(entry) { return entry.paper === normalizedPaper })) {
        return next
    }
    return next.concat([normaliseEntry({ paper: normalizedPaper })])
}

/**
 * Replaces the paper colour at an existing index while retaining its position.
 * @param {Array<Object>} entries Existing palette.
 * @param {number} index Entry to update.
 * @param {string} paper Replacement paper colour.
 * @returns {Array<{paper: string, dash: string, ink: string}>} Updated palette.
 */
function replace(entries, index, paper) {
    const next = normalise(entries)
    const replacement = normaliseEntry({ paper: paper })
    if (!replacement || index < 0 || index >= next.length) {
        return next
    }
    if (next.some(function(entry, entryIndex) {
        return entryIndex !== index && entry.paper === replacement.paper
    })) {
        return next
    }
    return next.map(function(entry, entryIndex) {
        return entryIndex === index ? replacement : entry
    })
}

/**
 * Removes an optional palette entry while protecting the first default colour.
 * @param {Array<Object>} entries Existing palette.
 * @param {number} index Requested removal index.
 * @returns {Array<{paper: string, dash: string, ink: string}>} Remaining palette.
 */
function remove(entries, index) {
    const next = normalise(entries)
    if (index <= 0 || index >= next.length) {
        return next
    }
    return next.filter(function(entry, entryIndex) { return entryIndex !== index })
}

/**
 * Moves an optional palette entry without allowing it to replace the fallback.
 *
 * Index zero is intentionally fixed: a note can always recover to that colour
 * after an optional swatch is deleted. The caller should remap saved notes with
 * `reorderedIndexMap()` before persisting the new order.
 * @param {Array<Object>} entries Existing palette.
 * @param {number} fromIndex Optional entry being moved.
 * @param {number} toIndex Optional destination index.
 * @returns {Array<{paper: string, dash: string, ink: string}>} Reordered palette.
 */
function moveOptional(entries, fromIndex, toIndex) {
    const next = normalise(entries)
    const validFrom = typeof fromIndex === "number" && Math.floor(fromIndex) === fromIndex
    const validTo = typeof toIndex === "number" && Math.floor(toIndex) === toIndex
    if (!validFrom || !validTo || fromIndex <= 0 || toIndex <= 0
            || fromIndex >= next.length || toIndex >= next.length || fromIndex === toIndex) {
        return next
    }
    const moved = next.slice()
    const entry = moved.splice(fromIndex, 1)[0]
    moved.splice(toIndex, 0, entry)
    return moved
}

/**
 * Produces an identity key for matching a complete persisted palette entry.
 * @param {{paper: string, dash: string, ink: string}} entry Valid palette entry.
 * @returns {string} Stable key for ordered-palette reconciliation.
 */
function entryKey(entry) {
    return entry.paper + "|" + entry.dash + "|" + entry.ink
}

/**
 * Maps each old palette index to its new index after a pure reorder.
 *
 * An empty list means the change is not a reorder (for example replacement or
 * deletion), or that there was no effective move. Entries are matched one at a
 * time so manually persisted duplicate colours do not create an ambiguous map.
 * @param {Array<Object>} before Palette before a configuration update.
 * @param {Array<Object>} after Palette after a configuration update.
 * @returns {Array<number>} Old-index to new-index map, or an empty list.
 */
function reorderedIndexMap(before, after) {
    const oldPalette = normalise(before)
    const newPalette = normalise(after)
    if (oldPalette.length !== newPalette.length) {
        return []
    }

    const consumed = []
    const mapping = []
    let changed = false
    for (let oldIndex = 0; oldIndex < oldPalette.length; oldIndex += 1) {
        const key = entryKey(oldPalette[oldIndex])
        let newIndex = -1
        for (let candidateIndex = 0; candidateIndex < newPalette.length; candidateIndex += 1) {
            if (consumed[candidateIndex] !== true && entryKey(newPalette[candidateIndex]) === key) {
                newIndex = candidateIndex
                consumed[candidateIndex] = true
                break
            }
        }
        if (newIndex < 0) {
            return []
        }
        mapping.push(newIndex)
        changed = changed || newIndex !== oldIndex
    }
    return changed ? mapping : []
}

/**
 * Reports the exact deleted index for a one-entry ordered palette removal.
 * @param {Array<Object>} before Palette before a configuration update.
 * @param {Array<Object>} after Palette after a configuration update.
 * @returns {number} Removed index, or -1 when the change is not a deletion.
 */
function removedIndex(before, after) {
    const oldPalette = normalise(before)
    const newPalette = normalise(after)
    if (oldPalette.length !== newPalette.length + 1) {
        return -1
    }
    for (let index = 1; index < oldPalette.length; index += 1) {
        const candidate = oldPalette.filter(function(entry, entryIndex) { return entryIndex !== index })
        if (toJson(candidate) === toJson(newPalette)) {
            return index
        }
    }
    return -1
}
