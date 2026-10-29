Изменён проект: `ios/Math_Tricks`.
Проекты `android/Math_Tricks` и `ios-legacy/Math Tricks Free` не изменялись. Android использован как образец.

Файлы и методы:

| Файл | Методы / компоненты | Изменение |
| --- | --- | --- |
| `Game/GameViewController.swift` | `requestBack`, `render`, `update`, `shareResult` | Результат «Без времени» остаётся после сохранения; обновляются цвета категории; выводятся монеты; отправляется отдельная карточка результата. |
| `Game/GameResultTableView.swift` | `layoutSubviews`, `rebuild`, `buildSummary`, `buildFooter`, методы таблицы | Убран пересчёт `tableHeaderView` внутри layout, который мог зациклить переход после таймера. Сводка и заголовок стали обычными ячейками. Исправлены повторное использование заголовка, панели, карточки, шрифты и кнопки. |
| `Statistics/ResultComponents.swift` | `ResultMetricGrid.geometry`, `sizeThatFits`, `layoutSubviews`, `ResultSummaryCell.systemLayoutSizeFitting`, `ResultUI.font` | Размеры карточек определяются по тексту, как в Android; учтены масштаб 160%, равная высота карточек, отдельные отступы и начертания. |
| `Statistics/StatisticsViewController.swift` | `selectInput`, `selectLevel`, `selectPageSize`, `choose`, `share` | Выпадающий выбор ввода и размера страницы, радиовыбор уровня; экспорт данных текущей страницы вместо снимка экрана. |
| `Statistics/ResultSelectionViewController.swift` — новый | `viewDidLoad`, `viewDidLayoutSubviews`, `radio` | Прокручиваемые выпадающие списки и диалог одиночного выбора с отмеченным текущим значением. |
| `Statistics/ResultDetailsViewController.swift` | `viewDidLoad`, `accessibilityPerformEscape`, `SessionTrickResultViewController.share` | Оформление диалога, расположение «Решение» и OK, закрытие снаружи; отдельная карточка для отправки результатов дочернего трюка. |
| `Statistics/ResultShareCard.swift` — новый | `session`, `make`, `links` | Отдельное изображение шириной 1080: логотип, режим, счёт, статистика и до 15 строк, ссылки Android/iPhone в отправляемом сообщении. |
| `Theme/ThemePickerViewController.swift` | `viewDidLoad`, `viewDidLayoutSubviews`, `refresh`, `select`, `save`, методы прокрутки | Карусель шести тем с соседними карточками; размеры и компоновка по Android; масштаб 80–200% с шагом 5%, системная отметка; кнопка смены предпросмотра, сворачивание панели, два переключателя цветов; отдельная горизонтальная компоновка. Черновик сохраняется одной операцией. |
| `Theme/ThemePreviewView.swift` | `apply`, `decorate`, `showFrame`, `setReferenceSize` | Рамка выбранной темы и четыре масштабируемых экрана: игра, меню, решение, список приёмов. |
| `Settings/FontSamplePreview.swift` | `rebuild`, `buildGame`, `showFrame`, `referenceSize` | Игровой предпросмотр с полем, монетами, кнопками и оригинальным прогрессбаром; учтены ориентация и реальный размер сцены. |
| `Main/MainMenuViewController.swift` | `init(previewSettings:)`, `viewDidLoad`, `render` | Предпросмотр использует настоящий интерфейс главного меню с демонстрационными числами, без подписки на прогресс и действий пользователя. |
| `Theme/ThemeExpressionSurfaceView.swift` — новый | `apply`, `layoutSubviews`, `updateMotion` | Геометрия рамки Android: отступ 8, радиусы 18/14, HSV-градиент, свечение и вращение; учитываются экономия энергии и уменьшение движения. |
| `Game/FittingMathExpressionView.swift` | `apply`, `layoutSubviews` | Новая поверхность примера, поддержка цвета игрока. |
| `Multiplayer/PlayerInputBoard.swift` | `render`, настройка компоновки | Передаётся цвет игрока рамке примера. |
| `Multiplayer/MultiplayerProgressView.swift` — новый | `setProgress`, `layoutSubviews` | Прямоугольный прогрессбар без системного скругления UIKit. |
| `Multiplayer/MultiplayerViewController.swift` | `buildContent`, `render` | Прогрессбар Android, убрана дополнительная центральная кнопка возврата; сохранены навигация и действие VoiceOver. |
| `Catalog/LevelsViewController.swift` | `buildContent`, `viewDidLayoutSubviews`, методы сетки, `LevelCell.height`, `configure`, `layoutSubviews` | Сетка без дополнительных промежутков; 3/5 столбцов с учётом масштаба; моноширинный шрифт нужного размера, цвета категории, исходные размеры звёзд/замка, отдельная подпись статистики, расчёт высоты по тексту. |
| `Data/ProgressModels.swift` | `AppSettings`, `SettingsChange.appearance` | Добавлены необязательный цвет фона игры и параметры шрифта в едином сохранении темы. Старые данные совместимы. |
| `Data/ProgressRepository.swift` | обработка `.appearance` | Валидация и атомарное сохранение новых настроек. |
| `Shell/AppRootViewController.swift` | `visibleScreenChanged` | Переключатель цвета игровой категории влияет на фон Timely/Neon. |
| `tools/import_result_resources.py`, `Resources/*/Results.strings` | импорт ресурсов | Добавлены переводы настроек тем и ссылки для отправки в 26 локалях. |
| `Assets.xcassets/result_share_logo.imageset` — новый | ресурс | Логотип для экспортируемой карточки. |

Проверка: компиляция Debug для generic iOS без подписи. Тесты, установка и запуск на устройстве не выполнялись.

Остаётся: рекламные награды, рекламное удвоение и дополнительные попытки требуют отдельного подключения rewarded-рекламы в iOS; действующего рекламного сервиса в этом проекте нет. Пиксельное совпадение и исправление зависания необходимо подтвердить при ручной проверке на устройстве.
