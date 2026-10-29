import UIKit

protocol AppBackHandling: AnyObject { func requestBack()
    
}

enum MainMetric: String, Equatable { case totalSolved, dailyStreak }

enum AppRoute: Equatable {
    case gameLeaderboard(GameMode,selected:Bool),difficultyLeaderboard,byHeartLeaderboard,trainingLeaderboard
    case statisticsList(Int, GameInputMode)
    case statisticEntries(StatisticsFilter, GameInputMode? = nil)
    case gameGraph(GameMode, selected: Bool)
    case nestedSolution(MathExample)
    case solutionPreview(MathExample)
    case solution(MathExample)
    case game(GameConfiguration)
    case resumeGame(String)
    case main
    case selectedGameModes
    case rule(Int), levels(Int)
    case training(trickID: Int, level: Int, examples: Int)
    case gameModes
    case tricks
    case multiplayer
    case selectedMultiplayer
    case multiplayerGame(MultiplayerConfiguration)
    case resumeMultiplayer
    case byHeart
    case byHeartLevels(Int)
    case byHeartExamples(number: Int, level: Int)
    case byHeartHint(number: Int, level: Int, example: MathExample)
    case multiplicationTable
    case settings
    case fontSize, numpad
    case appearance
    case selectDailyTricks
    case statistics, daily, dailySettings, cloud
    case graph(MainMetric), leaderboard(MainMetric)

    var title: String {
        switch self {
        case .gameLeaderboard,.difficultyLeaderboard,.byHeartLeaderboard,.trainingLeaderboard:return MainText.text("leaderboard")
        case .statisticsList: return MainText.text("example_statistics_title")
        case .statisticEntries: return MainText.text("example_statistics_title")
        case .gameGraph: return MainText.text("graph")
        case .nestedSolution, .solutionPreview: return CatalogText.ui("rule")
        case .solution, .byHeartHint: return CatalogText.ui("hint")
        case .game, .resumeGame: return "Math Tricks"
        case .main: return "Math Tricks"
        case .selectedGameModes: return CatalogText.ui("selected_play")
        case .rule: return CatalogText.ui("rule")
        case .levels: return CatalogText.ui("levels")
        case .training: return CatalogText.ui("play")
        case .gameModes: return MainText.text("activity_main_b_Start")
        case .tricks: return MainText.text("activity_main_b_Training")
        case .multiplayerGame, .resumeMultiplayer, .selectedMultiplayer: return MainText.text("activity_main_b_Teamwise")
        case .multiplayer: return MainText.text("activity_main_b_Teamwise")
        case .byHeartLevels, .byHeartExamples: return MainText.text("activity_main_b_by_heart")
        case .multiplicationTable: return CatalogText.ui("multiplication_table")
        case .byHeart: return MainText.text("activity_main_b_by_heart")
        case .cloud: return CloudText.text("title")
        case .fontSize: return CatalogText.ui("font_size")
        case .numpad: return CatalogText.ui("numpad")
        case .settings: return MainText.text("settings")
        case .appearance: return MainText.text("option_theme")
        case .selectDailyTricks: return CatalogText.ui("select_tricks")
        case .statistics: return MainText.text("example_statistics_title")
        case .daily: return MainText.text("play_day_streak").replacingOccurrences(of: "\n", with: " ")
        case .dailySettings: return MainText.text("activate_day_streak")
        case .graph: return MainText.text("graph")
        case .leaderboard: return MainText.text("leaderboard")
        }
    }
}

extension AppRoute {
    var gameCenterDestination: GameCenterDestination? {
        switch self {
        case .gameLeaderboard(let mode,let selected):
            guard !selected,let board=GameCenterLeaderboard.game(mode) else {return .all}
            return .leaderboard(board)
        case .trainingLeaderboard: return .leaderboard(.training)
        case .byHeartLeaderboard: return .leaderboard(.multiplication)
        case .leaderboard(.totalSolved): return .leaderboard(.totalSolved)
        case .difficultyLeaderboard: return .leaderboard(.gameLevel)
        case .leaderboard(.dailyStreak): return .leaderboard(.dailyStreak)
        default: return nil
        }
    }
}

