import UIKit
import Combine

final class GameViewController: ThemedViewController, AppBackHandling {
    private let configuration: GameConfiguration?
    private var session: GameSession?
    private var pending: (session: GameSession, mutation: GameMutation, completion: (() -> Void)?)?
    private struct QueuedInput {
        let signature: String
        let mode: GameInputMode
        let action: (inout GameSession, TimeInterval) throws -> GameMutation
    }
    private var queuedInput: [QueuedInput] = []
    private var backgroundSave: UIBackgroundTaskIdentifier = .invalid
    private var saving = false
    private var timer: Timer?
    private var observations = Set<AnyCancellable>()
    private var sceneActive = true
    private var pendingSolutionAnswer: String?
    private var solutionAnswerTask: Task<Void, Never>?
    private var status: AppLabel!
    private var levelLabel: AppLabel!
    private var scoreLabel: AppLabel!
    private var coinLabel: AppLabel!
    private let coinIcon = UIImageView(image:AppIcon.coins.image?.withRenderingMode(.alwaysTemplate))
    private let starImage = UIImageView()
    private let headerInformation=UIStackView()
    private var headerBalance:NSLayoutConstraint?
    private let booleanSolution = BooleanSolutionLabel()
    private let booleanSolutionScroll = AppScrollView()
    private var expressionView: FittingMathExpressionView!
    private var expressionPanel = UIView()
    private var utility = UIStackView()
    private var utilityActions = UIStackView()
    private let ruleScroll = AppScrollView()
    private var lowerPanel = UIStackView()
    private var playing = UIView()
    private var resultScroll = UIView()
    private lazy var resultTable = GameResultTableView()
    private var hasBuiltResults = false
    private var change: AppButton!
    private var move: AppButton!
    private let moveRow = UIStackView()
    private var voice: AppButton!
    private var replayVoice: AppButton!
    private var booleanProposal: AppLabel!
    private var layoutConstraints: [NSLayoutConstraint] = []
    private var layoutLandscape: Bool?
    private var layoutKeypadRight: Bool?
    private var lowerHeight: NSLayoutConstraint?
    private var equation: AppLabel!
    private var answer: AppLabel!
    private var trickName: AppLabel!
    private var hint: AppButton!
    private var skip: AppButton!
    private var resume: AppButton!
    private var inputModes = UIStackView()
    private var digits = UIStackView()
    private var variants = UIStackView()
    private var boolButtons = UIStackView()
    private var timerBar = AndroidGameProgressView()
    private var utilityWidths:[NSLayoutConstraint]=[]
    private var resultReadTask:Task<Void,Never>?
    private var resultHistoryID:String?
    private lazy var resultDetails=ResultDetailsCoordinator(owner:self,router:router)
    private var inputTransitionEnds: CFTimeInterval = 0
    private var leavingWithoutResults = false
    private var lastNumpad: Bool?
    private var choiceButtons: [AppButton] = []
    private var lastChoices: [Int64] = []
    private var isVisible = false
    var usesCategoryColor: Bool {
        settings.gameCategoryColors == true
            || ((session?.configuration.mode ?? configuration?.mode) == .training && settings.tricksCategoryColors != false)
    }
    private var lastSpokenSignature: String?

