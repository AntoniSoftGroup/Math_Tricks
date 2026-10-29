/// Настройки для ручной проверки. После изменения пересоберите приложение.
/// Действуют в Debug и Release. Перед публикацией поставьте все значения false.
nonisolated enum AppConstants {

    /// Дата выпуска, отображаемая рядом с версией в настройках (yyyy.MM.dd).
    static let releaseDate = "27.10.2026"

    static let useTestAds = false
    static let simulatePro = false
    static let unlockAllLevels = false
    /// true — не отправлять символы в Firebase; false — отправка включена.
    static let crashlyticsTestMode = false
    
}
