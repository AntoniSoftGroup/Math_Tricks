import Foundation

/// Single arithmetic expressions from Android hintExpr; descriptions and HTML
/// are never evaluated. Candidates follow StepExpressionParser's method rules.
nonisolated enum SolutionSubexpression {
    static func examples(from text: String) -> [MathExample] {
        var expression = text.replacingOccurrences(of: "=",with: "").replacingOccurrences(of: "?",with: "")
        for (source,target) in [("−","-"),("–","-"),("—","-"),("x","×"),("X","×"),("*","×"),(":","÷"),("/","÷"),("²","^2"),("³","^3"),("⁴","^4"),("⁵","^5"),("⁶","^6"),("⁹","^9")] {
            expression = expression.replacingOccurrences(of: source,with: target)
        }
        let pattern = #"^\s*(\d+)\s*([+\-×÷^])\s*(\d+)\s*$"#
        guard let parser = try? NSRegularExpression(pattern: pattern),
              let match = parser.firstMatch(in: expression,range: NSRange(expression.startIndex...,in: expression)),
              let firstRange = Range(match.range(at: 1),in: expression), let secondRange = Range(match.range(at: 3),in: expression),
              let signRange = Range(match.range(at: 2),in: expression),
              let first = Int64(expression[firstRange]), let second = Int64(expression[secondRange]),
              first <= 1_000_000, second <= 1_000_000 else { return [] }
        let sign = String(expression[signRange])
        if ["×","÷"].contains(sign), powerOfTen(first) || powerOfTen(second) { return [] }
        var output: [MathExample] = []
        func add(_ key: String,_ a: Int64,_ b: Int64,_ operation: MathExample.Operation) {
            guard let trick = TrickCatalog.shared.tricks.first(where: { $0.key == "trick_" + key }) else { return }
            let value: Double
            switch operation {
            case .addition: value = Double(a) + Double(b)
            case .subtraction: value = Double(a) - Double(b)
            case .multiplication: value = Double(a) * Double(b)
            case .division: guard b > 0 else { return }; value = Double(a) / Double(b)
            case .power: guard b <= 30 else { return }; value = pow(Double(a),Double(b))
            default: return
            }
            guard value.isFinite, value >= 0, value <= 1_000_000_000_000_000,
                  abs(value - value.rounded()) < 0.01, let answer = Int64(exactly: value.rounded()) else { return }
            let example = MathExample(trickID: trick.id,operand1: a,operand2: b,displayedOperand1: Double(a),displayedOperand2: Double(b),answer: answer,operation: operation)
            guard !output.contains(where: { $0.trickID == example.trickID }),
                  let steps = try? SolutionStep.generate(example), steps.filter({ !$0.isIntro && !$0.isFinal }).count > 1 else { return }
            output.append(example)
        }
        func square(_ base: Int64) {
            guard let key = squareKey(base) else { return }; add(key,base,2,.power)
        }
        switch sign {
        case "+":
            add("addition",first,second,.addition)
            if first >= 15, second >= 15, first < 10_000, second < 10_000, first % 100 != 0, second % 100 != 0, closeToRound(first) || closeToRound(second) {
                add("adding_numbers_close_to_hundreds",first,second,.addition)
            }
        case "-":
            let a = max(first,second), b = min(first,second)
            add("subtraction",a,b,.subtraction)
            if a == 1000 || a == 10_000 { add("subtracting_from_1000",a,b,.subtraction) }
            let nearest = (b % 100 >= 50 ? b / 100 + 1 : b / 100) * 100
            if a >= 15, b >= 15, a < 10_000, b < 10_000, a > b, a % 100 != 0, a - b > 10, nearest != a, closeToRound(a) || closeToRound(b) {
                add("subtracting_numbers_close_to_hundreds",a,b,.subtraction)
            }
        case "÷":
            guard second > 0, first.isMultiple(of: second) else { return [] }
            add("division",first,second,.division)
            if [2,3,4,5,6,7,8,9,15,20,25,40,50].contains(second) { add("dividing_by_\(second)",first,second,.division) }
        case "×":
            let a = max(first,second), b = min(first,second)
            add("multiplication",a,b,.multiplication)
            if a == b { square(a) }
            let constants: [Int64:String] = [2:"2",3:"3",4:"4",5:"5",6:"6",7:"7",8:"8",9:"9",11:"11_2digit",12:"12",13:"13",14:"14",15:"15",16:"16",17:"17",18:"18",19:"19",20:"20",25:"25",50:"50",75:"75",99:"99"]
            if let name = constants[b] { add("multiply_by_" + name,a,b,.multiplication) }
            else if let name = constants[a] { add("multiply_by_" + name,b,a,.multiplication) }
            if (11...19).contains(a), (11...19).contains(b) { add("multiply_numbers_between_11_and_19",a,b,.multiplication) }
            else if (10...99).contains(a), (10...99).contains(b) {
                if a / 10 == b / 10, a % 10 + b % 10 == 10 { add("multiply_two_digit_numbers_having_same_tens",a,b,.multiplication) }
                else if a % 10 == 1, b % 10 == 1 { add("multiply_two_digit_numbers_editing_in_1",a,b,.multiplication) }
            }
            // The Android builder validates the suitable near-round cases.
            if toughSuitable(b,a) { add("tough_multiplication",a,b,.multiplication) }
        case "^":
            if second == 2 { square(first); add("multiplication",first,first,.multiplication) }
            if first == 2 { add("power_of_two",2,second,.power) }
            else if second == 3 {
                if (1...99).contains(first) { add("power_3",first,3,.power) }
                else if (100...999).contains(first) { add("power_3_between_100_and_999",first,3,.power) }
            } else if [4,6,9].contains(second) { add("power_\(second)",first,second,.power) }
        default: break
        }
        return output
    }
    private static func toughSuitable(_ first: Int64,_ second: Int64) -> Bool {
        guard first > 2 else { return false }
        func factor(_ value:Int64) -> Int64 {
            for divisor in [Int64(10),11,3,2] where value > divisor && value.isMultiple(of: divisor) { return divisor }; return 0
        }
        let divideFirst = factor(first) != 0
        guard divideFirst || first % 5 == 0 && second % 2 == 0 else { return false }
        var a=first,b=second,iterations=0
        while true {
            let f=factor(divideFirst ? a : b); if f == 0 { break }
            let nextA=divideFirst ? a/f : a*f, nextB=divideFirst ? b*f : b/f
            if !divideFirst && nextA>nextB { break }
            a=nextA;b=nextB;iterations+=1
            if !divideFirst && (a % 10 == 0 || a>=b) { break }
        }
        return iterations>0 && !(a==first && b==second) && !(a==second && b==first)
    }
    private static func powerOfTen(_ value: Int64) -> Bool {
        guard value > 0 else { return false }; var n = value
        while n > 1 && n % 10 == 0 { n /= 10 }; return n == 1
    }
    private static func closeToRound(_ value: Int64) -> Bool {
        guard value >= 15, value % 100 != 0, value % 1000 != 0 else { return false }
        let a = value % 100, b = value % 1000
        return a >= 89 || (1...11).contains(a) || b >= 989 || (1...11).contains(b)
    }
    private static func squareKey(_ base: Int64) -> String? {
        guard base > 5 else { return nil }
        for (divisor,remainder,key) in [(1000,125,"125"),(100,25,"25"),(100,75,"75"),(100,5,"05"),(100,15,"15"),(100,95,"95")] {
            if base % Int64(divisor) == remainder, base > remainder { return "square_numbers_editing_in_" + key }
        }
        if base % 10 == 5, base >= 15 { return "square_numbers_editing_in_5" }
        if (10...89).contains(base) { let ten = base / 10 * 10; return "square_number_between_\(ten)_and_\(ten + 9)" }
        if (100...109).contains(base) { return "square_number_between_100_and_109" }
        if (11...99).contains(base) { return "power_2" }
        if (100...999).contains(base) { return "power_2_between_100_and_999" }
        if (1000...9999).contains(base) { return "power_2_between_1000_and_9999" }
        return nil
    }
}
