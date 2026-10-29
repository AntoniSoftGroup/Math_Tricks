import Foundation

nonisolated enum LegacyProgressError: LocalizedError {
    case modelUnavailable
    case unsupportedStore
    case incompleteStore
    case missingStore
    case invalidMapping
    case invalidPreference(String)
    case incompleteBackup

    var errorDescription: String? {
        switch self {
        case .modelUnavailable: return "The original Core Data models are unavailable."
        case .unsupportedStore: return "The saved store does not match a supported legacy model."
        case .incompleteStore: return "SQLite sidecars exist without the original store."
        case .missingStore: return "Legacy initialization is recorded, but its store is missing."
        case .invalidMapping: return "The legacy trick mapping is invalid."
        case .invalidPreference(let key): return "Invalid saved preference: \(key)."
        case .incompleteBackup: return "The existing compatibility backup is incomplete."
        }
    }
}

nonisolated enum LegacyGameMode: Int, Sendable {
    case single = 1, minute, speed, noTime, training, byHeart

    var androidMode: Int? {
        switch self {
        case .single: return 0
        case .minute: return 1
        case .speed: return 2
        case .noTime: return 3
        case .training, .byHeart: return nil // These use dedicated Android routes.
        }
    }
}

nonisolated struct LegacyTrickProgress: Sendable {
    let sourceObject: String
    let legacyID: Int64?
    let androidID: Int?
    let name: String?
    let checked: Bool?
    let status: Bool?
    let statusFixed: Bool?
}

nonisolated struct LegacyLevelProgress: Sendable {
    enum Kind: Sendable, Equatable { case trick, multiplication }
    let sourceObject: String
    let kind: Kind
    let legacyParentID: Int64?
    let androidTrickID: Int?
    let level: Int64?
    let rating: Int64?
    let score: Int64?
    let unlocked: Bool?
}

nonisolated struct LegacyGraphProgress: Sendable {
    let sourceObject: String
    let legacyMode: Int64?
    let date: String?
    let score: Int64?

    var androidMode: Int? {
        guard let legacyMode, let raw = Int(exactly: legacyMode) else { return nil }
        return LegacyGameMode(rawValue: raw)?.androidMode
    }

    /// Only speed graph rows use tenths of a second in the original store.
    var speedSeconds: Double? {
        guard legacyMode == Int64(LegacyGameMode.speed.rawValue), let score else { return nil }
        return Double(score) / 10
    }
}

nonisolated struct LegacyProgressSnapshot: Sendable {
    let storeIdentifier: String
    let storeURL: URL
    let backupURL: URL?
    let openedExistingStore: Bool
    let preferences: LegacyPreferences
    let tricks: [LegacyTrickProgress]
    let trickLevels: [LegacyLevelProgress]
    let multiplicationLevels: [LegacyLevelProgress]
    let graphs: [LegacyGraphProgress]
}
