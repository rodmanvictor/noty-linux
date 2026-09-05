pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import "../package/contents/ui/I18n.js" as I18n

/**
 * @brief Verifies the complete per-widget language list and translation fallback.
 *
 * These tests exercise the same JavaScript module used by main.qml and the
 * Plasma configuration page, so a missing option or malformed locale cannot
 * silently fall back to English after installation.
 */
Item {
    TestCase {
        name: "I18n"

        function test_all_requested_languages_are_available() {
            const options = I18n.languageOptions()
            compare(options.length, 10)
            compare(options.map(function(option) { return option.code }).join(","),
                "en,ru,es,id,de,fr,pt,zh,ja,hi")
            compare(I18n.languageIndex("hi"), 9)
            compare(I18n.languageIndex("zh-CN"), 7)
        }

        function test_codes_are_normalized_and_unknown_values_are_safe() {
            compare(I18n.normalize("ES-es"), "es")
            compare(I18n.normalize("ja-JP"), "ja")
            compare(I18n.normalize("unknown"), "en")
            compare(I18n.normalize(undefined), "en")
        }

        function test_translations_cover_widget_and_settings_surfaces() {
            compare(I18n.text("de", "Archive", "Архив"), "Archiv")
            compare(I18n.text("fr", "Open archive", "Открыть архив"), "Ouvrir l’archive")
            compare(I18n.text("es", "Use Plasma system font", "Использовать системный шрифт Plasma"),
                "Usar la fuente del sistema Plasma")
            compare(I18n.text("id", "Clear archive?", "Очистить архив?"), "Bersihkan arsip?")
            compare(I18n.text("zh", "Checklist", "Чек-лист"), "清单")
            compare(I18n.text("ja", "Cancel", "Отмена"), "キャンセル")
            compare(I18n.text("hi", "Delete permanently", "Удалить навсегда"), "स्थायी रूप से हटाएँ")
            compare(I18n.text("ru", "Archive", "Архив"), "Архив")
            compare(I18n.text("en", "Archive", "Архив"), "Archive")
        }
    }
}
