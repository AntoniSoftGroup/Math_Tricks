import Foundation

/// Pure session state. UIKit supplies monotonic time and persists accepted mutations.
nonisolated struct GameSession: Codable, Sendable {
    enum Phase: String, Codable, Sendable { case ready, running, paused, solution, finished, abandoned }
    let id: String
    private(set) var configuration: GameConfiguration
    let startedAt: Date
    var sequence: Int64 = 0
    private(set) var phase: Phase = .ready
    private(set) var level: Int
    private(set) var score: Int64 = 0
    private(set) var solved = 0
    private(set) var levelSolved = 0
    private(set) var stars = 3
    private(set) var hintsRemaining = 9
    private(set) var skipsRemaining = 9
    private(set) var elapsed: TimeInterval = 0
    private(set) var questionElapsed: TimeInterval = 0
    private(set) var penaltyTime: TimeInterval = 0
    private(set) var questionExpired = false
    private(set) var completed = false
    private(set) var example: MathExample
    private(set) var input = ""
    private(set) var inputMode: GameInputMode = .digits
    private(set) var attempts: [ExampleAttempt] = []
    private(set) var choices: [Int64] = []
    private(set) var proposedAnswer: Int64 = 0
    private var randomState: UInt64
    private var recent: [String] = []
    private var currentInputChanged:Bool?
    private var exampleClockOffset: TimeInterval?
    private var currentErrors = 0
    private var currentCorrections = 0
    private var currentHints = 0
    private var currentUserAnswer: String?
    private var currentBoolean: Bool?
    private(set) var rejectedChoices: [Int64]?
    private(set) var rejectedBoolean: Bool?
    private var answerRevealed = false
    private var stepHintAllowance: Int?
    private var stepSkipAllowance: Int?
    private var clockAnchor: TimeInterval?
    private enum CodingKeys: String, CodingKey {
        case id, configuration, startedAt, sequence, phase, level, score, solved, levelSolved, stars, hintsRemaining, skipsRemaining,
             elapsed, questionElapsed, penaltyTime, questionExpired, completed, example, input, inputMode, attempts, choices,
             proposedAnswer, randomState, recent, currentInputChanged, currentErrors, currentCorrections, currentHints, answerRevealed, stepHintAllowance, stepSkipAllowance, currentUserAnswer, currentBoolean, rejectedChoices, rejectedBoolean, exampleClockOffset
    }

    init(configuration: GameConfiguration, seed: UInt64 = UInt64.random(in: 1...UInt64.max)) throws {
        try configuration.validate()
        id = UUID().uuidString; self.configuration = configuration; startedAt = Date()
        level = configuration.difficulty; randomState = seed
        inputMode = configuration.inputMode ?? .digits
        example = try MathExample.generate(trickID: configuration.trickIDs[0], level: level, seed: seed)
        try nextExample()
    }
    mutating func rebaseProgressGeneration(_ generation:String){
        configuration.progressGeneration=generation;restorePaused()
    }
    var isTerminal: Bool { phase == .finished || phase == .abandoned }
    var isFinite: Bool { [.training, .byHeart, .speed, .daily].contains(configuration.mode) }
    var target: Int { configuration.mode == .speed ? 20 : configuration.exampleCount }
    var timerFraction: Double {
        if configuration.mode == .daily { return min(1,Double(levelSolved)/Double(max(1,target))) }
        if configuration.mode == .noTime || configuration.mode == .speed { return 1 }
        return max(0, min(1, remainingTime / (configuration.mode == .minute ? 60 : 20)))
    }
    var remainingTime: TimeInterval { configuration.mode == .minute ? max(0, 60 - elapsed - penaltyTime) : max(0, 20 - questionElapsed) }
    var resultValue: Double { configuration.mode == .speed ? elapsed + penaltyTime : Double(score) }
    var hasGraphResult: Bool {
        phase == .finished && (configuration.mode != .speed || completed)
            && (configuration.mode != .noTime || solved > 0)
    }

    mutating func resume(now: TimeInterval) {
        guard !isTerminal, phase != .solution else { return }
        phase = .running; clockAnchor = now; sequence += 1
    }
    mutating func pause(now: TimeInterval) {
        guard phase == .running else { return }
        tick(now: now)
        if !isTerminal { phase = .paused }
        clockAnchor = nil; sequence += 1
    }
    /// Restored snapshots never count suspended/process-dead time as thinking time.
    mutating func restorePaused() {
        clockAnchor = nil
        if !isTerminal { phase = .paused }
        sequence += 1
    }
    mutating func tick(now: TimeInterval) {
        guard phase == .running, let previous = clockAnchor else { return }
        let delta = max(0, now - previous)
        clockAnchor = now; elapsed += delta; questionElapsed += delta
        if [.noTime, .daily, .speed].contains(configuration.mode) || questionExpired { return }
        if remainingTime <= 0 {
            if [.training, .byHeart, .daily].contains(configuration.mode) {
                stars = max(0, stars - 1); questionExpired = true
            } else { finish(completed: configuration.mode == .minute) }
            sequence += 1
        }
    }
    mutating func appendDigit(_ digit: Int, now: TimeInterval) throws -> GameMutation {
        tick(now: now)
        guard phase == .running, (0...9).contains(digit), input.count < max(12, String(example.answer).count) else { return GameMutation() }
        input = input == "0" ? String(digit) : input + String(digit)
        sequence += 1
        currentUserAnswer = input
        if Int64(input) == example.answer { return try accept(now: now) }
        // Android numeric entry signals a prefix mismatch but applies no choice penalty.
        return GameMutation(wrong: !String(example.answer).hasPrefix(input))
    }
    mutating func deleteDigit(clear: Bool = false) {
        guard phase == .running else { return }
        if !input.isEmpty { currentCorrections += 1 }
        if clear { input = "" } else if !input.isEmpty { input.removeLast() }
        sequence += 1
    }
    mutating func changeInput() {
        guard phase == .running else { return }
        inputMode = GameInputMode(rawValue: (inputMode.rawValue + 1) % 3) ?? .digits
        input = "";currentInputChanged=true;sequence += 1
    }
    mutating func markInputChanged(){guard phase == .running else{return};currentInputChanged=true;sequence += 1}
    mutating func choose(_ value: Int64, now: TimeInterval) throws -> GameMutation {
        tick(now: now)
        guard phase == .running, choices.contains(value), !(rejectedChoices ?? []).contains(value) else { return GameMutation() }
        if currentUserAnswer == nil { currentUserAnswer = String(value) }
        if value == example.answer { return try accept(now: now) }
        rejectedChoices = (rejectedChoices ?? []) + [value]
        return penalizeChoice(boolean: false)
    }
    mutating func chooseBoolean(_ value: Bool, now: TimeInterval) throws -> GameMutation {
        tick(now: now)
        guard phase == .running, rejectedBoolean != value else { return GameMutation() }
        if currentBoolean == nil { currentBoolean = value; currentUserAnswer = value ? "true" : "false" }
        if value == (proposedAnswer == example.answer) { return try accept(now: now) }
        rejectedBoolean = value
        return penalizeChoice(boolean: true)
    }
    private mutating func penalizeChoice(boolean: Bool) -> GameMutation {
        currentErrors += 1
        let weight: Int64 = boolean ? 2 : 1
        switch configuration.mode {
        case .minute: penaltyTime += Double(weight * 2)
        case .speed: penaltyTime += Double(weight * 2)
        case .noTime: score = max(0, score - weight)
        default: score = max(0, score - weight * 150)
        }
        if [.training, .byHeart].contains(configuration.mode) { stars = max(0, stars - 1) }
        if configuration.mode == .minute, remainingTime <= 0 { finish(completed: true) }
        sequence += 1
        return GameMutation(coinDelta: boolean ? -3 : -2, wrong: true)
    }
    var solutionStepHintsRemaining: Int { stepSkipAllowance ?? 9 }
    var solutionAllHintsRemaining: Int { stepHintAllowance ?? 9 }
    mutating func consumeSolutionStepHint() -> Bool {
        guard phase == .solution, solutionStepHintsRemaining > 0 else { return false }
        stepSkipAllowance = solutionStepHintsRemaining - 1; answerRevealed = true; sequence += 1
        return true
    }
    mutating func consumeSolutionAllHint() -> Bool {
        guard phase == .solution, solutionAllHintsRemaining > 0 else { return false }
        stepHintAllowance = solutionAllHintsRemaining - 1; answerRevealed = true; sequence += 1
        return true
    }
    mutating func showSolutionAnswer() {
        guard phase == .solution else { return }
        input = String(example.answer); currentUserAnswer = input; answerRevealed = true; sequence += 1
    }
    mutating func acceptSolutionAnswer(now: TimeInterval) throws -> GameMutation {
        guard phase == .solution, input == String(example.answer) else { throw ProgressError.invalidState }
        phase = .running; clockAnchor = now
        return try accept(now: now)
    }
    mutating func revealSolution(now: TimeInterval) -> Bool {
        guard phase == .running, hintsRemaining > 0 else { return false }
        pause(now: now)
        guard !isTerminal else { return false }
        hintsRemaining -= 1; currentHints += 1; phase = .solution; sequence += 1
        return true
    }
    mutating func closeSolution(now: TimeInterval, answerWasRevealed: Bool = false) {
        guard phase == .solution else { return }
        answerRevealed = answerRevealed || answerWasRevealed
        phase = .paused; resume(now: now)
    }
    mutating func skip(now: TimeInterval) throws {
        tick(now: now)
        guard phase == .running, skipsRemaining > 0 else { return }
        skipsRemaining -= 1
        appendAttempt(.skipped, points: 0)
        try nextExample(resetQuestionClock: false); sequence += 1
    }
    private mutating func accept(now: TimeInterval) throws -> GameMutation {
        let before = score
        switch configuration.mode {
        case .minute, .noTime, .daily: score += 1
        case .speed: break
        case .training, .byHeart:
            score += Int64(max(0, remainingTime * Double(1000 / configuration.exampleCount) / 20))
        case .single: score += Int64(max(0, remainingTime * 100 / 20)) + 1
        }
        appendAttempt(.solved, points: score - before)
        questionElapsed = 0; exampleClockOffset = 0; input = ""
        solved += 1; levelSolved += 1
        let boundary = levelSolved >= target
        let rewardBoundary = configuration.mode == .daily ? solved.isMultiple(of: 10) : boundary
        var result = GameMutation(coinDelta: rewardBoundary ? 5 : 1, solvedDelta: 1, correct: true, levelCompleted: boundary)
        if boundary {
            if isFinite { finish(completed: true) }
            else {
                level = min(GameDifficulty.maximum, level + 1); levelSolved = 0
                if !configuration.selectedTricks { hintsRemaining += 1; skipsRemaining += 1 }
                result.unlockDifficulty = Int64(level)
            }
        }
        if configuration.mode == .daily, rewardBoundary, !isTerminal {level=min(GameDifficulty.maximum,level+1);result.unlockDifficulty=Int64(level)}
        if !isTerminal { try nextExample() }
        sequence += 1
        return result
    }
    mutating func finish(completed: Bool) {
        guard !isTerminal else { return }
        if !input.isEmpty || questionElapsed > 0 { appendAttempt(.unfinished, points: 0) }
        self.completed = completed && (!isFinite || levelSolved >= target); phase = .finished; clockAnchor = nil; sequence += 1
    }
    mutating func abandon() { phase = .abandoned; clockAnchor = nil; sequence += 1 }
    private mutating func appendAttempt(_ outcome: ExampleAttempt.Outcome, points: Int64) {
        attempts.append(ExampleAttempt(ordinal: attempts.count + 1, example: example, level: level,
            elapsed: max(0, questionElapsed - (exampleClockOffset ?? 0)), outcome: outcome, inputMode: inputMode, errors: currentErrors,
            corrections: currentCorrections, hints: currentHints, revealedAnswer: answerRevealed, points: points, inputChanged:currentInputChanged, userAnswer: currentUserAnswer, displayedChoices: inputMode == .choices ? choices : nil, proposedAnswer: inputMode == .boolean ? proposedAnswer : nil, chosenBoolean: currentBoolean, selectedChoices: inputMode == .choices ? (rejectedChoices ?? []) + (outcome == .solved ? [example.answer] : []) : nil))
    }
    private mutating func nextExample(resetQuestionClock: Bool = true) throws {
        for _ in 0..<51 {
            randomState &+= 0x9e3779b97f4a7c15
            var random = randomState
            random = (random ^ (random >> 30)) &* 0xbf58476d1ce4e5b9
            random = (random ^ (random >> 27)) &* 0x94d049bb133111eb
            random ^= random >> 31
            let ids = configuration.trickIDs
            let id = ids[Int(random % UInt64(ids.count))]
            if configuration.mode == .byHeart, let number = configuration.multiplicationNumber, let stage = configuration.multiplicationLevel {
                let factor = Self.multiplicationInterval(stage: stage)
                let second = factor.lowerBound + Int(random % UInt64(factor.count))
                let swap = (random >> 16).isMultiple(of: 2)
                let firstOperand = swap ? second : number
                let secondOperand = swap ? number : second
                example = MathExample(trickID: 3, operand1: Int64(firstOperand), operand2: Int64(secondOperand), displayedOperand1: Double(firstOperand), displayedOperand2: Double(secondOperand), answer: Int64(number * second), operation: .multiplication)
            } else { example = try MathExample.generate(trickID: id, level: level, seed: random) }
            if !recent.contains(example.signature) { break }
        }
        recent.append(example.signature); recent = Array(recent.suffix(7))
        if resetQuestionClock { questionElapsed = 0; questionExpired = false }
        exampleClockOffset = questionElapsed
        rejectedChoices = nil; rejectedBoolean = nil
        input = "";currentInputChanged=false;currentErrors = 0; currentCorrections = 0; currentHints = 0; currentUserAnswer = nil; currentBoolean = nil; answerRevealed = false
        let generated = AnswerChoices.make(example: example, seed: randomState)
        choices = generated.choices; proposedAnswer = generated.proposal
    }

    static func multiplicationInterval(stage: Int) -> ClosedRange<Int> {
        let minimum = stage == 1 || stage == 21 ? 2 : stage * 5 - 4
        let maximum = stage == 20 || stage == 21 ? 99 : stage * 5
        return minimum...maximum
    }
}

