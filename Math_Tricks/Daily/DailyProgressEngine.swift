import Foundation

nonisolated struct DailyReminderSettings: Codable, Sendable, Equatable {
    var hour=12
    var minute=0
    var difficulty=1
}
nonisolated enum DailyOptionsChange: Sendable { case time(hour:Int,minute:Int), difficulty(Int), target(Int), notifications(Bool) }

/// Android LocalProgressStore daily rules, using local Gregorian calendar days.
/// A day is awarded only by an accepted real answer, never by opening a screen.
nonisolated enum DailyProgressEngine {
    private static func calendar(_ timezone:TimeZone)->Calendar{var c=Calendar(identifier:.gregorian);c.timeZone=timezone;return c}
    static func dayKey(_ date:Date,timeZone:TimeZone = .current)->String{
        let parts=calendar(timeZone).dateComponents([.year,.month,.day],from:date)
        return String(format:"%04d-%02d-%02d",parts.year!,parts.month!,parts.day!)
    }
    static func dayNumber(_ key: String) -> Int? {
        date(key, timeZone: TimeZone(secondsFromGMT: 0)!).map { Int(floor($0.timeIntervalSince1970 / 86400)) }
    }
    static func isValidDayKey(_ key:String)->Bool {
        guard key.utf8.count==10,let value=date(key,timeZone:TimeZone(secondsFromGMT:0)!) else{return false}
        return dayKey(value,timeZone:TimeZone(secondsFromGMT:0)!)==key
    }
    private static func date(_ key:String,timeZone:TimeZone)->Date?{
        let p=key.split(separator:"-").compactMap{Int($0)};guard p.count==3 else{return nil}
        return calendar(timeZone).date(from:DateComponents(year:p[0],month:p[1],day:p[2]))
    }
    static func advance(_ state:inout ProgressState,now:Date,timeZone:TimeZone = .current) throws {
        let today=dayKey(now,timeZone:timeZone)
        guard let previous=state.daily.dayKey else {state.daily.dayKey=today;return}
        // Clock rollback never closes or awards the same calendar day twice.
        guard today>previous,let old=date(previous,timeZone:timeZone),let current=date(today,timeZone:timeZone),
              let gap=calendar(timeZone).dateComponents([.day],from:old,to:current).day,gap>0 else{return}
        var daily=state.daily
        if daily.seriesStartDay == nil, daily.streak > 0, let day = dayNumber(previous) {
            daily.seriesStartDay = max(1, day - Int(min(Int64(Int32.max), daily.streak)) + 1)
        }
        let complete=daily.completedToday ?? (daily.solved>=daily.target && daily.streak>0)
        if daily.solved>0 || daily.streak>0 {
            let point=DailyHistoryPoint(dayKey:previous,solved:daily.solved,target:daily.target,streak:complete ? daily.streak : 0,seriesStartDay:complete ? daily.seriesStartDay : nil)
            var history=state.dailyHistory ?? [];history.removeAll{$0.dayKey==previous};history.append(point);state.dailyHistory=history
        }
        let pending=daily.pendingStreak ?? 0
        let shields=max(0,daily.readyInsurance ?? 0)
        let missed=pending>0 ? max(1,daily.pendingCost ?? 1)+gap : gap-(daily.solved>=daily.target ? 1 : 0)
        let recover=(pending>0 || daily.streak>0) && missed>0 && missed<=shields
        let broken=pending>0 || gap>1 || daily.solved<daily.target
        if broken {
            daily.pendingStreak=recover ? (pending>0 ? pending : daily.streak) : 0
            daily.pendingCost=recover ? missed : 0;daily.pendingDay=recover ? today : nil
            daily.endedDay = !recover && (daily.streak>0 || pending>0) ? today : nil
            if !recover { daily.seriesStartDay = nil }
            daily.streak=0
        }
        daily.solved=0;daily.completedToday=false;daily.dayKey=today;state.daily=daily
    }
    static func record(_ count:Int64,in state:inout ProgressState,now:Date) throws {
        try advance(&state,now:now)
        guard count>0 else{return}
        let (solved,overflow)=state.daily.solved.addingReportingOverflow(count);guard !overflow else{throw ProgressError.overflow};state.daily.solved=solved
        guard solved>=max(1,state.daily.target),state.daily.completedToday != true else{return}
        var daily=state.daily
        var shields=max(0,daily.readyInsurance ?? 0)
        let pending=daily.pendingStreak ?? 0,cost=max(1,daily.pendingCost ?? 1)
        if pending>0,shields>=cost,daily.pendingDay==daily.dayKey {daily.streak=pending;shields-=cost;daily.shieldUsedDay=daily.dayKey}
        let progress=max(0,daily.insuranceProgress ?? 0)+1
        if progress>=7 {guard shields<Int.max else{throw ProgressError.overflow};shields+=1}
        daily.insuranceProgress=progress>=7 ? 0 : progress;daily.readyInsurance=shields
        let (streak,streakOverflow)=daily.streak.addingReportingOverflow(1);guard !streakOverflow else{throw ProgressError.overflow}
        if daily.seriesStartDay == nil, let key = daily.dayKey, let day = dayNumber(key) { daily.seriesStartDay = max(1, day - Int(min(Int64(Int32.max), streak)) + 1) }
        daily.streak=streak;daily.completedToday=true;daily.pendingStreak=0;daily.pendingCost=0;daily.pendingDay=nil;daily.endedDay=nil
        state.daily=daily
    }
}