/// A scene owns one router. Screens reference it weakly and never own the stack.
final class AppRouter {
    private weak var navigationController: AppNavigationController?
    private var preparingDaily=false
    private var preparedThemePreview: ThemePreviewView?
    func discardPreparedThemePreview() { preparedThemePreview = nil }
    private func makeAgeScreen() -> AgeScreenViewController {
        let screen = AgeScreenViewController(data:data)
        screen.prepareThemePreview = { [weak self] settings in
            guard let self, preparedThemePreview == nil else { return }
            var previewSettings = settings
            let theme = settings.theme ?? .light
            previewSettings.theme = theme
            previewSettings.useSystemFontSize = false
            if settings.useSystemFontSize { previewSettings.fontSizePercent = Int((ResultUI.font(16,settings:settings).pointSize/16*100).rounded()) }
            let base = ThemeColor.hex(settings.themeBaseColorHex ?? settings.accentColorHex ?? "0D47A1")
            previewSettings.themeIntensity = settings.theme == nil ? theme.defaultIntensity : settings.themeIntensity
            previewSettings.themeBaseColorHex = ThemeColor.hexString(base)
            previewSettings.accentColorHex = ThemeColor.hexString(ThemeColor.intensity(base,theme.mappedIntensity(previewSettings.themeIntensity)))
            let preview = ThemePreviewView()
            preview.apply(settings:previewSettings)
            preparedThemePreview = preview
        }
        return screen
    }
    private func makeThemePicker(initialSetup: Bool = false) -> ThemePickerViewController {
        let preview = preparedThemePreview; preparedThemePreview = nil
        return ThemePickerViewController(router:self, data:data, initialSetup:initialSetup, preparedPreview:preview)
    }
    private var screenPresentationTask: Task<Void,Never>?
    private let data: AppDataStore

    init(navigationController: AppNavigationController, data: AppDataStore) {
        self.navigationController = navigationController
        self.data = data
    }

    func start() {
        guard let navigationController, navigationController.viewControllers.isEmpty else { return }
        navigationController.setViewControllers([makeScreen(for: .main)], animated: false)
    }

    func reconcileOnboarding(_ flow: OnboardingState?) {
        guard let navigationController else { return }
        let assurance = AppAgeAssurance.shared
        guard assurance.isReady, !assurance.requiresSystemAge else { return }
        if assurance.needsManualAge(settings: data.snapshot?.settings ?? data.launchSettings) {
            if navigationController.topViewController is AgeScreenViewController { return }
            navigationController.setViewControllers([makeAgeScreen()], animated: false)
            return
        }
        switch flow?.phase ?? .complete {
        case .age:
            if navigationController.topViewController is AgeScreenViewController { return }
            navigationController.setViewControllers([makeAgeScreen()], animated: false)
        case .appearance:
            if (navigationController.topViewController as? ThemePickerViewController)?.isInitialSetup == true { return }
            navigationController.setViewControllers([makeThemePicker(initialSetup:true)], animated: false)
        case .complete:
            let needsMain = navigationController.topViewController is AgeScreenViewController
                || (navigationController.topViewController as? ThemePickerViewController)?.isInitialSetup == true
            if needsMain || navigationController.viewControllers.isEmpty {
                navigationController.setViewControllers([makeScreen(for: .main)], animated: false)
            }
        }
    }

    func show(_ route: AppRoute) {
        screenPresentationTask?.cancel(); screenPresentationTask = nil
        if let destination = route.gameCenterDestination,let presenter = navigationController?.topViewController {
            AppGameCenter.shared.show(destination,from:presenter,data:data);return
        }
        if route == .daily { startDailyPractice(); return }
        guard let navigationController, navigationController.transitionCoordinator == nil else { return }
        if route == .main {
            navigationController.popToRootViewController(animated: false)
            return
        }
        if route == .appearance && navigationController.topViewController is ThemePickerViewController { return }
        guard (navigationController.topViewController as? ShellScreenViewController)?.route != route else {
            return
        }
        let screen = makeScreen(for: route)
        if screen is GraphViewController || screen is GameViewController || screen is MultiplayerViewController || screen is StatisticsViewController {
            let source = navigationController.topViewController
            screenPresentationTask = Task { [weak self, weak source] in
                do {
                    if let statistics = screen as? StatisticsViewController { try await statistics.prepareForPresentation() }
                    else if let graph = screen as? GraphViewController { try await graph.prepareForPresentation() }
                    else if let game = screen as? GameViewController { try await game.prepareForPresentation() }
                    else if let multiplayer = screen as? MultiplayerViewController { try await multiplayer.prepareForPresentation() }
                    guard !Task.isCancelled, let self, let source,
                          self.navigationController?.topViewController === source else { return }
                    screen.view.frame = navigationController.view.bounds
                    screen.view.layoutIfNeeded()
                    if case .game(let configuration) = route, configuration.mode == .byHeart,
                       source is ByHeartExamplesViewController {
                        navigationController.setViewControllers(Array(navigationController.viewControllers.dropLast()) + [screen], animated: false)
                    } else {
                        navigationController.pushViewController(screen, animated: false)
                    }
                } catch {
                    guard !Task.isCancelled, let self, let source,
                          self.navigationController?.topViewController === source else { return }
                    (source as? ThemedViewController)?.showError(error, reading: true, retry: { [weak self] in self?.show(route) })
                }
            }
            return
        }
        if screen is LevelsViewController, navigationController.topViewController is RuleViewController {
            navigationController.setViewControllers(Array(navigationController.viewControllers.dropLast()) + [screen], animated:false)
        } else {
            navigationController.pushViewController(screen, animated: false)
        }
    }

