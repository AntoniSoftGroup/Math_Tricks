# Интерфейс iPhone Duo

Изменён только современный проект `ios/Math_Tricks`. Android и `ios-legacy`
не изменялись. Существовавшие до этой задачи правки сохранены.

## Поведение

Адаптация включается только при наличии системного шарнира в иерархии iPhone.
Обычные iPhone и iPad сохраняют прежние ограничения safe area и раскладку.
Размеры модели устройства и положение камеры не зашиты в код.

На Duo основное содержимое использует боковую область экрана, которую ранее
целиком исключала safe area камеры и статус-бара. Освобождается только сторона,
на которой действительно есть перекрытие. Верхняя и нижняя safe area, включая
отступ домашнего индикатора, сохраняются.

Шапки, строки настроек, содержимое ячеек, элементы выбора темы и баннер обходят
камеру и статус-бар локально. Каждый компонент проверяет пересечение в собственных
координатах. Фон и остальные части экрана не сужаются вместе с ним. Отступы
Reserved Regions уже включены Apple в frame и повторно не добавляются.

На Duo прокрутка не добавляет системную боковую safe area второй раз. Исходные
настройки прокрутки восстанавливаются, если представление покидает иерархию Duo.
На внутреннем экране Duo игровыми областями управляет системный
`UIArrangementViewController` с `UISplitArrangement`. Контейнер остаётся
подключённым и на плоском внутреннем экране, поэтому UIKit обрабатывает переходы
при сгибании и раскрытии. Поддерживаются обе оси разделения. При горизонтальном
сгибе, включая портретное положение «как ноутбук», пример и служебные элементы
находятся в верхней области, клавиатура — в нижней. При вертикальном сгибе
используются боковые области и выбранная сторона клавиатуры.

Ручной расчёт ширины промежутка и дополнительные поля по 8 pt удалены.
Отступы вокруг сгиба задаёт системный контейнер Apple. Из Reserved Regions
берётся только доступность внутреннего разделения и направление активного сгиба,
а не координаты для ручного перемещения игровых панелей.

Для явных обновлений контейнера используется `updateArrangement(_:animated:)`;
при включённом Reduce Motion анимация явно запрошенного обновления отключена.
Собственный таймер, угол-зависимая интерполяция и фиксированная длительность
анимации не добавлены. Состояние сессии и существующие игровые представления
сохраняются при смене контейнера и раскладки.

На внешнем экране Duo, в окне без линии разделения и на обычных iPhone/iPad
остаётся прежняя раскладка. Системный контейнер туда не устанавливается, чтобы
его правила сворачивания не скрыли клавиатуру на компактном экране.

## Файлы и методы

