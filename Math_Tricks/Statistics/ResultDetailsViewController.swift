import UIKit

/// Shared Android-style details sheet for saved metrics and an individual answer.
final class ResultDetailsViewController: UIViewController {
    private let sheetTitle: String
    private let settings: AppSettings
    private let metrics: [ResultMetric]?
    private let question: SessionResultQuestion?
    private let scroll = AppScrollView()
    private let restoredOffset: CGFloat
    var onSolution: ((CGFloat) -> Void)?
    init(title: String,metrics: [ResultMetric],settings: AppSettings) {
        sheetTitle = title; self.metrics = metrics; self.settings = settings; question = nil; restoredOffset = 0
        super.init(nibName: nil,bundle: nil); modalPresentationStyle = .overFullScreen
    }
    init(question: SessionResultQuestion,settings: AppSettings,offset: CGFloat = 0) {
        self.question = question; self.settings = settings; metrics = nil; restoredOffset = offset
        sheetTitle = ResultText.text("results_example")
        super.init(nibName: nil,bundle: nil); modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad(); view.backgroundColor = UIColor.black.withAlphaComponent(0.55); view.accessibilityViewIsModal = true
        let palette = ResultPalette(settings), card = UIView(), column = ResultUI.stack(.vertical,spacing: 12)
        let backdrop=UIControl();backdrop.frame=view.bounds;backdrop.autoresizingMask=[.flexibleWidth,.flexibleHeight]
        backdrop.addAction(UIAction { [weak self] _ in self?.dismiss(animated:false) },for:.touchUpInside);view.addSubview(backdrop)
        ResultUI.card(card,settings: settings,radius: 20);card.backgroundColor=ThemePalette(settings:settings).dialogBackground; card.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(card)
        ResultUI.pin(column,in: card,insets: UIEdgeInsets(top: 20,left: 20,bottom: 16,right: 20))
        let title = ResultUI.label(sheetTitle,size: 20,settings: settings,color: palette.primary); column.addArrangedSubview(title)
        column.addArrangedSubview(scroll)
        let content = ResultUI.stack(.vertical,spacing: 12); content.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(content)
        NSLayoutConstraint.activate([content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)])
        if let metrics { content.addArrangedSubview(ResultMetricGrid(metrics,settings: settings)) }
        if let question { buildQuestion(question,in: content,palette: palette) }
        let actions = ResultUI.stack(.horizontal,spacing: 8); actions.alignment = .center
        if question != nil {
            let solution = AppButton(title:ResultText.text("results_show_solution"),kind:.dialog) { [weak self] in
                guard let self else { return }; onSolution?(scroll.contentOffset.y)
            }
            solution.apply(settings:settings);solution.label.role = .body
            solution.setContentInsets(UIEdgeInsets(top:8,left:8,bottom:8,right:8),minimumHeight:48)
            actions.addArrangedSubview(solution)
        }
        actions.addArrangedSubview(UIView())
        let ok = AppButton(title:MainText.text("ok"),kind:.dialog) { [weak self] in self?.dismiss(animated: false) }
        ok.apply(settings:settings);ok.label.role = .body;ok.setContentInsets(UIEdgeInsets(top:8,left:16,bottom:8,right:16),minimumHeight:48)
        actions.addArrangedSubview(ok); column.addArrangedSubview(actions)
        NSLayoutConstraint.activate([card.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),card.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),card.widthAnchor.constraint(lessThanOrEqualToConstant: 560),card.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor,constant: -24),
            card.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,constant: 12),card.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -12)])
        let width = card.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor,constant: -24); width.priority = .defaultHigh; width.isActive = true
        let height = scroll.heightAnchor.constraint(equalTo: content.heightAnchor); height.priority = .defaultHigh; height.isActive = true
        let minHeight = scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 40); minHeight.priority = .init(999); minHeight.isActive = true
    }
    override func accessibilityPerformEscape() -> Bool {dismiss(animated:false);return true}
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated); scroll.setContentOffset(CGPoint(x: 0,y: max(0,min(restoredOffset,scroll.contentSize.height - scroll.bounds.height))),animated: false)
    }
    private func buildQuestion(_ question: SessionResultQuestion,in content: UIStackView,palette: ResultPalette) {
        let attempt = question.final
        func text(_ value: String,_ size: CGFloat = 16,_ color: UIColor? = nil) { content.addArrangedSubview(ResultUI.label(value,size: size,settings: settings,color: color ?? palette.primary)) }
        if let status = ResultAnswerStatus.text(attempt) { text(status.uppercased(),16,palette.error) }
        text(MathExpressionFormatter.text(attempt.example),20)
        if attempt.inputMode == .boolean || attempt.inputMode == .choices {
            if attempt.inputMode == .boolean { text(ResultText.format("results_displayed_answer",attempt.proposedAnswer ?? attempt.example.answer),16,palette.secondary) }
            text(ResultText.text("results_your_choice"))
            let values = attempt.inputMode == .boolean ? [Int64(0),1] : attempt.displayedChoices ?? []
            for start in stride(from: 0,to: values.count,by: 2) {
                let row = ResultUI.stack(.horizontal,spacing: 8); row.distribution = .fillEqually
                for value in values[start..<min(values.count,start + 2)] {
                    let boolean = value == 1
                    let correct = attempt.inputMode == .boolean ? boolean == (attempt.proposedAnswer == attempt.example.answer) : value == attempt.example.answer
                    let chosen = attempt.inputMode == .boolean ? attempt.chosenBoolean == boolean : (attempt.selectedChoices ?? [Int64(attempt.userAnswer ?? "")].compactMap{$0}).contains(value)
                    let title = attempt.inputMode == .boolean ? ResultText.text(boolean ? "results_true_option" : "results_false_option") : String(value)
                    let label = ResultUI.label(chosen ? ResultText.format("results_selected_option",title) : title,size: 18,settings: settings,color: chosen ? (correct ? palette.success : palette.error) : palette.secondary)
                    label.textAlignment = .center
                    let box = UIView(); ResultUI.card(box,settings: settings,radius: 12,border: true)
                    ResultUI.pin(label,in: box,insets: UIEdgeInsets(top: 12,left: 8,bottom: 12,right: 8))
                    if chosen { box.layer.borderWidth = 2; box.layer.borderColor = (correct ? palette.success : palette.error).cgColor }
                    row.addArrangedSubview(box)
                }
                content.addArrangedSubview(row)
            }
            text(ResultText.format("results_correct_answer",attempt.example.answer),16,palette.success)
        } else {
            text(ResultText.format(attempt.outcome == .solved && !attempt.revealedAnswer ? "results_entered_correct_answer" : "results_correct_answer",attempt.example.answer),16,palette.success)
            if attempt.outcome != .solved,let answer = attempt.userAnswer { text(ResultText.format("results_user_answer",answer),16,palette.secondary) }
        }
        if attempt.revealedAnswer { text(ResultText.text("results_revealed"),16,palette.secondary) }
        text(attempt.outcome == .solved ? ResultText.format("results_question_time",ResultText.time(attempt.elapsed)) : ResultText.text(attempt.outcome == .skipped ? "statistics_skipped" : "results_unsolved"))
        text(ResultText.format("results_question_help_details",Int64(attempt.hints),Int64(attempt.errors + attempt.corrections)),14,palette.secondary)
    }
}

