# Интерфейс iPhone Duo

Изменён только современный iOS-проект `ios/Math_Tricks`.
Android, `ios-legacy`, архивы ZIP и проект AppStoreScreenshots не изменялись.

## Камера и внешняя панель

`UIHingeInteraction` ограничивает новые правила устройством Duo. Другие устройства
сохраняют системные safe area и статус-бар. На Duo время, Wi-Fi, заряд и прочие
элементы статус-бара скрываются общим контроллером, включая собственные диалоги.
Корневая оболочка SwiftUI получает то же состояние Duo через callback общего
контейнера. Принудительный `.statusBarHidden(false)` удалён: раньше он оставлял
время и Wi-Fi видимыми, несмотря на `prefersStatusBarHidden` вложенного UIKit.
После скрытия статус-бара шапка пересчитывается по активным Reserved Regions;
отдельная область под системные значки вручную не добавляется.

На внешнем дисплее фон шапки занимает полную ширину и высоту верхней области
камеры. Содержимое шапки обходит камеру по горизонтали; при камере сверху слева
кнопка Back оказывается справа от занятой области. Solution обрабатывает Back
отдельно, а кнопки таблицы умножения и метода переносит под правую верхнюю камеру.

При камере внизу общий контейнер резервирует полосу на всю ширину от верхней
границы системной области камеры до нижнего края дисплея и закрашивает её чёрным.
Интерфейс и общий рекламный баннер заканчиваются над полосой. Её цвет не зависит
от темы. В игре вдвоём вместо нижней полосы резервируется вертикальная полоса
на всю высоту на стороне камеры — как в портрете, так и в ландшафте. Обе панели
игроков, результаты и рекламный баннер сдвигаются общим корневым контейнером.
Перевёрнутый портрет разрешён контроллерами только на Duo; в декларации
приложения добавлена соответствующая ориентация.

Координаты берутся из активных Reserved Regions, в локальных координатах view.
Их системные поля повторно не добавляются. Неактивная внутренняя камера не
резервирует место. Внутренний плоский дисплей использует всю доступную площадь,
с сохранением нижнего безопасного отступа системного жеста.

## Сгиб и анимация

Для связанных панелей применяется `UIArrangementViewController` с `.split`:

- Game сохраняет свой существующий системный контейнер.
- GameType разделяет выбор уровня и список режимов; на Duo в ландшафте панели
  равны, вместо прежнего отношения 1:2.
- Solution разделяет схему и панель шагов, действий и клавиатуры.
- Rule разделяет схему с операндами и список шагов с действиями.
- Игра вдвоём и её результаты размещают игроков в отдельных системных панелях.
- Главное меню использует пару меню/сведений и в раскрытом портрете, и в ландшафте.
- Настройка игры вдвоём разделяет выбор длины и способы ввода с кнопками запуска.
- Настройки текста разделяют образцы и регуляторы; выбор клавиатуры — два варианта.
- Выбор темы разделяет карусель образцов и панель настройки цвета/шрифта.

Контейнер сохраняется и на плоском внутреннем дисплее, чтобы UIKit управлял
переходом от отсутствующего отступа к активному сгибу и обратно. Обе оси
поддерживаются. Существующие views и их состояние сохраняются при переносе.
При выходе с внутреннего дисплея восстанавливается обычная стековая компоновка.
Вложенные системные контроллеры снимаются с родителя при удалении их host view.

На полностью раскрытом внутреннем экране две смысловые панели уже расположены
одна над другой в портрете, рядом — в ландшафте. При лёгком или сильном сгибе UIKit
анимирует отступ между существующими панелями, не создавая их заново. Доступность
внутреннего дисплея проверяется с `.includeInactive`, поэтому отсутствие активного
сгиба не отключает пару.

Окна без двух смысловых панелей, в том числе списки, формы и собственные диалоги,
сохраняют всю область и существующую прокрутку при сгибе. Общий контейнер больше
не устанавливает overlay-область и не переносит содержимое в верхнюю половину.
Правила камеры и нижней чёрной полосы продолжают действовать независимо от сгиба.

Отступы и переходы внутри системных областей анимирует UIKit. Ручная интерполяция
угла, таймер анимации и фиксированная длительность не добавлены. Корневой host
навигации и баннера сам не делится: размещением содержимого управляют экраны.

## Изменённые файлы и методы

Все пути ниже относительно `ios/Math_Tricks`.