    func showProPurchase() {
        guard let main = navigationController?.viewControllers.first as? MainMenuViewController else { return }
        show(.main)
        main.animateAndOpenPro()
    }

    func showResultTrick(session: GameSession,key: SessionTrickKey) {
        guard let navigationController,navigationController.transitionCoordinator == nil else { return }
        navigationController.pushViewController(SessionTrickResultViewController(session: session,key: key,router: self,data: data),animated: false)
    }

    private func startDailyPractice() {
        guard !preparingDaily, let navigationController, let source=navigationController.topViewController, data.snapshot != nil else { return }
        preparingDaily=true
        Task { [weak self,weak source] in
            guard let self else { return };defer{preparingDaily=false}
            do {
                try await data.refreshDailyProgress()
                guard let source,navigationController.topViewController === source,let state=data.snapshot else{return}
                if state.daily.solved>=state.daily.target {
                    source.present(AppDialogViewController(title:AppRoute.daily.title,message:CatalogText.ui("daily_complete"),actions:[.init(title:MainText.text("ok"),handler:{})],data:data),animated:false);return
                }
                let ids=try await data.catalogProgress().filter{$0.selected && $0.unlocked}.map(\.id)
                guard navigationController.topViewController === source else{return}
                if ids.isEmpty {source.present(AppDialogViewController(title:AppRoute.daily.title,message:CatalogText.ui("no_selection"),actions:[.init(title:MainText.text("ok"),handler:{})],data:data),animated:false);return}
                let reminder=state.settings.dailyReminder ?? DailyReminderSettings()
                let config=GameConfiguration(mode:.daily,difficulty:reminder.difficulty,trickIDs:ids,selectedTricks:true,exampleCount:max(1,Int(Int64(state.daily.target)-state.daily.solved)),inputMode:state.settings.gameInputMode,progressGeneration:state.generation)
                show(.game(config))
            }catch{
                guard let source,navigationController.topViewController === source else{return}
                source.present(AppDialogViewController(title:AppRoute.daily.title,message:CatalogText.ui("read_error"),actions:[.init(title:MainText.text("ok"),handler:{})],data:data),animated:false)
            }
        }
    }

    func showProgressFiles() {
        if let current = navigationController?.topViewController as? CloudViewController { current.showFileSection(); return }
        show(.cloud)
        (navigationController?.topViewController as? CloudViewController)?.showFileSection()
    }

    func goBack(confirmed: Bool = false) {
        screenPresentationTask?.cancel(); screenPresentationTask = nil
        if !confirmed, let game = navigationController?.topViewController as? AppBackHandling { game.requestBack(); return }
        guard let navigationController,
              navigationController.viewControllers.count > 1,
              navigationController.transitionCoordinator == nil else { return }
        navigationController.popViewController(animated: false)
    }