extension GameSession {
    /// Archive input is untrusted. Reject impossible state before it can reach
    /// a timer, an arithmetic step builder, or an Int conversion in the UI.
    nonisolated func validateSavedState() throws {
        try configuration.validate()
        guard !id.isEmpty, id.utf8.count <= 128, !id.contains("\0"),
              startedAt.timeIntervalSince1970 >= -2_208_988_800,
              startedAt.timeIntervalSince1970 <= 253_402_300_799,
              sequence >= 0, sequence < Int64.max / 2,
              GameDifficulty.contains(level), (configuration.mode != .training || level <= 100), score >= 0, score <= 1_000_000_000_000_000,
              (0...1_000_000).contains(solved), (0...target).contains(levelSolved),
              (0...3).contains(stars), (0...1_000_000).contains(hintsRemaining),
              (0...1_000_000).contains(skipsRemaining),
              [elapsed, questionElapsed, penaltyTime].allSatisfy({ $0.isFinite && $0 >= 0 && $0 <= 31_536_000_000 }),
              exampleClockOffset.map({ $0.isFinite && $0 >= 0 && $0 <= questionElapsed }) ?? true,
              input.utf8.count <= 16, input.allSatisfy({ $0.isASCII && $0.isNumber }),
              recent.count <= 7, recent.allSatisfy({ $0.utf8.count <= 128 }),
              [currentErrors,currentCorrections,currentHints].allSatisfy({ (0...1_000_000).contains($0) }),
              stepHintAllowance.map({ (0...10).contains($0) }) ?? true,
              stepSkipAllowance.map({ (0...10).contains($0) }) ?? true,
              currentUserAnswer.map({ $0.utf8.count <= 24 }) ?? true,
              attempts.count <= 1_000_000, choices.count == 4, Set(choices).count == 4,
              choices.contains(example.answer), choices.allSatisfy({ AnswerChoices.validValue($0) }),
              (rejectedChoices ?? []).count <= 3, Set(rejectedChoices ?? []).count == (rejectedChoices ?? []).count,
              (rejectedChoices ?? []).allSatisfy({ choices.contains($0) && $0 != example.answer }),
              rejectedBoolean.map({ $0 != (proposedAnswer == example.answer) }) ?? true,
              AnswerChoices.validValue(proposedAnswer),
              !completed || phase == .finished,
              !completed || !isFinite || levelSolved >= target else { throw ProgressError.invalidArchive }
        try example.validateSavedExample()
        var accepted = 0
        for (index,attempt) in attempts.enumerated() {
            guard attempt.ordinal == index + 1, GameDifficulty.contains(attempt.level), (configuration.mode != .training || attempt.level <= 100),
                  attempt.elapsed.isFinite, (0...31_536_000_000).contains(attempt.elapsed),
                  [attempt.errors,attempt.corrections,attempt.hints].allSatisfy({ (0...1_000_000).contains($0) }),
                  attempt.points >= 0, attempt.points <= 1_000_000_000_000_000,
                  attempt.userAnswer.map({ $0.utf8.count <= 24 }) ?? true,
                  attempt.displayedChoices.map({ $0.count == 4 && $0.allSatisfy({ AnswerChoices.validValue($0) }) }) ?? true,
                  attempt.selectedChoices.map({ $0.count <= 4 && $0.allSatisfy({ AnswerChoices.validValue($0) }) }) ?? true,
                  attempt.proposedAnswer.map({ AnswerChoices.validValue($0) }) ?? true else { throw ProgressError.invalidArchive }
            try attempt.example.validateSavedExample()
            if attempt.outcome == .solved { accepted += 1 }
        }
        guard accepted == solved else { throw ProgressError.invalidArchive }
    }
}
