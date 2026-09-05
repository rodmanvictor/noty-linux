import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs

import org.kde.kirigami as Kirigami

import "I18n.js" as I18n
import "PaletteContract.js" as PaletteContract
import "ThemeContract.js" as ThemeContract

/**
 * @brief Appearance controls rendered by Plasma's widget configuration dialog.
 *
 * `cfg_language`, `cfg_paletteJson` and note typography values are synchronized
 * with matching KConfig entries. Language applies to the entire widget; the
 * fan surface is transparent and the first palette colour remains the fallback.
 */
Kirigami.FormLayout {
    id: appearanceSettings
    property string cfg_language: "en"
    // Plasma supplies every KConfig value to the current category component.
    // These non-rendered bridge fields accept entries used by main.qml.
    property string cfg_notesJson: ""
    property string cfg_notesJsonDefault: ""
    property string cfg_languageDefault: "en"
    property string cfg_fanDirection: "rightToLeft"
    property string cfg_fanDirectionDefault: "rightToLeft"
    property string cfg_stickEdge: "right"
    property string cfg_stickEdgeDefault: "right"
    property bool cfg_showStickTitles: true
    property bool cfg_showStickTitlesDefault: true
    property string cfg_idleDisplayMode: "trafficLight"
    property string cfg_idleDisplayModeDefault: "trafficLight"
    property int cfg_fixedNoteWidth: 640
    property int cfg_fixedNoteWidthDefault: 640
    property int cfg_fixedNoteHeight: 480
    property int cfg_fixedNoteHeightDefault: 480
    property string cfg_paletteJson: ""
    property string cfg_paletteJsonDefault: ""
    property int cfg_noteFontSize: 12
    property int cfg_noteFontSizeDefault: 12
    property string cfg_noteFontFamily: "Noto Sans"
    property string cfg_noteFontFamilyDefault: "Noto Sans"
    property bool cfg_useSystemNoteFont: true
    property bool cfg_useSystemNoteFontDefault: true
    property string cfg_appearanceMode: "adaptive"
    property string cfg_appearanceModeDefault: "adaptive"
    property bool cfg_usePlasmaIconTheme: false
    property bool cfg_usePlasmaIconThemeDefault: false
    property string cfg_archiveRetention: "never"
    property string cfg_archiveRetentionDefault: "never"
    property string title: ""
    /** @brief Parsed ordered palette displayed by the colour management controls. */
    readonly property var paletteEntries: PaletteContract.fromJson(cfg_paletteJson)
    /** @brief Plasma's current default font, used unless the user makes an explicit override. */
    readonly property var systemDefaultFont: Kirigami.Theme.defaultFont
    /** @brief Readable body size calculated from the desktop point size. */
    readonly property int systemNoteFontSize: ThemeContract.readableSystemPixelSize(systemDefaultFont.pointSize)
    /** @brief Safe label for the desktop-selected typeface. */
    readonly property string systemNoteFontFamily: systemDefaultFont.family || "Noto Sans"
    /** @brief Neutral Phosphor tint or the current Plasma text colour, matching selected mode. */
    readonly property color settingsIconColour: cfg_appearanceMode === "noty" ? "#667784" : Kirigami.Theme.textColor
    /** @brief XS icon token used by compact configuration actions. */
    readonly property int settingsIconSize: 16

    /**
     * @brief Resolves a settings label in the selected interface language.
     * @param {string} english English source string and dictionary key.
     * @param {string} russian Russian legacy fallback retained for compatibility.
     * @returns {string} Localized settings text.
     */
    function text(english, russian) {
        return I18n.text(cfg_language, english, russian)
    }

    /**
     * @brief Writes a validated palette to the configuration bridge.
     * @param entries User-edited colour entries.
     */
    function savePalette(entries) {
        cfg_paletteJson = PaletteContract.toJson(entries)
    }

    /**
     * @brief Resolves the local vector source unless the user enabled Plasma icons.
     * @param {string} localPath Relative bundled Phosphor icon path.
     * @returns {url|string} Local source or an empty value for a themed icon.
     */
    function actionIconSource(localPath) {
        return cfg_usePlasmaIconTheme ? "" : Qt.resolvedUrl(localPath)
    }

    /**
     * @brief Provides a FreeDesktop icon name only for the explicit theme opt-in.
     * @param {string} iconName KDE/Breeze semantic icon name.
     * @returns {string} The supplied name or an empty string for bundled vectors.
     */
    function actionIconName(iconName) {
        return cfg_usePlasmaIconTheme ? iconName : ""
    }

    Kirigami.Separator {
        Kirigami.FormData.label: appearanceSettings.text("Interface", "Интерфейс")
        Kirigami.FormData.isSection: true
    }

    QQC2.ComboBox {
        id: languageChooser
        Kirigami.FormData.label: appearanceSettings.text("Language:", "Язык:")
        model: I18n.languageOptions()
        textRole: "text"
        currentIndex: I18n.languageIndex(cfg_language)
        onActivated: cfg_language = model[currentIndex].code
    }

    Kirigami.Separator {
        Kirigami.FormData.label: appearanceSettings.text("Typography", "Типографика")
        Kirigami.FormData.isSection: true
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: appearanceSettings.text("Font source:", "Источник:")
        text: appearanceSettings.text("Use Plasma system font", "Использовать системный шрифт Plasma")
        checked: cfg_useSystemNoteFont
        onToggled: cfg_useSystemNoteFont = checked
    }

    QQC2.SpinBox {
        from: 10
        to: 24
        stepSize: 1
        editable: true
        value: cfg_noteFontSize
        enabled: !cfg_useSystemNoteFont
        Kirigami.FormData.label: appearanceSettings.text("Text size:", "Размер текста:")
        onValueModified: {
            cfg_noteFontSize = value
            cfg_useSystemNoteFont = false
        }
    }

    QQC2.Label {
        visible: cfg_useSystemNoteFont
        text: systemNoteFontFamily + " · " + systemNoteFontSize + " px"
        Kirigami.FormData.label: appearanceSettings.text("Current:", "Текущий:")
        Accessible.description: appearanceSettings.text("System size ", "Системный размер ")
            + systemDefaultFont.pointSize
            + appearanceSettings.text(" pt is used with a ", " pt используется с минимумом ")
            + systemNoteFontSize
            + appearanceSettings.text(" px minimum.", " px.")
    }

    Loader {
        active: !cfg_useSystemNoteFont
        visible: active
        Kirigami.FormData.label: appearanceSettings.text("Family:", "Гарнитура:")
        sourceComponent: Component {
            QQC2.Button {
                text: cfg_noteFontFamily
                icon.source: appearanceSettings.actionIconSource("icons/text-aa.svg")
                icon.color: appearanceSettings.settingsIconColour
                icon.width: appearanceSettings.settingsIconSize
                icon.height: appearanceSettings.settingsIconSize
                onClicked: {
                    fontPicker.selectedFont = Qt.font({ family: cfg_noteFontFamily, pixelSize: cfg_noteFontSize })
                    fontPicker.open()
                }
                Accessible.name: appearanceSettings.text("Choose note typeface", "Выбрать шрифт заметок")

                HoverHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.label: appearanceSettings.text("Appearance", "Вид")
        Kirigami.FormData.isSection: true
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: appearanceSettings.text("Style:", "Стиль:")
        model: [
            { text: "Noty", code: "noty" },
            { text: "Adaptive", code: "adaptive" },
            { text: "Plasma", code: "plasma" }
        ]
        textRole: "text"
        currentIndex: cfg_appearanceMode === "noty" ? 0 : cfg_appearanceMode === "plasma" ? 2 : 1
        onActivated: cfg_appearanceMode = model[currentIndex].code
        Accessible.name: appearanceSettings.text("Appearance style", "Стиль оформления")
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: appearanceSettings.text("Icons:", "Иконки:")
        text: appearanceSettings.text("Use Plasma icon theme", "Использовать тему иконок Plasma")
        checked: cfg_usePlasmaIconTheme
        onToggled: cfg_usePlasmaIconTheme = checked
        Accessible.description: appearanceSettings.text(
            "Experimental: replaces bundled Phosphor vectors with the active Plasma icon theme.",
            "Экспериментально: заменяет локальные Phosphor на иконки активной темы Plasma."
        )
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: appearanceSettings.text("Edge:", "Край:")
        model: [
            { text: appearanceSettings.text("Right", "Справа"), code: "right" },
            { text: appearanceSettings.text("Left", "Слева"), code: "left" },
            { text: appearanceSettings.text("Top", "Сверху"), code: "top" },
            { text: appearanceSettings.text("Bottom", "Снизу"), code: "bottom" }
        ]
        textRole: "text"
        currentIndex: cfg_stickEdge === "left" ? 1 : cfg_stickEdge === "top" ? 2 : cfg_stickEdge === "bottom" ? 3 : 0
        onActivated: cfg_stickEdge = model[currentIndex].code
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: appearanceSettings.text("Sticks:", "Стики:")
        text: appearanceSettings.text("Show note titles", "Показывать названия заметок")
        checked: cfg_showStickTitles
        onToggled: cfg_showStickTitles = checked
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: appearanceSettings.text("While idle:", "В покое:")
        model: [
            { text: appearanceSettings.text("Traffic light", "Светофор"), code: "trafficLight" },
            { text: appearanceSettings.text("Always show sticks", "Всегда показывать стики"), code: "sticks" },
            { text: appearanceSettings.text("Hidden until hover", "Скрыть до наведения"), code: "hidden" }
        ]
        textRole: "text"
        currentIndex: cfg_idleDisplayMode === "sticks" ? 1 : cfg_idleDisplayMode === "hidden" ? 2 : 0
        onActivated: cfg_idleDisplayMode = model[currentIndex].code
    }

    Kirigami.Separator {
        Kirigami.FormData.label: appearanceSettings.text("Fixed note size", "Фиксированный размер")
        Kirigami.FormData.isSection: true
    }

    QQC2.SpinBox {
        from: 420
        to: 1600
        stepSize: 20
        editable: true
        value: cfg_fixedNoteWidth
        Kirigami.FormData.label: appearanceSettings.text("Width:", "Ширина:")
        onValueModified: cfg_fixedNoteWidth = value
    }

    QQC2.SpinBox {
        from: 300
        to: 1200
        stepSize: 20
        editable: true
        value: cfg_fixedNoteHeight
        Kirigami.FormData.label: appearanceSettings.text("Height:", "Высота:")
        onValueModified: cfg_fixedNoteHeight = value
    }

    Kirigami.Separator {
        Kirigami.FormData.label: appearanceSettings.text("Archive", "Архив")
        Kirigami.FormData.isSection: true
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: appearanceSettings.text("Keep archived notes:", "Хранить заметки:")
        model: [
            { text: appearanceSettings.text("Forever", "Всегда"), code: "never" },
            { text: appearanceSettings.text("30 minutes", "30 минут"), code: "30m" },
            { text: appearanceSettings.text("1 day", "1 день"), code: "1d" },
            { text: appearanceSettings.text("7 days", "7 дней"), code: "7d" },
            { text: appearanceSettings.text("30 days", "30 дней"), code: "30d" }
        ]
        textRole: "text"
        currentIndex: cfg_archiveRetention === "30m" ? 1
            : cfg_archiveRetention === "1d" ? 2
            : cfg_archiveRetention === "7d" ? 3
            : cfg_archiveRetention === "30d" ? 4 : 0
        onActivated: cfg_archiveRetention = model[currentIndex].code
    }

    Kirigami.Separator {
        Kirigami.FormData.label: appearanceSettings.text("Colours", "Цвета")
        Kirigami.FormData.isSection: true
    }

    Column {
        id: paletteEditor
        Kirigami.FormData.label: appearanceSettings.text("Palette:", "Палитра:")
        width: parent.width
        spacing: 6
        /** @brief Selected swatch whose edit, reorder and delete controls are active. */
        property int selectedIndex: 0
        readonly property int currentIndex: Math.max(0, Math.min(selectedIndex,
            Math.max(0, appearanceSettings.paletteEntries.length - 1)))

        QQC2.Label {
            width: paletteEditor.width
            text: appearanceSettings.text(
                "The first colour is the permanent default. Select another colour to edit, reorder or remove it.",
                "Первый цвет — основной. Выберите другой цвет, чтобы изменить, переставить или удалить его."
            )
            wrapMode: Text.WordWrap
            opacity: 0.72
        }

        Flickable {
            id: paletteStrip
            width: paletteEditor.width
            height: 28
            contentWidth: paletteRow.width
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentWidth > width
            QQC2.ScrollBar.horizontal: QQC2.ScrollBar {
                policy: QQC2.ScrollBar.AsNeeded
            }

            Row {
                id: paletteRow
                height: paletteStrip.height
                spacing: 4

                Repeater {
                    model: appearanceSettings.paletteEntries

                    delegate: QQC2.Button {
                        required property var modelData
                        required property int index
                        width: 24
                        height: 24
                        y: 2
                        padding: 0
                        checkable: true
                        checked: paletteEditor.currentIndex === index
                        hoverEnabled: true
                        background: Rectangle {
                            radius: width / 2
                            color: modelData.paper
                            border.width: parent.checked ? 2 : 1
                            border.color: modelData.ink
                        }
                        contentItem: Item { }
                        onClicked: paletteEditor.selectedIndex = index
                        Accessible.name: appearanceSettings.text("Select colour ", "Выбрать цвет ") + (index + 1)

                        HoverHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                QQC2.Button {
                    width: 24
                    height: 24
                    y: 2
                    padding: 0
                    icon.source: appearanceSettings.actionIconSource("icons/plus-circle.svg")
                    icon.name: appearanceSettings.actionIconName("list-add")
                    icon.color: appearanceSettings.settingsIconColour
                    icon.width: appearanceSettings.settingsIconSize
                    icon.height: appearanceSettings.settingsIconSize
                    display: QQC2.AbstractButton.IconOnly
                    onClicked: {
                        palettePicker.editedIndex = -1
                        palettePicker.selectedColor = "#fce795"
                        palettePicker.open()
                    }
                    Accessible.name: appearanceSettings.text("Add colour", "Добавить цвет")

                    HoverHandler {
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        Row {
            spacing: 5

            QQC2.Button {
                text: appearanceSettings.text("Edit", "Изменить")
                icon.source: appearanceSettings.actionIconSource("icons/palette.svg")
                icon.name: appearanceSettings.actionIconName("color-management")
                icon.color: appearanceSettings.settingsIconColour
                icon.width: appearanceSettings.settingsIconSize
                icon.height: appearanceSettings.settingsIconSize
                onClicked: {
                    palettePicker.editedIndex = paletteEditor.currentIndex
                    palettePicker.selectedColor = appearanceSettings.paletteEntries[paletteEditor.currentIndex].paper
                    palettePicker.open()
                }
                Accessible.name: appearanceSettings.text("Edit selected colour", "Изменить выбранный цвет")

                HoverHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }
            }

            QQC2.Button {
                text: "←"
                enabled: paletteEditor.currentIndex > 1
                onClicked: {
                    const movedTo = paletteEditor.currentIndex - 1
                    appearanceSettings.savePalette(PaletteContract.moveOptional(
                        appearanceSettings.paletteEntries, paletteEditor.currentIndex, movedTo))
                    paletteEditor.selectedIndex = movedTo
                }
                Accessible.name: appearanceSettings.text("Move colour left", "Переместить цвет левее")

                HoverHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }
            }

            QQC2.Button {
                text: "→"
                enabled: paletteEditor.currentIndex > 0
                    && paletteEditor.currentIndex < appearanceSettings.paletteEntries.length - 1
                onClicked: {
                    const movedTo = paletteEditor.currentIndex + 1
                    appearanceSettings.savePalette(PaletteContract.moveOptional(
                        appearanceSettings.paletteEntries, paletteEditor.currentIndex, movedTo))
                    paletteEditor.selectedIndex = movedTo
                }
                Accessible.name: appearanceSettings.text("Move colour right", "Переместить цвет правее")

                HoverHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }
            }

            QQC2.Button {
                enabled: paletteEditor.currentIndex > 0
                padding: 0
                icon.source: appearanceSettings.actionIconSource("icons/trash-simple.svg")
                icon.name: appearanceSettings.actionIconName("edit-delete")
                icon.color: appearanceSettings.settingsIconColour
                icon.width: appearanceSettings.settingsIconSize
                icon.height: appearanceSettings.settingsIconSize
                display: QQC2.AbstractButton.IconOnly
                onClicked: {
                    const deleted = paletteEditor.currentIndex
                    appearanceSettings.savePalette(PaletteContract.remove(
                        appearanceSettings.paletteEntries, deleted))
                    paletteEditor.selectedIndex = Math.max(0, deleted - 1)
                }
                Accessible.name: appearanceSettings.text("Remove selected colour", "Удалить выбранный цвет")

                HoverHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    ColorDialog {
        id: palettePicker
        property int editedIndex: -1
        title: appearanceSettings.text("Choose colour", "Выберите цвет")
        onAccepted: {
            const chosen = selectedColor.toString()
            const next = editedIndex < 0
                ? PaletteContract.append(appearanceSettings.paletteEntries, chosen)
                : PaletteContract.replace(appearanceSettings.paletteEntries, editedIndex, chosen)
            appearanceSettings.savePalette(next)
        }
    }

    FontDialog {
        id: fontPicker
        title: appearanceSettings.text("Choose typeface", "Выберите шрифт")
        onAccepted: {
            cfg_noteFontFamily = selectedFont.family
            cfg_useSystemNoteFont = false
        }
    }
}
