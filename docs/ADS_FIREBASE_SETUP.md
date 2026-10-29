# Реклама, согласие и Firebase в актуальном iOS

Изменён только `ios/Math_Tricks`. Android использован как источник поведения и переводов; из `ios-legacy` взяты только идентификаторы AdMob. Эти два проекта не изменены.

## Что работает в коде

- Google Mobile Ads 13.11.0, UMP 3.1.0 и Firebase Analytics 13.0.1 подключены через Swift Package Manager; разрешённые версии сохранены в `Package.resolved`.
- Firebase Crashlytics подключён из того же пакета Firebase: сбор сбоев включается при запуске, символы dSYM загружаются последней Build Phase. Настройка сайта и проверка отчёта: [CRASHLYTICS_SETUP.md](CRASHLYTICS_SETUP.md).
- Возрастной выбор запоминается один раз: после сохранения возраста, диапазона Apple, пропуска или неизвестного возраста при ошибке повторных проверок Apple нет. Если выбора ещё нет, используется наша форма с крестиком; на iOS 26.4+ вместо неё вызывается Apple при `declaredAgeRangeRequired`, на iOS 26.2–26.3 — при `isEligibleForAgeFeatures`. При технической ошибке первой проверки приложение продолжает работу без нашей формы, сохраняя неизвестный возраст с детской рекламой CHILD/G и запрещёнными рекламными согласиями Firebase. Отказ поделиться обязательным диапазоном требует повтора. Подробности: [AGE_ASSURANCE.md](AGE_ASSURANCE.md). После возрастного шага и выбора темы UMP обновляет согласие и показывает опубликованные сообщения. На iOS GDPR и системное разрешение ATT — разные этапы; их последовательность ведёт UMP. Game Center запускается после завершения этого процесса.
- До 13 лет: детский режим и рейтинг G. В 13–15 лет: подростковый режим и рейтинг T. В 16–20 лет: рейтинг T. С 21 года: рейтинг MA. Для UMP пользователь младше 16 лет помечен как не достигший возраста согласия. Неизвестный возраст обрабатывается как самая младшая группа; сам возраст в Firebase не отправляется.
- Один нижний баннер переживает переходы между экранами. В iOS используется Large Anchored Adaptive: Google рассчитывает высоту 50–150 pt (не более 20% высоты экрана) по доступной ширине и ориентации; контейнер принимает эту высоту. На первичной настройке и выборе темы баннер скрыт. Загрузка начинается только после инициализации SDK и разрешения `canRequestAds` от UMP.
- Если реклама недоступна или ещё загружается, видна кнопка PRO. Она использует уже существующий переход к полной версии в App Store.
- В Debug используется тестовый баннер Google. В Release — баннер главного экрана из legacy: `ca-app-pub-4469463872184379/9708489246`. App ID: `ca-app-pub-4469463872184379~4359959646`.
- Пункт «Настройки конфиденциальности» появляется в настройках, когда UMP требует такую возможность. При повторном открытии формы старый баннер убирается и после закрытия загружается с актуальными решениями.
- Как в Android, базовая Firebase Analytics включается при запуске; рекламные согласия изначально запрещены. Они обновляются с учётом возраста, ATT, целей TCF и согласия для Google Advertising Products. Разрешение показа ограниченной рекламы само по себе не считается разрешением персонализации.
- События `app_version_launch` и `app_version_first_launch` имеют параметры `app_version` и `version_code`. Первое отправляется при холодном запуске, второе — один раз для установленной версии/сборки, независимо от сброса игрового прогресса.
- Без корректного `GoogleService-Info.plist` Firebase не запускается; приложение продолжает работать. Конфигурация Firebase из legacy не переносилась.

## 1. Проверить приложение в AdMob