| Файл | Изменение |
|---|---|
| `Math_Tricks/Design/AppDuoLayout.swift` | Новый `AppDuoContentView`: определение доступности Duo через `UIHingeInteraction`, обновление `contentGuide` в `updateConstraints()`. `AppDuoLayout.occlusionFrames(in:)` и `unobscuredFrame(in:within:)`: локальные области камеры и статус-бара. `AppDuoAvoidingView.updateConstraints()`: перемещение только содержимого компонента. |
| `Math_Tricks/Design/AppDuoLayout.swift` (сгиб) | `divisionFrames(in:)`: активная системная область сгиба без дополнительных полей. `AppDuoContentView.updateConstraints()`: отслеживание изменения системной области и вызов `onDivisionChange`. |
| `Math_Tricks/Game/GameViewController.swift` (сгиб) | `synchronizeDuoArrangement()`, `pinGameContent(_:in:)`, `viewDidLayoutSubviews()`, `rebuildLayout(landscape:)`: подключение и удаление системного дочернего контейнера, размещение существующих элементов в его областях без сброса игры. Ручные ширины и промежутки вокруг сгиба удалены. |
| `Math_Tricks/Game/AppDuoGameArrangement.swift` | `canUse(in:)`, `make()`: выбор системного контейнера только для внутреннего разделения Duo. `NativeDuoGameArrangement.viewDidLoad()`, `update(animated:)`, `viewDidLayoutSubviews()`: настройка split на обеих осях, системные переходы и отслеживание оси компоновки. Новые типы скрыты за флагом SDK и проверкой iOS 27.1. |
| `Math_Tricks/Shell/AppRootViewController.swift` | `loadView()`, `viewDidLoad()`: общий контейнер экрана и баннер используют область содержимого Duo. |
| `Math_Tricks/Design/ThemedViewController.swift` | `loadView()`, `viewDidLoad()`, `setHeaderHidden(_:)`: подключение общей области к тематическим экранам. |
| `Math_Tricks/Shell/ShellScreenViewController.swift` | `loadView()`, `viewDidLoad()`: та же область в экранах оболочки. |
| `Math_Tricks/Design/AppComponents.swift` | `AppHeaderView.init(title:onBack:)`: фон шапки занимает всю ширину, строка и кнопка возврата обходят перекрытия. |
| `Math_Tricks/Main/MainMenuViewController.swift` | `loadView()`, `viewDidLoad()`, `pin(_:in:insets:)`: основная область расширяется, шапка и ежедневная панель обходят камеру независимо. `viewDidLayoutSubviews()`: на Duo пересчёт при любом изменении размера области, включая раскрытие и Split View без смены пропорций окна. |
| `Math_Tricks/Onboarding/AgeScreenViewController.swift` | `loadView()`, `viewDidLoad()`: область Duo и локальный обход камеры шапкой ввода возраста. |
| `Math_Tricks/Theme/ThemePickerViewController.swift` | `loadView()`, `viewDidLayoutSubviews()`: полная область карусели, отдельный обход камеры шапкой, настройкой шрифта и панелью цветов. |
| `Math_Tricks/Shell/BannerContainerView.swift` | `update(presenter:visible:canRequestAds:)`, `setContent(_:height:)`: размер рекламы по доступной локальной ширине; на Duo формат выбирается по размерам окна. |
| `Math_Tricks/Design/AppScrollView.swift` | `AppScrolling.update(_:allowed:clampOffset:)`: предотвращает повторный боковой системный отступ только на Duo. |
| `Math_Tricks/Design/AppListCell.swift` | `layoutSubviews()`, `restoreDuoContentFrame()`, `prepareForReuse()`: обход камеры отдельной ячейкой с восстановлением её исходного размера. |
| `Math_Tricks/Settings/SettingsViewController.swift` | `makeRow(_:icon:toggle:)`: независимая область содержимого для переключателей и подписей каждой строки. |
| `Math_Tricks.xcodeproj/project.pbxproj` | В Debug и Release добавлен SDK-зависимый флаг `MATH_TRICKS_DUO_SDK`. |

## Сборка

- Xcode 26.6: новые объявления исключаются через `#if MATH_TRICKS_DUO_SDK`.
  Для SDK 26.x флаг пустой; доступность API не проверяется только через
  `#available`, поскольку этого недостаточно для компиляции со старым SDK.
- Xcode 27.0: флаг также отключён — Reserved Regions появились в SDK 27.1.
- Xcode 27.1 и новее: флаг включается автоматически; обращения к API дополнительно
  защищены `if #available(iOS 27.1, *)`. Deployment target iOS 15 не менялся.

Полноэкранная адаптация Duo требует сборки SDK 27.1 или новее. Сборка старым SDK
подчиняется системному режиму совместимости, его границы нельзя отменить кодом
внутри приложения.

Проверка: Debug для generic iOS в установленном Xcode 26.6; SDK в этой установке —
iPhoneOS 26.5. Тесты, установка и запуск не выполнялись. Xcode 27.1 и симулятор Duo
здесь отсутствуют, поэтому сборка новой ветки с этим SDK и визуальная проверка
камеры, поворотов, раскрытия, Dynamic Island и Split View остаются непроверенными.

## Рекомендации Apple

- [Prepare your app for iPhone Duo](https://developer.apple.com/iphone-duo/prepare/): размеры текущего окна, динамическое изменение размеров и требования SDK.
- [UIArrangementViewController](https://developer.apple.com/documentation/uikit/uiarrangementviewcontroller): системная split-компоновка и `updateArrangement(_:animated:)`.
- [UIView.ReservedRegion](https://developer.apple.com/documentation/uikit/uiview/reservedregion): локальные координаты, включённые в frame поля и отслеживание изменений в `updateConstraints()`.
- [Strike a pose with adaptive layouts on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463/): смещение отдельных элементов вокруг занятых областей.
- [UIHingeInteraction](https://developer.apple.com/documentation/uikit/uihingeinteraction): `nil` для иерархии без шарнира.
