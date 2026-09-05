import QtQuick
import QtTest

import "../package/contents/ui/NoteStore.js" as NoteStore

/**
 * @brief Regression coverage for creating and saving notes without KConfig.
 *
 * The test never imports the installed applet instance, so it cannot modify a
 * user's existing notes while proving the same mutations used by main.qml.
 */
TestCase {
    name: "NoteStore"

    function test_create_uses_next_palette_colour() {
        const note = NoteStore.create([{ id: "first" }, { id: "second" }], "third", 8, "Untitled note")
        compare(note.id, "third")
        compare(note.title, "Untitled note")
        compare(note.body, "")
        compare(note.color, 2)
    }

    function test_save_preserves_explicit_title_and_body() {
        const before = [
            { id: "keep", title: "Keep", body: "unchanged", color: 1, pinned: false },
            { id: "edit", title: "Old", body: "", color: 3, pinned: false }
        ]
        const after = NoteStore.withBody(before, "edit", "  Новое название  \nТекст заметки")
        compare(after.length, 2)
        compare(after[0].body, "unchanged")
        compare(after[1].title, "Old")
        compare(after[1].body, "  Новое название  \nТекст заметки")
        compare(after[1].color, 3)
    }

    function test_title_and_archive_are_independent_operations() {
        const notes = [{ id: "note", title: "Old", body: "Body", color: 2, pinned: false }]
        const retitled = NoteStore.withTitle(notes, "note", "New title", "Untitled note")
        compare(retitled[0].title, "New title")
        compare(retitled[0].body, "Body")
        const archived = NoteStore.withArchived(retitled, "note", "2026-09-04T12:00:00.000Z")
        compare(archived[0].archived, true)
        compare(archived[0].archivedAt, "2026-09-04T12:00:00.000Z")
        compare(archived[0].title, "New title")
    }

    function test_archive_can_be_restored_or_expired_without_touching_active_notes() {
        const notes = [
            { id: "active", title: "Active", body: "", color: 0, pinned: false },
            { id: "old", title: "Old", body: "", color: 1, pinned: false },
            { id: "recent", title: "Recent", body: "", color: 2, pinned: false }
        ]
        const oldArchived = NoteStore.withArchived(notes, "old", "2026-09-04T10:00:00.000Z")
        const archived = NoteStore.withArchived(oldArchived, "recent", "2026-09-04T11:45:00.000Z")
        const retained = NoteStore.withoutExpiredArchived(archived, Date.parse("2026-09-04T12:00:00.000Z"), 30 * 60 * 1000)
        compare(retained.length, 2)
        compare(retained[0].id, "active")
        compare(retained[1].id, "recent")

        const restored = NoteStore.withRestored(retained, "recent")
        compare(restored[1].archived, false)
        compare(restored[1].archivedAt, null)
        compare(restored[1].title, "Recent")
    }

    function test_legacy_archived_note_without_timestamp_is_never_auto_deleted() {
        const legacy = [{ id: "legacy", title: "Legacy", body: "", color: 0, pinned: false, archived: true }]
        const retained = NoteStore.withoutExpiredArchived(legacy, Date.parse("2027-01-01T00:00:00.000Z"), 1)
        compare(retained.length, 1)
        compare(retained[0].id, "legacy")
    }

    function test_bulk_archive_cleanup_keeps_all_active_notes() {
        const notes = [
            { id: "active-one", title: "Active one", body: "", color: 0, pinned: false },
            { id: "archived", title: "Archived", body: "", color: 1, pinned: false, archived: true },
            { id: "active-two", title: "Active two", body: "", color: 2, pinned: false },
            { id: "legacy-archive", title: "Legacy", body: "", color: 3, pinned: false, archived: true }
        ]
        const retained = NoteStore.withoutArchived(notes)
        compare(retained.length, 2)
        compare(retained[0].id, "active-one")
        compare(retained[1].id, "active-two")
    }

    function test_markdown_checklists_toggle_inside_the_note_body() {
        const notes = [{ id: "note", title: "Plan", body: "Intro\n- [ ] Ship it\n- [x] Review", color: 2, pinned: false }]
        const completed = NoteStore.withToggledMarkdownChecklist(notes, "note", 0)
        compare(completed[0].body, "Intro\n- [x] Ship it\n- [x] Review")
        const reopened = NoteStore.withToggledMarkdownChecklist(completed, "note", 1)
        compare(reopened[0].body, "Intro\n- [x] Ship it\n- [ ] Review")
    }

    function test_legacy_checklists_migrate_to_markdown_without_losing_prose() {
        const notes = [{
            id: "note",
            title: "Plan",
            body: "Keep this prose",
            color: 2,
            pinned: false,
            checklist: [
                { id: "one", text: "Ship it", done: false },
                { id: "two", text: "Review", done: true }
            ]
        }]
        const migrated = NoteStore.migrateLegacyChecklists(notes)
        compare(migrated[0].body, "Keep this prose\n\n- [ ] Ship it\n- [x] Review")
        compare(migrated[0].checklist.length, 0)
    }

    function test_colour_and_delete_are_scoped_to_selected_note() {
        const notes = [
            { id: "a", title: "A", body: "", color: 0, pinned: false },
            { id: "b", title: "B", body: "", color: 1, pinned: false }
        ]
        const recoloured = NoteStore.withColor(notes, "b", 6)
        compare(recoloured[0].color, 0)
        compare(recoloured[1].color, 6)
        const remaining = NoteStore.without(recoloured, "a")
        compare(remaining.length, 1)
        compare(remaining[0].id, "b")
    }

    function test_ruled_paper_survives_other_mutations() {
        const notes = [{
            id: "note",
            title: "Plan",
            body: "Text",
            color: 1,
            pinned: false,
            ruled: true
        }]
        const recoloured = NoteStore.withColor(notes, "note", 5)
        compare(recoloured[0].ruled, true)
        const plainPaper = NoteStore.withRuled(recoloured, "note", false)
        compare(plainPaper[0].ruled, false)
        compare(plainPaper[0].body, "Text")
    }

    function test_deleted_palette_colour_falls_back_to_default_and_shifts_later_notes() {
        const notes = [
            { id: "first", title: "First", body: "", color: 0, pinned: false },
            { id: "deleted", title: "Deleted", body: "", color: 3, pinned: false },
            { id: "after", title: "After", body: "", color: 6, pinned: false }
        ]
        const remapped = NoteStore.withDeletedPaletteColour(notes, 3)
        compare(remapped[0].color, 0)
        compare(remapped[1].color, 0)
        compare(remapped[2].color, 5)
        compare(remapped[2].title, "After")
    }

    function test_reordered_palette_colours_keep_each_note_on_its_original_paper() {
        const notes = [
            { id: "default", title: "Default", body: "", color: 0, pinned: false },
            { id: "orange", title: "Orange", body: "", color: 1, pinned: false },
            { id: "pink", title: "Pink", body: "", color: 2, pinned: false },
            { id: "purple", title: "Purple", body: "", color: 3, pinned: false }
        ]
        const remapped = NoteStore.withRemappedPaletteColour(notes, [0, 3, 1, 2])
        compare(remapped[0].color, 0)
        compare(remapped[1].color, 3)
        compare(remapped[2].color, 1)
        compare(remapped[3].color, 2)
    }
}
