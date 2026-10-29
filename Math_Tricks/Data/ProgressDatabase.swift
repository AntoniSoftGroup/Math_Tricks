import Foundation
import SQLite3

/// Used only by ProgressRepository's actor. Every statement is bound and finalized.
nonisolated final class ProgressDatabase {
    enum Value {
        case integer(Int64), text(String), blob(Data), null
        var integer: Int64? { if case .integer(let value) = self { return value }; return nil }
        var text: String? { if case .text(let value) = self { return value }; return nil }
        var data: Data? { if case .blob(let value) = self { return value }; return nil }
    }
    let url: URL
    private var handle: OpaquePointer?
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    init(url: URL) throws {
        self.url = url
        let files = FileManager.default
        if !files.fileExists(atPath: url.path), ["-wal", "-shm"].contains(where: {
            files.fileExists(atPath: url.path + $0)
        }) { throw ProgressError.invalidState }
        try files.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let code = sqlite3_open_v2(url.path, &handle, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil)
        guard code == SQLITE_OK else {
            let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "Cannot open store."
            sqlite3_close_v2(handle)
            handle = nil
            throw ProgressError.database(message)
        }
        do {
            sqlite3_busy_timeout(handle, 5000)
            try execute("PRAGMA foreign_keys = ON")
        } catch {
            sqlite3_close_v2(handle)
            handle = nil
            throw error
        }
    }

    deinit { sqlite3_close_v2(handle) }

    func configureDurability() throws {
        _ = try query("PRAGMA journal_mode = WAL")
        try execute("PRAGMA synchronous = FULL")
    }

    func execute(_ sql: String, _ values: [Value] = []) throws {
        let statement = try prepare(sql, values)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_DONE else { throw failure() }
    }

    func query(_ sql: String, _ values: [Value] = []) throws -> [[Value]] {
        let statement = try prepare(sql, values)
        defer { sqlite3_finalize(statement) }
        var result: [[Value]] = []
        while true {
            let code = sqlite3_step(statement)
            if code == SQLITE_DONE { return result }
            guard code == SQLITE_ROW else { throw failure() }
            var row: [Value] = []
            for column in 0..<sqlite3_column_count(statement) {
                switch sqlite3_column_type(statement, column) {
                case SQLITE_INTEGER: row.append(.integer(sqlite3_column_int64(statement, column)))
                case SQLITE_TEXT:
                    guard let text = sqlite3_column_text(statement, column) else { throw ProgressError.invalidState }
                    row.append(.text(String(cString: text)))
                case SQLITE_BLOB:
                    let count = Int(sqlite3_column_bytes(statement, column))
                    if count == 0 { row.append(.blob(Data())) }
                    else if let bytes = sqlite3_column_blob(statement, column) {
                        row.append(.blob(Data(bytes: bytes, count: count)))
                    } else { throw ProgressError.invalidState }
                case SQLITE_NULL: row.append(.null)
                default: throw ProgressError.invalidState
                }
            }
            result.append(row)
        }
    }

    func transaction<T>(_ body: () throws -> T) throws -> T {
        try execute("BEGIN IMMEDIATE")
        do {
            let result = try body()
            try execute("COMMIT")
            return result
        } catch {
            try? execute("ROLLBACK")
            throw error
        }
    }

    func backup(to url: URL) throws {
        let destination = try ProgressDatabase(url: url)
        guard let backup = sqlite3_backup_init(destination.handle, "main", handle, "main") else { throw destination.failure() }
        let code = sqlite3_backup_step(backup, -1)
        let finish = sqlite3_backup_finish(backup)
        guard code == SQLITE_DONE, finish == SQLITE_OK else { throw destination.failure() }
    }

    private func prepare(_ sql: String, _ values: [Value]) throws -> OpaquePointer {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else { throw failure() }
        do {
            guard Int(sqlite3_bind_parameter_count(statement)) == values.count else { throw ProgressError.invalidValue }
            for (offset, value) in values.enumerated() {
                let index = Int32(offset + 1)
                let code: Int32
                switch value {
                case .integer(let value): code = sqlite3_bind_int64(statement, index, value)
                case .text(let value): code = sqlite3_bind_text(statement, index, value, -1, transient)
                case .blob(let value):
                    guard value.count <= Int(Int32.max) else { throw ProgressError.invalidValue }
                    if value.isEmpty { code = sqlite3_bind_zeroblob(statement, index, 0) }
                    else {
                        code = value.withUnsafeBytes { sqlite3_bind_blob(statement, index, $0.baseAddress, Int32(value.count), transient) }
                    }
                case .null: code = sqlite3_bind_null(statement, index)
                }
                guard code == SQLITE_OK else { throw failure() }
            }
            return statement
        } catch {
            sqlite3_finalize(statement)
            throw error
        }
    }

    private func failure() -> ProgressError {
        .database(handle.map { String(cString: sqlite3_errmsg($0)) } ?? "Store is closed.")
    }
}
