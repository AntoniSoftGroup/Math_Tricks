import Foundation

/// A projection only: saved IDs and parent IDs are never rewritten in Core Data.
nonisolated struct LegacyTrickMapping: Sendable {
    private struct Document: Decodable {
        let version: Int
        let entries: [Entry]
    }
    private struct Entry: Decodable, Sendable {
        let legacyID: Int64
        let androidID: Int
        let legacyName: String
        let canonicalName: String
        let basis: String
    }
    private let entries: [Int64: Entry]

    init(bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "LegacyTrickMapping", withExtension: "json") else {
            throw LegacyProgressError.invalidMapping
        }
        let document = try JSONDecoder().decode(Document.self, from: Data(contentsOf: url))
        guard document.version == 1, document.entries.count == 107,
              Set(document.entries.map(\.legacyID)).count == document.entries.count,
              Set(document.entries.map(\.androidID)).count == document.entries.count,
              document.entries.allSatisfy({ $0.legacyID > 0 && $0.androidID > 0 }) else {
            throw LegacyProgressError.invalidMapping
        }
        entries = Dictionary(uniqueKeysWithValues: document.entries.map { ($0.legacyID, $0) })
    }

    func androidID(for legacyID: Int64?) -> Int? {
        legacyID.flatMap { entries[$0]?.androidID }
    }
}
