import UIKit

final class MultiplayerSetupViewController: ThemedViewController {
    private let selected: Bool
    private var length: AppLabel!
    private let setupRow = UIStackView()
    private let setupSplit = AppDuoSplitView()
    private let duoOptions = UIStackView()
    private let nextRow = UIStackView()
    private var setupHosts: [UIView] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var duoBottom: NSLayoutConstraint!
    private var duoInputWidth: NSLayoutConstraint?
    private var setupScroll: UIScrollView!
    private var usesDuoPanes = false
    private var mode = GameInputMode.digits
    private var inputButtons: [UIButton] = []
    private let lengthBackground = ThemeSurfaceView(.button)
    private var inputChecks:[AndroidCheckBox]=[]
    private var launching = false
    private var initializedInput=false
    init(selected: Bool, router: AppRouter, data: AppDataStore) {
        self.selected = selected
        super.init(title: AppRoute.multiplayer.title, router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func buildContent() {
        let nextRow=self.nextRow;nextRow.axis = .horizontal;nextRow.alignment = .center;nextRow.spacing=0
        nextRow.translatesAutoresizingMaskIntoConstraints=false;body.addSubview(nextRow)
        for (kind,icon) in [(MultiplayerKind.cooperative,AppIcon.cooperative),(.versus,.versus)] {
            let key=button(CatalogText.ui(kind == .cooperative ? "cooperative":"versus"),icon:icon,kind:.iconSurface){[weak self] in self?.start(kind)}
            key.setContentInsets(UIEdgeInsets(top:13,left:13,bottom:13,right:13));key.widthAnchor.constraint(equalToConstant:160).isActive=true
            nextRow.addArrangedSubview(key)
        }
        let center=UIView();center.translatesAutoresizingMaskIntoConstraints=false;body.addSubview(center)
        regularConstraints = [
            center.bottomAnchor.constraint(equalTo:nextRow.topAnchor),
            nextRow.bottomAnchor.constraint(equalTo:body.bottomAnchor),nextRow.centerXAnchor.constraint(equalTo:body.centerXAnchor)
        ]
        duoBottom = center.bottomAnchor.constraint(equalTo:body.bottomAnchor)
        NSLayoutConstraint.activate(regularConstraints + [
            center.topAnchor.constraint(equalTo:body.topAnchor),center.leadingAnchor.constraint(equalTo:body.leadingAnchor),center.trailingAnchor.constraint(equalTo:body.trailingAnchor)
        ])
        setupSplit.translatesAutoresizingMaskIntoConstraints = false
        setupSplit.isHidden = true; center.addSubview(setupSplit)
        duoOptions.axis = .vertical;duoOptions.alignment = .center
        setupSplit.onArrangementChange = { [weak self] in self?.view.setNeedsLayout() }
        NSLayoutConstraint.activate([
            setupSplit.topAnchor.constraint(equalTo:center.topAnchor),setupSplit.bottomAnchor.constraint(equalTo:center.bottomAnchor),
            setupSplit.leadingAnchor.constraint(equalTo:center.leadingAnchor),setupSplit.trailingAnchor.constraint(equalTo:center.trailingAnchor)
        ])
        header.setTitle(MainText.text("player_alert_dialog_tv_steps_name"))
        let scroll=AppScrollView();setupScroll=scroll;scroll.translatesAutoresizingMaskIntoConstraints=false;center.addSubview(scroll)
        let content=setupRow;content.axis = .vertical;content.distribution = .fillEqually;content.alignment = .fill
        content.translatesAutoresizingMaskIntoConstraints=false;scroll.addSubview(content)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo:center.topAnchor),scroll.bottomAnchor.constraint(equalTo:center.bottomAnchor),scroll.leadingAnchor.constraint(equalTo:center.leadingAnchor),scroll.trailingAnchor.constraint(equalTo:center.trailingAnchor),
            content.topAnchor.constraint(equalTo:scroll.contentLayoutGuide.topAnchor),content.bottomAnchor.constraint(equalTo:scroll.contentLayoutGuide.bottomAnchor),content.leadingAnchor.constraint(equalTo:scroll.contentLayoutGuide.leadingAnchor),content.trailingAnchor.constraint(equalTo:scroll.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo:scroll.frameLayoutGuide.widthAnchor),content.heightAnchor.constraint(greaterThanOrEqualTo:scroll.frameLayoutGuide.heightAnchor)
        ])
        let selector=UIStackView();selector.axis = .vertical;selector.alignment = .center;selector.spacing=0
        let up=button(CatalogText.ui("multiplayer_length"),icon:.up,kind:.iconSurface){[weak self] in self?.changeLength(5)}
        let down=button(CatalogText.ui("multiplayer_length"),icon:.down,kind:.iconSurface){[weak self] in self?.changeLength(-5)}
        for key in [up,down] {key.widthAnchor.constraint(equalToConstant:60).isActive=true;key.heightAnchor.constraint(equalToConstant:60).isActive=true}
        length=label("—",role:.catalogTrick);length.textAlignment = .center
        let lengthPanel = UIView(); lengthPanel.translatesAutoresizingMaskIntoConstraints = false
        lengthBackground.translatesAutoresizingMaskIntoConstraints = false; length.translatesAutoresizingMaskIntoConstraints = false
        lengthPanel.addSubview(lengthBackground); lengthPanel.addSubview(length)
        NSLayoutConstraint.activate([lengthPanel.widthAnchor.constraint(equalToConstant:134),
            lengthBackground.topAnchor.constraint(equalTo:lengthPanel.topAnchor),lengthBackground.bottomAnchor.constraint(equalTo:lengthPanel.bottomAnchor),
            lengthBackground.leadingAnchor.constraint(equalTo:lengthPanel.leadingAnchor),lengthBackground.trailingAnchor.constraint(equalTo:lengthPanel.trailingAnchor),
            length.topAnchor.constraint(equalTo:lengthPanel.topAnchor,constant:8),length.bottomAnchor.constraint(equalTo:lengthPanel.bottomAnchor,constant:-8),
            length.leadingAnchor.constraint(equalTo:lengthPanel.leadingAnchor,constant:8),length.trailingAnchor.constraint(equalTo:lengthPanel.trailingAnchor,constant:-8)])
        selector.addArrangedSubview(up);selector.addArrangedSubview(lengthPanel);selector.addArrangedSubview(down)
        let inputs=UIStackView();inputs.axis = .horizontal;inputs.alignment = .center;inputs.distribution = .fillEqually
        for input in GameInputMode.allCases {
            let check=AndroidCheckBox();check.accessibilityLabel=CatalogText.ui("input_\(input.rawValue)")
            check.widthAnchor.constraint(equalToConstant:48).isActive=true;check.heightAnchor.constraint(equalToConstant:48).isActive=true
            check.addAction(UIAction{[weak self] _ in self?.chooseMode(input)},for:.valueChanged)
            inputChecks.append(check)
            let key = UIButton(type:.custom); key.translatesAutoresizingMaskIntoConstraints = false
            key.accessibilityLabel = CatalogText.ui("input_\(input.rawValue)")
            key.imageView?.contentMode = .scaleAspectFit
            key.contentEdgeInsets = UIEdgeInsets(top:15,left:15,bottom:15,right:15)
            NSLayoutConstraint.activate([key.widthAnchor.constraint(equalToConstant:105),key.heightAnchor.constraint(equalToConstant:163.5)])
            key.addAction(UIAction { [weak self] _ in self?.chooseMode(input) },for:.touchUpInside)
            inputButtons.append(key)
            let option=UIStackView(arrangedSubviews:[check,key]);option.axis = .vertical;option.alignment = .center;inputs.addArrangedSubview(option)
        }
        inputs.distribution = .fill;inputs.spacing=0
        for item in [selector,inputs] {
            let host=UIView();host.addSubview(item);item.translatesAutoresizingMaskIntoConstraints=false
            NSLayoutConstraint.activate([item.centerXAnchor.constraint(equalTo:host.centerXAnchor),item.centerYAnchor.constraint(equalTo:host.centerYAnchor),
                item.topAnchor.constraint(greaterThanOrEqualTo:host.topAnchor,constant:10),item.bottomAnchor.constraint(lessThanOrEqualTo:host.bottomAnchor,constant:-10),
                item.leadingAnchor.constraint(greaterThanOrEqualTo:host.leadingAnchor),item.trailingAnchor.constraint(lessThanOrEqualTo:host.trailingAnchor)])
            setupHosts.append(host);content.addArrangedSubview(host)
        }
    }
    override func update(_ progress: ProgressState?) {
        if !initializedInput, progress != nil {mode=settings.gameInputMode ?? .digits;initializedInput=true}
        length.text = progress.map { String($0.multiplayerLength) } ?? "—"
        for (index,check) in inputChecks.enumerated() {check.setOn(index==mode.rawValue,animated:false);check.onTintColor=palette.accent;check.isEnabled=progress != nil && !launching}
        themedButtons.forEach { $0.isEnabled = progress != nil && !launching }
        lengthBackground.apply(settings:appearanceSettings)
        let theme = palette.theme.isDark ? "dark" : "light"
        for (index,key) in inputButtons.enumerated() {
            let suffix = index == GameInputMode.digits.rawValue ? "numpad" : index == GameInputMode.choices.rawValue ? "block" : "bool"
            key.setImage(UIImage(named:"ic_th_\(theme)_iw_numpad_change_\(suffix)")?.withRenderingMode(.alwaysOriginal),for:.normal)
            key.isEnabled = progress != nil && !launching
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        synchronizeDuoPanes()
        setupRow.axis = view.bounds.width > view.bounds.height ? .horizontal : .vertical
        setupSplit.synchronizeArrangement()
    }
    private func synchronizeDuoPanes() {
        let shouldUse = AppDuoGameArrangement.canUse(in: body)
        guard shouldUse != usesDuoPanes else { return }
        usesDuoPanes = shouldUse
        if shouldUse {
            NSLayoutConstraint.deactivate(regularConstraints)
            duoBottom.isActive = true
            for host in setupHosts { setupRow.removeArrangedSubview(host);host.removeFromSuperview() }
            nextRow.removeFromSuperview()
            duoOptions.addArrangedSubview(setupHosts[1]);duoOptions.addArrangedSubview(nextRow)
            duoInputWidth = setupHosts[1].widthAnchor.constraint(equalTo:duoOptions.widthAnchor)
            duoInputWidth?.isActive = true
            setupSplit.addArrangedSubview(setupHosts[0]);setupSplit.addArrangedSubview(duoOptions)
        } else {
            duoInputWidth?.isActive = false;duoInputWidth = nil
            setupSplit.removeAllArrangedSubviews()
            duoOptions.removeArrangedSubview(setupHosts[1]);setupHosts[1].removeFromSuperview()
            duoOptions.removeArrangedSubview(nextRow);nextRow.removeFromSuperview()
            setupHosts.forEach { setupRow.addArrangedSubview($0) }
            body.addSubview(nextRow)
            duoBottom.isActive = false
            NSLayoutConstraint.activate(regularConstraints)
        }
        setupScroll.isHidden = shouldUse
        setupSplit.isHidden = !shouldUse
    }
    private func chooseMode(_ input:GameInputMode) {
        guard !launching,data.snapshot != nil else{return};mode=input;update(data.snapshot)
        Task{[weak self] in guard let self else{return};do{try await data.updateSettings(.gameInputMode(input))}catch{mode=settings.gameInputMode ?? .digits;update(data.snapshot);showError(error)}}
    }
    private func changeLength(_ delta: Int64) {
        guard let progress = data.snapshot else { return }
        Task { [weak self] in
            guard let self else { return }
            do { try await data.setMultiplayerLength(min(35, max(5, progress.multiplayerLength + delta))) } catch { showError(error) }
        }
    }
    private func start(_ kind: MultiplayerKind) {
        guard !launching, let progress = data.snapshot else { return }
        launching = true; update(progress)
        Task { [weak self] in
            guard let self else { return }
            defer { launching = false; update(data.snapshot) }
            do {
                try await data.updateSettings(.gameInputMode(mode))
                let ids = selected ? try await data.catalogProgress().filter { $0.selected && $0.unlocked }.map(\.id) : TrickCatalog.shared.tricks.filter { AppPurchases.shared.hasFullVersion || AppConstants.unlockAllLevels || $0.initiallyUnlocked }.map(\.id)
                guard !ids.isEmpty else { throw ProgressError.invalidValue }
                router?.show(.multiplayerGame(MultiplayerConfiguration(kind: kind, length: Int(progress.multiplayerLength), trickIDs: ids, selectedTricks: selected, inputMode: mode, progressGeneration: progress.generation)))
            } catch { showError(error) }
        }
    }
}
