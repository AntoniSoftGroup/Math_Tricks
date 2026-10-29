import Foundation

nonisolated enum ProgressError: LocalizedError, Equatable {
    case database(String)
    case unsupportedVersion(Int64)
    case invalidState
    case differentLegacyStore
    case notLoaded
    case invalidValue
    case insufficientCoins
    case operationConflict
    case alreadyUnlocked
    case overflow
    case invalidArchive
    case staleSession

    var errorDescription: String? {
        switch self {
        case .database(let message): return "Progress database: \(message)"
        case .unsupportedVersion(let version): return "Unsupported progress schema: \(version)."
        case .invalidState: return "Saved progress is incomplete."
        case .differentLegacyStore: return "The original progress store has changed."
        case .notLoaded: return "Progress has not been loaded."
        case .invalidValue: return "Invalid progress value."
        case .insufficientCoins: return "Not enough coins."
        case .operationConflict: return "An operation ID was reused for different data."
        case .alreadyUnlocked: return "The trick is already unlocked."
        case .invalidArchive: return "Unsupported or invalid progress archive."
        case .staleSession: return "Progress changed; start a new game."
        case .overflow: return "Progress counter overflow."
        }
    }
}

nonisolated enum GameMode: String, Codable, Sendable {
    case single, minute, speed, noTime, daily, training, byHeart
}

nonisolated enum AppTheme: Int, Codable, Sendable {
    case light = 1, dark, lightAurora, darkAurora, aurora, neon
}

nonisolated struct OnboardingState: Codable, Sendable, Equatable {
    enum Phase: String, Codable, Sendable { case age, appearance, complete }
    var phase: Phase
    var age: Int?
    var declaredAgeRange: DeclaredAgeBounds?
    var ageChoiceMade: Bool?

    var minimumKnownAge: Int? {
        guard let range = declaredAgeRange else { return age }
        return min(range.lowerBound ?? 0, age ?? Int.max)
    }
    var hasAgeChoice: Bool { age != nil || declaredAgeRange != nil || ageChoiceMade == true }
}

nonisolated struct DeclaredAgeBounds: Codable, Sendable, Equatable {
    let lowerBound: Int?
    let upperBound: Int?

    var isValid: Bool {
        (lowerBound != nil || upperBound != nil)
            && (lowerBound.map { (0...150).contains($0) } ?? true)
            && (upperBound.map { (0...150).contains($0) } ?? true)
            && (lowerBound ?? 0) <= (upperBound ?? Int.max)
    }
}

nonisolated struct AppSettings: Codable, Sendable, Equatable {
    var dailyReminder: DailyReminderSettings?
    var speechMode: Int?
    var keypadOnRight: Bool?
    var graphSmoothed: Bool?
    var gameCategoryColors: Bool?
    var tricksCategoryColors: Bool?
    var gameInputMode: GameInputMode?
    var trainingExampleCount: Int?
    var onboarding: OnboardingState?
    var soundEnabled = true
    var vibrationEnabled = true
    var signalWrongAnswer = false
    var numpad123 = true
    var theme: AppTheme?
    var accentColorHex: String?
    var themeBaseColorHex: String?
    var themeIntensity = 100
    var themeIntensities: [String: Int] = [:]
    var useSystemFontSize = true
    var fontSizePercent = 100
}

nonisolated enum SettingsChange: Sendable {
    case speechMode(Int)
    case keypadOnRight(Bool)
    case graphSmoothed(Bool)
    case tricksCategoryColors(Bool)
    case gameInputMode(GameInputMode)
    case trainingExampleCount(Int)
    case age(Int?)
    case declaredAgeRange(DeclaredAgeBounds)
    case sound(Bool)
    case vibration(Bool)
    case wrongAnswerSignal(Bool)
    case numpad123(Bool)
    case appearance(theme: AppTheme, colorHex: String?, intensity: Int, baseColorHex: String? = nil, intensities: [String: Int]? = nil, categoryColors: Bool? = nil, gameCategoryColors: Bool? = nil, fontPercent: Int? = nil, systemFont: Bool? = nil)
    case fontSize(useSystem: Bool, percent: Int)
}

