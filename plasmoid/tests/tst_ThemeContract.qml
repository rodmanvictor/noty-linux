pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import "../package/contents/ui/ThemeContract.js" as ThemeContract

/**
 * @brief Covers KConfig normalization for system-aware appearance and typography.
 *
 * The tests stay independent from a particular installed Plasma theme, while
 * proving that an 8 pt desktop font remains readable at Noty's 12 px floor.
 */
Item {
    TestCase {
        name: "ThemeContract"

        function test_adaptive_is_the_safe_default() {
            compare(ThemeContract.appearanceMode(undefined), "adaptive")
            compare(ThemeContract.appearanceMode("unexpected"), "adaptive")
            compare(ThemeContract.appearanceMode("noty"), "noty")
            compare(ThemeContract.appearanceMode("adaptive"), "adaptive")
            compare(ThemeContract.appearanceMode("plasma"), "plasma")
        }

        function test_system_font_size_has_a_readable_floor() {
            compare(ThemeContract.readableSystemPixelSize(8), 12)
            compare(ThemeContract.readableSystemPixelSize(9), 12)
            compare(ThemeContract.readableSystemPixelSize(12), 16)
            compare(ThemeContract.readableSystemPixelSize(undefined), 12)
        }

        function test_system_icon_theme_requires_an_explicit_opt_in() {
            verify(!ThemeContract.usesPlasmaIconTheme(undefined))
            verify(!ThemeContract.usesPlasmaIconTheme(false))
            verify(ThemeContract.usesPlasmaIconTheme(true))
        }
    }
}