| Файл | Методы / изменение |
|---|---|
| `Math_Tricks/Design/AppDuoLayout.swift` | `AppDuoViewController.loadView()`, `prefersStatusBarHidden`: общий Duo-контейнер и скрытие статус-бара. `AppDuoContentView.init`, `updateConstraints()`, `layoutSubviews()`, `setContentAnchors(to:)`: полная область и чёрная нижняя полоса; единые окна не сжимаются при сгибе. `AppDuoLayout.bottomCameraInset(in:)`, `headerHeight(in:minimum:)`: геометрия камеры. `AppDuoAvoidingView.updateConstraints()`: полный фон шапки и горизонтальный обход камеры. |
| `Math_Tricks/Game/AppDuoGameArrangement.swift` | `make()`, `NativeDuoGameArrangement.viewDidLoad()`, `update(animated:)`: системный split на обеих осях, включая плоский внутренний экран; single-pane/overlay удалён. `AppDuoSplitView.addArrangedSubview(_:)`, `synchronizeArrangement()`, `didMoveToWindow()`, `removeAllArrangedSubviews()`, `detachArrangement()`: переиспользуемая системная пара и корректное снятие дочернего контроллера. |
| `Math_Tricks/Design/AppComponents.swift` | `AppHeaderView.init(title:onBack:)`: включён фон на всю верхнюю область камеры. |
| `Math_Tricks/Design/ThemedViewController.swift` | Общая база Duo; `supportedInterfaceOrientations`: перевёрнутый портрет только для Duo/планшетов. |
| `Math_Tricks/Game/GameModesViewController.swift` | `buildContent()`, `viewWillLayoutSubviews()`, `viewDidLayoutSubviews()`: системная пара, снятие обычных ограничений и равные половины Duo; ширина кнопок по фактической панели. |
| `Math_Tricks/Game/SolutionViewController.swift` | `buildContent()`, `viewDidLayoutSubviews()`: системные схема/шаги. `updateDuoCameraControls()`: Back справа от левой камеры, таблица/метод ниже правой камеры; Back входит в панель схемы при сгибе. |
| `Math_Tricks/Catalog/RuleViewController.swift` | `buildContent()`, `viewDidLayoutSubviews()`: системная пара схемы и шагов, отключение ручных размеров панелей на внутреннем Duo. |
| `Math_Tricks/Multiplayer/MultiplayerViewController.swift` | `buildContent()`, `synchronizeDuoPanes()`, `viewDidLayoutSubviews()`, `render()`: системные пары игроков и результатов, возврат в обычную компоновку, видимость и интерактивность результатов. |
| `Math_Tricks/Multiplayer/MultiplayerSetupViewController.swift` | `buildContent()`, `synchronizeDuoPanes()`, `viewDidLayoutSubviews()`: системная пара длины/ввода; кнопки запуска входят во вторую панель; обычная компоновка восстанавливается на внешнем дисплее. |
| `Math_Tricks/Settings/TextAndKeypadViewController.swift` | `buildContent()`, `buildKeypads()`, `synchronizeDuoPanes()`, `viewDidLayoutSubviews()`: системная пара образцов/регуляторов шрифта и двух вариантов клавиатуры; отдельная прокрутка внутри панелей. |
| `Math_Tricks/Multiplayer/PlayerInputBoard.swift` | `init(frame:)`: камера обходится корневым контейнером сразу для обоих игроков; локальное сжатие отдельной панели убрано. Поля строк заголовка не увеличиваются от safe area; элементы информационной панели защищены от скруглений внутреннего экрана. |
| `Math_Tricks/Main/MainMenuViewController.swift` | Общая база Duo; `viewDidLoad()`: полная шапка. `viewDidLayoutSubviews()`, `rebuildLayout(landscape:)`: системная пара на внутреннем экране в обеих ориентациях, включая полностью раскрытый портрет. |
| `Math_Tricks/Onboarding/AgeScreenViewController.swift` | Общая база Duo; `viewDidLoad()`: полная шапка; `supportedInterfaceOrientations`: ориентации Duo. |
| `Math_Tricks/Shell/AppRootViewController.swift` | Общая база Duo; `loadView()`: общий контейнер камеры без повторного разделения корня; `prefersStatusBarHidden`: статус-бар скрыт на Duo; `isolated deinit`: очистка на главном actor. |
| `Math_Tricks/Shell/ShellScreenViewController.swift` | Общая база Duo и ориентации Duo для окон оболочки. |
| `Math_Tricks/Theme/ThemePickerViewController.swift` | Общая база Duo; `viewDidLoad()`, `synchronizeDuoPanes()`, `viewDidLayoutSubviews()`: системная пара карусели и настроек на внутреннем дисплее в обеих ориентациях; полный фон шапки и отдельная область её элементов; ориентации Duo; `isolated deinit`. |
| `Math_Tricks/Design/AppDialogViewController.swift` | Общая база Duo; `init`, `viewDidLoad()`: собственный диалог скрывает статус-бар и использует общую область содержимого. |
| `Math_Tricks/Catalog/TrainingUnlockViewController.swift` | Общая база Duo; `init`, `viewDidLoad()`: те же правила для диалога покупки приёма. |
| `Math_Tricks/Statistics/ResultDetailsViewController.swift` | Общая база Duo; оба `init`, `viewDidLoad()`: те же правила для деталей результата. |
| `Math_Tricks/Statistics/ResultSelectionViewController.swift` | Общая база Duo; `init`, `viewDidLayoutSubviews()`: те же правила для списка выбора. |
| `Math_Tricks.xcodeproj/project.pbxproj` | Debug/Release: объявлена возможность перевёрнутого портрета iPhone; обычные iPhone по-прежнему ограничены маской контроллеров. |
| `docs/IPHONE_DUO_LAYOUT.md` | Актуальное поведение, перечень файлов/методов и ограничения проверки. |

