import UIKit
import Combine

/// Like activity_main_host: changing screens and the shared banner are siblings.
final class AppRootViewController: AppDuoViewController {
    private let themeBackground = ThemeBackgroundView()
    private let topSystemBar = UIView()
    private let bottomSystemBar = UIView()
    private var palette = ThemePalette(settings: AppDataStore.shared.launchSettings)
    private let screenNavigation = AppNavigationController()
    let bannerContainer = BannerContainerView()
    private let data = AppDataStore.shared
    private lazy var router = AppRouter(navigationController: screenNavigation, data: data)
    private var progressErrorPending = false
    private var hasAppeared = false
    private var settingsObservation: AnyCancellable?
    private var dailyObservations=Set<AnyCancellable>()
    private var startupTask: Task<Void, Never>?
    private var serviceStartLink: CADisplayLink?
    private var sawMenuFrame = false
    private var servicesReady = false
    private let startupBegan = ProcessInfo.processInfo.systemUptime
    private let ageStatus = AppLabel(.body)
    private let ageActivity = UIActivityIndicatorView(style: .large)

    isolated deinit { startupTask?.cancel(); serviceStartLink?.invalidate() }

    override func loadView() { view = AppDuoContentView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        let initialSettings = data.snapshot?.settings ?? data.launchSettings
        palette = ThemePalette(settings:initialSettings)
        overrideUserInterfaceStyle = palette.theme.isDark ? .dark : .light
        view.backgroundColor = palette.background
        themeBackground.apply(settings:initialSettings)
        topSystemBar.backgroundColor = palette.systemBar
        bottomSystemBar.backgroundColor = palette.systemBar
        for decoration in [themeBackground, topSystemBar, bottomSystemBar] {
            decoration.translatesAutoresizingMaskIntoConstraints = false
            decoration.isUserInteractionEnabled = false
            view.addSubview(decoration)
        }
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            themeBackground.topAnchor.constraint(equalTo: view.topAnchor), themeBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            themeBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor), themeBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSystemBar.topAnchor.constraint(equalTo: view.topAnchor), topSystemBar.bottomAnchor.constraint(equalTo: safe.topAnchor),
            topSystemBar.leadingAnchor.constraint(equalTo: view.leadingAnchor), topSystemBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSystemBar.topAnchor.constraint(equalTo: safe.bottomAnchor), bottomSystemBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomSystemBar.leadingAnchor.constraint(equalTo: view.leadingAnchor), bottomSystemBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        screenNavigation.onVisibleScreenChanged = { [weak self] controller in self?.visibleScreenChanged(controller) }
        addChild(screenNavigation)
        let screenView = screenNavigation.view!
        screenView.translatesAutoresizingMaskIntoConstraints = false
        screenView.isHidden = data.snapshot == nil
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(screenView)
        view.addSubview(bannerContainer)

