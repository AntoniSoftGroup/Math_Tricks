# Одиночная игра, статистика и результаты

Изменён только проект `ios/Math_Tricks`. Проекты `android/Math_Tricks` и `ios-legacy/Math Tricks Free` не изменялись.

Пути ниже — относительно `ios/Math_Tricks`.

| Файлы | Методы и назначение |
| --- | --- |
| `Math_Tricks/Game/GameViewController.swift` | `buildContent`, `rebuildLayout`, `render`, `viewDidAppear`, `startNew`, `shareResult`: раскладка заголовка, ширина кнопок подсказки/пропуска, центральный текст, новый экран результата, переходы и защита повтора во время сохранения. |
| `Math_Tricks/Game/AndroidGameProgressView.swift` — новый | `apply`, `setProgress`, `layoutSubviews`: исходные изображения и цветовой фильтр прогрессбара Android. |
| `Math_Tricks/Game/FittingMathExpressionView.swift` | `fillsSurface`, `layoutSubviews`: фон одиночного примера растянут на всю область выражения. |
| `Math_Tricks/Game/GameResultTableView.swift` | `configure`, `rebuild`, `buildSummary`, `buildFooter`, методы таблицы: карточки счёта/времени/точности; тренировка показывает примеры, основные игры — трюки. Отдельная раскладка для альбомной ориентации. |
| `Math_Tricks/Game/SessionResultModel.swift` — новый | Группировка трюков по способу ввода, группировка пропусков с вопросом, сравнение первого/предыдущего лучшего/текущего времени. |
| `Math_Tricks/Statistics/ResultDetailsViewController.swift` — новый | `buildQuestion`, `ResultDetailsCoordinator.show/restore`, `SessionTrickResultViewController`: результат выбранного трюка → примеры → подробности ответа → решение. Возврат из решения восстанавливает подробности и прокрутку. Общие карточки статистики открывают показатели выбранного трюка или первое/лучшее время примера. |
| `Math_Tricks/Statistics/ResultComponents.swift` — новый | `ResultPalette`, `ResultUI`, `ResultMetricGrid`, `ResultColumnsView`, ячейки: общие цвета, карточки, кнопки и адаптивные колонки по образцу Android. |
| `Math_Tricks/Statistics/StatisticsViewController.swift` | `buildContent`, `placeControls`, `rebuildOverview`, `rebuildTableHeader`, методы таблицы: десять карточек показателей, четыре раздела, выбор ввода/уровня, сортировка, страницы и подробности нажатой строки. |
| `Math_Tricks/Statistics/PracticeStatistics.swift` | `PracticeAggregate.first/best`, `gameAverages`, `skipped`, `PracticeStatistics.tricks`: времена трюков считаются по средним за игру и уровень; времена примеров остаются индивидуальными. |
| `Math_Tricks/Statistics/ImportedPracticeRecord.swift` | `practiceRecords`: чтение числа пропусков из Android-архива. |
| `Math_Tricks/Game/Core/MathExample.swift`, `Math_Tricks/Game/Core/GameSession.swift` | `ExampleAttempt.selectedChoices`, `appendAttempt`, `validateSavedState`: сохранение выбранных вариантов для подробностей ответа; старые сохранения читаются без нового необязательного поля. |
| `Math_Tricks/Navigation/AppNavigation.swift` | `showResultTrick`: переход к результату трюка без изменения сохранённой игры. |
| `Math_Tricks/Design/AppComponents.swift`, `AppTypography.swift`, `AndroidImages.swift` | `setContentSpacing`, роль `gameUtility`, значки и исходные изображения: размеры и интервалы кнопок, оформление результатов. |
| `tools/import_result_resources.py` — новый; `Math_Tricks/Resources/*/Results.strings` — 26 новых файлов | Переводы подписей результатов и статистики из Android. |
| `Math_Tricks/Resources/NinePatch/theme_light_progress_bar_black.9.png`, `theme_light_progress_bar_black_light.9.png`, `theme_dark_progress_bar_black.9.png`, `theme_dark_progress_bar_black_dark.9.png` — новые | Исходные ресурсы прогрессбара Android. |

Проверка: успешная компиляция Debug для generic iOS без подписи. Тесты, установка и запуск на устройстве не выполнялись.
