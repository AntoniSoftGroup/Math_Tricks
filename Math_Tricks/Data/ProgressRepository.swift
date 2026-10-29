import Foundation
import CryptoKit

actor ProgressRepository {
    private var database: ProgressDatabase?
    private var state: ProgressState?
    private var legacyIndex: LegacyProgressIndex?
    private var sourceIdentifier: String?

    func open(legacy: LegacyProgressSnapshot) throws -> ProgressState {
        if let state {
            guard sourceIdentifier == legacy.storeIdentifier else { throw ProgressError.differentLegacyStore }
            return state
        }
        let url = legacy.storeURL.deletingLastPathComponent()
            .appendingPathComponent("MathTricksProgress", isDirectory: true).appendingPathComponent("Progress.sqlite")
        let candidate = try ProgressDatabase(url: url)
        guard let version = try candidate.query("PRAGMA user_version").first?.first?.integer else {
            throw ProgressError.invalidState
        }
        guard (0...4).contains(version) else { throw ProgressError.unsupportedVersion(version) }
        if version == 0 {
            guard try candidate.query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'").isEmpty else {
                throw ProgressError.invalidState
            }
        }
        try candidate.configureDurability()
        let initial = try candidate.transaction {
            if version < 2 {
                try candidate.execute("CREATE TABLE game_sessions (id TEXT PRIMARY KEY, sequence INTEGER NOT NULL, terminal INTEGER NOT NULL, started_at REAL NOT NULL, payload BLOB NOT NULL)")
                try candidate.execute("PRAGMA user_version = 4")
            }
            if version < 3 {
                try candidate.execute("CREATE TABLE multiplayer_sessions (id TEXT PRIMARY KEY, sequence INTEGER NOT NULL, terminal INTEGER NOT NULL, started_at INTEGER NOT NULL, payload BLOB NOT NULL)")
                try candidate.execute("PRAGMA user_version = 4")
            }
            if version < 4 {
                try candidate.execute("CREATE TABLE archived_graphs (id TEXT PRIMARY KEY,payload BLOB NOT NULL)")
                try candidate.execute("PRAGMA user_version = 4")
            }
            if version == 0 {
                try candidate.execute("CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)")
                try candidate.execute("CREATE TABLE app_state (id INTEGER PRIMARY KEY CHECK(id=1), payload BLOB NOT NULL)")
                try candidate.execute("CREATE TABLE trick_progress (id INTEGER PRIMARY KEY CHECK(id>0), selected INTEGER CHECK(selected IN (0,1)), unlocked INTEGER CHECK(unlocked IN (0,1)))")
                try candidate.execute("CREATE TABLE level_progress (scope TEXT NOT NULL, parent_id INTEGER NOT NULL, level INTEGER NOT NULL, payload BLOB NOT NULL, PRIMARY KEY(scope,parent_id,level))")
                try candidate.execute("CREATE TABLE operations (id TEXT PRIMARY KEY, request BLOB NOT NULL)")
                var imported = ProgressState(legacy: legacy.preferences)
                let returningUser = legacy.preferences.initializationVersion != nil
                    || legacy.preferences.storedKeys.contains(where: { $0.hasPrefix("DEFAULTS_") })
                    || !legacy.tricks.isEmpty || !legacy.trickLevels.isEmpty
                    || !legacy.multiplicationLevels.isEmpty || !legacy.graphs.isEmpty
                imported.settings.onboarding = OnboardingState(phase: returningUser ? .complete : .age)
                if !returningUser {
                    imported.settings.theme = .aurora
                    imported.settings.themeBaseColorHex = "0D47A1"
                    imported.settings.accentColorHex = "0D47A1"
                    imported.settings.themeIntensity = 40
                }
                try candidate.execute("INSERT INTO metadata(key,value) VALUES('original_store_uuid',?)", [.text(legacy.storeIdentifier)])
                try candidate.execute("INSERT INTO app_state(id,payload) VALUES(1,?)", [.blob(try Self.encode(imported))])
                try candidate.execute("PRAGMA user_version = 4")
                return imported
            }
            guard try candidate.query("SELECT value FROM metadata WHERE key='original_store_uuid'").first?.first?.text == legacy.storeIdentifier else {
                throw ProgressError.differentLegacyStore
            }
            guard let data = try candidate.query("SELECT payload FROM app_state WHERE id=1").first?.first?.data else {
                throw ProgressError.invalidState
            }
            let saved = try Self.decode(ProgressState.self, data)
            guard saved.revision >= 0 else { throw ProgressError.invalidState }
            return saved
        }
        let ignoreLegacy = try candidate.query("SELECT value FROM metadata WHERE key='ignore_legacy_progress'").first?.first?.text == "1"
        legacyIndex = ignoreLegacy ? LegacyProgressIndex() : LegacyProgressIndex(snapshot: legacy)
        sourceIdentifier = legacy.storeIdentifier
        database = candidate
        state = initial
        return initial
    }

    func updateSettings(_ change: SettingsChange) throws -> ProgressState {
        var next = try currentState()
        let before = next.settings
        switch change {
        case .speechMode(let mode):
            guard (0...2).contains(mode) else { throw ProgressError.invalidValue }; next.settings.speechMode = mode
        case .keypadOnRight(let right): next.settings.keypadOnRight = right
        case .graphSmoothed(let value): next.settings.graphSmoothed = value
        case .tricksCategoryColors(let value): next.settings.tricksCategoryColors = value
        case .gameInputMode(let mode): next.settings.gameInputMode = mode
        case .trainingExampleCount(let count):
            guard (10...50).contains(count), count.isMultiple(of: 10) else { throw ProgressError.invalidValue }
            next.settings.trainingExampleCount = count
        case .age(let age):
            guard age.map({ (0...99).contains($0) }) ?? true else { throw ProgressError.invalidValue }
            var flow = next.settings.onboarding ?? OnboardingState(phase: .complete)
            flow.age = age
            flow.ageChoiceMade = true
            if flow.phase == .age { flow.phase = .appearance }
            next.settings.onboarding = flow
        case .declaredAgeRange(let range):
            guard range.isValid else { throw ProgressError.invalidValue }
            var flow = next.settings.onboarding ?? OnboardingState(phase: .complete)
            flow.age = nil
            flow.declaredAgeRange = range
            flow.ageChoiceMade = true
            if flow.phase == .age { flow.phase = .appearance }
            next.settings.onboarding = flow
        case .sound(let enabled): next.settings.soundEnabled = enabled
        case .vibration(let enabled): next.settings.vibrationEnabled = enabled
        case .wrongAnswerSignal(let enabled): next.settings.signalWrongAnswer = enabled
        case .numpad123(let enabled): next.settings.numpad123 = enabled
        case .fontSize(let system, let percent):
            guard (80...200).contains(percent) else { throw ProgressError.invalidValue }
            next.settings.useSystemFontSize = system
            next.settings.fontSizePercent = percent
        case .appearance(let theme, let hex, let intensity, let baseHex, let intensities, let categoryColors, let gameCategoryColors, let fontPercent, let systemFont):
            guard (0...100).contains(intensity) else { throw ProgressError.invalidValue }
            if let hex {
                guard hex.count == 6, hex.allSatisfy({ $0.isASCII && $0.isHexDigit }) else { throw ProgressError.invalidValue }
            }
            if let baseHex {
                guard baseHex.count == 6, baseHex.allSatisfy({ $0.isASCII && $0.isHexDigit }) else { throw ProgressError.invalidValue }
            }
            if let intensities {
                guard intensities.allSatisfy({ entry in
                    guard let id = Int(entry.key), AppTheme(rawValue: id) != nil else { return false }
                    return (0...100).contains(entry.value)
                }) else { throw ProgressError.invalidValue }
                next.settings.themeIntensities.merge(intensities) { _, new in new }
            }
            next.settings.themeBaseColorHex = baseHex?.uppercased()
            next.settings.theme = theme
            next.settings.accentColorHex = hex?.uppercased()
            next.settings.themeIntensity = intensity
            if let categoryColors { next.settings.tricksCategoryColors = categoryColors }
            if let gameCategoryColors { next.settings.gameCategoryColors = gameCategoryColors }
            if let fontPercent {
                guard (80...200).contains(fontPercent) else { throw ProgressError.invalidValue }
                next.settings.fontSizePercent = fontPercent
            }
            if let systemFont { next.settings.useSystemFontSize = systemFont }
            next.settings.themeIntensities[String(theme.rawValue)] = intensity
            if var flow = next.settings.onboarding, flow.phase == .appearance {
                flow.phase = .complete
                next.settings.onboarding = flow
            }
        }
        guard next.settings != before else { return next }
        return try commit(next) { _ in }
    }

    func setCurrentLevel(_ level: Int64,selected:Bool=false) throws -> ProgressState {
        var next = try currentState()
        guard level > 0, level <= next.maximumLevel else { throw ProgressError.invalidValue }
        if selected {
            guard next.selectedCurrentLevel != level else{return next};next.selectedCurrentLevel=level
        } else {
            guard next.currentLevel != level else{return next};next.currentLevel=level
        }
        return try commit(next) { _ in }
    }

    func setMultiplayerLength(_ count: Int64) throws -> ProgressState {
        guard (5...35).contains(count), count.isMultiple(of: 5) else { throw ProgressError.invalidValue }
        var next = try currentState()
        guard next.multiplayerLength != count else { return next }
        next.multiplayerLength = count
        return try commit(next) { _ in }
    }

    func refreshDailyProgress(now: Date = Date()) throws -> ProgressState {
        var next = try currentState()
        let previous = next.daily, history = next.dailyHistory
        try DailyProgressEngine.advance(&next,now:now)
        guard previous != next.daily || history != next.dailyHistory else { return next }
        return try commit(next) { _ in }
    }
    func updateDailyOptions(_ change: DailyOptionsChange) throws -> ProgressState {
        var next = try currentState()
        try DailyProgressEngine.advance(&next,now:Date())
        var reminder = next.settings.dailyReminder ?? DailyReminderSettings()
        switch change {
        case .time(let hour,let minute):
            guard (0...23).contains(hour),(0...59).contains(minute) else { throw ProgressError.invalidValue }; reminder.hour=hour;reminder.minute=minute
        case .difficulty(let level):
            guard (Array(1...20)+Array(stride(from:25,through:100,by:5))).contains(level) else { throw ProgressError.invalidValue };reminder.difficulty=level
        case .target(let target):
            guard [1,2,3,4,5,10,20,30,40,50,75,100].contains(target) else { throw ProgressError.invalidValue };next.daily.target=target
        case .notifications(let enabled): next.daily.notificationsEnabled=enabled
        }
        next.settings.dailyReminder=reminder
        return try commit(next) { _ in }
    }

    func setDailyProgress(_ value: DailyProgress) throws -> ProgressState {
        guard value.target > 0, value.solved >= 0, value.streak >= 0 else { throw ProgressError.invalidValue }
        var next = try currentState()
        guard next.daily != value else { return next }
        next.daily = value
        return try commit(next) { _ in }
    }

    func setTrickSelected(_ id: Int, selected: Bool) throws -> ProgressState {
        guard id > 0 else { throw ProgressError.invalidValue }
        let next = try currentState()
        if try trickProgress(id)?.selected == selected { return next }
        return try commit(next) { database in
            try database.execute("INSERT INTO trick_progress(id,selected) VALUES(?,?) ON CONFLICT(id) DO UPDATE SET selected=excluded.selected",
                                 [.integer(Int64(id)), .integer(selected ? 1 : 0)])
        }
    }

    func trickProgress(_ id: Int) throws -> TrickProgress? {
        guard id > 0 else { throw ProgressError.invalidValue }
        let database = try currentDatabase()
        let base = legacyIndex?.tricks[id]
        guard let row = try database.query("SELECT selected,unlocked FROM trick_progress WHERE id=?", [.integer(Int64(id))]).first else {
            guard let trick = TrickCatalog.shared.trick(id) else { return base }
            return TrickProgress(id: id, selected: base?.selected ?? true, unlocked: (base?.unlocked ?? false) || trick.initiallyUnlocked)
        }
        func flag(_ column: Int, fallback: Bool) throws -> Bool {
            guard let value = row[column].integer else { return fallback }
            guard value == 0 || value == 1 else { throw ProgressError.invalidState }
            return value == 1
        }
        return try TrickProgress(id: id, selected: flag(0, fallback: base?.selected ?? true),
                                 unlocked: flag(1, fallback: (base?.unlocked ?? false) || TrickCatalog.shared.trick(id)?.initiallyUnlocked == true))
    }

    func catalogProgress() throws -> [TrickProgress] {
        try TrickCatalog.shared.tricks.compactMap { try trickProgress($0.id) }
    }

    func trainingCatalogProgress() throws -> TrainingCatalogProgress {
        let tricks = try catalogProgress()
        let completed = try allLevels(scope: .trick).filter { $0.bestScore > 0 && TrickCatalog.shared.trick($0.key.parentID) != nil }
        let counts = Dictionary(grouping: completed, by: { $0.key.parentID }).mapValues(\.count)
        return TrainingCatalogProgress(tricks: tricks, completedLevels: counts)
    }

    func setAllTricksSelected(_ selected: Bool) throws -> ProgressState {
        let next = try currentState()
        let ids = try catalogProgress().filter { $0.selected != selected }.map(\.id)
        guard !ids.isEmpty else { return next }
        return try commit(next) { database in
            for id in ids {
                try database.execute("INSERT INTO trick_progress(id,selected) VALUES(?,?) ON CONFLICT(id) DO UPDATE SET selected=excluded.selected",
                    [.integer(Int64(id)), .integer(selected ? 1 : 0)])
            }
        }
    }

    func unlockTrick(_ id: Int) throws -> ProgressState {
        guard TrickCatalog.shared.trick(id) != nil else { throw ProgressError.invalidValue }
        if try trickProgress(id)?.unlocked == true { return try currentState() }
        return try apply(ProgressOperation(id: "catalog-unlock/\(try currentState().generation ?? "original")/\(id)", coinDelta: -TrickCatalog.shared.unlockPrice, unlockTrickID: id))
    }

    func levelProgress(_ key: LevelKey) throws -> LevelProgress? {
        try key.validate()
        let database = try currentDatabase()
        let base = legacyIndex?.levels[key]
        guard let data = try database.query("SELECT payload FROM level_progress WHERE scope=? AND parent_id=? AND level=?", Self.bind(key)).first?.first?.data else { return base }
        let saved = try Self.decode(LevelProgress.self, data)
        guard saved.key == key else { throw ProgressError.invalidState }
        return LegacyProgressIndex.merge(base, saved)
    }

    func levels(scope: LevelKey.Scope, parentID: Int) throws -> [LevelProgress] {
        try LevelKey(scope: scope, parentID: parentID, level: 1).validate()
        let database = try currentDatabase()
        var keys = Set((legacyIndex?.levels.keys.filter { $0.scope == scope && $0.parentID == parentID }) ?? [])
        for row in try database.query("SELECT level FROM level_progress WHERE scope=? AND parent_id=?", [.text(scope.rawValue), .integer(Int64(parentID))]) {
            guard let raw = row.first?.integer, let number = Int(exactly: raw) else { throw ProgressError.invalidState }
            keys.insert(LevelKey(scope: scope, parentID: parentID, level: number))
        }
        return try keys.sorted { $0.level < $1.level }.compactMap { try levelProgress($0) }
    }

    func allLevels(scope: LevelKey.Scope) throws -> [LevelProgress] {
        let database = try currentDatabase()
        var values = legacyIndex?.levels.filter { $0.key.scope == scope } ?? [:]
        for row in try database.query("SELECT payload FROM level_progress WHERE scope=?", [.text(scope.rawValue)]) {
            guard let payload = row.first?.data else { throw ProgressError.invalidState }
            let level = try Self.decode(LevelProgress.self, payload)
            try level.key.validate()
            guard level.key.scope == scope else { throw ProgressError.invalidState }
            values[level.key] = LegacyProgressIndex.merge(values[level.key], level)
        }
        return values.values.sorted { $0.key.parentID == $1.key.parentID ? $0.key.level < $1.key.level : $0.key.parentID < $1.key.parentID }
    }

    func historicalGraphs() throws -> [HistoricalGraphPoint] {
        _ = try currentState()
        let stored: [HistoricalGraphPoint] = try currentDatabase().query("SELECT payload FROM archived_graphs ORDER BY rowid").map { row in
            guard let bytes=row.first?.data else{throw ProgressError.invalidState};return try Self.decode(HistoricalGraphPoint.self,bytes)
        }
        return (legacyIndex?.graphs ?? []) + stored
    }

    func apply(_ operation: ProgressOperation) throws -> ProgressState {
        try Self.validate(operation)
        let database = try currentDatabase()
        let request = try Self.encode(operation)
        // Retain an idempotency receipt, without copying the growing attempt
        // history into every previous receipt for this session.
        let receipt = Data("sha256:".utf8) + Data(SHA256.hash(data: request))
        if let previous = try database.query("SELECT request FROM operations WHERE id=?", [.text(operation.id)]).first?.first?.data {
            // Versions 1–4 originally stored the canonical request itself.
            guard previous == receipt || previous == request else { throw ProgressError.operationConflict }
            return try currentState()
        }
        var next = try currentState()
        // Choice penalties cannot turn an existing coin balance negative.
        let requestedCoins = try Self.add(next.coins, operation.coinDelta)
        next.coins = (operation.gameSession != nil || operation.multiplayerSession != nil) && operation.coinDelta < 0 ? max(0, requestedCoins) : requestedCoins
        guard next.coins >= 0 else { throw ProgressError.insufficientCoins }
        next.totalSolved = try Self.add(next.totalSolved, operation.solvedDelta)
        if operation.solvedDelta > 0 { try DailyProgressEngine.record(operation.solvedDelta,in:&next,now:Date()) }
        let winnerKey = operation.multiplayerSession.map { "multiplayer-winner/" + $0.id }
        let awardWinner = try winnerKey.map { try database.query("SELECT value FROM metadata WHERE key=?", [.text($0)]).isEmpty } ?? true
        if let joint = operation.jointScore { next.jointRecord = max(next.jointRecord ?? 0, joint) }
        if awardWinner, operation.playerWinner == 1 { next.playerOneWins = try Self.add(next.playerOneWins, 1) }
        if awardWinner, operation.playerWinner == 2 { next.playerTwoWins = try Self.add(next.playerTwoWins, 1) }
        if let level = operation.unlockDifficulty { next.maximumLevel = max(next.maximumLevel, level) }
        if let id = operation.unlockTrickID, operation.coinDelta < 0, try trickProgress(id)?.unlocked == true {
            throw ProgressError.alreadyUnlocked
        }
        if let record = operation.record {
            if let index = next.records.firstIndex(where: { $0.mode == record.mode && $0.selectedTricks == record.selectedTricks }) {
                let previous = next.records[index]
                if record.mode == .speed ? record.value < previous.value : record.value > previous.value { next.records[index] = record }
            } else { next.records.append(record) }
        }
        let level = try operation.level.map { LegacyProgressIndex.merge(try levelProgress($0.key), $0) }
        let nextLevel = try operation.nextLevel.map { LegacyProgressIndex.merge(try levelProgress($0.key), $0) }
        return try commit(next) { database in
            if let id = operation.unlockTrickID {
                try database.execute("INSERT INTO trick_progress(id,unlocked) VALUES(?,1) ON CONFLICT(id) DO UPDATE SET unlocked=1", [.integer(Int64(id))])
            }
            for level in [level, nextLevel].compactMap({ $0 }) {
                try database.execute("INSERT INTO level_progress(scope,parent_id,level,payload) VALUES(?,?,?,?) ON CONFLICT(scope,parent_id,level) DO UPDATE SET payload=excluded.payload",
                                     Self.bind(level.key) + [.blob(try Self.encode(level))])
            }
            if let session = operation.gameSession { try Self.writeSession(session, database: database) }
            if let session = operation.multiplayerSession { try Self.writeMultiplayer(session, database: database) }
            if awardWinner, operation.playerWinner != nil, let winnerKey {
                try database.execute("INSERT INTO metadata(key,value) VALUES(?,?)", [.text(winnerKey), .text(String(operation.playerWinner!))])
            }
            try database.execute("INSERT INTO operations(id,request) VALUES(?,?)", [.text(operation.id), .blob(receipt)])
        }
    }

    private func progressArchive() throws -> ProgressArchive {
        let statistics = try practiceStatistics()
        return try ProgressArchive(state:currentState(),tricks:catalogProgress(),levels:allLevels(scope:.trick)+allLevels(scope:.multiplication),sessions:statistics.sessions,multiplayer:statistics.multiplayerSessions,historicalGraphs:statistics.legacyGraphs,androidBackup:readAndroidArchive())
    }
    func exportProgressArchive(android:Bool=false) throws -> Data {
        let archive = try progressArchive()
        return try android ? archive.androidEncoded():archive.encoded()
    }
    func mergeCloudProgress(_ progress: CloudProgress, expectedRevision: Int64, cloudOwner: String) throws -> ProgressState {
        guard try currentState().revision == expectedRevision else { throw ProgressError.staleSession }
        // Read sessions and apply the merge on the same actor so a new game cannot be lost between awaits.
        let archive = try progress.archive(keeping:progressArchive())
        return try importProgressArchive(archive,expectedRevision:expectedRevision,cloudOwner:cloudOwner,preservingGeneration:true)
    }
    func previewProgressArchive(_ bytes:Data) throws -> ProgressArchive {
        do {
            if bytes.starts(with:[0x1f,0x8b]) {
                let state=try currentState()
                return try AndroidProgressArchive.decode(bytes).nativeArchive(settings:state.settings,notificationsEnabled:state.daily.notificationsEnabled,selectedTricks:Set(catalogProgress().filter(\.selected).map(\.id)))
            }
            return try ProgressArchive.decode(bytes)
        } catch {throw ProgressError.invalidArchive}
    }
    func importProgressArchive(_ archive:ProgressArchive,expectedRevision:Int64,cloudOwner:String?=nil,preservingGeneration:Bool=false) throws -> ProgressState {
        try archive.validate()
        let database=try currentDatabase()
        let previous=try currentState()
        guard previous.revision==expectedRevision else {throw ProgressError.staleSession}
        // Background merges keep one latest backup instead of growing a full database copy every sync.
        let backupName = cloudOwner == nil ? UUID().uuidString : "CloudLatest"
        let backup=database.url.deletingLastPathComponent().appendingPathComponent("BeforeImport",isDirectory:true).appendingPathComponent(backupName+".sqlite")
        try database.backup(to:backup)
        var next=archive.state
        next.revision=previous.revision;next.generation=preservingGeneration ? previous.generation ?? UUID().uuidString : UUID().uuidString
        // Age belongs to the current user, not the imported game progress.
        next.settings.onboarding=previous.settings.onboarding ?? OnboardingState(phase:.complete)
        next.settings.onboarding?.phase = .complete
        let generation=next.generation!
        let imported=try commit(next){database in
            if let cloudOwner { try database.execute("INSERT INTO metadata(key,value) VALUES('cloud_owner_uid',?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",[.text(cloudOwner)]) }
            for table in ["trick_progress","level_progress","game_sessions","multiplayer_sessions","archived_graphs"]{try database.execute("DELETE FROM "+table)}
            try database.execute("DELETE FROM metadata WHERE key='android_archive'")
            if let android=archive.androidBackup {try database.execute("INSERT INTO metadata(key,value) VALUES('android_archive',?)",[.blob(try Self.encode(android))])}
            for trick in archive.tricks{try database.execute("INSERT INTO trick_progress(id,selected,unlocked) VALUES(?,?,?)",[.integer(Int64(trick.id)),.integer(trick.selected ? 1 : 0),.integer(trick.unlocked ? 1 : 0)])}
            for level in archive.levels{try database.execute("INSERT INTO level_progress(scope,parent_id,level,payload) VALUES(?,?,?,?)",Self.bind(level.key)+[.blob(try Self.encode(level))])}
            for var session in archive.sessions{session.rebaseProgressGeneration(generation);try Self.writeSession(session,database:database)}
            for var session in archive.multiplayer{session.rebaseProgressGeneration(generation);try Self.writeMultiplayer(session,database:database)}
            for point in archive.historicalGraphs{try database.execute("INSERT INTO archived_graphs(id,payload) VALUES(?,?)",[.text(point.sourceID),.blob(try Self.encode(point))])}
            try database.execute("INSERT INTO metadata(key,value) VALUES('ignore_legacy_progress','1') ON CONFLICT(key) DO UPDATE SET value='1'")
            for session in archive.multiplayer where session.finished && session.winner != nil {
                try database.execute("INSERT INTO metadata(key,value) VALUES(?,?) ON CONFLICT(key) DO NOTHING",[.text("multiplayer-winner/"+session.id),.text(String(session.winner!))])
            }
        }
        legacyIndex=LegacyProgressIndex()
        return imported
    }

    func cloudOwner() throws -> String { try currentDatabase().query("SELECT value FROM metadata WHERE key='cloud_owner_uid'").first?.first?.text ?? "" }
    func setCloudOwner(_ uid: String) throws -> ProgressState {
        try commit(currentState()) { db in try db.execute("INSERT INTO metadata(key,value) VALUES('cloud_owner_uid',?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",[.text(uid)]) }
    }

    func resetLocalProgress() throws -> ProgressState {
        let database = try currentDatabase()
        let previous = try currentState()
        let backup = database.url.deletingLastPathComponent().appendingPathComponent("BeforeReset",isDirectory:true).appendingPathComponent(UUID().uuidString+".sqlite")
        try database.backup(to:backup)
        var next = ProgressState(legacy:try LegacyPreferences(domain:[:]))
        next.revision = previous.revision
        next.generation = UUID().uuidString
        next.coins = 0
        next.settings = previous.settings
        next.settings.onboarding?.phase = .complete
        next.multiplayerLength = previous.multiplayerLength
        next.daily.target = previous.daily.target
        next.daily.notificationsEnabled = previous.daily.notificationsEnabled
        let saved = try commit(next) { database in
            try database.execute("DELETE FROM metadata WHERE key='android_archive'")
            for table in ["trick_progress","level_progress","game_sessions","multiplayer_sessions","archived_graphs"] { try database.execute("DELETE FROM " + table) }
            try database.execute("INSERT INTO metadata(key,value) VALUES('ignore_legacy_progress','1') ON CONFLICT(key) DO UPDATE SET value='1'")
        }
        legacyIndex = LegacyProgressIndex()
        return saved
    }

    func clearPracticeStatistics() throws -> ProgressState {
        var next = try currentState()
        let statistics = try practiceStatistics()
        var baseline = next.statisticsBaseline ?? [:]
        for session in statistics.sessions { baseline[session.id] = session.attempts.count }
        // Child IDs keep each player's ordinal independent.
        for match in statistics.multiplayerSessions {
            for (index, player) in match.players.enumerated() { baseline[match.id + "/\(index)"] = player.attempts.count }
        }
        next.statisticsBaseline = baseline
        next.statisticsResetAt = Int64(Date().timeIntervalSince1970 * 1000)
        let archive = try readAndroidArchive().map { source in
            AndroidProgressArchive(format: source.format, version: source.version, createdAt: source.createdAt,
                tables: source.tables.map { table in
                    var table = table
                    if ["game_example_records", "game_trick_records", "game_trick_groups"].contains(table.name) { table.rows = [] }
                    return table
                })
        }
        return try commit(next) { database in
            if let archive {
                try database.execute("UPDATE metadata SET value=? WHERE key='android_archive'", [.blob(try Self.encode(archive))])
            }
        }
    }

    func resetGameRecord(_ mode: GameMode, selected: Bool) throws -> ProgressState {
        guard [.single, .minute, .speed, .noTime].contains(mode) else { throw ProgressError.invalidValue }
        var next = try currentState()
        next.records.removeAll { $0.mode == mode && $0.selectedTricks == selected }
        return try commit(next) { _ in }
    }

    func commitGameSession(_ session: GameSession, mutation: GameMutation) throws -> ProgressState {
        guard session.configuration.progressGeneration == (try currentState()).generation else { throw ProgressError.staleSession }
        var operation = ProgressOperation(id: "game/\(session.configuration.progressGeneration ?? "original")/\(session.id)/\(session.sequence)", coinDelta: mutation.coinDelta,
            solvedDelta: mutation.solvedDelta, unlockDifficulty: mutation.unlockDifficulty)
        operation.gameSession = session
        if session.phase == .finished {
            let mode = session.configuration.mode
            if [.single, .minute, .noTime].contains(mode) || mode == .speed && session.completed {
                operation.record = GameRecord(mode: mode, selectedTricks: session.configuration.selectedTricks,
                    value: session.resultValue, unit: mode == .speed ? .seconds : .points)
            }
            if session.completed, mode == .training || mode == .byHeart {
                let byHeart = mode == .byHeart
                let parent = byHeart ? session.configuration.multiplicationNumber! : session.configuration.trickIDs[0]
                let number = byHeart ? session.configuration.multiplicationLevel! : session.configuration.difficulty
                let scope: LevelKey.Scope = byHeart ? .multiplication : .trick
                operation.level = LevelProgress(key: LevelKey(scope: scope, parentID: parent, level: number),
                    bestScore: session.score, bestStars: Int64(session.stars), unlocked: true,measurements:session.levelMeasurements)
                if number < (byHeart ? 21 : 100) {
                    operation.nextLevel = LevelProgress(key: LevelKey(scope: scope, parentID: parent, level: number + 1), bestScore: 0, bestStars: 0, unlocked: true)
                }
            }
        }
        return try apply(operation)
    }

    func commitMultiplayerSession(_ session: MultiplayerSession, mutation: GameMutation) throws -> ProgressState {
        guard session.configuration.progressGeneration == (try currentState()).generation else { throw ProgressError.staleSession }
        var operation = ProgressOperation(id: "multiplayer/\(session.configuration.progressGeneration ?? "original")/\(session.id)/\(session.sequence)", coinDelta: mutation.coinDelta,
            solvedDelta: mutation.solvedDelta, playerWinner: session.finished ? session.winner : nil, unlockDifficulty: mutation.unlockDifficulty)
        operation.multiplayerSession = session
        if session.finished && session.configuration.kind == .cooperative { operation.jointScore = session.points.reduce(0,+) }
        return try apply(operation)
    }
    func saveMultiplayerSession(_ session: MultiplayerSession) throws {
        guard session.configuration.progressGeneration == (try currentState()).generation else { throw ProgressError.staleSession }
        let database = try currentDatabase()
        try database.transaction { try Self.writeMultiplayer(session, database: database) }
    }
    func resumableMultiplayerSession() throws -> MultiplayerSession? {
        guard let bytes = try currentDatabase().query("SELECT payload FROM multiplayer_sessions WHERE terminal=0 ORDER BY started_at DESC LIMIT 1").first?.first?.data else { return nil }
        var session = try Self.decode(MultiplayerSession.self,bytes); session.restorePaused(); return session
    }
    private func readAndroidArchive() throws -> AndroidProgressArchive? {
        let database=try currentDatabase()
        guard let bytes=try database.query("SELECT value FROM metadata WHERE key='android_archive'").first?.first?.data else {return nil}
        return try Self.decode(AndroidProgressArchive.self,bytes)
    }

    func practiceStatistics() throws -> PracticeStatistics {
        let database = try currentDatabase()
        let multiplayer: [MultiplayerSession] = try database.query("SELECT payload FROM multiplayer_sessions ORDER BY started_at DESC").map { row in
            guard let bytes = row.first?.data else { throw ProgressError.invalidState }
            return try Self.decode(MultiplayerSession.self,bytes)
        }
        return try PracticeStatistics(sessions: gameSessions(), multiplayer: multiplayer, legacyGraphs: historicalGraphs(),androidBackup:readAndroidArchive(),baseline:currentState().statisticsBaseline ?? [:])
    }

    private static func writeMultiplayer(_ session: MultiplayerSession, database: ProgressDatabase) throws {
        guard session.sequence >= 0, session.players.count == 2 else { throw ProgressError.invalidValue }
        for player in session.players { try player.configuration.validate() }
        try database.execute("INSERT INTO multiplayer_sessions(id,sequence,terminal,started_at,payload) VALUES(?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET sequence=excluded.sequence,terminal=excluded.terminal,payload=excluded.payload WHERE multiplayer_sessions.sequence<=excluded.sequence AND multiplayer_sessions.terminal<=excluded.terminal",
            [.text(session.id), .integer(session.sequence), .integer(session.finished ? 1 : 0), .integer(Int64(session.startedAt.timeIntervalSince1970 * 1000)), .blob(try encode(session))])
    }

    func saveGameSession(_ session: GameSession) throws {
        guard session.configuration.progressGeneration == (try currentState()).generation else { throw ProgressError.staleSession }
        try session.configuration.validate()
        let database = try currentDatabase()
        try database.transaction { try Self.writeSession(session, database: database) }
    }
    func resumableGameSession() throws -> GameSession? {
        let database = try currentDatabase()
        guard let payload = try database.query("SELECT payload FROM game_sessions WHERE terminal=0 ORDER BY started_at DESC LIMIT 1").first?.first?.data else { return nil }
        var session = try Self.decode(GameSession.self, payload)
        try session.configuration.validate()
        session.restorePaused()
        return session
    }
    func gameSessions() throws -> [GameSession] {
        try currentDatabase().query("SELECT payload FROM game_sessions ORDER BY started_at DESC").map { row in
            guard let payload = row.first?.data else { throw ProgressError.invalidState }
            return try Self.decode(GameSession.self, payload)
        }
    }
    private static func writeSession(_ session: GameSession, database: ProgressDatabase) throws {
        guard session.sequence >= 0, !session.id.isEmpty else { throw ProgressError.invalidValue }
        try database.execute("INSERT INTO game_sessions(id,sequence,terminal,started_at,payload) VALUES(?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET sequence=excluded.sequence,terminal=excluded.terminal,payload=excluded.payload WHERE game_sessions.sequence<=excluded.sequence AND game_sessions.terminal<=excluded.terminal",
            [.text(session.id), .integer(session.sequence), .integer(session.isTerminal ? 1 : 0), .integer(Int64(session.startedAt.timeIntervalSince1970 * 1000)), .blob(try encode(session))])
    }

    private func commit(_ value: ProgressState, writes: (ProgressDatabase) throws -> Void) throws -> ProgressState {
        let database = try currentDatabase()
        var next = value
        next.revision = try Self.add(next.revision, 1)
        try database.transaction {
            try writes(database)
            try database.execute("UPDATE app_state SET payload=? WHERE id=1", [.blob(try Self.encode(next))])
        }
        state = next // Publish only after the whole transaction commits.
        return next
    }

    private func currentState() throws -> ProgressState {
        guard let state else { throw ProgressError.notLoaded }
        return state
    }
    private func currentDatabase() throws -> ProgressDatabase {
        guard let database else { throw ProgressError.notLoaded }
        return database
    }
    private static func add(_ value: Int64, _ delta: Int64) throws -> Int64 {
        let (result, overflow) = value.addingReportingOverflow(delta)
        guard !overflow else { throw ProgressError.overflow }
        return result
    }
    private static func bind(_ key: LevelKey) -> [ProgressDatabase.Value] {
        [.text(key.scope.rawValue), .integer(Int64(key.parentID)), .integer(Int64(key.level))]
    }
    private static func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(value)
    }
    private static func decode<T: Decodable>(_ type: T.Type, _ data: Data) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
    private static func validate(_ operation: ProgressOperation) throws {
        guard !operation.id.isEmpty, operation.id.utf8.count <= 256,
              !operation.id.contains("\0"), operation.solvedDelta >= 0,
              operation.unlockTrickID.map({ $0 > 0 }) ?? true,
              operation.unlockDifficulty.map({ (1...Int64(GameDifficulty.maximum)).contains($0) }) ?? true,
              operation.playerWinner.map({ $0 == 1 || $0 == 2 }) ?? true else { throw ProgressError.invalidValue }
        if let session = operation.gameSession { try session.configuration.validate() }
        for level in [operation.level, operation.nextLevel].compactMap({ $0 }) {
            try level.key.validate();try level.measurements?.validate()
            guard level.bestScore >= 0, (0...3).contains(level.bestStars) else { throw ProgressError.invalidValue }
        }
        if let record = operation.record {
            guard [.single, .minute, .speed, .noTime].contains(record.mode), record.value.isFinite,
                  record.value >= 0, record.unit == (record.mode == .speed ? .seconds : .points),
                  record.mode != .speed || record.value > 0 else { throw ProgressError.invalidValue }
        }
    }
}
