import UIKit
import GameKit

/// Existing boards keep legacy identifiers and units; new boards use App Store Connect IDs.
nonisolated enum GameCenterLeaderboard: String, CaseIterable {
    case single = "lb_game_single_free"
    case minute = "lb_game_minute_free"
    case speed = "lb_game_speed_free"
    case noTime = "lb_game_noTime_free"
    case training = "lb_tricks_levels_free"
    case multiplication = "lb_byHeart_multiplication_levels_free"
    case totalSolved = "lb_total_solved_free"
    case dailyStreak = "lb_main_day_streak"
    case gameLevel = "lb_game_level"

    static func game(_ mode: GameMode) -> Self? {
        switch mode {
        case .single: return .single
        case .minute: return .minute
        case .speed: return .speed
        case .noTime: return .noTime
        default: return nil
        }
    }
    func improves(_ value: Int,over previous: Int) -> Bool {
        self == .speed ? value < previous : value > previous
    }
    func score(_ record: GameRecord) -> Int? {
        guard !record.selectedTricks, Self.game(record.mode) == self,
              record.unit == (self == .speed ? .seconds : .points),
              record.value.isFinite, record.value > 0 else { return nil }
        // Legacy LevelComplete sent Int(bestTime * 10): tenths, truncated toward zero.
        let value = self == .speed ? Double(Float(record.value) * 10) : record.value
        guard value.isFinite, value < Double(Int.max) else { return nil }
        return Int(value)
    }
}

nonisolated enum GameCenterDestination {
    case all
    case leaderboard(GameCenterLeaderboard)
}

/// One authentication handler per app. The local database remains the durable score queue.
@MainActor
final class AppGameCenter: NSObject, GKGameCenterControllerDelegate {
    static let shared = AppGameCenter()
    private weak var root: UIViewController?
    private weak var data: AppDataStore?
    private weak var requestPresenter: UIViewController?
    private var authenticationController: UIViewController?
    private weak var shownAuthenticationController: UIViewController?
    private var pendingDestination: GameCenterDestination?
    private var started = false
    private var authenticationFinished = false
    private var showingLeaderboard = false
    private var accountID: String?
    private var pending: [GameCenterLeaderboard:Int] = [:]
    private var submitted: [String:Int] = [:]
    private var syncTask: Task<Void,Never>?
    private var syncAgain = false
    private var submissionTask: Task<Void,Never>?
    private var retryTask: Task<Void,Never>?
    private var retryCount = 0
    private let defaults = UserDefaults.standard
    private var receiptKey: String { "gameCenter.submitted.v1.\(accountID ?? "")" }

    private func start(presenter: UIViewController,data: AppDataStore) {
        root = presenter.view.window?.rootViewController ?? presenter
        self.data = data
        guard !started else { presentAuthenticationIfNeeded(); return }
        guard data.snapshot != nil,
              AppAgeAssurance.shared.canContinue(settings: data.snapshot?.settings ?? data.launchSettings),
              (data.snapshot?.settings.onboarding?.phase ?? .complete) == .complete else { return }
        started = true
        NotificationCenter.default.addObserver(self,selector:#selector(becameActive),name:UIApplication.didBecomeActiveNotification,object:nil)
        GKLocalPlayer.local.authenticateHandler = { [weak self] controller,error in
            Task { @MainActor [weak self] in self?.authenticationChanged(controller:controller,error:error) }
        }
    }

    func show(_ destination: GameCenterDestination,from presenter: UIViewController,data: AppDataStore) {
        guard !showingLeaderboard, pendingDestination == nil else { return }
        requestPresenter = presenter
        pendingDestination = destination
        start(presenter:presenter,data:data)
        if GKLocalPlayer.local.isAuthenticated {
            updateAccount(); synchronize(); presentPendingLeaderboard()
        } else if authenticationFinished && authenticationController == nil {
            pendingDestination = nil; showSignInError()
        } else { presentAuthenticationIfNeeded() }
    }

    private func authenticationChanged(controller: UIViewController?,error: Error?) {
        if let controller {
            authenticationController = controller
            presentAuthenticationIfNeeded()
            return
        }
        authenticationFinished = true
        authenticationController = nil
        updateAccount()
        if let error { NSLog("Game Center authentication: %@",error.localizedDescription) }
        let resume = { [weak self] in
            guard let self else { return }
            if GKLocalPlayer.local.isAuthenticated { synchronize(); presentPendingLeaderboard() }
            else if pendingDestination != nil { pendingDestination = nil; showSignInError() }
        }
        if let shownAuthenticationController,shownAuthenticationController.presentingViewController != nil {
            shownAuthenticationController.dismiss(animated:false,completion:resume)
        } else { resume() }
    }

    private func updateAccount() {
        let next = GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.gamePlayerID : nil
        guard next != accountID else { return }
        retryTask?.cancel(); retryTask = nil; retryCount = 0
        accountID = next; pending.removeAll()
        submitted = next == nil ? [:] : defaults.dictionary(forKey:receiptKey) as? [String:Int] ?? [:]
    }

    private func presentAuthenticationIfNeeded() {
        guard pendingDestination != nil, UIApplication.shared.applicationState == .active,
              let controller = authenticationController,controller.presentingViewController == nil,
              let presenter = presentationTarget(),presenter !== controller,
              !presenter.isBeingPresented,!presenter.isBeingDismissed else { return }
        shownAuthenticationController = controller
        presenter.present(controller,animated:false)
    }

    private func presentPendingLeaderboard() {
        guard GKLocalPlayer.local.isAuthenticated,!showingLeaderboard,
              let destination = pendingDestination,
              shownAuthenticationController?.presentingViewController == nil,
              let presenter = presentationTarget(),!presenter.isBeingPresented,!presenter.isBeingDismissed else { return }
        let controller: GKGameCenterViewController
        switch destination {
        case .all: controller = GKGameCenterViewController(state:.leaderboards)
        case .leaderboard(let board):
            controller = GKGameCenterViewController(leaderboardID:board.rawValue,playerScope:.global,timeScope:.allTime)
        }
        controller.gameCenterDelegate = self
        pendingDestination = nil; showingLeaderboard = true
        presenter.present(controller,animated:false)
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated:false) { [weak self] in
            self?.showingLeaderboard = false; self?.synchronize()
        }
    }

