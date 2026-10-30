import UIKit

/// A read-only miniature built from the application's UI components.
/// Samples never open a repository or create a session, reward, timer or sound.
final class FontSamplePreview: UIView, UITableViewDataSource {
    private enum CatalogPreviewRow { case group(CatalogGroup, Bool), trick(CatalogTrick, Int) }
    private var catalogRows: [CatalogPreviewRow] = []
    private var kind: Int
    var showsSelectionBorder = true
    var referenceSize: CGSize? {
        didSet {
            guard oldValue != referenceSize else {return}
            let size = referenceSize ?? window?.bounds.size ?? UIScreen.main.bounds.size
            if let sceneLandscape, sceneLandscape != (size.width > size.height) { rebuild() }
            setNeedsLayout()
        }
    }
    func showFrame(_ value: Int) {
        guard (0...3).contains(value), kind != value else { return }
        setHostVisible(false)
        if content != nil || menuPreview != nil {
            cachedScenes[kind] = (content, menuPreview, appearanceUpdates)
            content?.isHidden = true; menuPreview?.view.isHidden = true
        }
        kind = value; content = nil; menuPreview = nil; appearanceUpdates = []; motionNeedsUpdate = true
        if let cached = cachedScenes.removeValue(forKey: value), let settings {
            content = cached.content; menuPreview = cached.menu; appearanceUpdates = cached.updates
            appearanceUpdates.forEach { $0(settings) }; menuPreview?.updatePreview(settings: settings)
            content?.isHidden = false; menuPreview?.view.isHidden = false
        } else { buildCurrent() }
        setNeedsLayout()
    }
    func setHostVisible(_ visible: Bool) {
        guard hostVisible != visible || motionNeedsUpdate else { return }
        hostVisible = visible; motionNeedsUpdate = false; backdrop.setHostVisible(visible)
        func update(_ view: UIView, visible: Bool) {
            let shown = visible && !view.isHidden
            if let surface = view as? ThemeExpressionSurfaceView, surface.motionEnabled != shown { surface.motionEnabled = shown }
            for child in view.subviews { update(child, visible: shown) }
        }
        update(scene, visible: visible)
    }
    func discardCachedScenes() {
        for cached in cachedScenes.values { cached.content?.removeFromSuperview(); cached.menu?.view.removeFromSuperview() }
        cachedScenes.removeAll()
    }
    private let scene = UIView()
    private let backdrop = ThemeBackgroundView()
    private var settings: AppSettings?
    private var content: UIStackView?
    private var menuPreview: MainMenuViewController?
    private var appearanceUpdates: [(AppSettings) -> Void] = []
    private var cachedScenes: [Int: (content: UIStackView?, menu: MainMenuViewController?, updates: [(AppSettings) -> Void])] = [:]
    private var hostVisible = false
    private var motionNeedsUpdate = true
    private var sceneLandscape: Bool?

