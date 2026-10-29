import UIKit

/// Explicit measurements keep the result summary out of UITableView's self-sizing cycle.
final class GameResultSummaryView: UIView {
    private let points = UIView()
    private var pointItems: [(view:UIView,height:CGFloat?,gap:CGFloat)] = []
    private var sections: [UIView] = []

    init(model: SessionResultModel,settings: AppSettings) {
        super.init(frame:.zero)
        let palette = ResultPalette(settings),session = model.session
        let training = [.training,.byHeart].contains(session.configuration.mode)
        let timed = session.configuration.mode == .speed && model.key == nil
        ResultUI.card(points,settings:settings); addSubview(points)
        func label(_ text: String,size: CGFloat,color: UIColor,weight: CGFloat = 400) -> UILabel {
            let label = ResultUI.label(text,size:size,settings:settings,color:color)
            label.font = ResultUI.font(size,settings:settings,weight:weight);label.textAlignment = .center
            return label
        }
        func add(_ view: UIView,height: CGFloat? = nil,gap: CGFloat = 8) {
            points.addSubview(view);pointItems.append((view,height,gap))
        }
        if let key = model.key {
            let title = TrickCatalog.shared.trick(key.id).map { AndroidRichText.plain(CatalogText.text($0.nameKey)) } ?? ""
            add(label(title,size:22,color:palette.primary,weight:500),gap:0)
        } else {
            if training {
                let level = session.configuration.mode == .byHeart ? session.configuration.multiplicationLevel ?? 1 : session.configuration.difficulty
                add(label(ResultText.format("results_level_completed",Int64(level)),size:18,color:palette.secondary),gap:0)
            }
            let trophy = UIImageView(image:UIImage(named:"ic_result_trophy")?.withTintColor(ThemeColor.rgb(0xFACC15),renderingMode:.alwaysOriginal))
            trophy.contentMode = .scaleAspectFit;add(trophy,height:44,gap:training ? 8 : 0)
        }
        add(label(timed ? ResultText.time(session.resultValue) : String(model.score),size:48,color:palette.primary,weight:500))
        add(label(ResultText.text(model.key != nil ? "results_trick_contribution" : timed ? "results_game_timer_result" : "results_points_earned"),size:12,color:palette.secondary),gap:6)
        if training && model.key == nil {
            let stars = UIImageView(image:UIImage(named:"ic_th_light_b_star_\(session.stars)")?.withTintColor(ThemeColor.rgb(0xFACC15),renderingMode:.alwaysOriginal))
            stars.contentMode = .scaleAspectFit;add(stars,height:38)
        }
        func grid(_ metrics: [ResultMetric], adaptive: Bool = true) {
            let view = ResultMetricGrid(metrics,settings:settings,border:false,adaptive:adaptive)
            view.usesIntrinsicSizing = false;sections.append(view);addSubview(view)
        }
        grid([
            ResultMetric(value:"\(model.key == nil ? model.correct : model.attempts.filter{$0.outcome == .solved}.count)/\(model.totalQuestions)",caption:ResultText.text(model.key == nil ? "results_correct" : "results_share_solved_label"),color:model.key == nil ? palette.success : nil),
            ResultMetric(value:ResultText.time(model.average),caption:ResultText.text("results_average_time")),
            ResultMetric(value:ResultText.time(model.totalTime),caption:ResultText.text(timed ? "results_examples_solving_time" : "results_total_time"))
        ])
        if let key = model.key {
            let aggregate = model.aggregate(key)
            grid([
                ResultMetric(value:String(aggregate.independentCount),caption:ResultText.text("results_trick_clean_label"),color:palette.success),
                ResultMetric(value:String(aggregate.errors),caption:ResultText.text("results_trick_errors_label")),
                ResultMetric(value:String(aggregate.hints),caption:ResultText.text("results_trick_hints_label")),
                ResultMetric(value:String(aggregate.skipped),caption:ResultText.text("results_trick_skipped_label"))
            ],adaptive:false)
        }
        if timed && session.penaltyTime > 0 {
            let text = ResultText.format("results_penalty_breakdown",ResultText.time(session.elapsed),ResultText.time(session.penaltyTime),ResultText.time(session.resultValue))
            let view = label(text,size:14,color:palette.secondary);sections.append(view);addSubview(view)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @discardableResult private func measure(width: CGFloat,layout: Bool) -> CGFloat {
        let width = max(1,width),textWidth = max(1,width-40)
        var y: CGFloat = 20
        for item in pointItems {
            let height = item.height ?? ceil(item.view.sizeThatFits(CGSize(width:textWidth,height:.greatestFiniteMagnitude)).height)
            y += item.gap
            if layout {item.view.frame = CGRect(x:20,y:y,width:textWidth,height:height)}
            y += height
        }
        y += 20
        if layout {points.frame = CGRect(x:0,y:0,width:width,height:y)}
        for view in sections {
            y += 16
            let height = ceil(view.sizeThatFits(CGSize(width:width,height:.greatestFiniteMagnitude)).height)
            if layout {view.frame = CGRect(x:0,y:y,width:width,height:height)}
            y += height
        }
        return ceil(y)
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {CGSize(width:size.width,height:measure(width:size.width,layout:false))}
    override func layoutSubviews() {super.layoutSubviews();measure(width:bounds.width,layout:true)}
}
