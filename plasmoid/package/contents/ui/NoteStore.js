.pragma library

/**
 * @fileoverview Pure note mutations shared by the Plasma UI and QML tests.
 *
 * Every function returns a new value. Persisting it to KConfig is deliberately
 * left to main.qml so the same operations can be verified without changing a
 * user's real widget data.
 */

/**
 * Creates the initial welcome note for an empty or damaged store.
 * @param {string} id Stable identifier supplied by the caller.
 * @returns {Object} A valid Noty note object.
 */
function welcomeNote(id, title, body) {
    return {
        id: id,
        title: title,
        body: body,
        color: 0,
        pinned: false,
        archived: false,
        archivedAt: null,
        checklist: [],
        width: null,
        height: null,
        ruled: false
    }
}

/**
 * Returns a newly-created blank note, choosing a palette colour by position.
 * @param {Array<Object>} notes Existing notes.
 * @param {string} id Identifier supplied by the caller.
 * @param {number} paletteLength Number of available colours; must be positive.
 * @returns {Object} A blank, active note.
 */
function create(notes, id, paletteLength, untitledTitle) {
    return {
        id: id,
        title: untitledTitle,
        body: "",
        color: notes.length % Math.max(1, paletteLength),
        pinned: false,
        archived: false,
        archivedAt: null,
        checklist: [],
        width: null,
        height: null,
        ruled: false
    }
}

/**
 * Finds a note by identifier.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Identifier to find.
 * @returns {Object|null} Found note, or null.
 */
function find(notes, id) {
    for (let index = 0; index < notes.length; index += 1) {
        if (notes[index].id === id) {
            return notes[index]
        }
    }
    return null
}

/**
 * Normalizes a legacy note's optional checklist property.
 * @param {Object} note Stored note.
 * @returns {Array<Object>} Valid checklist items.
 */
function checklistOf(note) {
    return Array.isArray(note.checklist) ? note.checklist : []
}

/**
 * Returns a persisted note width only when it is a finite positive number.
 * @param {Object} note Stored note.
 * @returns {number|null} Saved width, or null for the default card width.
 */
function widthOf(note) {
    return typeof note.width === "number" && isFinite(note.width) && note.width > 0
        ? Math.round(note.width) : null
}

/**
 * Returns a persisted note height only when it is a finite positive number.
 * @param {Object} note Stored note.
 * @returns {number|null} Saved height, or null for the default card height.
 */
function heightOf(note) {
    return typeof note.height === "number" && isFinite(note.height) && note.height > 0
        ? Math.round(note.height) : null
}

/**
 * Returns the archive timestamp only when the persisted value is a valid ISO
 * date. Legacy archived notes without the value intentionally remain retained.
 * @param {Object} note Stored note.
 * @returns {string|null} Archive timestamp, or null when no retention clock exists.
 */
function archivedAtOf(note) {
    return typeof note.archivedAt === "string" && isFinite(Date.parse(note.archivedAt))
        ? note.archivedAt : null
}

/**
 * Replaces a note body without changing its explicit deck title.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Target identifier.
 * @param {string} body New plain-text body.
 * @returns {Array<Object>} New collection; unchanged when no note matches.
 */
function withBody(notes, id, body) {
    return notes.map(function(note) {
        if (note.id !== id) {
            return note
        }
        return {
            id: note.id,
            title: note.title,
            body: body,
            color: note.color,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        }
    })
}

/**
 * Appends legacy checklist rows to a note body as GitHub-flavoured Markdown.
 *
 * Older widget versions stored tasks separately from prose. The lightweight
 * editor keeps every block in `body`, so this migration runs once while
 * preserving the task text and completion state.
 *
 * @param {Array<Object>} notes Existing notes.
 * @returns {Array<Object>} Notes whose legacy tasks are represented by
 *                          `- [ ]` / `- [x]` Markdown lines.
 */
