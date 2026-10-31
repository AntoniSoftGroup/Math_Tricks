import UIKit
import Combine

/// A common Android-style header and a body above the root-owned banner.
class ThemedViewController: AppDuoViewController {
    let data: AppDataStore
    weak var router: AppRouter?
    let body = UIView()
    let header: AppHeaderView
    var settings = AppSettings()
    var catalogCategoryID: Int? {
        didSet {
            guard oldValue != catalogCategoryID, isViewLoaded else { return }
            applyAppearance()
            setNeedsStatusBarAppearanceUpdate()
            NotificationCenter.default.post(name: TrainingCatalogAppearance.changed, object: self)
        }
    }
    var appearanceSettings: AppSettings { TrainingCatalogAppearance.settings(settings, groupID: catalogCategoryID, enabled: (self as? GameViewController)?.usesCategoryColor) }
    var palette: ThemePalette { ThemePalette(settings: appearanceSettings) }
    var themedButtons: [AppButton] = []
    var themedLabels: [AppLabel] = []
    private var observation: AnyCancellable?
    private var bodyTop:NSLayoutConstraint?
    private var hasAppliedSettings = false
    private var hasUpdatedContent=false
    private var refreshOnAppear=false

    init(title: String, router: AppRouter, data: AppDataStore) {
        self.data = data; self.router = router
        header = AppHeaderView(title: title, onBack: { [weak router] in router?.goBack() })
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { viewIfLoaded?.usesDuoLayout == true || UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        palette.theme.isClassic ? (ThemeColor.luminance(palette.systemBar) > 0.5 ? .darkContent : .lightContent) : (palette.theme.isDark ? .lightContent : .darkContent)
    }
    override func loadView() { view = AppDuoContentView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        settings = data.snapshot?.settings ?? AppSettings()
        view.backgroundColor = .clear
        body.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header); view.addSubview(body)
        let safe = view.appContentLayoutGuide
        let top=body.topAnchor.constraint(equalTo:header.bottomAnchor);bodyTop=top
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: safe.topAnchor), header.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            top, body.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            body.leadingAnchor.constraint(equalTo: safe.leadingAnchor), body.trailingAnchor.constraint(equalTo: safe.trailingAnchor)
        ])
        buildContent()
        applyAppearance()
        observation = data.$snapshot.sink { [weak self] progress in
            guard let self else { return }
            let nextSettings = progress?.settings ?? AppSettings()
            if !self.hasAppliedSettings || self.settings != nextSettings {
                self.settings = nextSettings
                self.hasAppliedSettings = true
                self.applyAppearance()
            }
            if self.view.window != nil || !self.hasUpdatedContent {self.update(progress);self.hasUpdatedContent=true} else {self.refreshOnAppear=true}
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated);refreshDeferredContent()
    }
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated);refreshDeferredContent()
    }
    private func refreshDeferredContent(){guard refreshOnAppear else{return};refreshOnAppear=false;update(data.snapshot)}
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if hasAppliedSettings, isViewLoaded, (previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory || previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass || previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass || previousTraitCollection?.displayScale != traitCollection.displayScale) {
            if view.window != nil {update(data.snapshot)} else {refreshOnAppear=true}
        }
    }
    func setHeaderHidden(_ hidden:Bool) {
        header.isHidden=hidden;bodyTop?.isActive=false
        bodyTop=body.topAnchor.constraint(equalTo:hidden ? view.appContentLayoutGuide.topAnchor:header.bottomAnchor)
        bodyTop?.isActive=true
    }
    func buildContent() {}
    func update(_ progress: ProgressState?) {}
    func applyAppearance() {
        header.apply(settings: appearanceSettings)
        themedButtons.forEach { $0.apply(settings: appearanceSettings) }
        themedLabels.forEach {
            $0.apply(settings: appearanceSettings)
            $0.textColor = $0.isDescendant(of: header) ? palette.headerText : palette.text
        }
    }
    @discardableResult
    func button(_ title: String, icon: AppIcon? = nil, kind: AppButton.Kind = .dialog, balancesIcon:Bool=false, action: @escaping () -> Void) -> AppButton {
        let button = AppButton(title: title, icon: icon, kind: kind, balancesIcon: balancesIcon, action: action)
        button.apply(settings: settings); themedButtons.append(button); return button
    }
    func label(_ text: String, role: AppTextRole = .body) -> AppLabel {
        let label = AppLabel(role); label.text = text; label.apply(settings: settings); label.textColor = palette.text
        themedLabels.append(label); return label
    }
    func scrollStack(in container: UIView? = nil, padding: CGFloat = 12) -> UIStackView {
        let host = container ?? body
        let scroll = AppScrollView(); scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = false
        let stack = UIStackView(); stack.axis = .vertical; stack.spacing = 10; stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack); host.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: host.topAnchor), scroll.bottomAnchor.constraint(equalTo: host.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: host.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: padding),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -padding),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -padding),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -2 * padding)
        ])
        return stack
    }
    func showError(_ error: Error, reading: Bool = false, retry: (() -> Void)? = nil) {
        guard presentedViewController == nil, viewIfLoaded?.window != nil else { return }
        let message = (error as? ProgressError) == .invalidArchive ? CatalogText.ui("archive_invalid") : (error as? ProgressError) == .staleSession ? CatalogText.ui("progress_changed") : (error as? ProgressError) == .insufficientCoins ? CatalogText.ui("not_enough_coins") : CatalogText.ui(reading ? "read_error" : "save_error")
        var actions: [AppDialogViewController.Action] = []
        if (error as? ProgressError) == .staleSession { actions.append(.init(title: CatalogText.ui("main_menu"), handler: { [weak self] in self?.router?.show(.main) })) }
        else if let retry { actions.append(.init(title: CatalogText.ui("retry"), handler: retry)) }
        actions.append(.init(title: MainText.text("ok"), handler: {}))
        present(AppDialogViewController(title: title ?? "Math Tricks", message: message, actions: actions, data: data), animated: false)
    }
}
