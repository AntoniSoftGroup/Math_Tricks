import Foundation
import UIKit
import FirebaseCore
import AuthenticationServices
import GoogleSignIn
@preconcurrency import FirebaseAuth

@MainActor
final class CloudSync {
    static let shared = CloudSync()
    static let changed = Notification.Name("CloudSyncChanged")
    enum Action { case automatic, save, restore, reset }
    struct Conflict {
        let local: CloudProgress
        let remote: CloudProgress
        let revision: Int64
        let localRevision: Int64
    }
    private(set) var busy = false
    private(set) var blocksInteraction = false
    private(set) var fileOperationActive = false
    private(set) var status = CloudText.text("signedOut")
    private(set) var conflict: Conflict?
    private(set) var capacityFraction: Double = 0
    private let profiles = CloudProfiles()
    private let identity = CloudIdentity()
    private var database: CloudFirestore?
    private var authObservation: AuthStateDidChangeListenerHandle?
    private var timer: Task<Void,Never>?
    private weak var host: UIViewController?
    private var safeScreen = false
    private var lastRevision: Int64 = -1
    private var lastSync = Date.distantPast
    private var task: Task<Void,Never>?
    private let data = AppDataStore.shared
    var user: User? { FirebaseApp.app() == nil ? nil : Auth.auth().currentUser }
    var accountName: String { user?.displayName ?? user?.email ?? CloudText.text("account") }
    var hasGoogle: Bool { user?.providerData.contains { $0.providerID == "google.com" } == true }
    var hasApple: Bool { user?.providerData.contains { $0.providerID == "apple.com" } == true }
    private var safe: Bool {
        !fileOperationActive && safeScreen && UIApplication.shared.applicationState == .active && host?.viewIfLoaded?.window != nil
            && host?.presentedViewController == nil && !AppAdvertising.shared.isGatheringConsent
    }
    private func pauseKey(_ uid: String) -> String { "cloud.localResetOnly." + uid }
    private func notify() { NotificationCenter.default.post(name:Self.changed,object:self) }
    private func setBusy(_ value: Bool, blocking: Bool = true) {
        busy = value; blocksInteraction = value && blocking; notify()
    }
    func beginFileOperation() -> Bool {
        guard !busy, !fileOperationActive else { return false }
        fileOperationActive = true; notify(); return true
    }
    func endFileOperation() {
        fileOperationActive = false; notify()
    }
    private func validateSession(_ uid: String) throws { guard user?.uid == uid else { throw CloudError.accountChanged } }
    private func identityError(_ error: Error, previous: String) -> String {
        let e = error as NSError
        if (e.domain == ASAuthorizationError.errorDomain && e.code == ASAuthorizationError.canceled.rawValue)
            || (e.domain == kGIDSignInErrorDomain && e.code == GIDSignInError.canceled.rawValue) { return previous }
        if e.domain == AuthErrorDomain && [AuthErrorCode.credentialAlreadyInUse.rawValue,AuthErrorCode.accountExistsWithDifferentCredential.rawValue].contains(e.code) { return CloudText.text("linkedElsewhere") }
        NSLog("Cloud authentication: %@",e.localizedDescription)
        return error is CloudError ? error.localizedDescription : CloudText.text("signIn")
    }
    private func recordCapacity(_ value: Double, uid: String) {
        capacityFraction = value
        if value < 0.8 { UserDefaults.standard.removeObject(forKey:"cloud.capacityWarning." + uid) }
    }
    func offerCapacityWarning(from presenter: UIViewController, export: @escaping () -> Void) {
        guard !busy, safe, capacityFraction >= 0.8, let uid = user?.uid,
              !UserDefaults.standard.bool(forKey:"cloud.capacityWarning." + uid), presenter.presentedViewController == nil else { return }
        UserDefaults.standard.set(true,forKey:"cloud.capacityWarning." + uid)
        presenter.present(AppDialogViewController(title:CloudText.text("capacityTitle"),message:CloudText.text("capacityWarning"),actions:[
            .init(title:CloudText.text("later"),handler:{}),.init(title:CloudText.text("exportFile"),handler:export)
        ],data:data),animated:false)
    }
    func activate(from host: UIViewController, safeScreen: Bool) {
        self.host = host; self.safeScreen = safeScreen
        guard FirebaseApp.app() != nil else { status = CloudText.text("unavailable"); return }
        if database == nil {
            database = CloudFirestore()
            authObservation = Auth.auth().addStateDidChangeListener { [weak self] _,_ in
                Task { @MainActor in
                    guard let self, !self.busy else { return }
                    self.conflict = nil; self.capacityFraction = 0; self.lastRevision = -1; self.lastSync = .distantPast
                    self.status = self.user == nil ? CloudText.text("signedOut") : CloudText.text("pending")
                    self.notify(); self.synchronize(.automatic)
                }
            }
            timer = Task { [weak self] in
                while !Task.isCancelled {
                    do { try await Task.sleep(nanoseconds:30_000_000_000) } catch { return }
                    self?.synchronize(.automatic)
                }
            }
            #if DEBUG
            Task.detached(priority:.utility) {
                do { try CloudProgress.checkPolicy() } catch { assertionFailure("Invalid cloud serialization: \(error)") }
            }
            #endif
        }
        synchronize(.automatic)
    }
    func localProgressReplaced() {
        guard let uid = user?.uid else { return }
        UserDefaults.standard.set(true,forKey:pauseKey(uid))
        conflict = nil; status = CloudText.text("paused"); notify()
    }
    func signIn(_ provider: CloudIdentity.Provider, from presenter: UIViewController, link: Bool = false) {
        guard !busy, !fileOperationActive, FirebaseApp.app() != nil else { return }
        let previous = status
        setBusy(true); status = CloudText.text("connecting")
        task = Task {
            do {
                let original = user?.uid
                let (credential,_) = try await identity.credential(provider,from:presenter)
                if link {
                    guard let current = user, current.uid == original else { throw CloudError.accountChanged }
                    _ = try await current.link(with:credential)
                } else { _ = try await Auth.auth().signIn(with:credential) }
                status = CloudText.text(link ? "linked" : "pending")
                conflict = nil; capacityFraction = 0; lastSync = .distantPast; lastRevision = -1
            } catch {
                status = identityError(error,previous:previous)
            }
            setBusy(false)
            synchronize(.automatic)
        }
    }
    func signOut() {
        guard !busy, !fileOperationActive else { return }
        do { try identity.signOut(); conflict = nil; capacityFraction = 0; status = CloudText.text("signedOut"); notify() }
        catch { status = error.localizedDescription; notify() }
    }
    private func currentArchive() async throws -> ProgressArchive {
        let bytes = try await data.exportProgressArchive()
        return try await Task.detached(priority:.utility) { try ProgressArchive.decode(bytes) }.value
    }
    private func selectProfile(_ uid: String) async throws {
        let owner = try await data.cloudOwner()
        guard owner != uid else { return }
        let previous = try await currentArchive()
        try await profiles.save(previous,uid:owner)
        try validateSession(uid)
        if let profile = try await profiles.load(uid) {
            guard safe, data.snapshot?.revision == previous.state.revision else { throw CloudError.changed }
            try await data.importProgressArchive(profile,expectedRevision:previous.state.revision,cloudOwner:uid)
        } else if owner.isEmpty {
            guard safe, data.snapshot?.revision == previous.state.revision else { throw CloudError.changed }
            try await data.setCloudOwner(uid)
        } else {
            // A different account starts with its own empty progress, never another user's wallet.
            var state = ProgressState(legacy:try LegacyPreferences(domain:[:]))
            state.coins = 0; state.settings = previous.state.settings
            let empty = ProgressArchive(state:state,tricks:TrickCatalog.shared.tricks.map { .init(id:$0.id,selected:true,unlocked:$0.initiallyUnlocked) },levels:[],sessions:[],multiplayer:[],historicalGraphs:[])
            guard safe, data.snapshot?.revision == previous.state.revision else { throw CloudError.changed }
            try await data.importProgressArchive(empty,expectedRevision:previous.state.revision,cloudOwner:uid)
        }
    }
    func synchronize(_ action: Action = .save, choosingLocal: Bool? = nil, completion: ((Result<Void,Error>) -> Void)? = nil) {
        guard !busy, let uid = user?.uid, let database, safe else {
            completion?(.failure(CloudError.changed)); return
        }
        if action == .automatic {
            guard conflict == nil else { return }
            if UserDefaults.standard.bool(forKey:pauseKey(uid)) { status = CloudText.text("paused"); notify(); return }
            guard Date().timeIntervalSince(lastSync) >= 30,
                  lastRevision != data.snapshot?.revision || Date().timeIntervalSince(lastSync) >= 300 else { return }
        }
        let choice = conflict
        if choosingLocal == nil { conflict = nil }
        setBusy(true,blocking:action != .automatic); status = CloudText.text("syncing"); notify()
        task = Task {
            let began = ProcessInfo.processInfo.systemUptime
            var result: Result<Void,Error> = .failure(CloudError.changed)
            defer {
                NSLog("Cloud sync (%@): %.3f s",action == .automatic ? "automatic" : "manual",ProcessInfo.processInfo.systemUptime - began)
                completion?(result)
                setBusy(false)
            }
            do {
                try await selectProfile(uid)
                let localArchive = try await currentArchive()
                let (local,capacity) = try await Task.detached(priority:.utility) {
                    let p = try CloudProgress(archive:localArchive)
                    do { return (p,try CloudPayload(p).fraction) }
                    catch CloudError.tooLarge { return (p,1.0) }
                }.value
                recordCapacity(capacity,uid:uid)
                var metadata = try await profiles.metadata(uid)
                let remote = try await database.read(uid:uid)
                try validateSession(uid)
                guard safe, data.snapshot?.revision == localArchive.state.revision else { throw CloudError.changed }
                var target: CloudProgress
                if action == .restore {
                    guard let progress = remote.progress else { throw CloudError.missing }; target = progress
                } else if action == .reset {
                    target = CloudProgress()
                    let now = Int64(Date().timeIntervalSince1970*1000)
                    target.stats["statisticsResetAt"] = max(now,(local.stats["statisticsResetAt"] ?? 0) + 1)
                    for key in ["target","exitBehavior","alarmPromoShown"] { target.stats[key] = local.stats[key] }
                    target.stats["dayDate"] = now
                } else if let cloud = remote.progress {
                    if let choosingLocal {
                        guard choice?.revision == remote.revision, choice?.localRevision == localArchive.state.revision else { throw CloudError.changed }
                        let base = metadata.base
                        target = try await Task.detached(priority:.utility) { try CloudProgress.merge(local,cloud,localWallet:choosingLocal,base:base) }.value
                        conflict = nil
                    } else if metadata.base == nil && local.isEmpty { target = cloud }
                    else {
                        let changedLocal = metadata.base.map { !local.sameWallet($0) } ?? true
                        let changedCloud = metadata.base.map { !cloud.sameWallet($0) } ?? true
                        if changedLocal && changedCloud && !local.sameWallet(cloud) {
                            conflict = Conflict(local:local,remote:cloud,revision:remote.revision,localRevision:localArchive.state.revision)
                            status = CloudText.text("conflict"); return
                        }
                        let base = metadata.base
                        target = try await Task.detached(priority:.utility) { try CloudProgress.merge(local,cloud,localWallet:!changedCloud,base:base) }.value
                    }
                } else {
                    guard metadata.base == nil else { throw CloudError.missing }
                    target = local
                }
                let accepted: CloudRemote
                let prepared = target
                let (wireTarget,combinedCapacity) = try await Task.detached(priority:.utility) {
                    let payload = try CloudPayload(prepared)
                    return (payload.progress,payload.fraction)
                }.value
                recordCapacity(action == .restore || action == .reset ? combinedCapacity : max(capacity,combinedCapacity),uid:uid)
                guard safe, data.snapshot?.revision == localArchive.state.revision else { throw CloudError.changed }
                if action == .restore || wireTarget == remote.progress { accepted = remote }
                else { accepted = try await database.write(target,uid:uid,expectedRevision:remote.revision) }
                try validateSession(uid)
                metadata.base = accepted.progress; metadata.revision = accepted.revision
                guard safe, data.snapshot?.revision == localArchive.state.revision else { throw CloudError.changed }
                var synchronizedRevision = localArchive.state.revision
                if target != local || action == .restore || action == .reset {
                    if action == .automatic {
                        let applied = try await data.mergeCloudProgress(target,expectedRevision:localArchive.state.revision,cloudOwner:uid)
                        synchronizedRevision = applied.revision
                    } else {
                        let restoring = action == .restore || action == .reset
                        let applied = target
                        let result = try await Task.detached(priority:.utility) { try applied.archive(keeping:localArchive,restoring:restoring) }.value
                        guard safe, data.snapshot?.revision == localArchive.state.revision else { throw CloudError.changed }
                        try await data.importProgressArchive(result,expectedRevision:localArchive.state.revision,cloudOwner:uid)
                        synchronizedRevision = data.snapshot?.revision ?? localArchive.state.revision
                    }
                    try await DailyNotificationService.shared.schedule(data.snapshot)
                }
                // Advance the merge baseline only after the cloud result has been applied locally.
                try await profiles.saveMetadata(metadata,uid:uid)
                try await profiles.save(currentArchive(),uid:uid)
                UserDefaults.standard.removeObject(forKey:pauseKey(uid))
                lastRevision = synchronizedRevision; lastSync = Date(); status = CloudText.text("synced")
                result = .success(())
            } catch {
                result = .failure(error)
                let interrupted = action == .automatic && (error as? CloudError == .changed || error as? ProgressError == .staleSession)
                lastSync = interrupted ? .distantPast : Date()
                if error as? CloudError == .tooLarge { recordCapacity(1,uid:uid) }
                status = interrupted ? CloudText.text("pending") : error is CloudError || error is ProgressError ? error.localizedDescription : CloudText.text("unavailable")
                NSLog("Cloud sync: %@",error.localizedDescription)
            }
        }
    }
    func deleteAccount(from presenter: UIViewController) {
        guard !busy, !fileOperationActive, let current = user, let database else { return }
        let uid = current.uid, provider: CloudIdentity.Provider = hasApple ? .apple : .google
        let previous = status
        setBusy(true)
        task = Task {
            defer { setBusy(false) }
            do {
                let (credential,code) = try await identity.credential(provider,from:presenter)
                _ = try await current.reauthenticate(with:credential)
                try validateSession(uid)
                let remote = try await database.read(uid:uid)
                if remote.progress != nil { _ = try await database.write(CloudProgress(),uid:uid,expectedRevision:remote.revision) }
                if let code { try await Auth.auth().revokeToken(withAuthorizationCode:code) }
                try await current.delete()
                try await data.setCloudOwner("")
                try await profiles.forget(uid)
                conflict = nil; status = CloudText.text("signedOut")
            } catch { status = identityError(error,previous:previous) }
        }
    }
}
