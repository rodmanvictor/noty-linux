import QtQuick
import QtTest

import "../package/contents/ui/LayoutContract.js" as LayoutContract

/**
 * @brief Verifies edge geometry and transparency defaults without Plasma state.
 *
 * These assertions cover the visible contract of the desktop widget: the
 * default deck opens from the right edge into the desktop and horizontal
 * placement stays deterministic for top and bottom edges.
 */
TestCase {
    name: "LayoutContract"

    function test_default_fan_opens_from_right_to_left() {
        compare(LayoutContract.fanDirection(undefined), "rightToLeft")
        verify(LayoutContract.opensRightToLeft(undefined))
        compare(LayoutContract.fanTabX(58, 34, undefined), 24)
    }

    function test_left_to_right_fan_anchors_its_tabs_to_the_left() {
        compare(LayoutContract.fanDirection("leftToRight"), "leftToRight")
        verify(!LayoutContract.opensRightToLeft("leftToRight"))
        compare(LayoutContract.fanTabX(58, 34, "leftToRight"), 0)
    }

    function test_stick_edge_uses_right_by_default_and_preserves_legacy_left() {
        compare(LayoutContract.stickEdge(undefined, undefined), "right")
        compare(LayoutContract.stickEdge(undefined, "leftToRight"), "left")
        compare(LayoutContract.stickEdge("left", undefined), "left")
    }

    function test_horizontal_edges_use_horizontal_sticks() {
        verify(LayoutContract.horizontalSticks("top"))
        verify(LayoutContract.horizontalSticks("bottom"))
        verify(!LayoutContract.horizontalSticks("right"))
        compare(LayoutContract.horizontalTabY(58, 34, "top"), 0)
        compare(LayoutContract.horizontalTabY(58, 34, "bottom"), 24)
        compare(LayoutContract.horizontalTabY(510, 34, "bottom"), 476)
    }

    function test_bottom_deck_mirrors_the_add_lane_and_tab_direction() {
        compare(LayoutContract.horizontalTabX(640, 112, 0, 71, 42, "top"), 42)
        compare(LayoutContract.horizontalTabX(640, 112, 1, 71, 42, "top"), 113)
        compare(LayoutContract.horizontalAddButtonX(640, 28, "top"), 4)

        compare(LayoutContract.horizontalTabX(640, 112, 0, 71, 42, "bottom"), 486)
        compare(LayoutContract.horizontalTabX(640, 112, 1, 71, 42, "bottom"), 415)
        compare(LayoutContract.horizontalAddButtonX(640, 28, "bottom"), 608)
    }

    function test_idle_display_has_three_exclusive_modes() {
        compare(LayoutContract.idleDisplayMode(undefined), "trafficLight")
        compare(LayoutContract.idleDisplayMode("trafficLight"), "trafficLight")
        compare(LayoutContract.idleDisplayMode("sticks"), "sticks")
        compare(LayoutContract.idleDisplayMode("hidden"), "hidden")
        compare(LayoutContract.idleDisplayMode("unsupported"), "trafficLight")
        verify(LayoutContract.keepsFanVisible("sticks"))
        verify(!LayoutContract.keepsFanVisible("trafficLight"))
        verify(!LayoutContract.keepsFanVisible("hidden"))
        verify(!LayoutContract.hidesDialogOnDeactivate("sticks"))
        verify(LayoutContract.hidesDialogOnDeactivate("trafficLight"))
        verify(LayoutContract.hidesDialogOnDeactivate("hidden"))
    }

    function test_add_button_is_centered_on_the_stick_lane() {
        compare(LayoutContract.addButtonX(24, 34, 28, false), 27)
        compare(LayoutContract.addButtonY(0, 112, 28, false), 4)
        compare(LayoutContract.addButtonX(42, 112, 28, true), 4)
        compare(LayoutContract.addButtonY(24, 34, 28, true), 27)
    }

    function test_full_axis_pitch_spreads_sparse_sticks_and_overlaps_dense_decks() {
        compare(LayoutContract.distributedTabPitch(480, 112, 3, 42), 142)
        compare(LayoutContract.distributedTabPitch(480, 112, 5, 42), 71)
        compare(LayoutContract.distributedTabPitch(480, 112, 6, 42), 56)
        verify(LayoutContract.distributedTabPitch(480, 112, 5, 42) < 112)
        verify(LayoutContract.distributedTabPitch(480, 112, 6, 42) < LayoutContract.distributedTabPitch(480, 112, 5, 42))
    }

    function test_compact_indicator_uses_the_outer_side_of_a_large_grid_cell() {
        compare(LayoutContract.compactX(64, 12, "right"), 52)
        compare(LayoutContract.compactX(64, 12, "left"), 0)
        compare(LayoutContract.compactY(432, 112, "right"), 160)
        compare(LayoutContract.compactY(432, 112, "left"), 160)
        compare(LayoutContract.compactX(112, 42, "top"), 35)
        compare(LayoutContract.compactY(64, 12, "top"), 0)
        compare(LayoutContract.compactY(64, 12, "bottom"), 52)
    }

    function test_popup_anchor_uses_the_exact_outer_boundary() {
        compare(LayoutContract.popupAnchorX(64, "right"), 64)
        compare(LayoutContract.popupAnchorX(64, "left"), 0)
        compare(LayoutContract.popupAnchorX(64, "top"), 32)
        compare(LayoutContract.popupAnchorY(432, "right"), 216)
        compare(LayoutContract.popupAnchorY(64, "top"), 0)
        compare(LayoutContract.popupAnchorY(64, "bottom"), 64)
    }

    function test_dialog_axis_is_flush_with_the_configured_screen_edge() {
        compare(LayoutContract.dialogEdgeAxisPosition(32, 1440, 58, "top"), 32)
        compare(LayoutContract.dialogEdgeAxisPosition(32, 1440, 58, "bottom"), 1414)
        compare(LayoutContract.dialogEdgeAxisPosition(-1920, 2560, 640, "left"), -1920)
        compare(LayoutContract.dialogEdgeAxisPosition(-1920, 2560, 640, "right"), 0)
    }

    function test_hovered_and_selected_sticks_rise_and_pull_outward() {
        compare(LayoutContract.stickLayer(2, false, false), 98)
        compare(LayoutContract.stickLayer(2, true, false), 200)
        compare(LayoutContract.stickLayer(2, false, true), 300)

        compare(LayoutContract.stickLift("right", false, true).x, -8)
        compare(LayoutContract.stickLift("right", true, false).x, -4)
        compare(LayoutContract.stickLift("left", false, true).x, 8)
        compare(LayoutContract.stickLift("top", false, true).y, 8)
        compare(LayoutContract.stickLift("bottom", false, true).y, -8)
    }

    function test_all_fan_sticks_fill_the_available_axis_without_overflowing() {
        compare(LayoutContract.distributedTabPitch(480, 112, 4, 42), 94)
        compare(LayoutContract.distributedTabPitch(480, 112, 6, 42), 56)
        compare(42 + 5 * LayoutContract.distributedTabPitch(480, 112, 6, 42) + 112, 434)

        compare(LayoutContract.stickHitLength(112, 72, 0, 4), 72)
        compare(LayoutContract.stickHitLength(112, 72, 2, 4), 72)
        compare(LayoutContract.stickHitLength(112, 72, 3, 4), 112)
    }

    function test_fixed_note_dimensions_stay_above_the_usable_minimum() {
        compare(LayoutContract.fixedNoteDimension(undefined, 420, 640), 640)
        compare(LayoutContract.fixedNoteDimension(300, 420, 640), 420)
        compare(LayoutContract.fixedNoteDimension(802.6, 420, 640), 803)
    }

}
