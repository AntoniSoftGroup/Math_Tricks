import UIKit
import Combine

final class MultiplayerViewController: ThemedViewController, AppBackHandling {
    private let configuration: MultiplayerConfiguration?
    private var session: MultiplayerSession?
    private let boards = [PlayerInputBoard(),PlayerInputBoard()]
    private let row = UIStackView()
    private let duoRow = AppDuoSplitView()
    private let duoResults = AppDuoSplitView()
    private var usesDuoPanes = false
    private let middle = UIStackView()
    private let gameColumn = UIStackView()
    private var initiallyStarted=false
    private var boardHosts:[UIStackView]=[]
    private let resultRow=UIStackView()
    private var resultPanels:[MultiplayerResultPanel]=[]
    private var boardEquality:NSLayoutConstraint?
    private var landscapeLayout:Bool?
    private let bar = MultiplayerProgressView()
    private var status: AppLabel!
    private var resume: AppButton!
    private var backgroundSave: UIBackgroundTaskIdentifier = .invalid
    private var timer: Timer?
    private var active = true
    private var visible = false
    private var saving = false
    private var pending: (MultiplayerSession,GameMutation)?
    private var queue: [(Int,String,PlayerAction)] = []
    private var observations = Set<AnyCancellable>()
    init(configuration: MultiplayerConfiguration?, router: AppRouter, data: AppDataStore) {
        self.configuration = configuration
        super.init(title: AppRoute.multiplayer.title, router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { timer?.invalidate() }
    private var now: TimeInterval { ProcessInfo.processInfo.systemUptime }
    override func buildContent() {
        view.accessibilityIdentifier = "screen.multiplayerGame"
        setHeaderHidden(true)
        let column=gameColumn;column.axis = .vertical; column.translatesAutoresizingMaskIntoConstraints = false
        body.addSubview(column)
        status = label("—", role: .caption); status.textAlignment = .center
        body.accessibilityCustomActions = [UIAccessibilityCustomAction(name: CatalogText.ui("back"),actionHandler: { [weak self] _ in self?.requestBack(); return true })]
        status.isHidden=true
        middle.axis = .vertical;middle.spacing=0;middle.addArrangedSubview(bar)
        bar.heightAnchor.constraint(equalToConstant:5).isActive=true
        row.axis = .vertical; row.distribution = .fill; row.spacing = 0
        for index in boards.indices {
            let host = UIStackView();host.axis = .vertical
            let board = boards[index];host.addArrangedSubview(board)
            boardHosts.append(host)
            board.onAction = { [weak self] action in self?.receive(index,action) }
            if index == 0 { board.onBack = { [weak self] in self?.requestBack() } }
        }
        column.addArrangedSubview(row)
        column.addArrangedSubview(duoRow); duoRow.isHidden = true
        duoRow.onArrangementChange = { [weak self] in self?.view.setNeedsLayout() }
        resume = button(CatalogText.ui("resume"), kind: .compact) { [weak self] in self?.resumeGame() }
        resume.isHidden=true
        column.addArrangedSubview(resume)
        resultRow.distribution = .fillEqually;resultRow.axis = .vertical;resultRow.isHidden=true
        for player in [1,0] {
            let panel = MultiplayerResultPanel(player:player)
            panel.onRetry = { [weak self] in self?.newGame() }
            panel.onExit = { [weak self] in self?.router?.goBack(confirmed:true) }
            resultPanels.append(panel);resultRow.addArrangedSubview(panel)
        }
        duoResults.translatesAutoresizingMaskIntoConstraints = false; body.addSubview(duoResults); duoResults.isHidden = true
        NSLayoutConstraint.activate([
            duoResults.topAnchor.constraint(equalTo:body.topAnchor), duoResults.bottomAnchor.constraint(equalTo:body.bottomAnchor),
            duoResults.leadingAnchor.constraint(equalTo:body.leadingAnchor), duoResults.trailingAnchor.constraint(equalTo:body.trailingAnchor)
        ])
        resultRow.translatesAutoresizingMaskIntoConstraints=false;body.addSubview(resultRow)
        NSLayoutConstraint.activate([resultRow.topAnchor.constraint(equalTo:body.topAnchor),resultRow.bottomAnchor.constraint(equalTo:body.bottomAnchor),resultRow.leadingAnchor.constraint(equalTo:body.leadingAnchor),resultRow.trailingAnchor.constraint(equalTo:body.trailingAnchor)])
        NSLayoutConstraint.activate([column.topAnchor.constraint(equalTo: body.topAnchor),column.bottomAnchor.constraint(equalTo: body.bottomAnchor),column.leadingAnchor.constraint(equalTo: body.leadingAnchor),column.trailingAnchor.constraint(equalTo: body.trailingAnchor)])
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).receive(on: RunLoop.main).sink { [weak self] _ in self?.background() }.store(in: &observations)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).receive(on: RunLoop.main).sink { [weak self] _ in self?.active = true; self?.render() }.store(in: &observations)
    }
    func prepareForPresentation() async throws {
        if let configuration { session = try MultiplayerSession(configuration: configuration) }
        else { session = try await data.resumableMultiplayerSession() }
        if let session { try await data.saveMultiplayerSession(session) }
        try Task.checkCancellation()
        guard session != nil else { throw ProgressError.invalidState }
        loadViewIfNeeded()
        render()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if configuration != nil, !initiallyStarted, session != nil {
            initiallyStarted = true; session?.resume(now: now); render()
        }
    }
    override func update(_ progress: ProgressState?) { render() }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        synchronizeDuoPanes()
        if usesDuoPanes {
            duoRow.synchronizeArrangement(); duoResults.synchronizeArrangement()
            duoResults.isHidden = resultRow.isHidden
            duoRow.axis = duoRow.isHorizontal == true ? .horizontal : .vertical
            boards[1].transform = CGAffineTransform(rotationAngle:.pi)
            return
        }
        let landscape=view.bounds.width>view.bounds.height
        if landscapeLayout != landscape {
            landscapeLayout=landscape;boardEquality?.isActive=false
            for item in row.arrangedSubviews {row.removeArrangedSubview(item);item.removeFromSuperview()}
            row.axis=landscape ? .horizontal:.vertical
            gameColumn.removeArrangedSubview(middle)
            boardHosts[0].removeArrangedSubview(middle);middle.removeFromSuperview()
            row.addArrangedSubview(boardHosts[1])
            if landscape {boardHosts[0].insertArrangedSubview(middle,at:0)} else {row.addArrangedSubview(middle)}
            resultRow.axis = .vertical
            row.addArrangedSubview(boardHosts[0])
            boardEquality=landscape ? boardHosts[0].widthAnchor.constraint(equalTo:boardHosts[1].widthAnchor):boardHosts[0].heightAnchor.constraint(equalTo:boardHosts[1].heightAnchor)
            boardEquality?.isActive=true
            middle.axis = .vertical
            status.isHidden=true
        }
        boards[1].transform = CGAffineTransform(rotationAngle:.pi)
    }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); visible = true;startTimer();render() }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated); visible = false; queue.removeAll(); session?.pause(now: now); timer?.invalidate(); timer = nil; savePaused()
    }
    private func synchronizeDuoPanes() {
        let shouldUse = AppDuoGameArrangement.canUse(in: body)
        guard shouldUse != usesDuoPanes else { return }
        usesDuoPanes = shouldUse
        boardEquality?.isActive = false
        landscapeLayout = nil
        if shouldUse {
            for host in boardHosts { row.removeArrangedSubview(host); host.removeFromSuperview() }
            row.removeArrangedSubview(middle)
            boardHosts[0].removeArrangedSubview(middle); middle.removeFromSuperview()
            boardHosts[0].insertArrangedSubview(middle, at: 0)
            duoRow.addArrangedSubview(boardHosts[1]); duoRow.addArrangedSubview(boardHosts[0])
            for panel in resultPanels {
                resultRow.removeArrangedSubview(panel); panel.removeFromSuperview()
                duoResults.addArrangedSubview(panel)
            }
        } else {
            duoRow.removeAllArrangedSubviews(); duoResults.removeAllArrangedSubviews()
            resultPanels.forEach { resultRow.addArrangedSubview($0) }
        }
        row.isHidden = shouldUse
        resultRow.isUserInteractionEnabled = !shouldUse
        duoRow.isHidden = !shouldUse
        duoResults.isHidden = !shouldUse || resultRow.isHidden
    }

    private func startTimer() {
        guard timer == nil, visible, session?.running == true else { return }
        let value = Timer(timeInterval: 0.05, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(value, forMode: .common); timer = value
    }
    @objc private func tick() {
        guard !saving, pending == nil, active, session?.running == true else { return }
        session?.tick(now: now)
        if session?.finished == true { AppFeedback.shared.play(.timerEnd);AppFeedback.shared.haptic(.timerEnd);persist(GameMutation()) }
        render()
    }
    private func resumeGame() {
        guard active, !saving, pending == nil, view.window != nil else { return }
        session?.resume(now: now); startTimer(); render()
    }
    private func newGame() {
        guard let configuration = session?.configuration else { return }
        do { session = try MultiplayerSession(configuration: configuration); resumeGame() }
        catch { showError(error) }
    }
    private func receive(_ player: Int,_ action: PlayerAction) {
        guard let session, session.players.indices.contains(player), !session.finished, active, visible, queue.count < 64 else { return }
        queue.append((player,session.players[player].example.signature,action)); drain()
    }
    private func drain() {
        guard !saving, pending == nil, active, session?.running == true else { return }
        while !queue.isEmpty {
            let (player,signature,action) = queue.removeFirst()
            guard var value = session, value.players[player].example.signature == signature else { continue }
            do {
                let mutation = try value.perform(player: player,action: action,now: now); session = value
                if mutation.correct { AppFeedback.shared.play(value.finished || mutation.levelCompleted ? .levelComplete:.solution); AppFeedback.shared.haptic(mutation.levelCompleted ? .levelComplete : .correct) }
                else if mutation.wrong && (mutation.coinDelta < 0 || settings.signalWrongAnswer) {
                    AppFeedback.shared.play(mutation.coinDelta < 0 ? .wrong:.error,volume:mutation.coinDelta < 0 ? 1:0.15)
                    AppFeedback.shared.haptic(mutation.coinDelta < 0 ? .wrong : .inputError)
                    if mutation.coinDelta == 0 {boards[player].signalWrongInput()}
                }
                else { AppFeedback.shared.play(.keypress) }
                if mutation.correct || mutation.coinDelta != 0 || value.finished { persist(mutation); return }
            } catch { showError(error); queue.removeAll(); return }
        }
        render()
    }
    private func persist(_ mutation: GameMutation) {
        guard pending == nil, var value = session else { return }
        value.pause(now: now); session = value; pending = (value,mutation); retrySave()
    }
    private func retrySave() {
        guard !saving, let pending else { return }
        saving = true; render()
        Task { [weak self] in
            guard let self else { return }
            do {
                try await data.commitMultiplayerSession(pending.0,mutation: pending.1)
                saving = false; self.pending = nil
                if active && visible { session?.resume(now: now); startTimer() }
                render(); endBackgroundSave(); drain()
            } catch { saving = false; endBackgroundSave(); render(); showError(error,retry: { [weak self] in self?.retrySave() }) }
        }
    }
    private func savePaused(completion: (() -> Void)? = nil) {
        guard let session, pending == nil, !saving else { return }
        saving = true
        Task { [weak self] in
            guard let self else { return }
            do { try await data.saveMultiplayerSession(session); saving = false; completion?(); endBackgroundSave(); render() }
            catch { saving = false; endBackgroundSave(); showError(error,retry: { [weak self] in self?.savePaused(completion: completion) }) }
        }
    }
    private func background() {
        if backgroundSave == .invalid {
            backgroundSave = UIApplication.shared.beginBackgroundTask(withName: "SaveMathTricksMatch") { [weak self] in self?.endBackgroundSave() }
        }
        active = false; session?.pause(now: now); timer?.invalidate(); timer = nil; queue.removeAll(); savePaused(); render(); if !saving && pending == nil { endBackgroundSave() }
    }
    private func endBackgroundSave() {
        guard backgroundSave != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundSave); backgroundSave = .invalid
    }
    private let exitConfirmation = ExitConfirmation()
    func requestBack() {
        guard let session, !session.finished else { router?.goBack(confirmed: true); return }
        guard !saving, pending == nil, presentedViewController == nil else { return }
        exitConfirmation.request(from: self, data: data, onExit: { [weak self] in
            guard let self else { return }
            self.session?.finish()
            savePaused { [weak self] in self?.router?.goBack(confirmed: true) }
        }, onShow: { self.session?.pause(now: self.now); self.render() }, onStay: { [weak self] in self?.resumeGame() })
    }
    private func render() {
        guard isViewLoaded, status != nil, let session else { return }
        for index in boards.indices { boards[index].render(session.players[index],player: index,points: session.configuration.kind == .versus ? -1 : session.points[index],settings: settings,enabled: (session.running || pending != nil) && active && !session.finished) }
        if session.configuration.kind == .versus { bar.setProgress(Float(session.balance + session.configuration.length) / Float(session.configuration.length * 2),animated: false) }
        else { bar.setProgress(Float(session.remaining / 20),animated: false) }
        bar.apply(settings:settings)
        status.text = session.configuration.kind == .versus ? "\(session.balance) / ±\(session.configuration.length)" : "\(CatalogText.ui("score")): \(session.points.reduce(0,+)) · \(MathExpressionFormatter.number(session.remaining)) " + CatalogText.ui("seconds")
        if session.finished {
            status.text = session.winner.map { CatalogText.ui("player") + " \($0) · " + CatalogText.ui("winner") } ?? CatalogText.ui("score") + ": \(session.points.reduce(0,+))"
            timer?.invalidate(); timer = nil
        }
        resume.isHidden = session.running || session.finished || saving || pending != nil; resume.isEnabled = !saving && pending == nil && active
        row.alpha=session.finished ? 0:1;row.isUserInteractionEnabled = !session.finished;resultRow.isHidden = !session.finished
        duoRow.alpha = session.finished ? 0 : 1
        duoRow.isUserInteractionEnabled = !session.finished
        duoResults.isHidden = !usesDuoPanes || !session.finished
        view.setNeedsLayout()
        if session.finished {
            for (index,player) in [1,0].enumerated() {
                let font=AppTypography.font(.multiplayerResult,settings:settings,traits:traitCollection)
                let result=NSMutableAttributedString()
                func append(_ text:String,_ color:UIColor?=nil,_ scale:CGFloat=1) {
                    result.append(NSAttributedString(string:text,attributes:[.font:font.withSize(font.pointSize*scale),.foregroundColor:color ?? palette.text]))
                }
                if session.configuration.kind == .versus {
                    let won=session.winner == player+1
                    append(MainText.text(won ? "alert_dialog_player_tv_win":"alert_dialog_player_tv_lose"))
                    append(won ? " :)":" :(",ThemeColor.rgb(won ? 0x008800:0x880000))
                } else {
                    let own=session.points[player],other=session.points[1-player],total=own+other
                    let ownColor=ThemeColor.rgb(player == 0 ? 0x1565C0:0x992424),otherColor=ThemeColor.rgb(player == 0 ? 0x992424:0x1565C0)
                    append(MainText.text("alert_dialog_player_score")+" ");append(String(own),ownColor)
                    append("\n"+MainText.text("alert_dialog_player_score_total")+" ",nil,0.8)
                    append(String(own),ownColor,0.8);append("+",nil,0.8);append(String(other),otherColor,0.8);append("=",nil,0.8);append(String(total),ThemeColor.rgb(0x2E7D32),0.8)
                    append("\n"+MainText.text("alert_dialog_timer_end_tv_score_max")+" ",nil,0.64)
                    append(String(max(total,data.snapshot?.jointRecord ?? 0)),ThemeColor.rgb(0x797100),0.64)
                }
                let paragraph=NSMutableParagraphStyle();paragraph.alignment = .center
                result.addAttribute(.paragraphStyle,value:paragraph,range:NSRange(location:0,length:result.length))
                resultPanels[index].configure(text:result,settings:settings,enabled:!saving && pending == nil)
            }
        }
    }
}
