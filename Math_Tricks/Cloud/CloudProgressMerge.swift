import Foundation

nonisolated extension CloudProgress {
    /// Mirrors Android: a wallet is selected, never added; independent statistics use a common baseline.
    static func merge(_ local: Self, _ remote: Self, localWallet: Bool, base: Self?) throws -> Self {
        var result = Self()
        let wallet = localWallet ? local : remote
        result.coins = wallet.coins; result.coinUnlocks = wallet.coinUnlocks
        result.byHeartUnlocked = local.byHeartUnlocked.union(remote.byHeartUnlocked)
        for key in recordKeys.keys {
            let a = local.records[key]!, b = remote.records[key]!, initial = result.records[key]!
            if let old = base?.records[key], a == initial && a != old && b == old { result.records[key] = a }
            else if let old = base?.records[key], b == initial && b != old && a == old { result.records[key] = b }
            else { result.records[key] = lowerRecord(key) ? min(a,b) : max(a,b) }
        }
        func mergeLevels(_ a: [String:[Int64]], _ b: [String:[Int64]]) -> [String:[Int64]] {
            a.merging(b) { first,second in var row = first; for i in 2..<5 { row[i] = max(first[i],second[i]) }; return row }
        }
        result.levels = mergeLevels(local.levels, remote.levels)
        result.byHeartLevels = mergeLevels(local.byHeartLevels, remote.byHeartLevels)
        result.hasMetrics = local.hasMetrics || remote.hasMetrics
        for key in Set(local.metrics.keys).union(remote.metrics.keys) {
            let a = local.metrics[key], b = remote.metrics[key], old = base?.metrics[key]
            if let old, (a == nil && b == old && local.hasMetrics) || (b == nil && a == old && remote.hasMetrics) { continue }
            if let a, let b { result.metrics[key] = a[5] > b[5] || (a[5] == b[5] && localWallet) ? a : b }
            else { result.metrics[key] = a ?? b }
        }
        func hasWork(_ p: Self) -> Bool { ["totalSolved","today","daysStreak"].contains { (p.stats[$0] ?? 0) > 0 } }
        func sameDay(_ a: Int64, _ b: Int64) -> Bool {
            if a == 0 || b == 0 { return a == b }
            return Calendar.current.isDate(Date(timeIntervalSince1970:Double(a)/1000),inSameDayAs:Date(timeIntervalSince1970:Double(b)/1000))
        }
        let sameDate = sameDay(local.stats["dayDate"]!,remote.stats["dayDate"]!)
        var daily = !hasWork(local) && hasWork(remote) ? remote : !hasWork(remote) && hasWork(local) ? local : local.stats["dayDate"]! > remote.stats["dayDate"]! ? local : remote
        if sameDate {
            for key in ["shieldUsedDay","incremented","today"] where local.stats[key] != remote.stats[key] {
                daily = local.stats[key]! > remote.stats[key]! ? local : remote
                break
            }
        }
        result.stats = daily.stats
        let lastUse = max(local.stats["shieldUsedDay"]!,remote.stats["shieldUsedDay"]!)
        if daily.stats["shieldUsedDay"]! < lastUse {
            for k in ["shieldReady","shieldProgress","streakPending","streakPendingDay","streakPendingCost"] { result.stats[k] = 0 }
            result.stats["shieldUsedDay"] = lastUse
        }
        for k in ["totalSolved","alarmPromoShown"] { result.stats[k] = max(local.stats[k]!,remote.stats[k]!) }
        result.stats["exitBehavior"] = local.stats["exitBehavior"]! >= 0 ? local.stats["exitBehavior"] : remote.stats["exitBehavior"]
        if sameDate { for k in ["today","daysStreak","incremented"] { result.stats[k] = max(local.stats[k]!,remote.stats[k]!) } }
        result.graphs = local.graphs
        for (key,point) in remote.graphs {
            if let existing = result.graphs[key], existing != point {
                guard existing.mode == 4, point.mode == 4, existing.date == point.date else { throw CloudError.invalid }
                let initial = base?.graphs[key]
                if initial == point || ((initial == nil || initial != existing) && localWallet) { continue }
            }
            result.graphs[key] = point
        }
        var days: [String:Graph] = [:]
        for point in result.graphs.values where point.mode == 5 {
            let key = String(point.date.prefix(10))
            if let old = days[key] {
                let a = Decimal(string:point.value)!, b = Decimal(string:old.value)!
                if a < b || (a == b && (point.target < old.target || (point.target == old.target && point.id > old.id))) { continue }
            }
            days[key] = point
        }
        result.graphs = result.graphs.filter { $0.value.mode != 5 || days[String($0.value.date.prefix(10))]?.id == $0.key }
        let localReset = local.stats["statisticsResetAt"]!, remoteReset = remote.stats["statisticsResetAt"]!
        result.stats["statisticsResetAt"] = max(localReset,remoteReset)
        if localReset != remoteReset {
            let newest = localReset > remoteReset ? local : remote
            result.groups = newest.groups; result.details = newest.details; result.examples = newest.examples
        } else {
            let initial = base?.stats["statisticsResetAt"] == localReset ? base : nil
            func counters(_ a: [String:[Int64]], _ b: [String:[Int64]], _ old: [String:[Int64]]?, aPresent: Bool, bPresent: Bool) throws -> [String:[Int64]] {
                var rows: [String:[Int64]] = [:]
                for key in Set(a.keys).union(b.keys) {
                    let first = a[key], second = b[key], start = old?[key]
                    if let start, (first == nil && second == start && aPresent) || (second == nil && first == start && bPresent) { continue }
                    guard let first, let second else { rows[key] = first ?? second; continue }
                    var row = localWallet ? first : second
                    row[3] = (start?[3] ?? -1) > 0 ? start![3] : first[3] > 0 ? first[3] : second[3]
                    row[4] = first[4] < 0 ? second[4] : second[4] < 0 ? first[4] : min(first[4],second[4])
                    for i in 5..<13 {
                        if let start {
                            let delta = max(0,first[i]-start[i]).addingReportingOverflow(max(0,second[i]-start[i]))
                            let sum = start[i].addingReportingOverflow(delta.partialValue)
                            guard !delta.overflow, !sum.overflow else { throw CloudError.tooLarge }
                            row[i] = sum.partialValue
                        } else { row[i] = max(first[i],second[i]) }
                    }
                    rows[key] = row
                }
                return rows
            }
            result.groups = try counters(local.groups,remote.groups,initial?.groups,aPresent:local.hasGroups,bPresent:remote.hasGroups)
            result.details = try counters(local.details,remote.details,initial?.details,aPresent:local.hasDetails,bPresent:remote.hasDetails)
            for key in Set(local.examples.keys).union(remote.examples.keys) {
                let a = local.examples[key], b = remote.examples[key], old = initial?.examples[key]
                if let old, (a == nil && b == old && local.hasExamples) || (b == nil && a == old && remote.hasExamples) { continue }
                guard var a, let b else { result.examples[key] = a ?? b; continue }
                a.first = old?.first ?? b.first; a.best = min(a.first,a.best,b.best); result.examples[key] = a
            }
        }
        result.hasGroups = local.hasGroups || remote.hasGroups; result.hasDetails = local.hasDetails || remote.hasDetails; result.hasExamples = local.hasExamples || remote.hasExamples
        try result.validate()
        return result
    }

    #if DEBUG
    static func checkPolicy() throws {
        let empty = try ArchiveGzip.compress(Data())
        let decodedEmpty = try ArchiveGzip.decompress(empty)
        assert(!empty.isEmpty && decodedEmpty.isEmpty)
        var a = Self(), b = Self()
        a.coins = 20; b.coins = 10
        a.stats["totalSolved"] = 8; b.stats["totalSolved"] = 5
        let merged = try merge(a,b,localWallet:false,base:nil)
        assert(merged.coins == 10 && merged.stats["totalSolved"] == 8)
        let wire = try a.legacyMap()
        let decoded = try Self(legacyMap:wire)
        assert(a.sameWallet(decoded) && a.records == decoded.records)
        let row: [Int64] = [1,1,0,10,10,4,4,4,0,0,0,40,40]
        a.groups = [key(row,count:3):row]; b = a
        let repeated = try merge(a,b,localWallet:true,base:a)
        assert(repeated.groups == a.groups)
        var detail = row; detail[1] = 11
        a.details = [key(detail,count:3):detail]
        let payload = try CloudPayload(a)
        assert(payload.progress.details.isEmpty && payload.fraction < 0.8 && payload.texts.count == 4)
        let groups = try String(data:unpacked(payload.texts[1]),encoding:.utf8)
        assert(groups == encodeRows(a.groups))
        a.details.removeAll()
        let state = ProgressState(legacy:try LegacyPreferences(domain:[:]))
        let local = ProgressArchive(state:state,tricks:TrickCatalog.shared.tricks.map { .init(id:$0.id,selected:true,unlocked:$0.initiallyUnlocked) },levels:[],sessions:[],multiplayer:[],historicalGraphs:[])
        let applied = try a.archive(keeping:local)
        let restored = try Self(archive:applied)
        assert(restored.coins == a.coins && restored.groups == a.groups && restored.details == a.details)
        let appliedAgain = try restored.archive(keeping:applied)
        let repeatedArchive = try Self(archive:appliedAgain)
        assert(repeatedArchive.groups == restored.groups)
    }
    #endif
}
