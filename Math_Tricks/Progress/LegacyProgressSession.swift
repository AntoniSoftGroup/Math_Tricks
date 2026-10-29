import Foundation

/// Multiple windows share one loading operation and cannot race store migration.
@MainActor
final class LegacyProgressSession {
    static let shared = LegacyProgressSession()
    private let storage = LegacyProgressStorage()
    private var loading: Task<LegacyProgressSnapshot, Error>?
    private(set) var snapshot: LegacyProgressSnapshot?

    private init() {}

    func prepare() async throws -> LegacyProgressSnapshot {
        if let snapshot { return snapshot }
        let task: Task<LegacyProgressSnapshot, Error>
        if let loading {
            task = loading
        } else {
            task = Task { try await storage.load() }
            loading = task
        }
        do {
            let value = try await task.value
            snapshot = value
            loading = nil
            return value
        } catch {
            loading = nil
            throw error
        }
    }
}