1. Открой [AdMob](https://apps.admob.com/) → **Приложения / Apps** → существующее **Math Tricks для iOS**.
2. В **Настройки приложения / App settings** проверь App ID: `ca-app-pub-4469463872184379~4359959646`.
3. В **Рекламные блоки / Ad units** проверь, что `ca-app-pub-4469463872184379/9708489246` — действующий блок формата **Баннер / Banner**. Создавать новый блок вместо действующего не требуется.
4. Если приложение ещё не связано с магазином, выбери его по ссылке [Math Tricks в App Store](https://apps.apple.com/app/id1209287132).

## 2. Опубликовать окно согласия GDPR

1. В левом меню AdMob открой **Конфиденциальность и сообщения / Privacy & messaging**.
2. Открой **Европейские нормативные акты / European regulations** → **Создать сообщение / Create message**.
3. Выбери именно iOS-приложение Math Tricks с App ID из предыдущего шага.
4. Укажи ссылку на политику конфиденциальности, которая уже используется в приложении: `https://antonisoftgroup.github.io/privacy.html`. Она должна описывать актуальное использование AdMob и Firebase.
5. Выбери языки сообщения, настрой оформление и доступные кнопки выбора.
6. Нажми **Опубликовать / Publish**. Сохранённый черновик в приложение не придёт. Форма появится у подходящих пользователей, когда этого потребует UMP.

[Официальная инструкция Google](https://support.google.com/admob/answer/10113207?hl=ru).

## 3. Настроить iOS ATT

1. В том же разделе **Privacy & messaging** открой **IDFA / Сообщения IDFA**.
2. Создай сообщение для того же iOS-приложения, укажи языки и объяснение использования рекламного идентификатора.
3. Опубликуй сообщение. Код и `NSUserTrackingUsageDescription` уже подготовлены; UMP управляет переходом к системному окну ATT.
4. ATT показывается по правилам iOS, если решение ещё не принято. При отказе приложение работает, реклама может запрашиваться без IDFA при разрешении UMP. Отказ от ATT не равен отключению базовой аналитики.

Для пользователя младше 16 лет не ожидай обычную цепочку рекламного согласия взрослого. Для проверки взрослого сценария используй возраст 16+ и подходящий регион. Не удаляй установленное приложение с ценным прогрессом ради повторного показа ATT: используй отдельный симулятор или тестовое устройство.

[Документация Google по IDFA и ATT](https://developers.google.com/admob/ios/privacy/idfa).

## 4. Добавить iOS в Firebase

1. Открой [существующий проект Firebase Android](https://console.firebase.google.com/project/api-project-162088319865/overview). Можно использовать другой свой проект, если данные нужно хранить отдельно.
2. Нажми шестерёнку → **Настройки проекта / Project settings** → **Общие / General** → **Ваши приложения / Your apps** → **Добавить приложение / Add app** → значок **iOS**.
3. В поле **Apple bundle ID** введи точно `com.antoni.mathtricks.free`. Название: `Math Tricks iOS`. App Store ID, если заполняешь: `1209287132`.
4. Если iOS-приложение с этим Bundle ID уже зарегистрировано, открой его существующую карточку вместо повторной регистрации.
5. Скачай свежий **GoogleService-Info.plist**. Сохрани исходное имя, без `(1)` и других суффиксов.
6. Положи его в `ios/Math_Tricks/Math_Tricks/GoogleService-Info.plist`. Это папка приложения, где находятся `Math_TricksApp.swift` и `ContentView.swift`. Xcode синхронизирует её автоматически; убедись, что файл включён в ресурсы target `Math_Tricks`.
7. В **Project settings → Integrations → Google Analytics** включи Analytics, если она ещё не подключена. Повторно устанавливать SDK и добавлять `FirebaseApp.configure()` не нужно — это сделано в коде.
8. Пересобери и запусти приложение после добавления файла.

[Инструкция Firebase по регистрации Apple-приложения](https://firebase.google.com/docs/ios/setup).

## 5. Связать AdMob и Firebase

1. В AdMob открой iOS-приложение → **App settings** → **Firebase** → **Link to Firebase**.
2. Выбери проект, в который добавлен iOS, и приложение `com.antoni.mathtricks.free`.
3. Подтверди связь. Для просмотра обычных событий Analytics этот шаг не заменяет конфигурационный plist из предыдущего раздела.

[Официальная инструкция по связыванию](https://support.google.com/admob/answer/6383165?hl=ru).

## 6. Посмотреть события

1. В Xcode открой **Product → Scheme → Edit Scheme → Run → Arguments**.
2. В **Arguments Passed On Launch** добавь `-FIRDebugEnabled` для своей локальной проверки.
3. Запусти приложение и открой **Firebase → Analytics → DebugView**. Ожидай стандартные события SDK и `app_version_launch`; `app_version_first_launch` будет только при первом запуске этой версии/сборки после подключения Firebase.
4. Для обычного режима убери аргумент и используй `-FIRDebugDisabled`, если нужно сбросить сохранённый SDK режим отладки. Обычные отчёты обновляются не сразу.

[Инструкция по DebugView](https://firebase.google.com/docs/analytics/debugview).

## Какие файлы и методы изменены

| Файл | Методы / назначение |
| --- | --- |
| `Math_Tricks/Services/AppAdvertising.swift` | `start`, `finish`, `configureAge`, `becameActive`, `presentPrivacyOptions`: UMP, возрастные ограничения, запуск AdMob, повторное согласие. |
| `Math_Tricks/Services/AppAnalytics.swift` | `configure`, `updateAdvertisingConsent`, `hasConsent`, `recordVersionLaunch`: Firebase, рекламные согласия, события версий, проверки чтения битов TCF в Debug. |
| `Math_Tricks/Shell/BannerContainerView.swift` | `update`, `apply`, методы `BannerViewDelegate`: общий баннер и PRO при недоступной рекламе. |
| `Math_Tricks/Shell/AppRootViewController.swift` | `startServices`, `updateBanner`, обработчики жизненного цикла: подключение рекламы к оболочке и согласование с Game Center. |
| `Math_Tricks/Settings/SettingsViewController.swift` | `buildContent`, `updateAdPrivacy`: вход в форму конфиденциальности. |
| `Math_Tricks/Math_TricksApp.swift` | `init`: начальная настройка Analytics. |
| `AppInfo.plist`, `Math_Tricks/PrivacyInfo.xcprivacy` | App ID, ATT, начальные рекламные согласия, SKAdNetwork, декларация использования tracking при разрешении пользователя. |
| `Math_Tricks/Resources/*/Main.strings` | 26 языков: подпись PRO, пункт конфиденциальности и сообщение об ошибке. |
| `Math_Tricks/Resources/{en,ru}.lproj/InfoPlist.strings` | Пояснение ATT на английском и русском. |
| `Math_Tricks.xcodeproj/project.pbxproj`, `Math_Tricks.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` | Зависимости SDK и `-ObjC`. |
| `docs/ADS_FIREBASE_SETUP.md` | Эта инструкция. |

Перед публикацией обнови **App Privacy** в App Store Connect с учётом подключённых SDK. SDK включают собственные privacy manifests; описание приложения в магазине задаётся отдельно. Справки: [AdMob](https://developers.google.com/admob/ios/data-disclosure), [Firebase](https://firebase.google.com/docs/ios/app-store-data-collection).

Автотесты и установка на устройство не выполнялись. Поведение окон, реальные показы и поступление событий нужно проверить после настройки кабинетов и добавления нового plist.