        let safeArea = view.appContentLayoutGuide
        NSLayoutConstraint.activate([
            screenView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            screenView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            screenView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            screenView.bottomAnchor.constraint(equalTo: bannerContainer.topAnchor),
            bannerContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            bannerContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            bannerContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        screenNavigation.didMove(toParent: self)
        ageActivity.translatesAutoresizingMaskIntoConstraints = false
        ageActivity.hidesWhenStopped = true
        view.addSubview(ageActivity)
        ageStatus.translatesAutoresizingMaskIntoConstraints = false
        ageStatus.text = NSLocalizedString("checking", tableName:"AgeAssurance", comment:"")
        ageStatus.textAlignment = .center
        ageStatus.numberOfLines = 0
        ageStatus.isHidden = true
        view.addSubview(ageStatus)
        NSLayoutConstraint.activate([
            ageStatus.topAnchor.constraint(equalTo:ageActivity.bottomAnchor,constant:12),
            ageStatus.leadingAnchor.constraint(equalTo:safeArea.leadingAnchor,constant:24),
            ageStatus.trailingAnchor.constraint(equalTo:safeArea.trailingAnchor,constant:-24),
            ageActivity.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            ageActivity.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])

        bannerContainer.collapse()
        bannerContainer.onBuyPro = { [weak self] in self?.router.showProPurchase() }
        settingsObservation = data.$snapshot.receive(on:RunLoop.main).sink { [weak self] progress in
            guard let self, let progress else { return }
            let settings = progress.settings
            self.palette = ThemePalette(settings: settings)
            self.overrideUserInterfaceStyle = self.palette.theme.isDark ? .dark : .light
            self.bannerContainer.apply(settings: settings)
            self.updateAgeFlow()
            self.openDailyIfNeeded()
            self.startServices()
            self.visibleScreenChanged(self.screenNavigation.topViewController)
            self.view.backgroundColor = self.palette.background
            self.view.layoutIfNeeded()
            for surface in [self.themeBackground,self.topSystemBar,self.bottomSystemBar] { surface.isHidden = false }
            self.setNeedsStatusBarAppearanceUpdate()
        }
        AppPurchases.shared.start()
        _ = AppFeedback.shared
        DailyNotificationService.shared.install()
        // Posted by the main-actor screen. Deliver synchronously during tracking:
        // RunLoop.main's default-mode scheduling would wait until scrolling ends.
        NotificationCenter.default.publisher(for: TrainingCatalogAppearance.changed)
            .sink { [weak self] notification in
                guard let self, let controller = notification.object as? UIViewController,
                      self.screenNavigation.topViewController === controller else { return }
                self.visibleScreenChanged(controller)
            }.store(in: &dailyObservations)
        NotificationCenter.default.publisher(for:DailyNotificationService.openDaily).receive(on:RunLoop.main)
            .sink{[weak self] _ in self?.openDailyIfNeeded()}.store(in:&dailyObservations)
        NotificationCenter.default.publisher(for:AppAdvertising.changed)
            .sink { [weak self] _ in
                self?.startServices()
                self?.updateBanner()
            }.store(in: &dailyObservations)
        NotificationCenter.default.publisher(for: AppAgeAssurance.changed)
            .sink { [weak self] _ in
                self?.updateAgeFlow()
                self?.startServices()
                self?.updateBanner()
                self?.openDailyIfNeeded()
            }.store(in: &dailyObservations)
        NotificationCenter.default.publisher(for: CloudSync.changed)
            .sink { [weak self] _ in
                guard let self else { return }
                self.screenNavigation.view.isUserInteractionEnabled = !CloudSync.shared.blocksInteraction
                CloudSync.shared.offerCapacityWarning(from:self) { [weak self] in self?.router.showProgressFiles() }
            }
            .store(in: &dailyObservations)
        NotificationCenter.default.publisher(for:UIApplication.didBecomeActiveNotification)
            .merge(with:NotificationCenter.default.publisher(for:UIApplication.significantTimeChangeNotification))
            .receive(on:RunLoop.main).sink{[weak self] notification in
                guard let self else { return }
                self.refreshDaily()
                if notification.name == UIApplication.didBecomeActiveNotification {
                    Task {
                        await AppPurchases.shared.refreshEntitlements(reason: "active")
                        _ = try? await AppPurchases.shared.loadFullVersionProduct()
                    }
                    self.updateAgeFlow()
                    AppAdvertising.shared.becameActive(settings: self.data.snapshot?.settings ?? self.data.launchSettings)
                    self.startServices()
                    self.updateBanner()
                }
            }.store(in:&dailyObservations)
        NotificationCenter.default.publisher(for:UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in self?.router.discardPreparedThemePreview() }.store(in:&dailyObservations)
        loadProgress()
    }

    private func visibleScreenChanged(_ controller: UIViewController?) {
        if controller is MainMenuViewController || controller is TricksViewController || controller is ByHeartViewController || controller is GameModesViewController {
            AppGameCenter.shared.synchronize()
        }
        let picking = controller is ThemePickerViewController
        let savedSettings = data.snapshot?.settings ?? data.launchSettings
        let game = (controller as? GameViewController) ?? (controller as? SolutionViewController)?.game
        let appearance = TrainingCatalogAppearance.settings(savedSettings, groupID: (controller as? ThemedViewController)?.catalogCategoryID, enabled: game?.usesCategoryColor)
        let screenPalette = ThemePalette(settings: appearance)
        themeBackground.apply(settings: appearance)
        updateBanner()
        themeBackground.setHostVisible(!picking && presentedViewController == nil)
        let barColor = screenPalette.systemBar
        ThemeColorTransition.apply(topSystemBar, color: barColor)
        ThemeColorTransition.apply(bottomSystemBar, color: barColor)
        if hasAppeared { startServices() }
    }

    private func loadProgress() {
        guard startupTask == nil else { return }
        progressErrorPending = false
        startupTask = Task { [weak self] in
            let began = ProcessInfo.processInfo.systemUptime
            do {
                try await AppDataStore.shared.prepare()
                NSLog("Startup local progress: %.3f s",ProcessInfo.processInfo.systemUptime - began)
                try await AppDataStore.shared.refreshDailyProgress()
                self?.refreshDaily()
                guard !Task.isCancelled else { return }
                // Screens observe the snapshot; loading never replaces the menu.
            } catch {
                guard !Task.isCancelled, let self else { return }
                self.progressErrorPending = true
                self.presentProgressErrorIfNeeded()
                NSLog("Progress could not load: %@", error.localizedDescription)
            }
            self?.startupTask = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppeared = true
        presentProgressErrorIfNeeded()
        updateAgeFlow()
        openDailyIfNeeded()
        startServices()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBanner()
    }

    private func startServices() {
        guard hasAppeared, let settings = data.snapshot?.settings,
              AppAgeAssurance.shared.canContinue(settings: settings) else { return }
        guard servicesReady else {
            if serviceStartLink == nil {
                let link = CADisplayLink(target:self,selector:#selector(startServicesAfterMenuFrame))
                serviceStartLink = link
                link.add(to:.main,forMode:.common)
            }
            return
        }
        AppAnalytics.shared.configure()
        AppAdvertising.shared.start(from: self, settings: settings)
        let current = screenNavigation.topViewController
        CloudSync.shared.activate(from:self,safeScreen:current is MainMenuViewController || current is SettingsViewController || current is CloudViewController)
        CloudSync.shared.offerCapacityWarning(from:self) { [weak self] in self?.router.showProgressFiles() }
    }

    @objc private func startServicesAfterMenuFrame() {
        guard UIApplication.shared.applicationState == .active, !screenNavigation.view.isHidden else { return }
        // Wait for one complete menu frame before initializing SDKs on the main thread.
        guard sawMenuFrame else { sawMenuFrame = true; return }
        serviceStartLink?.invalidate(); serviceStartLink = nil
        servicesReady = true
        NSLog("Startup menu displayed: %.3f s",ProcessInfo.processInfo.systemUptime - startupBegan)
        startServices()
    }

    private func updateBanner() {
        let settings = data.snapshot?.settings ?? data.launchSettings
        let visible = AppPurchases.shared.isReady && !AppPurchases.shared.hasFullVersion && data.snapshot != nil && (settings.onboarding?.phase ?? .complete) == .complete
            && !(screenNavigation.topViewController is ThemePickerViewController)
        bannerContainer.update(presenter: self, visible: visible && AppAgeAssurance.shared.canContinue(settings: settings), canRequestAds: AppAdvertising.shared.canRequestAds)
    }

    private func updateAgeFlow() {
        guard let settings = data.snapshot?.settings else { return }
        let assurance = AppAgeAssurance.shared
        if !assurance.isReady {
            if #available(iOS 26.2, *) {
                if settings.onboarding?.hasAgeChoice == true { assurance.start(from:self,data:data) }
            } else {
                assurance.start(from:self,data:data)
            }
        }
        ageStatus.apply(settings:settings)
        ageStatus.textColor = palette.text
        ageStatus.isHidden = assurance.isReady
        if !assurance.isReady {
            screenNavigation.view.isHidden = true
            ageActivity.color = palette.text
            ageActivity.startAnimating()
            if hasAppeared { assurance.start(from: self, data: data) }
        } else if assurance.requiresSystemAge {
            screenNavigation.view.isHidden = true
            ageActivity.stopAnimating()
            guard hasAppeared, viewIfLoaded?.window != nil, presentedViewController == nil,
                  UIApplication.shared.applicationState == .active else { return }
            let alert = UIAlertController(title: MainText.text("age_window"),
                message: NSLocalizedString("required", tableName: "AgeAssurance", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: CatalogText.ui("retry"), style: .default) { [weak self] _ in
                self?.dismiss(animated: false) { assurance.retry() }
            })
            present(alert, animated: true)
        } else {
            ageActivity.stopAnimating()
            router.reconcileOnboarding(settings.onboarding)
            screenNavigation.view.isHidden = false
        }
    }

    private func presentProgressErrorIfNeeded() {
        guard progressErrorPending, hasAppeared, viewIfLoaded?.window != nil,
              presentedViewController == nil else { return }
        progressErrorPending = false
        let dialog = AppDialogViewController(
            title: CatalogText.ui("saved_progress"),
            message: CatalogText.ui("read_error"),
            actions: [.init(title: CatalogText.ui("retry"), handler: { [weak self] in
                guard let self else { return }
                self.visibleScreenChanged(self.screenNavigation.topViewController)
                self.loadProgress()
            })],
            data: data
        )
        themeBackground.setHostVisible(false)
        present(dialog, animated: false)
    }

    private func openDailyIfNeeded(){
        guard hasAppeared,DailyNotificationService.shared.pendingOpen,let progress=data.snapshot,
            AppAgeAssurance.shared.canContinue(settings: progress.settings),
            progress.settings.onboarding?.phase == .complete || progress.settings.onboarding == nil else{return}
        DailyNotificationService.shared.consumeOpen();router.show(.daily)
    }
    private func refreshDaily(){
        guard data.snapshot != nil else{return}
        Task{[weak self] in
            guard let self else{return}
            do{try await data.refreshDailyProgress();try await DailyNotificationService.shared.schedule(data.snapshot);openDailyIfNeeded()}
            catch{NSLog("Daily progress refresh: %@",error.localizedDescription)}
        }
    }

    override var childForStatusBarStyle: UIViewController? { screenNavigation }
    override var childForStatusBarHidden: UIViewController? { nil }
    override var prefersStatusBarHidden: Bool { viewIfLoaded?.usesDuoLayout == true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        screenNavigation.supportedInterfaceOrientations
    }
    override var shouldAutorotate: Bool { screenNavigation.shouldAutorotate }
}
