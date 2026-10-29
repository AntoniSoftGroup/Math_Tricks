import Foundation

/// Measurements retained by Android, without individual attempt history.
nonisolated struct ImportedPracticeRecord:Sendable {
    let id:String
    let expression:String?
    let trickID:Int?
    let level:Int?
    let input:Int64
    let first:TimeInterval?
    let best:TimeInterval?
    let solved:Int
    let clean:Int
    let errors:Int
    let hints:Int
    let attempts:Int
    var completeRange = false
    let total:TimeInterval
    var skipped:Int=0
    let cleanTime:TimeInterval
    func matches(input mode:GameInputMode?,levels:ClosedRange<Int>?)->Bool {
        let permitted:Bool
        switch mode {case .none:permitted=true;case .digits:permitted=input==0;case .choices:permitted=input==4;case .boolean:permitted=input==2}
        guard permitted else { return false }
        guard let levels, let level else { return true }
        return completeRange ? levels.lowerBound == level && levels.count == 10 : levels.contains(level)

    }
}

nonisolated extension AndroidProgressArchive {
    func practiceRecords(includeDetails: Bool = false)throws->[ImportedPracticeRecord] {
        var result:[ImportedPracticeRecord]=[]
        let groups=rows("game_trick_groups")
        let groupKeys=Set(groups.map{row in "\(row["trick"]?.integer ?? 0)/\(row["level"]?.integer ?? 0)/\(row["input_mode"]?.integer ?? -1)"})
        for (source,bucket) in [(rows("game_trick_records"),false),(groups,true)] {
        for row in source {
            guard let id=row["trick"]?.integer,let level=row["level"]?.integer,let input=row["input_mode"]?.integer else {throw ProgressError.invalidArchive}
            func count(_ key:String)throws->Int {
                guard let value=row[key]?.integer,(0...1_000_000_000_000).contains(value) else {throw ProgressError.invalidArchive};return Int(value)
            }
            func time(_ key:String)throws->Double? {
                guard let value=row[key]?.integer,(-1...1_000_000_000_000_000).contains(value) else {throw ProgressError.invalidArchive};return value>0 ? Double(value)/1000:nil
            }
            let solved=try count("solved"),clean=try count("clean"),attempts=try count("attempts")
            guard clean<=solved,solved<=attempts else {throw ProgressError.invalidArchive}
            let record=try ImportedPracticeRecord(id:String(id),expression:nil,trickID:Int(id),level:Int(level),input:input,first:time("first_time"),best:time("best_time"),solved:solved,clean:clean,errors:count("errors"),hints:count("hints"),attempts:attempts,completeRange:bucket,total:time("total_time") ?? 0,skipped:count("skipped"),cleanTime:time("clean_time") ?? 0)
            let groupKey="\(id)/\((level-1)/10*10+1)/\(input)"
            if includeDetails || bucket || !groupKeys.contains(groupKey) {result.append(record)}
        }
        }
        for row in rows("game_example_records") {
            guard let expression=row["expression"]?.string,let input=row["input_mode"]?.integer,let first=row["first_time"]?.integer,let best=row["best_time"]?.integer,first>=(-1),best>=(-1) else {throw ProgressError.invalidArchive}
            result.append(ImportedPracticeRecord(id:PracticeStatistics.normalizeExpression(expression),expression:expression,trickID:nil,level:nil,input:input,first:first>0 ? Double(first)/1000:nil,best:best>0 ? Double(best)/1000:nil,solved:0,clean:0,errors:0,hints:0,attempts:0,total:0,cleanTime:0))
        }
        // Bounded imported counters also keep all later aggregate additions safe.
        var total:Int64=0
        for record in result {
            for value in [record.solved,record.clean,record.errors,record.hints] {
                let addition=total.addingReportingOverflow(Int64(value));guard !addition.overflow,addition.partialValue <= (includeDetails ? 2_000_000_000_000_000 : 1_000_000_000_000_000) else {throw ProgressError.invalidArchive};total=addition.partialValue
            }
        }
        return result
    }
}
