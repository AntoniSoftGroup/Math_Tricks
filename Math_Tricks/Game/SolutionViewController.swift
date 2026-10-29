import UIKit

final class SolutionViewController: ThemedViewController {
    private struct Parent {
        let example: MathExample
        let steps: [SolutionStep]
        let index, reached, variant: Int
        let input: String
        let methods: [MathExample]
        let methodIndex: Int
    }
    private var example: MathExample
    private let preview, isNested: Bool
    private var steps: [SolutionStep] = []
    private var index = 0, reached = 0, variant = 0
    private var input = ""
    private var parents: [Parent] = []
    private var methods: [MathExample] = []
    private var methodIndex = 0
    private var localSteps = 9, localSolutions = 9
    private var smallKeyboard = UserDefaults.standard.bool(forKey:"solution.numpadSmall")
    private var landscape: Bool?
    private var dirtyScheme = true
    private var lastWidth: CGFloat = 0
    private var zoom: CGFloat {
        get { let saved = UserDefaults.standard.double(forKey:"rule_scheme_zoom"); return saved > 0 ? saved : 1 }
        set { UserDefaults.standard.set(Double(newValue),forKey:"rule_scheme_zoom") }
    }
    private let column = UIStackView(), workspace = UIStackView(), keyboard = UIStackView()
    private let leftPanel = UIStackView(), rightPanel = UIStackView()
    private let diagramPanel = UIView(), listPanel = UIView()
    private let diagramScroll = AppScrollView(), stepsScroll = AppScrollView()
    private let diagrams = UIStackView(), rows = UIStackView(), heightControls = UIStackView(), crumbs = UIStackView()
    private let scheme = SolutionSchemeView()
    private let nestingArrows = SchemeNestingArrows()
    private let schemeScrollPosition = SchemeScrollPosition()
    private let crumbSurface = ThemeSurfaceView(.button)
    private var crumbHeight: NSLayoutConstraint?
    private var breadcrumbDepth = 0
    private let separateContainer = UIStackView()
    private let separateIcon = UIImageView(image: UIImage(named: "ic_tree_structure")?.withRenderingMode(.alwaysTemplate))
    private var method: AppCaptionIconButton!, multiplicationTable: AppCaptionIconButton!
    private var separate: AppButton!, skip: AppButton!, solve: AppButton!
    private var continueButton: AppButton!, share: AppButton!, back: AppButton!
    private var listHeight: NSLayoutConstraint!, listWidth: NSLayoutConstraint!, keyboardHeight: NSLayoutConstraint!
    private let stepsHeightPreference = StepsPanelHeightPreference(screen: .solution)
    private var stepRows: [SolutionStepRow] = [], keyButtons: [AppButton] = [], temporaryButtons: [AppButton] = []
    private var frozenSchemes: [SolutionSchemeView] = []
    private let finished = UIStackView()
    init(example:MathExample,preview:Bool = false,nested:Bool = false,router:AppRouter,data:AppDataStore) {
        self.example = example; self.preview = preview; isNested = nested
        super.init(title: preview ? CatalogText.ui("rule") : CatalogText.ui("hint"),router:router,data:data)
        catalogCategoryID = TrickCatalog.shared.trick(example.trickID)?.groupID
    }
    required init?(coder:NSCoder) { fatalError("init(coder:) has not been implemented") }
    var game: GameViewController? { navigationController?.viewControllers.compactMap { $0 as? GameViewController }.last }
    override var appearanceSettings: AppSettings {
        TrainingCatalogAppearance.settings(settings, groupID: catalogCategoryID, enabled: game?.usesCategoryColor)
    }
    private var charged: Bool { !preview || isNested && game != nil }
    private var stepsLeft: Int { charged ? game?.solutionStepHintsRemaining ?? 0 : localSteps }
    private var solutionsLeft: Int { charged ? game?.solutionAllHintsRemaining ?? 0 : localSolutions }
    private var fullySolved: Bool { !steps.isEmpty && reached >= steps.count - 1 && steps.last?.isFinal == true }
    override func buildContent() {
        if let game { catalogCategoryID = game.catalogCategoryID }
        view.accessibilityIdentifier = preview ? "screen.solutionPreview" : "screen.solution"
        setHeaderHidden(true)
        column.axis = .vertical; column.spacing = 4; column.translatesAutoresizingMaskIntoConstraints = false
        body.addSubview(column)
        NSLayoutConstraint.activate([column.topAnchor.constraint(equalTo:body.topAnchor),column.bottomAnchor.constraint(equalTo:body.bottomAnchor),column.leadingAnchor.constraint(equalTo:body.leadingAnchor,constant:5),column.trailingAnchor.constraint(equalTo:body.trailingAnchor,constant:-5)])
        method = AppCaptionIconButton(imageName: "ic_fx", iconSize: 24, captionSize: 9, bold: true, padding: 2) { [weak self] in
            guard let self else { return }; AppFeedback.shared.haptic(.step); variant = variant == 0 ? 1 : 0; generate()
        }
        multiplicationTable = AppCaptionIconButton(imageName: "ic_multiplication_table", iconSize: 24, captionSize: 9, bold: true, padding: 2) { [weak self] in
            self?.router?.show(.multiplicationTable)
        }
        multiplicationTable.label.text = CatalogText.ui("solution_multiplication_table")
        let schemeTools = UIStackView(arrangedSubviews: [multiplicationTable, method])
        schemeTools.axis = .vertical; schemeTools.alignment = .center; schemeTools.translatesAutoresizingMaskIntoConstraints = false
        for control in [multiplicationTable!,method!] {
            control.widthAnchor.constraint(equalToConstant:60).isActive = true
            control.label.preferredMaxLayoutWidth = 56
        }
        schemeTools.widthAnchor.constraint(equalToConstant:60).isActive = true
        schemeTools.setContentHuggingPriority(.required,for:.horizontal)
        let crumbScroll = AppScrollView(); crumbScroll.translatesAutoresizingMaskIntoConstraints = false; crumbScroll.tag = 10
        crumbs.axis = .horizontal; crumbs.alignment = .center; crumbs.spacing = 4;
        crumbs.isLayoutMarginsRelativeArrangement = true; crumbs.directionalLayoutMargins = NSDirectionalEdgeInsets(top:0,leading:12,bottom:0,trailing:12); crumbs.translatesAutoresizingMaskIntoConstraints = false; crumbScroll.addSubview(crumbs)
        NSLayoutConstraint.activate([crumbs.topAnchor.constraint(equalTo:crumbScroll.contentLayoutGuide.topAnchor),crumbs.bottomAnchor.constraint(equalTo:crumbScroll.contentLayoutGuide.bottomAnchor),crumbs.leadingAnchor.constraint(equalTo:crumbScroll.contentLayoutGuide.leadingAnchor),crumbs.trailingAnchor.constraint(equalTo:crumbScroll.contentLayoutGuide.trailingAnchor),crumbs.heightAnchor.constraint(equalTo:crumbScroll.frameLayoutGuide.heightAnchor),crumbs.heightAnchor.constraint(greaterThanOrEqualToConstant:38)])
        crumbHeight = crumbScroll.heightAnchor.constraint(equalToConstant:48); crumbHeight?.isActive = true
        crumbSurface.translatesAutoresizingMaskIntoConstraints = false; crumbScroll.insertSubview(crumbSurface,at:0)
        NSLayoutConstraint.activate([crumbSurface.topAnchor.constraint(equalTo:crumbs.topAnchor),crumbSurface.bottomAnchor.constraint(equalTo:crumbs.bottomAnchor),crumbSurface.leadingAnchor.constraint(equalTo:crumbs.leadingAnchor),crumbSurface.trailingAnchor.constraint(equalTo:crumbs.trailingAnchor),crumbs.widthAnchor.constraint(greaterThanOrEqualTo:crumbScroll.frameLayoutGuide.widthAnchor)])

        workspace.axis = .vertical; workspace.spacing = 5
        leftPanel.axis = .vertical; leftPanel.spacing = 4; rightPanel.axis = .vertical; rightPanel.spacing = 4
        rightPanel.setContentHuggingPriority(.defaultHigh,for:.vertical)
        leftPanel.addArrangedSubview(diagramPanel); rightPanel.addArrangedSubview(listPanel)
        workspace.addArrangedSubview(leftPanel); workspace.addArrangedSubview(rightPanel); column.addArrangedSubview(workspace)
        diagramPanel.translatesAutoresizingMaskIntoConstraints = false; listPanel.translatesAutoresizingMaskIntoConstraints = false
        listWidth = rightPanel.widthAnchor.constraint(equalTo:workspace.widthAnchor,multiplier:0.5)
        diagramScroll.contentInsetAdjustmentBehavior = .never
        diagramScroll.translatesAutoresizingMaskIntoConstraints = false; diagrams.translatesAutoresizingMaskIntoConstraints = false; diagrams.axis = .vertical
        diagrams.addArrangedSubview(scheme); diagrams.layer.addSublayer(nestingArrows); diagramScroll.addSubview(diagrams); diagramPanel.addSubview(diagramScroll)
        NSLayoutConstraint.activate([diagramScroll.topAnchor.constraint(equalTo:diagramPanel.topAnchor),diagramScroll.bottomAnchor.constraint(equalTo:diagramPanel.bottomAnchor),diagramScroll.leadingAnchor.constraint(equalTo:diagramPanel.leadingAnchor),diagramScroll.trailingAnchor.constraint(equalTo:diagramPanel.trailingAnchor),
            diagrams.topAnchor.constraint(equalTo:diagramScroll.contentLayoutGuide.topAnchor,constant:AppMetrics.headerHeight),diagrams.bottomAnchor.constraint(equalTo:diagramScroll.contentLayoutGuide.bottomAnchor,constant:-10),diagrams.leadingAnchor.constraint(equalTo:diagramScroll.contentLayoutGuide.leadingAnchor,constant:15),diagrams.trailingAnchor.constraint(equalTo:diagramScroll.contentLayoutGuide.trailingAnchor,constant:-15),diagrams.widthAnchor.constraint(equalTo:diagramScroll.frameLayoutGuide.widthAnchor,constant:-30),diagramPanel.heightAnchor.constraint(greaterThanOrEqualToConstant:AppMetrics.headerHeight)])
        diagramPanel.addSubview(schemeTools)
        NSLayoutConstraint.activate([schemeTools.topAnchor.constraint(equalTo: diagramPanel.topAnchor, constant: 5),
            schemeTools.trailingAnchor.constraint(equalTo: diagramPanel.trailingAnchor, constant: -10)])
        let zoomButtons = UIStackView(); zoomButtons.axis = .vertical; zoomButtons.spacing = 4; zoomButtons.translatesAutoresizingMaskIntoConstraints = false
        for (direction,icon) in [(1,AppIcon.zoomIn),(-1,AppIcon.zoomOut)] {
            let control = button("",icon:icon,kind:.icon) { [weak self] in self?.changeZoom(direction) }
            control.setContentInsets(UIEdgeInsets(top:6,left:6,bottom:6,right:6),minimumHeight:36)
            control.accessibilityLabel = direction > 0 ? "Zoom In" : "Zoom Out"
            NSLayoutConstraint.activate([control.widthAnchor.constraint(equalToConstant:36),control.heightAnchor.constraint(equalToConstant:36)])
            zoomButtons.addArrangedSubview(control)
        }

        back = button(CatalogText.ui("back"), icon: .back, kind: .icon) { [weak self] in AppFeedback.shared.haptic(.step); self?.router?.goBack() }
        back.setContentInsets(UIEdgeInsets(top:8,left:8,bottom:8,right:8),minimumHeight:AppMetrics.headerHeight)
        back.accessibilityIdentifier = "solution.back"
        body.addSubview(back)
        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo:body.topAnchor),back.leadingAnchor.constraint(equalTo:body.leadingAnchor),
            back.widthAnchor.constraint(equalToConstant:AppMetrics.headerBackWidth),
            back.heightAnchor.constraint(equalToConstant:AppMetrics.headerHeight)
        ])
        diagramPanel.addSubview(zoomButtons); diagramPanel.addSubview(crumbScroll)
        crumbScroll.layer.cornerRadius = 12; crumbScroll.clipsToBounds = true
        NSLayoutConstraint.activate([zoomButtons.topAnchor.constraint(equalTo:crumbScroll.bottomAnchor,constant:4),zoomButtons.centerXAnchor.constraint(equalTo:back.centerXAnchor),crumbScroll.topAnchor.constraint(equalTo:diagramPanel.topAnchor,constant:5),crumbScroll.leadingAnchor.constraint(equalTo:back.trailingAnchor,constant:8),crumbScroll.trailingAnchor.constraint(equalTo:schemeTools.leadingAnchor,constant:-8)])
        separate = button("",kind:.compact) { [weak self] in self?.openNested() }; separate.label.role = .detail
        separate.setContentInsets(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), minimumHeight: 44)
        separateContainer.axis = .vertical; separateContainer.alignment = .center; separateContainer.spacing = 2
        separateContainer.translatesAutoresizingMaskIntoConstraints = false
        separateIcon.contentMode = .scaleAspectFit; separateIcon.isAccessibilityElement = false
        separateContainer.addArrangedSubview(separateIcon); separateContainer.addArrangedSubview(separate)
        diagramPanel.addSubview(separateContainer)
        NSLayoutConstraint.activate([separateIcon.widthAnchor.constraint(equalToConstant:24),separateIcon.heightAnchor.constraint(equalToConstant:24),
            separateContainer.trailingAnchor.constraint(equalTo:diagramPanel.trailingAnchor,constant:-8),separateContainer.bottomAnchor.constraint(equalTo:diagramPanel.bottomAnchor,constant:-8),separateContainer.widthAnchor.constraint(lessThanOrEqualToConstant:164),
            separateContainer.leadingAnchor.constraint(greaterThanOrEqualTo:diagramPanel.leadingAnchor,constant:8),
            separate.widthAnchor.constraint(lessThanOrEqualTo:separateContainer.widthAnchor)])
        stepsScroll.translatesAutoresizingMaskIntoConstraints = false; rows.translatesAutoresizingMaskIntoConstraints = false; rows.axis = .vertical
        stepsScroll.addSubview(rows); listPanel.addSubview(stepsScroll)
        listHeight = listPanel.heightAnchor.constraint(equalToConstant:stepsHeightPreference.savedHeight ?? 180); listHeight.priority = .init(999)
        NSLayoutConstraint.activate([stepsScroll.topAnchor.constraint(equalTo:listPanel.topAnchor),stepsScroll.bottomAnchor.constraint(equalTo:listPanel.bottomAnchor),stepsScroll.leadingAnchor.constraint(equalTo:listPanel.leadingAnchor),stepsScroll.trailingAnchor.constraint(equalTo:listPanel.trailingAnchor),rows.topAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.topAnchor),rows.bottomAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.bottomAnchor),rows.leadingAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.leadingAnchor),rows.trailingAnchor.constraint(equalTo:stepsScroll.contentLayoutGuide.trailingAnchor),rows.widthAnchor.constraint(equalTo:stepsScroll.frameLayoutGuide.widthAnchor),listHeight])
        heightControls.axis = .vertical; heightControls.spacing = 2; heightControls.translatesAutoresizingMaskIntoConstraints = false
        for (delta,title) in [(StepsPanelHeightPreference.increment,"steps_height_increase"),(-StepsPanelHeightPreference.increment,"steps_height_decrease")] {
            let control = UIButton(type:.system); control.setTitle(delta > 0 ? "+" : "−",for:.normal); control.titleLabel?.font = .systemFont(ofSize:20)
            control.accessibilityLabel = CatalogText.ui(title); control.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([control.widthAnchor.constraint(equalToConstant:32),control.heightAnchor.constraint(equalToConstant:28)])
            control.addAction(UIAction { [weak self] _ in self?.resizeSteps(delta) },for:.touchUpInside); heightControls.addArrangedSubview(control)
        }
        listPanel.addSubview(heightControls)
        NSLayoutConstraint.activate([heightControls.trailingAnchor.constraint(equalTo:listPanel.trailingAnchor),heightControls.bottomAnchor.constraint(equalTo:listPanel.bottomAnchor,constant:-2)])
        continueButton = button("",kind:.compact) { [weak self] in self?.finishSolution() }
        share = button(CatalogText.ui("share_solution"),icon:.resultShare,kind:.compact) { [weak self] in self?.shareScheme() }
        finished.axis = .horizontal; finished.distribution = .fillEqually; finished.addArrangedSubview(continueButton); finished.addArrangedSubview(share); rightPanel.insertArrangedSubview(finished,at:0)
        for control in [continueButton!,share!] { control.label.role = .detail; control.setContentInsets(UIEdgeInsets(top:8,left:12,bottom:8,right:12),minimumHeight:48) }
        skip = button("",icon:.solveStep,kind:.compact) { [weak self] in self?.solveStep() }
        solve = button("",icon:.solveAll,kind:.compact) { [weak self] in self?.solveAll() }
        for control in [skip!,solve!] {
            control.label.role = .detail
            control.setContentInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12), minimumHeight: 48)
            control.setContentSpacing(12)
        }
        let actions = UIStackView(arrangedSubviews:[skip,solve]); actions.distribution = .fillEqually; actions.spacing = 8; actions.tag = 11
        rightPanel.addArrangedSubview(actions)
        keyboard.axis = .vertical; keyboard.distribution = .fillEqually; rightPanel.addArrangedSubview(keyboard)
        keyboardHeight = keyboard.heightAnchor.constraint(equalToConstant:smallKeyboard ? 72 : 192); keyboardHeight.priority = .defaultHigh; keyboardHeight.isActive = true
        rebuildKeyboard(); generate()
    }
    private func generate() {
        do { steps = try SolutionStep.generate(example,variant:variant); index = 0; reached = 0; input = ""; prepareStep() }
        catch { steps = []; showError(error,reading:true) }
        render()
    }
    private func prepareStep() {
        input = ""
        if steps.indices.contains(index), steps[index].isIntro { reached = min(steps.count - 1,max(reached,index + 1)) }
    }
    override func update(_ progress:ProgressState?) { if skip != nil { render() } }
    private func clear(_ stack:UIStackView) { for child in stack.arrangedSubviews { stack.removeArrangedSubview(child); child.removeFromSuperview() } }
    private func format(_ key:String,_ value:String) -> String { CatalogText.ui(key).replacingOccurrences(of:"%1$s",with:value).replacingOccurrences(of:"%s",with:value).replacingOccurrences(of:"%d",with:value) }
    private func normalized(_ value:String) -> String { value.replacingOccurrences(of:",",with:".").replacingOccurrences(of:"−",with:"-") }
    private func wrongInput() {
        if settings.signalWrongAnswer { AppFeedback.shared.play(.error); AppFeedback.shared.haptic(.inputError) }
    }
    private func enter(_ value:String) {
        guard steps.indices.contains(index), !steps[index].isIntro, !steps[index].isFinal else { return }
        if value == "⌫" { if !input.isEmpty { input.removeLast() }; AppFeedback.shared.play(.keypress); updateScheme(); return }
        let expected = normalized(steps[index].expectedAnswer)
        if value == "." {
            guard !input.isEmpty, !input.contains("."), !input.contains(",") else { wrongInput(); return }
        } else {
            let digitCount = input.filter { $0.isNumber }.count
            guard digitCount < expected.filter({ $0.isNumber }).count else { wrongInput(); return }
            if input == "0", !(value == "0" && expected.hasPrefix("00")) { wrongInput(); return }
        }
        input += value
        if !expected.hasPrefix(normalized(input)) { wrongInput() } else { AppFeedback.shared.play(.keypress) }
        if normalized(input) == expected {
            AppFeedback.shared.play(.solution); index = min(steps.count - 1,index + 1); reached = max(reached,index); prepareStep(); render(); scrollToStep()
        } else { updateScheme() }
    }
    @objc private func clearInput(_ gesture:UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }; input = ""; updateScheme()
    }
    private func rebuildKeyboard() {
        themedButtons.removeAll { button in keyButtons.contains(where:{ $0 === button }) }; keyButtons.removeAll(); clear(keyboard)
        func key(_ value:String,icon:AppIcon? = nil) -> AppButton {
            let control = button(icon == .backspace ? "" : value,icon:icon,kind:icon == nil ? .playerKey : .keypadIcon) { [weak self] in self?.enter(value) }
            control.setContentInsets(UIEdgeInsets(top:0,left:2,bottom:0,right:2),minimumHeight:20)
            if smallKeyboard { control.label.role = .caption }
            control.accessibilityLabel = icon == .backspace ? MainText.text("backspace") : value
            if icon == .backspace { let hold = UILongPressGestureRecognizer(target:self,action:#selector(clearInput(_:))); control.addGestureRecognizer(hold) }
            keyButtons.append(control); return control
        }
        func toggleAndDot() -> UIStackView {
            let toggle = button("",icon:smallKeyboard ? .keyboardExpand : .keyboardCollapse,kind:.icon) { [weak self] in
                guard let self else { return }; AppFeedback.shared.haptic(.step); smallKeyboard.toggle(); UserDefaults.standard.set(smallKeyboard,forKey:"solution.numpadSmall"); rebuildKeyboard(); render()
            }
            toggle.setContentInsets(UIEdgeInsets(top:0,left:2,bottom:0,right:2),minimumHeight:20); keyButtons.append(toggle)
            toggle.accessibilityLabel = "Toggle Keyboard"
            let row = UIStackView(arrangedSubviews:[toggle,key(".")]); row.distribution = .fillEqually; return row
        }
        let values = smallKeyboard ? [["1","2","3","4","5","6"],["toggle","7","8","9","0","⌫"]] : [["1","2","3"],["4","5","6"],["7","8","9"],["toggle","0","⌫"]]
        for values in values {
            let row = UIStackView(); row.distribution = .fillEqually
            for value in values { row.addArrangedSubview(value == "toggle" ? toggleAndDot() : key(value,icon:value == "⌫" ? .backspace : nil)) }
            keyboard.addArrangedSubview(row)
        }
        keyboardHeight.constant = smallKeyboard ? 72 : 192
    }
    private func solveStep() {
        guard steps.indices.contains(index), !steps[index].isIntro, !steps[index].isFinal, index == reached, stepsLeft > 0 else { return }
        if charged { guard game?.consumeSolutionStepHint() == true else { return } } else { localSteps -= 1 }
        AppFeedback.shared.haptic(.step)
        input = steps[index].expectedAnswer; index = min(steps.count - 1,index + 1); reached = max(reached,index); prepareStep(); render(); scrollToStep()
    }
    private func solveAll() {
        guard !steps.isEmpty, index < steps.count - 1, solutionsLeft > 0 else { return }
        if charged { guard game?.consumeSolutionAllHint() == true else { return } } else { localSolutions -= 1 }
        AppFeedback.shared.haptic(.step)
        index = steps.count - 1; reached = index; prepareStep(); render(); scrollToStep()
    }
    private func openNested() {
        guard steps.indices.contains(index) else { return }
        let candidates = SolutionSubexpression.examples(from:steps[index].hintExpr).filter { $0.signature != example.signature }
        guard let target = candidates.first, let generated = try? SolutionStep.generate(target) else { return }
        AppFeedback.shared.haptic(.step)
        parents.append(Parent(example:example,steps:steps,index:index,reached:reached,variant:variant,input:"",methods:methods,methodIndex:methodIndex))
        methods = candidates; methodIndex = 0; example = target; steps = generated; index = 0; reached = 0; variant = 0; prepareStep(); render()
    }
    private func switchMethod(_ direction:Int) {
        guard methods.count > 1 else { return }; AppFeedback.shared.haptic(.step); methodIndex = (methodIndex + direction + methods.count) % methods.count
        example = methods[methodIndex]; variant = 0; generate()
    }
    private func restoreParent(_ parent:Parent) {
        example = parent.example; steps = parent.steps; index = parent.index; reached = parent.reached; variant = parent.variant; input = parent.input; methods = parent.methods; methodIndex = parent.methodIndex
    }
    private func finishSolution() {
        guard fullySolved else { return }
        AppFeedback.shared.play(.solution); AppFeedback.shared.haptic(.step)
        if let parent = parents.popLast() {
            restoreParent(parent); index = min(steps.count - 1,index + 1); reached = max(reached,index); prepareStep(); render(); scrollToStep(); return
        }
        if isNested, let stack = navigationController?.viewControllers, let position = stack.firstIndex(where:{$0 === self}), position > 0, let parent = stack[position - 1] as? SolutionViewController {
            parent.acceptNestedAnswer(example.answer); router?.goBack(); return
        }
        if !preview, let game { game.continueFromSolution(example); return }
        router?.goBack()
    }
    private func acceptNestedAnswer(_ value:Int64) {
        guard steps.indices.contains(index) else { return }
        index = min(steps.count - 1,index + 1); reached = max(reached,index); prepareStep(); render()
    }
    private func shareScheme() {
        guard presentedViewController == nil, !steps.isEmpty, fullySolved || preview else { return }
        guard let image = SolutionSchemeShare.make(step:steps[index],input:input,example:example,steps:steps,settings:appearanceSettings,traits:traitCollection) else {
            present(AppDialogViewController(title: CatalogText.ui("share_solution"), message: ResultText.text("results_share_error"), actions: [.init(title: MainText.text("ok"), handler: {})], data: data), animated: false)
            return
        }
        let sheet = UIActivityViewController(activityItems:[image,ResultShareCard.links],applicationActivities:nil)
        sheet.popoverPresentationController?.sourceView = share; sheet.popoverPresentationController?.sourceRect = share.bounds
        present(sheet,animated:false)
    }

    private func heightLimits() -> ClosedRange<CGFloat> {
        let minimum = max(48,heightControls.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 4)
        let rightControls = rightPanel.arrangedSubviews.filter { $0 !== listPanel && $0 !== keyboard && !$0.isHidden }
        let controlsHeight = rightControls.reduce(CGFloat.zero) { height, control in
            height + control.systemLayoutSizeFitting(CGSize(width: max(1, rightPanel.bounds.width), height: 0),
                withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        }
        let rightSpacing = CGFloat(max(0, rightPanel.arrangedSubviews.filter { !$0.isHidden }.count - 1)) * rightPanel.spacing
        let available = workspace.bounds.height - workspace.spacing - 48 - controlsHeight
            - (keyboard.isHidden ? 0 : keyboardHeight.constant) - rightSpacing
        return minimum...max(minimum, min(view.bounds.height * 0.455, available))
    }
    private func resizeSteps(_ delta:Int) {
        guard landscape != true else { return }; view.layoutIfNeeded(); let limits = heightLimits()
        listHeight.constant = stepsHeightPreference.resize(by: delta, currentHeight: listPanel.bounds.height, limits: limits)
        view.setNeedsLayout(); view.layoutIfNeeded()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let wide = view.bounds.width > view.bounds.height
        if landscape != wide { landscape = wide; workspace.axis = wide ? .horizontal : .vertical; listWidth.isActive = wide; listHeight.isActive = !wide; heightControls.isHidden = wide }
        keyboardHeight.constant = smallKeyboard ? 72 : wide ? 136 : 192
        if !wide, workspace.bounds.height > 0 {
            let height = stepsHeightPreference.height(in: heightLimits())
            if abs(listHeight.constant - height) > 0.5 { listHeight.constant = height; view.setNeedsLayout() }
        }
        for control in keyButtons where control.label.text?.allSatisfy({ $0.isNumber || $0 == "." }) == true {
            control.label.role = smallKeyboard || wide ? .caption : .playerNumber
        }
        diagramScroll.layoutIfNeeded()
        if dirtyScheme || abs(lastWidth - diagramScroll.bounds.width) > 0.5 { lastWidth = diagramScroll.bounds.width; updateScheme() }
        diagramScroll.layoutIfNeeded(); diagrams.layoutIfNeeded(); updateNestingArrows(); schemeScrollPosition.finish(diagramScroll)
        if breadcrumbDepth != parents.count, let scroll = diagramPanel.viewWithTag(10) as? UIScrollView {
            breadcrumbDepth = parents.count
            scroll.layoutIfNeeded(); scroll.setContentOffset(CGPoint(x:max(0,scroll.contentSize.width-scroll.bounds.width),y:0),animated:false)
        }
        listPanel.bringSubviewToFront(heightControls)
    }
    private func updateNestingArrows() {
        let ids = parents.indices.map { depth in "\(parents[depth].example.signature):\(depth + 1 < parents.count ? parents[depth + 1].example.signature : example.signature)" }
        nestingArrows.update(parents:frozenSchemes,active:scheme,ids:ids,container:diagrams,palette:palette,scale:schemeStyle().fontSize / schemeStyle().originalSize)
    }
    private func schemeStyle() -> SolutionSchemeView.RuleStyle {
        let texts = parents.map { $0.steps[$0.index].processedEquation(input:$0.input,trickID:$0.example.trickID).text } + (steps.indices.contains(index) ? [steps[index].processedEquation(input:input,trickID:example.trickID).text] : [])
        return SolutionSchemeView.RuleStyle(width:max(1,diagramScroll.bounds.width - 30),texts:texts,settings:appearanceSettings,traits:traitCollection,zoom:zoom,isSolution:true)
    }
    private func changeZoom(_ direction:Int) {
        let style = schemeStyle(), candidate = direction > 0 ? min(3.5,min(zoom + 0.15,style.maximumZoom)) : max(0.5,zoom - 0.15)
        guard direction > 0 ? candidate > zoom + 0.005 : candidate < zoom - 0.005 else { return }; schemeScrollPosition.begin(diagramScroll,depth:parents.count); zoom = candidate; updateScheme(); view.setNeedsLayout()
    }
    private func updateScheme() {
        guard diagramScroll.bounds.width > 30, steps.indices.contains(index) else { return }
        let style = schemeStyle()
        for (depth,parent) in parents.enumerated() where frozenSchemes.indices.contains(depth) { frozenSchemes[depth].apply(step:parent.steps[parent.index],input:parent.input,example:parent.example,settings:appearanceSettings,frozen:true,ruleStyle:style) }
        scheme.apply(step:steps[index],input:input,example:example,settings:appearanceSettings,ruleStyle:style); dirtyScheme = false
    }
    private func scrollToStep() { rows.layoutIfNeeded(); if stepRows.indices.contains(index) { stepsScroll.scrollRectToVisible(stepRows[index].frame,animated:true) } }
    private func render() {
        guard skip != nil else { return }
        schemeScrollPosition.begin(diagramScroll,depth:parents.count)
        let valid = steps.indices.contains(index)
        if valid, steps[index].isIntro { reached = min(steps.count - 1,max(reached,index + 1)) }
        method.isEnabled = [62,66].contains(example.trickID) || example.trickID == 5 && example.operand1 < 100
        method.isHidden = !method.isEnabled
        method.label.text = CatalogText.ui(variant == 0 ? "rule_method_1" : "rule_method_2")
        let toolColor = palette.theme.isAnimated ? UIColor.white : palette.theme.isDark ? ThemeColor.rgb(0xB0B0B0) : ThemeColor.rgb(0x333333)
        back.apply(settings: appearanceSettings, tint: toolColor)
        multiplicationTable.apply(color: toolColor, iconColor: palette.theme.isDark ? .white : toolColor)
        method.apply(color:toolColor)
        workspace.isHidden = !valid; keyboard.isHidden = !valid
        column.viewWithTag(11)?.isHidden = !valid
        separateIcon.tintColor = palette.accent
        heightControls.backgroundColor = palette.dialogBackground; heightControls.layer.cornerRadius = 5
        heightControls.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { $0.tintColor = palette.text }
        listPanel.backgroundColor = ThemeColor.rgb(0x808080,alpha:21 / 255)
        listPanel.layer.borderColor = ThemeColor.rgb(0x808080,alpha:160 / 255).cgColor
        listPanel.layer.borderWidth = 2
        listPanel.layer.cornerRadius = 8
        listPanel.clipsToBounds = true
        themedButtons.removeAll { button in temporaryButtons.contains(where:{$0 === button}) }; temporaryButtons.removeAll()
        crumbSurface.apply(settings:appearanceSettings)
        let barFont = AppTypography.font(.scheme,settings:appearanceSettings,traits:traitCollection)
        crumbHeight?.constant = max(48,ceil(barFont.lineHeight * 18 / 20) + 8)
        clear(rows); clear(diagrams); clear(crumbs); stepRows.removeAll(); frozenSchemes.removeAll()
        for (depth,parent) in parents.enumerated() {
            let crumb = button(MathExpressionFormatter.text(parent.example) + " (" + format("rule_step_title",String(parent.index + (parent.steps.first?.isIntro == true ? 0 : 1))) + ")",kind:.plain) { [weak self] in
                guard let self else { return }; AppFeedback.shared.haptic(.step); while parents.count > depth { if let parent = parents.popLast() { restoreParent(parent) } }; render()
            }
            crumb.label.role = .dailyCaption; crumb.label.font = AppTypography.font(.dailyCaption,settings:appearanceSettings,traits:traitCollection,weight:700)
            crumb.label.textColor = ThemeColor.rgb(palette.theme.isDark ? 0xCCCCCC : 0x444444)
            crumb.setContentInsets(UIEdgeInsets(top:6,left:6,bottom:6,right:6),minimumHeight:38)
            temporaryButtons.append(crumb); crumbs.addArrangedSubview(crumb)
            let arrow = UIImageView(image:UIImage(named:"ic_breadcrumb_arrow_separator")?.withRenderingMode(.alwaysTemplate)); arrow.contentMode = .scaleToFill; arrow.tintColor = ThemeColor.rgb(palette.theme.isDark ? 0x999999 : 0x777777)
            arrow.translatesAutoresizingMaskIntoConstraints = false
            crumbs.addArrangedSubview(arrow)
            NSLayoutConstraint.activate([arrow.widthAnchor.constraint(equalToConstant:12),arrow.heightAnchor.constraint(equalTo:crumbs.heightAnchor)])
            let frozen = SolutionSchemeView(); frozen.alpha = 0.55; diagrams.addArrangedSubview(frozen); frozenSchemes.append(frozen)
            let target = depth + 1 < parents.count ? parents[depth + 1].example : example
            let childMethods = depth + 1 < parents.count ? parents[depth + 1].methods : methods
            let childMethodIndex = depth + 1 < parents.count ? parents[depth + 1].methodIndex : methodIndex
            let title = TrickCatalog.shared.trick(target.trickID).map { AndroidRichText.plain(CatalogText.text($0.nameKey)) } ?? ""
            let divider = UIStackView(); divider.alignment = .center
            divider.isLayoutMarginsRelativeArrangement = true; divider.directionalLayoutMargins = NSDirectionalEdgeInsets(top:20,leading:0,bottom:20,trailing:0)
            for direction in [-1,1] {
                let control = button(direction < 0 ? "◀" : "▶",kind:.plain) { [weak self] in self?.switchMethod(direction) }
                control.isHidden = childMethods.count <= 1; control.isEnabled = depth == parents.count - 1 && childMethods.count > 1; temporaryButtons.append(control)
                if direction > 0 { let label = AppLabel(.detail); label.text = title + (childMethods.count > 1 ? " (\(childMethodIndex + 1)/\(childMethods.count))" : ""); label.apply(settings:appearanceSettings); label.textColor = palette.text; label.textAlignment = .center; divider.addArrangedSubview(label) }
                divider.addArrangedSubview(control)
            }
            diagrams.addArrangedSubview(divider)
        }
        if !parents.isEmpty {
            let current = AppLabel(.detail,weight:700); current.text = MathExpressionFormatter.text(example); current.apply(settings:appearanceSettings); current.textColor = palette.text
            crumbs.addArrangedSubview(current)
        }
        diagramPanel.viewWithTag(10)?.isHidden = parents.isEmpty
        diagrams.addArrangedSubview(scheme)
        if valid {
            for position in 0...min(reached,steps.count - 1) {
                let row = SolutionStepRow(title:format("rule_step_title",String(position + (steps.first?.isIntro == true ? 0 : 1))),step:steps[position],settings:appearanceSettings,selected:position == index && reached > 0) { [weak self] in
                    guard let self else { return }; AppFeedback.shared.haptic(.step); index = position; prepareStep(); render(); scrollToStep()
                }
                row.isEnabled = reached > 0; stepRows.append(row); rows.addArrangedSubview(row)
            }
        }
        let stepFinal = valid && steps[index].isFinal, intro = valid && steps[index].isIntro
        separateContainer.isHidden = !valid || intro || stepFinal || [1,2,3,4].contains(example.trickID) || (valid && SolutionSubexpression.examples(from:steps[index].hintExpr).filter { $0.signature != example.signature }.isEmpty)
        separate.label.text = valid ? format("solve_step_separately_fmt",steps[index].hintExpr) : ""
        skip.label.text = format("solution_next_step_btn",String(stepsLeft)); skip.isEnabled = valid && !intro && !stepFinal && index == reached && stepsLeft > 0
        solve.label.text = format("solution_solve_all_btn",String(solutionsLeft)); solve.isEnabled = valid && !fullySolved && solutionsLeft > 0
        continueButton.isHidden = !fullySolved || (!parents.isEmpty && !stepFinal) || (preview && !isNested && parents.isEmpty)
        continueButton.label.text = format(parents.isEmpty && !preview ? "solution_continue_game" : "solution_insert_answer",String(example.answer))
        share.isHidden = !fullySolved && !preview; finished.isHidden = continueButton.isHidden && share.isHidden
        finished.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
        for control in keyButtons { control.isEnabled = valid && !intro && !stepFinal || control.accessibilityLabel == "Toggle Keyboard" }
        dirtyScheme = true; view.setNeedsLayout()
    }
}
