# Прокрутка только при нехватке места

19.10.2026. По запросу пользователя отключено оттягивание за границы содержимого
во всех собственных экранах iOS. Если содержимое помещается с учётом отступов,
pan-прокрутка отключена. При увеличении содержимого, раскрытии группы, повороте,
изменении текста/шрифта или масштаба она автоматически включается снова.

## Реализация

`Math_Tricks/Design/AppScrollView.swift`:

- `AppScrolling.update`: выключает bounces, bouncesZoom и alwaysBounce для обеих
  осей; сравнивает contentSize с bounds и adjustedContentInset с допуском в один
  физический пиксель. Отключает pan, когда всё помещается, и ограничивает offset
  после уменьшения содержимого.
- `AppScrollView`, `AppTableView`, `AppCollectionView`, `AppTextView` вызывают
  общую обработку из `init`, `contentSize.didSet`, `layoutSubviews` и
  `adjustedContentInsetDidChange`.
- У схемы с zoom масштабирование сохраняется даже при отсутствии переполнения;
  pan включается лишь когда увеличенная схема не помещается.
- `AppScrollView.scrollingAllowed` сохраняет отдельную временную блокировку
  карусели во время записи настроек темы. Автоматический расчёт переполнения
  не разблокирует карусель раньше завершения записи.

## Файлы подключённых экранов

В перечисленных файлах собственные UIScrollView / UITableView /
UICollectionView / UITextView заменены соответствующим подклассом. Делегаты,
данные и способы сохранения не менялись.

| Файл относительно Math_Tricks/ | Место изменения |
|---|---|
| `Design/ThemedViewController.swift` | `scrollStack`: общая прокрутка всех экранов, использующих этот помощник. |
| `Design/AppDialogViewController.swift` | `viewDidLoad`: содержимое диалога. |
| `Main/MainMenuViewController.swift` | `rebuildLayout`: основное меню. |
| `Theme/ThemePickerViewController.swift` | `pages`, `contentScroll`, `viewDidLoad`, `save`: карусель, настройки, временная блокировка. |
| `Settings/SettingsViewController.swift` | `buildContent`: список настроек. |
| `Settings/TextAndKeypadViewController.swift` | `buildKeypads`: карточки клавиатур; предпросмотры шрифта через общий scrollStack. |
| `Catalog/TricksViewController.swift` | `table`, `buildContent`: дерево приёмов. |
| `Catalog/LevelsViewController.swift` | `grid`, `buildContent`: сетка уровней. |
| `Catalog/RuleViewController.swift` | `textView`: текст правила. |
| `Catalog/TrainingUnlockViewController.swift` | `viewDidLoad`: диалог разблокировки. |
| `ByHeart/ByHeartViewController.swift` | `table`: числа и учебные этапы. |
| `ByHeart/MultiplicationTableViewController.swift` | `buildContent`: таблица умножения. |
| `Game/GameModesViewController.swift` | `modesScroll`, `buildContent`: выбор режима. |
| `Game/GameViewController.swift` | `booleanSolutionScroll`, `ruleScroll`: пояснения и название приёма. |
| `Game/GameResultTableView.swift` | `table`: фактические попытки партии. |
| `Game/SolutionViewController.swift` | `diagramScroll`, `rule`: схема с zoom и правило. |
| `Statistics/StatisticsViewController.swift` | `table`: статистика. |
| `Shell/ShellScreenViewController.swift` | `viewDidLoad`: вспомогательные назначения оболочки. |

Системные окна iOS (выбор файлов, системная отправка, Safari, настройки) не
подменяются подклассами приложения. Изменён только проект `ios/Math_Tricks`;
`android/Math_Tricks` и `ios-legacy/Math Tricks Free` не изменялись.

Debug BUILD с подписью успешен, exit code 0. Лог:
`/tmp/math_tricks_scroll_build.log`. Автотесты не создавались и не запускались.
Сборка установлена и запущена на iPhone (Antoni), PID 2725;
`DETACH_AND_RESUME=success`, exit code 0. Лог: `/tmp/math_tricks_scroll_install.log`.