    /// Called after a finished session, a menu return, an import, and authentication.
    func synchronize() {
        guard started,GKLocalPlayer.local.isAuthenticated,let data,let snapshot = data.snapshot else { return }
        updateAccount()
        guard syncTask == nil else { syncAgain = true; return }
        let account = accountID
        syncTask = Task { [weak self] in
            guard let self else { return }
            defer {
                syncTask = nil
                if syncAgain { syncAgain = false; synchronize() }
            }
            guard accountID == account,GKLocalPlayer.local.isAuthenticated else { return }
            enqueue(.totalSolved,value:Int(clamping:snapshot.totalSolved))
            enqueue(.dailyStreak,value:Int(clamping:snapshot.daily.streak))
            enqueue(.gameLevel,value:Int(clamping:snapshot.maximumLevel))
            for record in snapshot.records {
                if let board = GameCenterLeaderboard.game(record.mode),let score = board.score(record) { enqueue(board,value:score) }
            }
            do {
                let training = try await data.allLevels(scope:.trick)
                let multiplication = try await data.allLevels(scope:.multiplication)
                guard accountID == account,GKLocalPlayer.local.isAuthenticated else { return }
                enqueue(.training,value:training.filter { $0.bestScore > 0 && TrickCatalog.shared.trick($0.key.parentID) != nil }.count)
                enqueue(.multiplication,value:multiplication.filter { $0.bestScore > 0 && (2...99).contains($0.key.parentID) }.count)
            } catch { NSLog("Game Center local progress: %@",error.localizedDescription) }
            flush()
        }
    }

    private func enqueue(_ board: GameCenterLeaderboard,value: Int) {
        guard value > 0 else { return }
        if let old = submitted[board.rawValue],!board.improves(value,over:old) { return }
        if let old = pending[board],!board.improves(value,over:old) { return }
        pending[board] = value
    }

    private func flush() {
        guard submissionTask == nil,retryTask == nil,GKLocalPlayer.local.isAuthenticated,
              UIApplication.shared.applicationState == .active,let account = accountID,!pending.isEmpty else { return }
        let batch = pending
        submissionTask = Task { [weak self] in
            guard let self else { return }
            var failed = false
            for (board,value) in batch {
                guard accountID == account,GKLocalPlayer.local.isAuthenticated else { break }
                do {
                    try await GKLeaderboard.submitScore(value,context:0,player:GKLocalPlayer.local,leaderboardIDs:[board.rawValue])
                    guard accountID == account else { break }
                    if pending[board] == value { pending.removeValue(forKey:board) }
                    submitted[board.rawValue] = value
                    defaults.set(submitted,forKey:receiptKey)
                } catch {
                    failed = true
                    NSLog("Game Center score %@: %@",board.rawValue,error.localizedDescription)
                }
            }
            submissionTask = nil
            if failed && accountID == account { scheduleRetry() }
            else { retryCount = 0; flush() }
        }
    }

    private func scheduleRetry() {
        guard retryTask == nil,retryCount < 3,!pending.isEmpty else { return }
        let delays: [UInt64] = [5,15,60]
        let delay = delays[retryCount]; retryCount += 1
        retryTask = Task { [weak self] in
            do { try await Task.sleep(nanoseconds:delay * 1_000_000_000) } catch { return }
            guard let self else { return }
            retryTask = nil; flush()
        }
    }

    @objc private func becameActive() {
        updateAccount(); retryTask?.cancel(); retryTask = nil; retryCount = 0
        presentAuthenticationIfNeeded()
        if GKLocalPlayer.local.isAuthenticated { synchronize(); presentPendingLeaderboard(); flush() }
    }

    private func presentationTarget() -> UIViewController? {
        var target = root ?? requestPresenter
        while let current = target {
            if let presented = current.presentedViewController,!presented.isBeingDismissed { target = presented }
            else if let nav = current as? UINavigationController,let child = nav.visibleViewController { target = child }
            else if let tab = current as? UITabBarController,let child = tab.selectedViewController { target = child }
            else { break }
        }
        return target?.viewIfLoaded?.window == nil ? nil : target
    }

    private func showSignInError() {
        guard let presenter = presentationTarget(),let data else { return }
        let message = NSLocalizedString("game_center_sign_in",tableName:"GameCenter",value:"Sign in to Game Center in device Settings, then try again.",comment:"")
        presenter.present(AppDialogViewController(title:"Game Center",message:message,actions:[.init(title:MainText.text("ok"),handler:{})],data:data),animated:false)
    }
}
