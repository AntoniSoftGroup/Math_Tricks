import UIKit

final class TricksViewController: ThemedViewController, UITableViewDataSource, UITableViewDelegate {
    private enum Row {
        case group(CatalogGroup), trick(CatalogTrick, Int)
        var id: String {
            switch self { case .group(let group): return "g\(group.id)"; case .trick(let trick, _): return "t\(trick.id)" }
        }
        var groupID: Int {
            switch self { case .group(let group): return group.id; case .trick(let trick, _): return trick.groupID }
        }
    }
    private let selectionOnly: Bool
    private let table = AppTableView(frame: .zero, style: .plain)
    private var rows: [Row] = []
    private var expanded = Set(UserDefaults.standard.array(forKey: "catalog.expandedGroups") as? [Int] ?? [])
    private var progress: [Int: TrickProgress] = [:]
    private var completed: [Int: Int] = [:]
    private var loaded = false
    private var readTask: Task<Void, Never>?
    private var busy = Set<Int>()
    private var bulkUpdating = false
    private var restoringPosition = false
    private let selectAll = AndroidCheckBox()
    private let total = AppLabel(.trickName)
    private let heading = AppLabel(.trickName)
    private var headerButtons: [AppButton] = []
    private var playButtons: [AppButton] = []
    isolated deinit { readTask?.cancel() }

