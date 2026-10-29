# Изменения по образцу Android

Изменён проект `ios/Math_Tricks`. Проекты `android/Math_Tricks` и `ios-legacy/Math Tricks Free` не изменялись.

Все пути ниже указаны относительно `ios/Math_Tricks`.

| Файл | Методы / изменения | Для чего |
| --- | --- | --- |
| `Math_Tricks/Statistics/GraphViewController.swift` | `buildContent`, `update`; `AppLineChart.updateBounds`, `draw`, `selectPoint`, `drawMarker`, `drawSeriesBrackets` | График на всю область, переключатель в заголовке, заливка, пунктирная сетка, две шкалы, даты сверху и снизу, значения, маркер, скобки серий и пропуски как в Android. Масштаб сохраняется при переключении сглаживания. |
| `Math_Tricks/Multiplayer/MultiplayerSetupViewController.swift` | `buildContent`, `update`, `viewDidLayoutSubviews` | Расположение выбора шагов и способа ввода с учётом ориентации; заголовок из Android. |
| `Math_Tricks/Multiplayer/MultiplayerViewController.swift` | `buildContent`, `viewDidLayoutSubviews`, `render`, `drain`, `tick` | Полоса 5 пунктов, расположение в альбомной ориентации, отдельные результаты каждому игроку, личный/общий счёт и рекорд совместной игры, повтор и выход, сигналы ошибок и завершения. |
| `Math_Tricks/Multiplayer/PlayerInputBoard.swift` | `init`, `render`, `rebuildChoices`, `layoutSubviews`, `signalWrongInput` | Цвета и размеры, адаптивная высота клавиатуры, порядок вариантов верхнего игрока, предлагаемый ответ в выражении, пояснение после ошибки и встряхивание неверного ввода. |
| `Math_Tricks/ByHeart/ByHeartRowCell.swift` | `init`, `configure` | Размер текста, моноширинные интервалы, выравнивание, круг счёта, звёзды/замки, звезда за все уровни и приглушённый нулевой прогресс. |
| `Math_Tricks/ByHeart/ByHeartViewController.swift` | `buildContent`, `update`, `tableView(_:cellForRowAt:)` | Новое оформление строк, отсутствие разделителей и видимость кнопки в заголовке. |
| `Math_Tricks/ByHeart/ByHeartExamplesViewController.swift` | `buildContent`, `update` | Центрирование списка, разделитель, курсив примеров, размер текста и видимость стрелок в заголовке. |
| `Math_Tricks/Game/GameViewController.swift` | `buildContent`, `render`, `perform` | Предлагаемый ответ «верно / неверно» внутри выражения; пояснение занимает свою область; ошибки вариантов звучат независимо от настройки сигналов цифрового ввода; неверный цифровой ввод встряхивается. |
| `Math_Tricks/Services/AppFeedback.swift` | `play` | Громкость сигнала цифровой ошибки 15%, как в Android. |
| `Math_Tricks/Design/AppTypography.swift` | `AppTextRole.size`, `AppTypography.font` | Размеры клавиш двух игроков, результатов и примеров «Наизусть». |
| `Math_Tricks/Design/AndroidImages.swift` | `AppIcon` | Исходные значки сглаживания графика и разделителя примеров. |
| `Math_Tricks/Resources/AndroidDimensions.json` | Импорт размеров | Размеры круга счёта, результатов и примеров для телефонов и планшетов. |
| `Math_Tricks/Resources/*.lproj/Main.strings` — 26 файлов | Восемь строк из Android | Подписи графиков, настройки шагов и результаты игроков на всех имеющихся языках. |
| `tools/import_android_dimensions.py`, `tools/import_main_strings.py`, `tools/import_localizations.py` | Наборы импортируемых ресурсов | Сохранение новых размеров и переводов при следующем импорте. |

Проверка: успешная компиляция Debug для generic iOS, без подписи. Тесты, установка и запуск на устройстве не выполнялись.
