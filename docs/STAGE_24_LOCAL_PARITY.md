# Этап 24 — дополнительный локальный блок, 19.10.2026

Актуальное дополнение после аудита из 14 пунктов:
[STAGE_24_PARITY_AUDIT_FIXES.md](STAGE_24_PARITY_AUDIT_FIXES.md).
Предел обычной сложности 100 и конфликт root 6/9 исправлены; описание ниже
фиксирует предшествовавший блок работ. Итоговый Debug BUILD дополнения — OK.

Изменялся только `ios/Math_Tricks`. Android и ios-legacy использованы для чтения.
Существующие незакоммиченные изменения не сбрасывались. Автотестов, установки,
запуска, реального импорта/экспорта или сброса пользовательской базы не было.

Состояние: код перенесён и подготовлен к ручной проверке. Это не утверждение
о полном визуальном совпадении или завершении всех 25 этапов. Реклама, Game Center,
покупки и облако остаются для совместной настройки. Реальное обновление старого
приложения и визуальная приёмка не выполнялись.

## Файлы, методы и назначение

| Файлы | Методы / изменение |
|---|---|
| `Design/AndroidDimensions.swift`, `Resources/AndroidDimensions.json`, `tools/import_android_dimensions.py` | `value`: исходные размеры Android с учётом плотности, smallest width и ориентации; 9 наборов ресурсов, Android не меняется |
| `Design/AppTypography.swift` | `font`, `traitCollectionDidChange`: размеры меню, счётчиков, шапок, игры, приёмов, уровней и двух игроков; обновление при смене size class/масштаба |
| `Design/AppComponents.swift` | `AppButton.setContentInsets/setIcon/apply`: исходные размеры иконок, прозрачные текстовые действия, кнопки иконок с фоном, цвета игроков; цифры/иконки клавиатуры вписываются по высоте; `AppHeaderView.replaceTitle/setAccessoryView`: заголовок слева и игровые счётчики |
| `Design/AndroidCheckBox.swift` | `setOn/refresh`: оригинальные Android on/off drawable, 48 pt область нажатия и доступность |
| `Design/ThemedViewController.swift` | `setHeaderHidden`, `button`, обновление traits: компоновка двух игроков на всю доступную область, единое оформление; скрытые контроллеры откладывают чтение списков/истории до возврата на экран |
| `Design/AppDialogViewController.swift` | Закрытие диалогов без анимации |
| `Design/AndroidImages.swift` | Исходные стрелки вверх/вниз, варианты ввода и состояния TTS |
| `Main/MainMenuViewController.swift` | `buildHeader/buildDailyPanel/rebuildLayout/fitBuyLabel/render`: Android-порядок и пропорции, кнопки/нижние ссылки, счётчики с small/b/i; страховка максимум 2 строки, подпись уведомлений у переключателя |
| `Main/MainText.swift`, `Catalog/AndroidRichText.swift` | `richFormat/inline`: стили счётчиков без HTML-импортера; типографика списка приёмов |
| `Onboarding/AgeScreenViewController.swift` | Фиксированная клавиатура с равными рядами и пропорцией 40/60, клавиша удаления с фоном, зелёная подложка OK |
| `Game/GameModesViewController.swift` | Вертикальные стрелки выбора сложности; четыре режима с графиками/таблицами рядом и рекордами под кнопками; отдельная выбранная сложность для отмеченных приёмов |
| `Game/GameViewController.swift` | `buildContent/rebuildLayout/render`: inline-пример, шапка уровня/примеров/счёта/звёзд, монеты, фиксированная клавиатура и подсказки; landscape с боковой панелью и переносом клавиатуры; исходные состояния TTS; кнопка продолжения не вспыхивает во время фоновой записи; результат с попытками и действиями 2×2 в landscape |
| `Game/FittingMathExpressionView.swift` | `layoutSubviews/apply`: одинаковый масштаб выражения и ответа в одной строке, тематическая поверхность |
| `Game/GameResultTableView.swift` | `configure`: реальные попытки результата и переход к решению без игровых начислений |
| `Game/Core/GameSession.swift`, `Game/Core/MathExample.swift` | `changeInput/markInputChanged/eligible`: смена способа ввода не прибавляет ошибку, но исключает текущую попытку из рекордов чистого времени; новые Codable-поля optional |
| `Game/MathExpressionFormatter.swift` | Повторно используемый форматтер защищён NSLock для UI и фонового экспорта |
| `Catalog/LevelsViewController.swift` | Счётчик и стрелки в шапке, исходная сетка 3/5, размеры номеров, реальные ошибки/среднее/общее время; неизвестное время не заменяется нулём |
| `ByHeart/ByHeartViewController.swift`, `ByHeart/ByHeartRowCell.swift`, `ByHeart/ByHeartExamplesViewController.swift` | Горизонтальные строки числа/интервала/счёта/звёзд, общий счётчик в шапке, финальный уровень выделен; примеры и переход далее, стрелки количества в шапке |
| `Multiplayer/MultiplayerSetupViewController.swift` | Число со стрелками слева, исходные три иконки ввода с флажками, совместная/соревновательная игра снизу; выбор ввода сохраняется |
| `Multiplayer/PlayerInputBoard.swift`, `Multiplayer/MultiplayerViewController.swift` | Панели без прокрутки клавиатуры, inline-пример, цвета игроков, верхний/левый игрок развёрнут; landscape, общая полоса и выход с сохранением; устранён случай стартовой паузы до появления окна |
| `Multiplayer/MultiplayerSession.swift` | Начальный способ ввода передаётся конфигурацией; его установка не превращается в исправление ответа |
| `Settings/SettingsViewController.swift` | Строки и Android-флажки вместо поднятых кнопок/UISwitch; нажатие строки меняет значение, чекбокс не срабатывает дважды |
| `Settings/TextAndKeypadViewController.swift`, `Settings/FontSamplePreview.swift` | Черновик размера 80–200%, сброс к системному, четыре декоративных предпросмотра, сохранение только «Применить»; обе раскладки 123/789 и явный выбор |
| `Statistics/PracticeStatistics.swift`, `Statistics/ImportedPracticeRecord.swift`, `Statistics/StatisticsViewController.swift` | Подготовка импортированных измерений в actor, вне UI-потока. Объединение настоящих iOS-попыток и Android-измерений без фиктивных попыток; нормализация выражений, сохранение неизвестного способа ввода, диапазон уровней для статистики приёмов |
| `Statistics/GraphViewController.swift` | Импортированная история ежедневной серии; один день не дублируется при добавлении iOS-истории |
| `Statistics/LevelMeasurements.swift` | Проверяемые измерения уровня, derived только из настоящих попыток |
| `Archives/ArchiveGzip.swift`, `Archives/AndroidProgressArchive.swift`, `Archives/AndroidArchiveExport.swift`, `Archives/ProgressArchive.swift` | GZIP v5: ограниченная распаковка с проверкой CRC через zlib, валидация структуры, проекция, исходные таблицы и экспорт фактических данных. Полный iOS-архив обратно совместим |
| `Archives/ArchiveViewController.swift` | Два экспорта: полный iOS / Android; выбор GZIP; предварительный просмотр и два подтверждения импорта |
| `Data/ProgressModels.swift`, `Data/ProgressRepository.swift`, `Data/AppDataStore.swift`, `Data/LegacyProgressIndex.swift` | Optional-настройки и измерения, атомарное сохранение исходного Android-архива, проверка revision перед заменой, сохранение новых измерений при merge |
| `Navigation/AppNavigation.swift` | Маршруты кнопок таблиц лидеров до совместного подключения Game Center; вымышленные ID не добавлялись |
| `tools/import_main_strings.py`, `tools/import_localizations.py`, `Resources/*lproj/{Main,MainRich}.strings`, `docs/LOCALIZATION_REPORT.json` | Исходные игровые/шрифтовые подписи и форматирование счётчиков для 26 локалей; исходный Android fallback сохранён |
| `docs/MIGRATION_PLAN.md`, `STAGE_24_REVIEW.md`, `LOCAL_ARCHIVES.md`, `LOCALIZATION.md`, этот файл | Актуальный статус и ограничения проверки/совместимости; исторический MIGRATION_INVENTORY.json не переписывался |

## Открытая локальная проверка поведения

В текущем ядре и генераторе сохраняется ограничение сложности 1…100. В Android
обычная игра после каждых 10 решений увеличивает level без этого ограничения
(`Player.timerNewEcuation`). Каталог учебных уровней имеет отдельные 100 уровней.
Для обычной игры выше 100 ещё требуется отдельный аудит диапазонов всех 107
формул и совместимости старых результатов; это незавершённая локальная часть,
а не задача сервера. Сохранённый maximumLevel не обнуляется.

## Ограничения проверки

Проверялась только компиляция. Не проверены на запущенном приложении: размер/перенос
подписей, повороты, одновременный ввод двух игроков, VoiceOver, RTL и импорт файла.
До ручной сверки нельзя считать интерфейс полностью принятым как Android.
Ограничения формата GZIP v5 и отрицательного scope Android описаны в LOCAL_ARCHIVES.md.

19.10.2026: итоговые Debug и Release для `generic/platform=iOS` завершились
с кодом 0 после всех перечисленных правок. Только `build`, `CODE_SIGNING_ALLOWED=NO`.
Установка, запуск и автотесты не выполнялись. Продукты находятся в
`/tmp/math_tricks_migration_derived/Build/Products/`.
