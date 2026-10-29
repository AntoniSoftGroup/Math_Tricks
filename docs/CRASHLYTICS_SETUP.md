# Firebase Crashlytics в iOS

Изменён только актуальный проект `ios/Math_Tricks`. Android и `ios-legacy` не изменены.

## Что подключено

- Продукт `FirebaseCrashlytics` из уже подключённого пакета Firebase, без обновления версии SDK.
- В `AppAnalytics.configure()` после существующего `FirebaseApp.configure(options:)` включён автоматический сбор сбоев. Используется тот же `GoogleService-Info.plist`, что и для Analytics; второй проект Firebase или повторная инициализация не нужны.
- Debug и Release создают dSYM. Последняя Build Phase **Upload Crashlytics Symbols** запускает официальный скрипт Firebase для обработки и загрузки символов.
- Входные файлы скрипта включают dSYM, его Info.plist, исполняемый файл и конфигурацию Firebase. В Debug дополнительно учитывается `Math_Tricks.debug.dylib`; sandbox скриптов Xcode остаётся включённым.
- Возраст, IDFA и собственный идентификатор пользователя в Crashlytics приложением не передаются. Обработка сбоев SDK автоматическая; ручная отправка всех перехваченных ошибок не добавлена.

## Что открыть на сайте

1. Открой [Crashlytics проекта Firebase](https://console.firebase.google.com/project/api-project-162088319865/crashlytics).
2. Выбери iOS-приложение с Bundle ID **com.antoni.mathtricks.free**. Если предлагается начать настройку, нажми **Get started / Начать**.
3. Шаг подключения SDK уже выполнен в Xcode. Новый `GoogleService-Info.plist` скачивать не требуется, если выбран тот же проект и приложение.
4. После первого сбоя и следующего запуска приложения отчёт должен появиться здесь. Для сквозной проверки Firebase рекомендует искусственный тестовый сбой на отдельной тестовой установке.
5. Если появится **Missing dSYM**, проверь Build Phase **Upload Crashlytics Symbols**. Символы от конкретной сборки находятся в `.app.dSYM` рядом с собранным приложением, а у архива — в каталоге `dSYMs` внутри `.xcarchive`. Их можно загрузить вручную через Firebase.

Пользователь подтвердил работу тестового крэша. Тестовый обработчик удалён: «Оценить» снова открывает App Store в Debug и Release.

При настоящем падении Crashlytics сохраняет отчёт локально. Отправка выполняется при следующем запуске приложения, когда SDK инициализируется и есть доступ к сети. Если пользователь больше не запускает приложение, сохранённый отчёт не отправится. Появление отчёта в Firebase Console также требует времени на обработку.

Debug и Release успешно скомпилированы с подписью и Build Phase Crashlytics. Создание dSYM и совпадение UUID с бинарниками проверены; версия Firebase сохранена 13.0.1. Установка, запуск на устройстве и автотесты не выполнялись.

## Файлы и методы

| Файл | Изменение |
| --- | --- |
| `Math_Tricks.xcodeproj/project.pbxproj` | Продукт `FirebaseCrashlytics`, последняя Build Phase загрузки dSYM, Debug dSYM и отдельное имя debug dylib в списке входных файлов. Существующий `-ObjC` сохранён. |
| `Math_Tricks/Services/AppAnalytics.swift` | `configure`: включает Crashlytics после единственной инициализации Firebase. При отсутствии корректной конфигурации оба сервиса не запускаются. |
| `Math_Tricks/Main/AppExternalLinks.swift` | `rate`: тестовый крэш удалён, восстановлена обычная ссылка на App Store. |
| `docs/ADS_FIREBASE_SETUP.md` | Ссылка на настройку Crashlytics. |

Источники: [подключение Crashlytics для Apple](https://firebase.google.com/docs/crashlytics/ios/get-started), [автоматическая загрузка dSYM](https://firebase.google.com/docs/crashlytics/ios/get-deobfuscated-reports), [автоматический сбор отчётов](https://firebase.google.com/docs/crashlytics/ios/customize-crash-reports#enable-opt-in-reporting).