    init(router: AppRouter, data: AppDataStore, selectionOnly: Bool = false) {
        self.selectionOnly = selectionOnly
        super.init(title: selectionOnly ? CatalogText.ui("select_tricks") : AppRoute.tricks.title, router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func buildContent() {
        view.accessibilityIdentifier = "screen.tricks"
        buildHeader()
        let column = UIStackView(); column.axis = .vertical; column.translatesAutoresizingMaskIntoConstraints = false
        body.addSubview(column)
        table.backgroundColor = .clear; table.separatorStyle = .none
        table.dataSource = self; table.delegate = self
        table.estimatedRowHeight = 68; table.rowHeight = UITableView.automaticDimension
        table.contentInsetAdjustmentBehavior = .never
        table.register(TrainingCatalogCell.self, forCellReuseIdentifier: "trick")
        table.register(TrainingCatalogGroupCell.self, forCellReuseIdentifier: "group")
        column.addArrangedSubview(table)
        if !selectionOnly {
            let play = button(MainText.text("activity_main_b_one_player"), icon: .singlePlayer) { [weak self] in self?.playSelected(multiplayer: false) }
            let multiplayer = button(MainText.text("activity_main_b_two_players"), icon: .multiplayer) { [weak self] in self?.playSelected(multiplayer: true) }
            playButtons = [play, multiplayer]
            for button in playButtons {
                button.setContentInsets(UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5))
                button.label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            }
            let actions = UIStackView(arrangedSubviews: playButtons)
            actions.axis = .horizontal; actions.distribution = .fillEqually
            actions.isLayoutMarginsRelativeArrangement = true
            actions.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            column.addArrangedSubview(actions)
        }
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: body.topAnchor), column.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            column.leadingAnchor.constraint(equalTo: body.leadingAnchor), column.trailingAnchor.constraint(equalTo: body.trailingAnchor)
        ])
        rebuild()
    }

    private func buildHeader() {
        let collapse = button(CatalogText.ui("collapse_all"), icon: .up, kind: .icon) { [weak self] in self?.setExpanded(false) }
        let expand = button(CatalogText.ui("expand_all"), icon: .down, kind: .icon) { [weak self] in self?.setExpanded(true) }
        headerButtons = [collapse, expand]
        for key in headerButtons {
            key.setContentInsets(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
            key.widthAnchor.constraint(equalToConstant: 44).isActive = true
        }
        heading.text = title; heading.textAlignment = .center; heading.numberOfLines = 1
        heading.lineBreakMode = .byTruncatingTail
        heading.accessibilityTraits = .header
        heading.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let titleRow = UIStackView(arrangedSubviews: [collapse, expand, heading])
        titleRow.axis = .horizontal; titleRow.alignment = .center
        titleRow.setContentHuggingPriority(.defaultLow,for:.horizontal)
        header.replaceTitle(with: titleRow)
        total.text = "—/\(TrickCatalog.shared.tricks.count * TrickCatalog.shared.levelCount)"
        total.numberOfLines = 1; total.textAlignment = .right
        total.adjustsFontSizeToFitWidth = true; total.minimumScaleFactor = 0.65
        total.setContentHuggingPriority(.required, for: .horizontal)
        total.setContentCompressionResistancePriority(.required, for: .horizontal)
        total.accessibilityIdentifier = "training.completedLevels"
        selectAll.accessibilityLabel = CatalogText.ui("select_all")
        selectAll.accessibilityIdentifier = "training.selectAll"
        selectAll.widthAnchor.constraint(equalToConstant: 48).isActive = true
        selectAll.heightAnchor.constraint(equalToConstant: 36).isActive = true
        selectAll.addAction(UIAction { [weak self] _ in self?.toggleAll() }, for: .valueChanged)
        let counts = UIStackView(arrangedSubviews: selectionOnly ? [selectAll] : [total, selectAll])
        counts.axis = .vertical; counts.alignment = .trailing; counts.spacing = 2
        counts.setContentHuggingPriority(.required, for: .horizontal)
        let compactWidth=counts.widthAnchor.constraint(equalToConstant:48)
        compactWidth.priority = .defaultHigh;compactWidth.isActive=true
        let accessory = UIStackView(); accessory.axis = .horizontal; accessory.alignment = .center; accessory.spacing = 4
        accessory.isLayoutMarginsRelativeArrangement = true
        accessory.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 8)
        if !selectionOnly {
            let leaderboard = button(MainText.text("leaderboard"), icon: .leaderboard, kind: .icon) { [weak self] in self?.router?.show(.trainingLeaderboard) }
            leaderboard.setContentInsets(UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5))
            leaderboard.widthAnchor.constraint(equalToConstant: 40).isActive = true
            accessory.addArrangedSubview(leaderboard); headerButtons.append(leaderboard)
        }
        accessory.addArrangedSubview(counts)
        accessory.setContentHuggingPriority(.required,for:.horizontal)
        accessory.setContentCompressionResistancePriority(.required,for:.horizontal)
        header.setAccessoryView(accessory,trailingInset:0)
    }

    override func update(_ state: ProgressState?) {
        styleHeader()
        updateControls()
        if state != nil { readProgress() }
    }

    override func applyAppearance() {
        super.applyAppearance()
        styleHeader()
    }

    private func styleHeader() {
        let tint: UIColor = palette.theme == .light ? .white : palette.accent
        heading.apply(settings: appearanceSettings); heading.textColor = palette.theme == .light ? .white : palette.text
        total.apply(settings: appearanceSettings); total.textColor = heading.textColor
        selectAll.onTintColor = tint
        headerButtons.forEach { $0.apply(settings: appearanceSettings, tint: tint) }
        for index in table.indexPathsForVisibleRows ?? [] {
            if case .group(let group) = rows[index.row], let cell = table.cellForRow(at: index) as? TrainingCatalogGroupCell {
                cell.configure(group: group, expanded: expanded.contains(group.id), settings: appearanceSettings)
            }
        }
    }

    private func updateControls() {
        selectAll.isOn = loaded && progress.values.allSatisfy(\.selected)
        selectAll.isEnabled = loaded && !bulkUpdating && busy.isEmpty
        playButtons.forEach { $0.isEnabled = loaded; $0.isUserInteractionEnabled = !bulkUpdating && busy.isEmpty }
    }

    private func readProgress() {
        readTask?.cancel()
        readTask = Task { [weak self] in
            guard let self else { return }
            do {
                let overview = try await data.trainingCatalogProgress()
                guard !Task.isCancelled else { return }
                progress = Dictionary(uniqueKeysWithValues: overview.tricks.map { ($0.id, $0) })
                completed = overview.completedLevels; loaded = true
                total.text = "\(overview.completedTotal)/\(TrickCatalog.shared.tricks.count * TrickCatalog.shared.levelCount)"
                updateControls(); reloadPreservingPosition()
            } catch {
                guard !Task.isCancelled else { return }
                showError(error, reading: true, retry: { [weak self] in self?.readProgress() })
            }
        }
    }

    private func rebuild() {
        let anchor = scrollAnchor()
        rows = TrickCatalog.shared.groups.flatMap { group -> [Row] in
            [.group(group)] + (expanded.contains(group.id) ? TrickCatalog.shared.tricks(in: group.id).enumerated().map { .trick($0.element, $0.offset + 1) } : [])
        }
        reloadPreservingPosition(anchor: anchor)
    }

    private func scrollAnchor() -> (String, CGFloat)? {
        guard let first = table.indexPathsForVisibleRows?.min(), rows.indices.contains(first.row) else { return nil }
        return (rows[first.row].id, table.rectForRow(at: first).minY - table.contentOffset.y)
    }

    private func reloadPreservingPosition(anchor: (String, CGFloat)? = nil) {
        let saved = anchor ?? scrollAnchor()
        restoringPosition = true
        table.reloadData(); table.layoutIfNeeded()
        if let saved, let index = rows.firstIndex(where: { $0.id == saved.0 }) {
            let offset = table.rectForRow(at: IndexPath(row: index, section: 0)).minY - saved.1
            let maximum = max(0, table.contentSize.height - table.bounds.height)
            table.setContentOffset(CGPoint(x: 0, y: min(maximum, max(0, offset))), animated: false)
        }
        restoringPosition = false
    }

    private func setExpanded(_ value: Bool) {
        expanded = value ? Set(TrickCatalog.shared.groups.map(\.id)) : []
        UserDefaults.standard.set(Array(expanded).sorted(), forKey: "catalog.expandedGroups")
        rebuild(); updateCategoryFromScroll()
    }

    private func toggleAll() {
        guard loaded, !bulkUpdating, busy.isEmpty else { updateControls(); return }
        let selected = selectAll.isOn
        bulkUpdating = true; updateControls(); reloadPreservingPosition()
        Task { [weak self] in
            guard let self else { return }
            do { try await data.setAllTricksSelected(selected) } catch { showError(error) }
            bulkUpdating = false; updateControls(); readProgress()
        }
    }

    private func playSelected(multiplayer: Bool) {
        guard loaded, !bulkUpdating, busy.isEmpty else { return }
        guard progress.values.contains(where: { $0.selected && $0.unlocked }) else {
            present(AppDialogViewController(title: title ?? "", message: CatalogText.ui("no_selection"), actions: [.init(title: MainText.text("ok"), handler: {})], data: data), animated: false); return
        }
        router?.show(multiplayer ? .selectedMultiplayer : .selectedGameModes)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .group(let group):
            let cell = tableView.dequeueReusableCell(withIdentifier: "group", for: indexPath) as! TrainingCatalogGroupCell
            cell.configure(group: group, expanded: expanded.contains(group.id), settings: appearanceSettings)
            return cell
        case .trick(let trick, let position):
            let cell = tableView.dequeueReusableCell(withIdentifier: "trick", for: indexPath) as! TrainingCatalogCell
            cell.configure(trick: trick, position: position, value: progress[trick.id], completed: loaded ? completed[trick.id] ?? 0 : nil,
                settings: settings, busy: bulkUpdating || busy.contains(trick.id))
            cell.onToggle = { [weak self] selected in self?.toggle(trick.id, selected: selected) }
            return cell
        }
    }

    private func toggle(_ id: Int, selected: Bool) {
        guard !bulkUpdating, let value = progress[id], value.unlocked, busy.insert(id).inserted else { return }
        updateControls(); reloadPreservingPosition()
        Task { [weak self] in
            guard let self else { return }
            do { try await data.setTrickSelected(id, selected: selected) } catch { showError(error) }
            busy.remove(id); updateControls(); readProgress()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch rows[indexPath.row] {
        case .group(let group):
            if expanded.contains(group.id) { expanded.remove(group.id) } else { expanded.insert(group.id) }
            UserDefaults.standard.set(Array(expanded).sorted(), forKey: "catalog.expandedGroups")
            catalogCategoryID = group.id; rebuild()
        case .trick(let trick, _):
            guard let value = progress[trick.id], !bulkUpdating, !busy.contains(trick.id) else { return }
            if value.unlocked {
                if selectionOnly { toggle(trick.id, selected: !value.selected) }
                else { catalogCategoryID = trick.groupID; router?.show(.rule(trick.id)) }
            } else { offerUnlock(trick) }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !restoringPosition, scrollView.isDragging || scrollView.isDecelerating else { return }
        guard !defersScrollAppearance else { return }
        updateCategoryFromScroll()
    }
    private var defersScrollAppearance: Bool {
        !ThemeMotion.supported && ThemePalette(settings: settings).theme.isAnimated
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { updateAppearanceAfterScrolling() }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateAppearanceAfterScrolling()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateAppearanceAfterScrolling()
    }
    private func updateAppearanceAfterScrolling() {
        guard !restoringPosition, defersScrollAppearance else { return }
        updateCategoryFromScroll()
    }
    private func updateCategoryFromScroll() {
        guard let first = table.indexPathsForVisibleRows?.min(), rows.indices.contains(first.row) else { return }
        catalogCategoryID = rows[first.row].groupID
    }

    private func offerUnlock(_ trick: CatalogTrick) {
        guard data.snapshot != nil, presentedViewController == nil else { return }
        present(TrainingUnlockViewController(trick: trick, data: data,onBuyPro:{ [weak self] in self?.router?.showProPurchase() }), animated: false)
    }
}
