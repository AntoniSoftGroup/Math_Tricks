# Этап 24: исправления по списку из 14 расхождений

19.10.2026. Изменён только проект `ios/Math_Tricks`. `android/Math_Tricks` и
`ios-legacy/Math Tricks Free` не изменялись. Существовавшие изменения сохранены.

## Код и методы

Все пути в таблице — внутри `Math_Tricks/`, кроме явно указанных `tools/` и `docs/`.

| Пункты | Файлы и методы | Изменение и назначение |
|---|---|---|
| 1 | `Game/Core/MathExample.swift`: `GameDifficulty.contains`, `GameConfiguration.validate`, `MathExample.generate`; `Game/Core/GameSession.swift`: `accept`, `validateSavedState`; `Game/GameModesViewController.swift`: `update`, `levelEditingEnded`, `changeLevel`, `launch`; `Data/ProgressRepository.swift`: `validate`; `Archives/AndroidProgressArchive.swift`: `validate` | Убран общий предел 100 для обычной сложности, выбора, повышения, сессий и Android-статистики. Диапазон счётчика соответствует Java Int32. Учебные 100 уровней, 21 этап заучивания и варианты дневных настроек сохранены отдельно. |
| 1–2 | `Game/Core/AndroidExampleGenerator.cpp`, `tools/import_example_generator.py`: `MTGenerateExample`, `Generator.power`; `Game/Core/MathExample.swift`: `validateSavedExample` | Все 107 формул сохраняют исходные ветви насыщения. Промежуточные целые расширены до 128 бит, степень проверяет переполнение, C ABI проверяет представимость. Генерация теперь проверяет пример тем же валидатором, что архив. Проверка арифметики использует Decimal, корень проверяется обратным возведением ответа в степень. Допущены степени 2, 3, 4, 5, 6, 9. |
| 3–5 | `Game/Core/GameSession.swift`: начальные значения, `skip`, `nextExample`, `appendAttempt`, `choose`, `chooseBoolean`, `validateSavedState` | Новая партия: 5 подсказок и 5 пропусков. Пропуск сохраняет таймер и истечение времени; отдельное смещение не позволяет повторно учитывать время пропущенного примера в статистике. Неверные варианты блокируются в модели и сохраняются в JSON. Новые поля optional для старых сессий. |
| 5–6 | Новый `Game/Core/AnswerChoices.swift`: `make`, `validValue`; `Game/Core/GameSession.swift`: `nextExample` | Перенесены четыре Android-схемы изменения разрядов, выбор позиции правильного ответа и логического предложения. У квадратов с окончаниями 5/25/75/125 сохранены окончания вариантов. Отрицательные неверные варианты Android допускаются в истории и архиве. Лимит цифрового ввода расширяется для больших ответов, сохраняя прежний ввод коротких ответов. |
| 5, 13–14 | `Game/GameViewController.swift`: `buildContent`, `render`, `update`; `Multiplayer/PlayerInputBoard.swift`: `render` | Неверные кнопки блокируются и тускнеют, неправильный числовой вариант заменяется крестиком; защита действует также в двух игроках. После логической ошибки появляется прокручиваемое пояснение из имеющихся шагов решения. В скорости скрыт уровень, в дневной игре — обычные очки. Звёзды 0–3 используют исходные Android drawable. |
| 7–8 | `Statistics/GraphViewController.swift`: `update`, `dailyPoints`; `AppLineChart`: `updateBounds`, `draw`, `pinch`, `pan`, `selectPoint`, `resetZoom`, accessibility increment/decrement | Дневная вертикаль показывает решённые примеры. Дневная цель, прямые/сглаженные линии, pinch 1–20×, перемещение, сброс двойным нажатием, выбор точки, серии и пропуски. Ограничение последних 1000 точек удалено; viewport использует бинарный поиск. Застрахованные неуспешные дни остаются в данных и исключаются из восстановленной линии. |
| 7–8 | `Daily/DailyProgressEngine.swift`: `dayNumber`, `advance`, `record`; `Data/ProgressModels.swift`: optional `seriesStartDay`, метаданные `HistoricalGraphPoint`, `graphSmoothed`; `Archives/AndroidProgressArchive.swift`: `nativeArchive`; `Archives/AndroidArchiveExport.swift`: `androidEncoded` | Сохраняется начало серии для восстановления после страхования, импортируются исходные метаданные графика. В Android-экспорте Y дневной точки также исправлен со streak на solved, серия передаётся отдельно. Форма линии сохраняется в настройках. |
| 9–12 | `Statistics/StatisticsViewController.swift`: `buildContent`, `rebuild`, `updateSelections`, `changeLevel`, `selectLevel`, `selectPageSize`, `confirmClear`; `Navigation/AppNavigation.swift`: маршруты статистики, `makeScreen` | Начальный экран — обзор с переходами в четыре списка, ввод по текущей игровой настройке. Фильтр ввода переносится в подробности. Для приёмов доступны реальные отдельные уровни и десятки, включая >100. Рекомендации: до пяти медленных по чистому среднему времени и до пяти с ошибками по errors/attempts. Страницы 10/20/50/100, для приёмов также «Все». Добавлена очистка с подтверждением. |
| 10–12 | `Statistics/ImportedPracticeRecord.swift`: `practiceRecords`, `matches`; `Statistics/PracticeStatistics.swift`: `init`, `PracticeAggregate.attempts/errorRate`; `Data/ProgressModels.swift`: `statisticsBaseline`; `Data/ProgressRepository.swift`: `practiceStatistics`, `clearPracticeStatistics`, `updateSettings`; `Data/AppDataStore.swift`: `clearPracticeStatistics`; `Archives/ProgressArchive.swift`: `validate`; `Archives/AndroidArchiveExport.swift`: `androidEncoded` | Детальные и групповые Android-измерения доступны раздельно без двойного подсчёта. Очистка атомарно убирает три исходные статистические таблицы и задаёт границы уже учтённых iOS-попыток, сохраняя живые партии, обучение, результаты и настройки. Новые попытки действующих партий учитываются; очищенные измерения не возвращаются при экспорте Android. Валидация новых optional-полей сохранена. |
| Подписи | `tools/import_localizations.py`, `tools/localization/interface.en.json`, `tools/localization/interface.ru.json`, `Resources/{ar,be,bn,de,el,en,es,fa,fr,he,hu,id,it,ja,ka,ko,pl,pt,ro,ru,th,tr,uk,vi,zh-Hans,zh-Hant}.lproj/Interface.strings`, `docs/LOCALIZATION_REPORT.json` | Девять новых подписей/сообщений, исходные Android-переводы при наличии и документированный fallback. Подтверждение локальной очистки не обещает отсутствующее облако. |
| Контекст | `docs/CONTINUATION_CONTEXT.md`, `docs/MIGRATION_PLAN.md`, `docs/STAGE_24_LOCAL_PARITY.md`, этот файл | Обновлена точка продолжения и перечень реально внесённых изменений. |

