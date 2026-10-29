import CoreData

/// Called exclusively on the managed object context's queue; no objects escape.
nonisolated enum LegacySnapshotReader {
    static func read(context: NSManagedObjectContext, mapping: LegacyTrickMapping,
                     preferences: LegacyPreferences, storeURL: URL, backupURL: URL?,
                     existing: Bool) throws -> LegacyProgressSnapshot {
        guard let coordinator = context.persistentStoreCoordinator,
              let store = coordinator.persistentStores.first,
              let identifier = coordinator.metadata(for: store)[NSStoreUUIDKey] as? String else {
            throw LegacyProgressError.unsupportedStore
        }
        func rows(_ entity: String) throws -> [NSManagedObject] {
            let request = NSFetchRequest<NSManagedObject>(entityName: entity)
            request.fetchBatchSize = 256
            return try context.fetch(request)
        }
        func integer(_ row: NSManagedObject, _ key: String) -> Int64? {
            (row.value(forKey: key) as? NSNumber)?.int64Value
        }
        func boolean(_ row: NSManagedObject, _ key: String) -> Bool? {
            (row.value(forKey: key) as? NSNumber)?.boolValue
        }
        func source(_ row: NSManagedObject) -> String { row.objectID.uriRepresentation().absoluteString }
        let tricks = try rows("Tricks").map { row in
            let id = integer(row, "id")
            return LegacyTrickProgress(sourceObject: source(row), legacyID: id,
                androidID: mapping.androidID(for: id), name: row.value(forKey: "name") as? String,
                checked: boolean(row, "checked"), status: boolean(row, "status"),
                statusFixed: boolean(row, "status_fixed"))
        }
        func levels(_ entity: String, kind: LegacyLevelProgress.Kind) throws -> [LegacyLevelProgress] {
            try rows(entity).map { row in
                let parent = integer(row, "parent_id")
                return LegacyLevelProgress(sourceObject: source(row), kind: kind,
                    legacyParentID: parent,
                    androidTrickID: kind == .trick ? mapping.androidID(for: parent) : nil,
                    level: integer(row, "id"), rating: integer(row, "rating"),
                    score: integer(row, "score"), unlocked: boolean(row, "status"))
            }
        }
        let graphs = try rows("Graphs").map { row in
            LegacyGraphProgress(sourceObject: source(row), legacyMode: integer(row, "id_game"),
                                date: row.value(forKey: "date") as? String, score: integer(row, "score"))
        }
        // Do not merge duplicates, discard unknown IDs, or infer unlocked levels.
        return LegacyProgressSnapshot(storeIdentifier: identifier, storeURL: storeURL, backupURL: backupURL,
            openedExistingStore: existing, preferences: preferences, tricks: tricks,
            trickLevels: try levels("Tricks_Levels", kind: .trick),
            multiplicationLevels: try levels("ByHeart_Multiplication", kind: .multiplication), graphs: graphs)
    }
}