/// Returning from any nested solution restores the same details sheet and scroll position.
final class ResultDetailsCoordinator {
    private weak var owner: UIViewController?
    private weak var router: AppRouter?
    private var pending: (SessionResultQuestion,CGFloat)?
    init(owner: UIViewController,router: AppRouter?) { self.owner = owner; self.router = router }
    func show(_ question: SessionResultQuestion,settings: AppSettings,offset: CGFloat = 0) {
        guard let owner,owner.presentedViewController == nil else { return }
        let details = ResultDetailsViewController(question: question,settings: settings,offset: offset)
        details.onSolution = { [weak self,weak details] offset in
            guard let self else { return }; pending = (question,offset)
            details?.dismiss(animated: false) { [weak self] in self?.router?.show(.solutionPreview(question.final.example)) }
        }
        owner.present(details,animated: false)
    }
    func restore(settings: AppSettings) {
        guard let pending,owner?.presentedViewController == nil else { return }
        self.pending = nil; show(pending.0,settings: settings,offset: pending.1)
    }
}

final class SessionTrickResultViewController: ThemedViewController {
    private let session: GameSession
    private let key: SessionTrickKey
    private let result = GameResultTableView()
    private lazy var details = ResultDetailsCoordinator(owner: self,router: router)
    private var loadTask: Task<Void,Never>?
    init(session: GameSession,key: SessionTrickKey,router: AppRouter,data: AppDataStore) {
        self.session = session; self.key = key
        super.init(title: ResultText.text("results_trick"),router: router,data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { loadTask?.cancel() }
    override func buildContent() {
        setHeaderHidden(true); ResultUI.pin(result,in: body)
        result.onBack = { [weak self] in self?.router?.goBack(confirmed: true) }
        result.onQuestion = { [weak self] question in guard let self else { return }; details.show(question,settings: settings) }
        result.onShare = { [weak self] in self?.share() }
        loadTask = Task { [weak self] in
            guard let self else { return }
            do { let statistics = try await data.practiceStatistics(); if !Task.isCancelled { result.setStatistics(statistics) } }
            catch { if !Task.isCancelled { showError(error,reading: true) } }
        }
    }
    override func update(_ progress: ProgressState?) { result.configure(session: session,settings: settings,key: key) }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); details.restore(settings: settings) }
    private func share() {
        guard presentedViewController == nil,let content = ResultShareCard.session(session,key:key,statistics:result.resultStatistics,settings:settings) else { return }
        let sheet = UIActivityViewController(activityItems: [content.image,content.text],applicationActivities: nil)
        sheet.popoverPresentationController?.sourceView = result; sheet.popoverPresentationController?.sourceRect = CGRect(x: result.bounds.midX,y: result.bounds.maxY,width: 1,height: 1)
        present(sheet,animated: false)
    }
}
