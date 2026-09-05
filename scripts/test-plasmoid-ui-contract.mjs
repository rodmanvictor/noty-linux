/**
 * @fileoverview Source-level regression checks for Plasma-only visual contracts.
 *
 * QML unit tests cover pure geometry. This companion verifies that main.qml
 * actually consumes those contracts for transparent surfaces, edge placement,
 * idle presentation and the native Qt Markdown editor with compact block controls.
 */

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const mainQml = readFileSync(new URL("../plasmoid/package/contents/ui/main.qml", import.meta.url), "utf8");
const notionEditor = readFileSync(new URL("../plasmoid/package/contents/ui/NotionEditor.qml", import.meta.url), "utf8");
const paletteContract = readFileSync(new URL("../plasmoid/package/contents/ui/PaletteContract.js", import.meta.url), "utf8");
const noteStore = readFileSync(new URL("../plasmoid/package/contents/ui/NoteStore.js", import.meta.url), "utf8");
const themeContract = readFileSync(new URL("../plasmoid/package/contents/ui/ThemeContract.js", import.meta.url), "utf8");
const i18n = readFileSync(new URL("../plasmoid/package/contents/ui/I18n.js", import.meta.url), "utf8");
const plasmaIconNames = readFileSync(new URL("../plasmoid/package/contents/ui/PlasmaIconNames.js", import.meta.url), "utf8");
const notyIcon = readFileSync(new URL("../plasmoid/package/contents/ui/NotyIcon.qml", import.meta.url), "utf8");
const phosphorPaths = readFileSync(new URL("../plasmoid/package/contents/ui/PhosphorPaths.js", import.meta.url), "utf8");
const notyActionButton = readFileSync(new URL("../plasmoid/package/contents/ui/NotyActionButton.qml", import.meta.url), "utf8");
const archiveConfirmation = readFileSync(new URL("../plasmoid/package/contents/ui/ArchiveConfirmation.qml", import.meta.url), "utf8");
const configGeneral = readFileSync(new URL("../plasmoid/package/contents/ui/configGeneral.qml", import.meta.url), "utf8");
const configXml = readFileSync(new URL("../plasmoid/package/contents/config/main.xml", import.meta.url), "utf8");
const iconLicense = readFileSync(new URL("../plasmoid/package/contents/ui/icons/LICENSE", import.meta.url), "utf8");
const phosphorRegularAssets = [
    "plus", "plus-circle", "archive", "folder-open", "arrow-counter-clockwise", "trash-simple",
    "check-square", "text-b", "text-italic", "text-aa", "palette", "quotes", "list", "x"
];

for (const glyph of phosphorRegularAssets) {
    const svg = readFileSync(new URL(`../plasmoid/package/contents/ui/icons/${glyph}.svg`, import.meta.url), "utf8");
    assert.match(svg, /<svg[^>]*viewBox="0 0 256 256"[^>]*fill="currentColor"/, `${glyph} must bundle a Phosphor Regular SVG asset`);
}
assert.match(iconLicense, /MIT License[\s\S]*?Copyright \(c\) 2023 Phosphor Icons/, "bundled Phosphor assets must retain their MIT license");

/**
 * Fails with a named requirement when a visual contract disappears from QML.
 * @param {RegExp} pattern Required source pattern.
 * @param {string} requirement Human-readable regression condition.
 * @returns {void}
 */
function assertContract(pattern, requirement) {
    assert.match(mainQml, pattern, requirement);
}

/**
 * Fails with a named requirement when a NotionEditor contract disappears.
 * @param {RegExp} pattern Required component source pattern.
 * @param {string} requirement Human-readable regression condition.
 * @returns {void}
 */
function assertEditorContract(pattern, requirement) {
    assert.match(notionEditor, pattern, requirement);
}

