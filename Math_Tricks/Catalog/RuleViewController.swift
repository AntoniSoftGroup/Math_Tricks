import UIKit

final class RuleViewController: ThemedViewController, UIScrollViewDelegate, UITextFieldDelegate {
    let trick: CatalogTrick
    private var operandState: RuleExampleGenerator?
    private var needsOperandLayout = true
    private var example: MathExample?
    private var steps: [SolutionStep] = []
    private var index = 0
    private var variant = 0
    private var first: Int64 = 35
    private var second: Int64 = 31
    private var parents: [(MathExample, [SolutionStep], Int, Int)] = []
    private var methods: [MathExample] = []
    private var methodIndex = 0
    private var nestedMethods: [([MathExample], Int)] = []
    private let workspace = UIStackView()
    private let listPanel = UIStackView()
    private let schemePanel = UIView()
    private let schemeColumn = UIStackView()
    private let listOverlay = UIView()
    private let stepTitle = AppLabel(.trickName, weight: 700)
    private let listControls = UIStackView()
    private let operandBar = UIView()
    private let operandScroll = AppScrollView()
    private var lastOperandContentWidth: CGFloat = -1
    private var lastOperandViewportWidth: CGFloat = -1
    private var firstFieldWidth: NSLayoutConstraint!
    private var secondFieldWidth: NSLayoutConstraint!
    private var lastSchemeWidth: CGFloat = 0
    private var needsSchemeLayout = true
    private var zoomMultiplier: CGFloat {
        get { let value = UserDefaults.standard.double(forKey: "rule_scheme_zoom"); return value > 0 ? CGFloat(value) : 1 }
        set { UserDefaults.standard.set(Double(newValue), forKey: "rule_scheme_zoom") }
    }
    private var listWidth: NSLayoutConstraint!
    private var secondArrows: [AppButton] = []
    private let column = UIStackView()
    private let operands = UIStackView()
    private let operandContent = UIStackView()
    private let operandExpression = UIStackView()
    private let firstField = UITextField()
    private let secondField = UITextField()
    private let range = AppLabel(.menuCaption)
    private let sign = AppLabel(.body)
    private let signBalance = UIView()
    private var signBalanceWidth: NSLayoutConstraint!
    private var operandRowHeights: [NSLayoutConstraint] = []
    private var stackedOperandHeight: NSLayoutConstraint!
    private let prefix = AppLabel(.body)
    private var firstArrows: [AppButton] = []
    private let suffix = AppLabel(.body)
    private let secondSlot = UIStackView()
    private let stepsScroll = AppScrollView()
    private let stepRows = UIStackView()
    private let diagramScroll = AppScrollView()
    private let diagramColumn = UIStackView()
    private let scheme = SolutionSchemeView()
    private let nestingArrows = SchemeNestingArrows()
    private let schemeScrollPosition = SchemeScrollPosition()
    private let crumbSurface = ThemeSurfaceView(.button)
    private let crumbScroll = AppScrollView()
    private var barHeight: NSLayoutConstraint?
    private let breadcrumbs = UIStackView()
    private let textView = AppTextView()
    private var notice: AppButton!
    private var method: AppCaptionIconButton!
    private let separateContainer = UIStackView()
    private let separateIcon = UIImageView(image: UIImage(named: "ic_tree_structure")?.withRenderingMode(.alwaysTemplate))
    private var separate: AppButton!
    private var share: AppButton!
    private var insert: AppButton!
    private var previous: AppButton!
    private var nextStep: AppButton!
    private var levels: AppButton!
    private var listHeight: NSLayoutConstraint!
    private let stepsHeightPreference = StepsPanelHeightPreference(screen: .rule)
    private var stepButtons: [SolutionStepRow] = []
    private var frozenSchemes: [SolutionSchemeView] = []
    private var dividerButtons: [AppButton] = []
    private var repeatTimer: Timer?
    private var repeatCount = 0
    private var landscape: Bool?
    private var supported = true
    init(trick: CatalogTrick, router: AppRouter, data: AppDataStore) {
        self.trick = trick
        let defaults = RuleOperandDefaults.values[trick.id] ?? [35,31,1,999]
        first = defaults[0]; second = defaults[1]
        super.init(title: AndroidRichText.plain(CatalogText.text(trick.nameKey)), router: router, data: data)
        catalogCategoryID = trick.groupID
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func buildContent() {
        view.accessibilityIdentifier = "screen.rule.\(trick.id)"
        column.axis = .vertical; column.spacing = 4; column.translatesAutoresizingMaskIntoConstraints = false
        body.addSubview(column)
        NSLayoutConstraint.activate([column.topAnchor.constraint(equalTo: body.topAnchor), column.bottomAnchor.constraint(equalTo: body.bottomAnchor), column.leadingAnchor.constraint(equalTo: body.leadingAnchor, constant: 5), column.trailingAnchor.constraint(equalTo: body.trailingAnchor, constant: -5)])
        operandBar.translatesAutoresizingMaskIntoConstraints = false
        barHeight = operandBar.heightAnchor.constraint(equalToConstant:48); barHeight?.isActive = true
        operandBar.layer.cornerRadius = 12; operandBar.layer.borderWidth = 1.5
        operandBar.clipsToBounds = true
        operands.axis = .horizontal; operands.alignment = .center; operands.spacing = 4
        operands.translatesAutoresizingMaskIntoConstraints = false
        operandScroll.translatesAutoresizingMaskIntoConstraints = false
        operandScroll.showsHorizontalScrollIndicator = false; operandScroll.showsVerticalScrollIndicator = false
        operandScroll.isDirectionalLockEnabled = true
        operandBar.addSubview(operandScroll)
        let operandHost = UIView(); operandHost.translatesAutoresizingMaskIntoConstraints = false
        operandScroll.addSubview(operandHost); operandHost.addSubview(operands)
        let fittingWidth = operandHost.widthAnchor.constraint(equalTo: operandScroll.frameLayoutGuide.widthAnchor)
        fittingWidth.priority = .init(249)
        NSLayoutConstraint.activate([
            operandScroll.topAnchor.constraint(equalTo: operandBar.topAnchor), operandScroll.bottomAnchor.constraint(equalTo: operandBar.bottomAnchor),
            operandScroll.leadingAnchor.constraint(equalTo: operandBar.leadingAnchor), operandScroll.trailingAnchor.constraint(equalTo: operandBar.trailingAnchor),
            operandHost.topAnchor.constraint(equalTo: operandScroll.contentLayoutGuide.topAnchor), operandHost.bottomAnchor.constraint(equalTo: operandScroll.contentLayoutGuide.bottomAnchor),
            operandHost.leadingAnchor.constraint(equalTo: operandScroll.contentLayoutGuide.leadingAnchor), operandHost.trailingAnchor.constraint(equalTo: operandScroll.contentLayoutGuide.trailingAnchor),
            operandHost.heightAnchor.constraint(equalTo: operandScroll.frameLayoutGuide.heightAnchor),
            operandHost.widthAnchor.constraint(greaterThanOrEqualTo: operandScroll.frameLayoutGuide.widthAnchor), fittingWidth,
            operands.topAnchor.constraint(greaterThanOrEqualTo: operandHost.topAnchor, constant: 2), operands.bottomAnchor.constraint(lessThanOrEqualTo: operandHost.bottomAnchor, constant: -2),
            operands.centerYAnchor.constraint(equalTo:operandHost.centerYAnchor),
            operands.centerXAnchor.constraint(equalTo: operandHost.centerXAnchor),
            operands.leadingAnchor.constraint(greaterThanOrEqualTo: operandHost.leadingAnchor, constant: 6),
            operands.trailingAnchor.constraint(lessThanOrEqualTo: operandHost.trailingAnchor, constant: -6)
        ])
        operands.setContentCompressionResistancePriority(.required, for: .horizontal)
        operandBar.setContentHuggingPriority(.required, for: .vertical)
        range.numberOfLines = 2; range.adjustsFontSizeToFitWidth = false
        operands.addArrangedSubview(range)
        range.widthAnchor.constraint(lessThanOrEqualTo:operandScroll.frameLayoutGuide.widthAnchor,multiplier:0.18).isActive = true
        prefix.numberOfLines = 1; sign.numberOfLines = 1; suffix.numberOfLines = 1
        operandContent.axis = .horizontal; operandContent.alignment = .center; operandContent.spacing = 0
        stackedOperandHeight = operandContent.heightAnchor.constraint(equalToConstant:64)
        operandContent.addArrangedSubview(prefix)
        signBalance.translatesAutoresizingMaskIntoConstraints = false; signBalance.isHidden = true
        let firstSlot = UIStackView(arrangedSubviews:[signBalance,operandSlot(firstField,second:false)])
        firstSlot.axis = .horizontal; firstSlot.alignment = .center
        operandContent.addArrangedSubview(firstSlot)
        secondSlot.axis = .horizontal; secondSlot.alignment = .center
        secondSlot.addArrangedSubview(sign); secondSlot.addArrangedSubview(operandSlot(secondField, second: true))
        operandContent.addArrangedSubview(secondSlot); operandContent.addArrangedSubview(suffix)
        signBalanceWidth = signBalance.widthAnchor.constraint(equalTo:sign.widthAnchor)
        operandExpression.axis = .horizontal; operandExpression.alignment = .center
        operandExpression.addArrangedSubview(operandContent); operands.addArrangedSubview(operandExpression)
        let rangeBalance = UIView(); rangeBalance.translatesAutoresizingMaskIntoConstraints = false
        operands.addArrangedSubview(rangeBalance)
        rangeBalance.widthAnchor.constraint(equalTo:range.widthAnchor).isActive = true
        method = AppCaptionIconButton(imageName: "ic_fx", iconSize: 32, captionSize: 9, padding: 5) { [weak self] in
            guard let self else { return }; variant = variant == 0 ? 1 : 0; regenerate(reset: false)
        }
        method.label.numberOfLines = 1
        let methodWidth = method.widthAnchor.constraint(equalToConstant:64)
        let methodHeight = method.heightAnchor.constraint(equalToConstant:54)
        methodWidth.priority = .init(999); methodHeight.priority = .init(999)
        NSLayoutConstraint.activate([methodWidth,methodHeight])
        header.setAccessoryView(method)
        let titleScroll = AppScrollView(); titleScroll.translatesAutoresizingMaskIntoConstraints = false
        titleScroll.showsHorizontalScrollIndicator = false; titleScroll.showsVerticalScrollIndicator = false
        titleScroll.isDirectionalLockEnabled = true
        let titleLabel = label(title ?? "",role:.settingsTitle); titleLabel.numberOfLines = 0
        titleLabel.accessibilityTraits = .header; titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleScroll.addSubview(titleLabel); header.replaceTitle(with:titleScroll)
        NSLayoutConstraint.activate([titleScroll.heightAnchor.constraint(equalTo:header.heightAnchor),titleLabel.topAnchor.constraint(equalTo:titleScroll.contentLayoutGuide.topAnchor),titleLabel.bottomAnchor.constraint(equalTo:titleScroll.contentLayoutGuide.bottomAnchor),titleLabel.leadingAnchor.constraint(equalTo:titleScroll.contentLayoutGuide.leadingAnchor),titleLabel.trailingAnchor.constraint(equalTo:titleScroll.contentLayoutGuide.trailingAnchor,constant:-8),titleLabel.widthAnchor.constraint(equalTo:titleScroll.frameLayoutGuide.widthAnchor,constant:-8),titleLabel.heightAnchor.constraint(greaterThanOrEqualTo:titleScroll.frameLayoutGuide.heightAnchor)])
        breadcrumbs.axis = .horizontal; breadcrumbs.alignment = .center; breadcrumbs.spacing = 4
        breadcrumbs.isLayoutMarginsRelativeArrangement = true; breadcrumbs.directionalLayoutMargins = NSDirectionalEdgeInsets(top:0,leading:12,bottom:0,trailing:12)
        crumbScroll.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbs.translatesAutoresizingMaskIntoConstraints = false; crumbScroll.addSubview(breadcrumbs)
        NSLayoutConstraint.activate([breadcrumbs.topAnchor.constraint(equalTo: crumbScroll.contentLayoutGuide.topAnchor), breadcrumbs.bottomAnchor.constraint(equalTo: crumbScroll.contentLayoutGuide.bottomAnchor), breadcrumbs.leadingAnchor.constraint(equalTo: crumbScroll.contentLayoutGuide.leadingAnchor), breadcrumbs.trailingAnchor.constraint(equalTo: crumbScroll.contentLayoutGuide.trailingAnchor), breadcrumbs.heightAnchor.constraint(equalTo: crumbScroll.frameLayoutGuide.heightAnchor),breadcrumbs.widthAnchor.constraint(greaterThanOrEqualTo:crumbScroll.frameLayoutGuide.widthAnchor)])
        crumbSurface.translatesAutoresizingMaskIntoConstraints = false; crumbScroll.insertSubview(crumbSurface,at:0)
        NSLayoutConstraint.activate([crumbSurface.topAnchor.constraint(equalTo:breadcrumbs.topAnchor),crumbSurface.bottomAnchor.constraint(equalTo:breadcrumbs.bottomAnchor),crumbSurface.leadingAnchor.constraint(equalTo:breadcrumbs.leadingAnchor),crumbSurface.trailingAnchor.constraint(equalTo:breadcrumbs.trailingAnchor)])
        crumbScroll.tag = 19
        workspace.axis = .vertical; workspace.spacing = 5
        listPanel.axis = .vertical; listPanel.spacing = 4; schemePanel.translatesAutoresizingMaskIntoConstraints = false
        schemeColumn.axis = .vertical; schemeColumn.spacing = 4
        schemeColumn.addArrangedSubview(operandBar); schemeColumn.addArrangedSubview(schemePanel)
        schemeColumn.addSubview(crumbScroll)
        crumbScroll.layer.cornerRadius = 12; crumbScroll.clipsToBounds = true
        NSLayoutConstraint.activate([crumbScroll.topAnchor.constraint(equalTo:operandBar.topAnchor),crumbScroll.bottomAnchor.constraint(equalTo:operandBar.bottomAnchor),crumbScroll.leadingAnchor.constraint(equalTo:operandBar.leadingAnchor),crumbScroll.trailingAnchor.constraint(equalTo:operandBar.trailingAnchor)])
        schemeColumn.setContentHuggingPriority(.init(1), for: .vertical)
        workspace.addArrangedSubview(schemeColumn); workspace.addArrangedSubview(listPanel)
        listWidth = listPanel.widthAnchor.constraint(equalTo: workspace.widthAnchor, multiplier: 0.4)
        column.addArrangedSubview(workspace)
        listOverlay.translatesAutoresizingMaskIntoConstraints = false
        listPanel.addArrangedSubview(listOverlay)
        stepsScroll.translatesAutoresizingMaskIntoConstraints = false; stepRows.translatesAutoresizingMaskIntoConstraints = false
        stepRows.axis = .vertical; stepRows.spacing = 0; stepsScroll.addSubview(stepRows)
        listOverlay.addSubview(stepsScroll)
        listHeight = listOverlay.heightAnchor.constraint(equalToConstant:stepsHeightPreference.savedHeight ?? 225)
        listHeight.priority = .init(999)
        NSLayoutConstraint.activate([stepsScroll.topAnchor.constraint(equalTo: listOverlay.topAnchor), stepsScroll.bottomAnchor.constraint(equalTo: listOverlay.bottomAnchor), stepsScroll.leadingAnchor.constraint(equalTo: listOverlay.leadingAnchor), stepsScroll.trailingAnchor.constraint(equalTo: listOverlay.trailingAnchor),
            stepRows.topAnchor.constraint(equalTo: stepsScroll.contentLayoutGuide.topAnchor), stepRows.bottomAnchor.constraint(equalTo: stepsScroll.contentLayoutGuide.bottomAnchor), stepRows.leadingAnchor.constraint(equalTo: stepsScroll.contentLayoutGuide.leadingAnchor), stepRows.trailingAnchor.constraint(equalTo: stepsScroll.contentLayoutGuide.trailingAnchor), stepRows.widthAnchor.constraint(equalTo: stepsScroll.frameLayoutGuide.widthAnchor), listHeight])
        listControls.axis = .vertical; listControls.spacing = 2; listControls.translatesAutoresizingMaskIntoConstraints = false
        listControls.backgroundColor = palette.background.withAlphaComponent(0.9); listControls.layer.cornerRadius = 5
        for (delta, title) in [(StepsPanelHeightPreference.increment, "steps_height_increase"), (-StepsPanelHeightPreference.increment, "steps_height_decrease")] {
            let control = UIButton(type: .system)
            control.setTitle(delta > 0 ? "+" : "−",for: .normal)
            control.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            control.accessibilityLabel = CatalogText.ui(title)
            control.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([control.widthAnchor.constraint(equalToConstant:32),control.heightAnchor.constraint(equalToConstant:28)])
            control.addAction(UIAction { [weak self] _ in self?.resizeSteps(delta) },for: .touchUpInside)
            listControls.addArrangedSubview(control)
        }
        listOverlay.addSubview(listControls)
        NSLayoutConstraint.activate([listControls.trailingAnchor.constraint(equalTo: listOverlay.trailingAnchor), listControls.bottomAnchor.constraint(equalTo: listOverlay.bottomAnchor,constant: -2), listControls.widthAnchor.constraint(equalToConstant: 32)])
        diagramScroll.contentInsetAdjustmentBehavior = .never
        diagramScroll.translatesAutoresizingMaskIntoConstraints = false
        diagramScroll.alwaysBounceVertical = false
        diagramColumn.axis = .vertical; diagramColumn.translatesAutoresizingMaskIntoConstraints = false
        diagramColumn.addArrangedSubview(scheme); diagramColumn.layer.addSublayer(nestingArrows); diagramScroll.addSubview(diagramColumn)
        schemePanel.addSubview(diagramScroll)
        NSLayoutConstraint.activate([diagramScroll.topAnchor.constraint(equalTo: schemePanel.topAnchor), diagramScroll.bottomAnchor.constraint(equalTo: schemePanel.bottomAnchor), diagramScroll.leadingAnchor.constraint(equalTo: schemePanel.leadingAnchor), diagramScroll.trailingAnchor.constraint(equalTo: schemePanel.trailingAnchor),
            diagramColumn.topAnchor.constraint(equalTo: diagramScroll.contentLayoutGuide.topAnchor), diagramColumn.bottomAnchor.constraint(equalTo: diagramScroll.contentLayoutGuide.bottomAnchor,constant: -15), diagramColumn.leadingAnchor.constraint(equalTo: diagramScroll.contentLayoutGuide.leadingAnchor,constant: 15), diagramColumn.trailingAnchor.constraint(equalTo: diagramScroll.contentLayoutGuide.trailingAnchor,constant: -15), diagramColumn.widthAnchor.constraint(equalTo: diagramScroll.frameLayoutGuide.widthAnchor,constant: -30), schemePanel.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)])
        schemePanel.setContentHuggingPriority(.init(1), for: .vertical)
        let zoom = UIStackView(); zoom.axis = .vertical; zoom.spacing = 4; zoom.translatesAutoresizingMaskIntoConstraints = false
        for (direction, icon) in [(1,AppIcon.zoomIn), (-1,AppIcon.zoomOut)] {
            let control = button("", icon: icon, kind: .icon) { [weak self] in self?.changeSchemeSize(direction) }
            control.setContentInsets(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6), minimumHeight: 36)
            control.accessibilityLabel = direction > 0 ? "Zoom In" : "Zoom Out"
            control.widthAnchor.constraint(equalToConstant: 36).isActive = true
            control.heightAnchor.constraint(equalToConstant: 36).isActive = true
            zoom.addArrangedSubview(control)
        }
        schemePanel.addSubview(zoom)
        NSLayoutConstraint.activate([zoom.leadingAnchor.constraint(equalTo: schemePanel.leadingAnchor,constant: 10), zoom.topAnchor.constraint(equalTo: schemePanel.topAnchor,constant: 5)])
        notice = button("", kind: .plain) { [weak self] in
            let defaults = UserDefaults.standard; let key = "is_rule_steps_coming_soon_expanded"
            defaults.set(!(defaults.object(forKey: key) as? Bool ?? true), forKey: key); self?.render()
        }
        column.addArrangedSubview(notice)
        textView.isEditable = false; textView.isSelectable = true; textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        column.addArrangedSubview(textView)
        separate = button("", kind: .compact) { [weak self] in self?.openNested() }
        separate.label.role = .detail
        separate.setContentInsets(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), minimumHeight: 44)
        separateContainer.axis = .vertical; separateContainer.alignment = .center; separateContainer.spacing = 2
        separateContainer.translatesAutoresizingMaskIntoConstraints = false
        separateIcon.contentMode = .scaleAspectFit; separateIcon.isAccessibilityElement = false
        separateContainer.addArrangedSubview(separateIcon); separateContainer.addArrangedSubview(separate)
        schemePanel.addSubview(separateContainer)
        NSLayoutConstraint.activate([separateIcon.widthAnchor.constraint(equalToConstant:24),separateIcon.heightAnchor.constraint(equalToConstant:24),
            separateContainer.trailingAnchor.constraint(equalTo:schemePanel.trailingAnchor,constant:-10),separateContainer.bottomAnchor.constraint(equalTo:schemePanel.bottomAnchor,constant:-10),separateContainer.widthAnchor.constraint(lessThanOrEqualToConstant:164),
            separateContainer.leadingAnchor.constraint(greaterThanOrEqualTo:schemePanel.leadingAnchor,constant:8),
            separate.widthAnchor.constraint(lessThanOrEqualTo:separateContainer.widthAnchor)])
        insert = button("", kind: .compact) { [weak self] in self?.popNested(advance: true) }
        share = button(CatalogText.ui("share_solution"),icon:.resultShare, kind: .compact) { [weak self] in self?.shareScheme() }
        let finished = UIStackView(arrangedSubviews: [insert, share]); finished.distribution = .fillEqually; finished.tag = 22
        listPanel.insertArrangedSubview(finished,at:0)
        for control in [insert!,share!] { control.label.role = .detail; control.setContentInsets(UIEdgeInsets(top:8,left:12,bottom:8,right:12),minimumHeight:48) }
        previous = button("", icon: .previous, kind: .icon) { [weak self] in self?.move(-1) }
        nextStep = button("", icon: .next, kind: .icon) { [weak self] in self?.move(1) }
        levels = button(CatalogText.ui("levels"), icon: .levels, kind: .compact) { [weak self] in
            guard let self else { return }; router?.show(.levels(trick.id))
        }
        stepTitle.numberOfLines = 1; stepTitle.textAlignment = .center; stepTitle.alpha = 0.7
        stepTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        for control in [previous!, nextStep!] {
            control.setContentInsets(.zero,minimumHeight: 32)
            control.widthAnchor.constraint(equalToConstant: 50).isActive = true
        }
        let arrows = UIStackView(arrangedSubviews: [previous, stepTitle, nextStep]); arrows.alignment = .center
        let navigation = UIStackView(arrangedSubviews: [arrows, levels]); navigation.distribution = .fillEqually; navigation.spacing = 6
        column.addArrangedSubview(navigation)
        regenerate(reset: true)
    }
    private func operandSlot(_ field: UITextField, second: Bool) -> UIStackView {
        field.keyboardType = .numberPad; field.textAlignment = .center; field.delegate = self
        field.accessibilityIdentifier = second ? "rule.operand2" : "rule.operand1"
        let width = field.widthAnchor.constraint(equalToConstant: 85)
        width.isActive = true
        if second { secondFieldWidth = width } else { firstFieldWidth = width }
        field.adjustsFontSizeToFitWidth = false
        field.addAction(UIAction { [weak self, weak field] _ in
            guard let self, let field, let value = Int64(field.text ?? ""), value <= Int64(Int32.max) else { return }
            if second { self.second = value } else { first = value }
            regenerate(reset: false)
        }, for: .editingChanged)
        let toolbar = UIToolbar(); toolbar.sizeToFit()
        toolbar.items = [UIBarButtonItem(systemItem: .flexibleSpace), UIBarButtonItem(title: CatalogText.ui("resume"), primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) })]
        field.inputAccessoryView = toolbar
        let row = UIStackView(); row.axis = .horizontal; row.alignment = .center
        let height = row.heightAnchor.constraint(equalToConstant:32); height.priority = .init(999); height.isActive = true
        operandRowHeights.append(height)
        for direction in [-1, 1] {
            let control = button("", icon: direction < 0 ? .previous : .next, kind: .icon) {}
            control.setContentInsets(.zero,minimumHeight:32)
            if !second { firstArrows.append(control) } else { secondArrows.append(control) }
            control.widthAnchor.constraint(equalToConstant: 32).isActive = true
            control.addAction(UIAction { [weak self] _ in self?.startRepeat(second: second, direction: direction) }, for: .touchDown)
            control.addAction(UIAction { [weak self] _ in self?.stopRepeat() }, for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
            if direction == 1 { row.addArrangedSubview(field) }
            row.addArrangedSubview(control)
        }
        return row
    }
    private func startRepeat(second: Bool, direction: Int) {
        stopRepeat(); repeatCount = 0
        changeOperand(second: second, direction: direction)
        scheduleRepeat(second: second, direction: direction, initial: true)
    }
    private func scheduleRepeat(second: Bool, direction: Int, initial: Bool = false) {
        let delay: Double = initial ? 0.5 : repeatCount > 50 ? 0.01 : repeatCount > 30 ? 0.02 : repeatCount > 15 ? 0.04 : repeatCount > 5 ? 0.08 : 0.15
        repeatTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }; self.repeatCount += 1; self.changeOperand(second: second, direction: direction); self.scheduleRepeat(second: second, direction: direction)
            }
        }
    }
    private func stopRepeat() { repeatTimer?.invalidate(); repeatTimer = nil }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); stopRepeat() }
    private func changeOperand(second: Bool, direction: Int) {
        guard let state = operandState else { return }
        let changed = state.changing(second: second, direction: direction)
        first = changed.first; self.second = changed.second
        AppFeedback.shared.play(.keypress); regenerate(reset: false)
    }
    func textFieldDidEndEditing(_ textField: UITextField) { regenerate(reset: false) }
    private func regenerate(reset: Bool) {
        needsOperandLayout = true
        let value = RuleExampleGenerator.make(trickID: trick.id, first: first, second: second)
        first = value.first; second = value.second; operandState = value
        do {
            let generated = try SolutionStep.generate(value.example, variant: variant)
            example = value.example; steps = generated; supported = true
            index = reset ? 0 : min(index,steps.count - 1)
        } catch { supported = false; steps = [] }
        render()
    }
    private func move(_ delta: Int) {
        guard !steps.isEmpty else { return }; index = (index + delta + steps.count) % steps.count
        AppFeedback.shared.play(.solution); render(); scrollToStep()
    }
    private func scrollToStep() {
        guard stepButtons.indices.contains(index) else { return }
        stepsScroll.scrollRectToVisible(stepButtons[index].frame, animated: true)
    }
    private func clear(_ stack: UIStackView) {
        for view in stack.arrangedSubviews { stack.removeArrangedSubview(view); view.removeFromSuperview() }
    }
    private func format(_ key: String, _ value: String) -> String {
        CatalogText.ui(key).replacingOccurrences(of: "%1$s", with: value).replacingOccurrences(of: "%s", with: value).replacingOccurrences(of: "%d", with: value)
    }
    private func expression(_ value: MathExample) -> String {
        let a = MathExpressionFormatter.number(value.displayedOperand1), b = MathExpressionFormatter.number(value.displayedOperand2)
        switch value.operation {
        case .addition: return a + " + " + b
        case .subtraction: return a + " − " + b
        case .multiplication: return a + " × " + b
        case .division: return a + " ÷ " + b
        case .power: return a + "^" + b
        case .root: return b + "√" + a
        case .percent: return a + "% × " + b
        }
    }
    private func openNested() {
        guard let example, steps.indices.contains(index) else { return }
        let candidates = SolutionSubexpression.examples(from: steps[index].hintExpr).filter { $0.signature != example.signature }
        guard let candidate = candidates.first, parents.count < 16, let generated = try? SolutionStep.generate(candidate) else { return }
        parents.append((example, steps, index, variant)); nestedMethods.append((methods,methodIndex))
        methods = candidates; methodIndex = 0; self.example = candidate; steps = generated; index = 0; variant = 0
        render(); scrollToStep()
    }
    private func popNested(advance: Bool) {
        guard let parent = parents.popLast() else { return }
        example = parent.0; steps = parent.1; index = min(steps.count - 1, parent.2 + (advance ? 1 : 0)); variant = parent.3
        if let prior = nestedMethods.popLast() { methods = prior.0; methodIndex = prior.1 }
        render(); scrollToStep()
    }
    private func switchNestedMethod(_ direction: Int) {
        guard methods.count > 1 else { return }
        methodIndex = (methodIndex + direction + methods.count) % methods.count
        let candidate = methods[methodIndex]
        guard let generated = try? SolutionStep.generate(candidate) else { return }
        example = candidate; steps = generated; index = 0; render()
    }
    private func shareScheme() {
        guard let step = steps.last, let example, index == steps.count - 1, step.isFinal, presentedViewController == nil else { return }
        guard let image = SolutionSchemeShare.make(step:step,input:"",example:example,steps:steps,settings:appearanceSettings,traits:traitCollection) else {
            present(AppDialogViewController(title: CatalogText.ui("share_solution"), message: ResultText.text("results_share_error"), actions: [.init(title: MainText.text("ok"), handler: {})], data: data), animated: false)
            return
        }
        let sheet = UIActivityViewController(activityItems: [image,ResultShareCard.links], applicationActivities: nil)
        sheet.popoverPresentationController?.sourceView = share; sheet.popoverPresentationController?.sourceRect = share.bounds
        present(sheet, animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if lastOperandViewportWidth != operandScroll.bounds.width { needsOperandLayout = true }
        updateOperandBar()
        let isLandscape = view.bounds.width > view.bounds.height
        if landscape != isLandscape {
            landscape = isLandscape; listHeight?.isActive = !isLandscape
            listWidth?.isActive = isLandscape; workspace.axis = isLandscape ? .horizontal : .vertical
            listControls.isHidden = isLandscape
            column.setNeedsLayout()
        }
        if !isLandscape, listHeight != nil, workspace.bounds.height > 0 {
            let target = stepsHeightPreference.height(in: stepsHeightLimits())
            if abs(listHeight.constant - target) > 0.5 { listHeight.constant = target; view.setNeedsLayout() }
        }
        diagramScroll.layoutIfNeeded()
        if needsSchemeLayout || abs(lastSchemeWidth - diagramScroll.bounds.width) > 0.5 {
            lastSchemeWidth = diagramScroll.bounds.width
            updateSchemeLayout()
        }
        diagramScroll.layoutIfNeeded(); diagramColumn.layoutIfNeeded()
        let ids = parents.indices.map { depth in "\(parents[depth].0.signature):\(depth + 1 < parents.count ? parents[depth + 1].0.signature : example?.signature ?? "")" }
        let style = schemeStyle()
        nestingArrows.update(parents:frozenSchemes,active:scheme,ids:ids,container:diagramColumn,palette:palette,scale:style.fontSize/style.originalSize)
        schemeScrollPosition.finish(diagramScroll)
        operandScroll.layoutIfNeeded()
        if lastOperandContentWidth != operandScroll.contentSize.width || lastOperandViewportWidth != operandScroll.bounds.width {
            if !operandScroll.isDragging, !operandScroll.isDecelerating, !firstField.isFirstResponder, !secondField.isFirstResponder {
                lastOperandContentWidth = operandScroll.contentSize.width; lastOperandViewportWidth = operandScroll.bounds.width
                operandScroll.setContentOffset(CGPoint(x:max(0,(operandScroll.contentSize.width-operandScroll.bounds.width)/2),y:0),animated:false)
            }
        }
        listOverlay.bringSubviewToFront(listControls)
    }
    override func update(_ progress: ProgressState?) { needsOperandLayout = true; render() }
    private func resizeSteps(_ delta: Int) {
        guard landscape != true else { return }
        view.layoutIfNeeded()
        let limits = stepsHeightLimits()
        listHeight.constant = stepsHeightPreference.resize(by: delta, currentHeight: listOverlay.bounds.height, limits: limits)
        view.setNeedsLayout(); view.layoutIfNeeded()
    }
    private func stepsHeightLimits() -> ClosedRange<CGFloat> {
        let controlsHeight = listControls.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let minimum = max(48,controlsHeight + 4)
        let actions = listPanel.arrangedSubviews.filter { $0 !== listOverlay && !$0.isHidden }
        let actionsHeight = actions.reduce(CGFloat.zero) { $0 + $1.systemLayoutSizeFitting(CGSize(width:max(1,listPanel.bounds.width),height:0),withHorizontalFittingPriority:.required,verticalFittingPriority:.fittingSizeLevel).height + listPanel.spacing }
        let maximum = max(minimum,min(view.bounds.height * 0.455,workspace.bounds.height - (operandBar.isHidden ? 0 : operandBar.bounds.height + schemeColumn.spacing) - workspace.spacing - 48 - actionsHeight))
        return minimum...maximum
    }
    private func layoutOperandBar() {
        guard firstFieldWidth != nil else { return }
        let font = AppTypography.font(.scheme,settings:appearanceSettings,traits:traitCollection)
        func fieldWidth(_ field: UITextField) -> CGFloat {
            let measured = ((field.text ?? "") as NSString).size(withAttributes:[.font:font]).width + 12
            return max(28,measured)
        }
        let firstWidth = fieldWidth(firstField), secondWidth = fieldWidth(secondField)
        let stacked = operandState?.stackedOperands == true
        firstFieldWidth.constant = stacked ? max(firstWidth,secondWidth) : firstWidth
        secondFieldWidth.constant = stacked ? max(firstWidth,secondWidth) : secondWidth
    }
    private func changeSchemeSize(_ direction: Int) {
        let style = schemeStyle()
        let next = direction > 0 ? min(3.5,min(zoomMultiplier + 0.15,style.maximumZoom)) : max(0.5,zoomMultiplier - 0.15)
        guard direction > 0 ? next > zoomMultiplier + 0.005 : next < zoomMultiplier - 0.005 else { return }
        schemeScrollPosition.begin(diagramScroll,depth:parents.count); zoomMultiplier = next; updateSchemeLayout(); view.setNeedsLayout()
    }
    private func schemeStyle() -> SolutionSchemeView.RuleStyle {
        let width = max(1,diagramScroll.bounds.width - 30)
        let sources = parents.map { $0.1[$0.2].processedEquation(input: "",trickID: $0.0.trickID).text } + (steps.indices.contains(index) ? [steps[index].processedEquation(input: "",trickID: example?.trickID ?? trick.id).text] : [])
        return SolutionSchemeView.RuleStyle(width: width, texts: sources, settings: appearanceSettings, traits: traitCollection, zoom: zoomMultiplier)
    }
    private func updateSchemeLayout() {
        guard let example, steps.indices.contains(index), diagramScroll.bounds.width > 30 else { return }
        let style = schemeStyle()
        for (position, parent) in parents.enumerated() where frozenSchemes.indices.contains(position) {
            frozenSchemes[position].apply(step: parent.1[parent.2], input: "", example: parent.0, settings: appearanceSettings, frozen: true, ruleStyle: style)
        }
        scheme.apply(step: steps[index], input: "", example: example, settings: appearanceSettings, ruleStyle: style)
        needsSchemeLayout = false
    }
    private func updateOperandBar() {
        guard needsOperandLayout else { return }
        let operandFont = AppTypography.font(.scheme, settings: appearanceSettings, traits: traitCollection)
        firstField.font = operandFont
        secondField.font = firstField.font; firstField.textColor = palette.text; secondField.textColor = palette.text
        if !firstField.isFirstResponder { firstField.text = String(first) }
        if !secondField.isFirstResponder { secondField.text = String(second) }
        if let state = operandState {
            range.text = state.rangeText
            secondSlot.isHidden = !state.twoOperands
            firstField.isEnabled = !state.fixedFirst; secondField.isEnabled = !state.fixedSecond
            firstArrows.forEach { $0.isHidden = state.fixedFirst }; secondArrows.forEach { $0.isHidden = state.fixedSecond }
            if state.fixedFirst { firstField.text = MathExpressionFormatter.number(state.example.displayedOperand1) }
            if state.stackedOperands, suffix.superview !== operandExpression {
                operandContent.removeArrangedSubview(suffix); suffix.removeFromSuperview()
                operandExpression.addArrangedSubview(suffix)
            } else if !state.stackedOperands, suffix.superview !== operandContent {
                operandExpression.removeArrangedSubview(suffix); suffix.removeFromSuperview()
                operandContent.addArrangedSubview(suffix)
            }
            operandExpression.spacing = state.stackedOperands ? 8 : 0
            operandContent.axis = state.stackedOperands ? .vertical : .horizontal
            operandContent.alignment = state.stackedOperands ? .leading : .center
            operandContent.distribution = state.stackedOperands ? .fillEqually : .fill
            signBalanceWidth.isActive = state.stackedOperands
            signBalance.isHidden = !state.stackedOperands
            prefix.text = state.prefix; prefix.isHidden = state.prefix.isEmpty
            suffix.text = state.suffix; sign.text = state.sign
        }
        range.apply(settings: appearanceSettings); range.textColor = palette.secondary
        sign.apply(settings: appearanceSettings); sign.textColor = palette.text
        prefix.apply(settings: appearanceSettings); prefix.textColor = palette.text
        suffix.apply(settings: appearanceSettings); suffix.textColor = palette.text
        let rowHeight = max(32,ceil(operandFont.lineHeight)+6)
        operandRowHeights.forEach { $0.constant = rowHeight }
        stackedOperandHeight.constant = rowHeight * 2
        stackedOperandHeight.isActive = operandState?.stackedOperands == true
        layoutOperandBar()
        if operandScroll.bounds.width > 0 {
            let exampleHeight = rowHeight * (operandState?.stackedOperands == true ? 2 : 1)
            let rangeHeight = range.sizeThatFits(CGSize(width:max(1,operandScroll.bounds.width*0.18),height:.greatestFiniteMagnitude)).height
            barHeight?.constant = max(48,ceil(max(exampleHeight,rangeHeight))+4)
            needsOperandLayout = false
        }
    }
    private func render() {
        guard isViewLoaded, levels != nil else { return }
        schemeScrollPosition.begin(diagramScroll,depth:parents.count)
        separateIcon.tintColor = palette.accent
        updateOperandBar()
        stepTitle.apply(settings: appearanceSettings); stepTitle.textColor = palette.text
        stepTitle.text = steps.isEmpty ? "" : format("rule_step_title",String(index + (steps.first?.isIntro == true ? 0 : 1)))
        method.isEnabled = parents.isEmpty && ([62,66].contains(trick.id) || trick.id == 5 && first < 100)
        method.isHidden = !method.isEnabled
        method.label.text = CatalogText.ui(variant == 0 ? "rule_method_1" : "rule_method_2")
        method.apply(color: palette.headerText)
        operandBar.isHidden = !supported
        operandBar.alpha = parents.isEmpty ? 1 : 0
        operandBar.isUserInteractionEnabled = parents.isEmpty
        operandBar.accessibilityElementsHidden = !parents.isEmpty
        operandBar.backgroundColor = palette.theme.isClassic ? UIColor.gray.withAlphaComponent(32 / 255) : palette.surface
        operandBar.layer.borderColor = (palette.theme.isClassic ? UIColor.gray.withAlphaComponent(80 / 255) : palette.divider).cgColor
        suffix.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        suffix.lineBreakMode = .byWordWrapping
        stepsScroll.isHidden = !supported; diagramScroll.isHidden = !supported; textView.isHidden = supported
        notice.isHidden = supported
        let expanded = UserDefaults.standard.object(forKey: "is_rule_steps_coming_soon_expanded") as? Bool ?? true
        notice.label.text = CatalogText.ui(expanded ? "rule_steps_coming_soon" : "rule_steps_coming_soon_short") + (expanded ? " ▴" : " ▾")
        textView.attributedText = AndroidRichText.attributed(CatalogText.text(trick.ruleKey) == "-1" ? "" : CatalogText.text(trick.ruleKey), font: AppTypography.font(.body, settings: appearanceSettings, traits: traitCollection), color: palette.text)
        crumbScroll.isHidden = !supported || parents.isEmpty
        crumbSurface.apply(settings:appearanceSettings)
        workspace.isHidden = !supported
        listOverlay.backgroundColor = ThemeColor.rgb(0x808080,alpha:21 / 255)
        listOverlay.layer.borderColor = ThemeColor.rgb(0x808080,alpha:160 / 255).cgColor
        listOverlay.layer.borderWidth = 2
        listOverlay.layer.cornerRadius = 8
        listOverlay.clipsToBounds = true
        listControls.backgroundColor = palette.dialogBackground
        listControls.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { $0.tintColor = palette.text }
        themedButtons.removeAll { button in dividerButtons.contains(where: { $0 === button }) || breadcrumbs.arrangedSubviews.contains(where: { $0 === button }) }
        clear(stepRows); clear(breadcrumbs); stepButtons.removeAll(); dividerButtons.removeAll()
        for (depth, parent) in parents.enumerated() {
            let crumb = button(expression(parent.0) + " (" + format("rule_step_title",String(parent.2 + (parent.1.first?.isIntro == true ? 0 : 1))) + ")", kind: .plain) { [weak self] in
                guard let self else { return }; while parents.count > depth { popNested(advance: false) }
            }
            crumb.label.role = .dailyCaption; crumb.label.font = AppTypography.font(.dailyCaption,settings:appearanceSettings,traits:traitCollection,weight:700)
            crumb.label.textColor = ThemeColor.rgb(palette.theme.isDark ? 0xCCCCCC : 0x444444)
            crumb.setContentInsets(UIEdgeInsets(top:6,left:6,bottom:6,right:6),minimumHeight:38)
            breadcrumbs.addArrangedSubview(crumb)
            let arrow = UIImageView(image:UIImage(named:"ic_breadcrumb_arrow_separator")?.withRenderingMode(.alwaysTemplate)); arrow.tintColor = palette.secondary; arrow.translatesAutoresizingMaskIntoConstraints = false
            breadcrumbs.addArrangedSubview(arrow)
            NSLayoutConstraint.activate([arrow.widthAnchor.constraint(equalToConstant:12),arrow.heightAnchor.constraint(equalTo:breadcrumbs.heightAnchor)])
        }
        if let example, !parents.isEmpty {
            let current = AppLabel(.detail,weight:700); current.text = expression(example); current.apply(settings:appearanceSettings); current.textColor = palette.text; breadcrumbs.addArrangedSubview(current)
        }
        let offset = stepsScroll.contentOffset
        for (position, step) in steps.enumerated() {
            let title = format("rule_step_title",String(position + (steps.first?.isIntro == true ? 0 : 1)))
            let row = SolutionStepRow(title: title, step: step, settings: appearanceSettings, selected: position == index) { [weak self] in
                self?.index = position; self?.render(); self?.scrollToStep()
            }
            stepButtons.append(row); stepRows.addArrangedSubview(row)
        }
        stepsScroll.contentOffset = offset
        previous.isHidden = !supported; nextStep.isHidden = !supported
        previous.isEnabled = steps.count > 1; nextStep.isEnabled = steps.count > 1
        separateContainer.isHidden = true; share.isHidden = true; insert.isHidden = true; listPanel.viewWithTag(22)?.isHidden = true
        guard supported, let example, steps.indices.contains(index) else { return }
        clear(diagramColumn); frozenSchemes.removeAll()
        for (depth, parent) in parents.enumerated() {
            let frozen = SolutionSchemeView()
            frozen.alpha = 0.55; diagramColumn.addArrangedSubview(frozen); frozenSchemes.append(frozen)
            let child = depth + 1 < parents.count ? parents[depth + 1].0 : example
            let name = TrickCatalog.shared.trick(child.trickID).map { AndroidRichText.plain(CatalogText.text($0.nameKey)) } ?? ""
            let childMethods = depth + 1 < nestedMethods.count ? nestedMethods[depth + 1] : (methods,methodIndex)
            let caption = name + (childMethods.0.count > 1 ? " (\(childMethods.1+1)/\(childMethods.0.count))" : "")
            let divider = button(childMethods.0.count > 1 ? "◀  " + caption + "  ▶" : caption, kind: .plain) { [weak self] in self?.switchNestedMethod(1) }
            divider.setContentInsets(UIEdgeInsets(top:20,left:12,bottom:20,right:12),minimumHeight:44)
            divider.isEnabled = depth == parents.count - 1 && methods.count > 1
            diagramColumn.addArrangedSubview(divider); dividerButtons.append(divider)
        }
        diagramColumn.addArrangedSubview(scheme)
        let step = steps[index]
        let candidates = SolutionSubexpression.examples(from: step.hintExpr).filter { $0.signature != example.signature }
        separateContainer.isHidden = step.isIntro || step.isFinal || [1,2,3,4].contains(example.trickID) || candidates.isEmpty
        separate.label.text = format("solve_step_separately_fmt", step.hintExpr)
        share.isHidden = !step.isFinal; insert.isHidden = parents.isEmpty || !step.isFinal
        insert.label.text = format("solution_insert_answer", String(example.answer))
        listPanel.viewWithTag(22)?.isHidden = share.isHidden && insert.isHidden
        needsSchemeLayout = true
        view.setNeedsLayout()
    }
}