function migrateLegacyChecklists(notes) {
    return notes.map(function(note) {
        const legacyItems = checklistOf(note)
        if (legacyItems.length === 0) {
            return note
        }
        const taskLines = legacyItems.map(function(item) {
            return "- [" + (item.done === true ? "x" : " ") + "] " + (item.text || "")
        }).join("\n")
        const body = note.body && note.body.length > 0 ? note.body + "\n\n" + taskLines : taskLines
        return {
            id: note.id,
            title: note.title,
            body: body,
            color: note.color,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: [],
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        }
    })
}

/**
 * Flips one task row in a note's Markdown body.
 *
 * @param {Array<Object>} notes Existing notes.
 * @param {string} id Target note identifier.
 * @param {number} taskIndex Zero-based index among Markdown checklist rows.
 * @returns {Array<Object>} Updated note collection.
 */
function withToggledMarkdownChecklist(notes, id, taskIndex) {
    return notes.map(function(note) {
        if (note.id !== id) {
            return note
        }
        let seenTasks = -1
        const body = (note.body || "").split("\n").map(function(line) {
            const match = line.match(/^(\s*- \[)( |x|X)(\] .*)$/)
            if (!match) {
                return line
            }
            seenTasks += 1
            if (seenTasks !== taskIndex) {
                return line
            }
            return match[1] + (match[2].toLowerCase() === "x" ? " " : "x") + match[3]
        }).join("\n")
        return {
            id: note.id,
            title: note.title,
            body: body,
            color: note.color,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        }
    })
}

/**
 * Replaces a note's explicit palette index.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Target identifier.
 * @param {number} color Palette index.
 * @returns {Array<Object>} Recoloured collection.
 */
function withColor(notes, id, color) {
    return notes.map(function(note) {
        return note.id === id ? {
            id: note.id,
            title: note.title,
            body: note.body,
            color: color,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        } : note
    })
}

/**
 * Replaces a note title without modifying its body.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Target identifier.
 * @param {string} title Explicit title chosen by the user.
 * @param {string} fallbackTitle Localized title for blank input.
 * @returns {Array<Object>} Retitled collection.
 */
function withTitle(notes, id, title, fallbackTitle) {
    return notes.map(function(note) {
        return note.id === id ? {
            id: note.id,
            title: title.trim().length > 0 ? title.trim().slice(0, 72) : fallbackTitle,
            body: note.body,
            color: note.color,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        } : note
    })
}

/**
 * Marks a note as archived while retaining it in local KConfig storage.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Target identifier.
 * @param {string} archivedAt ISO timestamp at which retention begins.
 * @returns {Array<Object>} Archived collection.
 */
function withArchived(notes, id, archivedAt) {
    return notes.map(function(note) {
        return note.id === id ? {
            id: note.id,
            title: note.title,
            body: note.body,
            color: note.color,
            pinned: note.pinned,
            archived: true,
            archivedAt: typeof archivedAt === "string" && isFinite(Date.parse(archivedAt)) ? archivedAt : null,
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        } : note
    })
}

/**
 * Restores an archived note without altering its text or presentation.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Target identifier.
 * @returns {Array<Object>} Collection with the target note active again.
 */
function withRestored(notes, id) {
    return notes.map(function(note) {
        return note.id === id ? {
            id: note.id,
            title: note.title,
            body: note.body,
            color: note.color,
            pinned: note.pinned,
            archived: false,
            archivedAt: null,
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        } : note
    })
}

/**
 * Drops only archived notes whose timestamp is older than the selected limit.
 * Notes without an archive timestamp are kept to protect data from older builds.
 * @param {Array<Object>} notes Note collection.
 * @param {number} nowMs Current epoch time in milliseconds.
 * @param {number} retentionMs Positive retention duration in milliseconds.
 * @returns {Array<Object>} Collection without expired archived notes.
 */
