import Foundation

nonisolated enum MainText {
    static func text(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Main", bundle: .main, value: key, comment: "")
    }
    static func richFormat(_ key:String,_ value:String)->String {
        let format=NSLocalizedString(key,tableName:"MainRich",bundle:.main,value:text(key),comment:"")
        return String(format:format,locale:Locale.current,value)
    }
    static func count(_ key: String, _ number: Int64) -> String {
        String(format: text(key), locale: Locale.current, number)
    }
    static func format(_ key: String, _ value: String) -> String {
        String(format: text(key), locale: Locale.current, value)
    }
}
