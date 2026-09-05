.pragma library

/**
 * @fileoverview Shared interface translations for the Noty Plasma package.
 *
 * The widget intentionally keeps its content local and uses a small runtime
 * dictionary instead of Qt Linguist catalogs: all strings are short UI labels,
 * the language is a per-widget KConfig value, and this keeps the package
 * installable without a generated translation module. English remains the
 * source language and Russian remains the legacy fallback for existing data.
 */

/** @type {Array<Object>} Supported interface languages shown in settings. */
const languageDefinitions = [
    { code: "en", text: "English" },
    { code: "ru", text: "Русский" },
    { code: "es", text: "Español" },
    { code: "id", text: "Bahasa Indonesia" },
    { code: "de", text: "Deutsch" },
    { code: "fr", text: "Français" },
    { code: "pt", text: "Português" },
    { code: "zh", text: "中文" },
    { code: "ja", text: "日本語" },
    { code: "hi", text: "हिन्दी" }
]

/**
 * English source strings mapped to translations by ISO 639-1 code.
 *
 * @type {Object<string, Object<string, string>>}
 */
const translations = {
    "notes": {
        ru: "заметок", es: "notas", id: "catatan", de: "Notizen", fr: "notes",
        pt: "notas", zh: "条笔记", ja: "件のメモ", hi: "नोट्स"
    },
    "NEW NOTE": {
        ru: "НОВАЯ ЗАМЕТКА", es: "NUEVA NOTA", id: "CATATAN BARU", de: "NEUE NOTIZ",
        fr: "NOUVELLE NOTE", pt: "NOVA NOTA", zh: "新建笔记", ja: "新しいメモ", hi: "नया नोट"
    },
    "New note": {
        ru: "Новая заметка", es: "Nueva nota", id: "Catatan baru", de: "Neue Notiz",
        fr: "Nouvelle note", pt: "Nova nota", zh: "新建笔记", ja: "新しいメモ", hi: "नया नोट"
    },
    "Archive": {
        ru: "Архив", es: "Archivo", id: "Arsip", de: "Archiv", fr: "Archive",
        pt: "Arquivo", zh: "归档", ja: "アーカイブ", hi: "संग्रह"
    },
    "No archived notes": {
        ru: "Нет архивированных заметок", es: "No hay notas archivadas", id: "Tidak ada catatan yang diarsipkan",
        de: "Keine archivierten Notizen", fr: "Aucune note archivée", pt: "Não há notas arquivadas",
        zh: "没有已归档的笔记", ja: "アーカイブ済みのメモはありません", hi: "कोई संग्रहीत नोट नहीं"
    },
    "saved here": {
        ru: "сохранено здесь", es: "guardadas aquí", id: "tersimpan di sini", de: "hier gespeichert",
        fr: "enregistrées ici", pt: "salvas aqui", zh: "条已保存", ja: "件を保存", hi: "यहाँ सहेजे गए"
    },
    "Clear archive": {
        ru: "Очистить архив", es: "Vaciar archivo", id: "Bersihkan arsip", de: "Archiv leeren",
        fr: "Vider l’archive", pt: "Limpar arquivo", zh: "清空归档", ja: "アーカイブを消去", hi: "संग्रह साफ़ करें"
    },
    "Clear archive?": {
        ru: "Очистить архив?", es: "¿Vaciar el archivo?", id: "Bersihkan arsip?", de: "Archiv leeren?",
        fr: "Vider l’archive ?", pt: "Limpar o arquivo?", zh: "清空归档？", ja: "アーカイブを消去しますか？", hi: "संग्रह साफ़ करें?"
    },
    "All archived notes will be deleted permanently.": {
        ru: "Все архивированные заметки будут удалены без возможности восстановления.",
        es: "Todas las notas archivadas se eliminarán permanentemente.", id: "Semua catatan yang diarsipkan akan dihapus permanen.",
        de: "Alle archivierten Notizen werden dauerhaft gelöscht.", fr: "Toutes les notes archivées seront supprimées définitivement.",
        pt: "Todas as notas arquivadas serão excluídas permanentemente.", zh: "所有已归档的笔记都将永久删除。", ja: "アーカイブ済みのメモはすべて完全に削除されます。", hi: "सभी संग्रहीत नोट स्थायी रूप से हटा दिए जाएँगे।"
    },
    "Cancel": {
        ru: "Отмена", es: "Cancelar", id: "Batal", de: "Abbrechen", fr: "Annuler", pt: "Cancelar", zh: "取消", ja: "キャンセル", hi: "रद्द करें"
    },
    "Restore and open": {
        ru: "Восстановить и открыть", es: "Restaurar y abrir", id: "Pulihkan dan buka", de: "Wiederherstellen und öffnen",
        fr: "Restaurer et ouvrir", pt: "Restaurar e abrir", zh: "恢复并打开", ja: "復元して開く", hi: "पुनर्स्थापित करें और खोलें"
    },
    "Delete permanently": {
        ru: "Удалить навсегда", es: "Eliminar permanentemente", id: "Hapus permanen", de: "Dauerhaft löschen",
        fr: "Supprimer définitivement", pt: "Excluir permanentemente", zh: "永久删除", ja: "完全に削除", hi: "स्थायी रूप से हटाएँ"
    },
    "Nothing in archive": {
        ru: "Архив пуст", es: "El archivo está vacío", id: "Arsip kosong", de: "Das Archiv ist leer",
        fr: "L’archive est vide", pt: "O arquivo está vazio", zh: "归档为空", ja: "アーカイブは空です", hi: "संग्रह खाली है"
    },
    "Archived notes can be restored here.": {
        ru: "Сюда можно вернуть архивированные заметки.", es: "Aquí puedes restaurar las notas archivadas.",
        id: "Catatan yang diarsipkan dapat dipulihkan di sini.", de: "Archivierte Notizen können hier wiederhergestellt werden.",
        fr: "Les notes archivées peuvent être restaurées ici.", pt: "As notas arquivadas podem ser restauradas aqui.",
        zh: "可以在此处恢复已归档的笔记。", ja: "ここでアーカイブ済みのメモを復元できます。", hi: "संग्रहीत नोट यहाँ पुनर्स्थापित किए जा सकते हैं।"
    },
    "Close archive": {
        ru: "Закрыть архив", es: "Cerrar archivo", id: "Tutup arsip", de: "Archiv schließen",
        fr: "Fermer l’archive", pt: "Fechar arquivo", zh: "关闭归档", ja: "アーカイブを閉じる", hi: "संग्रह बंद करें"
    },
    "Archived": {
        ru: "В архиве", es: "Archivada", id: "Diarsipkan", de: "Archiviert", fr: "Archivée",
        pt: "Arquivada", zh: "已归档", ja: "アーカイブ済み", hi: "संग्रहीत"
    },
    "Undo": {
        ru: "Отменить", es: "Deshacer", id: "Urungkan", de: "Rückgängig", fr: "Annuler",
        pt: "Desfazer", zh: "撤销", ja: "元に戻す", hi: "पूर्ववत करें"
    },
    "Undo archive": {
        ru: "Отменить архивирование", es: "Deshacer archivado", id: "Urungkan pengarsipan", de: "Archivierung rückgängig machen",
        fr: "Annuler l’archivage", pt: "Desfazer arquivamento", zh: "撤销归档", ja: "アーカイブを元に戻す", hi: "संग्रहण पूर्ववत करें"
    },
    "Saved · just now": {
        ru: "Сохранено · только что", es: "Guardado · ahora mismo", id: "Tersimpan · baru saja", de: "Gespeichert · gerade eben",
        fr: "Enregistré · à l’instant", pt: "Salvo · agora mesmo", zh: "已保存 · 刚刚", ja: "保存済み · たった今", hi: "सहेजा गया · अभी"
    },
    "Collapse note": {
        ru: "Свернуть заметку", es: "Contraer nota", id: "Ciutkan catatan", de: "Notiz einklappen",
        fr: "Réduire la note", pt: "Recolher nota", zh: "收起笔记", ja: "メモを折りたたむ", hi: "नोट संक्षिप्त करें"
    },
    "Start writing…": {
        ru: "Начните писать…", es: "Empieza a escribir…", id: "Mulai menulis…", de: "Schreiben beginnen…",
        fr: "Commencez à écrire…", pt: "Comece a escrever…", zh: "开始书写…", ja: "書き始める…", hi: "लिखना शुरू करें…"
    },
    "Toggle task: ": {
        ru: "Переключить задачу: ", es: "Alternar tarea: ", id: "Alihkan tugas: ", de: "Aufgabe umschalten: ",
        fr: "Basculer la tâche : ", pt: "Alternar tarefa: ", zh: "切换任务：", ja: "タスクを切り替え: ", hi: "कार्य बदलें: "
    },
    "Bold": {
        ru: "Жирный", es: "Negrita", id: "Tebal", de: "Fett", fr: "Gras", pt: "Negrito", zh: "粗体", ja: "太字", hi: "बोल्ड"
    },
    "Italic": {
        ru: "Курсив", es: "Cursiva", id: "Miring", de: "Kursiv", fr: "Italique", pt: "Itálico", zh: "斜体", ja: "斜体", hi: "इटैलिक"
    },
    "Quote": {
        ru: "Цитата", es: "Cita", id: "Kutipan", de: "Zitat", fr: "Citation", pt: "Citação", zh: "引用", ja: "引用", hi: "उद्धरण"
    },
    "Checklist": {
        ru: "Чек-лист", es: "Lista de tareas", id: "Daftar periksa", de: "Checkliste", fr: "Liste de tâches",
        pt: "Lista de verificação", zh: "清单", ja: "チェックリスト", hi: "चेकलिस्ट"
    },
    "Toggle ruled paper": {
        ru: "Линейки в заметке", es: "Líneas en la nota", id: "Garis di catatan", de: "Linien in der Notiz",
        fr: "Lignes dans la note", pt: "Linhas na nota", zh: "笔记横线", ja: "メモの罫線", hi: "नोट में लाइनें"
    },
    "Archive note": {
        ru: "Архивировать заметку", es: "Archivar nota", id: "Arsipkan catatan", de: "Notiz archivieren",
        fr: "Archiver la note", pt: "Arquivar nota", zh: "归档笔记", ja: "メモをアーカイブ", hi: "नोट संग्रहीत करें"
    },
    "Open archive": {
        ru: "Открыть архив", es: "Abrir archivo", id: "Buka arsip", de: "Archiv öffnen",
        fr: "Ouvrir l’archive", pt: "Abrir arquivo", zh: "打开归档", ja: "アーカイブを開く", hi: "संग्रह खोलें"
    },
    "Date unavailable": {
        ru: "Дата недоступна", es: "Fecha no disponible", id: "Tanggal tidak tersedia", de: "Datum nicht verfügbar",
        fr: "Date indisponible", pt: "Data indisponível", zh: "日期不可用", ja: "日付なし", hi: "तारीख उपलब्ध नहीं"
    },
    "Interface": { ru: "Интерфейс", es: "Interfaz", id: "Antarmuka", de: "Oberfläche", fr: "Interface", pt: "Interface", zh: "界面", ja: "インターフェース", hi: "इंटरफ़ेस" },
    "Language:": { ru: "Язык:", es: "Idioma:", id: "Bahasa:", de: "Sprache:", fr: "Langue :", pt: "Idioma:", zh: "语言：", ja: "言語:", hi: "भाषा: " },
    "Typography": { ru: "Типографика", es: "Tipografía", id: "Tipografi", de: "Typografie", fr: "Typographie", pt: "Tipografia", zh: "排版", ja: "タイポグラフィ", hi: "टाइपोग्राफी" },
    "Font source:": { ru: "Источник:", es: "Fuente:", id: "Sumber font:", de: "Schriftquelle:", fr: "Source :", pt: "Fonte:", zh: "字体来源：", ja: "フォント元:", hi: "फ़ॉन्ट स्रोत: " },
    "Use Plasma system font": { ru: "Использовать системный шрифт Plasma", es: "Usar la fuente del sistema Plasma", id: "Gunakan font sistem Plasma", de: "Plasma-Systemschrift verwenden", fr: "Utiliser la police système Plasma", pt: "Usar a fonte do sistema Plasma", zh: "使用 Plasma 系统字体", ja: "Plasma システムフォントを使用", hi: "Plasma सिस्टम फ़ॉन्ट का उपयोग करें" },
    "Text size:": { ru: "Размер текста:", es: "Tamaño del texto:", id: "Ukuran teks:", de: "Textgröße:", fr: "Taille du texte :", pt: "Tamanho do texto:", zh: "文字大小：", ja: "文字サイズ:", hi: "टेक्स्ट आकार: " },
    "Current:": { ru: "Текущий:", es: "Actual:", id: "Saat ini:", de: "Aktuell:", fr: "Actuel :", pt: "Atual:", zh: "当前：", ja: "現在:", hi: "वर्तमान: " },
    "Family:": { ru: "Гарнитура:", es: "Familia:", id: "Keluarga:", de: "Familie:", fr: "Famille :", pt: "Família:", zh: "字体：", ja: "ファミリー:", hi: "फ़ैमिली: " },
    "Choose note typeface": { ru: "Выбрать шрифт заметок", es: "Elegir fuente de las notas", id: "Pilih jenis huruf catatan", de: "Schriftart für Notizen wählen", fr: "Choisir la police des notes", pt: "Escolher fonte das notas", zh: "选择笔记字体", ja: "メモの書体を選択", hi: "नोट फ़ॉन्ट चुनें" },
    "Appearance": { ru: "Вид", es: "Apariencia", id: "Tampilan", de: "Erscheinungsbild", fr: "Apparence", pt: "Aparência", zh: "外观", ja: "外観", hi: "दिखावट" },
    "Style:": { ru: "Стиль:", es: "Estilo:", id: "Gaya:", de: "Stil:", fr: "Style :", pt: "Estilo:", zh: "样式：", ja: "スタイル:", hi: "शैली: " },
    "Appearance style": { ru: "Стиль оформления", es: "Estilo visual", id: "Gaya tampilan", de: "Darstellungsstil", fr: "Style d’apparence", pt: "Estilo de aparência", zh: "外观样式", ja: "外観スタイル", hi: "दिखावट शैली" },
    "Icons:": { ru: "Иконки:", es: "Iconos:", id: "Ikon:", de: "Symbole:", fr: "Icônes :", pt: "Ícones:", zh: "图标：", ja: "アイコン:", hi: "आइकन: " },
    "Use Plasma icon theme": { ru: "Использовать тему иконок Plasma", es: "Usar el tema de iconos de Plasma", id: "Gunakan tema ikon Plasma", de: "Plasma-Symbolthema verwenden", fr: "Utiliser le thème d’icônes Plasma", pt: "Usar o tema de ícones Plasma", zh: "使用 Plasma 图标主题", ja: "Plasma アイコンテーマを使用", hi: "Plasma आइकन थीम का उपयोग करें" },
    "Edge:": { ru: "Край:", es: "Borde:", id: "Tepi:", de: "Rand:", fr: "Bord :", pt: "Borda:", zh: "边缘：", ja: "端:", hi: "किनारा: " },
    "Right": { ru: "Справа", es: "Derecha", id: "Kanan", de: "Rechts", fr: "Droite", pt: "Direita", zh: "右侧", ja: "右", hi: "दायाँ" },
    "Left": { ru: "Слева", es: "Izquierda", id: "Kiri", de: "Links", fr: "Gauche", pt: "Esquerda", zh: "左侧", ja: "左", hi: "बायाँ" },
    "Top": { ru: "Сверху", es: "Arriba", id: "Atas", de: "Oben", fr: "Haut", pt: "Superior", zh: "顶部", ja: "上", hi: "ऊपर" },
    "Bottom": { ru: "Снизу", es: "Abajo", id: "Bawah", de: "Unten", fr: "Bas", pt: "Inferior", zh: "底部", ja: "下", hi: "नीचे" },
    "Sticks:": { ru: "Стики:", es: "Pestañas:", id: "Stik:", de: "Tabs:", fr: "Onglets :", pt: "Abas:", zh: "便签条：", ja: "スティック:", hi: "स्टिक: " },
    "Show note titles": { ru: "Показывать названия заметок", es: "Mostrar títulos de las notas", id: "Tampilkan judul catatan", de: "Notiztitel anzeigen", fr: "Afficher les titres des notes", pt: "Mostrar títulos das notas", zh: "显示笔记标题", ja: "メモのタイトルを表示", hi: "नोट शीर्षक दिखाएँ" },
    "While idle:": { ru: "В покое:", es: "En reposo:", id: "Saat diam:", de: "Im Ruhezustand:", fr: "Au repos :", pt: "Em repouso:", zh: "空闲时：", ja: "待機中:", hi: "निष्क्रिय: " },
    "Traffic light": { ru: "Светофор", es: "Semáforo", id: "Lampu lalu lintas", de: "Ampel", fr: "Feu tricolore", pt: "Semáforo", zh: "交通灯", ja: "信号", hi: "ट्रैफिक लाइट" },
    "Always show sticks": { ru: "Всегда показывать стики", es: "Mostrar siempre las pestañas", id: "Selalu tampilkan stik", de: "Tabs immer anzeigen", fr: "Toujours afficher les onglets", pt: "Sempre mostrar abas", zh: "始终显示便签条", ja: "スティックを常に表示", hi: "स्टिक हमेशा दिखाएँ" },
    "Hidden until hover": { ru: "Скрыть до наведения", es: "Ocultar hasta pasar el cursor", id: "Sembunyikan hingga diarahkan", de: "Bis zum Überfahren ausblenden", fr: "Masquer jusqu’au survol", pt: "Ocultar até passar o cursor", zh: "悬停前隐藏", ja: "ホバーまで非表示", hi: "होवर तक छिपाएँ" },
    "Fixed note size": { ru: "Фиксированный размер", es: "Tamaño fijo de la nota", id: "Ukuran catatan tetap", de: "Feste Notizgröße", fr: "Taille fixe de la note", pt: "Tamanho fixo da nota", zh: "固定笔记大小", ja: "メモの固定サイズ", hi: "नोट का निश्चित आकार" },
    "Width:": { ru: "Ширина:", es: "Ancho:", id: "Lebar:", de: "Breite:", fr: "Largeur :", pt: "Largura:", zh: "宽度：", ja: "幅:", hi: "चौड़ाई: " },
    "Height:": { ru: "Высота:", es: "Alto:", id: "Tinggi:", de: "Höhe:", fr: "Hauteur :", pt: "Altura:", zh: "高度：", ja: "高さ:", hi: "ऊँचाई: " },
    "Keep archived notes:": { ru: "Хранить заметки:", es: "Conservar notas archivadas:", id: "Simpan catatan yang diarsipkan:", de: "Archivierte Notizen behalten:", fr: "Conserver les notes archivées :", pt: "Manter notas arquivadas:", zh: "保留归档笔记：", ja: "アーカイブ済みメモの保持:", hi: "संग्रहीत नोट रखें: " },
    "Forever": { ru: "Всегда", es: "Siempre", id: "Selamanya", de: "Unbegrenzt", fr: "Toujours", pt: "Para sempre", zh: "永久", ja: "無期限", hi: "हमेशा" },
    "30 minutes": { ru: "30 минут", es: "30 minutos", id: "30 menit", de: "30 Minuten", fr: "30 minutes", pt: "30 minutos", zh: "30 分钟", ja: "30 分", hi: "30 मिनट" },
    "1 day": { ru: "1 день", es: "1 día", id: "1 hari", de: "1 Tag", fr: "1 jour", pt: "1 dia", zh: "1 天", ja: "1 日", hi: "1 दिन" },
    "7 days": { ru: "7 дней", es: "7 días", id: "7 hari", de: "7 Tage", fr: "7 jours", pt: "7 dias", zh: "7 天", ja: "7 日", hi: "7 दिन" },
    "30 days": { ru: "30 дней", es: "30 días", id: "30 hari", de: "30 Tage", fr: "30 jours", pt: "30 dias", zh: "30 天", ja: "30 日", hi: "30 दिन" },
    "Colours": { ru: "Цвета", es: "Colores", id: "Warna", de: "Farben", fr: "Couleurs", pt: "Cores", zh: "颜色", ja: "色", hi: "रंग" },
    "Palette:": { ru: "Палитра:", es: "Paleta:", id: "Palet:", de: "Palette:", fr: "Palette :", pt: "Paleta:", zh: "调色板：", ja: "パレット:", hi: "पैलेट: " },
    "The first colour is the permanent default. Select another colour to edit, reorder or remove it.": {
        ru: "Первый цвет — основной. Выберите другой цвет, чтобы изменить, переставить или удалить его.",
        es: "El primer color es el predeterminado permanente. Selecciona otro para editarlo, reordenarlo o eliminarlo.",
        id: "Warna pertama adalah default permanen. Pilih warna lain untuk mengedit, mengurutkan ulang, atau menghapusnya.",
        de: "Die erste Farbe ist der dauerhafte Standard. Wähle eine andere zum Bearbeiten, Sortieren oder Entfernen.",
        fr: "La première couleur est la couleur par défaut permanente. Sélectionnez-en une autre pour la modifier, la déplacer ou la supprimer.",
        pt: "A primeira cor é o padrão permanente. Selecione outra para editar, reordenar ou remover.",
        zh: "第一种颜色是永久默认颜色。选择其他颜色即可编辑、重新排序或删除。",
        ja: "最初の色は常に既定色です。他の色を選ぶと編集、並べ替え、削除ができます。",
        hi: "पहला रंग स्थायी डिफ़ॉल्ट है। किसी अन्य रंग को संपादित, पुनःक्रमित या हटाने के लिए चुनें।"
    },
    "Select colour ": { ru: "Выбрать цвет ", es: "Seleccionar color ", id: "Pilih warna ", de: "Farbe auswählen ", fr: "Sélectionner la couleur ", pt: "Selecionar cor ", zh: "选择颜色 ", ja: "色を選択 ", hi: "रंग चुनें " },
    "Add colour": { ru: "Добавить цвет", es: "Añadir color", id: "Tambah warna", de: "Farbe hinzufügen", fr: "Ajouter une couleur", pt: "Adicionar cor", zh: "添加颜色", ja: "色を追加", hi: "रंग जोड़ें" },
    "Edit": { ru: "Изменить", es: "Editar", id: "Edit", de: "Bearbeiten", fr: "Modifier", pt: "Editar", zh: "编辑", ja: "編集", hi: "संपादित करें" },
    "Edit selected colour": { ru: "Изменить выбранный цвет", es: "Editar el color seleccionado", id: "Edit warna yang dipilih", de: "Ausgewählte Farbe bearbeiten", fr: "Modifier la couleur sélectionnée", pt: "Editar a cor selecionada", zh: "编辑所选颜色", ja: "選択した色を編集", hi: "चयनित रंग संपादित करें" },
    "Move colour left": { ru: "Переместить цвет левее", es: "Mover el color a la izquierda", id: "Pindahkan warna ke kiri", de: "Farbe nach links verschieben", fr: "Déplacer la couleur à gauche", pt: "Mover cor para a esquerda", zh: "将颜色左移", ja: "色を左へ移動", hi: "रंग बाएँ ले जाएँ" },
    "Move colour right": { ru: "Переместить цвет правее", es: "Mover el color a la derecha", id: "Pindahkan warna ke kanan", de: "Farbe nach rechts verschieben", fr: "Déplacer la couleur à droite", pt: "Mover cor para a direita", zh: "将颜色右移", ja: "色を右へ移動", hi: "रंग दाएँ ले जाएँ" },
    "Remove selected colour": { ru: "Удалить выбранный цвет", es: "Eliminar el color seleccionado", id: "Hapus warna yang dipilih", de: "Ausgewählte Farbe entfernen", fr: "Supprimer la couleur sélectionnée", pt: "Remover a cor selecionada", zh: "删除所选颜色", ja: "選択した色を削除", hi: "चयनित रंग हटाएँ" },
    "Choose colour": { ru: "Выберите цвет", es: "Elige un color", id: "Pilih warna", de: "Farbe auswählen", fr: "Choisir une couleur", pt: "Escolher cor", zh: "选择颜色", ja: "色を選択", hi: "रंग चुनें" },
    "Choose typeface": { ru: "Выберите шрифт", es: "Elige una fuente", id: "Pilih jenis huruf", de: "Schriftart auswählen", fr: "Choisir une police", pt: "Escolher fonte", zh: "选择字体", ja: "書体を選択", hi: "फ़ॉन्ट चुनें" },
    "System size ": { ru: "Системный размер ", es: "Tamaño del sistema ", id: "Ukuran sistem ", de: "Systemgröße ", fr: "Taille système ", pt: "Tamanho do sistema ", zh: "系统大小 ", ja: "システムサイズ ", hi: "सिस्टम आकार " },
    " pt is used with a ": { ru: " pt используется с минимумом ", es: " pt se usa con un mínimo de ", id: " pt digunakan dengan minimum ", de: " pt wird mit mindestens ", fr: " pt est utilisé avec un minimum de ", pt: " pt é usado com um mínimo de ", zh: " pt，最小值为 ", ja: " pt、最小 ", hi: " pt का उपयोग न्यूनतम " },
    " px minimum.": { ru: " px.", es: " px.", id: " px.", de: " px.", fr: " px.", pt: " px.", zh: " px。", ja: " px 以上。", hi: " px।" },
    "Experimental: replaces bundled Phosphor vectors with the active Plasma icon theme.": {
        ru: "Экспериментально: заменяет локальные Phosphor на иконки активной темы Plasma.",
        es: "Experimental: sustituye los vectores Phosphor incluidos por el tema de iconos activo de Plasma.",
        id: "Eksperimental: mengganti vektor Phosphor bawaan dengan tema ikon Plasma yang aktif.",
        de: "Experimentell: ersetzt die enthaltenen Phosphor-Vektoren durch das aktive Plasma-Symbolthema.",
        fr: "Expérimental : remplace les vecteurs Phosphor inclus par le thème d’icônes Plasma actif.",
        pt: "Experimental: substitui os vetores Phosphor incluídos pelo tema de ícones Plasma ativo.",
        zh: "实验功能：使用当前 Plasma 图标主题替代内置 Phosphor 矢量图标。",
        ja: "実験的機能: 内蔵 Phosphor ベクターをアクティブな Plasma アイコンテーマに置き換えます。",
        hi: "प्रायोगिक: बंडल किए गए Phosphor वेक्टर को सक्रिय Plasma आइकन थीम से बदलता है।"
    }
}

