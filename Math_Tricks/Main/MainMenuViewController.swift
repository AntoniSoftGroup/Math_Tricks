import UIKit
import Combine

/// Android activity_main: shared header, daily panel, menu and footer; the banner belongs to the root.
final class MainMenuViewController: UIViewController {
    private weak var router: AppRouter?
    private let data: AppDataStore
    private var observation: AnyCancellable?
    private var proPurchaseTask: Task<Void,Never>?
    private var settings = AppSettings()
    private var previewSettings: AppSettings?
    private var lastLandscape: Bool?
    private var footerWidths:[NSLayoutConstraint]=[]
    private let layoutContainer = UIView()
    private let header = UIView()
    private let dailyPanel = UIView()
    private let dailyDetails = UIView()
    private let dailyContents = UIStackView()
    private let dailyControls = UIStackView()
    private let counts = UIStackView()
    private let insuranceRow = UIStackView()
    private let solvedLabel = AppLabel(.headCount)
    private var headerGroupWidth:NSLayoutConstraint?
    private var buyWidth: NSLayoutConstraint?
    private var hasFullVersion: Bool { previewSettings == nil && AppPurchases.shared.hasFullVersion }
    private var settingsWidth:NSLayoutConstraint?
    private var landscapeActionWidth:NSLayoutConstraint?
    private var landscapeCountsWidth:NSLayoutConstraint?
    private let dailyActions=UIStackView()
    private let days = AppLabel(.headCount)
    private let today = AppLabel(.headCount)
    private let notificationLabel = AppLabel(.dailyCaption)
    private let notificationSwitch = UISwitch()
    private let notificationContainer = UIView()
    private lazy var links = AppExternalLinks(presenter: self, data: data)
    private var themedButtons: [AppButton] = []
    private var headerButtons: [AppButton] = []
    private lazy var settingsButton = button(MainText.text("settings"), icon: .settings, kind: .iconSurface) { [weak self] in self?.router?.show(.settings) }
    private lazy var totalLeaderboard = button(MainText.text("leaderboard"), icon: .leaderboard, kind: .icon) { [weak self] in self?.router?.show(.leaderboard(.totalSolved)) }
    private lazy var buy = button(MainText.text("activity_main_b_buy_pro"), icon: .noAds, trailing: .pro, kind: .compact) { [weak self] in self?.showProPurchase() }
    private lazy var streakSettings = button(MainText.text("activate_day_streak"), icon: .bell, kind: .compact) { [weak self] in self?.router?.show(.dailySettings) }
    private lazy var dailyPlay = button(MainText.text("play_day_streak"), icon: .daily, kind: .compact) { [weak self] in self?.router?.show(.daily) }
    private lazy var graph = button(MainText.text("graph"), icon: .graph, kind: .iconSurface) { [weak self] in self?.router?.show(.graph(.dailyStreak)) }
    private lazy var dailyLeaderboard = button(MainText.text("leaderboard"), icon: .leaderboard, kind: .iconSurface) { [weak self] in self?.router?.show(.leaderboard(.dailyStreak)) }
    private lazy var insurance = button("", kind: .plain) { [weak self] in self?.showInsurance() }
    private lazy var rate = button(MainText.text("activity_main_b_Rate"), trailing: .star, kind: .compact) { [weak self] in self?.links.rate() }
    private lazy var support = button(MainText.text("activity_main_b_support"), trailing: .support, kind: .compact) { [weak self] in self?.links.support() }
    private lazy var instagram = button(MainText.text("math_riddles"), icon: .more, trailing: .instagram, kind: .menu) { [weak self] in self?.links.instagram() }
    private lazy var primary: [AppButton] = [
        menu("activity_main_b_Start", .singlePlayer, .gameModes),
        menu("activity_main_b_Teamwise", .multiplayer, .multiplayer),
        menu("activity_main_b_Training", .training, .tricks),
        menu("activity_main_b_by_heart", .byHeart, .byHeart),
        menu("example_statistics_title", .statistics, .statistics)
    ]