nonisolated struct DailyProgress: Codable, Sendable, Equatable {
    var target = 5
    var solved: Int64 = 0
    var streak: Int64 = 0
    var dayKey: String?
    var insuranceProgress: Int?
    var readyInsurance: Int?
    var notificationsEnabled: Bool?
    var seriesStartDay: Int?
    var completedToday: Bool?
    var pendingStreak: Int64?
    var pendingCost: Int?
    var pendingDay: String?
    var endedDay: String?
    var shieldUsedDay: String?
}

nonisolated struct DailyHistoryPoint: Codable, Sendable, Equatable {
    let dayKey: String
    let solved: Int64
    let target: Int
    let streak: Int64
    var seriesStartDay: Int?
}

nonisolated struct GameRecord: Codable, Sendable, Equatable {
    enum Unit: String, Codable, Sendable { case points, seconds }
    let mode: GameMode
    let selectedTricks: Bool
    let value: Double
    let unit: Unit
}

nonisolated struct ProgressState: Codable, Sendable {
    var generation: String?
    var statisticsBaseline: [String:Int]?
    var statisticsResetAt: Int64?
    var revision: Int64 = 0
    var coins: Int64
    var totalSolved: Int64
    var selectedCurrentLevel:Int64?
    var currentLevel: Int64
    var maximumLevel: Int64
    var multiplayerLength: Int64
    var playerOneWins: Int64
    var playerTwoWins: Int64
    var settings: AppSettings
    var daily = DailyProgress()
    var dailyHistory: [DailyHistoryPoint]?
    var jointRecord: Int64?
    var records: [GameRecord]

    init(legacy: LegacyPreferences) {
        coins = legacy.coins
        totalSolved = legacy.totalSolved
        currentLevel = legacy.currentLevel
        maximumLevel = legacy.maximumLevel
        multiplayerLength = legacy.multiplayerLength
        playerOneWins = legacy.playerOneWins
        playerTwoWins = legacy.playerTwoWins
        settings = AppSettings()
        settings.soundEnabled = legacy.soundEnabled
        settings.vibrationEnabled = legacy.vibrationEnabled
        settings.numpad123 = legacy.numpad123
        settings.accentColorHex = legacy.themeColor
        records = legacy.records.compactMap { record in
            guard let value = record.value else { return nil }
            let mode: GameMode
            switch record.mode {
            case .single: mode = .single
            case .minute: mode = .minute
            case .speed: mode = .speed
            case .noTime: mode = .noTime
            case .training, .byHeart: return nil
            }
            return GameRecord(mode: mode, selectedTricks: record.selectedTricks, value: value,
                              unit: record.unit == .seconds ? .seconds : .points)
        }
    }
}

nonisolated struct LevelKey: Hashable, Codable, Sendable {
    enum Scope: String, Codable, Sendable { case trick, multiplication }
    let scope: Scope
    let parentID: Int
    let level: Int

    func validate() throws {
        guard parentID > 0, (1...(scope == .trick ? 100 : 21)).contains(level),
              scope != .multiplication || parentID <= 100 else { throw ProgressError.invalidValue }
    }
}

nonisolated struct LevelProgress: Codable, Sendable, Equatable {
    let key: LevelKey
    var bestScore: Int64
    var bestStars: Int64
    var unlocked: Bool
    var measurements:LevelMeasurements?=nil
}

nonisolated struct TrickProgress: Codable, Sendable, Equatable {
    let id: Int
    var selected: Bool
    var unlocked: Bool
}

/// A caller keeps the ID when retrying one logical reward, purchase or result.
nonisolated struct ProgressOperation: Codable, Sendable {
    let id: String
    var coinDelta: Int64 = 0
    var solvedDelta: Int64 = 0
    var unlockTrickID: Int?
    var level: LevelProgress?
    var record: GameRecord?
    var playerWinner: Int?
    var unlockDifficulty: Int64?
    var nextLevel: LevelProgress?
    var multiplayerSession: MultiplayerSession?
    var jointScore: Int64?
    var gameSession: GameSession?
}

nonisolated struct HistoricalGraphPoint: Codable, Sendable {
    let sourceID: String
    let mode: GameMode?
    let originalModeID: Int64?
    let dateText: String?
    let originalScore: Int64?
    let value: Double?
    let unit: GameRecord.Unit
    var seriesStartDay: Int?
    var seriesCount: Int64?
    var dailyTarget: Int?
}
