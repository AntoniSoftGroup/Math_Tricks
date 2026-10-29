import CoreData

/// One serial owner of the original store. Disk work never runs on the UI actor.
actor LegacyProgressStorage {
    private var container: NSPersistentContainer?
    private var loadedSnapshot: LegacyProgressSnapshot?

    func load() throws -> LegacyProgressSnapshot {
        if let loadedSnapshot { return loadedSnapshot }
        let mapping = try LegacyTrickMapping()
        guard let modelURL = Bundle.main.url(forResource: "Math_Tricks", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL),
              let bundleID = Bundle.main.bundleIdentifier else {
            throw LegacyProgressError.modelUnavailable
        }
        let domain = UserDefaults.standard.persistentDomain(forName: bundleID) ?? [:]
        let preferences = try LegacyPreferences(domain: domain)
        let candidate = NSPersistentContainer(name: "Math_Tricks", managedObjectModel: model)
        guard let storeURL = candidate.persistentStoreDescriptions.first?.url else {
            throw LegacyProgressError.modelUnavailable
        }
        let files = FileManager.default
        let exists = files.fileExists(atPath: storeURL.path)
        var backupURL: URL?
        if exists {
            let metadata = try storeMetadata(at: storeURL)
            let sourceModel = try matchingModel(metadata: metadata, current: model, modelDirectory: modelURL)
            if !model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
                // Check that the historical version can migrate before opening it for writes.
                _ = try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: model)
            }
            backupURL = try backup(storeURL: storeURL, sourceModel: sourceModel,
                                   metadata: metadata, defaults: domain)
        } else {
            guard !["-wal", "-shm"].contains(where: {
                files.fileExists(atPath: storeURL.path + $0)
            }) else { throw LegacyProgressError.incompleteStore }
            guard preferences.initializationVersion == nil else { throw LegacyProgressError.missingStore }
        }

        try files.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        _ = try candidate.persistentStoreCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL,
            options: [NSMigratePersistentStoresAutomaticallyOption: true,
                      NSInferMappingModelAutomaticallyOption: true])
        let context = candidate.newBackgroundContext()
        let snapshot = try context.performAndWait {
            try LegacySnapshotReader.read(context: context, mapping: mapping, preferences: preferences,
                storeURL: storeURL, backupURL: backupURL, existing: exists)
        }
        container = candidate
        loadedSnapshot = snapshot
        return snapshot
    }

    private func storeMetadata(at url: URL) throws -> [String: Any] {
        try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType, at: url, options: [NSReadOnlyPersistentStoreOption: true])
    }

    private func matchingModel(metadata: [String: Any], current: NSManagedObjectModel,
                               modelDirectory: URL) throws -> NSManagedObjectModel {
        if current.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) { return current }
        for url in try FileManager.default.contentsOfDirectory(at: modelDirectory, includingPropertiesForKeys: nil)
            where url.pathExtension == "mom" {
            if let model = NSManagedObjectModel(contentsOf: url),
               model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) { return model }
        }
        throw LegacyProgressError.unsupportedStore
    }

    private func backup(storeURL: URL, sourceModel: NSManagedObjectModel,
                        metadata: [String: Any], defaults: [String: Any]) throws -> URL {
        guard let storeUUID = metadata[NSStoreUUIDKey] as? String,
              let uuid = UUID(uuidString: storeUUID) else { throw LegacyProgressError.unsupportedStore }
        let files = FileManager.default
        let backups = storeURL.deletingLastPathComponent()
            .appendingPathComponent("LegacyCompatibilityBackups", isDirectory: true)
        let destination = backups.appendingPathComponent("stage4-" + uuid.uuidString, isDirectory: true)
        if files.fileExists(atPath: destination.path) {
            try validateBackup(at: destination, storeUUID: storeUUID)
            return destination
        }
        try files.createDirectory(at: backups, withIntermediateDirectories: true)
        let pending = backups.appendingPathComponent(".pending-" + UUID().uuidString, isDirectory: true)
        try files.createDirectory(at: pending, withIntermediateDirectories: true)

        // Core Data handles the SQLite store and its journal; don't copy a live .sqlite alone.
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: sourceModel)
        try coordinator.replacePersistentStore(at: pending.appendingPathComponent("Math_Tricks.sqlite"),
            destinationOptions: nil, withPersistentStoreFrom: storeURL,
            sourceOptions: [NSReadOnlyPersistentStoreOption: true], ofType: NSSQLiteStoreType)
        let preferences = try PropertyListSerialization.data(fromPropertyList: defaults, format: .binary, options: 0)
        try preferences.write(to: pending.appendingPathComponent("UserDefaults.plist"), options: .atomic)
        let manifest: [String: Any] = ["compatibilityVersion": 1, "storeUUID": storeUUID,
                                       "createdAt": Date(), "originalMetadata": metadata]
        let receipt = try PropertyListSerialization.data(fromPropertyList: manifest, format: .binary, options: 0)
        try receipt.write(to: pending.appendingPathComponent("manifest.plist"), options: .atomic)
        try validateBackup(at: pending, storeUUID: storeUUID)
        // Publish only a complete backup. Interrupted temporary folders are never used.
        try files.moveItem(at: pending, to: destination)
        return destination
    }

    private func validateBackup(at directory: URL, storeUUID: String) throws {
        let manifestData = try Data(contentsOf: directory.appendingPathComponent("manifest.plist"))
        let defaultsData = try Data(contentsOf: directory.appendingPathComponent("UserDefaults.plist"))
        let manifest = try PropertyListSerialization.propertyList(from: manifestData, format: nil) as? [String: Any]
        let defaults = try PropertyListSerialization.propertyList(from: defaultsData, format: nil) as? [String: Any]
        let metadata = try storeMetadata(at: directory.appendingPathComponent("Math_Tricks.sqlite"))
        guard manifest?["storeUUID"] as? String == storeUUID,
              (manifest?["compatibilityVersion"] as? NSNumber)?.intValue == 1,
              metadata[NSStoreUUIDKey] as? String == storeUUID, defaults != nil else {
            throw LegacyProgressError.incompleteBackup
        }
    }
}
