import Foundation

/// Reads the original key names. Missing values have in-memory defaults only.
nonisolated struct LegacyPreferences: Sendable {
    struct Record: Sendable {
        enum Unit: Sendable, Equatable { case points, seconds }
        let mode: LegacyGameMode
        let selectedTricks: Bool
        let value: Double?
        let unit: Unit
    }

    static let initializationKey = "COREDATA_VERSION_OLD"
    let storedKeys: Set<String>
    let initializationVersion: Int64?
    let coins: Int64
    let totalSolved: Int64
    let currentLevel: Int64
    let maximumLevel: Int64
    let soundEnabled: Bool
    let vibrationEnabled: Bool
    let numpad123: Bool
    let themeColor: String?
    let multiplayerLength: Int64
    let playerOneWins: Int64
    let playerTwoWins: Int64
    let records: [Record]

    init(domain: [String: Any]) throws {
        func number(_ key: String) throws -> NSNumber? {
            guard let value = domain[key] else { return nil }
            guard let number = value as? NSNumber, number.doubleValue.isFinite else {
                throw LegacyProgressError.invalidPreference(key)
            }
            return number
        }
        func integer(_ key: String, fallback: Int64) throws -> Int64 {
            guard let value = try number(key) else { return fallback }
            // Never narrow the old Int/Int16 values back to Int16.
            guard !["f", "d"].contains(String(cString: value.objCType)) else {
                throw LegacyProgressError.invalidPreference(key)
            }
            return value.int64Value
        }

        storedKeys = Set(domain.keys)
        initializationVersion = try number(Self.initializationKey)?.int64Value
        coins = try integer("DEFAULTS_MONEY_TOTAL", fallback: 0)
        totalSolved = try integer("DEFAULTS_EXAMPLES_SOLVED_TOTAL", fallback: 0)
        currentLevel = try integer("DEFAULTS_GAME_TYPE_CURRENT_LEVEL", fallback: 1)
        maximumLevel = try integer("DEFAULTS_GAME_TYPE_MAX_LEVEL", fallback: 5)
        soundEnabled = try number("DEFAULTS_SETTINGS_SOUND")?.boolValue ?? true
        vibrationEnabled = try number("DEFAULTS_SETTINGS_VIBRATION")?.boolValue ?? true
        numpad123 = try number("DEFAULTS_NUMPAD_123")?.boolValue ?? true
        multiplayerLength = try integer("DEFAULTS_TWO_PLAYERS_PROGRESS", fallback: 10)
        playerOneWins = try integer("DEFAULTS_PLAYER_1_WINS", fallback: 0)
        playerTwoWins = try integer("DEFAULTS_PLAYER_2_WINS", fallback: 0)
        if let savedColor = domain["DEFAULTS_THEME_COLOR"] {
            guard let color = savedColor as? String else {
                throw LegacyProgressError.invalidPreference("DEFAULTS_THEME_COLOR")
            }
            themeColor = color
        } else {
            themeColor = nil
        }

        var savedRecords: [Record] = []
        for selected in [false, true] {
            for (mode, suffix) in [(LegacyGameMode.single, "SINGLE"), (.minute, "MINUTE"),
                                   (.speed, "SPEED"), (.noTime, "NON_TIME")] {
                let key = "DEFAULTS_MAX_SCORE_GAME_" + (selected ? "CHECKED_" : "") + suffix
                let savedValue = try number(key)?.doubleValue
                let value: Double?
                if mode == .speed {
                    // Legacy stores seconds as Float; Int.max means no record yet.
                    value = savedValue.flatMap { $0 > 0 && $0 < Double(Int.max) ? $0 : nil }
                } else {
                    value = savedValue
                }
                savedRecords.append(Record(mode: mode, selectedTricks: selected, value: value,
                                           unit: mode == .speed ? .seconds : .points))
            }
        }
        records = savedRecords
    }
}
