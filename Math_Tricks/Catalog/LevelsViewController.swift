import UIKit

final class LevelsViewController: ThemedViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let trick: CatalogTrick
    private let grid = AppCollectionView(frame: .zero, collectionViewLayout: LevelGridLayout())
    private var saved: [Int: LevelProgress] = [:]
    private var loaded = false
    private var readTask: Task<Void, Never>?
    private var countLabel: AppLabel!
    private var count = 10
    private var layoutSize=CGSize.zero
    isolated deinit { readTask?.cancel() }
    init(trick: CatalogTrick, router: AppRouter, data: AppDataStore) {
        self.trick = trick
        super.init(title: AndroidRichText.plain(CatalogText.text(trick.nameKey)), router: router, data: data)
        catalogCategoryID = trick.groupID
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func buildContent() {
        view.accessibilityIdentifier = "screen.levels.\(trick.id)"
        let column = UIStackView(); column.axis = .vertical; column.translatesAutoresizingMaskIntoConstraints = false
        body.addSubview(column)
        header.setTitle(MainText.format("activity_game_tv_level",""))
        countLabel=label("0/10",role:.trickName);countLabel.numberOfLines=1;countLabel.textAlignment = .center
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let up=button(CatalogText.ui("examples"),icon:.up,kind:.icon){[weak self] in self?.changeCount(10)}
        let down=button(CatalogText.ui("examples"),icon:.down,kind:.icon){[weak self] in self?.changeCount(-10)}
        for key in [up,down] {key.setContentInsets(UIEdgeInsets(top:12,left:4,bottom:12,right:4),minimumHeight:44);key.widthAnchor.constraint(equalToConstant:32).isActive=true}
        let controls=UIStackView(arrangedSubviews:[up,countLabel,down]);controls.axis = .horizontal;controls.alignment = .center
        controls.spacing = 0; controls.setContentHuggingPriority(.required, for: .horizontal)
        header.setAccessoryView(controls)
        grid.backgroundColor = .clear; grid.alwaysBounceVertical = false
        grid.dataSource = self; grid.delegate = self
        grid.register(LevelCell.self, forCellWithReuseIdentifier: "level")
        column.addArrangedSubview(grid)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: body.topAnchor), column.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            column.leadingAnchor.constraint(equalTo: body.leadingAnchor), column.trailingAnchor.constraint(equalTo: body.trailingAnchor)
        ])
    }
    override func update(_ progress: ProgressState?) {
        count = progress?.settings.trainingExampleCount ?? 10
        countLabel.text = "0/\(count)"
        countLabel.textColor=palette.theme == .light ? .white:palette.text
        guard progress != nil else { return }
        readTask?.cancel()
        readTask = Task { [weak self] in
            guard let self else { return }
            do {
                let values = try await data.levels(scope: .trick, parentID: trick.id)
                guard !Task.isCancelled else { return }
                let firstLoad = !loaded
                saved = Dictionary(uniqueKeysWithValues: values.map { ($0.key.level, $0) }); loaded = true
                grid.reloadData()
                if firstLoad, let highest = values.filter(\.unlocked).map({ $0.key.level }).max() {
                    grid.layoutIfNeeded()
                    grid.scrollToItem(at: IndexPath(item: min(highest, TrickCatalog.shared.levelCount) - 1, section: 0), at: .top, animated: false)
                }
            } catch {
                guard !Task.isCancelled else { return }
                showError(error, reading: true, retry: { [weak self] in self?.update(self?.data.snapshot) })
            }
        }
    }
    private func changeCount(_ delta: Int) {
        let next = min(50, max(10, count + delta))
        guard next != count else { return }
        Task { [weak self] in
            guard let self else { return }
            do { try await data.updateSettings(.trainingExampleCount(next)) } catch { showError(error) }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size,with:coordinator)
        coordinator.animate(alongsideTransition:nil) { [weak self] _ in
            guard let self else { return }
            grid.reloadData(); grid.collectionViewLayout.invalidateLayout()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if layoutSize != grid.bounds.size {layoutSize=grid.bounds.size;grid.collectionViewLayout.invalidateLayout()}
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { TrickCatalog.shared.levelCount }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "level", for: indexPath) as! LevelCell
        let number = indexPath.item + 1
        cell.configure(number: number, progress: saved[number], unlocked: loaded && (AppConstants.unlockAllLevels || number == 1 || saved[number]?.unlocked == true), settings: appearanceSettings)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let level = indexPath.item + 1
        guard loaded, AppConstants.unlockAllLevels || level == 1 || saved[level]?.unlocked == true else { return }
        router?.show(.training(trickID: trick.id, level: level, examples: count))
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let landscape = view.bounds.width > view.bounds.height
        let font = AppTypography.font(.body, settings: settings, traits: traitCollection)
        let fitting = max(1, Int(collectionView.bounds.width / (112 * font.pointSize / 16)))
        let columns = min(landscape ? 5 : 3, fitting)
        let width=floor(collectionView.bounds.width/CGFloat(columns))
        let rowStart = indexPath.item / columns * columns
        let rowEnd = min(rowStart + columns, TrickCatalog.shared.levelCount)
        let height = (rowStart..<rowEnd).map { item in
            let number = item + 1
            return LevelCell.height(width:width,number:number,progress:saved[number],unlocked:loaded && (AppConstants.unlockAllLevels || number==1 || saved[number]?.unlocked==true),settings:appearanceSettings,traits:traitCollection,landscape:landscape)
        }.max() ?? 0
        return CGSize(width:width,height:height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { UIEdgeInsets.zero }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }
}

