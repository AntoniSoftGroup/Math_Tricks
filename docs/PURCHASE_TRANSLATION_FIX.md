# Исправление ключей pro.* вместо переводов

Причина: в собранном приложении отсутствовала русская таблица Purchases.strings,
хотя переводы присутствовали в исходниках. Успешная компиляция не выявила проблему.

Изменения в ios/Math_Tricks:

- `Math_Tricks/Services/AppPurchases.swift`, `text`: используется существующий
  `CatalogText.ui` и общая таблица Interface вместо отдельной Purchases.
- `Math_Tricks/Resources/*.lproj/Interface.strings`: перенесены 11 ключей pro.*
  для всех 26 языков; отдельные Purchases.strings удалены.
- `docs/IOS_PURCHASES.md`, `docs/PURCHASE_DIALOG_LOCALIZATION.md`: исправлены пути
  таблиц перевода.

Проверка: Debug generic iOS без подписи — BUILD SUCCEEDED.
Проверены значения всех 286 ключей внутри скомпилированного Math_Tricks.app.
Foundation Bundle.localizedString возвращает правильные переводы всех 286 ключей
из локализованных bundle готового приложения, включая русский язык.
Лог: `/tmp/math_tricks_purchase_translation_fix_build.log`.
Установка и запуск на iPhone не выполнялись. Для проверки нужен запуск обновлённой
сборки из Xcode; удалять приложение или его прогресс не требуется.

Android и ios-legacy не изменялись.
