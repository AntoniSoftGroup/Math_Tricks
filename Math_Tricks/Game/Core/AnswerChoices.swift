import Foundation

/// Player.ecuationBlocks / generateBlocks: perturb decimal places, preserving
/// the suffix of the four square-ending tricks before inserting the answer.
nonisolated enum AnswerChoices {
    static func validValue(_ value: Int64) -> Bool { (-100_000_000_000_000_000...100_000_000_000_000_000).contains(value) }
    static func make(example: MathExample, seed: UInt64) -> (choices: [Int64], proposal: Int64) {
        var state = seed
        func random(_ count: Int) -> Int {
            state &+= 0x9e3779b97f4a7c15
            var z = state
            z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
            z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
            return Int((z ^ (z >> 31)) % UInt64(count))
        }
        let key = TrickCatalog.shared.trick(example.trickID)?.key ?? ""
        let scale: Int64
        if key == "trick_square_numbers_editing_in_5" { scale = 100 }
        else if ["trick_square_numbers_editing_in_25", "trick_square_numbers_editing_in_75"].contains(key) { scale = 1000 }
        else if key == "trick_square_numbers_editing_in_125" { scale = 10000 }
        else { scale = 1 }
        let base = example.answer / scale, suffix = example.answer % scale
        let schemes: [[Int64]] = [[1,1,1,1],[-1,-1,-1,1],[1,-1,1,1],[-1,1,-1,1]]
        let signs = schemes[random(4)]
        var values = Array(repeating: base, count: 4), place: Int64 = 1
        repeat {
            if (base / place) % 10 != 0 || place * 100 >= base {
                values[0] += place * signs[0]; values[1] += place * 2 * signs[1]
            }
            if (base / place / 10) % 10 != 0 || place * 100 >= base {
                values[2] += place * 10 * signs[2]; values[3] += place * 20 * signs[3]
            }
            place *= 10
        } while place * 10 < base
        values = values.map { $0 * scale + suffix }
        let index = random(4)
        let proposal = random(2) == 0 ? values[index == 2 ? 0 : index] : example.answer
        values[index] = example.answer
        return (values, proposal)
    }
}
