# Тренировка: интерфейс списка приёмов

19.10.2026. Изменён только `ios/Math_Tricks`. Android и ios-legacy не изменялись.
Эталон: `activity_tree_tricks.xml`, `group_item.xml`, `trick.xml`,
`TricksFragment` и `MySimpleCursorTreeAdapter` текущего Android.

## Файлы и методы

Пути исходников ниже относительно `Math_Tricks/`.

| Файл | Методы / модели | Изменение |
|---|---|---|
| `Catalog/TricksViewController.swift` | `buildContent`, `buildHeader`, `styleHeader`, `updateControls` | Убраны отдельные монеты и текстовая панель управления. Стрелки сворачивания/раскрытия, рейтинг, общий прогресс и флажок перенесены в шапку. «Один игрок» и «Два игрока» расположены рядом с одинаковым оформлением. |
| Там же | `readProgress`, `rebuild`, `reloadPreservingPosition`, `toggle`, `toggleAll`, `playSelected`, `scrollViewDidScroll` | Чтение настоящих результатов, номера внутри группы, сохранение видимой строки при обновлениях, блокировка повторного ввода во время записи, цвет текущей категории при прокрутке/раскрытии. |
| `Catalog/TrainingCatalogCell.swift` | `TrainingCatalogCell.configure`, `TrainingCatalogGroupCell.configure` | Отдельные ячейки для тренировки: исходные цветные иконки, жирные группы, стрелки, номера, N/100, звезда за 100 уровней. Закрытый приём: PRO, монета, стоимость, замок без флажка. Системные разделители удалены. Общий `CatalogCell` статистики/результатов не менялся. |
| `Catalog/TrainingUnlockViewController.swift` | `viewDidLoad`, `update`, `unlock` | Диалог с балансом, названием, стоимостью, PRO-ссылкой, кнопками отмены и покупки. Ошибка остаётся в диалоге; успешная покупка возвращает к списку без открытия правила. |
| `Catalog/TrainingCatalogAppearance.swift` | `color`, `foreground`, `settings` | Исходные восемь цветов ResColors; белые элементы Timely/Aurora, временная палитра категории без записи выбранного цвета темы. |
| `Catalog/TrickCatalog.swift` | `TrainingCatalogProgress` | Сводка фактического прогресса списка. |
| `Data/ProgressRepository.swift`, `Data/AppDataStore.swift` | `trainingCatalogProgress`, `updateSettings` | Подсчёт уникальных учебных уровней с ненулевым результатом, с объединением legacy и новой SQLite; настройка смены цветов сохраняется атомарно с темой. |
| `Data/ProgressModels.swift` | `AppSettings`, `SettingsChange.appearance` | Optional-поле `tricksCategoryColors`, совместимое со старыми сохранениями. По умолчанию смена цветов включена, как в Android. |
| `Design/AppTypography.swift` | `AppTextRole`, `font` | Отдельные роли catalogTrick/catalogGroup используют исходные Android-ресурсы размеров и масштабирование. |
| `Design/AppComponents.swift` | `AppHeaderView.compactBackButton` | Компактная кнопка возврата только для шапки тренировки. |
| `Design/AndroidImages.swift` | `AppIcon`, `catalogIndicator`, фон групп | Исходные значки покупки/замка и Android nine-patch ресурсов групп. |
| `Design/ThemedViewController.swift` | `catalogCategoryID`, `appearanceSettings`, `applyAppearance` | Временное оформление категории без изменения сохранённой темы. |
| `Shell/AppRootViewController.swift` | `viewDidLoad`, `visibleScreenChanged` | Общий фон и системные панели учитывают текущую категорию и возвращаются к выбранной теме при выходе. Событие категории обрабатывается синхронно на main actor, без планирования через default-mode RunLoop: status bar меняется вместе с хидером прямо во время прокрутки, не после отпускания списка. Фон Timely не перекрашивается от списка. |
| `Catalog/RuleViewController.swift`, `Catalog/LevelsViewController.swift` | `init` | Цвет выбранной категории сохраняется на экранах правила и уровней. |
| `Theme/ThemePickerViewController.swift` | `viewDidLoad`, `save` | Переключатель Android «Менять цвет в списке трюков в зависимости от категории»; черновик до применения. |
| `Navigation/AppNavigation.swift` | `AppRoute.trainingLeaderboard`, `title` | Кнопка рейтинга имеет отдельное назначение. Реальный Game Center по-прежнему отложен. |
| `tools/import_android_resources.py`, `docs/ANDROID_RESOURCES.json` | `main` | Воспроизводимый импорт шести nine-patch изображений групп/стрелок из Android. |
| `tools/import_main_strings.py`, `Resources/*.lproj/Main.strings` | список `KEYS`, 26 локалей | Исходные переводы подписей одного/двух игроков и переключателя цветов. |

Добавленные ресурсы: `Resources/NinePatch/bg_th_{light,dark}_elv_item_off.9.png`
и `Resources/NinePatch/theme_{light,dark}_group_indicator_{up,down}.9.png`.

## Проверка

Debug BUILD с подписью для iPhone (Antoni) завершился с кодом 0.
Лог: `/tmp/math_tricks_training_build.log`.
Установка поверх существующего приложения завершена (`InstallComplete`).
Итоговая сборка запущена на iPhone (Antoni), процесс 2421;
отладчик успешно отсоединён с продолжением приложения (`DETACH_AND_RESUME=success`).
Лог установки/запуска: `/tmp/math_tricks_training_install.log`.
Автотесты не создавались и не запускались. Визуальную приёмку выполняет пользователь.
Пользовательская база не сбрасывалась и не импортировалась инструментами разработки.
Внешние SDK, Game Center, магазин монет и рекламные сервисы не подключались.
