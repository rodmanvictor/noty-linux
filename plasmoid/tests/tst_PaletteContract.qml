import QtQuick
import QtTest

import "../package/contents/ui/PaletteContract.js" as PaletteContract

/**
 * @brief Regression coverage for persisted palette customization rules.
 *
 * Tests use only pure JavaScript and cannot read or write the widget's KConfig
 * instance. They prove the first colour survives and ordered deletion can be
 * identified for note-colour fallback.
 */
TestCase {
    name: "PaletteContract"

    function test_defaults_are_stable_and_non_empty() {
        const palette = PaletteContract.fromJson("")
        compare(palette.length, 8)
        compare(palette[0].paper, "#fce795")
        compare(palette[0].dash, "#e0ad08")
        for (let index = 0; index < palette.length; index += 1) {
            verify(PaletteContract.contrastRatio(palette[index].paper, palette[index].ink) >= 4.5)
        }
    }

    function test_custom_colours_are_normalized_and_first_colour_cannot_die() {
        const start = PaletteContract.fromJson("")
        const appended = PaletteContract.append(start, "#abc")
        compare(appended.length, 9)
        compare(appended[8].paper, "#aabbcc")
        verify(appended[8].dash.length === 7)
        verify(appended[8].ink.length === 7)

        const protectedFirst = PaletteContract.remove(appended, 0)
        compare(protectedFirst.length, 9)
        compare(protectedFirst[0].paper, "#fce795")
    }

    function test_deleted_optional_colour_is_detected_by_order() {
        const before = PaletteContract.fromJson("")
        const after = PaletteContract.remove(before, 3)
        compare(after.length, before.length - 1)
        compare(PaletteContract.removedIndex(before, after), 3)
        compare(PaletteContract.removedIndex(before, PaletteContract.append(before, "#102030")), -1)
    }

    function test_optional_colours_reorder_without_displacing_the_default() {
        const before = PaletteContract.fromJson("")
        const after = PaletteContract.moveOptional(before, 1, 3)
        compare(after[0].paper, before[0].paper)
        compare(after[3].paper, before[1].paper)
        compare(after[1].paper, before[2].paper)

        const map = PaletteContract.reorderedIndexMap(before, after)
        compare(map.length, before.length)
        compare(map[0], 0)
        compare(map[1], 3)
        compare(map[2], 1)
        compare(map[3], 2)

        const rejected = PaletteContract.moveOptional(before, 0, 2)
        compare(rejected[0].paper, before[0].paper)
        compare(PaletteContract.reorderedIndexMap(before, before).length, 0)
    }

    function test_dark_theme_text_falls_back_to_note_ink_on_pastel_paper() {
        const entries = PaletteContract.fromJson("")
        for (let index = 0; index < entries.length; index += 1) {
            const resolvedInk = PaletteContract.readableInk(entries[index].paper, "#f5f5f5", entries[index].ink)
            verify(PaletteContract.contrastRatio(resolvedInk, entries[index].paper) >= 4.5)
        }

        const entry = entries[4]
        const resolved = PaletteContract.readableInk(entry.paper, "#f5f5f5", entry.ink)
        compare(resolved, entry.ink)
        verify(PaletteContract.contrastRatio(resolved, entry.paper) >= 4.5)

        const lightThemeResolved = PaletteContract.readableInk(entry.paper, "#1d1d1d", entry.ink)
        compare(lightThemeResolved, "#1d1d1d")
    }
}