    init(router: AppRouter, data: AppDataStore) {
        self.router = router; self.data = data
        super.init(nibName: nil, bundle: nil)
        title = "Math Tricks"
    }
    init(previewSettings: AppSettings) {
        self.previewSettings=previewSettings;data=AppDataStore.shared
        super.init(nibName:nil,bundle:nil)
    }
    func updatePreview(settings: AppSettings) {
        guard previewSettings != nil else { return }
        previewSettings = settings
        if isViewLoaded { render(nil) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let palette = ThemePalette(settings: settings)
        if palette.theme.isClassic { return ThemeColor.luminance(palette.systemBar) > 0.5 ? .darkContent : .lightContent }
        return palette.theme.isDark ? .lightContent : .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.accessibilityIdentifier = "screen.main"
        layoutContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(layoutContainer)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            layoutContainer.topAnchor.constraint(equalTo: safe.topAnchor), layoutContainer.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            layoutContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor), layoutContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor)
        ])
        buildHeader()
        buildDailyPanel()
        _ = primary
        _ = rate; _ = support; _ = instagram
        instagram.label.numberOfLines=2
        instagram.label.lineBreakMode = .byWordWrapping
        if previewSettings != nil {view.isUserInteractionEnabled=false;render(nil)}
        else {observation = data.$snapshot.sink { [weak self] progress in self?.render(progress) }}
    }

    private func button(_ title: String, icon: AppIcon? = nil, trailing: AppIcon? = nil, kind: AppButton.Kind, action: @escaping () -> Void) -> AppButton {
        let result = AppButton(title: title, icon: icon, trailingIcon: trailing, kind: kind, balancesIcon: kind == .menu, action: action)
        themedButtons.append(result)
        return result
    }
    private func showProPurchase() { AppPurchases.shared.present(from: self, data: data) }
    func animateAndOpenPro() {
        proPurchaseTask?.cancel()
        proPurchaseTask = Task { [weak self] in
            do { try await Task.sleep(nanoseconds:800_000_000) } catch { return }
            guard let self, view.window != nil, navigationController?.topViewController === self else { return }
            let pulse = CAKeyframeAnimation(keyPath:"transform.scale")
            pulse.values = [1,0.9,1]; pulse.keyTimes = [0,0.5,1]
            pulse.duration = 1; pulse.repeatCount = 1
            pulse.preferredFrameRateRange = CAFrameRateRange(minimum:30,maximum:30,preferred:30)
            buy.layer.add(pulse,forKey:"buyPro")
            do { try await Task.sleep(nanoseconds:1_000_000_000) } catch { return }
            guard !Task.isCancelled, view.window != nil, navigationController?.topViewController === self else { return }
            buy.sendActions(for:.touchUpInside)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        proPurchaseTask?.cancel(); proPurchaseTask = nil
    }
    private func menu(_ key: String, _ icon: AppIcon, _ route: AppRoute) -> AppButton {
        let title = MainText.text(key)
        let caption = route == .statistics ? String(title.prefix(1)).uppercased() + title.dropFirst().lowercased() : title
        let result = button(caption, icon: icon, kind: .menu) { [weak self] in self?.router?.show(route) }
        result.accessibilityIdentifier = "main.\(key)"
        return result
    }
    private func stack(_ axis: NSLayoutConstraint.Axis, _ views: [UIView], spacing: CGFloat = 0) -> UIStackView {
        let result = UIStackView(arrangedSubviews: views); result.axis = axis; result.spacing = spacing
        return result
    }
    private func pin(_ child: UIView, in parent: UIView, insets: UIEdgeInsets = .zero) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: insets.top), child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -insets.bottom),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: insets.left), child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -insets.right)
        ])
    }
    private func buildHeader() {
        solvedLabel.textAlignment = .center
        solvedLabel.accessibilityIdentifier="main.totalSolved"
        let solved=stack(.horizontal,[totalLeaderboard,solvedLabel])
        solved.alignment = .center;solved.spacing=5
        let row=stack(.horizontal,[solved,buy,settingsButton])
        row.alignment = .fill
        pin(row,in:header)
        headerGroupWidth=solved.widthAnchor.constraint(equalTo:row.widthAnchor,multiplier:0.4)
        buyWidth = buy.widthAnchor.constraint(equalToConstant: AppMetrics.minimumTouchSize)
        settingsWidth=settingsButton.widthAnchor.constraint(equalToConstant:60)
        NSLayoutConstraint.activate([
            header.heightAnchor.constraint(greaterThanOrEqualToConstant:AppMetrics.headerHeight),
            settingsWidth!,totalLeaderboard.widthAnchor.constraint(equalToConstant:48)
        ])
        buy.label.numberOfLines=3;buy.label.lineBreakMode = .byWordWrapping
        buy.setContentInsets(UIEdgeInsets(top:10,left:10,bottom:10,right:10))
        for item in [totalLeaderboard,settingsButton,graph,dailyLeaderboard] {
            item.setContentInsets(UIEdgeInsets(top:8,left:4,bottom:8,right:4))
        }
        buy.accessibilityIdentifier="main.buyFullVersion"
        settingsButton.accessibilityIdentifier="main.settings"
        headerButtons=[totalLeaderboard]
    }
    private func buildDailyPanel() {
        dailyContents.axis = .vertical; dailyContents.spacing = 0
        pin(dailyContents, in: dailyPanel)
        dailyControls.axis = .horizontal; dailyControls.spacing = 0; dailyControls.alignment = .fill
        dailyActions.axis = .horizontal;dailyActions.distribution = .fillEqually
        dailyActions.addArrangedSubview(streakSettings);dailyActions.addArrangedSubview(dailyPlay)
        for item in [streakSettings,dailyPlay] {
            item.label.numberOfLines=3;item.label.lineBreakMode = .byWordWrapping
            item.setContentInsets(UIEdgeInsets(top:8,left:8,bottom:8,right:8))
        }
        dailyControls.addArrangedSubview(dailyActions)
        dailyControls.addArrangedSubview(graph); dailyControls.addArrangedSubview(dailyLeaderboard)
        graph.widthAnchor.constraint(equalToConstant: 48).isActive = true
        dailyLeaderboard.widthAnchor.constraint(equalToConstant: 48).isActive = true
        dailyContents.addArrangedSubview(dailyControls)
        counts.axis = .horizontal; counts.distribution = .fillEqually
        counts.addArrangedSubview(days); counts.addArrangedSubview(today)
        days.textAlignment = .right; today.textAlignment = .right
        days.accessibilityIdentifier = "main.streak"; today.accessibilityIdentifier = "main.today"
        insuranceRow.axis = .horizontal; insuranceRow.alignment = .center
        insuranceRow.distribution = .fillEqually
        insurance.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:28)
        insurance.label.textAlignment = .natural
        insurance.label.numberOfLines = 2
        insurance.label.lineBreakMode = .byTruncatingTail
        insuranceRow.addArrangedSubview(insurance)
        notificationLabel.text = MainText.text("enable_notifications")
        notificationLabel.numberOfLines = 2
        notificationLabel.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
        notificationLabel.setContentHuggingPriority(.required, for: .horizontal)
        notificationSwitch.setContentHuggingPriority(.required, for: .horizontal)
        notificationSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        let toggle = stack(.horizontal, [notificationLabel, notificationSwitch], spacing: 5)
        toggle.alignment = .center
        toggle.translatesAutoresizingMaskIntoConstraints = false
        notificationContainer.addSubview(toggle)
        NSLayoutConstraint.activate([
            toggle.leadingAnchor.constraint(greaterThanOrEqualTo: notificationContainer.leadingAnchor, constant: 4),
            toggle.trailingAnchor.constraint(equalTo: notificationContainer.trailingAnchor, constant: -4),
            toggle.topAnchor.constraint(equalTo: notificationContainer.topAnchor, constant: 2),
            toggle.bottomAnchor.constraint(equalTo: notificationContainer.bottomAnchor, constant: -2)
        ])
        notificationSwitch.accessibilityLabel = notificationLabel.text
        notificationSwitch.accessibilityIdentifier = "main.notificationSettings"
        notificationSwitch.addAction(UIAction { [weak self] _ in
            self?.notificationSwitch.setOn(false, animated: false)
            self?.router?.show(.dailySettings)
        }, for: .valueChanged)
        insuranceRow.addArrangedSubview(notificationContainer)
        let details = stack(.vertical, [counts, insuranceRow])
        pin(details, in: dailyDetails, insets: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        dailyContents.addArrangedSubview(dailyDetails)
    }

    override func traitCollectionDidChange(_ previousTraitCollection:UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard isViewLoaded,observation != nil else{return}
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory || previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            lastLandscape=nil;view.setNeedsLayout();render(data.snapshot)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let landscape = view.bounds.width > view.bounds.height
        if lastLandscape != landscape { rebuildLayout(landscape: landscape) }
        fitBuyLabel(landscape:landscape)
        fitRiddlesLabel()
    }
    private func fitRiddlesLabel() {
        let width=instagram.label.bounds.width
        guard width>0 else{return}
        let full=MainText.text("math_riddles")
        let height=(full as NSString).boundingRect(with:CGSize(width:width,height:.greatestFiniteMagnitude),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:[.font:instagram.label.font as Any],context:nil).height
        let caption=height<=2*instagram.label.font.lineHeight+1 ? full : MainText.text("math_riddles_short")
        if instagram.label.text != caption {instagram.label.text=caption}
    }
    private func fitBuyLabel(landscape:Bool) {
        let width=buy.label.bounds.width
        guard width>0 else{return}
        if hasFullVersion {
            buy.label.text = "PRO"
            buy.label.numberOfLines = 1
            buy.accessibilityLabel = AppPurchases.text("pro.active")
            return
        }
        let price = previewSettings == nil ? AppPurchases.shared.fullVersionPrice : nil
        let suffix = price.map { " " + $0 } ?? ""
        let full = MainText.text("activity_main_b_buy_pro") + suffix
        let short = MainText.text("activity_main_b_buy_pro_short") + suffix
        let lines=landscape ? 1 : 3
        func height(_ text: String) -> CGFloat {
            (text as NSString).boundingRect(with:CGSize(width:width,height:.greatestFiniteMagnitude),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:[.font:buy.label.font as Any],context:nil).height
        }
        let caption = height(full)<=CGFloat(lines)*buy.label.font.lineHeight+1 ? full : short
        if buy.label.text != caption { buy.label.text = caption }
        buy.accessibilityLabel = full
        buy.label.numberOfLines = landscape ? 1 : max(lines, Int(ceil(height(caption) / buy.label.font.lineHeight)))
        buy.label.adjustsFontSizeToFitWidth = landscape
        buy.label.minimumScaleFactor = 0.7
    }
    private func rebuildLayout(landscape: Bool) {
        lastLandscape = landscape
        NSLayoutConstraint.deactivate(footerWidths);footerWidths.removeAll()
        headerGroupWidth?.isActive = !landscape && !hasFullVersion
        settingsWidth?.constant=AndroidDimensions.value("ll_head",traits:traitCollection,size:view.bounds.size,fallback:60)
        landscapeActionWidth?.isActive=false;landscapeCountsWidth?.isActive=false
        layoutContainer.subviews.forEach { $0.removeFromSuperview() }
        let column = stack(.vertical, [header])
        column.spacing = 0
        pin(column, in: layoutContainer)
        // Return reusable arranged views to their portrait parents before regrouping.
        if counts.superview !== dailyDetails.subviews.first {
            if let details = dailyDetails.subviews.first as? UIStackView { details.insertArrangedSubview(counts, at: 0) }
        }
        if landscape {
            dailyControls.insertArrangedSubview(counts,at:1)
            landscapeActionWidth=dailyActions.widthAnchor.constraint(equalTo:dailyControls.widthAnchor,multiplier:0.6,constant:-57.6)
            landscapeCountsWidth=counts.widthAnchor.constraint(equalTo:dailyControls.widthAnchor,multiplier:0.4,constant:-38.4)
            landscapeActionWidth?.isActive=true;landscapeCountsWidth?.isActive=true
        } else {column.addArrangedSubview(dailyPanel)}
        days.textAlignment=landscape ? .natural : .right
        today.textAlignment=landscape ? .natural : .right
        let scroll = AppScrollView(); scroll.alwaysBounceVertical = false
        column.addArrangedSubview(scroll)
        let content = stack(.vertical, [])
        content.spacing = 0
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        if landscape { content.addArrangedSubview(dailyPanel) }
        let menuArea = UIView()
        let menu = stack(.vertical, [])
        menu.spacing = 0
        if landscape {
            let first = stack(.horizontal, Array(primary.prefix(3)))
            first.distribution = .fillEqually
            let second = stack(.horizontal, Array(primary.suffix(2)))
            second.distribution = .fillEqually
            menu.addArrangedSubview(first); menu.addArrangedSubview(second)
        } else { primary.forEach { menu.addArrangedSubview($0) } }
        if !landscape {
            let footer=UIView()
            let width=AndroidDimensions.value("a_main_b_rate",traits:traitCollection,size:view.bounds.size,fallback:150)
            for item in [rate,support] {
                footer.addSubview(item);item.label.numberOfLines=2
                NSLayoutConstraint.activate([
                    item.topAnchor.constraint(equalTo:footer.topAnchor),item.bottomAnchor.constraint(equalTo:footer.bottomAnchor),
                    item.widthAnchor.constraint(lessThanOrEqualTo:footer.widthAnchor,multiplier:0.5)
                ])
                let preferred=item.widthAnchor.constraint(equalToConstant:width);preferred.priority = .defaultHigh;preferred.isActive=true;footerWidths.append(preferred)
            }
            rate.leadingAnchor.constraint(equalTo:footer.leadingAnchor).isActive=true
            support.trailingAnchor.constraint(equalTo:footer.trailingAnchor).isActive=true
            menu.setCustomSpacing(AndroidDimensions.value("b_setttings_padding_bottom",traits:traitCollection,size:view.bounds.size,fallback:25),after:primary.last!)
            menu.addArrangedSubview(footer)
        }
        menu.translatesAutoresizingMaskIntoConstraints=false;menuArea.addSubview(menu)
        let margin=AndroidDimensions.value(landscape ? "a_main_ll_b_margins_land" : "a_main_ll_b_margins",traits:traitCollection,size:view.bounds.size,fallback:landscape ? 0 : 40)
        NSLayoutConstraint.activate([
            menu.leadingAnchor.constraint(equalTo:menuArea.leadingAnchor,constant:margin),menu.trailingAnchor.constraint(equalTo:menuArea.trailingAnchor,constant:-margin),
            menu.topAnchor.constraint(greaterThanOrEqualTo:menuArea.topAnchor),menu.bottomAnchor.constraint(lessThanOrEqualTo:menuArea.bottomAnchor)
        ])
        menu.centerYAnchor.constraint(equalTo:menuArea.centerYAnchor).isActive=true
        content.addArrangedSubview(menuArea)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor)
        ])
        if landscape {
            let footer = stack(.horizontal, [rate, instagram, support], spacing: 4)
            footer.distribution = .fillEqually
            column.addArrangedSubview(footer)
        } else {
            let footer = UIView()
            instagram.setContentInsets(UIEdgeInsets(top:8,left:14,bottom:8,right:14))
            pin(instagram, in: footer, insets: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
            column.addArrangedSubview(footer)
            footer.isHidden = instagram.isHidden
        }
        // Ensure the scrollable center receives spare height; fixed panels fit their content.
        scroll.setContentHuggingPriority(.init(1), for: .vertical)
        render(data.snapshot)
    }

    private func render(_ progress: ProgressState?) {
        settings = previewSettings ?? progress?.settings ?? AppSettings()
        let palette = ThemePalette(settings: settings)
        themedButtons.forEach { $0.apply(settings: settings) }
        buy.setIconsHidden(hasFullVersion)
        let horizontalPadding: CGFloat = hasFullVersion ? 8 : 10
        buy.setContentInsets(UIEdgeInsets(top:10,left:horizontalPadding,bottom:10,right:horizontalPadding))
        buyWidth?.constant = max(AppMetrics.minimumTouchSize, ceil(("PRO" as NSString).size(withAttributes: [.font: buy.label.font as Any]).width) + 2 * horizontalPadding)
        if hasFullVersion {
            headerGroupWidth?.isActive = false
            buyWidth?.isActive = true
        } else {
            buyWidth?.isActive = false
            headerGroupWidth?.isActive = lastLandscape == false
        }
        let headerText: UIColor = palette.theme.isClassic ? (palette.theme == .light ? .white : palette.text) : palette.text
        headerButtons.forEach { $0.apply(settings: settings, tint: headerText) }
        ThemeColorTransition.apply(header, color: palette.header)
        ThemeColorTransition.apply(dailyPanel, color: palette.theme.isClassic ? ThemeColor.shade(palette.header, 1.5) : palette.header)
        ThemeColorTransition.apply(dailyDetails, color: palette.theme.isClassic ? ThemeColor.shade(palette.header, 1.7) : palette.surface)
        for label in [solvedLabel,days,today,notificationLabel] {
            label.apply(settings:settings);label.textColor=label === solvedLabel ? headerText : palette.theme.isClassic ? (palette.theme == .light ? .white : palette.text) : palette.text
        }
        solvedLabel.attributedText=AndroidRichText.inline(MainText.richFormat("all_time_solved",progress.map{String($0.totalSolved)} ?? "—"),font:solvedLabel.font,color:headerText)
        if let daily = progress?.daily {
            days.attributedText=AndroidRichText.inline(MainText.richFormat("day_streak_text",String(daily.streak)),font:days.font,color:days.textColor)
            today.attributedText=AndroidRichText.inline(MainText.richFormat("day_streak_today","\(daily.solved)/\(daily.target)"),font:today.font,color:today.textColor)
            let status:String
            if (daily.pendingStreak ?? 0)>0 {status=CatalogText.ui("streak_pending")+": \(daily.pendingStreak ?? 0) · \(daily.pendingCost ?? 0)"}
            else if daily.endedDay != nil {status=CatalogText.ui("streak_ended")}
            else {status=MainText.count("streak_shield_progress",Int64(daily.insuranceProgress ?? 0))}
            let ready=(daily.readyInsurance ?? 0)>0 ? MainText.count("streak_shield_ready",Int64(daily.readyInsurance ?? 0))+"\n" : ""
            insurance.label.text = "ⓘ " + ready + status
            insurance.accessibilityLabel = insurance.label.text
        } else { days.text = "—"; today.text = "—"; insurance.label.text = "ⓘ" }
        insurance.label.textColor=palette.theme.isClassic ? (palette.theme == .light ? .white : palette.text) : palette.text
        if previewSettings != nil {
            solvedLabel.attributedText=AndroidRichText.inline(MainText.richFormat("all_time_solved","621"),font:solvedLabel.font,color:headerText)
            days.attributedText=AndroidRichText.inline(MainText.richFormat("day_streak_text","7"),font:days.font,color:days.textColor)
            today.attributedText=AndroidRichText.inline(MainText.richFormat("day_streak_today","5/10"),font:today.font,color:today.textColor)
        }
        notificationContainer.isHidden = previewSettings != nil || progress?.daily.notificationsEnabled == true
        insurance.label.textAlignment=notificationContainer.isHidden ? .center : .natural
        notificationSwitch.setOn(false, animated: false)
        notificationSwitch.onTintColor = palette.switchOnTint
        let wasHidden = instagram.isHidden
        // Temporarily hide Math Riddles in the menu and theme previews.
        instagram.isHidden = true
        if lastLandscape == false { instagram.superview?.isHidden = instagram.isHidden }
        if wasHidden != instagram.isHidden { view.setNeedsLayout() }
        view.setNeedsLayout()
        setNeedsStatusBarAppearanceUpdate()
    }
    private func showInsurance() {
        let daily = data.snapshot?.daily
        let progress = MainText.count("streak_shield_progress", Int64(daily?.insuranceProgress ?? 0))
        let pending = (daily?.pendingStreak ?? 0)>0 ? CatalogText.ui("streak_pending")+": \(daily?.pendingStreak ?? 0) · \(daily?.pendingCost ?? 0)\n" : ""
        let ready = (daily?.readyInsurance ?? 0) > 0 ? MainText.count("streak_shield_ready", Int64(daily?.readyInsurance ?? 0)) + "\n" : ""
        present(AppDialogViewController(title: MainText.text("streak_shield_title"), message: pending + ready + progress + "\n\n" + MainText.text("streak_shield_rules"),
            actions: [.init(title: MainText.text("ok"), handler: {})], data: data), animated: false)
    }
}