private final class LevelGridLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        newBounds.size != collectionView?.bounds.size
    }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange:newBounds)
        if let context = context as? UICollectionViewFlowLayoutInvalidationContext,
           newBounds.size != collectionView?.bounds.size {
            context.invalidateFlowLayoutDelegateMetrics = true
            context.invalidateFlowLayoutAttributes = true
        }
        return context
    }
}

/// The Android level button and its separate statistics caption share one background.
private final class LevelCell: UICollectionViewCell {
    private let surface=ThemeSurfaceView(.button),text=UILabel(),icon=UIImageView(),measurements=UILabel()
    private let selectionOverlay = AppListHighlightView()
    private var buttonHeight: CGFloat=110
    private var value: (Int,LevelProgress?,Bool,AppSettings)?
    override init(frame: CGRect) {
        super.init(frame:frame)
        for child in [surface,text,icon,measurements] {contentView.addSubview(child)}
        contentView.addSubview(selectionOverlay)
        text.textAlignment = .center;text.numberOfLines=0;icon.contentMode = .scaleAspectFit
        measurements.textAlignment = .center;measurements.numberOfLines=0
        isAccessibilityElement=true
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    override var isHighlighted: Bool { didSet { updateHighlight() } }
    override var isSelected: Bool { didSet { updateHighlight() } }
    private func updateHighlight() {
        selectionOverlay.setActive(value?.2 == true && (isHighlighted || isSelected))
        if let (_, _, unlocked, settings) = value {
            surface.apply(settings: settings, pressed: unlocked && (isHighlighted || isSelected), enabled: unlocked)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        value = nil
        selectionOverlay.reset()
    }
    private static func font(_ settings: AppSettings,_ traits: UITraitCollection) -> UIFont {
        let size=AppTypography.font(.menu,settings:settings,traits:traits).pointSize
        return UIFont(name:"RobotoMono-Regular",size:size) ?? UIFont.monospacedSystemFont(ofSize:size,weight:.regular)
    }
    private static func caption(_ progress: LevelProgress?,unlocked: Bool) -> String? {
        guard unlocked,let progress else {return nil}
        func time(_ value: Double?) -> String { ResultText.time(value) }
        if let metric=progress.measurements {
            return MainText.format("levels_stat_errors",metric.errors.map(String.init) ?? ResultText.text("results_no_time"))+"\n"+MainText.format("levels_stat_average",time(metric.average))+"\n"+MainText.format("levels_stat_total",time(metric.total))
        }
        return progress.bestScore>0 || progress.bestStars>0 ? MainText.text("levels_stat_time_not_measured") : nil
    }
    private static func title(_ number: Int,_ progress: LevelProgress?,_ unlocked: Bool) -> String {"-\(number)-\n\n"+(unlocked ? String(progress?.bestScore ?? 0) : "")}
    private static func titleHeight(_ width: CGFloat,number: Int,progress: LevelProgress?,unlocked: Bool,settings: AppSettings,traits: UITraitCollection) -> CGFloat {
        // Include all three lines even for a locked button, as Android's TextView does.
        let value=title(number,progress,unlocked)+(unlocked ? "" : " ")
        return ceil((value as NSString).boundingRect(with:CGSize(width:max(1,width-8),height:.greatestFiniteMagnitude),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:[.font:font(settings,traits)],context:nil).height)
    }
    static func height(width: CGFloat,number: Int,progress: LevelProgress?,unlocked: Bool,settings: AppSettings,traits: UITraitCollection,landscape: Bool) -> CGFloat {
        let button=max(landscape ? 96 : 110,titleHeight(width,number:number,progress:progress,unlocked:unlocked,settings:settings,traits:traits)+25+4+12)
        guard let caption=caption(progress,unlocked:unlocked) else {return button}
        let font=AppTypography.font(.caption,settings:settings,traits:traits)
        let extra=(caption as NSString).boundingRect(with:CGSize(width:max(1,width-8),height:.greatestFiniteMagnitude),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:[.font:font],context:nil).height
        return ceil(button+extra+8)
    }
    func configure(number: Int,progress: LevelProgress?,unlocked: Bool,settings: AppSettings) {
        value=(number,progress,unlocked,settings)
        selectionOverlay.apply(settings: settings)
        updateHighlight()
        let palette=ThemePalette(settings:settings)
        text.font=Self.font(settings,traitCollection);text.textColor=palette.accent;text.text=Self.title(number,progress,unlocked)+(unlocked ? "" : " ")
        let asset=unlocked ? "ic_th_light_b_star_\(progress?.bestStars ?? 0)" : "ic_th_light_b_lock"
        icon.image=UIImage(named:asset)?.withTintColor(palette.accent,renderingMode:.alwaysOriginal)
        measurements.font=AppTypography.font(.caption,settings:settings,traits:traitCollection);measurements.textColor=palette.theme == .aurora ? .white : palette.accent
        measurements.text=Self.caption(progress,unlocked:unlocked);measurements.isHidden=measurements.text==nil
        buttonHeight=max(UIScreen.main.bounds.width>UIScreen.main.bounds.height ? 96 : 110,Self.titleHeight(bounds.width,number:number,progress:progress,unlocked:unlocked,settings:settings,traits:traitCollection)+25+4+12)
        accessibilityLabel=[text.text,measurements.text].compactMap{$0}.joined(separator:" ")
        accessibilityTraits=unlocked ? .button : [.button,.notEnabled]
        contentView.alpha=unlocked ? 1 : 0.6;setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews();surface.frame=contentView.bounds
        selectionOverlay.frame = contentView.bounds
        contentView.bringSubviewToFront(selectionOverlay)
        if let (number,progress,unlocked,settings)=value {
            let size=window?.bounds.size ?? UIScreen.main.bounds.size
            buttonHeight=max(size.width>size.height ? 96 : 110,Self.titleHeight(bounds.width,number:number,progress:progress,unlocked:unlocked,settings:settings,traits:traitCollection)+25+4+12)
        }
        let iconSize=icon.image?.size ?? CGSize(width:64,height:25)
        let titleSize=text.sizeThatFits(CGSize(width:max(1,bounds.width-8),height:.greatestFiniteMagnitude))
        let y=max(6,(buttonHeight-titleSize.height-4-iconSize.height)/2)
        text.frame=CGRect(x:4,y:y,width:bounds.width-8,height:titleSize.height)
        icon.frame=CGRect(x:(bounds.width-iconSize.width)/2,y:y+titleSize.height+4,width:iconSize.width,height:iconSize.height)
        measurements.frame=CGRect(x:4,y:buttonHeight,width:bounds.width-8,height:max(0,bounds.height-buttonHeight-8))
    }
}