## Проверка и границы

Итоговая **Debug BUILD — OK**, exit code 0:

```sh
xcodebuild -quiet -project Math_Tricks.xcodeproj -scheme Math_Tricks \
  -configuration Debug -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/math_tricks_migration_derived CODE_SIGNING_ALLOWED=NO build
```

Лог: `/tmp/math_tricks_parity_build.log`. В изменённом коде ошибок компиляции нет.
В итоговом логе осталось прежнее предупреждение NumberFormatter о лишнем
`nonisolated(unsafe)` в `Game/MathExpressionFormatter.swift`; этот файл не менялся.

Автотесты не создавались и не запускались. Приложение не устанавливалось и не
запускалось согласно специальному режиму BUILD-only из контекста миграции.
Инструментами разработки пользовательская база, импорт, экспорт и очистка не
вызывались. Реклама, Game Center, покупки, облако и будильник не добавлялись.

Это исправление исходников, а не выполненная визуальная приёмка. Проверка на
устройстве остаётся пользователю: таймер при пропуске, восстановление блокировок,
ввод/отображение больших ответов, архивы, фильтры и очистка статистики, жесты
графика, страховки, большие шрифты, RTL и повороты.

Предел 100 снят, но не обещается математическая корректность исходного Android
при любом значении Int32: отдельные Android-формулы растут без ограничений,
содержат Float и на крайних значениях сами выходят из исходных числовых диапазонов.
Сохранены явные границы представимости: целые отображаемые операнды до 2^53−1,
ответ до 10^15. Непредставимый или арифметически неверный пример отклоняется с
ошибкой, уровень молча не подменяется меньшим. Существующий построитель пошаговых
схем имеет собственную проверку операндов Int32; для больших значений может
показываться общее правило. Полную поддержку крайних значений и визуальное
совпадение ещё нельзя объявлять завершёнными.
