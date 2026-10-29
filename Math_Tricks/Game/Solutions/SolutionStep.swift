import Foundation

nonisolated struct SolutionArrow: Decodable, Sendable {
    let startOffset, endOffset: Int
    let color, labelColor: UInt32
    let isDimmed, startGap, targetGap: Bool
    let curveAmount: Double
    let label: String
    let isSquareBox, alwaysShowLabel, noHead: Bool
    let startTokenLength, tokenLength: Int
    let isCarryFlight, centerBetweenArrows, drawDashedDivider: Bool
    let dividerOffset: Int
}
nonisolated struct SolutionStep: Decodable, Sendable {
    let description, hintExpr, equation, expectedAnswer: String
    let isFinal, isIntro: Bool
    let pulseIndex: Int
    let arrows, frozenArrows: [SolutionArrow]
    let crossedOutOffsets, transparentOffsets: [Int]
    let highlightedRanges: [[Int]]
    static func generate(_ example: MathExample, variant: Int = 0) throws -> [SolutionStep] {
        guard let pointer = MTCreateSolutionSteps(Int32(example.trickID), example.operand1, example.operand2, Int32(variant)) else { throw ProgressError.invalidValue }
        defer { MTFreeSolutionSteps(pointer) }
        let bytes = Data(String(cString: pointer).utf8)
        let steps = try JSONDecoder().decode([SolutionStep].self, from: bytes)
        guard !steps.isEmpty else { throw ProgressError.invalidState }
        return steps
    }
    struct DisplayedEquation: Sendable {
        let text: String
        let sourceOffsets: [Int]
        let cursorOffset: Int?
        func removingLeadingBlankLines() -> DisplayedEquation {
            let units = Array(text.utf16)
            var start = 0
            while start < units.count {
                var end = start
                while end < units.count, units[end] == 32 || units[end] == 9 || units[end] == 13 { end += 1 }
                guard end < units.count, units[end] == 10 else { break }
                start = end + 1
            }
            guard start > 0 else { return self }
            return DisplayedEquation(text: String(decoding: units.dropFirst(start), as: UTF16.self),
                                     sourceOffsets: Array(sourceOffsets.dropFirst(start)),
                                     cursorOffset: cursorOffset.flatMap { $0 >= start ? $0 - start : nil })
        }
        func range(_ offset: Int, length: Int = 1) -> NSRange? {
            guard offset >= 0, length >= 0 else { return nil }
            let positions = sourceOffsets.indices.filter { sourceOffsets[$0] >= offset && sourceOffsets[$0] < offset + max(1,length) }
            guard let first = positions.first, let last = positions.last else { return nil }
            return NSRange(location: first, length: last - first + 1)
        }
    }
    func processedEquation(input: String, trickID: Int) -> DisplayedEquation {
        // The same three branches as Android prepareEquation: column digits,
        // duplicated square placeholders, and ordinary decimal placeholders.
        var units = Array(equation.utf16)
        var offsets = Array(units.indices)
        let source = equation as NSString
        let newline = source.range(of: "\n")
        let searchStart = newline.location == NSNotFound ? 0 : NSMaxRange(newline)
        let column = trickID == 1 || trickID == 2 || equation.contains("\n× ")
        let typed = Array(input.utf16)
        if !isFinal {
            let search = NSRange(location: searchStart, length: source.length - searchStart)
            let underscore = source.range(of: " _ ", range: search)
            let powRange = underscore.location == NSNotFound ? NSRange(location: NSNotFound,length: 0) : source.range(of: "²", range: NSRange(location: underscore.location,length: source.length - underscore.location))
            let before = underscore.location == NSNotFound ? NSRange(location: 0,length: 0) : NSRange(location: 0,length: underscore.location)
            let minus = source.range(of: "-",options: .backwards,range: before)
            let plus = source.range(of: "+",options: .backwards,range: before)
            let operatorIndex = [minus.location,plus.location].filter { $0 != NSNotFound }.max()
            let firstQuestion = operatorIndex.map { source.range(of: "?",range: NSRange(location: $0,length: source.length - $0)).location }
            let dual = operatorIndex.map { $0 >= searchStart } == true && underscore.location != NSNotFound && powRange.location != NSNotFound && firstQuestion.map { $0 < powRange.location } == true
            if column {
                var character = 0
                for position in units.indices.reversed() where units[position] == 63 {
                    if character < typed.count { units[position] = typed[character]; character += 1 }
                }
            } else if dual, let op = operatorIndex {
                let firstStart = op + 1, firstEnd = underscore.location
                let secondStart = NSMaxRange(underscore), secondEnd = powRange.location
                let count = firstEnd - firstStart
                let replacement = (0..<count).map { $0 < typed.count ? typed[$0] : UInt16(63) }
                for (begin,end) in [(secondStart,secondEnd),(firstStart,firstEnd)] {
                    units.replaceSubrange(begin..<end,with: replacement)
                    offsets.replaceSubrange(begin..<end,with: (0..<count).map { begin + min($0,max(0,end-begin-1)) })
                }
            } else {
                var character = 0, position = searchStart
                while position < units.count {
                    if units[position] == 63 && character < typed.count {
                        let value = typed[character]
                        if (48...57).contains(value) || value == 45 {
                            units[position] = value; character += 1
                            if character < typed.count, typed[character] == 46 || typed[character] == 44 {
                                units.insert(46,at: position + 1); offsets.insert(offsets[position],at: position + 1)
                                position += 1; character += 1
                            }
                        } else if value == 46 || value == 44 {
                            units.insert(46,at: position); offsets.insert(offsets[position],at: position)
                            position += 1; character += 1
                        }
                    }
                    position += 1
                }
            }
        }
        let candidates = units.indices.filter { units[$0] == 63 && (column || $0 >= searchStart) }
        return DisplayedEquation(text: String(decoding: units,as: UTF16.self),sourceOffsets: offsets,cursorOffset: isFinal ? nil : column ? candidates.last : candidates.first)
    }
}
