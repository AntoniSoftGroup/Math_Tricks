import UIKit

nonisolated enum MathExpressionFormatter {
    private static let numberLock=NSLock()
    nonisolated(unsafe) private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter(); formatter.locale = .autoupdatingCurrent
        formatter.minimumFractionDigits = 0; formatter.maximumFractionDigits = 2; formatter.usesGroupingSeparator = false
        return formatter
    }()
    static func number(_ value: Double) -> String {
        numberLock.lock();defer{numberLock.unlock()}
        return numberFormatter.string(from: NSNumber(value: value)) ?? String(value)
    }
    static func text(_ example: MathExample) -> String {
        let first = number(example.displayedOperand1), second = number(example.displayedOperand2)
        switch example.operation {
        case .addition: return "\(first) + \(second)"
        case .subtraction: return "\(first) − \(second)"
        case .multiplication: return "\(first) × \(second)"
        case .division: return "\(first) ÷ \(second)"
        case .power: return first + superscript(String(example.operand2))
        case .root: return (example.operand2 == 2 ? "" : superscript(String(example.operand2))) + "√" + first
        case .percent: return "\(first)% → \(second)"
        }
    }
    private static func superscript(_ text: String) -> String {
        let digits: [Character: Character] = ["0":"⁰","1":"¹","2":"²","3":"³","4":"⁴","5":"⁵","6":"⁶","7":"⁷","8":"⁸","9":"⁹"]
        return String(text.map { digits[$0] ?? $0 })
    }
}