assert.doesNotMatch(configXml, /<entry name="transparentFan"/, "transparent fan must not expose a misleading background toggle");
assert.match(configXml, /<entry name="fanDirection" type="String">[\s\S]*?<default>rightToLeft<\/default>/, "fan direction must default to right-to-left");
assert.match(configXml, /<entry name="stickEdge" type="String">[\s\S]*?<default>right<\/default>/, "sticks must default to the right edge");
assert.match(configXml, /<entry name="showStickTitles" type="Bool">[\s\S]*?<default>true<\/default>/, "stick titles must default to visible");
assert.match(configXml, /<entry name="idleDisplayMode" type="String">[\s\S]*?<default>trafficLight<\/default>/, "closed state must expose the three-way idle presentation setting");
assert.match(configXml, /<entry name="fixedNoteWidth" type="Int">[\s\S]*?<default>640<\/default>/, "settings must expose one shared fixed note width");
assert.match(configXml, /<entry name="fixedNoteHeight" type="Int">[\s\S]*?<default>480<\/default>/, "settings must expose one shared fixed note height");
assert.match(configXml, /<entry name="paletteJson" type="String">/, "settings must persist the user-configured palette");
assert.match(configXml, /<entry name="noteFontSize" type="Int">[\s\S]*?<default>12<\/default>/, "note text must default to a compact 12 px size");
assert.match(configXml, /<entry name="noteFontFamily" type="String">[\s\S]*?<default>Noto Sans<\/default>/, "note typography must define a stable default typeface");
assert.match(configXml, /<entry name="useSystemNoteFont" type="Bool">[\s\S]*?<default>true<\/default>/, "new and existing notes must follow Plasma's system font by default");
assert.match(configXml, /<entry name="appearanceMode" type="String">[\s\S]*?<default>adaptive<\/default>/, "Adaptive must be the default Plasma-aware visual system");
assert.match(configXml, /<entry name="usePlasmaIconTheme" type="Bool">[\s\S]*?<default>false<\/default>/, "the icon theme experiment must require an explicit opt-in");
assert.match(configXml, /<entry name="archiveRetention" type="String">[\s\S]*?<default>never<\/default>/, "archives must default to indefinite recovery rather than accidental deletion");
assert.match(configXml, /<entry name="language" type="String">[\s\S]*?en, ru, es, id, de, fr, pt, zh, ja or hi/, "configuration must document every supported interface language");
assert.match(i18n, /code: "en"[\s\S]*?code: "ru"[\s\S]*?code: "es"[\s\S]*?code: "id"[\s\S]*?code: "de"[\s\S]*?code: "fr"[\s\S]*?code: "pt"[\s\S]*?code: "zh"[\s\S]*?code: "ja"[\s\S]*?code: "hi"/, "the shared i18n module must expose all requested locales");
assert.match(i18n, /function normalize\(value\)[\s\S]*?split\("-"\)\[0\][\s\S]*?return "en"/, "locale normalization must strip regions and fall back to English");
assert.match(mainQml, /import "I18n\.js" as I18n[\s\S]*?readonly property string language: I18n\.normalize[\s\S]*?function text\(english, russian\)[\s\S]*?return I18n\.text\(language, english, russian\)/, "the widget must resolve every visible label through the shared i18n module");
assert.match(configGeneral, /import "I18n\.js" as I18n[\s\S]*?function text\(english, russian\)[\s\S]*?return I18n\.text\(cfg_language, english, russian\)[\s\S]*?model: I18n\.languageOptions\(\)[\s\S]*?currentIndex: I18n\.languageIndex\(cfg_language\)/, "settings must use the same locale list and translation helper as the widget");
assert.match(archiveConfirmation, /import "I18n\.js" as I18n[\s\S]*?property string language[\s\S]*?function text\(english, russian\)[\s\S]*?I18n\.text/, "archive confirmation must follow the selected interface language");
assertContract(/Plasmoid\.backgroundHints: PlasmaCore\.Types\.NoBackground/, "applet surface must always be transparent");
assertContract(/Plasmoid\.userBackgroundHints: PlasmaCore\.Types\.NoBackground/, "containment override must always remain transparent");
assertContract(/backgroundHints: PlasmaCore\.Dialog\.NoBackground[\s\S]*?color: Qt\.rgba\(0, 0, 0, 0\)/, "dialog window and Plasma surface must both be transparent");
assertContract(/id: noteDialog[\s\S]*?type: PlasmaCore\.Dialog\.Dock[\s\S]*?flags: Qt\.FramelessWindowHint \| Qt\.Tool[\s\S]*?backgroundHints: PlasmaCore\.Dialog\.NoBackground/, "transparent edge surface must stay a frameless Dock popup so KWin does not paint a tool-window background");
assertContract(/readonly property string stickEdge: LayoutContract\.stickEdge\(Plasmoid\.configuration\.stickEdge, fanDirection\)/, "stick edge must be normalized from settings");
assertContract(/readonly property bool horizontalSticks: LayoutContract\.horizontalSticks\(stickEdge\)/, "top and bottom edge must switch to horizontal sticks");
assertContract(/readonly property string idleDisplayMode: LayoutContract\.idleDisplayMode\(Plasmoid\.configuration\.idleDisplayMode\)/, "idle presentation must be normalized from settings");
assertContract(/readonly property bool keepSticksVisible: LayoutContract\.keepsFanVisible\(idleDisplayMode\)/, "sticks-only mode must keep the fan visible");
assertContract(/preferredRepresentation: compactRepresentation[\s\S]*?hideOnWindowDeactivate: LayoutContract\.hidesDialogOnDeactivate\(idleDisplayMode\)/, "the applet itself must preserve focus for persistent sticks");
assertContract(/hideOnWindowDeactivate: LayoutContract\.hidesDialogOnDeactivate\(root\.idleDisplayMode\)[\s\S]*?onActiveChanged:[\s\S]*?!active && root\.keepSticksVisible && root\.selectedId !== ""[\s\S]*?root\.closeNoteCard\(\)/, "persistent sticks must not reopen on desktop focus changes, while an open card still collapses");
assert.doesNotMatch(mainQml, /persistentFanTimer/, "persistent sticks must never use a close-and-reopen timer that steals desktop menus");
assertContract(/id: hiddenFanCloseTimer[\s\S]*?root\.idleDisplayMode === "hidden"[\s\S]*?!root\.compactPointerInside[\s\S]*?!root\.fanPointerInside[\s\S]*?noteDialog\.visible = false/, "hidden mode must close after the pointer leaves both the edge trigger and fan");
assertContract(/onEntered:[\s\S]*?root\.compactPointerInside = true[\s\S]*?hiddenFanCloseTimer\.stop\(\)[\s\S]*?onExited:[\s\S]*?root\.compactPointerInside = false[\s\S]*?root\.scheduleHiddenFanClose\(\)/, "the transparent edge trigger must own a bounded hover lifetime");
assertContract(/visible: root\.showTrafficLight[\s\S]*?opacity: noteDialog\.visible \? 0 : 0\.94/, "traffic light must fade while the fan is open");
assertContract(/color: root\.stickColour\(modelData\.color\)/, "traffic-light marks and note sticks must share the same colour function");
assertContract(/readonly property var palette: PaletteContract\.fromJson\(Plasmoid\.configuration\.paletteJson\)[\s\S]*?function reconcilePaletteChange\(\)[\s\S]*?PaletteContract\.removedIndex\(appliedPalette, palette\)[\s\S]*?NoteStore\.withDeletedPaletteColour\(notes, removedIndex\)/, "palette settings must drive the deck and remap notes whose colour was deleted");
assertContract(/id: popupAnchor[\s\S]*?LayoutContract\.popupAnchorX\(parent\.width, root\.stickEdge\)[\s\S]*?root\.dialogAnchor = popupAnchor/, "dialog must retain a one-pixel compact anchor as its transient parent");
assertContract(/visualParent: root\.dialogAnchor \|\| root/, "dialog must use the outer-edge anchor instead of the full Plasma cell");
assertContract(/function alignDialogToScreenEdge\(\)[\s\S]*?root\.availableScreenRect[\s\S]*?root\.stickEdge === "top" \|\| root\.stickEdge === "bottom"[\s\S]*?noteDialog\.y = LayoutContract\.dialogEdgeAxisPosition[\s\S]*?noteDialog\.x = LayoutContract\.dialogEdgeAxisPosition[\s\S]*?onStickEdgeChanged: scheduleDialogEdgeAlignment\(\)[\s\S]*?onAvailableScreenRectChanged: scheduleDialogEdgeAlignment\(\)[\s\S]*?onScreenGeometryChanged: scheduleDialogEdgeAlignment\(\)[\s\S]*?id: dialogEdgeAlignmentTimer[\s\S]*?onHeightChanged: root\.scheduleDialogEdgeAlignment\(\)[\s\S]*?onVisibleChanged: \{[\s\S]*?root\.scheduleDialogEdgeAlignment\(\)/, "Dock dialog must be rechecked after geometry and work-area changes");
assertContract(/x: LayoutContract\.compactX\(parent\.width, width, root\.stickEdge\)[\s\S]*?y: LayoutContract\.compactY\(parent\.height, height, root\.stickEdge\)/, "traffic light must align with the configured outer edge inside an oversized Plasma cell");
assertContract(/visible: root\.showStickTitles/, "stick titles must obey their setting");
assertContract(/PlasmaCore\.Types\.TopEdge[\s\S]*PlasmaCore\.Types\.BottomEdge/, "dialog must support top and bottom edge placement");
assertContract(/LayoutContract\.horizontalTabX\(fullView\.width, fanStick\.width, index, fullView\.fanTabPitch, fullView\.tabStart, root\.stickEdge\)/, "horizontal sticks must mirror their tab direction for the selected edge");
assertContract(/id: cardStickNavigation[\s\S]*?visible: root\.selectedId !== ""[\s\S]*?onClicked: root\.openNote\(cardStick\.modelData\.id\)/, "open cards must keep clickable note sticks outside the paper");
assertContract(/id: fanPane[\s\S]*?LayoutContract\.stickLift\(root\.stickEdge, false, isHoveredStick\)[\s\S]*?LayoutContract\.stickLayer\(index, false, isHoveredStick\)/, "hovered closed-fan sticks must pull outward above their neighbours");
assertContract(/id: cardStickNavigation[\s\S]*?LayoutContract\.stickLift\(root\.stickEdge, isSelectedStick, isHoveredStick\)[\s\S]*?LayoutContract\.stickLayer\(index, isSelectedStick, isHoveredStick\)/, "selected and hovered card sticks must pull outward above their neighbours");
assertContract(/id: fanStick[\s\S]*?rotation: root\.horizontalSticks \? 0 : -90 - parent\.rotation/, "idle vertical stick titles must counter-rotate against their tab tilt");
assertContract(/id: cardStick[\s\S]*?rotation: root\.horizontalSticks \? 0 : -90 - parent\.rotation/, "open-card vertical stick titles must counter-rotate against their unchanged tab tilt");
assertContract(/readonly property var visibleNotes: activeNotes[\s\S]*?readonly property var cardNavigationNotes: visibleNotes/, "all active fan sticks must remain present and retain the same order after a card opens");
assertContract(/readonly property int deckLength: root\.horizontalSticks \? root\.fixedNoteWidth : root\.fixedNoteHeight[\s\S]*?readonly property int fanTabPitch: LayoutContract\.distributedTabPitch\([\s\S]*?deckLength, tabLength, root\.visibleNotes\.length, tabStart[\s\S]*?readonly property int firstHorizontalTabX: LayoutContract\.horizontalTabX/, "the fan must allocate the full widget axis and distribute every stick across it");
assertContract(/readonly property int tabY: root\.horizontalSticks[\s\S]*?LayoutContract\.horizontalTabY\(height, tabHeight, root\.stickEdge\)[\s\S]*?id: cardStickNavigation[\s\S]*?y: \(root\.horizontalSticks[\s\S]*?fullView\.tabY/, "a Bottom deck must stay anchored to the lower edge after its note card opens");
assertContract(/id: addButton[\s\S]*?LayoutContract\.horizontalAddButtonX\(fullView\.width, width, root\.stickEdge\)[\s\S]*?property bool showControl: root\.compactPointerInside \|\| root\.fanPointerInside[\s\S]*?addHandoffHover\.hovered \|\| addArea\.containsMouse/, "the add control must become discoverable as soon as the widget is hovered");
assertContract(/readonly property int iconSizeXs: 16[\s\S]*?readonly property int addIconSize: 22[\s\S]*?readonly property int cardActionIconSize: iconSizeXs[\s\S]*?readonly property color actionIconColour: usesPlasmaAppearance/, "the icon system must expose one standard size, one deliberate add-action size and a mode-aware colour token");
assertContract(/id: addButton[\s\S]*?width: 28[\s\S]*?height: 28[\s\S]*?color: "transparent"[\s\S]*?border\.width: 0[\s\S]*?opacity: !showControl \? 0 : \(addArea\.containsMouse \? 1 : 0\.52\)[\s\S]*?NotyIcon \{[\s\S]*?anchors\.centerIn: parent[\s\S]*?width: root\.addIconSize[\s\S]*?glyph: "plus"[\s\S]*?color: root\.actionIconColour/, "the add control must keep a 28 pt hit area around a prominent 22 pt Phosphor glyph without a duplicate fill or border");
assertContract(/id: addButton[\s\S]*?id: addHandoffZone[\s\S]*?root\.stickEdge === "bottom"[\s\S]*?id: addHandoffHover/, "the Phosphor add control must retain its mirrored pointer hand-off lane");
assertContract(/id: fanPane[\s\S]*?Rectangle \{[\s\S]*?x: fanStick\.lift\.x[\s\S]*?MouseArea \{[\s\S]*?LayoutContract\.stickHitLength\(fanStick\.height, fullView\.fanTabPitch/, "closed-fan animation must move only its visual while its hit zone remains stable");
assertContract(/id: cardStickNavigation[\s\S]*?LayoutContract\.horizontalTabX\(fullView\.width, cardStick\.width, index, fullView\.fanTabPitch, fullView\.tabStart, root\.stickEdge\)[\s\S]*?Rectangle \{[\s\S]*?x: cardStick\.lift\.x[\s\S]*?MouseArea \{[\s\S]*?LayoutContract\.stickHitLength\(cardStick\.height, fullView\.fanTabPitch/, "open-card sticks must reuse the full-axis mirrored pitch with stable hit zones");
assertContract(/readonly property int fixedNoteWidth: LayoutContract\.fixedNoteDimension\([\s\S]*?readonly property int fixedNoteHeight: LayoutContract\.fixedNoteDimension\([\s\S]*?readonly property int selectedNoteWidth: fixedNoteWidth[\s\S]*?readonly property int selectedNoteHeight: fixedNoteHeight/, "every card must use the shared fixed dimensions from settings");
assertContract(/id: noteCard[\s\S]*?width: fullView\.cardWidth[\s\S]*?height: fullView\.cardHeight[\s\S]*?z: 20/, "the paper must cover only the inner edge of the persistent switcher");
assert.doesNotMatch(mainQml, /id: resizeHandle|Qt\.SizeFDiagCursor|function updateDimensions|liveResize/, "fixed-size cards must not expose a manual resize interaction");
assertContract(/readonly property font systemDefaultFont: Kirigami\.Theme\.defaultFont[\s\S]*?readonly property int systemDefaultNoteFontSize: ThemeContract\.readableSystemPixelSize\(systemDefaultFont\.pointSize\)[\s\S]*?readonly property int noteFontSize: configuredFontSize\([\s\S]*?Plasmoid\.configuration\.useSystemNoteFont !== false[\s\S]*?function configuredFontSize\(value, useSystemFont\)[\s\S]*?if \(useSystemFont\)[\s\S]*?systemDefaultNoteFontSize[\s\S]*?Math\.max\(10, Math\.min\(24, candidate\)\)/, "note typography must follow the system font by default with a legible 12 px floor and preserve manual bounds");
assertContract(/readonly property string appearanceMode: ThemeContract\.appearanceMode\(Plasmoid\.configuration\.appearanceMode\)[\s\S]*?readonly property bool usesAdaptiveAppearance: appearanceMode === "adaptive"[\s\S]*?readonly property bool usesPlasmaAppearance: appearanceMode === "plasma"[\s\S]*?function colour\(index\)[\s\S]*?usesPlasmaAppearance[\s\S]*?return entry/, "appearance modes must retain a shared, palette-based note surface contract");
assertContract(/function colour\(index\)[\s\S]*?if \(usesPlasmaAppearance\)[\s\S]*?return \{ paper: entry\.paper, ink: plasmaInkFor\(entry\), dash: entry\.dash \}[\s\S]*?function plasmaInkFor\(entry\)[\s\S]*?PaletteContract\.readableInk\(entry\.paper, systemTextColour\.toString\(\), entry\.ink\)/, "Plasma must preserve coloured paper and fall back from unreadable dark-theme text instead of rendering black cards");
assertContract(/function stickColour\(index\)[\s\S]*?return Qt\.darker\(colour\(index\)\.paper, 1\.08\)[\s\S]*?function spineColour\(index\)[\s\S]*?return Qt\.darker\(colour\(index\)\.paper, 1\.14\)[\s\S]*?function perforationColour\(index\)[\s\S]*?return Qt\.darker\(colour\(index\)\.paper, 1\.34\)/, "Plasma sticks, spines and perforation must stay derived from each selected note paper");
assertContract(/id: archiveDrawer[\s\S]*?color: root\.colour\(0\)\.paper[\s\S]*?ArchiveConfirmation \{[\s\S]*?surfaceColor: archiveDrawer\.color/, "Plasma archive and its confirmation must inherit the readable paper surface");
assertContract(/id: archiveDrawer[\s\S]*?color: root\.colour\(0\)\.paper/, "the archive surface must use the active visual-system paper rather than bypassing Plasma mode with a raw palette colour");
assertContract(/id: titleEditor[\s\S]*?font\.pixelSize: root\.noteFontSize \+ 3[\s\S]*?font\.family: root\.noteFontFamily[\s\S]*?NotionEditor \{[\s\S]*?noteFontFamily: root\.noteFontFamily[\s\S]*?noteFontSize: root\.noteFontSize/, "selected typography must apply coherently to title and NotionEditor body");
assertContract(/NotionEditor \{[\s\S]*?markdown: root\.selectedNote \? root\.selectedNote\.body : ""[\s\S]*?onMarkdownEdited: root\.updateBody\(root\.selectedId, markdown\)[\s\S]*?onChecklistToggled: root\.toggleMarkdownChecklist\(root\.selectedId, taskIndex\)/, "the card must delegate one Markdown document and task intents to NotionEditor while NoteStore remains authoritative");
assertEditorContract(/TextArea \{[\s\S]*?textFormat: TextEdit\.MarkdownText[\s\S]*?selectByMouse: true[\s\S]*?selectByKeyboard: true[\s\S]*?persistentSelection: true[\s\S]*?onTextChanged:[\s\S]*?control\.markdownEdited\(text\)/, "NotionEditor must retain Qt's stock editable Markdown document and normal persistence signal");
assertEditorContract(/id: formatBubble[\s\S]*?hasSelection: editor\.selectedText\.length > 0[\s\S]*?visible: opacity > 0[\s\S]*?height: 34[\s\S]*?glyph: "text-b"[\s\S]*?glyph: "text-italic"[\s\S]*?glyph: "quotes"[\s\S]*?glyph: "check-square"/, "the contextual bubble must appear only for a selection and contain the four supported Qt/Markdown actions");
assertEditorContract(/id: taskBlock[\s\S]*?Accessible\.role: Accessible\.CheckBox[\s\S]*?radius: 5[\s\S]*?cursorShape: Qt\.PointingHandCursor[\s\S]*?control\.requestChecklistToggle/, "task blocks must use one larger rounded control with pointer, keyboard and accessibility support");
assertEditorContract(/renderedQuoteEntries: EditorContract\.quoteEntries[\s\S]*?Quiet vertical rules[\s\S]*?width: 3/, "quote blocks must derive their visual rule from the same rendered Markdown document");
assert.doesNotMatch(notionEditor, /property bool editingMarkdown/, "NotionEditor must not switch into a raw Markdown source mode");
assertContract(/function stickColour\(index\)[\s\S]*?Qt\.darker\(colour\(index\)\.paper, 1\.08\)/, "sticks must stay close to the note paper tone");
assertContract(/function spineColour\(index\)[\s\S]*?Qt\.darker\(colour\(index\)\.paper, 1\.14\)/, "title spine must be only one restrained step darker than its stick");
assertContract(/id: titleSpine[\s\S]*?width: 40[\s\S]*?root\.spineColour\(root\.selectedNote\.color\)[\s\S]*?anchors\.leftMargin: 14[\s\S]*?rotation: -90/, "title spine must be narrower, use the soft palette and read bottom-to-top");
assertContract(/id: spinePerforation[\s\S]*?width: 2[\s\S]*?root\.perforationColour\(root\.selectedNote\.color\)[\s\S]*?opacity: 0\.88/, "perforation must be thicker and use a darker tone of the current paper");
assertContract(/readonly property int cardActionIconSize: iconSizeXs/, "each note must expose the shared 16 pt Phosphor Regular icon size");
assert.match(notionEditor, /id: ruledPaper[\s\S]*?visible: control\.ruled[\s\S]*?Math\.ceil\(ruledPaper\.height \/ 28\)/, "the native editor must retain the ruled-paper surface inside the note card");
assertContract(/id: ruledLinesButton[\s\S]*?Layout\.preferredWidth: 32[\s\S]*?root\.setRuled\(root\.selectedId, checked\)[\s\S]*?glyph: "list"[\s\S]*?glyphSize: root\.cardActionIconSize/, "each note must toggle ruled paper with the shared 16 pt Phosphor Regular icon");
assertContract(/onClicked: root\.closeNoteCard\(\)[\s\S]*?Accessible\.name: root\.text\("Collapse note", "Свернуть заметку"\)[\s\S]*?glyph: "x"[\s\S]*?glyphSize: root\.cardActionIconSize/, "the card header must collapse with the selected Phosphor x icon at the same scale as footer actions");
assertContract(/id: archiveButton[\s\S]*?controlsHovered: archiveArea\.containsMouse[\s\S]*?archiveHandoffArea\.containsMouse \|\| openArchiveArea\.containsMouse[\s\S]*?animatedWidth: controlsHovered \? 158 : 32[\s\S]*?id: openArchiveButton[\s\S]*?anchors\.right: archiveIconButton\.left[\s\S]*?glyph: "folder-open"[\s\S]*?text: root\.text\("Open archive", "Открыть архив"\)[\s\S]*?onClicked: root\.toggleArchiveDrawer\(\)[\s\S]*?id: archiveIconButton[\s\S]*?glyph: "archive"[\s\S]*?id: archiveHandoffArea[\s\S]*?id: archiveTooltip[\s\S]*?anchors\.bottom: archiveIconButton\.top[\s\S]*?text: root\.text\("Archive note", "Архивировать заметку"\)/, "archive must be icon-only, show its local tooltip above and reveal the secondary archive browser on the left without a hover gap");
assertContract(/id: archiveIconButton[\s\S]*?color: "transparent"[\s\S]*?border\.width: archiveArea\.containsMouse \? 1 : 0[\s\S]*?glyph: "archive"/, "archive icon must remain visually bare until its subtle hover outline appears");
assert.doesNotMatch(mainQml, /archiveButton[\s\S]{0,500}ToolTip/, "archive action must not use Plasma's oversized tooltip");
assertContract(/function archiveNote\(id\)[\s\S]*?NoteStore\.withArchived\(notes, id, new Date\(\)\.toISOString\(\)\)[\s\S]*?archiveUndoTimer\.restart\(\)/, "archiving must persist a timestamp and offer a bounded undo");
assertContract(/function restoreArchivedNote\(id, openAfterRestore\)[\s\S]*?NoteStore\.withRestored\(notes, id\)/, "archive recovery must restore the exact local note");
assertContract(/function purgeExpiredArchives\(\)[\s\S]*?NoteStore\.withoutExpiredArchived\(notes, Date\.now\(\), retentionMs\)/, "retention cleanup must remove only notes that are past their configured lifetime");
assert.doesNotMatch(mainQml, /id: archiveDeckButton/, "archive access must not compete with the deck's add-note control");
assertContract(/function clearArchivedNotes\(\)[\s\S]*?NoteStore\.withoutArchived\(notes\)/, "bulk archive cleanup must retain active notes");
assertContract(/id: archiveDrawer[\s\S]*?id: clearArchiveButton[\s\S]*?text: root\.text\("Clear archive", "Очистить архив"\)[\s\S]*?clearArchiveConfirmation\.open\(\)[\s\S]*?id: archiveList[\s\S]*?contentWidth: availableWidth[\s\S]*?width: archiveList\.availableWidth[\s\S]*?text: modelData\.title[\s\S]*?root\.restoreArchivedNote\(modelData\.id, true\)[\s\S]*?root\.deleteNote\(modelData\.id\)[\s\S]*?id: closeArchiveButton[\s\S]*?anchors\.top: archiveDrawer\.top[\s\S]*?anchors\.right: archiveDrawer\.right[\s\S]*?onClicked: root\.archiveDrawerOpen = false[\s\S]*?glyph: "x"[\s\S]*?ArchiveConfirmation \{[\s\S]*?id: clearArchiveConfirmation[\s\S]*?onClearRequested: root\.clearArchivedNotes\(\)/, "archive drawer must use an absolute top-right x and the local confirmation component while retaining full-width rows");
assert.match(archiveConfirmation, /Item \{[\s\S]*?property bool opened: false[\s\S]*?color: Qt\.lighter\(control\.surfaceColor, 1\.035\)[\s\S]*?objectName: "cancelArchiveAction"[\s\S]*?objectName: "clearArchiveAction"[\s\S]*?control\.clearRequested\(\)/, "archive cleanup confirmation must stay light, local and separately testable");
assert.doesNotMatch(mainQml, /id: clearArchiveConfirmation[\s\S]{0,220}?\bDialog\s*\{/, "archive cleanup must not inherit a mismatched native dialog surface");
assert.doesNotMatch(mainQml, /Back to notes|К заметкам/, "the archive drawer must not retain the old back-to-notes button");
assert.match(notyIcon, /import QtQuick\.Shapes[\s\S]*?Phosphor Icons Core 2\.1\.1[\s\S]*?property bool usePlasmaIconTheme: false[\s\S]*?Kirigami\.Icon \{[\s\S]*?visible: root\.usePlasmaIconTheme[\s\S]*?Shape \{[\s\S]*?visible: !root\.usePlasmaIconTheme[\s\S]*?width: 256[\s\S]*?scale: Math\.min[\s\S]*?preferredRendererType: Shape\.CurveRenderer[\s\S]*?ShapePath \{[\s\S]*?fillColor: root\.color[\s\S]*?PathSvg \{[\s\S]*?PhosphorPaths\.forGlyph\(root\.glyph\)/, "the shared icon component must keep bundled Phosphor vectors as its fallback while allowing an explicit Plasma-theme source");
assert.doesNotMatch(notyIcon, /isMask:|layer\.effect:\s*MultiEffect|Image\s*\{/, "the icon component must not use texture masks or raster effects that produce opaque squares");
for (const glyph of ["archive", "arrow-counter-clockwise", "check-square", "folder-open", "list", "palette", "plus", "plus-circle", "quotes", "text-aa", "text-b", "text-italic", "trash-simple", "x"]) {
    assert.match(phosphorPaths, new RegExp(`"${glyph}": "M`), `the vector map must include ${glyph}`);
}
assert.match(notyActionButton, /PlasmaComponents\.ToolButton[\s\S]*?property string glyph[\s\S]*?property int glyphSize: 16[\s\S]*?property color glyphColor: "#667784"[\s\S]*?contentItem: Item[\s\S]*?NotyIcon \{[\s\S]*?width: control\.glyphSize[\s\S]*?height: control\.glyphSize[\s\S]*?background: Rectangle[\s\S]*?control\.hovered[\s\S]*?border\.width/, "standard actions must keep the ToolButton hit area separate from the centred, token-sized Phosphor glyph");
assert.match(notyActionButton, /HoverHandler[\s\S]*?acceptedDevices: PointerDevice\.Mouse \| PointerDevice\.TouchPad[\s\S]*?cursorShape: Qt\.PointingHandCursor/, "every shared icon button must expose the native pointing-hand cursor");
assert.doesNotMatch(notyActionButton, /contentItem:\s*NotyIcon/, "ToolButton must never stretch the glyph itself to the full control bounds");
assertContract(/id: ruledLinesButton[\s\S]*?glyph: "list"/, "the card must retain the selected Phosphor list icon for ruled paper");
assert.match(mainQml, /model: root\.palette\.length[\s\S]*?delegate: Rectangle[\s\S]*?MouseArea \{[\s\S]*?hoverEnabled: true[\s\S]*?cursorShape: Qt\.PointingHandCursor[\s\S]*?onClicked: root\.setColor\(root\.selectedId, index\)/, "palette colour swatches must use a pointing-hand cursor");
assert.match(mainQml, /MouseArea \{\s*anchors\.fill: parent\s*hoverEnabled: true\s*cursorShape: Qt\.PointingHandCursor\s*onClicked: root\.createNote\(\)/, "the empty new-note stick must use a pointing-hand cursor");
assertContract(/glyph: "plus"[\s\S]*?glyph: "trash-simple"[\s\S]*?glyph: "arrow-counter-clockwise"[\s\S]*?glyph: "list"[\s\S]*?glyph: "folder-open"[\s\S]*?glyph: "archive"/, "all card and archive actions outside the editor must use the chosen Phosphor Regular glyph mapping");
assertEditorContract(/glyph: "text-b"[\s\S]*?glyph: "text-italic"[\s\S]*?glyph: "quotes"[\s\S]*?glyph: "check-square"/, "the editor's four visual actions must use the selected Phosphor Regular glyph mapping");
assert.match(configGeneral, /icons\/text-aa\.svg/, "settings must use the chosen Phosphor typography glyph");
assert.match(configGeneral, /icons\/trash-simple\.svg/, "settings must use the chosen Phosphor deletion glyph");
assert.match(configGeneral, /icons\/plus-circle\.svg/, "settings must use the chosen Phosphor add glyph");
assert.doesNotMatch(mainQml, /Tabler|Hugeicons|archive-arrow-down|archive-restore|notebook-text|panel-right-close|trash-2|source: "dialog-ok-apply"/, "the card must not retain mixed legacy or system action icons");
assert.doesNotMatch(configGeneral, /Tabler/, "configuration controls must not reintroduce a third-party mixed icon set");
assert.match(configGeneral, /actionIconSource\(localPath\)[\s\S]*?cfg_usePlasmaIconTheme[\s\S]*?actionIconName\(iconName\)[\s\S]*?cfg_usePlasmaIconTheme[\s\S]*?icon\.name: appearanceSettings\.actionIconName/, "settings must switch between local Phosphor vectors and the active Plasma icon theme together");
assert.match(configGeneral, /settingsIconColour: cfg_appearanceMode === "noty"[\s\S]*?settingsIconSize: 16[\s\S]*?icon\.width: appearanceSettings\.settingsIconSize[\s\S]*?icon\.height: appearanceSettings\.settingsIconSize/, "configuration actions must reuse the shared XS size and the selected visual-system colour");
assert.ok((configGeneral.match(/HoverHandler \{[\s\S]*?cursorShape: Qt\.PointingHandCursor/g) || []).length >= 7, "configuration colour and typeface actions must expose a pointing-hand cursor");
assert.match(configGeneral, /cfg_archiveRetention: "never"[\s\S]*?Keep archived notes:[\s\S]*?code: "30m"[\s\S]*?code: "30d"/, "settings must expose a clear archive retention policy");
assert.match(paletteContract, /function remove\(entries, index\)[\s\S]*?index <= 0/, "palette contract must protect the first mandatory colour");
assert.match(paletteContract, /function removedIndex\(before, after\)[\s\S]*?for \(let index = 1/, "palette contract must identify only optional colour deletion");
assert.match(paletteContract, /function moveOptional\(entries, fromIndex, toIndex\)[\s\S]*?fromIndex <= 0[\s\S]*?toIndex <= 0/, "palette contract must keep the default colour fixed while optional swatches reorder");
assert.match(paletteContract, /function reorderedIndexMap\(before, after\)[\s\S]*?return changed \? mapping : \[\]/, "palette contract must expose an old-to-new map for a pure reorder");
assert.match(noteStore, /function withRemappedPaletteColour\(notes, oldToNewIndex\)[\s\S]*?color: mapped/, "note persistence must retain each note's paper after palette order changes");
assert.match(mainQml, /const oldToNewIndex = PaletteContract\.reorderedIndexMap\(appliedPalette, palette\)[\s\S]*?NoteStore\.withRemappedPaletteColour\(notes, oldToNewIndex\)/, "main must persist palette-index reconciliation after an optional swatch moves");
assert.match(configGeneral, /The first colour is the permanent default[\s\S]*?id: paletteStrip[\s\S]*?QQC2\.ScrollBar\.horizontal[\s\S]*?PaletteContract\.moveOptional\([\s\S]*?Move colour left[\s\S]*?Move colour right/, "settings must make the palette a horizontal selectable strip with safe ordering controls");
assert.match(configGeneral, /Kirigami\.FormLayout \{[\s\S]*?id: appearanceSettings[\s\S]*?id: paletteEditor/, "the Plasma configuration host must retain its required FormLayout root while exposing palette controls");
assert.match(configGeneral, /cfg_noteFontSize: 12[\s\S]*?cfg_useSystemNoteFont: true[\s\S]*?systemNoteFontSize: ThemeContract\.readableSystemPixelSize\(systemDefaultFont\.pointSize\)[\s\S]*?Use Plasma system font[\s\S]*?FontDialog\s*\{[\s\S]*?id: fontPicker[\s\S]*?cfg_noteFontFamily = selectedFont\.family[\s\S]*?cfg_useSystemNoteFont = false/, "settings must make the system font default and retain a native manual typeface picker");
assert.match(themeContract, /function appearanceMode\(value\)[\s\S]*?"adaptive"[\s\S]*?function readableSystemPixelSize\(pointSize\)[\s\S]*?Math\.max\(12, Math\.round\(safePointSize \* 96 \/ 72\)\)[\s\S]*?function usesPlasmaIconTheme\(value\)[\s\S]*?value === true/, "theme settings must normalize mode, readable system typography and explicit icon-theme opt-in");
assert.match(plasmaIconNames, /"archive": "archive"[\s\S]*?"folder-open": "folder-open"[\s\S]*?"x": "window-close"/, "the Plasma icon-theme mapping must preserve selected Noty action semantics");
assert.match(plasmaIconNames, /"list": "view-list-text"/, "the Plasma icon-theme mapping must use a text-row glyph for ruled paper");
assert.match(plasmaIconNames, /"plus": "list-add"/, "the bare new-note plus must keep its Plasma equivalent");
assert.ok(((mainQml + notionEditor).match(/usePlasmaIconTheme: \w+\.usePlasmaIconTheme/g) || []).length >= 14, "every direct card, archive and editor action must receive the Plasma icon-theme opt-in");

console.log("Plasmoid visual and editing contracts are intact.");
