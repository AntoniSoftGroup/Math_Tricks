import Foundation

nonisolated enum MultiplayerKind: String, Codable, Sendable { case versus, cooperative }
nonisolated enum PlayerAction: Sendable { case digit(Int), delete, clear, choice(Int64), boolean(Bool) }
nonisolated struct MultiplayerConfiguration: Codable, Sendable, Equatable {
    let kind: MultiplayerKind
    let length: Int
    let trickIDs: [Int]
    var selectedTricks = false
    var inputMode = GameInputMode.digits
    var progressGeneration: String?
    func validate() throws {
        guard (5...35).contains(length), length.isMultiple(of: 5) else { throw ProgressError.invalidValue }
        try GameConfiguration(mode: .noTime, difficulty: 1, trickIDs: trickIDs, progressGeneration: progressGeneration).validate()
    }
}
nonisolated struct MultiplayerSession: Codable, Sendable {
    let id: String
    private(set) var configuration: MultiplayerConfiguration
    let startedAt: Date
    var sequence: Int64 = 0
    private(set) var players: [GameSession]
    private(set) var points: [Int64] = [0,0]
    private(set) var balance = 0
    private(set) var sharedElapsed: TimeInterval = 0
    private(set) var running = false
    private(set) var finished = false
    private(set) var winner: Int?
    private var anchor: TimeInterval?
    private enum CodingKeys: String, CodingKey { case id, configuration, startedAt, sequence, players, points, balance, sharedElapsed, running, finished, winner }
    init(configuration: MultiplayerConfiguration) throws {
        try configuration.validate()
        self.configuration = configuration; id = UUID().uuidString; startedAt = Date()
        let playerConfig = GameConfiguration(mode: .noTime, difficulty: 1, trickIDs: configuration.trickIDs, selectedTricks: configuration.selectedTricks, inputMode:configuration.inputMode,progressGeneration: configuration.progressGeneration)
        players = [try GameSession(configuration: playerConfig), try GameSession(configuration: playerConfig)]
        for index in 0..<2 {
            players[index].resume(now: 0)
            players[index].pause(now: 0)
        }
    }
    mutating func rebaseProgressGeneration(_ generation:String){
        configuration.progressGeneration=generation
        players.indices.forEach{players[$0].rebaseProgressGeneration(generation)}
        restorePaused()
    }
    var remaining: TimeInterval { max(0, 20 - sharedElapsed) }
    mutating func resume(now: TimeInterval) {
        guard !finished else { return }
        running = true; anchor = now; players.indices.forEach { players[$0].resume(now: now) }; sequence += 1
    }
    mutating func pause(now: TimeInterval) {
        tick(now: now); running = false; anchor = nil
        players.indices.forEach { players[$0].pause(now: now) }; sequence += 1
    }
    mutating func restorePaused() {
        running = false; anchor = nil; players.indices.forEach { players[$0].restorePaused() }; sequence += 1
    }
    mutating func tick(now: TimeInterval) {
        guard running, !finished, let anchor else { return }
        sharedElapsed += max(0, now - anchor); self.anchor = now
        players.indices.forEach { players[$0].tick(now: now) }
        if configuration.kind == .cooperative, remaining <= 0 { finish() }
    }
    mutating func perform(player: Int, action: PlayerAction, now: TimeInterval) throws -> GameMutation {
        tick(now: now)
        guard running, !finished, players.indices.contains(player) else { return GameMutation() }
        let mutation: GameMutation
        switch action {
        case .digit(let value): mutation = try players[player].appendDigit(value, now: now)
        case .delete: players[player].deleteDigit(); mutation = GameMutation()
        case .clear: players[player].deleteDigit(clear: true); mutation = GameMutation()
        case .choice(let value): mutation = try players[player].choose(value, now: now)
        case .boolean(let value): mutation = try players[player].chooseBoolean(value, now: now)
        }
        if mutation.correct {
            if configuration.kind == .versus {
                balance += player == 0 ? 1 : -1
                if abs(balance) >= configuration.length { winner = balance > 0 ? 1 : 2; finish() }
            } else {
                points[player] += Int64(remaining * 100 / 20) + (player == 0 ? 1 : 0)
                sharedElapsed = 0
            }
        } else if mutation.coinDelta < 0 {
            let weight = mutation.coinDelta == -3 ? 2 : 1
            if configuration.kind == .versus {
                balance -= (player == 0 ? 1 : -1) * weight
                if abs(balance) >= configuration.length { winner = balance > 0 ? 1 : 2; finish() }
            } else { points[player] = max(0, points[player] - Int64(weight * 150)) }
        }
        sequence += 1
        return mutation
    }
    mutating func finish() {
        guard !finished else { return }
        finished = true; running = false; anchor = nil
        players.indices.forEach { players[$0].finish(completed: true) }; sequence += 1
    }
}
