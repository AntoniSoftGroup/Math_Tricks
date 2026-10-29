import Foundation
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore

nonisolated struct CloudRemote: Sendable {
    var progress: CloudProgress?
    var revision: Int64 = 0
}

/// Measure the exact strings sent to Firestore, including compression and Base64 overhead.
nonisolated struct CloudPayload {
    let progress: CloudProgress
    let main: [String:Any]
    let texts: [String]
    let fraction: Double
    init(_ source: CloudProgress) throws {
        var p = source
        // Android's released per-level cloud document covers levels 1...10.
        p.details = p.details.filter { $0.value[1] <= 10 }
        let map = try p.legacyMap(enforceCapacity:false)
        let raw = [Data(CloudProgress.encodeRows(p.metrics).utf8),Data(CloudProgress.encodeRows(p.groups).utf8),
            try JSONSerialization.data(withJSONObject:p.examples.sorted { $0.key < $1.key }.map { _,e -> [Any] in [e.expression,e.input,e.first,e.best] }),
            Data(CloudProgress.encodeRows(p.details).utf8)]
        let encoded = try raw.enumerated().map { index,data in index == 0 ? String(decoding:data,as:UTF8.self) : try CloudProgress.packed(data,limit:Int.max) }
        let graphText = p.graphs.values.map(\.encoded).joined()
        let graphData = (map["graphs"] as? [String:Any])?["data"] as? String ?? ""
        let fields = ["levels","byHeartLevels","byHeartUnlocked","coinUnlocks"].compactMap { map[$0] as? String }
        var ratios = encoded.map { Double($0.utf8.count) / Double(CloudProgress.limit) }
        ratios += raw.map { Double($0.count) / Double(CloudProgress.rawLimit) }
        ratios += [Double(try JSONSerialization.data(withJSONObject:map).count)/685_000,
            Double(fields.reduce(graphData.utf8.count) { $0 + $1.utf8.count })/685_000,
            Double(graphData.utf8.count)/600_000,Double(graphText.utf8.count)/2_000_000,Double(p.graphs.count)/20_000]
        fraction = ratios.max() ?? 0
        progress = p; main = map; texts = encoded
    }
}

