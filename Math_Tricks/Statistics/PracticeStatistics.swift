import Foundation

nonisolated enum StatisticsFilter: Equatable, Sendable { case all, session(String), trick(Int), example(String) }
nonisolated struct PracticeEntry: Sendable, Identifiable {
    let id: String
    let sessionID: String
    let startedAt: Date
    let mode: GameMode?
    let multiplayer: Bool
    let attempt: ExampleAttempt
}
nonisolated struct PracticeAggregate: Sendable, Identifiable {
    let id: String
    let entries: [PracticeEntry]
    var imported:[ImportedPracticeRecord]=[]
    var trickRecord = false
    private var gameAverages: [(date: Date, level: Int, value: TimeInterval)] {
        Dictionary(grouping: independent) { $0.sessionID + "/" + String($0.attempt.level) }.values.compactMap { group in
            guard let first=group.first else{return nil}
            return (first.startedAt,first.attempt.level,group.reduce(0){$0+$1.attempt.elapsed}/Double(group.count))
        }.sorted { $0.date == $1.date ? $0.level < $1.level : $0.date < $1.date }
    }
    var solved: Int { entries.filter { $0.attempt.outcome == .solved }.count + imported.reduce(0){$0+$1.solved} }
    var independent: [PracticeEntry] { entries.filter { $0.attempt.eligible } }
    var independentCount:Int {independent.count+imported.reduce(0){$0+$1.clean}}
    var average: TimeInterval? {independentCount==0 ? nil:(independent.reduce(0){$0+$1.attempt.elapsed}+imported.reduce(0){$0+$1.cleanTime})/Double(independentCount)}
    var first: TimeInterval? { if trickRecord { return imported.compactMap(\.first).first ?? gameAverages.first?.value }; return imported.compactMap(\.first).first ?? independent.sorted { $0.startedAt == $1.startedAt ? $0.attempt.ordinal < $1.attempt.ordinal : $0.startedAt < $1.startedAt }.first?.attempt.elapsed }
    var best: TimeInterval? { ((trickRecord ? gameAverages.map(\.value) : independent.map { $0.attempt.elapsed })+imported.compactMap(\.best)).min() }
    var errors: Int { entries.reduce(0) { $0 + $1.attempt.errors + $1.attempt.corrections }+imported.reduce(0){$0+$1.errors} }
    var attempts: Int { entries.count + imported.reduce(0) { $0 + $1.attempts } }
    var errorRate: Double { Double(errors) / Double(max(1, attempts)) }
    var hints: Int { entries.reduce(0) { $0 + $1.attempt.hints }+imported.reduce(0){$0+$1.hints} }
    var skipped: Int { entries.filter { $0.attempt.outcome == .skipped }.count + imported.reduce(0) { $0 + $1.skipped } }
    var totalTime: TimeInterval { entries.reduce(0) { $0 + $1.attempt.elapsed }+imported.reduce(0){$0+$1.total} }
}
nonisolated struct PracticeStatistics: Sendable {
    let imported:[ImportedPracticeRecord]
    let importedDetails: [ImportedPracticeRecord]
    let sessions: [GameSession]
    let multiplayerSessions: [MultiplayerSession]
    let entries: [PracticeEntry]
    let legacyGraphs: [HistoricalGraphPoint]
    init(sessions: [GameSession], multiplayer: [MultiplayerSession], legacyGraphs: [HistoricalGraphPoint],androidBackup:AndroidProgressArchive?=nil, baseline: [String:Int] = [:]) throws {
        imported=try androidBackup?.practiceRecords() ?? []
        importedDetails=try androidBackup?.practiceRecords(includeDetails: true) ?? []
        self.sessions = sessions; multiplayerSessions = multiplayer
        let graphMetadata = Dictionary(uniqueKeysWithValues: (androidBackup?.rows("graph") ?? []).compactMap { row -> (String,[String:AndroidProgressArchive.Value])? in
            guard let id = row["cloud_id"]?.string else { return nil }; return ("android/" + id, row)
        })
        self.legacyGraphs = legacyGraphs.map { original in
            guard let row = graphMetadata[original.sourceID] else { return original }
            var point = original
            point.seriesStartDay = point.seriesStartDay ?? row["series_start"]?.integer.flatMap(Int.init(exactly:))
            point.seriesCount = point.seriesCount ?? row["series_count"]?.integer
            point.dailyTarget = point.dailyTarget ?? row["daily_target"]?.integer.flatMap(Int.init(exactly:))
            return point
        }
        var all: [PracticeEntry] = []
        for session in sessions {
            all.append(contentsOf: session.attempts.map { PracticeEntry(id: session.id + "/\($0.ordinal)",sessionID: session.id,startedAt: session.startedAt,mode: session.configuration.mode,multiplayer: false,attempt: $0) })
        }
        for session in multiplayer {
            for (player, child) in session.players.enumerated() {
                all.append(contentsOf: child.attempts.map { PracticeEntry(id: session.id + "/\(player)/\($0.ordinal)",sessionID: session.id,startedAt: session.startedAt,mode: nil,multiplayer: true,attempt: $0) })
            }
        }
        entries = all.filter { $0.attempt.ordinal > (baseline[$0.multiplayer ? $0.id.components(separatedBy: "/").dropLast().joined(separator: "/") : $0.sessionID] ?? 0) }.sorted { $0.startedAt == $1.startedAt ? $0.id < $1.id : $0.startedAt > $1.startedAt }
    }
    func filtered(_ filter: StatisticsFilter, input: GameInputMode? = nil, levels: ClosedRange<Int>? = nil) -> [PracticeEntry] {
        entries.filter { entry in
            let permitted: Bool
            switch filter { case .all: permitted = true; case .session(let id): permitted = entry.sessionID == id; case .trick(let id): permitted = entry.attempt.example.trickID == id; case .example(let key): permitted = entry.attempt.example.signature == key || Self.expressionKey(entry.attempt.example) == key }
            return permitted && (input == nil || entry.attempt.inputMode == input) && (levels?.contains(entry.attempt.level) ?? true)
        }
    }
    static func expressionKey(_ example:MathExample)->String {
        normalizeExpression(MathExpressionFormatter.text(example))
    }
    static func normalizeExpression(_ text:String)->String {
        var value=text.components(separatedBy:.whitespacesAndNewlines).joined()
        for (old,new) in [("×","*"),("∙","*"),("·","*"),("÷","/"),(":","/"),("−","-"),("–","-")] {value=value.replacingOccurrences(of:old,with:new)}
        return value
    }
    static func examples(_ entries: [PracticeEntry]) -> [PracticeAggregate] {
        Dictionary(grouping: entries) { expressionKey($0.attempt.example) }.map { PracticeAggregate(id: $0.key,entries: $0.value) }
    }
    static func tricks(_ entries: [PracticeEntry]) -> [PracticeAggregate] {
        Dictionary(grouping: entries) { String($0.attempt.example.trickID) }.map { PracticeAggregate(id: $0.key,entries: $0.value,trickRecord:true) }
    }
}