## Компиляция и проверка

Новые API защищены `MATH_TRICKS_DUO_SDK` и `if #available(iOS 27.1, *)`.
Флаг отключается при сборке SDK 26.x и 27.0. Для Duo требуется SDK 27.1 или новее:
старый SDK оставляет приложение в системном режиме совместимости.

Здесь установлен Xcode 26.6 с iPhoneOS SDK 26.5. Компиляция Debug/generic iOS
успешна; подпись, установка, запуск и тесты не выполнялись. Эта сборка проверяет
общий код и совместимость со старым SDK; ветка с новыми API исключена.
Компиляция ветки Duo SDK 27.1, геометрия камер и системная анимация сгиба требуют
проверки в Xcode 27.1/новее на Duo или соответствующем симуляторе.

## Документация Apple

- [Подготовка к iPhone Duo](https://developer.apple.com/iphone-duo/prepare/)
- [UIArrangementViewController](https://developer.apple.com/documentation/uikit/uiarrangementviewcontroller)
- [UISplitArrangement](https://developer.apple.com/documentation/uikit/uisplitarrangement-swift.struct)
- [UIView.ReservedRegion](https://developer.apple.com/documentation/uikit/uiview/reservedregion)
- [UIHingeInteraction](https://developer.apple.com/documentation/uikit/uihingeinteraction)

## Уточнение портретного режима

В этой правке удалён общий перенос единых окон вверх. Изменены:
`AppDuoLayout.swift` (`updateConstraints`, `layoutSubviews`),
`AppDuoGameArrangement.swift` (`make`, `NativeDuoGameArrangement`),
`MainMenuViewController.swift` (`viewDidLayoutSubviews`, `rebuildLayout`),
`MultiplayerSetupViewController.swift`, `TextAndKeypadViewController.swift`,
`ThemePickerViewController.swift` (`buildContent`/`viewDidLoad`,
`synchronizeDuoPanes`, `viewDidLayoutSubviews`). В `RuleViewController.swift`,
`GameModesViewController.swift`, `GameViewController.swift`,
`SolutionViewController.swift`, `MultiplayerViewController.swift` и
`AppRootViewController.swift` сняты больше не нужные отключения single-pane host.
Существующий игровой split сохранён. Списки и остальные единые окна не делятся.

Изменён только `ios/Math_Tricks`. Android, `ios-legacy`, ZIP-архивы и
AppStoreScreenshots не изменены.

## Исправление значков под камерой

- `Math_Tricks/Math_TricksApp.swift`, `body`: удалено принудительное отображение
  статус-бара в корне SwiftUI.
- `Math_Tricks/ContentView.swift`, `body`, `AppRootHost.makeUIViewController`,
  `dismantleUIViewController`: видимость статус-бара синхронизируется с Duo для
  текущего окна; callback снимается при удалении host. Обычные устройства сохраняют
  статус-бар. Переключение не пересоздаёт навигацию и рекламный баннер.
- `Math_Tricks/Design/AppDuoLayout.swift`, `onDuoAvailabilityChange`, hinge handler
  в `init(frame:)`: состояние Duo передаётся внешнему SwiftUI-контейнеру.
- `docs/IPHONE_DUO_LAYOUT.md`: причина, исправление и перечень методов.

Компиляция проверяет общий код в Xcode 26.6/SDK 26.5. Фактическое скрытие значков
и высоту шапки Duo необходимо проверить при сборке SDK 27.1 или новее.

## Общая полоса камеры, закругления и поля кнопок

В этой правке изменён только `ios/Math_Tricks`. Android, `ios-legacy`, архивы ZIP
и AppStoreScreenshots не изменялись.

### Результат анализа

- Раньше `PlayerInputBoard` отдельно выбирал свободный прямоугольник вокруг
  камеры. Поэтому при пересечении камеры только одним игроком менялась лишь его
  панель. Теперь камера резервирует общую вертикальную полосу у физического левого
  или правого края окна. Полоса чёрная во всех темах. После следующей правки в портрете она
  горизонтальная, в альбомной ориентации — вертикальная. Ориентация и положение камеры берутся из текущих
  координат Reserved Regions; ширина не прибавляется к системному отступу второй раз.
- В `GameViewController` строки `utilityActions` и `moveRow` используют явные поля
  и `isLayoutMarginsRelativeArrangement`. UIKit по умолчанию может расширять их
  полями safe area. На Duo `AppDuoStackView` отключает такое расширение: заданные
  поля кнопок сохраняются, а камеру и края учитывает внешний контейнер. То же
  правило действует для содержимого общих кнопок и строк информации игроков.
- В `MainMenuViewController.buildMenu(in:size:includesSecondaryActions:)` все
  основные кнопки, включая «Два игрока», размещаются одним стеком с одинаковыми
  боковыми ограничениями. Отдельного камерного отступа у этой кнопки нет; её
  собственные размеры и общие поля меню не менялись.
- На внутреннем экране элементы шапок и реклама защищаются safe area текущего
  окна и минимальным полем 16 pt от физического края. Применяется больший отступ,
  а не сумма двух отступов. Отступы считаются в локальных координатах: уже
  отодвинутый элемент и внутренний край между панелями не получают повторного поля.
  Фоны шапок сохраняют полную область. Прокручиваемая шапка, ушедшая за край окна,
  не увеличивает высоту вслед за safe area.
- Размер рекламы запрашивается по фактической защищённой ширине. Вертикальные
  защитные поля при необходимости включаются в высоту контейнера, сохраняя высоту
  самого баннера. Расчёт ширины доступен и при первоначально свёрнутом контейнере.

### Файлы и методы этой правки

| Файл | Изменение |
|---|---|
| `Math_Tricks/Design/AppDuoLayout.swift` | `AppDuoContentView.cameraBandStyle`, `updateConstraints()`, `layoutSubviews()`: общий боковой резерв и чёрная полоса. `AppDuoLayout.cameraBandFrame(in:style:)`: физическая сторона камеры. `isInnerDisplay(in:)`, `roundedCornerInsets(in:within:)`, `roundedCornerSafeFrame(in:within:)`, `headerHeight(in:minimum:)`: безопасные края внутреннего дисплея. `AppDuoAvoidingView.updateConstraints()`: отдельные правила камеры и закруглений. `AppDuoStackView.layoutSubviews()`: исключение повторных полей safe area только на Duo, восстановление исходного поведения вне Duo. |
| `Math_Tricks/Shell/AppRootViewController.swift` | `visibleScreenChanged(_:)`: вертикальная полоса на всём окне при игре вдвоём; возврат к обычной нижней полосе при выходе. |
| `Math_Tricks/Multiplayer/PlayerInputBoard.swift` | `init(frame:)`: убран локальный сдвиг всей панели от камеры; строки информации используют явные поля, информационная область защищена от скруглений. |
| `Math_Tricks/Game/GameViewController.swift` | `utilityActions`, `moveRow`: стеки с явными полями без повторного отступа камеры. |
| `Math_Tricks/Design/AppComponents.swift` | `AppButton.init(...)`: одинаковая политика полей внутренних строк всех кнопок на Duo. |
| `Math_Tricks/Shell/BannerContainerView.swift` | `init(frame:)`, `update(presenter:visible:canRequestAds:)`, `setContent(_:height:)`: безопасные края, запрос по доступной ширине и корректная высота баннера. |
| `Math_Tricks/Theme/ThemePickerViewController.swift` | `viewDidLayoutSubviews()`: ручная шапка использует ту же защиту от закруглений. |
| `docs/IPHONE_DUO_LAYOUT.md` | Обновлены правила полосы, результаты анализа и перечень методов. |

Компиляция — Xcode 26.6 / SDK 26.5, Debug для generic iOS, без подписи, установки,
запуска и тестов. Ветка Duo требует SDK 27.1+; полосу камеры, закругления и реальные
отступы нужно визуально проверить на соответствующем устройстве или симуляторе.

Основание: [UIKit — insetsLayoutMarginsFromSafeArea](https://developer.apple.com/documentation/uikit/uiview/insetslayoutmarginsfromsafearea),
[UIKit — safeAreaInsets](https://developer.apple.com/documentation/uikit/uiview/safeareainsets).

## Уточнение портрета, стрелок и парных панелей

Изменён только современный проект `ios/Math_Tricks`. Android, `ios-legacy`,
архивы ZIP и AppStoreScreenshots не изменялись.

- В игре вдвоём полоса камеры в портрете горизонтальная, в альбомной ориентации
  вертикальная. Резервируется общий край всего окна, включая обоих игроков и
  рекламу. При повороте правило пересчитывается по текущим размерам окна.
- Back центрируется по вертикали безопасной области шапки, включая увеличенную
  шапку у камеры. Общая геометрия применяется также к ручной шапке выбора темы.
- Solution получил прозрачную область управления с теми же правилами камеры и
  закруглений, что у общей шапки. На Duo убрано дополнительное поле 5 pt у всего
  рабочего пространства, чтобы стрелка совпадала с предыдущими экранами.
  Противоположные кнопки учитывают закругления, а при камере справа располагаются
  под ней. При камере слева кнопки масштаба стоят под камерой; Back остаётся справа
  от неё. Верх схемы учитывает фактическую высоту области управления.
- В списке трюков правый блок шапки и общая строка кнопок тренировки используют
  AppDuoStackView: системные поля safe area больше не расширяют заданные поля
  повторно. Обе игровые кнопки сохраняют равную ширину и одинаковые внешние поля.
- На раскрытом внутреннем экране в портрете главное меню показывает сначала
  шапку/серию/дополнительные действия, затем игровые кнопки. Порядок альбомной
  раскладки сохранён.
- Настройки серии на внутреннем дисплее состоят из двух равных нативных панелей:
  уведомления/время/системные настройки и цель/сложность/трюки/игра/статус. Каждая
  прокручивается отдельно. UIArrangementViewController сам выбирает ось и
  анимирует поля сгиба через существующий AppDuoSplitView. На внешнем экране и
  других устройствах восстанавливается исходный единый список.

| Файл | Методы и назначение |
|---|---|
| `Math_Tricks/Design/AppDuoLayout.swift` | `AppDuoContentView.CameraBandStyle`, `updateConstraints()`, `AppDuoLayout.cameraBandFrame(in:style:)`: горизонтальная полоса сверху/снизу и общий резерв. `headerForegroundFrame(in:)`, `AppDuoAvoidingView.updateConstraints()`: общая безопасная геометрия шапок. |
| `Math_Tricks/Shell/AppRootViewController.swift` | `updateCameraBand(for:)`, `visibleScreenChanged(_:)`, `viewDidLayoutSubviews()`: выбор полосы по экрану и текущей ориентации. |
| `Math_Tricks/Design/AppComponents.swift` | `AppHeaderView.init(title:onBack:)`: центрирование Back. |
| `Math_Tricks/Theme/ThemePickerViewController.swift` | `viewDidLayoutSubviews()`: такая же геометрия и центрирование ручной шапки. |
| `Math_Tricks/Game/SolutionViewController.swift` | `buildContent()`, `updateDuoCameraControls()`: единая область Back/навигации, защита кнопок от закруглений, масштаб под левой камерой и отступ схемы. |
| `Math_Tricks/Catalog/TricksViewController.swift` | `buildContent()`, `buildHeader()`: устранение повторных системных полей у кнопок и правой части шапки. |
| `Math_Tricks/Main/MainMenuViewController.swift` | `rebuildLayout(landscape:)`: порядок двух панелей в раскрытом портрете. |
| `Math_Tricks/Daily/DailySettingsViewController.swift` | `buildContent()`, `viewDidLayoutSubviews()`: две панели и восстановление исходного списка. |
| `docs/IPHONE_DUO_LAYOUT.md` | Выжимка файлов, методов и новых правил. |

Проверка: Debug generic iOS без подписи, установки, запуска и тестов. Доступный
Xcode 26.6 / SDK 26.5 проверяет общий код; ветка API Duo требует SDK 27.1+ и
нуждается в визуальной проверке на соответствующем устройстве/симуляторе.
