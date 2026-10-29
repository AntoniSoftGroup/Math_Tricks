import Foundation

nonisolated struct SessionTrickKey: Hashable {
    let id: Int
    let input: GameInputMode
}
nonisolated struct SessionResultQuestion {
    let attempts: [ExampleAttempt]
    var final: ExampleAttempt { attempts[attempts.count - 1] }
    var correct: Bool { final.independent }
}
nonisolated struct SessionResultModel {
    let session: GameSession
    let key: SessionTrickKey?
    let questions: [SessionResultQuestion]
    let trickKeys: [SessionTrickKey]
    init(session: GameSession, key: SessionTrickKey? = nil) {
        self.session = session; self.key = key
        var questions: [SessionResultQuestion] = [], pending: [ExampleAttempt] = []
        let training = [.training,.byHeart].contains(session.configuration.mode)
        for attempt in session.attempts {
            if training {
                pending.append(attempt)
                if attempt.outcome == .solved { questions.append(SessionResultQuestion(attempts: pending)); pending = [] }
            } else { questions.append(SessionResultQuestion(attempts: [attempt])) }
        }
        if !pending.isEmpty { questions.append(SessionResultQuestion(attempts: pending)) }
        self.questions = key.map { key in questions.filter { $0.final.example.trickID == key.id && $0.final.inputMode == key.input } } ?? questions
        var seen = Set<SessionTrickKey>()
        trickKeys = session.attempts.compactMap { attempt in
            let key = SessionTrickKey(id: attempt.example.trickID,input: attempt.inputMode)
            return seen.insert(key).inserted ? key : nil
        }
    }
    var exampleRows: Bool { key != nil || [.training,.byHeart].contains(session.configuration.mode) }
    var attempts: [ExampleAttempt] { key.map { key in session.attempts.filter { $0.example.trickID == key.id && $0.inputMode == key.input } } ?? session.attempts }
    var score: Int64 { key == nil ? session.score : attempts.reduce(0) { $0 + $1.points } }
    var correct: Int { questions.filter(\.correct).count }
    var totalQuestions: Int { key == nil && [.training,.byHeart].contains(session.configuration.mode) ? max(session.target,questions.count) : questions.count }
    var totalTime: TimeInterval { attempts.reduce(0) { $0 + $1.elapsed } }
    var average: TimeInterval? {
        let clean = key == nil ? questions.map(\.final).filter(\.independent) : attempts.filter(\.eligible)
        return clean.isEmpty ? nil : clean.reduce(0) { $0 + $1.elapsed } / Double(clean.count)
    }
    func aggregate(_ key: SessionTrickKey) -> PracticeAggregate {
        PracticeAggregate(id: String(key.id),entries: session.attempts.filter { $0.example.trickID == key.id && $0.inputMode == key.input }.map {
            PracticeEntry(id: "\($0.ordinal)",sessionID: session.id,startedAt: session.startedAt,mode: session.configuration.mode,multiplayer: false,attempt: $0)
        })
    }
    func comparison(_ attempt: ExampleAttempt, statistics: PracticeStatistics?) -> (first: TimeInterval?, best: TimeInterval?) {
        let expression = PracticeStatistics.expressionKey(attempt.example)
        let earlier = statistics?.entries.filter {
            $0.attempt.inputMode == attempt.inputMode && $0.attempt.eligible && PracticeStatistics.expressionKey($0.attempt.example) == expression &&
            ($0.startedAt < session.startedAt || ($0.sessionID == session.id && $0.attempt.ordinal < attempt.ordinal))
        }.sorted { $0.startedAt == $1.startedAt ? $0.attempt.ordinal < $1.attempt.ordinal : $0.startedAt < $1.startedAt } ?? []
        let imported = statistics?.imported.filter { $0.expression != nil && $0.id == expression && $0.matches(input: attempt.inputMode,levels: nil) } ?? []
        let first = imported.compactMap(\.first).first ?? earlier.first?.attempt.elapsed
        let best = (earlier.map { $0.attempt.elapsed } + imported.compactMap(\.best)).min()
        return (first ?? attempt.elapsed,best)
    }
}

nonisolated enum ResultAnswerStatus {
    static func text(_ attempt: ExampleAttempt) -> String? {
        var parts: [String] = []
        if attempt.outcome == .skipped { parts.append(ResultText.text("statistics_skipped")) }
        else if attempt.outcome != .solved { parts.append(ResultText.text("results_unsolved")) }
        if attempt.hints > 0 || attempt.revealedAnswer { parts.append(ResultText.text("results_with_hint")) }
        if attempt.errors > 0 || attempt.corrections > 0 { parts.append(ResultText.text("results_with_error")) }
        if attempt.inputChanged == true { parts.append(ResultText.text("statistics_input_changed")) }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