    private func makeScreen(for route: AppRoute) -> UIViewController {
        if case .nestedSolution(let example) = route { return SolutionViewController(example: example, preview: true, nested: true, router: self, data: data) }
        if case .solutionPreview(let example) = route { return SolutionViewController(example: example, preview: true, router: self, data: data) }
        if case .solution(let example) = route { return SolutionViewController(example: example, router: self, data: data) }
        if case .game(let configuration) = route { return GameViewController(configuration: configuration, router: self, data: data) }
        if case .resumeGame = route { return GameViewController(configuration: nil, router: self, data: data) }
        if case .training(let id, let level, let count) = route {
            return GameViewController(configuration: GameConfiguration(mode: .training, difficulty: level, trickIDs: [id], exampleCount: count), router: self, data: data)
        }
        if route == .main { return MainMenuViewController(router: self, data: data) }
        if route == .gameModes || route == .selectedGameModes { return GameModesViewController(selected: route == .selectedGameModes, router: self, data: data) }
        if route == .cloud { return CloudViewController(title:route.title,router:self,data:data) }
        if route == .dailySettings { return DailySettingsViewController(title: route.title, router: self, data: data) }
        if route == .selectDailyTricks { return TricksViewController(router: self, data: data, selectionOnly: true) }
        if route == .settings { return SettingsViewController(title: route.title, router: self, data: data) }
        if route == .fontSize || route == .numpad { return TextAndKeypadViewController(fontMode: route == .fontSize, router: self, data: data) }
        if case .statisticsList(let section, let input) = route { return StatisticsViewController(section: section, input: input, router: self, data: data) }
        if route == .statistics { return StatisticsViewController(router: self,data: data) }
        if case .statisticEntries(let filter, let input) = route { return StatisticsViewController(filter: filter,input: input,router: self,data: data) }
        if case .gameGraph(let mode,let selected) = route { return GraphViewController(mode: mode,selected: selected,router: self,data: data) }
        if case .graph(let metric) = route { return GraphViewController(metric: metric,router: self,data: data) }
        if route == .multiplayer || route == .selectedMultiplayer { return MultiplayerSetupViewController(selected: route == .selectedMultiplayer, router: self, data: data) }
        if case .multiplayerGame(let config) = route { return MultiplayerViewController(configuration: config, router: self, data: data) }
        if route == .resumeMultiplayer { return MultiplayerViewController(configuration: nil, router: self, data: data) }
        if route == .byHeart { return ByHeartViewController(router: self, data: data) }
        if case .byHeartLevels(let number) = route { return ByHeartViewController(number: number, router: self, data: data) }
        if case .byHeartHint(let number, let level, let example) = route { return ByHeartExamplesViewController(number:number,level:level,hintExample:example,router:self,data:data) }
        if case .byHeartExamples(let number, let level) = route { return ByHeartExamplesViewController(number: number, level: level, router: self, data: data) }
        if route == .multiplicationTable { return MultiplicationTableViewController(title: route.title, router: self, data: data) }
        if route == .tricks { return TricksViewController(router: self, data: data) }
        if case .rule(let id) = route, let trick = TrickCatalog.shared.trick(id) { return RuleViewController(trick: trick, router: self, data: data) }
        if case .levels(let id) = route, let trick = TrickCatalog.shared.trick(id) { return LevelsViewController(trick: trick, router: self, data: data) }
        if route == .appearance { return makeThemePicker() }
        return ShellScreenViewController(route: route, router: self, data: data)
    }
}

/// Native containment provides push/pop lifecycle without a second system header.
final class AppNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    var onVisibleScreenChanged: ((UIViewController) -> Void)?
    private lazy var backGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(swipeBack(_:)))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        delegate = self
        setNavigationBarHidden(true, animated: false)
        // Keep edge-swipe back without UIKit's interactive slide transition.
        interactivePopGestureRecognizer?.isEnabled = false
        backGesture.edges = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        backGesture.delegate = self
        view.addGestureRecognizer(backGesture)
    }

    @objc private func swipeBack(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .ended, viewControllers.count > 1,
              transitionCoordinator == nil, presentedViewController == nil else { return }
        let direction: CGFloat = backGesture.edges == .right ? -1 : 1
        guard gesture.translation(in: view).x * direction > 40
                || gesture.velocity(in: view).x * direction > 300 else { return }
        if let game = topViewController as? AppBackHandling { game.requestBack() }
        else { popViewController(animated: false) }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        onVisibleScreenChanged?(viewController)
    }

    override var childForStatusBarStyle: UIViewController? { topViewController }
    override var childForStatusBarHidden: UIViewController? { topViewController }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    override var shouldAutorotate: Bool {
        topViewController?.shouldAutorotate ?? true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1 && transitionCoordinator == nil && presentedViewController == nil
    }
}
