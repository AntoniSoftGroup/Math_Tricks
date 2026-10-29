import Foundation
import CoreFoundation

nonisolated enum CloudError: String, LocalizedError {
    case unavailable, invalid, tooLarge, changed, accountChanged, missing, signIn, linkedElsewhere
    var errorDescription: String? { CloudText.text(rawValue) }
}

nonisolated enum CloudText {
    private static let english = Bundle.main.path(forResource:"en",ofType:"lproj").flatMap(Bundle.init(path:))
    static func text(_ key: String) -> String {
        let name = "cloud." + key
        let fallback = english?.localizedString(forKey:name,value:nil,table:"Interface")
        return Bundle.main.localizedString(forKey:name,value:fallback,table:"Interface")
    }
}

/// The Android Firestore contract. Settings, age, billing and live sessions stay on the device.
nonisolated struct CloudProgress: Codable, Equatable, Sendable {
    struct Graph: Codable, Equatable, Sendable {
        var id: String
        var mode: Int64
        var value: String
        var date: String
        var start: Int64 = 0
        var count: Int64 = 0
        var target: Int64 = 0
        var encoded: String { "\(id),\(mode),\(value),\(date)" + (target > 0 ? ",\(start),\(count),\(target)" : "") + ";" }
    }
    struct Example: Codable, Equatable, Sendable {
        var expression: String
        var input: Int64
        var first: Int64
        var best: Int64
        var key: String { expression + "/\(input)" }
    }
    var coins: Int64 = 0
    var records: [String:Int64] = ["classic":0,"minute":0,"time":Int64(Int32.max),"untimed":0,"selection":0,"selectionMinute":0,"selectionTime":Int64(Int32.max),"selectionUntimed":0,"team":0,"maxLevel":5]
    var stats = statKeys.mapValues { $0 == "preference_ex_per_day_total" ? Int64(5) : $0 == "exit_behavior" ? -1 : 0 }
    var levels: [String:[Int64]] = [:]
    var byHeartLevels: [String:[Int64]] = [:]
    var byHeartUnlocked: Set<Int64> = []
    var coinUnlocks: Set<Int64> = []
    var graphs: [String:Graph] = [:]
    var metrics: [String:[Int64]] = [:]
    var groups: [String:[Int64]] = [:]
    var details: [String:[Int64]] = [:]
    var examples: [String:Example] = [:]
    var hasMetrics = true
    var hasGroups = true
    var hasDetails = true
    var hasExamples = true

    static let recordKeys = ["classic":"preference_score_max", "minute":"preference_score_max_minute", "time":"preference_score_max_time", "untimed":"preference_score_max_not_time", "selection":"preference_score_max_selection", "selectionMinute":"preference_score_max_selection_minute", "selectionTime":"preference_score_max_selection_time", "selectionUntimed":"preference_score_max_selection_not_time", "team":"preference_score_max_timewise", "maxLevel":"preference_game_type_level_max"]
    static let statKeys = ["statisticsResetAt":"statistics_reset_at", "totalSolved":"preference_ex_per_day_total_solved", "daysStreak":"preference_days_streak", "today":"preference_ex_per_day_today_new", "target":"preference_ex_per_day_total", "dayDate":"preference_set_day_streak_date", "incremented":"preference_inc_day_streak_date", "alarmPromoShown":"alarm_promo_shown", "exitBehavior":"exit_behavior", "shieldReady":"streak_shield_ready", "shieldProgress":"streak_shield_progress", "streakPending":"streak_pending", "streakPendingCost":"streak_pending_cost", "streakPendingDay":"streak_pending_day", "streakEndedDay":"streak_ended_day", "shieldUsedDay":"streak_shield_used_day", "seriesStartDay":"streak_series_start_day"]
    static let counterColumns = ["trick","level","input_mode","first_time","best_time","attempts","solved","clean","errors","hints","skipped","total_time","clean_time"]
    static let limit = 1_044_480
    static let rawLimit = 32 * 1024 * 1024

    static func key(_ row: [Int64], count: Int = 2) -> String { row.prefix(count).map(String.init).joined(separator: ":") }
    static func lowerRecord(_ key: String) -> Bool { key == "time" || key == "selectionTime" }
    func sameWallet(_ other: Self) -> Bool { coins == other.coins && coinUnlocks == other.coinUnlocks }
    var isEmpty: Bool {
        coins == 0 && coinUnlocks.isEmpty && levels.isEmpty && byHeartLevels.isEmpty && byHeartUnlocked.isEmpty
            && graphs.isEmpty && stats["totalSolved"] == 0 && stats["today"] == 0 && stats["daysStreak"] == 0
            && records == Self().records && metrics.isEmpty && groups.isEmpty && details.isEmpty && examples.isEmpty
    }

    static func integer(_ value: Any?, min: Int64 = 0, max: Int64 = Int64.max - 1) throws -> Int64 {
        guard let n = value as? NSNumber, CFGetTypeID(n) != CFBooleanGetTypeID(),
              !["f","d"].contains(String(cString: n.objCType)), n.int64Value >= min, n.int64Value <= max else { throw CloudError.invalid }
        return n.int64Value
    }
    static func encodeRows(_ rows: [String:[Int64]]) -> String {
        rows.sorted { $0.key < $1.key }.map { $0.value.map(String.init).joined(separator: ",") + ";" }.joined()
    }
    static func decodeRows(_ text: String, columns: Int, keys: Int = 2) throws -> [String:[Int64]] {
        guard text.utf8.count <= rawLimit, text.isEmpty || text.hasSuffix(";") else { throw CloudError.invalid }
        let parts = text.split(separator: ";", omittingEmptySubsequences: true)
        guard parts.count <= 200_000 else { throw CloudError.tooLarge }
        var result: [String:[Int64]] = [:]
        for part in parts {
            var values = part.split(separator: ",", omittingEmptySubsequences: false)
            if columns == 13 && values.count == 14 { values.remove(at: 5) }
            guard values.count == columns else { throw CloudError.invalid }
            let row = try values.map { value -> Int64 in guard let n = Int64(value) else { throw CloudError.invalid }; return n }
            guard result.updateValue(row, forKey: key(row, count: keys)) == nil else { throw CloudError.invalid }
        }
        return result
    }
    static func packed(_ data: Data, limit: Int = limit) throws -> String {
        guard data.count <= rawLimit else { throw CloudError.tooLarge }
        let value = try ArchiveGzip.compress(data).base64EncodedString()
        guard value.utf8.count <= limit else { throw CloudError.tooLarge }
        return value
    }
    static func unpacked(_ value: Any?, limit: Int = rawLimit) throws -> Data {
        guard let text = value as? String, text.utf8.count <= Self.limit, let compressed = Data(base64Encoded: text) else { throw CloudError.invalid }
        let data = try ArchiveGzip.decompress(compressed)
        guard data.count <= limit else { throw CloudError.tooLarge }
        return data
    }
    func legacyMap(enforceCapacity: Bool = true) throws -> [String:Any] {
        try validate()
        let graphText = graphs.values.sorted { $0.date == $1.date ? $0.id < $1.id : $0.date < $1.date }.map(\.encoded).joined()
        if enforceCapacity { guard graphs.count <= 20_000, graphText.utf8.count <= 2_000_000 else { throw CloudError.tooLarge } }
        let map: [String:Any] = ["coins":coins, "records":records, "stats":stats,
            "levels":Self.encodeRows(levels), "byHeartLevels":Self.encodeRows(byHeartLevels),
            "byHeartUnlocked":byHeartUnlocked.sorted().map { "\($0);" }.joined(), "coinUnlocks":coinUnlocks.sorted().map { "\($0);" }.joined(),
            "graphs":["encoding":"gzip-base64", "count":graphs.count, "data":try Self.packed(Data(graphText.utf8), limit: enforceCapacity ? 600_000 : Int.max)]]
        if enforceCapacity { guard try JSONSerialization.data(withJSONObject: map).count <= 685_000 else { throw CloudError.tooLarge } }
        return map
    }
    init() {}
    init(legacyMap map: [String:Any]) throws {
        self.init()
        guard Set(map.keys) == Set(["coins","records","levels","byHeartLevels","byHeartUnlocked","coinUnlocks","stats","graphs"]),
              let recordMap = map["records"] as? [String:Any], Set(recordMap.keys) == Set(Self.recordKeys.keys),
              let statMap = map["stats"] as? [String:Any], Set(statMap.keys).isSubset(of: Set(Self.statKeys.keys)),
              Set(["totalSolved","daysStreak","today","target","dayDate","incremented"]).isSubset(of: Set(statMap.keys)) else { throw CloudError.invalid }
        coins = try Self.integer(map["coins"], max: Int64(Int32.max))
        for k in records.keys {
            let n = try Self.integer(recordMap[k], min: k == "maxLevel" ? 1 : 0, max: Int64(Int32.max))
            records[k] = Self.lowerRecord(k) && n == 0 ? Int64(Int32.max) : k == "maxLevel" ? max(5,n) : n
        }
        for (k,v) in statMap { stats[k] = try Self.integer(v, min: k == "exitBehavior" ? -1 : k == "target" ? 1 : 0, max: ["dayDate","statisticsResetAt"].contains(k) ? 4_102_444_800_000 : Int64(Int32.max)) }
        for (field,byHeart) in [("levels",false),("byHeartLevels",true)] {
            guard let text = map[field] as? String, text.utf8.count <= 350_000 else { throw CloudError.invalid }
            let rows = try Self.decodeRows(text, columns: 5)
            if byHeart { byHeartLevels = rows } else { levels = rows }
        }
        func ids(_ field: String) throws -> Set<Int64> {
            guard let text = map[field] as? String, text.isEmpty || text.hasSuffix(";") else { throw CloudError.invalid }
            let values = try text.split(separator: ";").map { s -> Int64 in guard let n = Int64(s), n > 0 else { throw CloudError.invalid }; return n }
            guard values.count <= 1000, Set(values).count == values.count else { throw CloudError.invalid }
            return Set(values)
        }
        byHeartUnlocked = try ids("byHeartUnlocked"); coinUnlocks = try ids("coinUnlocks")
        guard let g = map["graphs"] as? [String:Any], Set(g.keys) == Set(["encoding","count","data"]), g["encoding"] as? String == "gzip-base64" else { throw CloudError.invalid }
        let count = try Self.integer(g["count"], max: 20_000)
        let raw = try Self.unpacked(g["data"], limit: 2_000_000)
        guard let text = String(data: raw, encoding: .ascii), text.isEmpty || text.hasSuffix(";") else { throw CloudError.invalid }
        for line in text.split(separator: ";") {
            let p = line.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
            guard p.count == 4 || p.count == 7, let mode = Int64(p[1]) else { throw CloudError.invalid }
            var graph = Graph(id:p[0],mode:mode,value:p[2],date:p[3])
            if p.count == 7 {
                guard let start = Int64(p[4]), let c = Int64(p[5]), let target = Int64(p[6]) else { throw CloudError.invalid }
                graph.start = start; graph.count = c; graph.target = target
            }
            guard graphs.updateValue(graph, forKey: graph.id) == nil else { throw CloudError.invalid }
        }
        guard graphs.count == count else { throw CloudError.invalid }
        hasMetrics = false; hasGroups = false; hasDetails = false; hasExamples = false
        try validate()
    }
    func validate() throws {
        guard (0...Int64(Int32.max)).contains(coins), Set(records.keys) == Set(Self.recordKeys.keys), Set(stats.keys) == Set(Self.statKeys.keys),
              records.allSatisfy({ (0...Int64(Int32.max)).contains($0.value) }), (5...Int64(Int32.max)).contains(records["maxLevel"] ?? 0),
              (1...100).contains(stats["target"] ?? 0), (0...6).contains(stats["shieldProgress"] ?? 0), (-1...2).contains(stats["exitBehavior"] ?? -2),
              (0...1).contains(stats["incremented"] ?? -1), (0...1).contains(stats["alarmPromoShown"] ?? -1),
              stats.allSatisfy({ $0.key == "exitBehavior" || $0.value >= 0 }), (stats["statisticsResetAt"] ?? 0) <= 4_102_444_800_000 else { throw CloudError.invalid }
        let trickIDs = Set(TrickCatalog.shared.tricks.map { Int64($0.id) })
        guard coinUnlocks.isSubset(of: trickIDs), byHeartUnlocked.allSatisfy({ (12...99).contains($0) }) else { throw CloudError.invalid }
        for (rows,heart) in [(levels,false),(byHeartLevels,true)] {
            guard rows.count <= 20_000 else { throw CloudError.tooLarge }
            for (key,r) in rows {
                guard r.count == 5, key == Self.key(r), heart ? (2...99).contains(r[0]) : trickIDs.contains(r[0]),
                      (1...(heart ? 21 : 100)).contains(r[1]), (0...3).contains(r[2]), (0...Int64(Int32.max)).contains(r[3]), (0...1).contains(r[4]) else { throw CloudError.invalid }
            }
        }
        for (key,g) in graphs {
            guard key == g.id, g.id.count == 32, g.id.allSatisfy({ $0.isASCII && $0.isHexDigit && !$0.isUppercase }),
                  (1...5).contains(g.mode), let value = Decimal(string:g.value,locale:Locale(identifier:"en_US_POSIX")), value >= 0, value <= Decimal(Int32.max),
                  g.value.range(of:"^[0-9]+([.][0-9]+)?$",options:.regularExpression) != nil, g.start >= 0, g.count >= 0, g.target >= 0,
                  g.mode == 5 || (g.start == 0 && g.count == 0 && g.target == 0) else { throw CloudError.invalid }
            let f = DateFormatter(); f.locale = Locale(identifier:"en_US_POSIX"); f.calendar = Calendar(identifier:.gregorian); f.timeZone = TimeZone(secondsFromGMT:0); f.isLenient = false
            switch g.date.count { case 10:f.dateFormat="yyyy.MM.dd"; case 18:f.dateFormat="yyyy.MM.dd - HH:mm"; case 21:f.dateFormat="yyyy.MM.dd - HH:mm:ss"; case 25:f.dateFormat="yyyy.MM.dd - HH:mm:ss.SSS"; default:throw CloudError.invalid }
            guard let date = f.date(from:g.date), f.string(from:date) == g.date else { throw CloudError.invalid }
        }
        for (key,r) in metrics {
            guard r.count == 6, key == Self.key(r), trickIDs.contains(r[0]), (1...100).contains(r[1]), (-1...Int64(Int32.max)).contains(r[2]), r[3] >= -1, r[4] >= 0, (0...4_102_444_800_000).contains(r[5]) else { throw CloudError.invalid }
        }
        for (rows,individual) in [(groups,false),(details,true)] {
            guard rows.count <= 200_000 else { throw CloudError.tooLarge }
            for (key,r) in rows {
                guard r.count == 13, key == Self.key(r,count:3), trickIDs.contains(r[0]), (1...100).contains(r[1]), individual || (r[1]-1)%10 == 0,
                      [0,2,4].contains(r[2]), r[3] >= -1, r[4] >= -1, r.dropFirst(5).allSatisfy({ (0...1_000_000_000_000_000).contains($0) }), r[6] <= r[5], r[7] <= r[6], r[12] <= r[11] else { throw CloudError.invalid }
            }
        }
        guard examples.count <= 1_000_000 else { throw CloudError.tooLarge }
        for (key,e) in examples { guard key == e.key, !e.expression.isEmpty, e.expression.count <= 1024, [0,2,4].contains(e.input), e.first > 0, e.best > 0, e.best <= e.first else { throw CloudError.invalid } }
    }
}
