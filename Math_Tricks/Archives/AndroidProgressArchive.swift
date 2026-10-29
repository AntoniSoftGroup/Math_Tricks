import Foundation

/// Original Android v5 tables are retained alongside the native projection.
/// Aggregate records are never expanded into invented individual attempts.
nonisolated struct AndroidProgressArchive:Codable,Sendable {
    enum Value:Codable,Sendable,Equatable {
        case number(Int64),text(String),null
        init(from decoder:Decoder) throws {
            let value=try decoder.singleValueContainer()
            if value.decodeNil(){self = .null}
            else if let n=try? value.decode(Int64.self){self = .number(n)}
            else {self = .text(try value.decode(String.self))}
        }
        func encode(to encoder:Encoder) throws {
            var value=encoder.singleValueContainer()
            switch self {case .number(let n):try value.encode(n);case .text(let s):try value.encode(s);case .null:try value.encodeNil()}
        }
        var integer:Int64?{if case .number(let n)=self{return n};return nil}
        var string:String?{if case .text(let s)=self{return s};return nil}
    }
    struct Table:Codable,Sendable {
        let name:String
        let columns:[String]
        var rows:[[Value]]
        func dictionaries()->[[String:Value]]{rows.map{Dictionary(uniqueKeysWithValues:zip(columns,$0))}}
    }
    private struct LevelSummary:Decodable {let errorExamples:Int64?;let average:Int64?;let total:Int64?}
    let format:String
    let version:Int
    let createdAt:Int64
    let tables:[Table]
    static let schemas:[(String,[String])]=[
        ("Levels",["_idTricks","name","rating","score","satus"]),
        ("byHeartLevels",["_idByHeart","name","rating","score","satus"]),
        ("byHeart",["_id","name","satus"]),
        ("cloud_progress_prefs",["key","value"]),("cloud_coin_unlocks",["id"]),
        ("graph",["id_graph","value","date","cloud_id","series_start","series_count","daily_target"]),
        ("game_example_records",["expression","input_mode","first_time","best_time"]),
        ("game_trick_records",["trick","level","input_mode","first_time","best_time","attempts","solved","clean","errors","hints","skipped","total_time","clean_time"]),
        ("game_level_records",["mode","scope","level","first_result","last_result","best_score","best_stars","best_correct","best_average","best_total"]),
        ("cloud_level_metrics",["trick","level","errors","average","total","updated_at"]),
        ("game_trick_groups",["trick","level","input_mode","first_time","best_time","attempts","solved","clean","errors","hints","skipped","total_time","clean_time"])
    ]
    static func decode(_ bytes:Data)throws->Self {
        let raw=bytes.starts(with:[0x1f,0x8b]) ? try ArchiveGzip.decompress(bytes):bytes
        let archive=try JSONDecoder().decode(Self.self,from:raw);try archive.validate();return archive
    }
    func rows(_ table:String)->[[String:Value]]{tables.first{$0.name==table}?.dictionaries() ?? []}
    func validate()throws {
        guard format=="math-tricks-progress",version==5,createdAt>=0,createdAt<=253_402_300_799_000,tables.count==Self.schemas.count else {throw ProgressError.invalidArchive}
        for (table,schema) in zip(tables,Self.schemas) {
            guard table.name==schema.0,Set(table.columns)==Set(schema.1),table.columns.count==schema.1.count,table.rows.count<=1_000_000 else {throw ProgressError.invalidArchive}
            for row in table.rows {
                guard row.count==table.columns.count else {throw ProgressError.invalidArchive}
                for (column,item) in zip(table.columns,row) {
                    switch item {
                    case .number(let n):guard n<=1_000_000_000_000_000,(n>=(-1) || (n == -2 && table.name=="game_level_records" && column=="scope")) else {throw ProgressError.invalidArchive}
                    case .text(let s):guard s.utf8.count<=262_144,!s.contains("\0") else {throw ProgressError.invalidArchive}
                    case .null:break
                    }
                }
            }
        }
        _ = try practiceRecords()
        _ = try preferences()
        // Validate keys before constructing dictionaries or making any persistent changes.
        let keys:[String:[String]]=["Levels":["_idTricks","name"],"byHeartLevels":["_idByHeart","name"],"byHeart":["_id"],"cloud_progress_prefs":["key"],"cloud_coin_unlocks":["id"],"graph":["cloud_id"],"game_example_records":["expression","input_mode"],"game_trick_records":["trick","level","input_mode"],"game_trick_groups":["trick","level","input_mode"],"game_level_records":["mode","scope","level"],"cloud_level_metrics":["trick","level"]]
        for table in tables {
            var identities=Set<Data>()
            for row in table.dictionaries() {
                let values=try (keys[table.name] ?? []).map {key->Value in guard let value=row[key],value != .null else {throw ProgressError.invalidArchive};return value}
                guard identities.insert(try JSONEncoder().encode(values)).inserted else {throw ProgressError.invalidArchive}
                if table.name=="game_example_records" || table.name=="game_trick_records" || table.name=="game_trick_groups" {
                    guard let input=row["input_mode"]?.integer,[-1,0,2,4].contains(input) else {throw ProgressError.invalidArchive}
                    if table.name != "game_example_records" {
                        guard let id=row["trick"]?.integer,TrickCatalog.shared.trick(Int(id)) != nil,let level=row["level"]?.integer,(1...Int64(GameDifficulty.maximum)).contains(level) else {throw ProgressError.invalidArchive}
                    } else {guard row["expression"]?.string?.isEmpty==false else {throw ProgressError.invalidArchive}}
                }
                if table.name=="game_level_records" {
                    for key in ["first_result","last_result"] {
                        guard let text=row[key]?.string,let raw=text.data(using:.utf8),let object=try JSONSerialization.jsonObject(with:raw) as? [String:Any],(object["owner"] as? String ?? "").isEmpty else {throw ProgressError.invalidArchive}
                    }
                }
            }
        }
    }
    func nativeArchive(settings:AppSettings,notificationsEnabled:Bool?,selectedTricks:Set<Int>)throws->ProgressArchive {
        try validate()
        let prefs=try preferences()
        var state=ProgressState(legacy:try LegacyPreferences(domain:[:]))
        state.settings=settings;state.settings.onboarding?.phase = .complete
        state.coins=prefs["preference_tricks_count"] ?? 500
        state.totalSolved=prefs["preference_ex_per_day_total_solved"] ?? 0
        state.statisticsResetAt=prefs["statistics_reset_at"]
        state.maximumLevel=prefs["preference_game_type_level_max"] ?? 5
        state.currentLevel=max(1,prefs["preference_game_type_level"] ?? 1)
        state.selectedCurrentLevel=max(1,prefs["preference_training_level"] ?? 1)
        state.playerOneWins=prefs["preference_rtm_count_victory"] ?? 0;state.playerTwoWins=prefs["preference_rtm_count_defeat"] ?? 0
        state.jointRecord=prefs["preference_score_max_timewise"]
        state.records=[]
        for (mode,suffix) in [(GameMode.single,""),(.minute,"_minute"),(.speed,"_time"),(.noTime,"_not_time")] {
            for selected in [false,true] {
                let key="preference_score_max"+(selected ? "_selection":"")+suffix
                if let raw=prefs[key],raw>=0,mode != .speed || (raw>0 && raw<Int32.max) {
                    state.records.append(GameRecord(mode:mode,selectedTricks:selected,value:Double(raw)/(mode == .speed ? 10:1),unit:mode == .speed ? .seconds:.points))
                }
            }
        }
        let unlocked=try Set(rows("cloud_coin_unlocks").map {row->Int in guard let id=row["id"]?.integer,TrickCatalog.shared.trick(Int(id)) != nil else {throw ProgressError.invalidArchive};return Int(id)})
        let tricks=TrickCatalog.shared.tricks.map{TrickProgress(id:$0.id,selected:selectedTricks.contains($0.id),unlocked:$0.initiallyUnlocked || unlocked.contains($0.id))}
        var levels:[LevelProgress]=[]
        for (table,parent,scope) in [("Levels","_idTricks",LevelKey.Scope.trick),("byHeartLevels","_idByHeart",.multiplication)] {
            for row in rows(table) {
                guard let id=row[parent]?.integer,let number=row["name"]?.integer,let rating=row["rating"]?.integer,let score=row["score"]?.integer,let status=row["satus"]?.integer,(0...3).contains(rating),score>=0,[0,1].contains(status) else {throw ProgressError.invalidArchive}
                let key=LevelKey(scope:scope,parentID:Int(id),level:Int(number));try key.validate()
                levels.append(LevelProgress(key:key,bestScore:score,bestStars:rating,unlocked:status==1))
            }
        }
        var measurements:[LevelKey:LevelMeasurements]=[:]
        for row in rows("game_level_records") where row["mode"]?.integer==4 {
            guard let parent=row["scope"]?.integer,let number=row["level"]?.integer,let text=row["last_result"]?.string,let raw=text.data(using:.utf8) else {throw ProgressError.invalidArchive}
            let summary=try JSONDecoder().decode(LevelSummary.self,from:raw)
            let key=LevelKey(scope:.trick,parentID:Int(parent),level:Int(number))
            if parent>0 {
                measurements[key]=LevelMeasurements(errors:summary.errorExamples.flatMap{$0>=0 ? Int($0):nil},average:summary.average.flatMap{$0>=0 ? Double($0)/1000:nil},total:summary.total.flatMap{$0>=0 ? Double($0)/1000:nil})
            }
        }
        for row in rows("cloud_level_metrics") {
            guard let parent=row["trick"]?.integer,let number=row["level"]?.integer,let errors=row["errors"]?.integer,let average=row["average"]?.integer,let total=row["total"]?.integer else {throw ProgressError.invalidArchive}
            let key=LevelKey(scope:.trick,parentID:Int(parent),level:Int(number));try key.validate()
            measurements[key]=LevelMeasurements(errors:errors>=0 ? Int(errors):nil,average:average>=0 ? Double(average)/1000:nil,total:total>=0 ? Double(total)/1000:nil)
        }
        for index in levels.indices {levels[index].measurements=measurements[levels[index].key]}
        var daily=DailyProgress()
        daily.target=Int(prefs["preference_ex_per_day_total"] ?? 5);daily.solved=prefs["preference_ex_per_day_today_new"] ?? 0
        daily.streak=prefs["preference_days_streak"] ?? 0;daily.insuranceProgress=Int(prefs["streak_shield_progress"] ?? 0)
        daily.readyInsurance=Int(prefs["streak_shield_ready"] ?? 0);daily.completedToday=prefs["preference_inc_day_streak_date"]==1
        daily.notificationsEnabled=notificationsEnabled
        if let ms=prefs["preference_set_day_streak_date"],ms>0 {guard ms<=253_402_300_799_000 else {throw ProgressError.invalidArchive};daily.dayKey=DailyProgressEngine.dayKey(Date(timeIntervalSince1970:Double(ms)/1000))}
        daily.pendingStreak=prefs["streak_pending"];daily.pendingCost=prefs["streak_pending_cost"].map(Int.init)
        func key(_ days:Int64?)throws->String? {guard let days,days>0 else{return nil};guard days<=2_932_896 else {throw ProgressError.invalidArchive};return DailyProgressEngine.dayKey(Date(timeIntervalSince1970:Double(days)*86400),timeZone:TimeZone(secondsFromGMT:0)!)}
        daily.pendingDay=try key(prefs["streak_pending_day"]);daily.endedDay=try key(prefs["streak_ended_day"]);daily.shieldUsedDay=try key(prefs["streak_shield_used_day"])
        if let start = prefs["streak_series_start_day"], (1...2_932_896).contains(start) { daily.seriesStartDay = Int(start) }
        state.daily=daily
        var graphs:[HistoricalGraphPoint]=[]
        for row in rows("graph") {
            guard let id=row["cloud_id"]?.string,id.count==32,id.allSatisfy({$0.isASCII && $0.isHexDigit}),let modeID=row["id_graph"]?.integer,(1...5).contains(modeID),let text=row["value"]?.string,let value=Double(text),value.isFinite,value>=0,value<=Double(Int32.max),let date=row["date"]?.string,date.utf8.count<=256 else {throw ProgressError.invalidArchive}
            let mode:[Int64:GameMode]=[1:.single,2:.minute,3:.speed,4:.noTime,5:.daily]
            graphs.append(HistoricalGraphPoint(sourceID:"android/"+id,mode:mode[modeID],originalModeID:modeID,dateText:date,originalScore:nil,value:value,unit:modeID==3 ? .seconds:.points,seriesStartDay:row["series_start"]?.integer.flatMap(Int.init(exactly:)),seriesCount:row["series_count"]?.integer,dailyTarget:row["daily_target"]?.integer.flatMap(Int.init(exactly:))))
        }
        let archive=ProgressArchive(state:state,tricks:tricks,levels:levels,sessions:[],multiplayer:[],historicalGraphs:graphs,androidBackup:self,exportedAt:Date(timeIntervalSince1970:Double(createdAt)/1000))
        try archive.validate();return archive
    }
    func preferences()throws->[String:Int64] {
        let allowed:Set<String>=["statistics_reset_at","preference_days_streak","preference_ex_per_day_today_new","preference_ex_per_day_total","preference_ex_per_day_total_solved","preference_inc_day_streak_date","preference_set_day_streak_date","streak_shield_ready","streak_shield_progress","streak_pending","streak_pending_day","streak_ended_day","streak_shield_used_day","streak_series_start_day","streak_pending_cost","preference_game_type_level","preference_training_level","preference_rtm_count_victory","preference_rtm_count_defeat","preference_score_max","preference_score_max_minute","preference_score_max_time","preference_score_max_not_time","preference_score_max_selection","preference_score_max_selection_minute","preference_score_max_selection_time","preference_score_max_selection_not_time","preference_score_max_timewise","preference_game_type_level_max","preference_tricks_count"]
        var result:[String:Int64]=[:]
        for row in rows("cloud_progress_prefs") {
            guard let key=row["key"]?.string,allowed.contains(key),let value=row["value"]?.integer,value>=(-1) else {throw ProgressError.invalidArchive}
            if value>=0 {result[key]=value}
        }
        return result
    }
}
