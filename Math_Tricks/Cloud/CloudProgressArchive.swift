import Foundation
import CryptoKit

nonisolated extension CloudProgress {
    init(archive: ProgressArchive) throws {
        let android = try AndroidProgressArchive.decode(archive.androidEncoded(forCloud:true))
        try self.init(android: android)
    }

    init(android: AndroidProgressArchive) throws {
        self.init()
        let prefs = try android.preferences()
        coins = prefs["preference_tricks_count"] ?? 0
        for (key,pref) in Self.recordKeys { records[key] = prefs[pref] ?? records[key] }
        for (key,pref) in Self.statKeys { stats[key] = prefs[pref] ?? stats[key] }
        for (table,parent,heart) in [("Levels","_idTricks",false),("byHeartLevels","_idByHeart",true)] {
            for row in android.rows(table) {
                let values = try [parent,"name","rating","score","satus"].map { k -> Int64 in guard let n = row[k]?.integer else { throw CloudError.invalid }; return n }
                // Android stores only rows that differ from its initial unlocks.
                let initial = values[1] == 1 || (heart && values[1] == 21)
                if values[2] == 0 && values[3] == 0 && values[4] == (initial ? 1 : 0) { continue }
                if heart { byHeartLevels[Self.key(values)] = values } else { levels[Self.key(values)] = values }
            }
        }
        byHeartUnlocked = Set(android.rows("byHeart").compactMap { r in guard r["satus"]?.integer == 1, let id = r["_id"]?.integer, id > 11 else { return nil }; return id })
        coinUnlocks = Set(android.rows("cloud_coin_unlocks").compactMap { $0["id"]?.integer })
        for row in android.rows("graph") {
            guard let id = row["cloud_id"]?.string, let mode = row["id_graph"]?.integer, let raw = row["value"]?.string, let date = row["date"]?.string,
                  let value = Decimal(string:raw,locale:Locale(identifier:"en_US_POSIX")) else { throw CloudError.invalid }
            let graph = Graph(id:id,mode:mode,value:NSDecimalNumber(decimal:value).stringValue,date:date,
                start:row["series_start"]?.integer ?? 0,count:row["series_count"]?.integer ?? 0,target:row["daily_target"]?.integer ?? 0)
            graphs[id] = graph
        }
        for row in android.rows("cloud_level_metrics") {
            let values = try ["trick","level","errors","average","total","updated_at"].map { k -> Int64 in guard let n = row[k]?.integer else { throw CloudError.invalid }; return n }
            metrics[Self.key(values)] = values
        }
        for (table,individual) in [("game_trick_groups",false),("game_trick_records",true)] {
            for row in android.rows(table) where [0,2,4].contains(row["input_mode"]?.integer ?? -1) {
                let values = try Self.counterColumns.map { k -> Int64 in guard let n = row[k]?.integer else { throw CloudError.invalid }; return n }
                if individual { details[Self.key(values,count:3)] = values } else { groups[Self.key(values,count:3)] = values }
            }
        }
        for row in android.rows("game_example_records") where [0,2,4].contains(row["input_mode"]?.integer ?? -1) {
            guard let text = row["expression"]?.string, let input = row["input_mode"]?.integer, let first = row["first_time"]?.integer, let best = row["best_time"]?.integer, first > 0, best > 0 else { continue }
            let e = Example(expression:PracticeStatistics.normalizeExpression(text),input:input,first:first,best:best)
            examples[e.key] = e
        }
        try validate()
    }

    /// Preserve native sessions and settings; subtract their counters from the imported aggregates.
    func archive(keeping local: ProgressArchive, restoring: Bool = false) throws -> ProgressArchive {
        try validate()
        typealias V = AndroidProgressArchive.Value
        typealias Row = [String:V]
        var tables = Dictionary(uniqueKeysWithValues: AndroidProgressArchive.schemas.map { ($0.0, restoring ? [] : local.androidBackup?.rows($0.0) ?? []) })
        var prefs = restoring ? [:] : (try local.androidBackup?.preferences()) ?? [:]
        prefs["preference_tricks_count"] = coins
        for (key,pref) in Self.recordKeys { prefs[pref] = records[key] }
        // Android's portable file deliberately excludes these two interface preferences.
        for (key,pref) in Self.statKeys where !["alarmPromoShown","exitBehavior"].contains(key) { prefs[pref] = stats[key] }
        prefs["preference_game_type_level"] = min(local.state.currentLevel, records["maxLevel"] ?? 5)
        tables["cloud_progress_prefs"] = prefs.sorted { $0.key < $1.key }.map { ["key":.text($0.key),"value":.number($0.value)] }
        tables["cloud_coin_unlocks"] = coinUnlocks.sorted().map { ["id":.number($0)] }
        for (name,rows,parent) in [("Levels",levels,"_idTricks"),("byHeartLevels",byHeartLevels,"_idByHeart")] {
            tables[name] = rows.sorted { $0.key < $1.key }.map { r in Dictionary(uniqueKeysWithValues:zip([parent,"name","rating","score","satus"], r.value.map(V.number))) }
        }
        tables["byHeart"] = (2...99).map { ["_id":.number(Int64($0)),"name":.text(""),"satus":.number($0 < 12 || byHeartUnlocked.contains(Int64($0)) ? 1 : 0)] }
        tables["graph"] = graphs.values.sorted { $0.date == $1.date ? $0.id < $1.id : $0.date < $1.date }.map { g in
            ["id_graph":.number(g.mode),"value":.text(g.value),"date":.text(g.date),"cloud_id":.text(g.id),"series_start":.number(g.start),"series_count":.number(g.count),"daily_target":.number(g.target)]
        }
        tables["cloud_level_metrics"] = metrics.sorted { $0.key < $1.key }.map { r in Dictionary(uniqueKeysWithValues:zip(["trick","level","errors","average","total","updated_at"],r.value.map(V.number))) }
        let savedReset = (try local.androidBackup?.preferences())?["statistics_reset_at"] ?? 0
        let reset = (stats["statisticsResetAt"] ?? 0) > (local.state.statisticsResetAt ?? savedReset)
        var state = local.state
        let sessions = restoring ? [] : local.sessions
        let multiplayer = restoring ? [] : local.multiplayer
        if reset {
            var baseline = state.statisticsBaseline ?? [:]
            for session in sessions { baseline[session.id] = session.attempts.count }
            for match in multiplayer { for (i,player) in match.players.enumerated() { baseline[match.id + "/\(i)"] = player.attempts.count } }
            state.statisticsBaseline = baseline
        }
        // Build the part already represented by retained native attempts, without imported totals.
        let native = ProgressArchive(state:state,tricks:local.tricks,levels:local.levels,sessions:sessions,multiplayer:multiplayer,historicalGraphs:[],exportedAt:local.exportedAt)
        let contribution = try Self(archive:native)
        for (table,rows,own) in [("game_trick_groups",groups,contribution.groups),("game_trick_records",details,contribution.details)] {
            var all = Dictionary(uniqueKeysWithValues:(tables[table] ?? []).compactMap { r -> (String,Row)? in
                guard let a = r["trick"]?.integer, let b = r["level"]?.integer, let c = r["input_mode"]?.integer else { return nil }; return ("\(a):\(b):\(c)",r)
            })
            let maximum: Int64 = table == "game_trick_records" ? 10 : 100
            all = all.filter { ($0.value["level"]?.integer ?? 0) > maximum || ![0,2,4].contains($0.value["input_mode"]?.integer ?? -1) }
            for (key,var r) in rows {
                if let existing = own[key] { for index in 5..<13 { r[index] = max(0,r[index] - existing[index]) } }
                all[key] = Dictionary(uniqueKeysWithValues:zip(Self.counterColumns,r.map(V.number)))
            }
            tables[table] = all.sorted { $0.key < $1.key }.map(\.value)
        }
        tables["game_example_records"] = examples.sorted { $0.key < $1.key }.map { _,e in ["expression":.text(e.expression),"input_mode":.number(e.input),"first_time":.number(e.first),"best_time":.number(e.best)] }
        let android = AndroidProgressArchive(format:"math-tricks-progress",version:5,createdAt:Int64(Date().timeIntervalSince1970*1000),tables:AndroidProgressArchive.schemas.map { name,columns in
            .init(name:name,columns:columns,rows:(tables[name] ?? []).map { r in columns.map { r[$0] ?? .null } })
        })
        let projected = try android.nativeArchive(settings:local.state.settings,notificationsEnabled:local.state.daily.notificationsEnabled,selectedTricks:Set(local.tricks.filter(\.selected).map(\.id)))
        var projectedState = projected.state
        projectedState.statisticsBaseline = state.statisticsBaseline
        projectedState.playerOneWins = local.state.playerOneWins; projectedState.playerTwoWins = local.state.playerTwoWins
        // Existing session graphs are already generated from those sessions by the UI/exporter.
        let nativeGraphIDs = Set(sessions.filter { $0.phase == .finished && !$0.configuration.selectedTricks }.map { session in
            "android/" + SHA256.hash(data:Data(("ios-session/" + session.id).utf8)).prefix(16).map { String(format:"%02x",$0) }.joined()
        })
        let result = ProgressArchive(state:projectedState,tricks:projected.tricks,levels:projected.levels,sessions:sessions,multiplayer:multiplayer,
            historicalGraphs:projected.historicalGraphs.filter { !nativeGraphIDs.contains($0.sourceID) },androidBackup:android)
        try result.validate()
        return result
    }
}
