# Полная версия iOS: настройка и проверка

Реализована разовая покупка полной версии через StoreKit 2 (iOS 15+).
После подтверждённой Apple покупки исчезают рекламный баннер и предложение PRO,
открываются все 107 трюков в каталоге, одиночной и совместной игре.
Уровни внутри трюка по-прежнему открываются прохождением. Монеты не списываются.

В главном меню «Купить полную версию» открывает окно с преимуществами,
актуальной ценой App Store и кнопкой «Восстановить покупки».
Покупка, ожидающая одобрения, не включает PRO до подтверждения.
Отмена оплаты ничего не меняет. После возврата/отзыва Apple доступ обновляется
через StoreKit. Открытые за монеты трюки и игровой прогресс сохраняются.

Доступ проверяется при запуске, возврате в приложение и изменении транзакций.
Покупка связана с Аккаунтом Apple для App Store, отдельно от Google-входа
и облачного профиля. После покупки нажатие «PRO» показывает статус полной версии, «ОК» и
«Восстановить покупки». Восстановление доступно независимо от текущего статуса PRO.
Покупка Android и отдельное старое платное приложение автоматически не дают
покупку в этом iOS-приложении.

## 1. Что создать на сайте Apple

Откройте [App Store Connect](https://appstoreconnect.apple.com/).

1. В **Business → Agreements** владелец аккаунта принимает **Paid Apps Agreement**,
   заполняет банковские и налоговые сведения. Договор должен быть **Active**, в том
   числе для Sandbox. [Требования Apple](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/).
2. В **Apps** выберите бесплатное приложение Math Tricks с Bundle ID
   **`com.antoni.mathtricks.free`**.
3. Откройте **Monetization → In-App Purchases → +**:

   | Поле | Значение |
   | --- | --- |
   | Type | **Non-Consumable** — разовая покупка без срока действия |
   | Reference Name | `Full Version` |
   | Product ID | **`remove_ads_v1`** — точно, с учётом регистра |

   Этот ID задан в `AppPurchases.fullVersionID`. Совпадение с Android удобно,
   но товары Google Play и App Store независимы. ID нужно создать именно в этом
   iOS-приложении; наличие товара в Google Play для Apple недостаточно.
4. Добавьте локализации названия и описания. Например: «Полная версия»,
   «Отключение рекламы и доступ ко всем математическим трюкам».
   Задайте цену и доступность в нужных странах, заполните обязательные поля.
5. В **Review Information** добавьте screenshot окна покупки и пояснение для
   ревьюера: «Main menu → Buy full version → Buy PRO. Unlocks all tricks and removes ads.
   Restore purchases is available in the same dialog».
6. Сохраните товар. В Sandbox изменения могут появиться в течение часа.
   [Создание товара у Apple](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/create-consumable-or-non-consumable-in-app-purchases/).

Никаких ключей оплаты в код вводить не нужно: приложение использует встроенную
проверку подписанных транзакций StoreKit. Свой сервер оплаты не добавлялся.
Capability **In-App Purchase** уже включена в Xcode-проекте. Для подписанной сборки
проверьте команду разработчика, Bundle ID и provisioning profile.

## 2. Быстрая локальная проверка в Xcode

Она работает без создания товара на сайте и без списания денег.

1. Откройте `Math_Tricks.xcodeproj`.
2. В проект добавлен файл `Math_TricksTests/FullVersion.storekit` с товаром
   `remove_ads_v1`. Цена `4.99` в нём — только пример для локальной проверки.
3. **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration**:
   выберите `FullVersion.storekit`.
4. Запустите приложение и нажмите «Купить полную версию», затем кнопку с ценой.
   Подтвердите локальную тестовую покупку.
5. Проверьте, что реклама и нижний блок PRO исчезли, в каталоге открыты все трюки,
   монеты остались прежними. Перезапустите приложение: PRO должен сохраниться.
6. Для возврата используйте **Debug → StoreKit → Manage Transactions** и действие
   Refund/Revoke у покупки. После обновления StoreKit PRO должен выключиться,
   а трюки, ранее открытые за монеты, должны остаться открытыми.
7. В этом же окне удалите тестовые транзакции для нового прогона. Проверьте отмену
   покупки и сценарий Ask to Buy: ожидание не должно открывать PRO, одобрение должно.

Добавлен `AppPurchasesTests.testFullVersionEntitlementAndRefund`: проверка отсутствия
покупки, выдачи PRO, восстановления в новом экземпляре менеджера и отзыва после
возврата. В рамках этой задачи тест не запускался; выполняется проверка компиляции.

## 3. Проверка с настоящими товарами App Store в Sandbox

1. Перед этой проверкой поставьте **StoreKit Configuration = None** в схеме Run,
   иначе приложение продолжит брать локальный товар вместо App Store.
2. В App Store Connect откройте **Users and Access → Sandbox → +** и создайте
   Sandbox Apple Account с адресом, который ещё не занят Аккаунтом Apple.
   [Создание тестового аккаунта](https://developer.apple.com/help/app-store-connect/test-in-app-purchases/create-a-sandbox-apple-account).
3. На iPhone включите **Developer Mode** и запустите development-сборку из Xcode.
   После первой попытки покупки откройте **Settings → Developer → Sandbox Apple Account**
   и войдите тестовым аккаунтом. Основной iCloud-аккаунт выходить не требуется.
4. Снова откройте покупку. Цена должна соответствовать товару App Store Connect.
   Убедитесь, что используется тестовая среда Sandbox; тестовые покупки бесплатны.
   Для такой проверки загружать бинарник на сайт заранее не требуется.
   Дополнительно можно проверить сборку из TestFlight, которая также использует Sandbox.
   [Инструкция Apple по Sandbox](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox).
5. После успешной покупки проверьте отсутствие рекламы, все трюки и повторный запуск
   без интернета. На другом устройстве с тем же тестовым Аккаунтом Apple нажмите
   «Восстановить покупки»: полная версия должна вернуться без повторной оплаты.
6. Перед удалением приложения сохраните игровой прогресс. Переустановка удаляет
   локальные данные; восстановление покупки возвращает PRO, а не игровой прогресс.
7. Для повторной покупки используйте **Users and Access → Sandbox → выберите тестера
   → Clear Purchase History** или соответствующий пункт на iPhone. Это очищает только
   тестовые покупки выбранного Sandbox-аккаунта.
   [Настройки Sandbox](https://developer.apple.com/help/app-store-connect/test-in-app-purchases/manage-sandbox-apple-account-settings).

## 4. Что проверить вручную

- Без покупки остаются реклама и блокировки платных трюков.
- Успешная покупка убирает баннер целиком, без пустого места снизу; все трюки доступны.
- Отмена, отсутствие интернета, недоступный товар и ожидающая одобрения покупка
  не выдают PRO и не списывают монеты.
- Восстановление возвращает покупку; отсутствие покупки даёт понятное сообщение.
- После возврата Apple PRO отключается; прогресс, монеты и открытия за монеты остаются.
- Смена Google-профиля, сброс прогресса и импорт файла не отнимают действующую покупку.
- Экспорт/облако не переносят PRO на другой Аккаунт Apple: покупка накладывается
  на доступ отдельно, исходные данные открытий за монеты в базе не меняются.

Если товар недоступен: проверьте Active-договор, Bundle ID, **`remove_ads_v1`**,
тип Non-Consumable, цену, страны доступности, интернет и Configuration = None.
Подождите до часа после изменений в App Store Connect. Восстановление доступно
даже если запрос цены товара не сработал.

## 5. Публикация

Первую покупку этого типа отправляйте на ревью вместе с новой версией приложения.
Заполните метаданные товара и версии, загрузите сборку, добавьте покупку и версию
в одну submission через **Add for Review**, затем **Submit for Review**.
[Порядок отправки у Apple](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase).

## Изменённые части

- `Services/AppPurchases.swift`: `start`, `refreshEntitlements`, `present`, `purchase`,
  `restore` — проверка Apple, цена, оплата, восстановление и статусы.
- `Data/AppDataStore.swift`: `catalogProgress`, `trainingCatalogProgress`, `trickProgress`,
  `unlockTrick` — доступ PRO поверх прогресса без записи платного доступа в архивы.
- `Main/MainMenuViewController.swift`: `showProPurchase`, `fitBuyLabel`, `render` —
  подключение покупки к кнопке и подпись PRO после оплаты.
- `Main/AppExternalLinks.swift`: удалена ссылка на отдельное legacy-приложение из покупки.
- `Services/AppAdvertising.swift`, `Shell/AppRootViewController.swift`,
  `Shell/BannerContainerView.swift`: запрет рекламы
  для PRO, удаление баннера, запуск и обновление StoreKit.
- `Game/GameModesViewController.swift`, `Multiplayer/MultiplayerSetupViewController.swift`:
  все трюки для полной версии в обычной игре.
- `Resources/*.lproj/Interface.strings`: окно и сообщения покупки переведены на все 26 языков приложения.
- `Math_Tricks.xcodeproj/project.pbxproj`: capability In-App Purchase.
- `Math_TricksTests/AppPurchasesTests.swift`, `FullVersion.storekit`: проверка и локальный товар.

Изменения только в текущем **ios/Math_Tricks**. **android/Math_Tricks** и
**ios-legacy** не изменялись. Настройка App Store Connect выполняется владельцем
аккаунта по этой инструкции; на сайт изменения не вносились.

## Компиляция

Debug, generic iOS, `CODE_SIGNING_ALLOWED=NO`: **BUILD SUCCEEDED**.
Приложение и тестовый сценарий: `build-for-testing` — **TEST BUILD SUCCEEDED**.
Тесты не запускались; установка, запуск и покупка на устройстве не выполнялись.
Логи: `/tmp/math_tricks_iap_build.log`, `/tmp/math_tricks_iap_final_build.log`.

Обновление окна активной PRO: `AppPurchases.present` оставляет восстановление
доступным и при активной покупке; кнопка закрытия активного статуса называется «ОК».
Изменения только в ios/Math_Tricks; Android и ios-legacy не изменялись.

Apple требует механизм восстановления для восстанавливаемых покупок
([App Review 3.1.1](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase)).
Отдельного требования постоянно показывать кнопку при активной покупке в проверенных
документах нет. В этом приложении её оставили доступной при любом статусе PRO.
Сейчас выдача доступа реализована для одного товара remove_ads_v1; при добавлении
других товаров потребуется обработать и их права, одного AppStore.sync недостаточно.

Окно покупки теперь имеет локализованный заголовок «Полная версия», кнопки
«Купить полную версию · цена», «Закрыть» и «Восстановить покупки».
Восстановление отображается внизу под разделителем, без основной заливки.
Полный список этой правки: [PURCHASE_DIALOG_LOCALIZATION.md](PURCHASE_DIALOG_LOCALIZATION.md).
