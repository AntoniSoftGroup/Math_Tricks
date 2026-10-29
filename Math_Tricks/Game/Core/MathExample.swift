import Foundation

nonisolated struct MathExample: Codable, Sendable, Equatable {
    enum Operation: Int, Codable, Sendable { case addition, subtraction, multiplication, division, power, root, percent }
    let trickID: Int
    let operand1: Int64
    let operand2: Int64
    let displayedOperand1: Double
    let displayedOperand2: Double
    let answer: Int64
    let operation: Operation
    var signature: String { "\(trickID):\(operand1):\(operand2)" }

    static func generate(trickID: Int, level: Int, seed: UInt64) throws -> MathExample {
        guard GameDifficulty.contains(level) else { throw ProgressError.invalidValue }
        let raw = MTGenerateExample(Int32(trickID), Int32(level), seed)
        guard raw.valid == 1, let operation = Operation(rawValue: Int(raw.operation)),
              raw.answer >= 0, raw.displayedOperand1.isFinite, raw.displayedOperand2.isFinite else { throw ProgressError.invalidValue }
        let example = MathExample(trickID: trickID, operand1: raw.operand1, operand2: raw.operand2,
            displayedOperand1: raw.displayedOperand1, displayedOperand2: raw.displayedOperand2, answer: raw.answer, operation: operation)
        do { try example.validateSavedExample() } catch { throw ProgressError.invalidValue }
        return example
    }
}

nonisolated struct GameConfiguration: Codable, Sendable, Equatable {
    let mode: GameMode
    let difficulty: Int
    let trickIDs: [Int]
    var selectedTricks = false
    var exampleCount = 10
    var multiplicationNumber: Int?
    var multiplicationLevel: Int?
    var inputMode: GameInputMode?
    var progressGeneration: String?
    func validate() throws {
        guard GameDifficulty.contains(difficulty), (mode != .training || difficulty <= 100), !trickIDs.isEmpty, trickIDs.count <= 107,
              Set(trickIDs).count == trickIDs.count,
              trickIDs.allSatisfy({ TrickCatalog.shared.trick($0) != nil }),
              (1...100).contains(exampleCount) else { throw ProgressError.invalidValue }
        if let generation = progressGeneration {
            guard !generation.isEmpty, generation.utf8.count <= 128, !generation.contains("\0") else { throw ProgressError.invalidValue }
        }
        if mode == .byHeart {
            guard let number = multiplicationNumber, (2...99).contains(number),
                  let level = multiplicationLevel, (1...21).contains(level) else { throw ProgressError.invalidValue }
        }
        if mode == .training, trickIDs.count != 1 { throw ProgressError.invalidValue }
    }
}

nonisolated struct ExampleAttempt: Codable, Sendable, Equatable {
    enum Outcome: String, Codable, Sendable { case solved, skipped, unfinished }
    let ordinal: Int
    let example: MathExample
    let level: Int
    let elapsed: TimeInterval
    let outcome: Outcome
    let inputMode: GameInputMode
    let errors: Int
    let corrections: Int
    let hints: Int
    let revealedAnswer: Bool
    let points: Int64
    var inputChanged:Bool?
    var userAnswer: String?
    var displayedChoices: [Int64]?
    var proposedAnswer: Int64?
    var chosenBoolean: Bool?
    var selectedChoices: [Int64]?
    var eligible:Bool {independent && inputChanged != true && elapsed>0}
    var independent: Bool { outcome == .solved && errors == 0 && corrections == 0 && hints == 0 && !revealedAnswer }
}
nonisolated enum GameInputMode: Int, Codable, Sendable, CaseIterable { case digits, choices, boolean }
nonisolated struct GameMutation: Sendable {
    var coinDelta: Int64 = 0
    var solvedDelta: Int64 = 0
    var correct = false
    var wrong = false
    var levelCompleted = false
    var unlockDifficulty: Int64?
}

/// The Android level counter is Int32. Arithmetic representability is checked separately.
nonisolated enum GameDifficulty {
    static let maximum = Int(Int32.max)
    static func contains(_ level: Int) -> Bool { (1...maximum).contains(level) }
}

extension MathExample {
    nonisolated func validateSavedExample() throws {
        // Integer values up to 2^53-1 are exact in the displayed Double operands.
        let maximumOperand: Int64 = 9_007_199_254_740_991
        guard TrickCatalog.shared.trick(trickID) != nil,
              (0...maximumOperand).contains(operand1), (0...maximumOperand).contains(operand2),
              (0...1_000_000_000_000_000).contains(answer),
              [displayedOperand1, displayedOperand2].allSatisfy({ $0.isFinite && $0 >= 0 && $0 <= Double(maximumOperand) }),
              let first = Decimal(string: String(displayedOperand1), locale: Locale(identifier: "en_US_POSIX")),
              let second = Decimal(string: String(displayedOperand2), locale: Locale(identifier: "en_US_POSIX")) else { throw ProgressError.invalidArchive }
        let calculated: Decimal
        switch operation {
        case .addition: calculated = first + second
        case .subtraction: calculated = first - second
        case .multiplication: calculated = first * second
        case .division:
            guard second > 0 else { throw ProgressError.invalidArchive }
            calculated = first / second
        case .percent: calculated = first * second / 100
        case .power:
            guard (0...30).contains(operand2) else { throw ProgressError.invalidArchive }
            calculated = (0..<Int(operand2)).reduce(Decimal(1)) { value, _ in value * first }
        case .root:
            guard [2,3,4,5,6,9].contains(operand2) else { throw ProgressError.invalidArchive }
            let powered = (0..<Int(operand2)).reduce(Decimal(1)) { value, _ in value * Decimal(answer) }
            guard powered == first else { throw ProgressError.invalidArchive }
            return
        }
        guard !calculated.isNaN, calculated == Decimal(answer) else { throw ProgressError.invalidArchive }
    }
}
