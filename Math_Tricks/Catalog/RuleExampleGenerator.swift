import Foundation

/// RuleFragment operands are independent of the random game generator.
nonisolated struct RuleExampleGenerator {
    let first: Int64
    let second: Int64
    let example: MathExample
    let resultText: String
    let rangeText: String
    let prefix: String
    let suffix: String
    let sign: String
    let twoOperands: Bool
    let fixedFirst: Bool
    let fixedSecond: Bool
    let stackedOperands: Bool

    static let percentages: [Int: Int64] = [49:50,50:25,51:20,52:15,53:5,54:4,55:2,56:0,57:150,58:200,70:250,99:300,100:500,105:75,106:750,107:40]
    private static let multipliers: [Int: Int64] = [5:11,7:5,8:9,9:4,26:15,27:20,33:99,34:25,35:50,59:3,60:6,61:7,62:8,63:12,64:13,65:14,66:16,67:17,68:18,69:19,87:2,90:125,93:250,94:500,95:750,96:999,101:75]
    private static let divisors: [Int: Int64] = [10:5,28:4,29:20,30:50,31:25,36:40,71:15,72:6,85:3,86:2,88:8,97:7,98:9]
    private static let roots: [Int: (degree: Int64, minimum: Int64, maximum: Int64)] = [24:(2,2,99),73:(3,1,99),74:(4,2,107),75:(6,1,32),76:(9,1,10),89:(5,1,73)]
    private static let powers: [Int: Int64] = [6:2,17:2,19:2,20:2,23:2,32:2,39:2,44:2,45:2,46:2,47:2,48:2,77:2,78:2,79:2,80:3,81:3,82:4,83:6,84:9,91:2,92:2,102:2,103:2,104:2]
    private static let endings: [Int: (modulus: Int64, ending: Int64)] = [6:(10,5),39:(100,25),91:(100,75),92:(1000,125),102:(100,5),103:(100,15),104:(100,95)]
    private static func power(_ base: Int64, _ exponent: Int64) -> Int64 { (0..<exponent).reduce(1) { value, _ in value * base } }
    private static func text(_ value: Decimal) -> String { NSDecimalNumber(decimal: value).stringValue }
    static func make(trickID id: Int, first requestedFirst: Int64, second requestedSecond: Int64) -> Self {
        let defaults = RuleOperandDefaults.values[id] ?? [35,31,1,999]
        var first = max(0, min(Int64(Int32.max), requestedFirst))
        var second = max(0, min(999999, requestedSecond))
        var a = first, b = second
        var operation = MathExample.Operation.multiplication
        var displayA = Decimal(first), displayB = Decimal(second)
        var lower = defaults[2], upper = defaults[3]
        var range = "\(lower)..\(upper)", prefix = "", suffix = "", sign = " × "
        var two = false, fixedFirst = false, fixedSecond = false, stacked = false
        var exactResult: Decimal?
        if [1,2,3,4,12,14,15].contains(id) {
            two = true; stacked = true; lower = 1; upper = 999999; range = "1..999999"
            first = min(upper, first); second = min(upper, second)
            if [1,14].contains(id) {
                operation = .addition; sign = " + "
                if first < 1 { first = 128 }; if second < 1 { second = 497 }
            } else if [2,15].contains(id) {
                operation = .subtraction; sign = " − "
                if first < second { swap(&first, &second) }
                if first < 1 { first = 987 }; if second < 1 { second = 456 }
            } else if id == 4 {
                operation = .division; sign = " ÷ "
                first = max(1,first); second = max(1,second)
                if first % second != 0 { first = second * max(1, first / second) }
            } else { first = max(1,first); second = max(1,second) }
            a = first; b = second; displayA = Decimal(a); displayB = Decimal(b)
        } else if id == 11 {
            first = min(9999, max(1, first)); a = first > 999 ? 10000 : 1000; b = first
            displayA = Decimal(a); displayB = Decimal(b); operation = .subtraction
            prefix = "\(a) − "; range = "1..9999"
        } else if [16,18,21].contains(id) {
            two = true
            if id == 16 {
                if !(11...19).contains(first) { first = 14 }; if !(11...19).contains(second) { second = 17 }; range = "11..19"
            } else if id == 18 {
                if !(10...99).contains(first) || first % 10 == 0 { first = 31 }
                second = first / 10 * 10 + 10 - first % 10; fixedSecond = true; range = "11..99"
            } else {
                first = (10...99).contains(first) ? first / 10 * 10 + 1 : 51
                second = (10...99).contains(second) ? second / 10 * 10 + 1 : 31; range = "1..9"
            }
            a = first; b = second; displayA = Decimal(a); displayB = Decimal(b)
        } else if id == 22 || id == 25 || percentages[id] != nil {
            operation = .percent; two = true; sign = "% → "
            if let percent = percentages[id] {
                first = percent; fixedFirst = true; range = "1..9999"
                if second < 1 { second = 64 }; second = min(9999,second)
            } else {
                let percentStep: Int64 = id == 22 ? 5 : 1
                first = max(percentStep, min(99,first)); first -= first % percentStep
                let amountStep: Int64 = id == 22 ? 20 : first % 2 == 0 ? 50 : 100
                second = max(id == 22 ? 40 : 100, min(9999,second)); second -= second % amountStep
                range = id == 22 ? "5..95 %\n40..9980" : (first % 2 == 0 ? "1..99 %\n100..9950" : "1..99 %\n100..9900")
            }
            a = first; b = second; displayA = id == 56 ? Decimal(string: "0.5")! : Decimal(a); displayB = Decimal(b)
        } else if let root = roots[id] {
            let base = min(root.maximum, max(root.minimum, Int64(pow(Double(first), 1 / Double(root.degree)).rounded())))
            first = power(base,root.degree); a = first; b = root.degree
            operation = .root; displayA = Decimal(a); displayB = Decimal(b); exactResult = Decimal(base)
            range = "\(power(root.minimum,root.degree))..\(power(root.maximum,root.degree))"
            prefix = (b == 2 ? "" : superscript(b)) + "√"
        } else if id == 13 {
            first = min(30,max(1,first)); a = 2; b = first; operation = .power
            displayA = 2; displayB = Decimal(b); exactResult = Decimal(power(a,b)); prefix = "2^"; range = "1..30"
        } else if let exponent = powers[id] {
            if let ending = endings[id] {
                if first < lower || first > upper || first % ending.modulus != ending.ending { first = defaults[0] }
            } else if first < lower || first > upper { first = defaults[0] }
            a = first; b = exponent; operation = .power; displayA = Decimal(a); displayB = Decimal(b)
            exactResult = Decimal(power(a,b)); suffix = superscript(b)
        } else {
            first = min(upper,max(lower,first))
            if let divisor = divisors[id] {
                first = max(divisor, first / divisor * divisor); operation = .division; b = divisor; displayB = Decimal(b)
            } else if [37,40,42].contains(id) {
                let divisor: Int64 = id == 37 ? 2 : id == 40 ? 5 : 4
                first = max(divisor, first / divisor * divisor)
                b = divisor; displayB = 1 / Decimal(divisor)
            } else if [38,41,43].contains(id) {
                operation = .division; b = id == 38 ? 2 : id == 41 ? 5 : 4; displayB = 1 / Decimal(b)
            } else { b = multipliers[id] ?? 2; displayB = Decimal(b) }
            a = first; displayA = Decimal(a)
        }
        let result: Decimal
        if let exactResult { result = exactResult }
        else {
            switch operation {
            case .addition: result = displayA + displayB
            case .subtraction: result = displayA - displayB
            case .division: result = displayA / displayB
            case .percent: result = displayA * displayB / 100
            default: result = displayA * displayB
            }
        }
        let resultText = text(result)
        if !two {
            if operation == .power, id != 13 { suffix += " = " + resultText }
            else if !prefix.isEmpty { suffix = " = " + resultText }
            else { suffix = (operation == .division ? " ÷ " : " × ") + text(displayB) + " = " + resultText }
        } else { suffix = " = " + resultText }
        return Self(first: first, second: second,
            example: MathExample(trickID: id,operand1: a,operand2: b,displayedOperand1: NSDecimalNumber(decimal: displayA).doubleValue,displayedOperand2: NSDecimalNumber(decimal: displayB).doubleValue,answer: NSDecimalNumber(decimal: result).int64Value,operation: operation),
            resultText: resultText, rangeText: range, prefix: prefix, suffix: suffix, sign: sign,
            twoOperands: two, fixedFirst: fixedFirst, fixedSecond: fixedSecond, stackedOperands: stacked)
    }
    private static func superscript(_ value: Int64) -> String { [2:"²",3:"³",4:"⁴",5:"⁵",6:"⁶",9:"⁹"][value] ?? String(value) }
    func changing(second changeSecond: Bool, direction: Int) -> Self {
        let id = example.trickID, delta = Int64(direction)
        var a = first, b = second
        if id == 22 || id == 25 {
            if changeSecond { b += delta * (id == 22 ? 20 : a % 2 == 0 ? 50 : 100) }
            else { a += delta * (id == 22 ? 5 : 1) }
        } else if id == 18 {
            let position = (a / 10 - 1) * 9 + a % 10 - 1
            let next = (position + delta + 81) % 81
            a = (next / 9 + 1) * 10 + next % 9 + 1
        } else if id == 16 {
            if changeSecond { b = (b - 11 + delta + 9) % 9 + 11 } else { a = (a - 11 + delta + 9) % 9 + 11 }
        } else if id == 14 || id == 15 {
            if changeSecond {
                for _ in 0..<200 {
                    b = min(9999,max(15,b + delta))
                    let remainder = b % 100
                    if b % 100 != 0, b % 1000 != 0, remainder >= 89 || (1...11).contains(remainder) || b % 1000 >= 989 || (1...11).contains(b % 1000) { break }
                    if b == 15 || b == 9999 { break }
                }
            } else { a = min(9999,max(15,a + delta)) }
        } else if id == 4 {
            if changeSecond {
                var next = b + delta
                while (1...999999).contains(next), a % next != 0 { next += delta }
                if (1...999999).contains(next), a % next == 0 { b = next }
            } else { let next = a + delta * b; if (1...999999).contains(next) { a = next } }
        } else if let root = Self.roots[id] {
            let base = min(root.maximum,max(root.minimum,example.answer + delta)); a = Self.power(base,root.degree)
        } else if changeSecond {
            let step: Int64 = id == 21 ? 10 : 1
            let lower: Int64 = id == 21 ? 11 : 1, upper: Int64 = id == 21 ? 91 : fixedFirst ? 9999 : 999999
            let next = b + delta * step; if (lower...upper).contains(next) { b = next }
        } else if !fixedFirst {
            let defaults = RuleOperandDefaults.values[id] ?? [35,31,1,999]
            var lower = defaults[2], upper = defaults[3], step: Int64 = 1
            if let ending = Self.endings[id] { lower = ending.modulus + ending.ending; step = ending.modulus }
            if let divisor = Self.divisors[id] { step = divisor }
            if [37,40,42].contains(id) { step = id == 37 ? 2 : id == 40 ? 5 : 4 }
            if id == 21 { lower = 11; upper = 91; step = 10 }
            let next = a + delta * step; if (lower...upper).contains(next) { a = next }
        }
        return Self.make(trickID: id,first: a,second: b)
    }
}
