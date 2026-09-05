import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import "LayoutContract.js" as LayoutContract
import "NoteStore.js" as NoteStore
import "I18n.js" as I18n
import "PaletteContract.js" as PaletteContract
import "ThemeContract.js" as ThemeContract

/**
 * @brief Native Plasma desktop representation of Noty.
 *
 * Plasma owns placement and popup focus handling. The compact representation is
 * a 12 pt edge pill; the full representation is its fanned deck and editor.
 * Notes belong to this plasmoid instance and are persisted through KConfig.
 */
PlasmoidItem {
    id: root

    width: 12
    height: 68
    Plasmoid.icon: "note"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.userBackgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: compactRepresentation
    hideOnWindowDeactivate: LayoutContract.hidesDialogOnDeactivate(idleDisplayMode)
    toolTipMainText: "Noty"
    toolTipSubText: activeNotes.length + " " + text("notes", "заметок")

    /** @brief User-configurable ordered palette; its first colour is the permanent fallback. */
    readonly property var palette: PaletteContract.fromJson(Plasmoid.configuration.paletteJson)
    /** @brief Last palette observed after initialization, used to reconcile safe palette edits. */
    property var appliedPalette: []
    /** @brief Prevents palette reconciliation before stored notes have loaded. */
    property bool paletteReady: false
    property var notes: []
    property string selectedId: ""
    /** @brief One-pixel outer-edge target used to place the desktop dialog flush. */
    property var dialogAnchor: null
    /** @brief Persisted language code normalized to one of the supported locales. */
    readonly property string language: I18n.normalize(Plasmoid.configuration.language || "en")
    /** @brief Configured direction in which tabs and cards open from their edge. */
    readonly property string fanDirection: LayoutContract.fanDirection(Plasmoid.configuration.fanDirection)
    /** @brief Normalized desktop edge used for both the compact trigger and deck. */
    readonly property string stickEdge: LayoutContract.stickEdge(Plasmoid.configuration.stickEdge, fanDirection)
    /** @brief True when the selected edge presents sticks horizontally. */
    readonly property bool horizontalSticks: LayoutContract.horizontalSticks(stickEdge)
    /** @brief Whether titles remain visible on the coloured note sticks. */
    readonly property bool showStickTitles: Plasmoid.configuration.showStickTitles !== false
    /** @brief Normalized closed-state presentation selected in widget settings. */
    readonly property string idleDisplayMode: LayoutContract.idleDisplayMode(Plasmoid.configuration.idleDisplayMode)
    /** @brief Whether the closed-state coloured compact indicator is rendered. */
    readonly property bool showTrafficLight: idleDisplayMode === "trafficLight"
    /** @brief Whether the note sticks remain visible whenever no card is open. */
    readonly property bool keepSticksVisible: LayoutContract.keepsFanVisible(idleDisplayMode)
    /** @brief One of Noty, Adaptive or fully Plasma-driven visual systems. */
    readonly property string appearanceMode: ThemeContract.appearanceMode(Plasmoid.configuration.appearanceMode)
    /** @brief Adaptive mode is the default: pastel paper with Plasma typography and states. */
    readonly property bool usesAdaptiveAppearance: appearanceMode === "adaptive"
    /** @brief Full Plasma mode replaces the paper palette with current system colours. */
    readonly property bool usesPlasmaAppearance: appearanceMode === "plasma"
    /** @brief Opt-in mapping from selected semantic icons to the active Plasma icon theme. */
    readonly property bool usePlasmaIconTheme: ThemeContract.usesPlasmaIconTheme(Plasmoid.configuration.usePlasmaIconTheme)
    /** @brief Current desktop default font exposed by Kirigami and kept live with its theme. */
    readonly property font systemDefaultFont: Kirigami.Theme.defaultFont
    /** @brief Noty retains a 12 px reading floor when Plasma's system point size is smaller. */
    readonly property int systemDefaultNoteFontSize: ThemeContract.readableSystemPixelSize(systemDefaultFont.pointSize)
    /** @brief Current desktop family, falling back only if a theme provides no family string. */
    readonly property string systemDefaultNoteFontFamily: systemDefaultFont.family || "Noto Sans"
    /** @brief System palette values used by Adaptive action chrome and the Plasma mode. */
    readonly property color systemTextColour: Kirigami.Theme.textColor
    readonly property color systemBackgroundColour: Kirigami.Theme.backgroundColor
    readonly property color systemHighlightColour: Kirigami.Theme.highlightColor
    readonly property color systemHighlightedTextColour: Kirigami.Theme.highlightedTextColor
    /** @brief User-selected or system-derived base type size for note content. */
    readonly property int noteFontSize: configuredFontSize(
        Plasmoid.configuration.noteFontSize, Plasmoid.configuration.useSystemNoteFont !== false
    )
    /** @brief User-selected or system-derived family for note titles and Markdown body text. */
    readonly property string noteFontFamily: configuredFontFamily(
        Plasmoid.configuration.noteFontFamily, Plasmoid.configuration.useSystemNoteFont !== false
    )
    /** @brief Retention policy applied only to timestamped archived notes. */
    readonly property string archiveRetention: configuredArchiveRetention(Plasmoid.configuration.archiveRetention)
    /** @brief Lowest dimensions that preserve the title, editor and footer controls. */
    readonly property int minimumNoteWidth: 420
    readonly property int minimumNoteHeight: 300
    /** @brief Single optical icon size shared by every standard action. */
    readonly property int iconSizeXs: 16
    /** @brief Larger add affordance: the plus is a primary edge action, not a row icon. */
    readonly property int addIconSize: 22
    /** @brief Shared optical size for the card's primary action icons. */
    readonly property int cardActionIconSize: iconSizeXs
    /** @brief Neutral Noty tint; Plasma derives a contrast-safe ink from the default paper. */
    readonly property color actionIconColour: usesPlasmaAppearance ? colour(0).ink : "#667784"
    /** @brief Restrained Noty outline; Plasma derives it from the contrast-safe default ink. */
    readonly property color actionIconBorder: usesPlasmaAppearance
        ? Qt.rgba(actionIconColour.r, actionIconColour.g, actionIconColour.b, 0.22)
        : "#d3dce3"
    /** @brief Icon colour for active task surfaces in the selected visual system. */
    readonly property color actionIconOnDarkColour: usesPlasmaAppearance ? systemHighlightedTextColour : "#c8d1d8"
    /** @brief Shared fixed width applied to every open note card. */
    readonly property int fixedNoteWidth: LayoutContract.fixedNoteDimension(
        Plasmoid.configuration.fixedNoteWidth, minimumNoteWidth, 640
    )
    /** @brief Shared fixed height applied to every open note card. */
    readonly property int fixedNoteHeight: LayoutContract.fixedNoteDimension(
        Plasmoid.configuration.fixedNoteHeight, minimumNoteHeight, 480
    )
    /** @brief Legacy per-note size fields are deliberately ignored after the fixed-size change. */
    readonly property int selectedNoteWidth: fixedNoteWidth
    /** @brief Legacy per-note size fields are deliberately ignored after the fixed-size change. */
    readonly property int selectedNoteHeight: fixedNoteHeight
    /** @brief True when a right-edge deck grows into the desktop toward the left. */
    readonly property bool opensRightToLeft: stickEdge === "right"
    /**
     * @brief The note currently rendered by the editor, or null for the deck.
     *
     * This value is updated imperatively alongside `selectedId`. Keeping the
     * object instead of deriving it through nested bindings prevents the
     * editor's text and colour bindings from recursively re-evaluating the
     * selected note while the user types.
     */
    property var selectedNote: null
    property bool showAllNotes: false
    property string hoveredId: ""
    /** @brief Whether the archive recovery sheet is displayed instead of the active deck. */
    property bool archiveDrawerOpen: false
    /** @brief Most recently archived note, kept briefly for a non-destructive undo. */
    property string undoArchiveId: ""
    /** @brief Controls the short-lived archive undo affordance. */
    property bool archiveUndoVisible: false
    /** @brief Whether the pointer is over Plasma's invisible compact trigger. */
    property bool compactPointerInside: false
    /** @brief Whether the pointer is over the visible fan or open card. */
    property bool fanPointerInside: false
    readonly property var activeNotes: notes.filter(note => note.archived !== true)
    /** @brief Archived notes in newest-first order for the recovery sheet. */
    readonly property var archivedNotes: notes.filter(note => note.archived === true).slice().sort(function(first, second) {
        return (second.archivedAt || "").localeCompare(first.archivedAt || "")
    })
    /** @brief Every active note stays visible in the fan; pitch adapts to its available axis. */
    readonly property var visibleNotes: activeNotes
    /** @brief The open-card switcher preserves exactly the fan's order and membership. */
    readonly property var cardNavigationNotes: visibleNotes

    /**
     * @brief Returns a UI string in the current interface language.
     * @param {string} english English source string and translation key.
     * @param {string} russian Russian legacy fallback kept for existing UI copy.
     * @returns {string} Translated text with an English fallback.
     */
    function text(english, russian) {
        return I18n.text(language, english, russian)
    }

    /**
     * @brief Resolves the system-derived or explicitly selected body type size.
     * @param value KConfig manual pixel size supplied by Plasma.
     * @param useSystemFont Whether the current system font is still selected.
     * @returns {number} Whole pixel size from 10 through 24, or the system value with a 12 px floor.
     */
    function configuredFontSize(value, useSystemFont) {
        if (useSystemFont) {
            return systemDefaultNoteFontSize
        }
        const candidate = typeof value === "number" && isFinite(value) ? Math.round(value) : 12
        return Math.max(10, Math.min(24, candidate))
    }

    /**
     * @brief Resolves the system-derived or explicitly selected typeface name.
     * @param value KConfig font-family value.
     * @param useSystemFont Whether the current system font is still selected.
     * @returns {string} Installed system family or the configured family name.
     */
    function configuredFontFamily(value, useSystemFont) {
        if (useSystemFont) {
            return systemDefaultNoteFontFamily
        }
        return typeof value === "string" && value.trim().length > 0 ? value.trim() : systemDefaultNoteFontFamily
    }

    /**
     * @brief Converts KConfig storage to one supported archive retention option.
     * @param value Persisted retention identifier.
     * @returns {string} `never`, `30m`, `1d`, `7d` or `30d`.
     */
    function configuredArchiveRetention(value) {
        return value === "30m" || value === "1d" || value === "7d" || value === "30d" ? value : "never"
    }

    /**
     * @brief Returns the configured archive lifetime in milliseconds.
     * @param retention Normalized retention identifier.
     * @returns {number} Positive lifetime, or zero when archive retention is unlimited.
     */
    function archiveRetentionMilliseconds(retention) {
        if (retention === "30m") return 30 * 60 * 1000
        if (retention === "1d") return 24 * 60 * 60 * 1000
        if (retention === "7d") return 7 * 24 * 60 * 60 * 1000
        if (retention === "30d") return 30 * 24 * 60 * 60 * 1000
        return 0
    }

    /**
     * @brief Formats an archive timestamp in the user's current desktop locale.
     * @param value ISO archive timestamp.
     * @returns {string} Interface-appropriate date and time, or a safe fallback for legacy data.
     */
    function archiveDateLabel(value) {
        return typeof value === "string" && isFinite(Date.parse(value))
            ? Qt.formatDateTime(new Date(value), language === "ru" ? "dd.MM.yyyy HH:mm" : "MMM d, yyyy HH:mm")
            : text("Date unavailable", "Дата недоступна")
    }

    /**
     * @brief Pins the visible edge dialog to the configured physical screen edge.
     *
     * Plasma's `Dock` surface keeps the compositor's transparent-popup
     * treatment. The compositor can relayout after activation, so placement
     * is repeated once its final size is known.
     * @sideeffect Updates the visible dialog's global x or y coordinate.
     */
    function alignDialogToScreenEdge() {
        if (!noteDialog.visible) {
            return
        }
        const usableScreen = root.availableScreenRect
        if (root.stickEdge === "top" || root.stickEdge === "bottom") {
            noteDialog.y = LayoutContract.dialogEdgeAxisPosition(
                usableScreen.y, usableScreen.height, noteDialog.height, root.stickEdge
            )
        } else {
            noteDialog.x = LayoutContract.dialogEdgeAxisPosition(
                usableScreen.x, usableScreen.width, noteDialog.width, root.stickEdge
            )
        }
    }

    /** @brief Coalesces geometry changes while Plasma finishes laying out the Dock dialog. */
    function scheduleDialogEdgeAlignment() {
        if (noteDialog.visible) {
            dialogEdgeAlignmentTimer.restart()
        }
    }

    /**
     * @brief Returns a paper, ink and dash trio for a stored colour index.
     *
     * Every appearance mode preserves the note's paper identity. Noty keeps
     * its local ink; Adaptive retains its paired ink with Plasma typography;
     * Plasma adopts the desktop text colour only if it remains readable on the
     * same paper. This prevents a dark desktop theme from turning every note
     * into a black card.
     * @param index Stored palette index.
     * @returns {{paper: color, ink: color, dash: color}} Current visual-system colours.
     */
    function colour(index) {
        const entry = palette[((index % palette.length) + palette.length) % palette.length]
        if (usesPlasmaAppearance) {
            return { paper: entry.paper, ink: plasmaInkFor(entry), dash: entry.dash }
        }
        return entry
    }

    /**
     * @brief Uses Plasma text only where it passes WCAG contrast on note paper.
     * @param {{paper: string, ink: string, dash: string}} entry Palette entry.
     * @returns {color|string} System text or the entry's paired fallback ink.
     */
    function plasmaInkFor(entry) {
        return PaletteContract.readableInk(entry.paper, systemTextColour.toString(), entry.ink)
    }

    /**
     * Reassigns notes after a settings-driven palette deletion or reorder.
     * @sideeffect Deleted-colour notes use the mandatory first entry; reordered
     *             notes retain their existing paper colour.
     */
    function reconcilePaletteChange() {
        if (!paletteReady) {
            return
        }
        const removedIndex = PaletteContract.removedIndex(appliedPalette, palette)
        const oldToNewIndex = PaletteContract.reorderedIndexMap(appliedPalette, palette)
        if (removedIndex > 0) {
            notes = NoteStore.withDeletedPaletteColour(notes, removedIndex)
            selectedNote = selectedId === "" ? null : NoteStore.find(notes, selectedId)
            saveNotes()
        } else if (oldToNewIndex.length > 0) {
            notes = NoteStore.withRemappedPaletteColour(notes, oldToNewIndex)
            selectedNote = selectedId === "" ? null : NoteStore.find(notes, selectedId)
            saveNotes()
        }
        appliedPalette = palette
    }

    /**
     * @brief Returns the restrained tab colour derived from the note paper.
     * @param index Stored palette index.
     * @return A colour slightly darker than the editor sheet.
     */
    function stickColour(index) {
        return Qt.darker(colour(index).paper, 1.08)
    }

    /**
     * @brief Returns the title-spine colour without breaking the paper palette.
     * @param index Stored palette index.
     * @return A colour one subtle step darker than the matching stick.
     */
    function spineColour(index) {
        return Qt.darker(colour(index).paper, 1.14)
    }

    /**
     * @brief Returns a strong colour-related perforation tone.
     * @param index Stored palette index.
     * @return A thicker dashed separator that keeps the note hue.
     */
    function perforationColour(index) {
        return Qt.darker(colour(index).paper, 1.34)
    }

    /** @brief Converts the persisted JSON value to the in-memory note list. */
    function loadNotes() {
        try {
            const parsed = JSON.parse(Plasmoid.configuration.notesJson || "[]")
            const loadedNotes = Array.isArray(parsed) ? parsed : []
            notes = NoteStore.migrateLegacyChecklists(loadedNotes)
            if (JSON.stringify(notes) !== JSON.stringify(loadedNotes)) {
                saveNotes()
            }
        } catch (error) {
            console.warn("Noty: ignoring malformed stored notes", error)
            notes = []
        }
        if (notes.length === 0) {
            notes = [NoteStore.welcomeNote(Date.now().toString(), text("Welcome to Noty", "Добро пожаловать в Noty"), text("Hover the edge tab to open your notes.", "Наведите курсор на плашку у края экрана."))]
            saveNotes()
        }
    }

    /** @brief Serializes all notes into this widget's KConfig entry. */
    function saveNotes() {
        Plasmoid.configuration.notesJson = JSON.stringify(notes)
    }

    /**
     * @brief Removes archived notes only after their explicitly configured retention period.
     * @sideeffect Writes KConfig when expired note entries are removed.
     */
    function purgeExpiredArchives() {
        const retentionMs = archiveRetentionMilliseconds(archiveRetention)
        const next = NoteStore.withoutExpiredArchived(notes, Date.now(), retentionMs)
        if (next.length === notes.length) {
            return
        }
        notes = next
        if (undoArchiveId !== "" && !NoteStore.find(notes, undoArchiveId)) {
            undoArchiveId = ""
            archiveUndoVisible = false
        }
        saveNotes()
    }

    /**
     * @brief Adds a blank note and opens it in the full representation.
     * @return The identifier of the newly created note.
     */
    function createNote() {
        const note = NoteStore.create(notes, Date.now().toString(), palette.length, text("Untitled note", "Новая заметка"))
        notes = [note].concat(notes)
        saveNotes()
        selectedId = note.id
        selectedNote = note
        archiveDrawerOpen = false
        showNotes()
        return note.id
    }

    /** @brief Finds a note by identifier, or returns null when it was removed. */
    function noteById(id) {
        return NoteStore.find(notes, id)
    }

    /**
     * @brief Saves changed plain-text content without changing its title.
     * @param id Identifier of the edited note.
     * @param body New note content.
     */
    function updateBody(id, body) {
        const next = NoteStore.withBody(notes, id, body)
        const changed = NoteStore.find(next, id)
        if (!changed) {
            return
        }
        notes = next
        selectedNote = changed
        saveNotes()
    }

    /**
     * @brief Toggles one rendered Markdown task without exposing source markup.
     * @param id Identifier of the edited note.
     * @param taskIndex Zero-based index among Markdown task rows.
     * @sideeffect Persists the new Markdown; NotionEditor reloads through its body binding.
     */
    function toggleMarkdownChecklist(id, taskIndex) {
        const next = NoteStore.withToggledMarkdownChecklist(notes, id, taskIndex)
        const changed = NoteStore.find(next, id)
        if (!changed) {
            return
        }
        notes = next
        selectedNote = changed
        saveNotes()
    }

    /** @brief Schedules closing a hidden-mode fan after pointer hand-off. */
    function scheduleHiddenFanClose() {
        if (idleDisplayMode === "hidden" && selectedId === "") {
            hiddenFanCloseTimer.restart()
        }
    }

    /**
     * @brief Saves an explicitly edited note title.
     * @param id Identifier of the edited note.
     * @param title Title from the card header.
     */
    function updateTitle(id, title) {
        const next = NoteStore.withTitle(notes, id, title, text("Untitled note", "Новая заметка"))
        const changed = NoteStore.find(next, id)
        if (!changed) {
            return
        }
        notes = next
        selectedNote = changed
        saveNotes()
    }

    /** @brief Cycles a note through the shared colour palette. */
    function cycleColor(id) {
        const note = noteById(id)
        if (!note) {
            return
        }
        const next = NoteStore.withColor(notes, id, (note.color + 1) % palette.length)
        notes = next
        selectedNote = noteById(id)
        saveNotes()
    }

    /**
     * @brief Applies an explicit palette colour to a note from the editor swatches.
     * @param id Identifier of the note to recolour.
     * @param color Palette index selected by the user.
     */
    function setColor(id, color) {
        const next = NoteStore.withColor(notes, id, color)
        notes = next
        selectedNote = noteById(id)
        saveNotes()
    }

    /**
     * @brief Enables or disables notebook-style ruled lines on one note.
     * @param id Identifier of the note to configure.
     * @param ruled True to render the light horizontal guide lines.
     */
    function setRuled(id, ruled) {
        const next = NoteStore.withRuled(notes, id, ruled)
        const changed = NoteStore.find(next, id)
        if (!changed) {
            return
        }
        notes = next
        selectedNote = changed
        saveNotes()
    }

    /**
     * @brief Permanently removes a note and returns the deck to its tab view.
     * @param id Identifier of the note to remove.
     */
    function deleteNote(id) {
        notes = NoteStore.without(notes, id)
        selectedId = ""
        selectedNote = null
        if (undoArchiveId === id) {
            undoArchiveId = ""
            archiveUndoVisible = false
        }
        saveNotes()
    }

    /**
     * @brief Permanently removes all archived notes after the drawer confirmation.
     * @sideeffect Clears the undo target because it no longer exists in storage.
     */
    function clearArchivedNotes() {
        if (archivedNotes.length === 0) {
            return
        }
        notes = NoteStore.withoutArchived(notes)
        undoArchiveId = ""
        archiveUndoVisible = false
        archiveUndoTimer.stop()
        saveNotes()
    }

    /**
     * @brief Restores an archived note and optionally opens it for editing.
     * @param id Identifier of the archived note.
     * @param openAfterRestore Whether the restored note should become the active card.
     */
    function restoreArchivedNote(id, openAfterRestore) {
        const next = NoteStore.withRestored(notes, id)
        const restored = NoteStore.find(next, id)
        if (!restored) {
            return
        }
        notes = next
        undoArchiveId = ""
        archiveUndoVisible = false
        saveNotes()
        if (openAfterRestore === true) {
            archiveDrawerOpen = false
            selectedId = id
            selectedNote = restored
            showNotes()
        }
    }

    /**
     * @brief Shows or hides the local recovery sheet without changing notes.
     */
    function toggleArchiveDrawer() {
        archiveDrawerOpen = !archiveDrawerOpen
        if (archiveDrawerOpen) {
            selectedId = ""
            selectedNote = null
            showNotes()
        }
    }

    /**
     * @brief Archives a note and returns the card to the active fan.
     * @param id Identifier of the note to archive.
     */
    function archiveNote(id) {
        notes = NoteStore.withArchived(notes, id, new Date().toISOString())
        selectedId = ""
        selectedNote = null
        saveNotes()
        undoArchiveId = id
        archiveUndoVisible = true
        archiveUndoTimer.restart()
    }

    /** @brief Restores the last archived note while its undo action remains available. */
    function undoArchive() {
        if (undoArchiveId !== "") {
            restoreArchivedNote(undoArchiveId, false)
        }
    }

    /**
     * @brief Shows the note deck in a standalone Plasma dialog.
     *
     * Desktop applets use the Planar form factor, where `Plasmoid.expanded`
     * does not create a popup. A PlasmaCore.Dialog is therefore the explicit
     * desktop interaction surface.
     */
    function showNotes(activateWindow) {
        noteDialog.visible = true
        if (activateWindow !== false) {
            noteDialog.requestActivate()
        }
    }

    /**
     * @brief Closes the card and restores the configured idle presentation.
     * @sideeffect The always-visible mode returns directly to the fan; other
     *             modes close the dialog and leave only their compact trigger.
     */
    function closeNoteCard() {
        selectedId = ""
        selectedNote = null
        if (keepSticksVisible) {
            showNotes(false)
        } else {
            noteDialog.visible = false
        }
    }

    /** @brief Reconciles an idle setting change with the current popup state. */
    function applyIdleDisplayMode() {
        if (selectedId !== "") {
            return
        }
        if (keepSticksVisible) {
            Qt.callLater(function() {
                if (root.keepSticksVisible && root.selectedId === "") {
                    root.showNotes(false)
                }
            })
        } else if (noteDialog.visible) {
            noteDialog.visible = false
        }
    }

    /** @brief Opens a selected note in the standalone Plasma dialog. */
    function openNote(id) {
        const note = noteById(id)
        if (!note) {
            return
        }
        selectedId = id
        selectedNote = note
        archiveDrawerOpen = false
        showNotes()
    }

    Component.onCompleted: {
        loadNotes()
        purgeExpiredArchives()
        appliedPalette = palette
        paletteReady = true
        applyIdleDisplayMode()
    }
    onIdleDisplayModeChanged: applyIdleDisplayMode()
    onPaletteChanged: reconcilePaletteChange()
    onArchiveRetentionChanged: purgeExpiredArchives()
    onStickEdgeChanged: scheduleDialogEdgeAlignment()
    onAvailableScreenRectChanged: scheduleDialogEdgeAlignment()
    onScreenGeometryChanged: scheduleDialogEdgeAlignment()

    Timer {
        id: dialogEdgeAlignmentTimer
        interval: 0
        repeat: false
        onTriggered: root.alignDialogToScreenEdge()
    }

    /** @brief Hides archive undo after a short, deliberate recovery window. */
    Timer {
        id: archiveUndoTimer
        interval: 10000
        repeat: false
        onTriggered: {
            root.archiveUndoVisible = false
            root.undoArchiveId = ""
        }
    }

    /** @brief Checks retention while the plasmoid stays alive between openings. */
    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.purgeExpiredArchives()
    }

    Timer {
        id: hiddenFanCloseTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (root.idleDisplayMode === "hidden"
                    && root.selectedId === ""
                    && !root.compactPointerInside
                    && !root.fanPointerInside) {
                noteDialog.visible = false
            }
        }
    }

    compactRepresentation: Item {
        id: compactRoot
        readonly property int compactLength: Math.max(42, Math.min(112, root.notes.length * 19 + 12))
        implicitWidth: root.horizontalSticks ? compactLength : 12
        implicitHeight: root.horizontalSticks ? 12 : compactLength

        Item {
            id: popupAnchor
            /** @brief Keeps the visual parent on the configured edge of the compact applet cell. */
            width: 1
            height: 1
            x: LayoutContract.popupAnchorX(parent.width, root.stickEdge)
            y: LayoutContract.popupAnchorY(parent.height, root.stickEdge)
            Component.onCompleted: root.dialogAnchor = popupAnchor
            Component.onDestruction: if (root.dialogAnchor === popupAnchor) root.dialogAnchor = null
        }

        Rectangle {
            id: compactStrip
            /**
             * Plasma's desktop grid reserves at least one full cell for an
             * applet. Keep that cell transparent and render only the visible
             * 12 px grab strip on its outer edge.
            */
            visible: root.showTrafficLight
            width: root.horizontalSticks ? parent.compactLength : 12
            height: root.horizontalSticks ? 12 : parent.compactLength
            x: LayoutContract.compactX(parent.width, width, root.stickEdge)
            y: LayoutContract.compactY(parent.height, height, root.stickEdge)
            radius: 6
            color: root.usesPlasmaAppearance ? Qt.darker(root.systemBackgroundColour, 1.16) : "#1d1d20"
            opacity: noteDialog.visible ? 0 : 0.94
            scale: noteDialog.visible ? 0.92 : 1

            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            Column {
                visible: !root.horizontalSticks
                anchors.centerIn: parent
                spacing: 5
                Repeater {
                    model: root.activeNotes.slice(0, 8)
                    delegate: Rectangle {
                        required property var modelData
                        width: 7
                        height: 14
                        radius: 3
                        color: root.stickColour(modelData.color)
                        Behavior on color { ColorAnimation { duration: 160 } }
                    }
                }
            }
            Row {
                visible: root.horizontalSticks
                anchors.centerIn: parent
                spacing: 5
                Repeater {
                    model: root.activeNotes.slice(0, 8)
                    delegate: Rectangle {
                        required property var modelData
                        width: 14
                        height: 7
                        radius: 3
                        color: root.stickColour(modelData.color)
                        Behavior on color { ColorAnimation { duration: 160 } }
                    }
                }
            }
        }
        MouseArea {
            /**
             * The grid cell is deliberately larger than the visible strip.
             * Keeping the whole cell interactive makes the edge trigger
             * practical to hit while keeping the desktop visually clean.
            */
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                root.compactPointerInside = true
                hiddenFanCloseTimer.stop()
                if (!noteDialog.visible) {
                    root.showNotes()
                }
            }
            onExited: {
                root.compactPointerInside = false
                root.scheduleHiddenFanClose()
            }
            onClicked: root.showNotes()
        }
    }

    /**
     * @brief The note deck and editor shared by panel and desktop presentations.
     *
     * The desktop dialog and the optional panel full representation each create
     * their own instance of this component.
     */
    Component {
        id: noteView

        Item {
            id: fullView
            readonly property int tabWidth: root.horizontalSticks ? 112 : 34
            readonly property int tabHeight: root.horizontalSticks ? 34 : 112
            /** @brief Permanent add-button lane before the first stick. */
            readonly property int tabStart: 42
            readonly property int tabLength: root.horizontalSticks ? tabWidth : tabHeight
            /**
             * @brief Entire available card axis allocated to the fan in both closed and open states.
             *
             * The pitch below then spreads sparse notes apart and increasingly overlaps a dense deck,
             * without moving the first lane or allowing the final stick to leave the widget.
             */
            readonly property int deckLength: root.horizontalSticks ? root.fixedNoteWidth : root.fixedNoteHeight
            readonly property int fanWidth: root.horizontalSticks ? deckLength : 58
            readonly property int fanHeight: root.horizontalSticks ? 58 : deckLength
            /** @brief The same compact pitch is used before and after a card opens. */
            readonly property int fanTabPitch: LayoutContract.distributedTabPitch(
                deckLength, tabLength, root.visibleNotes.length, tabStart
            )
            /** @brief First horizontal tab mirrors to the right lane for Bottom. */
            readonly property int firstHorizontalTabX: LayoutContract.horizontalTabX(
                width, tabWidth, 0, fanTabPitch, tabStart, root.stickEdge
            )
            readonly property int tabX: root.horizontalSticks ? tabStart : (root.opensRightToLeft ? width - tabWidth : 0)
            /**
             * @brief Current horizontal-stick row, anchored to the active surface edge.
             *
             * The fan is 58 pt high while closed but grows to accommodate the
             * editor when a card opens. Using the actual view height keeps a
             * Bottom deck at the screen bottom in both states.
             */
            readonly property int tabY: root.horizontalSticks
                ? LayoutContract.horizontalTabY(height, tabHeight, root.stickEdge)
                : tabStart
            /** @brief Compact but readable local recovery sheet dimensions. */
            readonly property int archiveWidth: 390
            readonly property int archiveHeight: 420
            readonly property int cardWidth: root.selectedNoteWidth
            readonly property int cardHeight: root.selectedNoteHeight
            /** @brief Card switcher has the same fixed-orientation tab geometry as the closed fan. */
            readonly property int cardStickDepth: 30
            readonly property int cardX: root.selectedId !== "" && root.stickEdge === "left" ? cardStickDepth : 0
            readonly property int cardY: root.selectedId !== "" && root.stickEdge === "top" ? cardStickDepth : 0
            implicitWidth: root.archiveDrawerOpen ? archiveWidth
                : (root.selectedId === "" ? fanWidth : Math.max(fanWidth, cardWidth + (root.horizontalSticks ? 0 : cardStickDepth)))
            implicitHeight: root.archiveDrawerOpen ? archiveHeight
                : (root.selectedId === "" ? fanHeight : Math.max(fanHeight, cardHeight + (root.horizontalSticks ? cardStickDepth : 0)))
            width: implicitWidth
            height: implicitHeight

            HoverHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onHoveredChanged: {
                    root.fanPointerInside = hovered
                    if (hovered) {
                        hiddenFanCloseTimer.stop()
                    } else {
                        root.scheduleHiddenFanClose()
                    }
                }
            }

            /** @brief Transparent shingled fan matching Noty's edge-tab state. */
            Item {
                id: fanPane
                anchors.fill: parent
                visible: root.selectedId === ""

                Repeater {
                    model: root.visibleNotes
                    delegate: Item {
                        id: fanStick
                        required property var modelData
                        required property int index
                        width: fullView.tabWidth
                        height: fullView.tabHeight
                        readonly property bool isHoveredStick: root.hoveredId === modelData.id
                        readonly property var lift: LayoutContract.stickLift(root.stickEdge, false, isHoveredStick)
                        x: root.horizontalSticks
                            ? LayoutContract.horizontalTabX(fullView.width, fanStick.width, index, fullView.fanTabPitch, fullView.tabStart, root.stickEdge)
                            : fullView.tabX
                        y: root.horizontalSticks ? fullView.tabY : fullView.tabStart + index * fullView.fanTabPitch
                        z: LayoutContract.stickLayer(index, false, isHoveredStick)

                        Rectangle {
                            width: fanStick.width
                            height: fanStick.height
                            x: fanStick.lift.x
                            y: fanStick.lift.y
                            radius: 9
                            color: root.stickColour(modelData.color)
                            border.color: root.spineColour(modelData.color)
                            rotation: root.horizontalSticks ? 0 : (fanStick.isHoveredStick ? (root.opensRightToLeft ? -1 : 1) : (root.opensRightToLeft ? -3 : 3))
                            scale: fanStick.isHoveredStick ? 1.035 : 1
                            transformOrigin: root.horizontalSticks ? Item.Top : (root.opensRightToLeft ? Item.Right : Item.Left)

                            Behavior on rotation { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                            Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                            Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: root.horizontalSticks ? parent.width - 16 : fullView.tabHeight - 38
                                // Keep vertical titles readable while the paper tab gently tilts.
                                rotation: root.horizontalSticks ? 0 : -90 - parent.rotation
                                visible: root.showStickTitles
                                text: modelData.title.toUpperCase()
                                color: root.colour(modelData.color).ink
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            width: root.horizontalSticks
                                ? LayoutContract.stickHitLength(fanStick.width, fullView.fanTabPitch, fanStick.index, root.visibleNotes.length)
                                : fanStick.width
                            height: root.horizontalSticks
                                ? fanStick.height
                                : LayoutContract.stickHitLength(fanStick.height, fullView.fanTabPitch, fanStick.index, root.visibleNotes.length)
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.hoveredId = fanStick.modelData.id
                            onExited: if (root.hoveredId === fanStick.modelData.id) root.hoveredId = ""
                            onClicked: root.openNote(fanStick.modelData.id)
                        }
                    }
                }

                Rectangle {
                    visible: root.activeNotes.length === 0
                    width: fullView.tabWidth
                    height: fullView.tabHeight
                    x: root.horizontalSticks ? fullView.firstHorizontalTabX : fullView.tabX
                    y: root.horizontalSticks ? fullView.tabY : fullView.tabStart
                    radius: 9
                    color: root.usesPlasmaAppearance ? root.systemBackgroundColour : "#303037"
                    border.color: root.usesPlasmaAppearance ? root.actionIconBorder : "#4c4c56"
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.horizontalSticks ? parent.width - 16 : fullView.tabHeight - 20
                        rotation: root.horizontalSticks ? 0 : -90
                        text: root.text("NEW NOTE", "НОВАЯ ЗАМЕТКА")
                        color: root.usesPlasmaAppearance ? root.systemTextColour : "#eaeaf0"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.createNote()
                    }
                }

                Rectangle {
                    id: addButton
                    width: 28
                    height: 28
                    x: root.horizontalSticks
                        ? LayoutContract.horizontalAddButtonX(fullView.width, width, root.stickEdge)
                        : LayoutContract.addButtonX(fullView.tabX, fullView.tabWidth, width, false)
                    y: LayoutContract.addButtonY(fullView.tabY, fullView.tabHeight, height, root.horizontalSticks)
                    radius: width / 2
                    z: 350
                    /**
                     * @brief The button is discoverable as soon as the fan itself is hovered.
                     *
                     * A direct hover makes the affordance fully opaque. The surrounding
                     * widget and stick states deliberately keep it at a quieter opacity,
                     * so users can head directly to its stable reserved lane.
                     */
                    property bool showControl: root.compactPointerInside || root.fanPointerInside
                        || root.hoveredId !== "" || addHandoffHover.hovered || addArea.containsMouse || addRevealTimer.running
                    color: "transparent"
                    border.width: 0
                    opacity: !showControl ? 0 : (addArea.containsMouse ? 1 : 0.52)
                    scale: showControl ? (addArea.containsMouse ? 1.04 : 1) : 0.25
                    transformOrigin: Item.Center

                    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    Timer {
                        id: addRevealTimer
                        interval: 180
                        repeat: false
                    }

                    Connections {
                        target: root
                        function onHoveredIdChanged() {
                            if (root.hoveredId === "") {
                                addRevealTimer.restart()
                            } else {
                                addRevealTimer.stop()
                            }
                        }
                    }

                    NotyIcon {
                        anchors.centerIn: parent
                        width: root.addIconSize
                        height: root.addIconSize
                        glyph: "plus"
                        color: root.actionIconColour
                        usePlasmaIconTheme: root.usePlasmaIconTheme
                    }

                    MouseArea {
                        id: addArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: addButton.showControl
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.createNote()
                        onExited: if (root.hoveredId === "") addRevealTimer.restart()
                        Accessible.role: Accessible.Button
                        Accessible.name: root.text("New note", "Новая заметка")
                    }
                }

                /**
                 * @brief Invisible hand-off lane between the first stick and add control.
                 *
                 * It keeps the add affordance alive while a pointer travels slowly
                 * through the otherwise empty ten-pixel gap.
                 */
                Item {
                    id: addHandoffZone
                    x: root.horizontalSticks
                        ? (root.stickEdge === "bottom"
                            ? fullView.firstHorizontalTabX + fullView.tabWidth
                            : addButton.x + addButton.width)
                        : fullView.tabX
                    y: root.horizontalSticks ? fullView.tabY : addButton.y + addButton.height
                    width: root.horizontalSticks
                        ? (root.stickEdge === "bottom"
                            ? Math.max(0, addButton.x - (fullView.firstHorizontalTabX + fullView.tabWidth))
                            : Math.max(0, fullView.tabStart - (addButton.x + addButton.width)))
                        : fullView.tabWidth
                    height: root.horizontalSticks
                        ? fullView.tabHeight
                        : Math.max(0, fullView.tabStart - (addButton.y + addButton.height))
                    z: 349

                    HoverHandler {
                        id: addHandoffHover
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onHoveredChanged: {
                            if (hovered) {
                                addRevealTimer.stop()
                            } else if (root.hoveredId === "" && !addArea.containsMouse) {
                                addRevealTimer.restart()
                            }
                        }
                    }
                }

            }

            /**
             * @brief Recovery sheet for locally archived notes.
             *
             * It is deliberately an inline overlay rather than a second Plasma
             * popup, so archive actions stay inside the same edge interaction
             * surface and cannot steal desktop context-menu clicks.
             */
            Rectangle {
                id: archiveDrawer
                anchors.fill: parent
                z: 60
                visible: root.archiveDrawerOpen && root.selectedId === ""
                opacity: visible ? 1 : 0
                scale: visible ? 1 : 0.98
                radius: 14
                color: root.colour(0).paper
                border.width: 1
                border.color: Qt.darker(color, 1.12)

                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            PlasmaComponents.Label {
                                text: root.text("Archive", "Архив")
                                color: root.colour(0).ink
                                font.pixelSize: root.noteFontSize + 3
                                font.family: root.noteFontFamily
                                font.bold: true
                            }
                            PlasmaComponents.Label {
                                text: root.archivedNotes.length === 0
                                    ? root.text("No archived notes", "Нет архивированных заметок")
                                    : root.archivedNotes.length + " " + root.text("saved here", "сохранено здесь")
                                color: root.colour(0).ink
                                opacity: 0.58
                                font.pixelSize: 10
                            }
                        }

                        Rectangle {
                            id: clearArchiveButton
                            Layout.preferredWidth: 118
                            Layout.preferredHeight: 32
                            radius: 16
                            enabled: root.archivedNotes.length > 0
                            opacity: enabled ? 1 : 0.45
                            color: clearArchiveArea.containsMouse ? Qt.lighter(archiveDrawer.color, 1.07) : Qt.rgba(1, 1, 1, 0.28)
                            border.width: 1
                            border.color: Qt.darker(archiveDrawer.color, 1.18)

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 5
                                NotyIcon {
                                    width: root.iconSizeXs
                                    height: root.iconSizeXs
                                    glyph: "trash-simple"
                                    color: root.actionIconColour
                                    usePlasmaIconTheme: root.usePlasmaIconTheme
                                }
                                Text {
                                    text: root.text("Clear archive", "Очистить архив")
                                    color: root.colour(0).ink
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }

                            MouseArea {
                                id: clearArchiveArea
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: clearArchiveButton.enabled
                                cursorShape: Qt.PointingHandCursor
                                onClicked: clearArchiveConfirmation.open()
                                Accessible.role: Accessible.Button
                                Accessible.name: root.text("Clear archive", "Очистить архив")
                            }
                        }

                        Item {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Qt.darker(archiveDrawer.color, 1.22)
                        opacity: 0.5
                    }

                    ScrollView {
                        id: archiveList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth

                        Column {
                            /** @brief Match the viewport, rather than the Flickable's implicit content width. */
                            width: archiveList.availableWidth
                            spacing: 6

                            Repeater {
                                model: root.archivedNotes

                                delegate: Rectangle {
                                    required property var modelData
                                    width: archiveList.availableWidth
                                    height: 58
                                    radius: 10
                                    color: rowArea.containsMouse ? Qt.lighter(archiveDrawer.color, 1.035) : Qt.rgba(1, 1, 1, 0.22)
                                    border.width: rowArea.containsMouse ? 1 : 0
                                    border.color: Qt.darker(archiveDrawer.color, 1.18)

                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    Rectangle {
                                        width: 14
                                        height: 14
                                        radius: 7
                                        anchors.left: parent.left
                                        anchors.leftMargin: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: root.stickColour(modelData.color)
                                        border.width: 1
                                        border.color: root.spineColour(modelData.color)
                                    }

                                    ColumnLayout {
                                        id: archiveNoteSummary
                                        anchors.left: parent.left
                                        anchors.leftMargin: 34
                                        anchors.right: actionButtons.left
                                        anchors.rightMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.title
                                            color: root.colour(modelData.color).ink
                                            font.family: root.noteFontFamily
                                            font.pixelSize: 12
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: root.archiveDateLabel(modelData.archivedAt)
                                            color: root.colour(modelData.color).ink
                                            opacity: 0.58
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Row {
                                        id: actionButtons
                                        anchors.right: parent.right
                                        anchors.rightMargin: 7
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        NotyActionButton {
                                            width: 28
                                            height: 28
                                            focusPolicy: Qt.NoFocus
                                            onClicked: root.restoreArchivedNote(modelData.id, true)
                                            Accessible.name: root.text("Restore and open", "Восстановить и открыть")
                                            glyph: "arrow-counter-clockwise"
                                            glyphSize: root.iconSizeXs
                                            glyphColor: root.actionIconColour
                                            outlineColor: root.actionIconBorder
                                            usePlasmaIconTheme: root.usePlasmaIconTheme
                                        }
                                        NotyActionButton {
                                            width: 28
                                            height: 28
                                            focusPolicy: Qt.NoFocus
                                            onClicked: root.deleteNote(modelData.id)
                                            Accessible.name: root.text("Delete permanently", "Удалить навсегда")
                                            glyph: "trash-simple"
                                            glyphSize: root.iconSizeXs
                                            glyphColor: root.actionIconColour
                                            outlineColor: root.actionIconBorder
                                            usePlasmaIconTheme: root.usePlasmaIconTheme
                                        }
                                    }

                                    MouseArea {
                                        id: rowArea
                                        anchors.left: parent.left
                                        anchors.right: actionButtons.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.restoreArchivedNote(modelData.id, true)
                                    }
                                }
                            }

                            Item {
                                visible: root.archivedNotes.length === 0
                                width: archiveList.availableWidth
                                height: 150

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    PlasmaComponents.Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: root.text("Nothing in archive", "Архив пуст")
                                        color: root.colour(0).ink
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                    }
                                    PlasmaComponents.Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: root.text("Archived notes can be restored here.", "Сюда можно вернуть архивированные заметки.")
                                        color: root.colour(0).ink
                                        opacity: 0.58
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }

                NotyActionButton {
                    id: closeArchiveButton
                    anchors.top: archiveDrawer.top
                    anchors.topMargin: 8
                    anchors.right: archiveDrawer.right
                    anchors.rightMargin: 8
                    width: 32
                    height: 32
                    z: 80
                    focusPolicy: Qt.NoFocus
                    onClicked: root.archiveDrawerOpen = false
                    Accessible.name: root.text("Close archive", "Закрыть архив")
                    glyph: "x"
                    glyphSize: root.cardActionIconSize
                    glyphColor: root.actionIconColour
                    outlineColor: root.actionIconBorder
                    usePlasmaIconTheme: root.usePlasmaIconTheme
                }

                ArchiveConfirmation {
                    id: clearArchiveConfirmation
                    z: 200
                    language: root.language
                    surfaceColor: archiveDrawer.color
                    inkColor: root.colour(0).ink
                    actionColor: root.actionIconColour
                    actionBorder: root.actionIconBorder
                    usePlasmaIconTheme: root.usePlasmaIconTheme
                    fontFamily: root.noteFontFamily
                    onClearRequested: root.clearArchivedNotes()
                }
            }

            /** @brief Brief recovery action shown immediately after archiving a card. */
            Rectangle {
                id: archiveUndoToast
                visible: root.archiveUndoVisible && !root.archiveDrawerOpen && root.selectedId === ""
                z: 70
                width: undoRow.implicitWidth + 18
                height: 32
                radius: 16
                x: Math.max(8, Math.min(parent.width - width - 8, parent.width / 2 - width / 2))
                y: parent.height - height - 10
                color: root.usesPlasmaAppearance ? root.systemBackgroundColour : "#302f35"
                border.width: 1
                border.color: root.usesPlasmaAppearance ? root.actionIconBorder : "#77747e"
                opacity: visible ? 0.98 : 0

                Behavior on opacity { NumberAnimation { duration: 150 } }

                Row {
                    id: undoRow
                    anchors.centerIn: parent
                    spacing: 7
                    Text {
                        text: root.text("Archived", "В архиве")
                        color: root.usesPlasmaAppearance ? root.systemTextColour : "#f7f5fa"
                        font.pixelSize: 11
                    }
                    Text {
                        text: root.text("Undo", "Отменить")
                        color: root.usesPlasmaAppearance ? root.systemHighlightColour : "#f7f5fa"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.undoArchive()
                    Accessible.role: Accessible.Button
                    Accessible.name: root.text("Undo archive", "Отменить архивирование")
                }
            }

            /**
             * @brief Persistent note switcher exposed beyond the open card.
             *
             * The active card covers the inner four pixels of every stick, so
             * the navigation reads as a continuation of the paper without ever
             * covering the header or archive action.
             */
            Item {
                id: cardStickNavigation
                anchors.fill: parent
                visible: root.selectedId !== ""
                z: 30

                Repeater {
                    model: root.cardNavigationNotes
                    delegate: Item {
                        id: cardStick
                        required property var modelData
                        required property int index
                        width: fullView.tabWidth
                        height: fullView.tabHeight
                        readonly property bool isSelectedStick: modelData.id === root.selectedId
                        readonly property bool isHoveredStick: root.hoveredId === modelData.id
                        readonly property var lift: LayoutContract.stickLift(root.stickEdge, isSelectedStick, isHoveredStick)
                        x: (root.horizontalSticks
                            ? LayoutContract.horizontalTabX(fullView.width, cardStick.width, index, fullView.fanTabPitch, fullView.tabStart, root.stickEdge)
                            : (root.stickEdge === "right" ? fullView.cardWidth - 4 : 0))
                        y: (root.horizontalSticks
                            ? fullView.tabY
                            : fullView.tabStart + index * fullView.fanTabPitch)
                        z: LayoutContract.stickLayer(index, isSelectedStick, isHoveredStick)

                        Rectangle {
                            width: cardStick.width
                            height: cardStick.height
                            x: cardStick.lift.x
                            y: cardStick.lift.y
                            radius: 9
                            color: root.stickColour(modelData.color)
                            border.width: modelData.id === root.selectedId ? 2 : 1
                            border.color: root.spineColour(modelData.color)
                            rotation: root.horizontalSticks ? 0
                                : ((cardStick.isHoveredStick || cardStick.isSelectedStick) ? 0 : (root.stickEdge === "right" ? -2 : 2))
                            scale: cardStick.isHoveredStick ? 1.035 : (cardStick.isSelectedStick ? 1.015 : 1)
                            transformOrigin: root.horizontalSticks ? Item.Top
                                : (root.stickEdge === "right" ? Item.Left : Item.Right)

                            Behavior on color { ColorAnimation { duration: 180 } }
                            Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                            Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                width: root.horizontalSticks ? parent.width - 16 : fullView.tabHeight - 28
                                // Counter-rotate the title so its letters do not inherit tab tilt.
                                rotation: root.horizontalSticks ? 0 : -90 - parent.rotation
                                visible: root.showStickTitles
                                text: modelData.title.toUpperCase()
                                color: root.colour(modelData.color).ink
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            width: root.horizontalSticks
                                ? LayoutContract.stickHitLength(cardStick.width, fullView.fanTabPitch, cardStick.index, root.cardNavigationNotes.length)
                                : cardStick.width
                            height: root.horizontalSticks
                                ? cardStick.height
                                : LayoutContract.stickHitLength(cardStick.height, fullView.fanTabPitch, cardStick.index, root.cardNavigationNotes.length)
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.hoveredId = cardStick.modelData.id
                            onExited: if (root.hoveredId === cardStick.modelData.id) root.hoveredId = ""
                            onClicked: root.openNote(cardStick.modelData.id)
                        }
                    }
                }
            }

            /** @brief Full paper editor displayed after selecting a fan tab. */
            Rectangle {
                id: noteCard
                visible: root.selectedId !== ""
                x: fullView.cardX
                y: fullView.cardY
                width: fullView.cardWidth
                height: fullView.cardHeight
                z: 20
                radius: 14
                color: root.selectedNote ? root.colour(root.selectedNote.color).paper : root.colour(0).paper
                border.color: Qt.darker(color, 1.08)

                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Item {
                    id: editorPane
                    visible: root.selectedId !== "" && root.selectedNote !== null
                    anchors.fill: parent
                    /** @brief Dark title spine that extends exactly to the perforation. */
                    Item {
                        id: titleSpine
                        width: 40
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        Rectangle {
                            id: roundedSpine
                            width: parent.width
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            radius: 14
                            color: root.selectedNote ? root.spineColour(root.selectedNote.color) : root.spineColour(0)

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 14
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            color: roundedSpine.color
                        }
                        Text {
                            anchors.centerIn: parent
                            width: parent.height - 28
                            rotation: -90
                            text: root.selectedNote ? root.selectedNote.title.toUpperCase() : ""
                            color: root.selectedNote ? root.colour(root.selectedNote.color).ink : root.colour(0).ink
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            opacity: 0.94
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    /** @brief Perforation separating the dark title spine from editable paper. */
                    Item {
                        id: spinePerforation
                        width: 2
                        anchors.left: titleSpine.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 14
                        anchors.bottomMargin: 14

                        Repeater {
                            model: Math.max(0, Math.floor(spinePerforation.height / 11))
                            delegate: Rectangle {
                                required property int index
                                width: 2
                                height: 6
                                y: index * 11
                                radius: 1
                                color: root.selectedNote ? root.perforationColour(root.selectedNote.color) : root.perforationColour(0)
                                opacity: 0.88
                            }
                        }
                    }
                    ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 60
                            anchors.rightMargin: 16
                            anchors.topMargin: 16
                            anchors.bottomMargin: 16
                            RowLayout {
                                Layout.fillWidth: true
                                TextField {
                                    id: titleEditor
                                    Layout.preferredWidth: 230
                                    Layout.fillWidth: true
                                    font.bold: true
                                    font.pixelSize: root.noteFontSize + 3
                                    font.family: root.noteFontFamily
                                    color: root.selectedNote ? root.colour(root.selectedNote.color).ink : root.colour(0).ink
                                    selectByMouse: true
                                    background: Rectangle { color: "transparent" }
                                    property bool loadingTitle: false
                                    property string loadedNoteId: ""
                                    function loadSelectedTitle() {
                                        const nextId = root.selectedNote ? root.selectedNote.id : ""
                                        if (nextId === loadedNoteId) {
                                            return
                                        }
                                        loadingTitle = true
                                        text = root.selectedNote ? root.selectedNote.title : ""
                                        loadedNoteId = nextId
                                        loadingTitle = false
                                    }
                                    Component.onCompleted: loadSelectedTitle()
                                    onEditingFinished: if (!loadingTitle && loadedNoteId === root.selectedId) root.updateTitle(root.selectedId, text)
                                    Connections {
                                        target: root
                                        function onSelectedNoteChanged() { titleEditor.loadSelectedTitle() }
                                    }
                                }
                                PlasmaComponents.Label {
                                    text: root.text("Saved · just now", "Сохранено · только что")
                                    color: root.selectedNote ? root.colour(root.selectedNote.color).ink : root.colour(0).ink
                                    opacity: 0.48
                                    font.pixelSize: 10
                                }
                                NotyActionButton {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    focusPolicy: Qt.NoFocus
                                    onClicked: root.closeNoteCard()
                                    Accessible.name: root.text("Collapse note", "Свернуть заметку")
                                    glyph: "x"
                                    glyphSize: root.cardActionIconSize
                                    glyphColor: root.actionIconColour
                                    outlineColor: root.actionIconBorder
                                    usePlasmaIconTheme: root.usePlasmaIconTheme
                                }
                            }
                            /**
                             * @brief Native Qt document engine with Notion-like visual block controls.
                             *
                             * The component owns no note model. It emits Markdown changes and task
                             * intents, while the established NoteStore remains the single source of truth.
                             */
                            NotionEditor {
                                id: editor
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                noteId: root.selectedId
                                markdown: root.selectedNote ? root.selectedNote.body : ""
                                paperColor: root.selectedNote ? root.colour(root.selectedNote.color).paper : root.colour(0).paper
                                inkColor: root.selectedNote ? root.colour(root.selectedNote.color).ink : root.colour(0).ink
                                selectionColor: root.usesPlasmaAppearance
                                    ? Qt.rgba(root.systemHighlightColour.r, root.systemHighlightColour.g, root.systemHighlightColour.b, 0.28)
                                    : Qt.rgba(0.16, 0.14, 0.11, 0.22)
                                actionIconColor: root.actionIconColour
                                actionIconOnDarkColor: root.actionIconOnDarkColour
                                actionIconBorder: root.actionIconBorder
                                noteFontFamily: root.noteFontFamily
                                noteFontSize: root.noteFontSize
                                ruled: root.selectedNote && root.selectedNote.ruled === true
                                usePlasmaIconTheme: root.usePlasmaIconTheme
                                placeholderText: root.text("Start writing…", "Начните писать…")
                                boldText: root.text("Bold", "Жирный")
                                italicText: root.text("Italic", "Курсив")
                                quoteText: root.text("Quote", "Цитата")
                                checklistText: root.text("Checklist", "Чек-лист")
                                toggleTaskPrefix: root.text("Toggle task: ", "Переключить задачу: ")
                                onMarkdownEdited: root.updateBody(root.selectedId, markdown)
                                onChecklistToggled: root.toggleMarkdownChecklist(root.selectedId, taskIndex)
                            }
                            /** @brief Bottom palette and a single non-destructive archive action. */
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                Repeater {
                                    model: root.palette.length
                                    delegate: Rectangle {
                                        required property int index
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: root.colour(index).dash
                                        border.width: root.selectedNote && root.selectedNote.color === index ? 3 : 0
                                        border.color: root.selectedNote ? root.colour(root.selectedNote.color).ink : "transparent"
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.setColor(root.selectedId, index)
                                        }
                                    }
                                }
                                NotyActionButton {
                                    id: ruledLinesButton
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    checkable: true
                                    checked: root.selectedNote && root.selectedNote.ruled === true
                                    focusPolicy: Qt.NoFocus
                                    onClicked: root.setRuled(root.selectedId, checked)
                                    Accessible.name: root.text("Toggle ruled paper", "Линейки в заметке")
                                    glyph: "list"
                                    glyphSize: root.cardActionIconSize
                                    glyphColor: root.actionIconColour
                                    outlineColor: root.actionIconBorder
                                    usePlasmaIconTheme: root.usePlasmaIconTheme
                                    opacity: ruledLinesButton.checked ? 1 : 0.7
                                }
                                Item { Layout.fillWidth: true }
                                Item {
                                    id: archiveButton
                                    /**
                                     * @brief Keeps archive and its secondary browser action in one hover zone.
                                     *
                                     * The primary action is icon-only. Hovering it reveals a subdued archive
                                     * browser on its left, so the two actions do not compete visually.
                                     */
                                    property bool controlsHovered: archiveArea.containsMouse
                                        || archiveHandoffArea.containsMouse || openArchiveArea.containsMouse
                                    property real animatedWidth: controlsHovered ? 158 : 32
                                    Layout.preferredWidth: animatedWidth
                                    Layout.preferredHeight: 32
                                    clip: false
                                    Accessible.role: Accessible.Button
                                    Accessible.name: root.text("Archive note", "Архивировать заметку")

                                    Behavior on animatedWidth {
                                        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                                    }

                                    Rectangle {
                                        id: openArchiveButton
                                        width: archiveButton.controlsHovered ? 118 : 0
                                        height: 32
                                        anchors.right: archiveIconButton.left
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        radius: 16
                                        visible: opacity > 0
                                        opacity: archiveButton.controlsHovered ? 1 : 0
                                        color: Qt.rgba(1, 1, 1, 0.10)
                                        border.width: 1
                                        border.color: root.actionIconBorder

                                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                        Behavior on opacity { NumberAnimation { duration: 110 } }

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            NotyIcon {
                                                width: root.iconSizeXs
                                                height: root.iconSizeXs
                                                glyph: "folder-open"
                                                color: root.actionIconColour
                                                usePlasmaIconTheme: root.usePlasmaIconTheme
                                            }
                                            Text {
                                                text: root.text("Open archive", "Открыть архив")
                                                color: root.actionIconColour
                                                font.pixelSize: 10
                                                font.weight: Font.Medium
                                            }
                                        }

                                        MouseArea {
                                            id: openArchiveArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.toggleArchiveDrawer()
                                            Accessible.role: Accessible.Button
                                            Accessible.name: root.text("Open archive", "Открыть архив")
                                        }
                                    }

                                    Rectangle {
                                        id: archiveIconButton
                                        width: 32
                                        height: 32
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        radius: 16
                                        color: "transparent"
                                        border.width: archiveArea.containsMouse ? 1 : 0
                                        border.color: root.actionIconBorder

                                        Behavior on border.width { NumberAnimation { duration: 120 } }

                                        NotyIcon {
                                            anchors.centerIn: parent
                                            width: root.cardActionIconSize
                                            height: root.cardActionIconSize
                                            glyph: "archive"
                                            color: root.actionIconColour
                                            usePlasmaIconTheme: root.usePlasmaIconTheme
                                        }

                                        MouseArea {
                                            id: archiveArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.archiveNote(root.selectedId)
                                        }
                                    }

                                    /** @brief Transparent bridge prevents the secondary action vanishing in its 8 pt gap. */
                                    MouseArea {
                                        id: archiveHandoffArea
                                        anchors.left: openArchiveButton.right
                                        anchors.right: archiveIconButton.left
                                        anchors.top: archiveIconButton.top
                                        anchors.bottom: archiveIconButton.bottom
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                    }

                                    /** @brief Local tooltip for the primary archive action, without Plasma's global style. */
                                    Rectangle {
                                        id: archiveTooltip
                                        width: tooltipText.implicitWidth + 20
                                        height: 26
                                        anchors.right: archiveIconButton.right
                                        anchors.bottom: archiveIconButton.top
                                        anchors.bottomMargin: 6
                                        radius: 8
                                        visible: opacity > 0
                                        opacity: archiveArea.containsMouse ? 1 : 0
                                        color: "#3f4c57"
                                        border.width: 1
                                        border.color: "#687783"

                                        Behavior on opacity { NumberAnimation { duration: 120 } }

                                        Text {
                                            id: tooltipText
                                            anchors.centerIn: parent
                                            text: root.text("Archive note", "Архивировать заметку")
                                            color: root.actionIconOnDarkColour
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                        }
                                    }
                                }
                            }
                    }
                }

            }
        }
    }

    fullRepresentation: noteView

    /**
     * @brief Popup used for the Planar desktop form factor.
     * @sideeffect Clears the selected editor when Plasma closes the popup after
     *             a focus change.
     */
    PlasmaCore.Dialog {
        id: noteDialog
        visualParent: root.dialogAnchor || root
        type: PlasmaCore.Dialog.Dock
        flags: Qt.FramelessWindowHint | Qt.Tool
        location: root.stickEdge === "left" ? PlasmaCore.Types.LeftEdge
            : root.stickEdge === "top" ? PlasmaCore.Types.TopEdge
            : root.stickEdge === "bottom" ? PlasmaCore.Types.BottomEdge
            : PlasmaCore.Types.RightEdge
        backgroundHints: PlasmaCore.Dialog.NoBackground
        color: Qt.rgba(0, 0, 0, 0)
        hideOnWindowDeactivate: LayoutContract.hidesDialogOnDeactivate(root.idleDisplayMode)
        visible: false
        onWidthChanged: root.scheduleDialogEdgeAlignment()
        onHeightChanged: root.scheduleDialogEdgeAlignment()
        onActiveChanged: {
            if (!active && root.keepSticksVisible && root.selectedId !== "") {
                root.closeNoteCard()
            }
        }
        onVisibleChanged: {
            root.scheduleDialogEdgeAlignment()
            if (!visible) {
                root.selectedId = ""
                root.selectedNote = null
                root.archiveDrawerOpen = false
                root.fanPointerInside = false
            }
        }

        mainItem: Item {
            /** @brief Supplies the same full-axis geometry before the async view loads. */
            readonly property int desiredWidth: root.archiveDrawerOpen ? 390
                : (root.selectedId === "" ? (root.horizontalSticks ? root.fixedNoteWidth : 58) : Math.max(root.horizontalSticks ? root.fixedNoteWidth : 58, root.selectedNoteWidth + (root.horizontalSticks ? 0 : 30)))
            readonly property int desiredHeight: root.archiveDrawerOpen ? 420
                : (root.selectedId === "" ? (root.horizontalSticks ? 58 : root.fixedNoteHeight) : Math.max(root.horizontalSticks ? 58 : root.fixedNoteHeight, root.selectedNoteHeight + (root.horizontalSticks ? 30 : 0)))
            width: desiredWidth
            height: desiredHeight

            Loader {
                anchors.fill: parent
                sourceComponent: noteView
            }
        }
    }
}
