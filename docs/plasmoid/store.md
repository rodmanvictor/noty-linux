# Публикация в KDE Store

## Граница публикации

В KDE Store публикуется только самодостаточный QML-пакет из `plasmoid/package/`.
Экспериментальное C++-приложение из `linux/` не входит в виджет: KDE Store не
собирает плазмоиды, которым требуется компиляция. Для такого приложения нужен
отдельный канал распространения — например, PPA, AUR или OpenSUSE OBS.

## Проверка перед загрузкой

Из корня репозитория выполнить:

```bash
npm run docs:check
npm run test:plasmoid
jq empty plasmoid/package/metadata.json
```

Пакет должен иметь `metadata.json` в корне архива, `KPackageStructure` со
значением `Plasma/Applet`, уникальный `KPlugin.Id`, лицензию, версию и
`X-Plasma-API-Minimum-Version` не ниже `6.0`.

## Создание архива

Архив создаётся из содержимого `plasmoid/package`, без внешней директории:

```bash
mkdir -p build/releases
(cd plasmoid/package && zip -qr ../../build/releases/noty-plasma-0.1.0.zip .)
unzip -l build/releases/noty-plasma-0.1.0.zip
```

В списке файлов должны быть `metadata.json`, `contents/ui/main.qml`, все
импортируемые QML/JS-файлы и локальные лицензии иконок.

## Карточка KDE Store

- Категория: `KDE Plasma Extensions` → `Plasma 6`.
- Название: `Noty`.
- Короткое описание: `Local-first sticky notes docked to the Plasma desktop edge.`
- Лицензия: `MIT`.
- Исходники: `https://github.com/rodmanvictor/noty-linux`.
- Ошибки и запросы: `https://github.com/rodmanvictor/noty-linux/issues`.
- Совместимость: `KDE Plasma 6`; пакет не заявляет поддержку Plasma 5.

В описание нужно включить команду установки, ссылку на исходники и явное
указание, что это независимая реализация для KDE Plasma, вдохновлённая идеей
Noty для macOS и не являющаяся официальным продуктом исходного проекта.

После загрузки проверить страницу виджета в режиме просмотра без авторизации:
название, автор, версия, лицензия, скриншоты, архив скачивания и установку
через `Add Widgets` → `Get New Widgets`.
