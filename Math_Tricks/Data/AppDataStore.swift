import Combine
import Foundation

/// The UI-facing data boundary. Controllers never access Core Data or SQLite.
@MainActor
final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()
    @Published private(set) var snapshot: ProgressState?
    private let repository = ProgressRepository()
    private var purchasesObservation: AnyCancellable?
    private var loading: (id: UUID, task: Task<ProgressState, Error>)?

    private(set) var launchSettings: AppSettings
    private init() {
        launchSettings = UserDefaults.standard.data(forKey:"launchSettings")
            .flatMap { try? JSONDecoder().decode(AppSettings.self,from:$0) } ?? AppSettings()
        purchasesObservation = NotificationCenter.default.publisher(for: AppPurchases.changed)
            .sink { [weak self] _ in
                guard let self, let snapshot = self.snapshot else { return }
                self.snapshot = snapshot
            }
    }

    @discardableResult
    func prepare() async throws -> ProgressState {
        if let snapshot { return snapshot }
        let pending: (id: UUID, task: Task<ProgressState, Error>)
        if let loading { pending = loading }
        else {
            pending = (UUID(), Task {
                let legacy = try await LegacyProgressSession.shared.prepare()
                return try await repository.open(legacy: legacy)
            })
            loading = pending
        }
        defer { if loading?.id == pending.id { loading = nil } }
        let value = try await pending.task.value
        publish(value)
        return snapshot ?? value
    }

    func updateSettings(_ change: SettingsChange) async throws {
        publish(try await repository.updateSettings(change))
    }
    func refreshDailyProgress() async throws { publish(try await repository.refreshDailyProgress()) }
    func updateDailyOptions(_ change: DailyOptionsChange) async throws { publish(try await repository.updateDailyOptions(change)) }
    func setDailyProgress(_ value: DailyProgress) async throws {
        publish(try await repository.setDailyProgress(value))
    }
    func setCurrentLevel(_ level: Int64,selected:Bool=false) async throws {
        publish(try await repository.setCurrentLevel(level,selected:selected))
    }
    func setMultiplayerLength(_ count: Int64) async throws {
        publish(try await repository.setMultiplayerLength(count))
    }
    func setTrickSelected(_ id: Int, selected: Bool) async throws {
        publish(try await repository.setTrickSelected(id, selected: selected))
    }
    func apply(_ operation: ProgressOperation) async throws {
        publish(try await repository.apply(operation))
    }
    func catalogProgress() async throws -> [TrickProgress] {
        try await repository.catalogProgress().map(applyingFullVersion)
    }
    func trainingCatalogProgress() async throws -> TrainingCatalogProgress {
        let progress = try await repository.trainingCatalogProgress()
        return TrainingCatalogProgress(tricks: progress.tricks.map(applyingFullVersion), completedLevels: progress.completedLevels)
    }
    func setAllTricksSelected(_ selected: Bool) async throws { publish(try await repository.setAllTricksSelected(selected)) }
    func unlockTrick(_ id: Int) async throws {
        if AppPurchases.shared.hasFullVersion || AppConstants.unlockAllLevels, TrickCatalog.shared.trick(id) != nil { return }
        publish(try await repository.unlockTrick(id))
    }
    func trickProgress(_ id: Int) async throws -> TrickProgress? {
        try await repository.trickProgress(id).map(applyingFullVersion)
    }
    // Store entitlements never become coin unlocks in exported or cloud progress.
    private func applyingFullVersion(_ value: TrickProgress) -> TrickProgress {
        var value = value
        if AppPurchases.shared.hasFullVersion || AppConstants.unlockAllLevels { value.unlocked = true }
        return value
    }
    func levelProgress(_ key: LevelKey) async throws -> LevelProgress? {
        try await repository.levelProgress(key)
    }
    func levels(scope: LevelKey.Scope, parentID: Int) async throws -> [LevelProgress] {
        try await repository.levels(scope: scope, parentID: parentID)
    }
    func allLevels(scope: LevelKey.Scope) async throws -> [LevelProgress] { try await repository.allLevels(scope: scope) }
    func historicalGraphs() async throws -> [HistoricalGraphPoint] {
        try await repository.historicalGraphs()
    }

    func exportProgressArchive(android:Bool=false) async throws -> Data { try await repository.exportProgressArchive(android:android) }
    func previewProgressArchive(_ bytes:Data) async throws -> ProgressArchive { try await repository.previewProgressArchive(bytes) }
    func cloudOwner() async throws -> String { try await repository.cloudOwner() }
    func setCloudOwner(_ uid: String) async throws { publish(try await repository.setCloudOwner(uid)) }
    func importProgressArchive(_ archive:ProgressArchive,expectedRevision:Int64,cloudOwner:String?=nil) async throws {
        let next = try await repository.importProgressArchive(archive,expectedRevision:expectedRevision,cloudOwner:cloudOwner)
        if cloudOwner == nil { CloudSync.shared.localProgressReplaced() }
        publish(next)
        AppGameCenter.shared.synchronize()
    }
    @discardableResult
    func mergeCloudProgress(_ progress: CloudProgress, expectedRevision: Int64, cloudOwner: String) async throws -> ProgressState {
        let next = try await repository.mergeCloudProgress(progress,expectedRevision:expectedRevision,cloudOwner:cloudOwner)
        publish(next)
        AppGameCenter.shared.synchronize()
        return next
    }
    func clearPracticeStatistics() async throws { publish(try await repository.clearPracticeStatistics()) }
    func resetLocalProgress() async throws {
        let next = try await repository.resetLocalProgress()
        CloudSync.shared.localProgressReplaced()
        publish(next)
    }
    func resetGameRecord(_ mode: GameMode, selected: Bool) async throws { publish(try await repository.resetGameRecord(mode, selected: selected)) }
    func commitGameSession(_ session: GameSession, mutation: GameMutation) async throws {
        publish(try await repository.commitGameSession(session, mutation: mutation))
        if session.isTerminal {AppGameCenter.shared.synchronize()}
    }
    func commitMultiplayerSession(_ session: MultiplayerSession, mutation: GameMutation) async throws { publish(try await repository.commitMultiplayerSession(session,mutation: mutation)) }
    func saveMultiplayerSession(_ session: MultiplayerSession) async throws { try await repository.saveMultiplayerSession(session) }
    func resumableMultiplayerSession() async throws -> MultiplayerSession? { try await repository.resumableMultiplayerSession() }
    func saveGameSession(_ session: GameSession) async throws { try await repository.saveGameSession(session) }
    func resumableGameSession() async throws -> GameSession? { try await repository.resumableGameSession() }
    func practiceStatistics() async throws -> PracticeStatistics { try await repository.practiceStatistics() }
    func gameSessions() async throws -> [GameSession] { try await repository.gameSessions() }

    private func publish(_ value: ProgressState) {
        // Concurrent windows may resume in a different order from disk commits.
        guard snapshot.map({ value.revision >= $0.revision }) ?? true else { return }
        if launchSettings != value.settings {
            launchSettings = value.settings
            if let encoded = try? JSONEncoder().encode(value.settings) {
                UserDefaults.standard.set(encoded,forKey:"launchSettings")
            }
        }
        snapshot = value
    }
}
