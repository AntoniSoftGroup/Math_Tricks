import Foundation

/// Canonical projections keep the original Core Data rows intact, including duplicates.
nonisolated struct LegacyProgressIndex: Sendable {
    var tricks: [Int: TrickProgress] = [:]
    var levels: [LevelKey: LevelProgress] = [:]
    let graphs: [HistoricalGraphPoint]

    init() { graphs = [] }

    init(snapshot: LegacyProgressSnapshot) {
        for row in snapshot.tricks {
            guard let id = row.androidID else { continue }
            let previous = tricks[id]
            tricks[id] = TrickProgress(id: id, selected: (previous?.selected ?? false) || row.checked == true,
                                      unlocked: (previous?.unlocked ?? false) || row.status == true)
        }
        for row in snapshot.trickLevels + snapshot.multiplicationLevels {
            let parent: Int?
            let scope: LevelKey.Scope
            if row.kind == .trick {
                scope = .trick
                parent = row.androidTrickID
            } else {
                scope = .multiplication
                parent = row.legacyParentID.flatMap { Int(exactly: $0) }
            }
            guard let parent, let number = row.level.flatMap({ Int(exactly: $0) }) else { continue }
            let key = LevelKey(scope: scope, parentID: parent, level: number)
            guard (try? key.validate()) != nil else { continue }
            let value = LevelProgress(key: key, bestScore: row.score ?? 0,
                                      bestStars: row.rating ?? 0, unlocked: row.unlocked == true)
            levels[key] = Self.merge(levels[key], value)
        }
        graphs = snapshot.graphs.map { row in
            let mode: GameMode?
            switch row.legacyMode {
            case 1: mode = .single
            case 2: mode = .minute
            case 3: mode = .speed
            case 4: mode = .noTime
            default: mode = nil
            }
            return HistoricalGraphPoint(sourceID: row.sourceObject, mode: mode,
                originalModeID: row.legacyMode, dateText: row.date, originalScore: row.score,
                value: mode == .speed ? row.speedSeconds : row.score.map(Double.init),
                unit: mode == .speed ? .seconds : .points)
        }
    }

    static func merge(_ base: LevelProgress?, _ value: LevelProgress) -> LevelProgress {
        guard let base else { return value }
        return LevelProgress(key: value.key, bestScore: max(base.bestScore, value.bestScore),
                             bestStars: max(base.bestStars, value.bestStars), unlocked: base.unlocked || value.unlocked,measurements:value.measurements ?? base.measurements)
    }
}
