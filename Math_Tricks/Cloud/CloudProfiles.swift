import Foundation
import CryptoKit

/// Account snapshots and merge baselines are local, private and excluded from cloud payloads.
actor CloudProfiles {
    struct Metadata: Codable, Sendable {
        var base: CloudProgress?
        var revision: Int64 = 0
    }
    private let directory = FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("CloudProfiles",isDirectory:true)
    private func file(_ uid: String, suffix: String) throws -> URL {
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
        let name = SHA256.hash(data:Data(uid.utf8)).map { String(format:"%02x",$0) }.joined()
        return directory.appendingPathComponent(name + suffix)
    }
    func load(_ uid: String) throws -> ProgressArchive? {
        let path = try file(uid,suffix:".progress.json")
        guard FileManager.default.fileExists(atPath:path.path) else { return nil }
        let values = try path.resourceValues(forKeys:[.fileSizeKey])
        guard (values.fileSize ?? Int.max) <= ProgressArchive.maximumBytes else { throw CloudError.tooLarge }
        return try ProgressArchive.decode(Data(contentsOf:path))
    }
    func save(_ archive: ProgressArchive, uid: String) throws {
        try archive.encoded().write(to:file(uid,suffix:".progress.json"),options:[.atomic,.completeFileProtectionUntilFirstUserAuthentication])
    }
    func metadata(_ uid: String) throws -> Metadata {
        let path = try file(uid,suffix:".sync.json")
        guard FileManager.default.fileExists(atPath:path.path) else { return Metadata() }
        let values = try path.resourceValues(forKeys:[.fileSizeKey])
        guard (values.fileSize ?? Int.max) <= ProgressArchive.maximumBytes else { throw CloudError.tooLarge }
        let m = try JSONDecoder().decode(Metadata.self,from:Data(contentsOf:path))
        guard m.revision >= 0, m.revision < Int64.max else { throw CloudError.invalid }
        try m.base?.validate()
        return m
    }
    func saveMetadata(_ metadata: Metadata, uid: String) throws {
        try JSONEncoder().encode(metadata).write(to:file(uid,suffix:".sync.json"),options:[.atomic,.completeFileProtectionUntilFirstUserAuthentication])
    }
    func forget(_ uid: String) throws {
        for suffix in [".progress.json",".sync.json"] {
            let path = try file(uid,suffix:suffix)
            if FileManager.default.fileExists(atPath:path.path) { try FileManager.default.removeItem(at:path) }
        }
    }
}
