import Foundation
import CryptoKit

nonisolated extension ProgressArchive {
    /// Android's file stores progress and measurements, rather than iOS UI settings/live sessions.
    func androidEncoded(forCloud: Bool = false)throws->Data {
        try validate()
        typealias V=AndroidProgressArchive.Value
        typealias Row=[String:V]
        func add(_ a:Int64,_ b:Int64)throws->Int64 {
            let result=a.addingReportingOverflow(b)
            guard !result.overflow,(-1...1_000_000_000_000_000).contains(result.partialValue) else {throw ProgressError.invalidArchive}
            return result.partialValue
        }
        guard levels.allSatisfy({$0.bestScore<=Int32.max}) else {throw ProgressError.invalidArchive}
        var tables=Dictionary(uniqueKeysWithValues:AndroidProgressArchive.schemas.map{($0.0,androidBackup?.rows($0.0) ?? [])})
        let saved=Dictionary(uniqueKeysWithValues:levels.map{($0.key,$0)})
        for (name,scope,parents,last) in [("Levels",LevelKey.Scope.trick,TrickCatalog.shared.tricks.map(\.id),100),("byHeartLevels",.multiplication,Array(2...99),21)] {
            tables[name]=parents.flatMap {parent in (1...last).map {number->Row in
                let item=saved[LevelKey(scope:scope,parentID:parent,level:number)]
                return [scope == .trick ? "_idTricks":"_idByHeart":.number(Int64(parent)),"name":.number(Int64(number)),"rating":.number(item?.bestStars ?? 0),"score":.number(item?.bestScore ?? 0),"satus":.number((number==1 || (scope == .multiplication && number==21) || item?.unlocked==true) ? 1:0)]
            }}
        }
        let oldNumbers=Dictionary(uniqueKeysWithValues:(tables["byHeart"] ?? []).compactMap{row->(Int64,V)? in guard let id=row["_id"]?.integer,let status=row["satus"] else{return nil};return (id,status)})
        tables["byHeart"]=(2...99).map{["_id":V.number(Int64($0)),"name":.text(""),"satus":oldNumbers[Int64($0)] ?? .number($0<=11 ? 1:0)]}
        tables["cloud_coin_unlocks"]=tricks.filter{item in item.unlocked && TrickCatalog.shared.trick(item.id)?.initiallyUnlocked != true}.map{["id":.number(Int64($0.id))]}
        // Current Android v5 restore rejects a scope below -1, including its own
        // older selected-set summaries. Keep those in the full iOS archive instead.
        if forCloud { tables["game_level_records"] = [] }
        else { guard (tables["game_level_records"] ?? []).allSatisfy({($0["scope"]?.integer ?? -1)>=(-1)}) else {throw ProgressError.invalidArchive} }
        var prefs=(try androidBackup?.preferences()) ?? [:]
        let direct:[String:Int64]=["preference_tricks_count":state.coins,"preference_ex_per_day_total_solved":state.totalSolved,"preference_game_type_level":state.currentLevel,"preference_training_level":state.selectedCurrentLevel ?? state.currentLevel,"preference_game_type_level_max":state.maximumLevel,"preference_rtm_count_victory":state.playerOneWins,"preference_rtm_count_defeat":state.playerTwoWins,"preference_days_streak":state.daily.streak,"preference_ex_per_day_today_new":state.daily.solved,"preference_ex_per_day_total":Int64(state.daily.target),"preference_inc_day_streak_date":state.daily.completedToday==true ? 1:0,"streak_shield_progress":Int64(state.daily.insuranceProgress ?? 0),"streak_shield_ready":Int64(state.daily.readyInsurance ?? 0),"streak_pending":state.daily.pendingStreak ?? 0,"streak_pending_cost":Int64(state.daily.pendingCost ?? 0)]
        prefs.merge(direct){_,new in new}
        prefs["statistics_reset_at"] = state.statisticsResetAt ?? prefs["statistics_reset_at"] ?? 0
        prefs["streak_series_start_day"] = state.daily.seriesStartDay.map(Int64.init) ?? 0
        if let joint=state.jointRecord {guard joint<=Int32.max else {throw ProgressError.invalidArchive};prefs["preference_score_max_timewise"]=joint}
        for (mode,suffix) in [(GameMode.single,""),(.minute,"_minute"),(.speed,"_time"),(.noTime,"_not_time")] {
            for selected in [false,true] {
                let key="preference_score_max"+(selected ? "_selection":"")+suffix
                prefs.removeValue(forKey:key)
                if let record=state.records.first(where:{$0.mode==mode && $0.selectedTricks==selected}) {
                    let raw=(record.value*(mode == .speed ? 10:1)).rounded()
                    guard raw>=0,raw<=Double(Int32.max) else {throw ProgressError.invalidArchive};prefs[key]=Int64(raw)
                }
            }
        }
        let dayParser=DateFormatter();dayParser.locale=Locale(identifier:"en_US_POSIX");dayParser.calendar=Calendar(identifier:.gregorian);dayParser.dateFormat="yyyy-MM-dd";dayParser.isLenient=false
        if let day=state.daily.dayKey,let date=dayParser.date(from:day) {prefs["preference_set_day_streak_date"]=Int64(date.timeIntervalSince1970*1000)}
        dayParser.timeZone=TimeZone(secondsFromGMT:0)
        for (key,day) in [("streak_pending_day",state.daily.pendingDay),("streak_ended_day",state.daily.endedDay),("streak_shield_used_day",state.daily.shieldUsedDay)] {
            prefs[key]=day.flatMap{dayParser.date(from:$0)}.map{Int64($0.timeIntervalSince1970/86400)} ?? 0
        }
        tables["cloud_progress_prefs"]=prefs.sorted{$0.key<$1.key}.map{["key":.text($0.key),"value":.number($0.value)]}
        let formatter=DateFormatter();formatter.locale=Locale(identifier:"en_US_POSIX");formatter.calendar=Calendar(identifier:.gregorian);formatter.dateFormat="yyyy.MM.dd - HH:mm:ss.SSS"
        func stableID(_ source:String)->String {SHA256.hash(data:Data(source.utf8)).prefix(16).map{String(format:"%02x",$0)}.joined()}
        var graphs=tables["graph"] ?? []
        var graphIDs=Set(graphs.compactMap{$0["cloud_id"]?.string})
        let graphModes:[GameMode:Int64]=[.single:1,.minute:2,.speed:3,.noTime:4]
        for point in historicalGraphs where point.mode != .daily {
            guard let mode=point.mode,let graph=graphModes[mode],let value=point.value,value>=0,let date=point.dateText else {continue}
            let original=point.sourceID.hasPrefix("android/") ? String(point.sourceID.dropFirst(8)):stableID(point.sourceID)
            if graphIDs.insert(original).inserted {graphs.append(["id_graph":.number(graph),"value":.text(String(value)),"date":.text(date),"cloud_id":.text(original),"series_start":.number(0),"series_count":.number(0),"daily_target":.number(0)])}
        }
        for session in sessions where session.hasGraphResult && !session.configuration.selectedTricks {
            guard let graph=graphModes[session.configuration.mode] else {continue}
            let id=stableID("ios-session/"+session.id)
            if graphIDs.insert(id).inserted {graphs.append(["id_graph":.number(graph),"value":.text(String(session.resultValue)),"date":.text(formatter.string(from:session.startedAt)),"cloud_id":.text(id),"series_start":.number(0),"series_count":.number(0),"daily_target":.number(0)])}
        }
        for point in state.dailyHistory ?? [] {
            guard point.streak <= Int32.max, point.solved <= Int32.max else { throw ProgressError.invalidArchive }
            let id=stableID("ios-day/"+point.dayKey)
            let inferredStart = DailyProgressEngine.dayNumber(point.dayKey).map { max(0, $0 - Int(point.streak) + 1) } ?? 0
            let start = point.streak > 0 ? point.seriesStartDay ?? inferredStart : 0
            if graphIDs.insert(id).inserted {
                graphs.append(["id_graph":.number(5),"value":.text(String(point.solved)),"date":.text(point.dayKey.replacingOccurrences(of:"-",with:".")),"cloud_id":.text(id),"series_start":.number(Int64(start)),"series_count":.number(point.streak),"daily_target":.number(Int64(point.target))])
            }
        }
        guard graphs.allSatisfy({row in guard let text=row["value"]?.string,let value=Double(text) else{return false};return value.isFinite && value>=0 && value<=Double(Int32.max)}) else {throw ProgressError.invalidArchive}
        tables["graph"]=graphs
        let statistics=try PracticeStatistics(sessions:sessions,multiplayer:multiplayer,legacyGraphs:[],baseline:state.statisticsBaseline ?? [:])
        func input(_ mode:GameInputMode)->Int64 {mode == .digits ? 0:mode == .choices ? 4:2}
        func milliseconds(_ seconds:Double)throws->Int64 {let value=(seconds*1000).rounded(.down);guard value.isFinite,value>=0,value<=1_000_000_000_000_000 else {throw ProgressError.invalidArchive};return Int64(value)}
        func exampleID(_ row:Row)->String { (row["expression"]?.string ?? "")+"/\(row["input_mode"]?.integer ?? -1)" }
        var exampleRecords=Dictionary(uniqueKeysWithValues:(tables["game_example_records"] ?? []).map{(exampleID($0),$0)})
        func trickID(_ row:Row)->String {"\(row["trick"]?.integer ?? 0)/\(row["level"]?.integer ?? 0)/\(row["input_mode"]?.integer ?? -1)"}
        var trickRecords=Dictionary(uniqueKeysWithValues:(tables["game_trick_records"] ?? []).map{(trickID($0),$0)})
        var groups=Dictionary(uniqueKeysWithValues:(tables["game_trick_groups"] ?? []).map{(trickID($0),$0)})
        let sourceGroupKeys=Set(groups.keys)
        for original in trickRecords.values {
            var item=original;let level=original["level"]?.integer ?? 1;item["level"] = .number((level-1)/10*10+1)
            let key=trickID(item)
            if sourceGroupKeys.contains(key) {continue}
            if var group=groups[key] {
                for column in ["attempts","solved","clean","errors","hints","skipped","total_time","clean_time"] {group[column] = .number(try add(group[column]?.integer ?? 0,item[column]?.integer ?? 0))}
                let times=[group["best_time"]?.integer,item["best_time"]?.integer].compactMap{$0}.filter{$0>0};group["best_time"] = .number(times.min() ?? -1);groups[key]=group
            } else {item["first_time"] = .number(-1);groups[key]=item}
        }
        func accumulate(_ existing:Row?,seed:Row,attempt a:ExampleAttempt,elapsed:Int64,clean:Bool)throws->Row {
            var row=existing ?? seed
            for (column,delta) in [("attempts",Int64(1)),("solved",a.outcome == .solved ? 1:0),("clean",clean ? 1:0),("errors",Int64(a.errors+a.corrections)),("hints",Int64(a.hints)),("skipped",a.outcome == .skipped ? 1:0),("total_time",elapsed),("clean_time",clean ? elapsed:0)] {row[column] = .number(try add(row[column]?.integer ?? 0,delta))}
            if clean {
                if (row["first_time"]?.integer ?? -1)<=0 {row["first_time"] = .number(elapsed)}
                row["best_time"] = .number(min(row["best_time"]?.integer.flatMap{$0>0 ? $0:nil} ?? elapsed,elapsed))
            }
            if row["first_time"]==nil {row["first_time"] = .number(-1)}
            if row["best_time"]==nil {row["best_time"] = .number(-1)}
            return row
        }
        for entry in statistics.entries.sorted(by:{$0.startedAt==$1.startedAt ? $0.attempt.ordinal<$1.attempt.ordinal:$0.startedAt<$1.startedAt}) where entry.mode != .byHeart {
            let a=entry.attempt;let elapsed=max(0,try milliseconds(a.elapsed));let clean=a.eligible && elapsed>0
            let expression=PracticeStatistics.expressionKey(a.example),method=input(a.inputMode)
            if clean {
                let key=expression+"/\(method)"
                var row=exampleRecords[key] ?? ["expression":.text(expression),"input_mode":.number(method),"first_time":.number(elapsed),"best_time":.number(elapsed)]
                row["best_time"] = .number(min(row["best_time"]?.integer.flatMap{$0>0 ? $0:nil} ?? elapsed,elapsed));exampleRecords[key]=row
            }
            var row:Row=["trick":.number(Int64(a.example.trickID)),"level":.number(Int64(a.level)),"input_mode":.number(method)]
            let key=trickID(row)
            trickRecords[key]=try accumulate(trickRecords[key],seed:row,attempt:a,elapsed:elapsed,clean:clean)
            row["level"] = .number(Int64((a.level-1)/10*10+1))
            let groupKey=trickID(row)
            groups[groupKey]=try accumulate(groups[groupKey],seed:row,attempt:a,elapsed:elapsed,clean:clean)

        }
        tables["game_example_records"]=exampleRecords.sorted{$0.key<$1.key}.map(\.value)
        tables["game_trick_records"]=trickRecords.sorted{$0.key<$1.key}.map(\.value)
        tables["game_trick_groups"]=groups.sorted{$0.key<$1.key}.map(\.value)
        // Keep imported summaries and project actual iOS training measurements into
        // the dedicated cross-platform metric table.
        func metricID(_ row:Row)->String {"\(row["trick"]?.integer ?? 0)/\(row["level"]?.integer ?? 0)"}
        var metrics=Dictionary(uniqueKeysWithValues:(tables["cloud_level_metrics"] ?? []).map{(metricID($0),$0)})
        for session in sessions.sorted(by:{$0.startedAt<$1.startedAt}) where session.configuration.mode == .training && session.completed {
            let total=session.attempts.reduce(0){$0+$1.elapsed};let average=try session.levelMeasurements.average.map{try milliseconds($0)} ?? -1
            let row:Row=["trick":.number(Int64(session.configuration.trickIDs[0])),"level":.number(Int64(session.configuration.difficulty)),"errors":.number(Int64(session.attempts.filter{$0.errors+$0.corrections>0}.count)),"average":.number(average),"total":.number(try milliseconds(total)),"updated_at":.number(Int64(session.startedAt.timeIntervalSince1970*1000))]
            if (metrics[metricID(row)]?["updated_at"]?.integer ?? 0) <= (row["updated_at"]?.integer ?? 0) { metrics[metricID(row)]=row }
        }
        tables["cloud_level_metrics"]=metrics.sorted{$0.key<$1.key}.map(\.value)
        func levelID(_ row:Row)->String {"\(row["mode"]?.integer ?? 0)/\(row["scope"]?.integer ?? -1)/\(row["level"]?.integer ?? 1)"}
        var summaries=Dictionary(uniqueKeysWithValues:(tables["game_level_records"] ?? []).map{(levelID($0),$0)})
        let modes:[GameMode:Int64]=[.single:0,.minute:1,.speed:2,.noTime:3,.training:4]
        for session in sessions.sorted(by:{$0.startedAt<$1.startedAt}) where session.phase == .finished && !session.configuration.selectedTricks {
            guard let mode=modes[session.configuration.mode] else {continue}
            let scope:Int64=mode==4 ? Int64(session.configuration.trickIDs[0]):-1
            let correct=session.attempts.filter(\.independent)
            let eligible=session.attempts.filter(\.eligible)
            let total=try milliseconds(session.attempts.reduce(0){$0+$1.elapsed})
            let average=correct.isEmpty ? -1:try milliseconds(correct.reduce(0){$0+$1.elapsed}/Double(correct.count))
            let independentAverage=eligible.isEmpty ? -1:try milliseconds(eligible.reduce(0){$0+$1.elapsed}/Double(eligible.count))
            let score=mode==2 ? Int64((session.resultValue*10).rounded()):session.score
            guard score<=Int32.max else {throw ProgressError.invalidArchive}
            let stars:Int64=mode==4 ? Int64(session.stars):0
            // Only known configuration fields are encoded; no keyboard/speech history is invented.
            let configuration="ios-v1:\(session.configuration.exampleCount):\(session.configuration.inputMode?.rawValue ?? 0)"
            let result:[String:Any]=["id":session.id,"owner":"","mode":mode,"scope":scope,"level":session.configuration.difficulty,"configuration":configuration,"created":Int64(session.startedAt.timeIntervalSince1970*1000),"finished":true,"enhanced":true,"score":score,"stars":stars,"penaltyTime":try milliseconds(session.penaltyTime),"completedAt":0,"errorExamples":session.attempts.filter{$0.errors+$0.corrections>0}.count,"recordedEntries":session.attempts.count,"correct":correct.count,"questions":mode==4 ? session.configuration.exampleCount:session.attempts.count,"total":total,"average":average,"solved":session.solved,"independent":eligible.count,"independentAverage":independentAverage]
            let raw=try JSONSerialization.data(withJSONObject:result,options:[.sortedKeys])
            guard let payload=String(data:raw,encoding:.utf8) else {throw ProgressError.invalidArchive}
            var row:Row=["mode":.number(mode),"scope":.number(scope),"level":.number(Int64(session.configuration.difficulty))]
            let key=levelID(row)
            if let old=summaries[key] {row=old}
            if row["first_result"]==nil {row["first_result"] = .text(payload)}
            row["last_result"] = .text(payload)
            row["best_score"] = .number(row["best_score"]?.integer.map{mode==2 ? min($0,score):max($0,score)} ?? score)
            row["best_stars"] = .number(max(row["best_stars"]?.integer ?? 0,stars))
            row["best_correct"] = .number(max(row["best_correct"]?.integer ?? 0,Int64(correct.count)))
            row["best_average"] = .number([row["best_average"]?.integer,average].compactMap{$0}.filter{$0>=0}.min() ?? -1)
            row["best_total"] = .number(min(row["best_total"]?.integer ?? total,total))
            summaries[key]=row
        }
        tables["game_level_records"]=summaries.sorted{$0.key<$1.key}.map(\.value)
        let converted=AndroidProgressArchive(format:"math-tricks-progress",version:5,createdAt:Int64(exportedAt.timeIntervalSince1970*1000),tables:AndroidProgressArchive.schemas.map {name,columns in
            AndroidProgressArchive.Table(name:name,columns:columns,rows:(tables[name] ?? []).map{row in columns.map{row[$0] ?? .null}})
        })
        try converted.validate()
        return try ArchiveGzip.compress(JSONEncoder().encode(converted))
    }
}