    init(configuration: GameConfiguration?, router: AppRouter, data: AppDataStore) {
        self.configuration = configuration
        super.init(title: "Math Tricks", router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { timer?.invalidate();resultReadTask?.cancel() }
    override func buildContent() {
        view.accessibilityIdentifier = "screen.game"
        // The Android game divides the available screen between expression and keyboard.
        // Only the rule name and result page scroll; the keyboard stays in place.
        let headerLeft=headerInformation;headerLeft.axis = .vertical;headerLeft.alignment = .leading
        levelLabel=label("",role:.headCount);status=label("",role:.headCount)
        headerLeft.addArrangedSubview(levelLabel);headerLeft.addArrangedSubview(status)
        let hud=UIStackView();hud.axis = .horizontal;hud.alignment = .center;hud.spacing=8
        hud.addArrangedSubview(headerLeft)
        starImage.contentMode = .scaleAspectFit; starImage.isAccessibilityElement = true
        
        let starWidth=starImage.widthAnchor.constraint(equalToConstant:75),starHeight=starImage.heightAnchor.constraint(equalToConstant:30)
        starWidth.priority = .init(999);starHeight.priority = .init(999);NSLayoutConstraint.activate([starWidth,starHeight])
        scoreLabel=label("",role:.score);scoreLabel.textAlignment = .left
        scoreLabel.numberOfLines=1;scoreLabel.adjustsFontSizeToFitWidth=true;scoreLabel.minimumScaleFactor=0.5
        scoreLabel.setContentHuggingPriority(.defaultHigh,for:.horizontal)
        hud.addArrangedSubview(scoreLabel);hud.addArrangedSubview(starImage);header.replaceTitle(with:hud)
        let equal=headerLeft.widthAnchor.constraint(equalTo:scoreLabel.widthAnchor);equal.priority = .init(999);equal.isActive=true;headerBalance=equal
        for item in [levelLabel,status] {item?.numberOfLines=1;item?.adjustsFontSizeToFitWidth=true;item?.minimumScaleFactor=0.7}
        playing.translatesAutoresizingMaskIntoConstraints=false;body.addSubview(playing)
        NSLayoutConstraint.activate([
            playing.topAnchor.constraint(equalTo:body.topAnchor),playing.bottomAnchor.constraint(equalTo:body.bottomAnchor),
            playing.leadingAnchor.constraint(equalTo:body.leadingAnchor),playing.trailingAnchor.constraint(equalTo:body.trailingAnchor)
        ])
        equation=label("",role:.expression);equation.accessibilityIdentifier="game.expression"
        answer=label("?",role:.expression);answer.accessibilityIdentifier="game.input"
        expressionView=FittingMathExpressionView(equation:equation,answer:answer);expressionView.fillsSurface=true
        expressionPanel.translatesAutoresizingMaskIntoConstraints=false;playing.addSubview(expressionPanel)
        expressionPanel.addSubview(expressionView)
        coinLabel=label("—",role:.catalogTrick);coinLabel.textAlignment = .right
        let coins=UIStackView();coins.axis = .horizontal;coins.alignment = .center;coins.spacing=4
        coinIcon.contentMode = .scaleAspectFit
        coins.addArrangedSubview(coinIcon);coins.addArrangedSubview(coinLabel)
        coins.translatesAutoresizingMaskIntoConstraints=false;expressionPanel.addSubview(coins)
        NSLayoutConstraint.activate([
            coinIcon.widthAnchor.constraint(equalToConstant:40),coinIcon.heightAnchor.constraint(equalToConstant:40),
            coins.topAnchor.constraint(equalTo:expressionPanel.topAnchor,constant:8),
            coins.trailingAnchor.constraint(equalTo:expressionPanel.trailingAnchor,constant:-16),
            expressionView.leadingAnchor.constraint(equalTo:expressionPanel.leadingAnchor),
            expressionView.trailingAnchor.constraint(equalTo:expressionPanel.trailingAnchor),
            expressionView.topAnchor.constraint(equalTo:expressionPanel.topAnchor),
            expressionView.bottomAnchor.constraint(equalTo:expressionPanel.bottomAnchor)
        ])
        change=button(CatalogText.ui("change_input"),icon:.changeInput,kind:.icon) { [weak self] in
            guard let self, CACurrentMediaTime() >= inputTransitionEnds else { return }
            perform { session,_ in session.changeInput();return GameMutation() }
        }
        voice=button(CatalogText.ui("speech"),icon:.sound,kind:.icon) { [weak self] in self?.cycleVoice() }
        replayVoice=button(CatalogText.ui("speech"),icon:.sound,kind:.icon) { [weak self] in
            guard let self,let session else{return};AppSpeech.shared.speak(session.example,settings:settings)
        }
        for item in [voice,replayVoice] {
            item!.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:32)
            item!.isHidden = !AppSpeech.isEnabled
            expressionPanel.addSubview(item!)
        }
        NSLayoutConstraint.activate([
            voice.trailingAnchor.constraint(equalTo:expressionPanel.trailingAnchor,constant:-8),voice.bottomAnchor.constraint(equalTo:expressionPanel.bottomAnchor,constant:-8),voice.widthAnchor.constraint(equalToConstant:44),
            replayVoice.trailingAnchor.constraint(equalTo:voice.leadingAnchor),replayVoice.bottomAnchor.constraint(equalTo:voice.bottomAnchor),replayVoice.widthAnchor.constraint(equalToConstant:44)
        ])
        inputModes.axis = .vertical;inputModes.spacing=0;inputModes.translatesAutoresizingMaskIntoConstraints=false
        inputModes.clipsToBounds = true
        digits.axis = .vertical;digits.distribution = .fillEqually;digits.spacing=0
        variants.axis = .vertical;variants.distribution = .fillEqually;variants.spacing=0
        let boolPanel=UIStackView();boolPanel.axis = .vertical;boolPanel.distribution = .fillEqually
        booleanProposal=label("",role:.expression);booleanProposal.textAlignment = .center
        booleanProposal.numberOfLines=1;booleanProposal.adjustsFontSizeToFitWidth=true;booleanProposal.minimumScaleFactor=0.3
        booleanProposal.isHidden=true;boolPanel.addArrangedSubview(booleanProposal)
        booleanSolution.translatesAutoresizingMaskIntoConstraints = false; booleanSolutionScroll.addSubview(booleanSolution)
        NSLayoutConstraint.activate([
            booleanSolution.leadingAnchor.constraint(equalTo: booleanSolutionScroll.contentLayoutGuide.leadingAnchor, constant: 8),
            booleanSolution.trailingAnchor.constraint(equalTo: booleanSolutionScroll.contentLayoutGuide.trailingAnchor, constant: -8),
            booleanSolution.topAnchor.constraint(equalTo: booleanSolutionScroll.contentLayoutGuide.topAnchor, constant: 8),
            booleanSolution.bottomAnchor.constraint(equalTo: booleanSolutionScroll.contentLayoutGuide.bottomAnchor, constant: -8),
            booleanSolution.widthAnchor.constraint(equalTo: booleanSolutionScroll.frameLayoutGuide.widthAnchor, constant: -16)
        ])
        boolPanel.addArrangedSubview(booleanSolutionScroll); booleanSolutionScroll.isHidden = true
        boolButtons.axis = .horizontal;boolButtons.distribution = .fillEqually
        boolPanel.addArrangedSubview(boolButtons)
        inputModes.addArrangedSubview(digits);inputModes.addArrangedSubview(variants);inputModes.addArrangedSubview(boolPanel)
        boolPanel.tag=104
        for value in [false,true] {
            let key=button(CatalogText.ui(value ? "true":"false"),icon:value ? .correct:.incorrect,kind:.keypadIcon) { [weak self] in
                self?.perform { session,now in try session.chooseBoolean(value,now:now) }
            }
            key.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:24)
            boolButtons.addArrangedSubview(key)
        }
        hint=button("",icon:.hint,kind:.dialog) { [weak self] in self?.showSolution() }
        skip=button("",icon:.skip,kind:.dialog) { [weak self] in
            self?.perform { session,now in try session.skip(now:now);return GameMutation() }
        }
        for item in [hint,skip] {
            item!.label.role = .gameUtility;item!.setContentSpacing(14)
            item!.label.numberOfLines=1
            item!.label.setContentCompressionResistancePriority(.required,for:.horizontal)
            item!.setContentInsets(UIEdgeInsets(top:10,left:20,bottom:10,right:20),minimumHeight:50)
            item!.setContentHuggingPriority(.required,for:.horizontal)
            let width=item!.widthAnchor.constraint(equalToConstant:94);width.isActive=true;utilityWidths.append(width)
        }
        change.setContentInsets(UIEdgeInsets(top:2,left:8,bottom:2,right:8),minimumHeight:40)
        utility.axis = .vertical;utility.spacing=0;utility.translatesAutoresizingMaskIntoConstraints=false
        utilityActions.axis = .horizontal;utilityActions.alignment = .center
        utilityActions.isLayoutMarginsRelativeArrangement = true
        utilityActions.directionalLayoutMargins = NSDirectionalEdgeInsets(top:0,leading:2,bottom:0,trailing:2)
        trickName=label("",role:.catalogTrick);trickName.textAlignment = .center
        ruleScroll.translatesAutoresizingMaskIntoConstraints=false
        trickName.translatesAutoresizingMaskIntoConstraints=false;ruleScroll.addSubview(trickName)
        NSLayoutConstraint.activate([
            trickName.leadingAnchor.constraint(equalTo:ruleScroll.contentLayoutGuide.leadingAnchor,constant:5),
            trickName.trailingAnchor.constraint(equalTo:ruleScroll.contentLayoutGuide.trailingAnchor,constant:-5),
            trickName.topAnchor.constraint(equalTo:ruleScroll.contentLayoutGuide.topAnchor),
            trickName.bottomAnchor.constraint(equalTo:ruleScroll.contentLayoutGuide.bottomAnchor),
            trickName.widthAnchor.constraint(equalTo:ruleScroll.frameLayoutGuide.widthAnchor,constant:-10),
            trickName.heightAnchor.constraint(greaterThanOrEqualTo:ruleScroll.frameLayoutGuide.heightAnchor)
        ])
        ruleScroll.tag=105
        utility.addArrangedSubview(timerBar);utility.addArrangedSubview(utilityActions);utility.addArrangedSubview(ruleScroll)
        move=button(CatalogText.ui("change_input"),icon:.forward,kind:.iconSurface) { [weak self] in self?.moveKeypad() }
        move.setContentInsets(UIEdgeInsets(top:15,left:15,bottom:15,right:15),minimumHeight:44.5)
        NSLayoutConstraint.activate([move.widthAnchor.constraint(equalToConstant:45),move.heightAnchor.constraint(equalToConstant:44.5)])
        moveRow.axis = .horizontal; moveRow.alignment = .center
        moveRow.isLayoutMarginsRelativeArrangement = true
        moveRow.directionalLayoutMargins = NSDirectionalEdgeInsets(top:0,leading:10,bottom:10,trailing:10)
        lowerPanel.axis = .horizontal;lowerPanel.spacing=0;lowerPanel.translatesAutoresizingMaskIntoConstraints=false
        playing.addSubview(lowerPanel);playing.addSubview(utility)
        resume=button(CatalogText.ui("resume")) { [weak self] in self?.resumePlaying() }
        playing.addSubview(resume)
        NSLayoutConstraint.activate([
            resume.centerXAnchor.constraint(equalTo:playing.centerXAnchor),resume.centerYAnchor.constraint(equalTo:playing.centerYAnchor),
            resume.widthAnchor.constraint(lessThanOrEqualTo:playing.widthAnchor,multiplier:0.8)
        ])
        resultScroll.isHidden = true
        resultScroll.translatesAutoresizingMaskIntoConstraints=false;body.addSubview(resultScroll)
        NSLayoutConstraint.activate([resultScroll.topAnchor.constraint(equalTo:body.topAnchor),resultScroll.bottomAnchor.constraint(equalTo:body.bottomAnchor),resultScroll.leadingAnchor.constraint(equalTo:body.leadingAnchor),resultScroll.trailingAnchor.constraint(equalTo:body.trailingAnchor)])
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: RunLoop.main).sink { [weak self] _ in self?.suspendForBackground() }.store(in: &observations)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: RunLoop.main).sink { [weak self] _ in self?.sceneActive = true; self?.scheduleSolutionAnswer(); self?.render() }.store(in: &observations)
    }
    private func buildResultsIfNeeded() {
        guard !hasBuiltResults else { return }
        hasBuiltResults = true
        ResultUI.pin(resultTable,in:resultScroll)
        resultTable.onQuestion = { [weak self] question in guard let self else{return};resultDetails.show(question,settings:settings) }
        resultTable.onTrick = { [weak self] key in guard let self,let session else{return};router?.showResultTrick(session:session,key:key) }
        resultTable.onBack = { [weak self] in self?.router?.goBack(confirmed:true) }
        resultTable.onRetry = { [weak self] in self?.startNew() }
        resultTable.onNext = { [weak self] in self?.startNextLevel() }
        resultTable.onShare = { [weak self] in self?.shareResult() }
        resultTable.onLeaderboard = { [weak self] in
            guard let self,let session else {return}
            router?.show(.gameLeaderboard(session.configuration.mode,selected:session.configuration.selectedTricks))
        }
    }
    override func applyAppearance() {
        super.applyAppearance()
        applyHeaderTextColors()
        coinLabel?.textColor = palette.text; coinIcon.tintColor = palette.accent
    }
    private func applyHeaderTextColors() {
        let headColor = palette.headerText
        for item in [levelLabel,status,scoreLabel] { item?.textColor = headColor }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyHeaderTextColors()
        if session?.phase == .ready { session?.resume(now: now); render() }
    }
    override func update(_ progress: ProgressState?) {
        if !settings.soundEnabled || (settings.speechMode ?? 0) == 0 { AppSpeech.shared.stop() }
        if lastNumpad != settings.numpad123 { rebuildDigits() }
        timerBar.apply(settings:appearanceSettings)
        expressionView.apply(settings:appearanceSettings)
        view.setNeedsLayout()
        render()
    }
    private func rebuildDigits() {
        lastNumpad = settings.numpad123
        let old = digits.arrangedSubviews
        for row in old {
            if let stack = row as? UIStackView { themedButtons.removeAll { button in stack.arrangedSubviews.contains { $0 === button } } }
            digits.removeArrangedSubview(row); row.removeFromSuperview()
        }
        let order = settings.numpad123 ? [[1,2,3],[4,5,6],[7,8,9]] : [[7,8,9],[4,5,6],[1,2,3]]
        for numbers in order + [[0,-1]] {
            let row = UIStackView(); row.axis = .horizontal; row.distribution = .fillEqually
            for number in numbers {
                let key: AppButton
                if number >= 0 {
                    key = button(String(number), kind: .keypad) { [weak self] in
                        self?.perform { session, now in try session.appendDigit(number, now: now) }
                    }
                    key.accessibilityIdentifier = "game.digit.\(number)"
                } else {
                    key = button(MainText.text("backspace"), icon: .backspace, kind: .keypadIcon) { [weak self] in
                        self?.perform { session, _ in session.deleteDigit(); return GameMutation() }
                    }
                    key.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(clearInput(_:))))
                }
                row.addArrangedSubview(key)
            }
            for case let key as AppButton in row.arrangedSubviews {key.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:24)}
            digits.addArrangedSubview(row)
        }
    }
    @objc private func clearInput(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        perform { session, _ in
            session.deleteDigit(clear: true)
            AppFeedback.shared.haptic(.correct)
            return GameMutation()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let landscape=view.bounds.width>view.bounds.height
        if layoutLandscape != landscape || layoutKeypadRight != settings.keypadOnRight { rebuildLayout(landscape:landscape) }
        // Android gives approximately half the whole game area to the keyboard.
        let available=max(0,body.bounds.height)
        lowerHeight?.constant = min(available * 0.72,max(available * 0.45,(available+header.bounds.height)*0.5))
    }
    private func rebuildLayout(landscape:Bool) {
        layoutLandscape=landscape;layoutKeypadRight=settings.keypadOnRight
        headerInformation.axis=landscape ? .horizontal:.vertical
        headerInformation.distribution=landscape ? .fillEqually:.fill
        headerInformation.alignment=landscape ? .center:.leading
        for item in [levelLabel,status] {item?.textAlignment=landscape ? .center:.left}
        scoreLabel.textAlignment=landscape ? .center:.left
        headerBalance?.isActive=false
        headerBalance=headerInformation.widthAnchor.constraint(equalTo:scoreLabel.widthAnchor,multiplier:landscape ? 2:1)
        headerBalance?.priority = .init(999);headerBalance?.isActive = !scoreLabel.isHidden
        NSLayoutConstraint.deactivate(layoutConstraints);layoutConstraints=[]
        utility.removeArrangedSubview(ruleScroll);utilityActions.removeArrangedSubview(ruleScroll);ruleScroll.removeFromSuperview()
        utility.removeArrangedSubview(moveRow);moveRow.removeFromSuperview()
        for item in moveRow.arrangedSubviews {moveRow.removeArrangedSubview(item);item.removeFromSuperview()}
        for stack in [lowerPanel,utilityActions] { for view in stack.arrangedSubviews {stack.removeArrangedSubview(view);view.removeFromSuperview()} }
        change.removeFromSuperview();utility.removeFromSuperview();playing.addSubview(utility)
        utilityActions.addArrangedSubview(skip)
        if !landscape {
            utilityActions.addArrangedSubview(ruleScroll)
            layoutConstraints.append(ruleScroll.heightAnchor.constraint(equalToConstant:50))
            utilityActions.addArrangedSubview(hint)
            expressionPanel.addSubview(change)
            layoutConstraints += [change.leadingAnchor.constraint(equalTo:expressionPanel.leadingAnchor,constant:8),change.bottomAnchor.constraint(equalTo:expressionPanel.bottomAnchor,constant:-8)]
            lowerPanel.addArrangedSubview(inputModes)
        } else {
            utility.insertArrangedSubview(ruleScroll,at:2)
            utilityActions.insertArrangedSubview(change,at:0)
            utilityActions.insertArrangedSubview(UIView(),at:1);utilityActions.addArrangedSubview(hint)
            if settings.keypadOnRight == true { lowerPanel.addArrangedSubview(utility);lowerPanel.addArrangedSubview(inputModes) }
            else {lowerPanel.addArrangedSubview(inputModes);lowerPanel.addArrangedSubview(utility)}
            layoutConstraints.append(inputModes.widthAnchor.constraint(equalTo:lowerPanel.widthAnchor,multiplier:11.0/21))
            let keypadOnRight = settings.keypadOnRight == true
            move.setIcon(keypadOnRight ? .backward : .forward)
            if keypadOnRight { moveRow.addArrangedSubview(UIView());moveRow.addArrangedSubview(move) }
            else { moveRow.addArrangedSubview(move);moveRow.addArrangedSubview(UIView()) }
            utility.addArrangedSubview(moveRow)
        }
        layoutConstraints += [expressionPanel.topAnchor.constraint(equalTo:playing.topAnchor),expressionPanel.leadingAnchor.constraint(equalTo:playing.leadingAnchor),expressionPanel.trailingAnchor.constraint(equalTo:playing.trailingAnchor),
            lowerPanel.leadingAnchor.constraint(equalTo:playing.leadingAnchor),lowerPanel.trailingAnchor.constraint(equalTo:playing.trailingAnchor),lowerPanel.bottomAnchor.constraint(equalTo:playing.bottomAnchor)]
        let height=lowerPanel.heightAnchor.constraint(equalToConstant:body.bounds.height*0.5);height.priority = .init(999);lowerHeight=height;layoutConstraints.append(height)
        if landscape {
            layoutConstraints.append(expressionPanel.bottomAnchor.constraint(equalTo:lowerPanel.topAnchor))
        } else {
            layoutConstraints += [utility.topAnchor.constraint(equalTo:expressionPanel.bottomAnchor),utility.leadingAnchor.constraint(equalTo:playing.leadingAnchor),utility.trailingAnchor.constraint(equalTo:playing.trailingAnchor),utility.bottomAnchor.constraint(equalTo:lowerPanel.topAnchor)]
        }
        NSLayoutConstraint.activate(layoutConstraints)
    }
    private func moveKeypad() {
        Task { [weak self] in
            guard let self else{return}
            do {try await data.updateSettings(.keypadOnRight(!(settings.keypadOnRight ?? false)));view.setNeedsLayout()}
            catch {showError(error)}
        }
    }
    private func cycleVoice() {
        perform{session,_ in session.markInputChanged();return GameMutation()}
        Task { [weak self] in
            guard let self else{return}
            do {try await data.updateSettings(.speechMode(((settings.speechMode ?? 0)+1)%3));if let session {AppSpeech.shared.speak(session.example,settings:settings)}}
            catch {showError(error)}
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated); isVisible = true
        resultDetails.restore(settings:settings)
        if pendingSolutionAnswer != nil { scheduleSolutionAnswer() }
        else if session?.phase == .solution {
            session?.closeSolution(now: now, answerWasRevealed: true)
            persist(GameMutation())
        }
        if session?.phase == .ready || session?.phase == .running { resumePlaying() }
        startTimer()
        render()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated); isVisible = false; queuedInput.removeAll()
        solutionAnswerTask?.cancel(); solutionAnswerTask = nil
        AppSpeech.shared.stop()
        timer?.invalidate(); timer = nil
        if session?.phase == .running { session?.pause(now: now); savePaused() }
    }
    private var now: TimeInterval { ProcessInfo.processInfo.systemUptime }
    func prepareForPresentation() async throws {
        if var configuration {
            configuration.inputMode = data.snapshot?.settings.gameInputMode ?? .digits
            configuration.progressGeneration = data.snapshot?.generation
            session = try GameSession(configuration: configuration)
            if let session { try await data.saveGameSession(session) }
        } else { session = try await data.resumableGameSession() }
        try Task.checkCancellation()
        guard session != nil else { throw ProgressError.invalidState }
        loadViewIfNeeded()
        render()
    }
    private func startNew() {
        guard !saving,pending == nil else{return}
        guard let config = session?.configuration else { return }
        session = nil
        do { session = try GameSession(configuration: config); resumePlaying() }
        catch { showError(error) }
    }
    private func startNextLevel() {
        guard !saving, pending == nil, let value = session, value.completed else { return }
        let previous = value.configuration
        let byHeart = previous.mode == .byHeart
        let number = byHeart ? previous.multiplicationLevel ?? 21 : previous.difficulty
        guard [.training,.byHeart].contains(previous.mode), number < (byHeart ? 21 : 100) else { return }
        let next = GameConfiguration(mode: previous.mode, difficulty: byHeart ? previous.difficulty : number + 1,
            trickIDs: previous.trickIDs, selectedTricks: previous.selectedTricks,
            exampleCount: byHeart && number + 1 == 21 ? 50 : previous.exampleCount,
            multiplicationNumber: previous.multiplicationNumber,
            multiplicationLevel: byHeart ? number + 1 : previous.multiplicationLevel,
            inputMode: settings.gameInputMode, progressGeneration: data.snapshot?.generation)
        do { session = try GameSession(configuration: next); resumePlaying() }
        catch { showError(error) }
    }
    private func resumePlaying() {
        guard !saving, pending == nil, sceneActive, isVisible || view.window != nil else { return }
        session?.resume(now: now); render(); startTimer()
        if let session, lastSpokenSignature != session.example.signature {
            AppSpeech.shared.speak(session.example,settings:settings); lastSpokenSignature=session.example.signature
        }
    }
    private func startTimer() {
        guard timer == nil, isVisible, session?.phase == .running else { return }
        let timer = Timer(timeInterval: 0.05, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common); self.timer = timer
    }
    @objc private func tick() {
        guard !saving, pending == nil, sceneActive, var value = session, value.phase == .running else { return }
        let previous = value.phase; let previousStars = value.stars
        value.tick(now: now); session = value
        if value.stars < previousStars { AppFeedback.shared.play(.starLost); AppFeedback.shared.haptic(.timerEnd) }
        if value.phase != previous { AppFeedback.shared.play(.timerEnd); AppFeedback.shared.haptic(.timerEnd); persist(GameMutation()) }
        render()
    }
    private func perform(_ action: @escaping (inout GameSession, TimeInterval) throws -> GameMutation) {
        guard sceneActive, isVisible, let current = session else { return }
        if saving || pending != nil {
            if pending != nil, !current.isTerminal, queuedInput.count < 32 {
                queuedInput.append(QueuedInput(signature: current.example.signature, mode: current.inputMode, action: action))
            }
            return
        }
        guard var value = session, value.phase == .running else { return }
        do {
            let previousExample=value.example
            let previousInput=value.inputMode
            let mutation = try action(&value, now)
            session = value
            if value.inputMode != previousInput {
                animateInputModeChange()
                let mode=value.inputMode
                Task { [weak self] in guard let self else {return};do{try await data.updateSettings(.gameInputMode(mode))}catch{showError(error)} }
            }
            if mutation.correct {
                AppSpeech.shared.accepted(previous:previousExample,next:value.isTerminal ? nil : value.example,settings:settings)
                lastSpokenSignature=value.example.signature
            }
            if mutation.correct { AppFeedback.shared.play(mutation.levelCompleted ? .levelComplete : .solution); AppFeedback.shared.haptic(mutation.levelCompleted ? .levelComplete : .correct) }
            else if mutation.wrong && (mutation.coinDelta < 0 || settings.signalWrongAnswer) {
                AppFeedback.shared.play(mutation.coinDelta < 0 ? .wrong:.error,volume:mutation.coinDelta < 0 ? 1:0.15)
                AppFeedback.shared.haptic(mutation.coinDelta < 0 ? .wrong : .inputError)
                if mutation.coinDelta == 0 {
                    let shake=CAKeyframeAnimation(keyPath:"transform.translation.x");shake.values=[0,5,-5,5,-5,0];shake.duration=0.24;answer.layer.add(shake,forKey:"wrongAnswer")
                }
            }
            else { AppFeedback.shared.play(value.inputMode != previousInput ? .switchNumpad : .keypress) }
            if mutation.correct || mutation.coinDelta != 0 || value.isTerminal || value.inputMode != .digits || value.input.isEmpty {
                persist(mutation)
            } else { render() }
        } catch { showError(error) }
    }
    private func animateInputModeChange() {
        guard view.window != nil, !UIAccessibility.isReduceMotionEnabled else { return }
        inputTransitionEnds = CACurrentMediaTime() + 0.1
        let transition = CATransition()
        transition.type = .push; transition.subtype = .fromRight
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        inputModes.layer.add(transition,forKey:"inputModeChange")
    }
    private func persist(_ mutation: GameMutation, completion: (() -> Void)? = nil) {
        guard var value = session, pending == nil else { return }
        value.pause(now: now); session = value
        pending = (value, mutation, completion)
        retrySave()
    }
    private func retrySave() {
        guard !saving, let pending else { return }
        saving = true; render()
        Task { [weak self] in
            guard let self else { return }
            do {
                try await data.commitGameSession(pending.session, mutation: pending.mutation)
                saving = false; self.pending = nil
                if sceneActive && isVisible && session?.phase == .paused { session?.resume(now: now); startTimer() }
                render(); pending.completion?(); endBackgroundSave(); drainQueuedInput()
            } catch {
                saving = false; render(); endBackgroundSave()
                showError(error, retry: { [weak self] in self?.retrySave() })
            }
        }
    }
    private func savePaused(completion: (() -> Void)? = nil) {
        guard let session, pending == nil, !saving else { return }
        saving = true
        Task { [weak self] in
            guard let self else { return }
            do { try await data.saveGameSession(session); saving = false; render(); completion?(); endBackgroundSave() }
            catch { saving = false; endBackgroundSave(); showError(error, retry: { [weak self] in self?.savePaused(completion: completion) }) }
        }
    }
    private func suspendForBackground() {
        sceneActive = false; queuedInput.removeAll()
        if backgroundSave == .invalid {
            backgroundSave = UIApplication.shared.beginBackgroundTask(withName: "SaveMathTricksProgress") { [weak self] in
                self?.endBackgroundSave()
            }
        }
        AppSpeech.shared.stop()
        session?.pause(now: now); timer?.invalidate(); timer = nil
        savePaused(); render()
        if !saving && pending == nil { endBackgroundSave() }
    }
    private func endBackgroundSave() {
        guard backgroundSave != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundSave); backgroundSave = .invalid
    }
    private func drainQueuedInput() {
        while !saving, pending == nil, sceneActive, isVisible, !queuedInput.isEmpty {
            let next = queuedInput.removeFirst()
            guard let session, session.phase == .running else { queuedInput.removeAll(); return }
            if session.example.signature == next.signature && session.inputMode == next.mode { perform(next.action) }
        }
    }
    private let exitConfirmation = ExitConfirmation()
    func requestBack() {
        guard pendingSolutionAnswer == nil else { return }
        guard let value = session, !value.isTerminal else { router?.goBack(confirmed: true); return }
        guard !saving, pending == nil, presentedViewController == nil else { return }
        exitConfirmation.request(from: self, data: data, onExit: { [weak self] in
            guard let self else { return }
            let showScore = session?.configuration.mode == .noTime && !(session?.attempts.isEmpty ?? true)
            leavingWithoutResults = !showScore
            session?.finish(completed: false)
            persist(GameMutation()) { [weak self] in
                if !showScore { self?.router?.goBack(confirmed: true) }
            }
        }, onShow: { self.session?.pause(now: self.now); AppSpeech.shared.stop(); self.render() }, onStay: { [weak self] in self?.resumePlaying() })
    }
    var solutionStepHintsRemaining: Int { session?.solutionStepHintsRemaining ?? 0 }
    func consumeSolutionStepHint() -> Bool { session?.consumeSolutionStepHint() ?? false }
    var solutionAllHintsRemaining: Int { session?.solutionAllHintsRemaining ?? 0 }
    func consumeSolutionAllHint() -> Bool { session?.consumeSolutionAllHint() ?? false }
    func continueFromSolution(_ example: MathExample) {
        guard session?.phase == .solution, session?.example.signature == example.signature, pendingSolutionAnswer == nil else { return }
        pendingSolutionAnswer = example.signature; session?.showSolutionAnswer()
        router?.goBack(confirmed: true)
    }
    private func scheduleSolutionAnswer() {
        guard let signature = pendingSolutionAnswer, solutionAnswerTask == nil, isVisible, sceneActive, !saving, pending == nil else { return }
        solutionAnswerTask = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: 500_000_000) } catch { return }
            guard let self else { return }
            solutionAnswerTask = nil
            guard isVisible, sceneActive, pendingSolutionAnswer == signature,
                  session?.example.signature == signature, !saving, pending == nil else { return }
            do {
                let mutation = try session?.acceptSolutionAnswer(now: now) ?? GameMutation()
                if mutation.correct { AppFeedback.shared.haptic(mutation.levelCompleted ? .levelComplete : .correct) }
                pendingSolutionAnswer = nil
                persist(mutation) { [weak self] in
                    guard let self, isVisible, sceneActive, session?.isTerminal == false else { return }; resumePlaying()
                }
            } catch { showError(error) }
        }
    }
    private func showSolution() {
        AppSpeech.shared.stop()
        guard !saving, pending == nil, session?.revealSolution(now: now) == true, let example = session?.example else { return }
        let route: AppRoute
        if let configuration=session?.configuration, configuration.mode == .byHeart,
           let number=configuration.multiplicationNumber, let level=configuration.multiplicationLevel {
            route = .byHeartHint(number:number,level:level,example:example)
        } else { route = .solution(example) }
        persist(GameMutation()) { [weak self] in self?.router?.show(route) }
    }
    private func render() {
        guard isViewLoaded, status != nil else { return }
        if leavingWithoutResults {
            resultScroll.isHidden = true
            resume.isHidden = true
            themedButtons.forEach { $0.isEnabled = false }
            return
        }
        applyHeaderTextColors()
        if pendingSolutionAnswer != nil { scheduleSolutionAnswer() }
        let enabled = session?.phase == .running && !saving && pending == nil && sceneActive
        let acceptsInput = enabled || (pending != nil && session?.isTerminal == false && sceneActive && isVisible)
        themedButtons.filter { $0 !== hint && $0 !== skip }.forEach { $0.isEnabled = acceptsInput }
        resume.isHidden = (session?.phase != .paused && session?.phase != .ready) || saving || pending != nil
        resume.isEnabled = !saving && pending == nil && sceneActive
        let finished=session?.phase == .finished
        if finished { buildResultsIfNeeded() }
        resultScroll.isHidden = !finished
        playing.isHidden=finished
        if header.isHidden != finished {setHeaderHidden(finished)}
        guard let session else { return }
        let groupID=TrickCatalog.shared.trick(session.example.trickID)?.groupID
        if catalogCategoryID != groupID {
            catalogCategoryID=groupID
            timerBar.apply(settings:appearanceSettings);expressionView.apply(settings:appearanceSettings)
        }
        if session.isTerminal { timer?.invalidate(); timer = nil }
        timerBar.isHidden = [.noTime, .speed].contains(session.configuration.mode)
        if session.configuration.mode == .daily, let daily=data.snapshot?.daily {
            timerBar.setProgress(Float(min(1,Double(daily.solved)/Double(max(1,daily.target)))),animated:false)
        } else { timerBar.setProgress(Float(session.timerFraction), animated: false) }
        let score = session.configuration.mode == .speed ? String(format:"%.1f",locale:Locale.current,session.resultValue) : String(session.score)
        levelLabel.isHidden = session.configuration.mode == .speed
        scoreLabel.isHidden = session.configuration.mode == .daily
        headerBalance?.isActive = !scoreLabel.isHidden
        levelLabel.text=MainText.format("activity_game_tv_level",String(session.level))
        status.text=MainText.format("activity_game_tv_examples","\(session.levelSolved)/\(session.target)")
        scoreLabel.text=MainText.text(session.configuration.mode == .speed ? "activity_game_time_tv_score" : "activity_game_tv_score")+" "+score
        starImage.isHidden = ![.training,.byHeart].contains(session.configuration.mode)
        starImage.image = palette.gameStars(session.stars)
        starImage.accessibilityLabel = "\(session.stars)/3"
        coinLabel.text=data.snapshot?.coins.description ?? "—"
        coinLabel.textColor = palette.text; coinIcon.tintColor = palette.accent
        if session.configuration.mode == .daily,let daily=data.snapshot?.daily {status.text="\(daily.solved)/\(daily.target)"}
        trickName.text=TrickCatalog.shared.trick(session.example.trickID).map {AndroidRichText.plain(CatalogText.text($0.nameKey))} ?? ""
        let speechMode = AppSpeech.isEnabled ? (settings.speechMode ?? 0) : 0
        equation.text=(speechMode==1 ? "":MathExpressionFormatter.text(session.example).replacingOccurrences(of:" ",with:""))+"="
        answer.text=session.input.isEmpty ? "?":session.input
        if session.inputMode == .boolean {answer.text=speechMode==1 ? "?":String(session.proposedAnswer)}
        booleanProposal.text=String(session.proposedAnswer)
        expressionView.setNeedsLayout()
        expressionView.animateNewExample(id:"\(session.id):\(session.solved):\(session.skipsRemaining):\(session.example.signature)")
        voice.setIcon((settings.speechMode ?? 0)==0 ? .voiceOn:settings.speechMode==1 ? .voiceBoth:.voiceOff)
        voice.alpha=1
        voice.isHidden = !AppSpeech.isEnabled
        replayVoice.isHidden = !AppSpeech.isEnabled || speechMode==0
        if session.phase == .finished {
            resultTable.configure(session:session,settings:settings,coins:data.snapshot?.coins);resultTable.setActionsEnabled(!saving && pending == nil)
            if [.training,.byHeart].contains(session.configuration.mode),resultHistoryID != session.id {
                resultHistoryID=session.id;resultReadTask?.cancel()
                resultReadTask=Task{[weak self] in
                    guard let self else{return}
                    do {let statistics=try await data.practiceStatistics();if !Task.isCancelled,resultHistoryID==session.id {resultTable.setStatistics(statistics)}}
                    catch {if !Task.isCancelled {resultHistoryID=nil;showError(error,reading:true)}}
                }
            }
        }

        digits.isHidden = session.inputMode != .digits || session.isTerminal
        variants.isHidden = session.inputMode != .choices || session.isTerminal
        inputModes.arrangedSubviews.first(where:{$0.tag==104})?.isHidden = session.inputMode != .boolean || session.isTerminal
        hint.label.text = String(session.hintsRemaining); hint.accessibilityLabel=CatalogText.ui("hint")+" \(session.hintsRemaining)"; hint.isEnabled = session.hintsRemaining > 0; hint.isUserInteractionEnabled = enabled
        for (index,item) in [hint,skip].enumerated() {
            let count=index == 0 ? session.hintsRemaining:session.skipsRemaining
            let textWidth=ceil((String(count) as NSString).size(withAttributes:[.font:item!.label.font!]).width)
            utilityWidths[index].constant=40+14+min(40,(index == 0 ? AppIcon.hint:AppIcon.skip).image?.size.width ?? 24)+textWidth
        }
        skip.label.text = String(session.skipsRemaining); skip.accessibilityLabel=CatalogText.ui("skip")+" \(session.skipsRemaining)"; skip.isEnabled = session.skipsRemaining > 0; skip.isUserInteractionEnabled = enabled
        if lastChoices != session.choices { rebuildChoices(session.choices) }
        for (index, button) in choiceButtons.enumerated() {
            let rejected = (session.rejectedChoices ?? []).contains(session.choices[index])
            button.isEnabled = acceptsInput && !rejected
            button.label.text = rejected ? "×" : String(session.choices[index])
        }
        for (index, button) in boolButtons.arrangedSubviews.enumerated() {
            button.isUserInteractionEnabled = acceptsInput && session.rejectedBoolean != (index == 1)
            (button as? AppButton)?.isEnabled = button.isUserInteractionEnabled
        }
        booleanSolutionScroll.isHidden = false
        if booleanSolution.configure(example: session.example, settings: appearanceSettings,
                                     showing: session.inputMode == .boolean && session.rejectedBoolean != nil) {
            booleanSolutionScroll.setContentOffset(.zero, animated: false)
        }
        move.isEnabled=true
    }
    private func shareResult() {
        guard presentedViewController == nil,let session,let content=ResultShareCard.session(session,statistics:resultTable.resultStatistics,settings:settings) else{return}
        let sheet=UIActivityViewController(activityItems:[content.image,content.text],applicationActivities:nil)
        sheet.popoverPresentationController?.sourceView=resultTable;sheet.popoverPresentationController?.sourceRect=CGRect(x:resultTable.bounds.midX,y:resultTable.bounds.maxY,width:1,height:1)
        present(sheet,animated:false)
    }
    private func rebuildChoices(_ choices: [Int64]) {
        themedButtons.removeAll { choiceButtons.contains($0) }; choiceButtons.removeAll()
        variants.arrangedSubviews.forEach { variants.removeArrangedSubview($0); $0.removeFromSuperview() }
        lastChoices = choices
        for pair in stride(from: 0, to: choices.count, by: 2) {
            let row = UIStackView(); row.axis = .horizontal; row.distribution = .fillEqually
            for index in pair..<min(pair + 2, choices.count) {
                let value = choices[index]
                let button = button(String(value), kind: .keypad) { [weak self] in
                    self?.perform { session, now in try session.choose(value, now: now) }
                }
                button.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:24)
                choiceButtons.append(button); row.addArrangedSubview(button)
            }
            variants.addArrangedSubview(row)
        }
    }
}
