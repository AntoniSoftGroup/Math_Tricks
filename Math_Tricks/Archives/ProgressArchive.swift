import Foundation

nonisolated struct ProgressArchive:Codable,Sendable {
    let androidBackup:AndroidProgressArchive?
    let format:String
    let version:Int
    let exportedAt:Date
    let bundleIdentifier:String
    let state:ProgressState
    let tricks:[TrickProgress]
    let levels:[LevelProgress]
    let sessions:[GameSession]
    let multiplayer:[MultiplayerSession]
    let historicalGraphs:[HistoricalGraphPoint]
    init(state:ProgressState,tricks:[TrickProgress],levels:[LevelProgress],sessions:[GameSession],multiplayer:[MultiplayerSession],historicalGraphs:[HistoricalGraphPoint],androidBackup:AndroidProgressArchive?=nil,exportedAt:Date=Date()){
        format="math-tricks-ios-progress";version=1;self.exportedAt=exportedAt;self.androidBackup=androidBackup;bundleIdentifier="com.antoni.mathtricks.free"
        self.state=state;self.tricks=tricks;self.levels=levels;self.sessions=sessions;self.multiplayer=multiplayer;self.historicalGraphs=historicalGraphs
    }
    static let maximumBytes=50*1024*1024
    static func decode(_ bytes:Data) throws -> ProgressArchive {
        guard bytes.count>0,bytes.count<=maximumBytes else{throw ProgressError.invalidArchive}
        let value=try JSONDecoder().decode(Self.self,from:bytes)
        try value.validate();return value
    }
    func encoded() throws ->Data {
        try validate();let encoder=JSONEncoder();encoder.outputFormatting=[.sortedKeys]
        let bytes=try encoder.encode(self)
        guard bytes.count<=Self.maximumBytes else{throw ProgressError.invalidArchive}
        return bytes
    }
    func validate() throws {
        try androidBackup?.validate()
        guard state.statisticsResetAt.map({ (0...4_102_444_800_000).contains($0) }) ?? true else { throw ProgressError.invalidArchive }
        guard format=="math-tricks-ios-progress",version==1,bundleIdentifier=="com.antoni.mathtricks.free",
              state.revision>=0,state.coins>=0,state.totalSolved>=0,state.currentLevel>0,state.maximumLevel>=state.currentLevel,
              state.selectedCurrentLevel.map({$0>0 && $0<=state.maximumLevel}) ?? true,
              state.playerOneWins>=0,state.playerTwoWins>=0,(5...35).contains(state.multiplayerLength),state.multiplayerLength.isMultiple(of:5),
              (80...200).contains(state.settings.fontSizePercent),(0...100).contains(state.settings.themeIntensity),
              state.daily.target>0,state.daily.target<=100,state.daily.solved>=0,state.daily.streak>=0,
              (0...6).contains(state.daily.insuranceProgress ?? 0),(0...1_000_000).contains(state.daily.readyInsurance ?? 0),
              tricks.count==TrickCatalog.shared.tricks.count,Set(tricks.map(\.id))==Set(TrickCatalog.shared.tricks.map(\.id)),
              levels.count<=13_000,Set(levels.map(\.key)).count==levels.count,sessions.count<=100_000,multiplayer.count<=100_000,
              Set(sessions.map(\.id)).count==sessions.count,Set(multiplayer.map(\.id)).count==multiplayer.count,
              historicalGraphs.count<=1_000_000,Set(historicalGraphs.map(\.sourceID)).count==historicalGraphs.count,
              exportedAt.timeIntervalSince1970 >= -2_208_988_800,exportedAt.timeIntervalSince1970 <= 253_402_300_799,
              state.jointRecord.map({$0>=0 && $0<=1_000_000_000_000_000}) ?? true else{throw ProgressError.invalidArchive}
        if let baseline = state.statisticsBaseline {
            guard baseline.count <= 300_000, baseline.allSatisfy({ !$0.key.isEmpty && $0.key.utf8.count <= 256 && (0...1_000_000).contains($0.value) }) else { throw ProgressError.invalidArchive }
        }
        for key in [state.daily.dayKey,state.daily.pendingDay,state.daily.endedDay,state.daily.shieldUsedDay].compactMap({$0}) {
            guard DailyProgressEngine.isValidDayKey(key) else { throw ProgressError.invalidArchive }
        }
        guard (0...1_000_000).contains(state.daily.pendingCost ?? 0), (state.daily.pendingStreak ?? 0)>=0,
              (state.daily.pendingStreak ?? 0)<Int64.max/2, (state.dailyHistory?.count ?? 0)<=1_000_000 else { throw ProgressError.invalidArchive }
        if let history=state.dailyHistory {
            guard Set(history.map(\.dayKey)).count==history.count else { throw ProgressError.invalidArchive }
            for point in history {
                guard DailyProgressEngine.isValidDayKey(point.dayKey),point.solved>=0,(1...100).contains(point.target),point.streak>=0 else { throw ProgressError.invalidArchive }
            }
        }
        guard state.daily.seriesStartDay.map({ (1...2_932_896).contains($0) }) ?? true else { throw ProgressError.invalidArchive }
        for point in state.dailyHistory ?? [] {
            guard point.seriesStartDay.map({ (1...2_932_896).contains($0) }) ?? true else { throw ProgressError.invalidArchive }
        }
        for point in historicalGraphs {
            guard point.seriesStartDay.map({ (0...2_932_896).contains($0) }) ?? true,
                  point.seriesCount.map({ (0...Int64(Int32.max)).contains($0) }) ?? true,
                  point.dailyTarget.map({ (0...100).contains($0) }) ?? true else { throw ProgressError.invalidArchive }
        }
        for color in [state.settings.accentColorHex,state.settings.themeBaseColorHex].compactMap({$0}) {
            guard color.count==6,color.allSatisfy({$0.isASCII && $0.isHexDigit}) else{throw ProgressError.invalidArchive}
        }
        for (key,value) in state.settings.themeIntensities{guard Int(key).flatMap(AppTheme.init(rawValue:)) != nil,(0...100).contains(value) else{throw ProgressError.invalidArchive}}
        if let flow=state.settings.onboarding{guard flow.phase == .complete,flow.age.map({(0...99).contains($0)}) ?? true,flow.declaredAgeRange?.isValid ?? true else{throw ProgressError.invalidArchive}}
        if let voice=state.settings.speechMode{guard (0...2).contains(voice) else{throw ProgressError.invalidArchive}}
        if let count=state.settings.trainingExampleCount{guard (10...50).contains(count),count.isMultiple(of:10) else{throw ProgressError.invalidArchive}}
        if let reminder=state.settings.dailyReminder{guard (0...23).contains(reminder.hour),(0...59).contains(reminder.minute),(1...100).contains(reminder.difficulty) else{throw ProgressError.invalidArchive}}
        for level in levels{try level.key.validate();try level.measurements?.validate();guard level.bestScore>=0,(0...3).contains(level.bestStars),level.key.scope != .trick || TrickCatalog.shared.trick(level.key.parentID) != nil else{throw ProgressError.invalidArchive}}
        for record in state.records{guard record.value.isFinite,record.value>=0,[.single,.minute,.speed,.noTime].contains(record.mode),record.unit == (record.mode == .speed ? .seconds : .points) else{throw ProgressError.invalidArchive}}
        for session in sessions{try Self.validate(session)}
        for match in multiplayer{try match.configuration.validate();guard !match.id.isEmpty,match.id.utf8.count<=128,!match.id.contains("\0"),match.sequence<Int64.max/2,(-match.configuration.length-2...match.configuration.length+2).contains(match.balance),match.startedAt.timeIntervalSince1970 >= -2_208_988_800,match.startedAt.timeIntervalSince1970 <= 253_402_300_799, match.players.count==2,match.sequence>=0,(5...35).contains(match.configuration.length),match.configuration.length.isMultiple(of:5),match.points.count==2,match.points.allSatisfy({$0>=0 && $0<=1_000_000_000_000_000}),match.winner.map({$0==1 || $0==2}) ?? true,match.sharedElapsed.isFinite,match.sharedElapsed>=0 else{throw ProgressError.invalidArchive};for player in match.players{try Self.validate(player)}}
        for point in historicalGraphs{guard point.sourceID.utf8.count<=2048,point.dateText.map({$0.utf8.count<=256}) ?? true, point.value.map(\.isFinite) ?? true,!point.sourceID.isEmpty else{throw ProgressError.invalidArchive}}
    }
    private static func validate(_ session:GameSession) throws {
        try session.validateSavedState()
    }
}
