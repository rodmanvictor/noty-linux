# Notion-подобный Markdown-редактор Plasma

## Архитектура

Карточка заметки использует [`NotionEditor.qml`](../../plasmoid/package/contents/ui/NotionEditor.qml).
Это компактный композиционный компонент, а не отдельный движок редактора:

- единственный `TextArea` с `TextEdit.MarkdownText` остаётся владельцем текста,
  курсора, выделения, undo/redo, IME и рендеринга CommonMark/GitHub Markdown;
- `NotionEditor.markdown` приходит из `NoteStore`, а сигнал `markdownEdited()`
  возвращает изменённый Markdown в тот же store;
- `checklistToggled()` передаёт только индекс строки в `NoteStore`; состояние
  задачи нигде отдельно не хранится;
- карточка не имеет режима редактирования исходного Markdown.

Такой подход повторяет модель официального примера Qt Quick Controls Text
Editor: `Action` использует `cursorSelection` для инлайн-форматирования, а
документ остаётся нативным QML/Qt, без QWidget-моста или WebEngine.

## Три визуальных блока

Qt уже интерактивно обрабатывает GitHub tasks, но не даёт QML API для настройки
их маленького квадратного маркера. Поэтому компонент добавляет только лёгкие
визуальные слои над тем же `TextArea`:

1. **Selection bubble.** Появляется исключительно при непустом выделении и
   содержит Bold, Italic, Quote и Checklist. Жирность и курсив меняют
   `cursorSelection`; quote/checklist расширяют выделение до целого видимого
   абзаца и добавляют стандартный Markdown-маркер.
2. **Task block.** `EditorContract.checklistEntries()` сопоставляет `- [ ]` и
   `- [x]` с позициями уже отрисованного документа. Поверх штатного маркера
   располагается квадрат со скруглением 5 px и зоной нажатия 36 px. Он имеет
   курсор-руку, keyboard-focus и роль `Accessible.CheckBox`.
3. **Quote block.** `EditorContract.quoteEntries()` находит строки `>`, а
   компонент рисует рядом с ними тонкую вертикальную rule. Markdown и ввод
   текста при этом по-прежнему полностью принадлежат Qt.

`EditorContract.js` не парсит документ целиком и не хранит UI-состояние: это
детерминированные helpers для сопоставления исходного Markdown с координатами
Qt. Они нужны ровно потому, что `TextArea` не предоставляет делегаты для task
или quote block.

## Почему не сторонняя библиотека

`QMarkdownTextEdit` — C++-виджет на базе `QPlainTextEdit`: он подсвечивает
исходный Markdown, а не даёт WYSIWYG QML-интерфейс. KDE `KTextEditor` — мощный
редактор для кода на QWidget, а не компактный блок заметки. Браузерные движки
наподобие TipTap потребовали бы WebEngine/Chromium и JavaScript-бандл.

`NotionEditor` сохраняет преимущества близкого к Notion взаимодействия —
крупные задачи, quote rule и bubble-menu — без второго редакторского стека.

## Регрессионная проверка

- `plasmoid/tests/tst_RichEditor.qml` проверяет рендер Markdown, action-based
  bold/italic, quote/checklist для частичного выделения, а также позиционирование
  task/quote blocks. Отдельный сценарий дожидается завершения layout и кликает
  именно поверх видимого task-control: это защищает от регрессии, когда Qt уже
  рисовал строку правильно, а QML-оверлей оставался на его предварительной
  координате.
- `plasmoid/tests/tst_NativeMarkdownTasks.qml` проверяет базовую поддержку
  GitHub task list самим Qt.
- `scripts/test-plasmoid-ui-contract.mjs` гарантирует, что карточка делегирует
  Markdown одному `NotionEditor`, а компонент сохраняет штатный `TextArea`,
  selection bubble, rounded task control и quote rule.
- После изменений запускаются `npm run test:plasmoid` и `npm run docs:check`.