/**
 * Normalizes a persisted language code to a supported locale.
 * @param {string} value KConfig language value.
 * @returns {string} Supported ISO 639-1 code, defaulting to English.
 */
function normalize(value) {
    const code = typeof value === "string" ? value.toLowerCase().split("-")[0] : ""
    for (let index = 0; index < languageDefinitions.length; index += 1) {
        if (languageDefinitions[index].code === code) {
            return code
        }
    }
    return "en"
}

/**
 * Returns language options for a ComboBox without exposing mutable internals.
 * @returns {Array<Object>} Autonym-labelled language options.
 */
function languageOptions() {
    return languageDefinitions.map(function(entry) {
        return { code: entry.code, text: entry.text }
    })
}

/**
 * Finds the ComboBox index for a persisted code.
 * @param {string} value KConfig language value.
 * @returns {number} Zero-based option index.
 */
function languageIndex(value) {
    const code = normalize(value)
    for (let index = 0; index < languageDefinitions.length; index += 1) {
        if (languageDefinitions[index].code === code) {
            return index
        }
    }
    return 0
}

/**
 * Resolves a UI string with a graceful fallback for missing translations.
 * @param {string} language Requested locale code.
 * @param {string} english English source text and dictionary key.
 * @param {string} russian Legacy Russian fallback retained by the original UI.
 * @returns {string} Localized text or the English source string.
 */
function text(language, english, russian) {
    const locale = normalize(language)
    if (locale === "ru") {
        return russian || english
    }
    if (locale === "en") {
        return english
    }
    const entry = translations[english]
    return entry && entry[locale] ? entry[locale] : english
}
