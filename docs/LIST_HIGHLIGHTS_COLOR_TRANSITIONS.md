# Подсветка списков и переходы цвета

Изменён проект `ios/Math_Tricks`. Android и ios-legacy не менялись.

Подсветка нажатия подключена к спискам «Наизусть», трюков и категорий,
статистики, результатов, уровней, настроек, шагов решения, тем и вариантов выбора.
Общий цвет подсветки учитывает текущую тему. При переиспользовании ячеек
подсветка сбрасывается, а после отпускания плавно исчезает.

Переход цвета хедера, системных полос и фона использует общую длительность:
0,4 секунды и функцию сглаживания `t * t * (3 - 2 * t)`.
При смене цели переход продолжается от текущего видимого цвета.
Изменение цвета по категории сохраняет зависимость от переключателей
для каталога и игры. Смешивание цветов работает и при Reduce Motion, как
у фона Neon; отдельные ограничения анимаций перемещения не меняются.

Timely в каталоге получает цвет текущей категории при включённом первом
переключателе, как Neon. Удалено исключение, которое принудительно возвращало
Timely сохранённый основной цвет. Повторное применение основного цвета перед
цветом категории при обновлении прогресса также удалено.

Хедер и системные полосы обновляют фактический цвет покадрово через один
кратковременный CADisplayLink в режиме `.common`. При повторном запросе того же
целевого цвета переход продолжается. Переход к другой категории начинается
от последнего отображённого цвета. Внешняя UIView-анимация смены категории
удалена. Для Timely градиент и световое пятно обновляют цвета слоёв, сохраняя
маску света, частицы и анимации движения без пересоздания фоновых текстур.

В `ThemeColorTransition.Driver.apply` и `frame` удалены две ветки, которые
при Reduce Motion сразу выставляли конечный цвет. Прямые присваивания цвета
хедера в `MainMenuViewController.render`, `ThemePickerViewController.refresh`
и обработчике настроек `AgeScreenViewController.viewDidLoad` заменены общим
переходом. Панели ежедневной практики главного меню также используют его.

| Файл | Методы / типы и изменение |
| --- | --- |
| `Design/AppListCell.swift` | Новые `AppListHighlightView`, `AppListRow`, `AppListCell`: `applyHighlight`, `setActive`, обработчики нажатия и наведения, сброс в `prepareForReuse` |
| `ByHeart/ByHeartRowCell.swift` | `configure`: общая подсветка для строк «Наизусть» |
| `Catalog/TrainingCatalogCell.swift` | Ячейки трюков и категорий наследуют общий `AppListCell` |
| `Catalog/AndroidRichText.swift` | `CatalogCell.configure`: общая подсветка |
| `Catalog/LevelsViewController.swift` | `LevelCell.configure`, `updateHighlight`, `prepareForReuse`: подсветка доступных уровней; `didSelectItemAt`: снятие выделения после выбора |
| `Statistics/ResultComponents.swift` | `ResultColumnsCell.configure`, `StatisticsTextCell.configure`: общая подсветка; из `ResultColumnsView` удалён отдельный механизм нажатия |
| `Statistics/StatisticsViewController.swift` | `cellForRowAt`: передача настроек темы ячейкам статистики |
| `Game/GameResultTableView.swift` | `placeSummary`, `cellForRowAt`, `GameResultRowCell.configure`: общая подсветка результатов с сохранением неактивных заголовков |
| `Settings/SettingsViewController.swift` | `update`: настройка подсветки; `SettingsRow` наследует `AppListRow`, сохраняет отдельную обработку переключателей |
| `Game/Solutions/SolutionStepRow.swift` | `apply`: подсветка нажатия для шагов решения через `AppListRow` |
| `Theme/ThemePreviewView.swift` | `apply`: подсветка карточек тем через `AppListRow` |
| `Statistics/ResultSelectionViewController.swift` | `viewDidLoad`, `configurationUpdateHandler`: подсветка вариантов всплывающих списков |
| `Theme/ThemeColorTransition.swift` | `apply`, `eased`, `Driver.apply/frame/paint`: общий кратковременный кадровый цикл изменения фактического цвета хедера, полос и статичного фона |
| `Design/AppComponents.swift` | `AppHeaderView.apply`: общий переход цвета во всех темах |
| `Design/ThemedViewController.swift` | `catalogCategoryID.didSet`: обновление цели цвета без внешней UIView-анимации |
| `Theme/ThemeBackgroundView.swift` | `updateStaticBackground`, `frame`: общие длительность и сглаживание; `updatePaints`, `TimelyBackgroundLayers.configure`: нативный градиент и кэшированная маска света |
| `Shell/AppRootViewController.swift` | `visibleScreenChanged`: единая передача цвета категории для Timely и Neon, плавная смена полос; `viewDidLoad`: удалено повторное применение основного цвета при обновлении прогресса |

Сборка Debug для generic iOS завершилась успешно с отключённой подписью.
Журнал: `/tmp/math_tricks_faster_color_transition_build.log`.
Тесты не запускались; на устройство приложение не устанавливалось.