@MainActor
final class CloudFirestore {
    private let database: Firestore
    init() {
        database = Firestore.firestore()
        let settings = database.settings
        settings.cacheSettings = MemoryCacheSettings()
        database.settings = settings
    }
    private func reference(_ uid: String, _ name: String) -> DocumentReference {
        database.collection("users").document(uid).collection("backups").document(name)
    }
    func read(uid: String) async throws -> CloudRemote {
        // Read the revision first so a concurrent save cannot pair a newer main document with stale statistics.
        let current = try await reference(uid,"current").getDocument(source:.server)
        async let metrics = reference(uid,"level_statistics").getDocument(source:.server)
        async let groups = reference(uid,"trick_statistics").getDocument(source:.server)
        async let examples = reference(uid,"example_statistics").getDocument(source:.server)
        async let details = reference(uid,"trick_level_statistics").getDocument(source:.server)
        let values = try await (metrics,groups,examples,details)
        return try Self.decode(current:current,extras:[values.0,values.1,values.2,values.3])
    }
    nonisolated private static func decode(current: DocumentSnapshot, extras: [DocumentSnapshot]) throws -> CloudRemote {
        guard current.exists else {
            guard !extras.contains(where: \.exists) else { throw CloudError.invalid }
            return CloudRemote()
        }
        guard let data = current.data(), Set(data.keys) == Set(["schemaVersion","revision","updatedAt","progress"]),
              try CloudProgress.integer(data["schemaVersion"],min:1,max:1) == 1,
              data["updatedAt"] is Timestamp, let wire = data["progress"] as? [String:Any] else { throw CloudError.invalid }
        let revision = try CloudProgress.integer(data["revision"],min:1)
        var p = try CloudProgress(legacyMap:wire)
        for doc in extras where doc.exists {
            guard let d = doc.data() else { throw CloudError.invalid }
            let detailed = doc.documentID == "trick_level_statistics", compressed = doc.documentID != "level_statistics"
            let fields = ["schemaVersion","revision","updatedAt","data"] + (compressed ? ["encoding"] : []) + (detailed ? ["resetAt"] : [])
            guard Set(d.keys) == Set(fields), try CloudProgress.integer(d["schemaVersion"],min:1,max:1) == 1,
                  d["updatedAt"] is Timestamp, try CloudProgress.integer(d["revision"],min:1) <= revision else { throw CloudError.changed }
            let text: String
            if compressed {
                guard d["encoding"] as? String == "gzip-base64", let decoded = String(data:try CloudProgress.unpacked(d["data"]),encoding:.utf8) else { throw CloudError.invalid }
                text = decoded
            } else {
                guard let decoded = d["data"] as? String, decoded.utf8.count <= CloudProgress.limit else { throw CloudError.invalid }; text = decoded
            }
            switch doc.documentID {
            case "level_statistics": p.metrics = try CloudProgress.decodeRows(text,columns:6); p.hasMetrics = true
            case "trick_statistics": p.groups = try CloudProgress.decodeRows(text,columns:13,keys:3); p.hasGroups = true
            case "trick_level_statistics":
                let reset = try CloudProgress.integer(d["resetAt"],max:4_102_444_800_000)
                p.hasDetails = true
                if reset >= (p.stats["statisticsResetAt"] ?? 0) { p.details = try CloudProgress.decodeRows(text,columns:13,keys:3) }
            case "example_statistics":
                guard let rows = try JSONSerialization.jsonObject(with:Data(text.utf8)) as? [[Any]], rows.count <= 1_000_000 else { throw CloudError.invalid }
                for r in rows {
                    guard r.count == 4, let expression = r[0] as? String else { throw CloudError.invalid }
                    let e = CloudProgress.Example(expression:PracticeStatistics.normalizeExpression(expression),input:try CloudProgress.integer(r[1],max:4),first:try CloudProgress.integer(r[2],min:1),best:try CloudProgress.integer(r[3],min:1))
                    guard p.examples.updateValue(e,forKey:e.key) == nil else { throw CloudError.invalid }
                }
                p.hasExamples = true
            default: throw CloudError.invalid
            }
        }
        try p.validate()
        return CloudRemote(progress:p,revision:revision)
    }

    func write(_ progress: CloudProgress, uid: String, expectedRevision: Int64) async throws -> CloudRemote {
        guard expectedRevision < Int64.max - 1 else { throw CloudError.invalid }
        let payload = try CloudPayload(progress)
        guard payload.fraction <= 1 else { throw CloudError.tooLarge }
        let p = payload.progress, main = payload.main, texts = payload.texts
        let current = reference(uid,"current")
        let extraRefs = ["level_statistics","trick_statistics","example_statistics","trick_level_statistics"].map { reference(uid,$0) }
        let next = expectedRevision + 1
        let reset = p.stats["statisticsResetAt"] ?? 0
        _ = try await database.runTransaction { @Sendable transaction,errorPointer -> Any? in
            do {
                guard Auth.auth().currentUser?.uid == uid else { throw CloudError.accountChanged }
                let old = try transaction.getDocument(current)
                let revision = old.exists ? try CloudProgress.integer(old.data()?["revision"],min:1) : 0
                guard revision == expectedRevision else { throw CloudError.changed }
                transaction.setData(["schemaVersion":1,"revision":next,"updatedAt":FieldValue.serverTimestamp(),"progress":main],forDocument:current)
                for (index,ref) in extraRefs.enumerated() {
                    var d: [String:Any] = ["schemaVersion":1,"revision":next,"updatedAt":FieldValue.serverTimestamp(),"data":texts[index]]
                    if index != 0 { d["encoding"] = "gzip-base64" }
                    if index == 3 { d["resetAt"] = reset }
                    transaction.setData(d,forDocument:ref)
                }
                return next
            } catch { errorPointer?.pointee = error as NSError; return nil }
        }
        return CloudRemote(progress:p,revision:next)
    }
}