    init(kind: Int) {
        self.kind = kind
        super.init(frame: .zero)
        clipsToBounds = true; layer.cornerRadius = 10
        accessibilityElementsHidden = true; isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        scene.isUserInteractionEnabled = false; addSubview(scene)
        backdrop.translatesAutoresizingMaskIntoConstraints = false;backdrop.isHidden=true;scene.addSubview(backdrop)
        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: scene.topAnchor), backdrop.bottomAnchor.constraint(equalTo: scene.bottomAnchor),
            backdrop.leadingAnchor.constraint(equalTo: scene.leadingAnchor), backdrop.trailingAnchor.constraint(equalTo: scene.trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func prepareBackground(settings: AppSettings) {
        let palette=ThemePalette(settings:settings)
        backgroundColor=palette.background
        layer.borderWidth=showsSelectionBorder ? 2 : 0;layer.borderColor=palette.accent.cgColor
    }
    func apply(settings: AppSettings) {
        prepareBackground(settings:settings)
        guard self.settings != settings else { return }
        var previous = self.settings
        previous?.accentColorHex = settings.accentColorHex
        previous?.themeIntensity = settings.themeIntensity
        previous?.themeBaseColorHex = settings.themeBaseColorHex
        previous?.themeIntensities = settings.themeIntensities
        previous?.onboarding = settings.onboarding
        previous?.fontSizePercent = settings.fontSizePercent
        previous?.useSystemFontSize = settings.useSystemFontSize
        let appearanceOnly = previous == settings
        self.settings = settings
        backdrop.apply(settings: settings);backdrop.isHidden=false
        if appearanceOnly {
            layer.borderColor = ThemePalette(settings: settings).accent.cgColor
            appearanceUpdates.forEach { $0(settings) }
            menuPreview?.updatePreview(settings: settings)
        } else {
            rebuild(); setNeedsLayout()
        }
        setHostVisible(hostVisible)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = referenceSize ?? window?.bounds.size ?? UIScreen.main.bounds.size
        guard bounds.width > 0, size.width > 0 else { return }
        scene.transform = .identity; scene.bounds = CGRect(origin: .zero, size: size)
        scene.center = CGPoint(x: bounds.midX, y: bounds.midY)
        scene.transform = CGAffineTransform(scaleX: bounds.width / size.width, y: bounds.width / size.width)
        scene.setNeedsLayout(); scene.layoutIfNeeded()
    }

    private func text(_ value: String, role: AppTextRole = .body, color: UIColor? = nil) -> AppLabel {
        let label = AppLabel(role)
        let settings = settings ?? AppSettings()
        label.text = value; label.apply(settings: settings)
        label.textColor = color ?? ThemePalette(settings: settings).text
        appearanceUpdates.append { label.apply(settings:$0) }
        return label
    }
    private func button(_ value: String, icon: AppIcon? = nil, kind: AppButton.Kind = .dialog) -> AppButton {
        let button = AppButton(title: value, icon: icon, kind: kind, balancesIcon: false, action: {})
        button.apply(settings: settings ?? AppSettings())
        appearanceUpdates.append { button.apply(settings: $0) }
        return button
    }
    private func row(_ views: [UIView], equally: Bool = false) -> UIStackView {
        let row = UIStackView(arrangedSubviews: views); row.axis = .horizontal; row.alignment = equally ? .fill : .center
        if equally { row.distribution = .fillEqually }
        return row
    }

    private func rebuild() {
        discardCachedScenes(); buildCurrent()
        setHostVisible(hostVisible)
    }
    private func buildCurrent() {
        guard let settings else { return }
        let size = referenceSize ?? window?.bounds.size ?? UIScreen.main.bounds.size
        sceneLandscape = size.width > size.height; motionNeedsUpdate = true
        appearanceUpdates.removeAll()
        content?.removeFromSuperview(); content=nil
        menuPreview?.view.removeFromSuperview();menuPreview=nil
        if kind == 1 {
            let controller=MainMenuViewController(previewSettings:settings);menuPreview=controller
            ResultUI.pin(controller.view,in:scene);return
        }
        let content = UIStackView(); content.axis = .vertical; content.spacing = 0
        content.translatesAutoresizingMaskIntoConstraints = false; scene.addSubview(content); self.content = content
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scene.topAnchor), content.leadingAnchor.constraint(equalTo: scene.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scene.trailingAnchor),
            content.bottomAnchor.constraint(lessThanOrEqualTo: scene.bottomAnchor)
        ])
        let palette = ThemePalette(settings:settings)
        layer.borderWidth=showsSelectionBorder ? 2 : 0;layer.borderColor=palette.accent.cgColor
        if kind == 2 { buildSolution(content) }
        else {
            let header=AppHeaderView(title:kind == 0 ? MainText.format("activity_game_tv_level","3") : AppRoute.tricks.title,onBack:{})
            header.apply(settings:settings);content.addArrangedSubview(header)
            appearanceUpdates.append { header.apply(settings:$0) }
            if kind == 0 { buildGame(content,header:header) } else { buildCatalog(content) }
        }
        setHostVisible(hostVisible)
    }

    private func buildGame(_ content: UIStackView, header: AppHeaderView) {
        guard let settings else { return }
        let landscape = sceneLandscape == true
        let palette = ThemePalette(settings:settings), headColor = palette.headerText
        let info = ResultUI.stack(landscape ? .horizontal : .vertical)
        info.distribution = landscape ? .fillEqually : .fill
        info.alignment = landscape ? .center : .leading
        for value in [MainText.format("activity_game_tv_level","3"),MainText.format("activity_game_tv_examples","7 / 10")] {
            let label = text(value,role:.headCount,color:headColor)
            label.numberOfLines=1;label.adjustsFontSizeToFitWidth=true;label.minimumScaleFactor=0.7
            info.addArrangedSubview(label)
        }
        let score = text("120",role:.score,color:headColor)
        score.numberOfLines=1;score.adjustsFontSizeToFitWidth=true;score.minimumScaleFactor=0.5
        let stars = UIImageView(image:palette.gameStars(2));stars.contentMode = .scaleAspectFit
        appearanceUpdates.append { stars.image=ThemePalette(settings:$0).gameStars(2) }
        NSLayoutConstraint.activate([stars.widthAnchor.constraint(equalToConstant:75),stars.heightAnchor.constraint(equalToConstant:30)])
        let hud = row([info,score,stars]);hud.alignment = .center;hud.spacing=8
        let balance=info.widthAnchor.constraint(equalTo:score.widthAnchor,multiplier:landscape ? 2 : 1);balance.priority = .init(999);balance.isActive=true
        header.replaceTitle(with:hud)
        content.bottomAnchor.constraint(equalTo:scene.bottomAnchor).isActive=true

        let area = UIView();area.translatesAutoresizingMaskIntoConstraints=false;content.addArrangedSubview(area)
        let equation=text("35 × 11 = ",role:.expression), answer=text("385",role:.expression)
        let expression=FittingMathExpressionView(equation:equation,answer:answer)
        expression.fillsSurface=true;expression.apply(settings:settings);ResultUI.pin(expression,in:area)
        appearanceUpdates.append { expression.apply(settings:$0) }
        let coin=UIImageView(image:AppIcon.coins.image);coin.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([coin.widthAnchor.constraint(equalToConstant:40),coin.heightAnchor.constraint(equalToConstant:40)])
        let coins=row([coin,text("240",role:.catalogTrick)]);coins.alignment = .center;coins.spacing=4
        coins.translatesAutoresizingMaskIntoConstraints=false;area.addSubview(coins)
        appearanceUpdates.append { coin.image=AppIcon.coins.image?.withTintColor(ThemePalette(settings:$0).accent,renderingMode:.alwaysOriginal) }
        let voice=button("",icon:.voiceOn,kind:.icon);voice.isHidden = !AppSpeech.isEnabled
        voice.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:32);area.addSubview(voice)
        NSLayoutConstraint.activate([
            voice.trailingAnchor.constraint(equalTo:area.trailingAnchor,constant:-8),voice.bottomAnchor.constraint(equalTo:area.bottomAnchor,constant:-8),voice.widthAnchor.constraint(equalToConstant:44)
        ])
        let change=button("",icon:.changeInput,kind:.icon)
        change.setContentInsets(UIEdgeInsets(top:2,left:8,bottom:2,right:8),minimumHeight:40)
        if !landscape {
            NSLayoutConstraint.activate([
                coins.topAnchor.constraint(equalTo:area.topAnchor,constant:8),
                coins.trailingAnchor.constraint(equalTo:area.trailingAnchor,constant:-16)
            ])
            area.addSubview(change)
            NSLayoutConstraint.activate([change.leadingAnchor.constraint(equalTo:area.leadingAnchor,constant:8),change.bottomAnchor.constraint(equalTo:area.bottomAnchor,constant:-8)])
        }
        let utility=ResultUI.stack(.vertical)
        let progress=AndroidGameProgressView();progress.apply(settings:settings);progress.setProgress(0.72,animated:false)
        if !landscape { utility.addArrangedSubview(progress) }
        appearanceUpdates.append { progress.apply(settings:$0) }
        let rule=AppScrollView(), name=text(TrickCatalog.shared.trick(5).map { AndroidRichText.plain(CatalogText.text($0.nameKey)) } ?? "")
        name.role = .catalogTrick;name.textAlignment = .center;name.translatesAutoresizingMaskIntoConstraints=false;rule.addSubview(name)
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo:rule.contentLayoutGuide.topAnchor),name.bottomAnchor.constraint(equalTo:rule.contentLayoutGuide.bottomAnchor),
            name.leadingAnchor.constraint(equalTo:rule.contentLayoutGuide.leadingAnchor,constant:5),name.trailingAnchor.constraint(equalTo:rule.contentLayoutGuide.trailingAnchor,constant:-5),
            name.widthAnchor.constraint(equalTo:rule.frameLayoutGuide.widthAnchor,constant:-10),name.heightAnchor.constraint(greaterThanOrEqualTo:rule.frameLayoutGuide.heightAnchor)
        ])
        let skip=button("10",icon:.skip),hint=button("10",icon:.hint)
        for (item,icon) in [(skip,AppIcon.skip),(hint,AppIcon.hint)] {
            item.label.role = .gameUtility;item.label.numberOfLines=1;item.setContentSpacing(14)
            item.label.adjustsFontSizeToFitWidth=true;item.label.minimumScaleFactor=0.5
            item.setContentInsets(UIEdgeInsets(top:10,left:20,bottom:10,right:20),minimumHeight:50)
            let width=item.widthAnchor.constraint(equalToConstant:94);width.isActive=true
            let update: (AppSettings)->Void = { _ in
                width.constant=54+min(40,icon.image?.size.width ?? 24)+ceil(("10" as NSString).size(withAttributes:[.font:item.label.font!]).width)+1
            }
            appearanceUpdates.append(update);update(settings)
        }
        let actions=row(landscape ? [change,UIView(),skip,hint] : [skip,rule,hint]);actions.alignment = .center
        actions.isLayoutMarginsRelativeArrangement=true;actions.directionalLayoutMargins=NSDirectionalEdgeInsets(top:0,leading:8,bottom:0,trailing:8)
        utility.addArrangedSubview(actions)
        if landscape {
            name.setContentHuggingPriority(.init(1),for:.vertical)
            rule.setContentHuggingPriority(.init(1),for:.vertical)
            utility.insertArrangedSubview(rule,at:0)
            let preferredHeaderHeight=header.heightAnchor.constraint(equalToConstant:AppMetrics.headerHeight)
            preferredHeaderHeight.priority = .init(749);preferredHeaderHeight.isActive=true
            let move=button("",icon:settings.keypadOnRight == true ? .backward : .forward,kind:.iconSurface)
            move.setContentInsets(UIEdgeInsets(top:15,left:15,bottom:15,right:15),minimumHeight:44.5)
            NSLayoutConstraint.activate([move.widthAnchor.constraint(equalToConstant:45),move.heightAnchor.constraint(equalToConstant:44.5)])
            let moveRow=row(settings.keypadOnRight == true ? [coins,UIView(),move] : [move,UIView(),coins])
            moveRow.isLayoutMarginsRelativeArrangement=true;moveRow.directionalLayoutMargins=NSDirectionalEdgeInsets(top:0,leading:10,bottom:0,trailing:10)
            utility.insertArrangedSubview(moveRow,at:0)
            NSLayoutConstraint.activate([
                moveRow.heightAnchor.constraint(equalTo:move.heightAnchor),
                actions.heightAnchor.constraint(equalTo:hint.heightAnchor)
            ])
        } else { rule.heightAnchor.constraint(equalToConstant:50).isActive=true;content.addArrangedSubview(utility) }
        let keyboard=ResultUI.stack(.vertical);keyboard.distribution = .fillEqually
        for numbers in (settings.numpad123 ? [[1,2,3],[4,5,6],[7,8,9]] : [[7,8,9],[4,5,6],[1,2,3]]) + [[0,-1]] {
            keyboard.addArrangedSubview(row(numbers.map { number in
                let key=button(number >= 0 ? String(number) : "",icon:number >= 0 ? nil : .backspace,kind:number >= 0 ? .keypad : .keypadIcon)
                key.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:24)
                return key
            },equally:true))
        }
        let lower: UIStackView
        if landscape {
            content.removeArrangedSubview(area);area.removeFromSuperview()
            let inputColumn=UIStackView(arrangedSubviews:[progress,area,keyboard]);inputColumn.axis = .vertical
            lower=row(settings.keypadOnRight == true ? [utility,inputColumn] : [inputColumn,utility]);lower.alignment = .fill
            inputColumn.widthAnchor.constraint(equalTo:lower.widthAnchor,multiplier:0.5).isActive=true
        } else { lower=keyboard }
        content.addArrangedSubview(lower)
        let height=(landscape ? keyboard : lower).heightAnchor.constraint(equalTo:scene.heightAnchor,multiplier:0.5);height.priority = .init(999);height.isActive=true
    }

    private func buildSolution(_ content: UIStackView) {
        guard let settings else { return }
        let example=MathExample(trickID:5,operand1:35,operand2:11,displayedOperand1:35,displayedOperand2:11,answer:385,operation:.multiplication)
        guard let steps=try? SolutionStep.generate(example),let final=steps.last else { return }
        func format(_ key: String, _ value: String) -> String {
            CatalogText.ui(key).replacingOccurrences(of:"%1$s",with:value).replacingOccurrences(of:"%s",with:value).replacingOccurrences(of:"%d",with:value)
        }
        let landscape=sceneLandscape == true
        content.spacing=4;content.isLayoutMarginsRelativeArrangement=true
        content.directionalLayoutMargins=NSDirectionalEdgeInsets(top:0,leading:5,bottom:0,trailing:5)
        content.bottomAnchor.constraint(equalTo:scene.bottomAnchor).isActive=true
        let workspace=ResultUI.stack(landscape ? .horizontal : .vertical,spacing:5)
        if landscape {workspace.distribution = .fillEqually}
        let left=ResultUI.stack(.vertical,spacing:4),right=ResultUI.stack(.vertical,spacing:4)
        right.setContentHuggingPriority(.defaultHigh,for:.vertical)
        workspace.addArrangedSubview(left);workspace.addArrangedSubview(right);content.addArrangedSubview(workspace)
        let diagram=UIView();diagram.translatesAutoresizingMaskIntoConstraints=false;left.addArrangedSubview(diagram)
        diagram.heightAnchor.constraint(greaterThanOrEqualToConstant:48).isActive=true
        let scroll=AppScrollView();ResultUI.pin(scroll,in:diagram)
        let scheme=SolutionSchemeView();scroll.addSubview(scheme)
        NSLayoutConstraint.activate([
            scheme.topAnchor.constraint(equalTo:scroll.contentLayoutGuide.topAnchor,constant:AppMetrics.headerHeight),scheme.bottomAnchor.constraint(equalTo:scroll.contentLayoutGuide.bottomAnchor,constant:-10),
            scheme.leadingAnchor.constraint(equalTo:scroll.contentLayoutGuide.leadingAnchor,constant:15),scheme.trailingAnchor.constraint(equalTo:scroll.contentLayoutGuide.trailingAnchor,constant:-15),
            scheme.widthAnchor.constraint(equalTo:scroll.frameLayoutGuide.widthAnchor,constant:-30)
        ])
        let schemeWidth=max(1,(referenceSize ?? UIScreen.main.bounds.size).width*(landscape ? 0.5 : 1)-40)
        let updateScheme: (AppSettings)->Void = { settings in
            let width=scheme.bounds.width > 0 ? scheme.bounds.width : schemeWidth
            let style=SolutionSchemeView.RuleStyle(width:width,texts:[final.processedEquation(input:"",trickID:example.trickID).text],settings:settings,traits:scheme.traitCollection,zoom:1,isSolution:true)
            scheme.apply(step:final,input:"",example:example,settings:settings,frozen:true,ruleStyle:style)
        }
        appearanceUpdates.append(updateScheme);updateScheme(settings)
        let back=button("",icon:.back,kind:.icon);back.setContentInsets(UIEdgeInsets(top:8,left:8,bottom:8,right:8),minimumHeight:AppMetrics.headerHeight);diagram.addSubview(back)
        NSLayoutConstraint.activate([back.topAnchor.constraint(equalTo:diagram.topAnchor),back.leadingAnchor.constraint(equalTo:diagram.leadingAnchor,constant:-5),back.widthAnchor.constraint(equalToConstant:AppMetrics.headerBackWidth),back.heightAnchor.constraint(equalToConstant:AppMetrics.headerHeight)])
        let tools=ResultUI.stack(.vertical,spacing:4);tools.alignment = .center;tools.translatesAutoresizingMaskIntoConstraints=false;diagram.addSubview(tools)
        let table=AppCaptionIconButton(imageName:"ic_multiplication_table",iconSize:24,captionSize:9,bold:true,padding:2) {}
        table.label.text=CatalogText.ui("solution_multiplication_table");table.alpha=0.65;tools.addArrangedSubview(table)
        let method=AppCaptionIconButton(imageName:"ic_fx",iconSize:24,captionSize:8,bold:true,padding:2) {}
        method.label.text=CatalogText.ui("rule_method_1");method.alpha=0.65;tools.addArrangedSubview(method)
        for icon in [AppIcon.zoomIn,.zoomOut] {
            let key=button("",icon:icon,kind:.icon);key.setContentInsets(UIEdgeInsets(top:6,left:6,bottom:6,right:6),minimumHeight:36)
            key.widthAnchor.constraint(equalToConstant:36).isActive=true;key.heightAnchor.constraint(equalToConstant:36).isActive=true;tools.addArrangedSubview(key)
        }
        NSLayoutConstraint.activate([tools.topAnchor.constraint(equalTo:diagram.topAnchor,constant:5),tools.trailingAnchor.constraint(equalTo:diagram.trailingAnchor,constant:-10)])
        let updateTools: (AppSettings)->Void = { settings in
            let palette=ThemePalette(settings:settings),color=palette.theme.isAnimated ? UIColor.white : palette.theme.isDark ? ThemeColor.rgb(0xB0B0B0) : ThemeColor.rgb(0x333333)
            back.apply(settings:settings,tint:color);table.apply(color:color,iconColor:palette.theme.isDark ? .white : color);method.apply(color:palette.theme.isDark ? .white : .black)
        }
        appearanceUpdates.append(updateTools);updateTools(settings)
        let insertAnswer = button(format("solution_insert_answer","385"),kind:.compact)
        let shareSolution = button(CatalogText.ui("share_solution"),icon:.resultShare,kind:.compact)
        for control in [insertAnswer,shareSolution] { control.label.role = .detail; control.setContentInsets(UIEdgeInsets(top:8,left:12,bottom:8,right:12),minimumHeight:48) }
        right.addArrangedSubview(row([insertAnswer,shareSolution],equally:true))
        let list=UIView();list.translatesAutoresizingMaskIntoConstraints=false;right.addArrangedSubview(list)
        let stepsScroll=AppScrollView();ResultUI.pin(stepsScroll,in:list)
        let rows=ResultUI.stack(.vertical);rows.translatesAutoresizingMaskIntoConstraints=false;stepsScroll.addSubview(rows)
        NSLayoutConstraint.activate([
            rows.topAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.topAnchor),rows.bottomAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.bottomAnchor),
            rows.leadingAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.leadingAnchor),rows.trailingAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.trailingAnchor),rows.widthAnchor.constraint(equalTo:stepsScroll.frameLayoutGuide.widthAnchor)
        ])
        if !landscape {let height=list.heightAnchor.constraint(equalToConstant:180);height.priority = .init(999);height.isActive=true}
        if !landscape {
            let resize=ResultUI.stack(.vertical,spacing:2);resize.translatesAutoresizingMaskIntoConstraints=false;resize.layer.cornerRadius=5;list.addSubview(resize)
            for title in ["+","−"] {
                let key=UIButton(type:.system);key.setTitle(title,for:.normal);key.titleLabel?.font = .systemFont(ofSize:20)
                key.widthAnchor.constraint(equalToConstant:32).isActive=true;key.heightAnchor.constraint(equalToConstant:28).isActive=true;resize.addArrangedSubview(key)
                appearanceUpdates.append { key.tintColor=ThemePalette(settings:$0).text };key.tintColor=ThemePalette(settings:settings).text
            }
            NSLayoutConstraint.activate([resize.trailingAnchor.constraint(equalTo:list.trailingAnchor),resize.bottomAnchor.constraint(equalTo:list.bottomAnchor,constant:-2)])
            let update: (AppSettings)->Void = { resize.backgroundColor=ThemePalette(settings:$0).dialogBackground }
            appearanceUpdates.append(update);update(settings)
        }
        let updateList: (AppSettings)->Void = { list.backgroundColor=ThemePalette(settings:$0).accent.withAlphaComponent(0.06) }
        appearanceUpdates.append(updateList);updateList(settings)
        for (position,step) in steps.enumerated() {
            let title=format("rule_step_title",String(position+(steps.first?.isIntro == true ? 0 : 1))),selected=position == steps.count-1
            let item=SolutionStepRow(title:title,step:step,settings:settings,selected:selected) {};rows.addArrangedSubview(item)
            appearanceUpdates.append { item.apply(title:title,step:step,settings:$0,selected:selected) }
        }
        let actions=row([button(format("solution_next_step_btn","10"),icon:.solveStep,kind:.compact),button(format("solution_solve_all_btn","3"),icon:.solveAll,kind:.compact)],equally:true);actions.spacing=8
        for case let key as AppButton in actions.arrangedSubviews {
            key.label.role = .detail;key.setContentInsets(UIEdgeInsets(top:10,left:12,bottom:10,right:12),minimumHeight:48);key.setContentSpacing(12);key.isEnabled=false
        }
        right.addArrangedSubview(actions)
        let keyboard=ResultUI.stack(.vertical);keyboard.distribution = .fillEqually
        let small=UserDefaults.standard.bool(forKey:"solution.numpadSmall")
        let values=small ? [["1","2","3","4","5","6"],["toggle","7","8","9","0","⌫"]] : [["1","2","3"],["4","5","6"],["7","8","9"],["toggle","0","⌫"]]
        for values in values {
            let keys=values.map { value -> UIView in
                if value == "toggle" {
                    let toggle=button("",icon:small ? .keyboardExpand : .keyboardCollapse,kind:.icon)
                    toggle.setContentInsets(UIEdgeInsets(top:0,left:2,bottom:0,right:2),minimumHeight:20)
                    let dot=button(".",kind:.playerKey);dot.label.role=small || landscape ? .caption : .playerNumber;dot.isEnabled=false
                    dot.setContentInsets(UIEdgeInsets(top:0,left:2,bottom:0,right:2),minimumHeight:20)
                    return row([toggle,dot],equally:true)
                }
                let key=button(value == "⌫" ? "" : value,icon:value == "⌫" ? .backspace : nil,kind:value == "⌫" ? .keypadIcon : .playerKey)
                key.label.role=small || landscape ? .caption : .playerNumber;key.isEnabled=false
                key.setContentInsets(UIEdgeInsets(top:0,left:2,bottom:0,right:2),minimumHeight:20);return key
            }
            keyboard.addArrangedSubview(row(keys,equally:true))
        }
        right.addArrangedSubview(keyboard)
        let height=keyboard.heightAnchor.constraint(equalToConstant:small ? 72 : landscape ? 136 : 192);height.priority = .defaultHigh;height.isActive=true
    }

    private func buildCatalog(_ content: UIStackView) {
        guard let settings else { return }
        content.bottomAnchor.constraint(equalTo:scene.bottomAnchor).isActive=true
        if let header=content.arrangedSubviews.first as? AppHeaderView {
            func headerKey(_ icon: AppIcon, width: CGFloat) -> AppButton {
                let key=button("",icon:icon,kind:.icon)
                key.setContentInsets(UIEdgeInsets(top:12,left:12,bottom:12,right:12));key.widthAnchor.constraint(equalToConstant:width).isActive=true
                let update: (AppSettings)->Void = { key.apply(settings:$0,tint:ThemePalette(settings:$0).headerText) }
                appearanceUpdates.append(update);update(settings);return key
            }
            let title=text(AppRoute.tricks.title,role:.trickName,color:ThemePalette(settings:settings).headerText)
            title.textAlignment = .center;title.numberOfLines=1;title.lineBreakMode = .byTruncatingTail
            title.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
            let titleRow=row([headerKey(.up,width:44),headerKey(.down,width:44),title]);titleRow.alignment = .center
            header.replaceTitle(with:titleRow)
            let total=text("24/\(TrickCatalog.shared.tricks.count * TrickCatalog.shared.levelCount)",role:.trickName,color:ThemePalette(settings:settings).headerText)
            total.numberOfLines=1;total.adjustsFontSizeToFitWidth=true;total.minimumScaleFactor=0.65
            let check=AndroidCheckBox();check.isOn=true;check.widthAnchor.constraint(equalToConstant:48).isActive=true;check.heightAnchor.constraint(equalToConstant:36).isActive=true
            let update: (AppSettings)->Void = { check.onTintColor=ThemePalette(settings:$0).headerText }
            appearanceUpdates.append(update);update(settings)
            let counts=ResultUI.stack(.vertical);counts.alignment = .trailing;counts.spacing=2
            counts.addArrangedSubview(total);counts.addArrangedSubview(check)
            total.setContentCompressionResistancePriority(.required,for:.horizontal)
            let compactWidth=counts.widthAnchor.constraint(equalToConstant:48)
            compactWidth.priority = .defaultHigh;compactWidth.isActive=true
            let accessory=row([headerKey(.leaderboard,width:40),counts]);accessory.alignment = .center;accessory.spacing=4
            accessory.isLayoutMarginsRelativeArrangement=true;accessory.directionalLayoutMargins=NSDirectionalEdgeInsets(top:2,leading:4,bottom:2,trailing:8)
            accessory.setContentHuggingPriority(.required,for:.horizontal);accessory.setContentCompressionResistancePriority(.required,for:.horizontal)
            header.setAccessoryView(accessory,trailingInset:0)
        }
        catalogRows=[]
        let groups=TrickCatalog.shared.groups
        for index in [0,2,3,4,5] where groups.indices.contains(index) {
            let group=groups[index], expanded=index == 2
            catalogRows.append(.group(group,expanded))
            if expanded {
                for (position,trick) in TrickCatalog.shared.tricks(in:group.id).prefix(3).enumerated() { catalogRows.append(.trick(trick,position+1)) }
            }
        }
        let table=AppTableView(frame:.zero,style:.plain)
        table.backgroundColor = .clear;table.separatorStyle = .none;table.contentInsetAdjustmentBehavior = .never
        table.estimatedRowHeight=68;table.rowHeight=UITableView.automaticDimension;table.showsVerticalScrollIndicator=false
        table.register(TrainingCatalogCell.self,forCellReuseIdentifier:"trick");table.register(TrainingCatalogGroupCell.self,forCellReuseIdentifier:"group")
        table.dataSource=self;content.addArrangedSubview(table)
        appearanceUpdates.append { [weak self] settings in
            guard let self else { return }
            for cell in table.visibleCells {
                if let path=table.indexPath(for:cell) { configureCatalogCell(cell,row:catalogRows[path.row],settings:settings) }
            }
            UIView.performWithoutAnimation { table.beginUpdates();table.endUpdates() }
        }
        let actions=row([
            button(MainText.text("activity_main_b_one_player"),icon:.singlePlayer),
            button(MainText.text("activity_main_b_two_players"),icon:.multiplayer)
        ],equally:true)
        actions.isLayoutMarginsRelativeArrangement=true;actions.directionalLayoutMargins=NSDirectionalEdgeInsets(top:0,leading:10,bottom:0,trailing:10)
        for case let key as AppButton in actions.arrangedSubviews {
            key.setContentInsets(UIEdgeInsets(top:10,left:5,bottom:10,right:5))
            key.label.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        }
        content.addArrangedSubview(actions)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { catalogRows.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row=catalogRows[indexPath.row]
        let identifier: String
        switch row { case .group: identifier="group";case .trick: identifier="trick" }
        let cell=tableView.dequeueReusableCell(withIdentifier:identifier,for:indexPath)
        configureCatalogCell(cell,row:row,settings:settings ?? AppSettings());return cell
    }
    private func configureCatalogCell(_ cell: UITableViewCell, row: CatalogPreviewRow, settings: AppSettings) {
        switch row {
        case .group(let group,let expanded):
            (cell as? TrainingCatalogGroupCell)?.configure(group:group,expanded:expanded,settings:settings)
        case .trick(let trick,let position):
            (cell as? TrainingCatalogCell)?.configure(trick:trick,position:position,value:TrickProgress(id:trick.id,selected:true,unlocked:true),completed:position == 1 ? TrickCatalog.shared.levelCount : 0,settings:settings,busy:false)
        }
    }
}
