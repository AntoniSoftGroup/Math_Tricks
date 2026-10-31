import UIKit

/// Results use explicit row measurements; no self-sizing table/header feeds back into layout.
final class GameResultTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    private enum Row { case trick(SessionTrickKey), question(SessionResultQuestion) }
    private let table = UITableView(frame:.zero,style:.plain)
    private let toolbar = UIView(), footer = UIView(), summaryScroll = UIScrollView()
    private let back = UIButton(type:.system),leaderboard = UIButton(type:.system),balance = UILabel()
    private let summaryCell = GameResultRowCell(style:.default,reuseIdentifier:nil)
    private var summary: GameResultSummaryView?
    private var model: SessionResultModel?
    private var rows: [Row] = []
    private var settings = AppSettings()
    private var statistics: PracticeStatistics?
    private var rowHeights: [Int:CGFloat] = [:]
    private var portrait = true
    private var contentWidth: CGFloat = 0
    private var identity = ""
    private var share: UIButton?
    private var actions: [UIButton] = []
    private var actionsEnabled = true
    var resultStatistics: PracticeStatistics? {statistics}
    var onQuestion: ((SessionResultQuestion) -> Void)?
    var onTrick: ((SessionTrickKey) -> Void)?
    var onRetry: (() -> Void)?
    var onNext: (() -> Void)?
    var onBack: (() -> Void)?
    var onShare: (() -> Void)?
    var onLeaderboard: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame:frame)
        for view in [toolbar,footer,summaryScroll,table] {addSubview(view)}
        table.backgroundColor = .clear;table.separatorStyle = .none;table.dataSource = self;table.delegate = self
        table.register(GameResultRowCell.self,forCellReuseIdentifier:"result")
        table.estimatedRowHeight = 0;table.estimatedSectionHeaderHeight = 0;table.estimatedSectionFooterHeight = 0
        table.sectionHeaderTopPadding = 0;table.contentInsetAdjustmentBehavior = .never
        table.bounces = false;summaryScroll.bounces = false
        summaryScroll.contentInsetAdjustmentBehavior = .never
        for view in [back,leaderboard,balance] {toolbar.addSubview(view)}
        back.setImage(AppIcon.back.image?.withRenderingMode(.alwaysTemplate),for:.normal)
        back.accessibilityLabel = ResultText.text("results_back")
        back.addAction(UIAction { [weak self] _ in self?.onBack?() },for:.touchUpInside)
        leaderboard.setImage(AppIcon.leaderboard.image?.withRenderingMode(.alwaysTemplate),for:.normal)
        leaderboard.accessibilityLabel = MainText.text("leaderboard");leaderboard.accessibilityIdentifier = "results.leaderboard"
        leaderboard.addAction(UIAction { [weak self] _ in self?.onLeaderboard?() },for:.touchUpInside)
        leaderboard.isHidden = true;balance.textAlignment = .right
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    func configure(session: GameSession,settings: AppSettings,key: SessionTrickKey? = nil,coins: Int64? = nil) {
        leaderboard.isHidden = key != nil || session.configuration.selectedTricks || GameCenterLeaderboard.game(session.configuration.mode) == nil
        leaderboard.tintColor = ThemePalette(settings:settings).accent
        if let coins {
            let text = NSMutableAttributedString()
            if let image = AppIcon.coins.image {
                let icon = NSTextAttachment();icon.image = image.withTintColor(ThemePalette(settings:settings).accent)
                icon.bounds = CGRect(x:0,y:-5,width:24,height:24);text.append(NSAttributedString(attachment:icon))
            }
            text.append(NSAttributedString(string:" \(coins)",attributes:[.font:ResultUI.font(13,settings:settings),.foregroundColor:ResultPalette(settings).primary]))
            balance.attributedText = text
        } else {balance.attributedText = nil}
        let next = "\(session.id)/\(session.sequence)/\(key?.id ?? 0)/\(key?.input.rawValue ?? -1)"
        guard next != identity || settings != self.settings else {return}
        identity = next;self.settings = settings;model = SessionResultModel(session:session,key:key)
        rebuild()
    }
    func setStatistics(_ value: PracticeStatistics) {
        statistics = value;rowHeights.removeAll();table.reloadData()
    }
    func setActionsEnabled(_ enabled: Bool) {
        actionsEnabled = enabled;leaderboard.isEnabled = enabled
        share?.isEnabled = enabled;actions.forEach {$0.isEnabled = enabled}
    }
    private func rebuild() {
        guard let model else {return}
        back.tintColor = settings.theme == .light ? .black : ResultPalette(settings).primary
        summary?.removeFromSuperview()
        summary = GameResultSummaryView(model:model,settings:settings)
        rows = model.exampleRows ? model.questions.flatMap { question in
            question.attempts.dropLast().filter {$0.outcome == .skipped}.map {Row.question(SessionResultQuestion(attempts:[$0]))} + [.question(question)]
        } : model.trickKeys.map(Row.trick)
        placeSummary();buildFooter(model)
        rowHeights.removeAll();table.reloadData();setNeedsLayout()
    }
    private func placeSummary() {
        guard let summary else {return}
        summary.removeFromSuperview()
        if portrait {summaryCell.configure(summary,settings:settings)}
        else {summaryCell.clear();summaryScroll.addSubview(summary)}
        summaryScroll.isHidden = portrait
    }
    private func buildFooter(_ model: SessionResultModel) {
        footer.subviews.forEach {$0.removeFromSuperview()};actions.removeAll()
        let share = ResultUI.button(ResultText.text("results_share_results"),icon:.resultShare,settings:settings) { [weak self] in self?.onShare?() }
        self.share = share;footer.addSubview(share)
        if model.key == nil {
            let retry = ResultUI.button(ResultText.text("results_retry"),icon:.resultRetry,settings:settings) { [weak self] in self?.onRetry?() }
            actions.append(retry)
            if [.training,.byHeart].contains(model.session.configuration.mode),model.session.completed {
                let config = model.session.configuration,current = config.mode == .byHeart ? config.multiplicationLevel ?? 21 : config.difficulty
                let finished = current >= (config.mode == .byHeart ? 21 : 100)
                let title = finished ? ResultText.text("results_finish_training") : ResultText.format("statistics_level",Int64(current+1))
                actions.append(ResultUI.button(title,icon:.resultNext,settings:settings) { [weak self] in
                    if finished {self?.onBack?()} else {self?.onNext?()}
                })
            }
        }
        for button in actions {footer.addSubview(button)}
        for button in actions + [share] {
            ResultUI.applyButton(button,settings:settings,size:16)
            button.titleLabel?.numberOfLines = 0;button.isEnabled = actionsEnabled
        }
    }
    /// Returns height and places buttons without UIStackView/intrinsic-size negotiation.
    private func footerHeight(width: CGFloat,layout: Bool) -> CGFloat {
        guard let share else {return 0}
        func place(_ buttons: [UIButton],y: CGFloat) -> CGFloat {
            guard !buttons.isEmpty else {return 0}
            let available = max(1,width-CGFloat(buttons.count-1)*8)
            let natural = buttons.map {min(available,$0.sizeThatFits(CGSize(width:available,height:.greatestFiniteMagnitude)).width)}
            let widths = natural.reduce(0,+) <= available ? natural : buttons.map {_ in available/CGFloat(buttons.count)}
            let height = zip(buttons,widths).map {max(56,$0.0.sizeThatFits(CGSize(width:$0.1,height:.greatestFiniteMagnitude)).height)}.max() ?? 56
            if layout {
                var x = (width-widths.reduce(0,+)-CGFloat(buttons.count-1)*8)/2
                for (index,button) in buttons.enumerated() {button.frame = CGRect(x:x,y:y,width:widths[index],height:height);x += widths[index]+8}
            }
            return height
        }
        if !portrait {return place(actions+[share],y:0)}
        let height = place([share],y:0)
        return actions.isEmpty ? height : height+8+place(actions,y:height+8)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0,bounds.height > 0 else {return}
        let width = max(1,bounds.width-32),nextPortrait = bounds.width <= bounds.height
        let changed = portrait != nextPortrait || abs(contentWidth-width)>0.5
        if portrait != nextPortrait {portrait = nextPortrait;placeSummary()}
        contentWidth = width
        let headerHeight = AppDuoLayout.headerHeight(in: self)
        toolbar.frame = CGRect(x:0,y:0,width:bounds.width,height:headerHeight)
        let headerContent = AppDuoLayout.headerForegroundFrame(in: toolbar)
        let rowY = headerContent.midY - AppMetrics.headerHeight / 2
        let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
        back.frame = CGRect(x:rtl ? headerContent.maxX-AppMetrics.headerBackWidth : headerContent.minX,y:rowY,width:AppMetrics.headerBackWidth,height:AppMetrics.headerHeight)
        let margin: CGFloat = usesDuoLayout ? 8 : 16
        let balanceLimit = max(0,min(width/2,headerContent.width-AppMetrics.headerBackWidth-(leaderboard.isHidden ? 0 : 56)-2*margin))
        let balanceWidth = min(balanceLimit,balance.sizeThatFits(CGSize(width:balanceLimit,height:AppMetrics.headerHeight)).width)
        balance.frame = CGRect(x:rtl ? headerContent.minX+margin : headerContent.maxX-margin-balanceWidth,y:rowY,width:balanceWidth,height:AppMetrics.headerHeight)
        leaderboard.frame = CGRect(x:rtl ? balance.frame.maxX+8 : balance.frame.minX-56,y:headerContent.midY-24,width:48,height:48)
        let footerHeight = footerHeight(width:width,layout:true)
        footer.frame = CGRect(x:16,y:max(headerHeight,bounds.height-footerHeight-8),width:width,height:footerHeight)
        let top = headerHeight+8,availableHeight = max(1,footer.frame.minY-top-8)
        let tableWidth = portrait ? width : max(1,width-width/2.1-8)
        table.frame = CGRect(x:portrait ? 16 : 16+width/2.1+8,y:top,width:tableWidth,height:availableHeight)
        if !portrait,let summary {
            summaryScroll.frame = CGRect(x:16,y:top,width:width/2.1,height:availableHeight)
            let height = summary.sizeThatFits(CGSize(width:summaryScroll.bounds.width,height:.greatestFiniteMagnitude)).height
            summary.frame = CGRect(x:0,y:0,width:summaryScroll.bounds.width,height:height)
            summaryScroll.contentSize = CGSize(width:summaryScroll.bounds.width,height:height+16)
        }
        if changed {rowHeights.removeAll();table.reloadData()}
    }
    private var dataOffset: Int {portrait ? 2 : 1}
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {model == nil ? 0 : rows.count+dataOffset}
    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = rowHeights[indexPath.row] {return height}
        let width = max(1,tableView.bounds.width)
        let height: CGFloat
        if portrait && indexPath.row == 0 {height = (summary?.sizeThatFits(CGSize(width:width,height:.greatestFiniteMagnitude)).height ?? 0)+16}
        else {height = makeRow(indexPath.row).sizeThatFits(CGSize(width:width,height:.greatestFiniteMagnitude)).height}
        let result = height.isFinite ? max(1,ceil(height)) : 56
        rowHeights[indexPath.row] = result;return result
    }
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if portrait && indexPath.row == 0 {return summaryCell}
        let cell = tableView.dequeueReusableCell(withIdentifier:"result",for:indexPath) as! GameResultRowCell
        cell.configure(makeRow(indexPath.row),settings:settings,interactive:indexPath.row >= dataOffset);return cell
    }
    private func makeRow(_ index: Int) -> ResultColumnsView {
        guard let model else {return ResultColumnsView(title:"",values:[],settings:settings)}
        if index == dataOffset-1 {
            let headings = model.exampleRows ? [ResultText.text("results_first_time_header"),ResultText.text("results_best_time_header"),ResultText.text("results_current_time")] : [ResultText.text("results_share_solved_label")]
            let view = ResultColumnsView(title:ResultText.text(model.exampleRows ? "results_example":"results_trick"),values:headings,settings:settings,header:true,fixed:model.exampleRows)
            view.layer.cornerRadius = 16;view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner];return view
        }
        let rowIndex = index-dataOffset,palette = ResultPalette(settings)
        guard rows.indices.contains(rowIndex) else {return ResultColumnsView(title:"",values:[],settings:settings)}
        let last = rowIndex == rows.count-1
        switch rows[rowIndex] {
        case .trick(let key):
            var title = TrickCatalog.shared.trick(key.id).map {AndroidRichText.plain(CatalogText.text($0.nameKey))} ?? ""
            if model.trickKeys.filter({$0.id == key.id}).count>1 {title += " · "+CatalogText.ui("input_\(key.input.rawValue)")}
            return ResultColumnsView(title:title,values:[String(model.aggregate(key).solved)],settings:settings,colors:[palette.primary],last:last)
        case .question(let question):
            let attempt = question.final,compare = model.comparison(attempt,statistics:statistics)
            let timing = ResultAnswerStatus.text(attempt) == nil
            let first = timing ? ResultText.time(compare.first) : "—",bestTime = compare.best ?? attempt.elapsed
            var best = timing ? ResultText.time(bestTime) : "—",current = timing ? ResultText.time(attempt.elapsed) : "—"
            var color = timing ? palette.primary : palette.secondary
            if timing && best == current {best = "="}
            else if timing,let previous = compare.best,previous != attempt.elapsed {
                current = ResultText.format(attempt.elapsed<previous ? "results_faster":"results_slower",current)
                color = attempt.elapsed<previous ? palette.success : palette.error
            }
            if timing && first == ResultText.time(attempt.elapsed) {current = "="}
            return ResultColumnsView(title:MathExpressionFormatter.text(attempt.example),values:[first,best,current],settings:settings,fixed:true,correct:question.correct,colors:[palette.secondary,palette.secondary,color],last:last)
        }
    }
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath,animated:false)
        let row = indexPath.row-dataOffset
        guard rows.indices.contains(row) else {return}
        switch rows[row] {case .trick(let key):onTrick?(key);case .question(let question):onQuestion?(question)}
    }
}

private final class GameResultRowCell: AppListCell {
    private var row: UIView?
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) {
        super.init(style:style,reuseIdentifier:reuseIdentifier);backgroundColor = .clear;selectionStyle = .none
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    func configure(_ row: UIView, settings: AppSettings, interactive: Bool = false) {
        clear(); self.row = row
        contentView.addSubview(row)
        applyHighlight(settings: settings, enabled: interactive)
        setNeedsLayout()
    }
    func clear() {row?.removeFromSuperview();row = nil}
    override func layoutSubviews() {
        super.layoutSubviews()
        let gap: CGFloat = row is GameResultSummaryView ? 16 : 0
        row?.frame = CGRect(x:0,y:0,width:contentView.bounds.width,height:max(1,contentView.bounds.height-gap))
    }
}
