import Foundation

nonisolated struct LevelMeasurements:Codable,Sendable,Equatable {
    let errors:Int?
    let average:TimeInterval?
    let total:TimeInterval?
    func validate()throws {
        guard errors.map({(0...1_000_000_000).contains($0)}) ?? true,
              [average,total].compactMap({$0}).allSatisfy({$0.isFinite && (0...1_000_000_000_000).contains($0)}) else {throw ProgressError.invalidArchive}
    }
}
nonisolated extension GameSession {
    var levelMeasurements:LevelMeasurements {
        let correct=attempts.filter(\.independent)
        return LevelMeasurements(errors:attempts.filter{$0.errors+$0.corrections>0}.count,
            average:correct.isEmpty ? nil:correct.reduce(0){$0+$1.elapsed}/Double(correct.count),total:attempts.reduce(0){$0+$1.elapsed})
    }
}