function withoutExpiredArchived(notes, nowMs, retentionMs) {
    if (typeof nowMs !== "number" || !isFinite(nowMs)
            || typeof retentionMs !== "number" || !isFinite(retentionMs) || retentionMs <= 0) {
        return notes
    }
    return notes.filter(function(note) {
        const archivedAt = archivedAtOf(note)
        return note.archived !== true || archivedAt === null || Date.parse(archivedAt) + retentionMs > nowMs
    })
}

/**
 * Removes every archived record while preserving all active notes verbatim.
 *
 * This is intentionally separate from expiry cleanup: the caller must obtain
 * explicit user confirmation before invoking this irreversible bulk action.
 * @param {Array<Object>} notes Note collection.
 * @returns {Array<Object>} Collection containing only active notes.
 */
function withoutArchived(notes) {
    return notes.filter(function(note) { return note.archived !== true })
}

/**
 * Enables or disables ruled-paper lines for one note.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Target identifier.
 * @param {boolean} ruled Whether notebook lines should be visible.
 * @returns {Array<Object>} Reconfigured collection.
 */
function withRuled(notes, id, ruled) {
    return notes.map(function(note) {
        if (note.id !== id) {
            return note
        }
        return {
            id: note.id,
            title: note.title,
            body: note.body,
            color: note.color,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: ruled === true
        }
    })
}

/**
 * Reconciles stored note colour indexes after an optional palette entry dies.
 *
 * The first palette entry is never removable. A note using the deleted colour
 * therefore falls back to index zero, while colours after it shift left by one
 * to retain their visual paper colour.
 * @param {Array<Object>} notes Note collection.
 * @param {number} removedIndex Deleted palette index; zero and negatives are ignored.
 * @returns {Array<Object>} Notes with colour indexes valid for the new palette.
 */
function withDeletedPaletteColour(notes, removedIndex) {
    if (typeof removedIndex !== "number" || removedIndex <= 0) {
        return notes
    }
    return notes.map(function(note) {
        const current = typeof note.color === "number" ? note.color : 0
        const color = current === removedIndex ? 0 : (current > removedIndex ? current - 1 : current)
        return {
            id: note.id,
            title: note.title,
            body: note.body,
            color: color,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        }
    })
}

/**
 * Reassigns stored palette indexes after optional swatches change position.
 *
 * The mapping is indexed by the old palette position and contains the matching
 * new position. Invalid legacy indexes deliberately fall back to zero, which
 * is the palette's permanent default colour.
 * @param {Array<Object>} notes Note collection.
 * @param {Array<number>} oldToNewIndex Old-index to new-index palette map.
 * @returns {Array<Object>} Notes that retain their previous visual paper colour.
 */
function withRemappedPaletteColour(notes, oldToNewIndex) {
    if (!Array.isArray(oldToNewIndex) || oldToNewIndex.length === 0) {
        return notes
    }
    return notes.map(function(note) {
        const current = typeof note.color === "number" && Math.floor(note.color) === note.color
            ? note.color : 0
        const mapped = current >= 0 && current < oldToNewIndex.length
            && typeof oldToNewIndex[current] === "number"
            && Math.floor(oldToNewIndex[current]) === oldToNewIndex[current]
            && oldToNewIndex[current] >= 0
            ? oldToNewIndex[current] : 0
        return {
            id: note.id,
            title: note.title,
            body: note.body,
            color: mapped,
            pinned: note.pinned,
            archived: note.archived === true,
            archivedAt: archivedAtOf(note),
            checklist: checklistOf(note),
            width: widthOf(note),
            height: heightOf(note),
            ruled: note.ruled === true
        }
    })
}

/**
 * Removes a note permanently.
 * @param {Array<Object>} notes Note collection.
 * @param {string} id Target identifier.
 * @returns {Array<Object>} Collection without the matching note.
 */
function without(notes, id) {
    return notes.filter(function(note) { return note.id !== id })
}
