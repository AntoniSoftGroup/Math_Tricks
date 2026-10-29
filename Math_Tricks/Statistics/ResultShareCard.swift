import UIKit

struct ResultShareRow {
    let title: String
    let values: [String]
    var correct: Bool = false
}

/// A separate 1080-point export, independent of device size and table scroll position.
enum ResultShareCard {
    static var links: String {
        ResultText.format("results_share_store_links",ResultText.format("results_share_app_url","example.matharithmetics"),ResultText.text("results_share_ios_url"))
    }
    static func session(_ session: GameSession,key: SessionTrickKey? = nil,statistics: PracticeStatistics?,settings: AppSettings) -> (image: UIImage, text: String)? {
        let model=SessionResultModel(session:session,key:key)
        let mode: String
        switch session.configuration.mode {
        case .training: mode=MainText.text("activity_main_b_Training")
        case .byHeart: mode=MainText.text("activity_main_b_by_heart")
        case .daily: mode=MainText.text("play_day_streak")
        default: mode=CatalogText.ui("mode_\(session.configuration.mode.rawValue)")
        }
        let title=key.flatMap { TrickCatalog.shared.trick($0.id) }.map { AndroidRichText.plain(CatalogText.text($0.nameKey))+"\n"+mode } ?? mode
        let rows: [ResultShareRow]
        if model.exampleRows {
            rows=model.questions.filter(\.correct).map { question in
                let attempt=question.final,comparison=model.comparison(attempt,statistics:statistics)
                let current=key != nil ? attempt.elapsed : min(attempt.elapsed,comparison.best ?? attempt.elapsed)
                return ResultShareRow(title:MathExpressionFormatter.text(attempt.example),values:[ResultText.time(attempt.inputChanged == true ? nil : comparison.first),ResultText.time(attempt.inputChanged == true ? nil : current)],correct:true)
            }
        } else {
            rows=model.trickKeys.map { key in
                var name=TrickCatalog.shared.trick(key.id).map { AndroidRichText.plain(CatalogText.text($0.nameKey)) } ?? ""
                if model.trickKeys.filter({ $0.id == key.id }).count>1 { name += " · "+CatalogText.ui("input_\(key.input.rawValue)") }
                return ResultShareRow(title:name,values:[String(model.aggregate(key).solved)])
            }
        }
        let timed=session.configuration.mode == .speed && key == nil
        let score=timed ? ResultText.time(session.resultValue) : String(model.score)
        let label=ResultText.text(key != nil ? "results_trick_contribution" : timed ? "results_total_time" : "results_points_earned")
        let solved = model.questions.filter(\.correct)
        let count = model.exampleRows ? solved.count : model.trickKeys.reduce(0) { $0 + model.aggregate($1).solved }
        let total = solved.reduce(0.0) { total, question in
            let attempt = question.final
            return total + (key != nil ? attempt.elapsed : min(attempt.elapsed, model.comparison(attempt, statistics: statistics).best ?? attempt.elapsed))
        }
        let average = count > 0 ? total / Double(count) : nil
        let intro: String
        if !model.exampleRows {
            intro = String.localizedStringWithFormat(ResultText.text("results_share_tricks_intro"), Int64(count))
        } else if count == 0 {
            intro = ResultText.text("results_share_no_clean")
        } else {
            intro = String.localizedStringWithFormat(ResultText.text("results_share_clean_intro"), Int64(count), ResultText.time(total), ResultText.time(average))
        }
        let metrics=model.exampleRows ? [ResultMetric(value:String(count),caption:ResultText.text("results_share_solved_label")),ResultMetric(value:ResultText.time(total),caption:ResultText.text("results_total_time")),ResultMetric(value:ResultText.time(average),caption:ResultText.text("results_average_time"))] : []
        guard let image = make(title:ResultText.format("results_share_game_type",title),subtitle:intro,score:score,scoreCaption:label,metrics:metrics,headings:model.exampleRows ? [ResultText.text("results_example"),ResultText.text("results_first_time_header"),ResultText.text("results_current_time")] : [ResultText.text("results_trick"),ResultText.text("results_share_solved_label")],rows:rows,settings:settings) else { return nil }
        return (image, intro + "\n\n" + links)
    }

    static func make(title: String,subtitle: String,score: String? = nil,scoreCaption: String? = nil,metrics: [ResultMetric] = [],headings: [String],rows: [ResultShareRow],settings: AppSettings) -> UIImage? {
        var export=settings;export.useSystemFontSize=false;export.fontSizePercent=100
        let palette=ResultPalette(export),accent=ThemePalette(settings:export).accent
        let root=UIView(),column=ResultUI.stack(.vertical,spacing:24)
        root.backgroundColor=palette.background;root.layer.cornerRadius=32
        ResultUI.pin(column,in:root,insets:UIEdgeInsets(top:64,left:64,bottom:64,right:64))
        func label(_ text: String,_ size: CGFloat,_ color: UIColor,center: Bool = true) -> UILabel {
            let label=ResultUI.label(text,size:size,settings:export,color:color);label.textAlignment=center ? .center : .natural;return label
        }
        let brand=ResultUI.stack(.horizontal,spacing:32);brand.alignment = .center
        let logo=UIImageView(image:UIImage(named:"result_share_logo"));logo.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([logo.widthAnchor.constraint(equalToConstant:208),logo.heightAnchor.constraint(equalToConstant:208)])
        brand.addArrangedSubview(logo);brand.addArrangedSubview(label("Math Tricks",48,accent,center:false));column.addArrangedSubview(brand)
        let stores=ResultUI.stack(.horizontal,spacing:24);stores.distribution = .fillEqually
        for (value,caption) in [(ResultText.format("results_store_rating",String(format:"%.1f",locale:Locale.current,4.5)),ResultText.text("results_store_reviews")),(ResultText.text("results_store_download_count"),ResultText.text("results_store_downloads"))] {
            let stack=ResultUI.stack(.vertical,spacing:8);stack.addArrangedSubview(label(value,36,palette.primary));stack.addArrangedSubview(label(caption,26,palette.secondary));stores.addArrangedSubview(stack)
        }
        column.addArrangedSubview(stores)
        let mode=UIView();mode.backgroundColor=accent.withAlphaComponent(24/255);mode.layer.cornerRadius=20;mode.layer.borderWidth=2;mode.layer.borderColor=accent.withAlphaComponent(100/255).cgColor
        ResultUI.pin(label(title,36,palette.primary),in:mode,insets:UIEdgeInsets(top:24,left:24,bottom:24,right:24));column.addArrangedSubview(mode)
        if let score {column.addArrangedSubview(label(score,56,accent))}
        if let scoreCaption {column.addArrangedSubview(label(scoreCaption,26,palette.secondary))}
        if !subtitle.isEmpty {column.addArrangedSubview(label(subtitle,30,palette.secondary))}
        if !metrics.isEmpty {
            let box=UIView(),row=ResultUI.stack(.horizontal,spacing:24);row.distribution = .fillEqually;ResultUI.card(box,settings:export,radius:24)
            for metric in metrics { let stack=ResultUI.stack(.vertical,spacing:6);stack.addArrangedSubview(label(metric.value,44,palette.primary));stack.addArrangedSubview(label(metric.caption,24,palette.secondary));row.addArrangedSubview(stack) }
            ResultUI.pin(row,in:box,insets:UIEdgeInsets(top:24,left:24,bottom:24,right:24));column.addArrangedSubview(box)
        }
        let box=UIView(),table=ResultUI.stack(.vertical);ResultUI.card(box,settings:export,radius:24)
        func row(title: String,values: [String],header: Bool,correct: Bool = false) -> UIView {
            let row=ResultUI.stack(.horizontal,spacing:12);row.alignment = .center
            row.isLayoutMarginsRelativeArrangement=true;row.directionalLayoutMargins=NSDirectionalEdgeInsets(top:header ? 0 : 20,leading:0,bottom:header ? 16 : 20,trailing:0)
            if correct { let icon=UIImageView(image:UIImage(named:"ic_result_correct")?.withTintColor(palette.success,renderingMode:.alwaysOriginal));icon.contentMode = .scaleAspectFit;icon.widthAnchor.constraint(equalToConstant:30).isActive=true;icon.heightAnchor.constraint(equalToConstant:30).isActive=true;row.addArrangedSubview(icon) }
            row.addArrangedSubview(label(title,header ? 26 : 30,header ? palette.secondary : palette.primary,center:false))
            for value in values {let text=label(value,header ? 26 : 30,header ? palette.secondary : palette.primary);text.widthAnchor.constraint(equalToConstant:190).isActive=true;row.addArrangedSubview(text)}
            return row
        }
        table.addArrangedSubview(row(title:headings.first ?? "",values:Array(headings.dropFirst()),header:true))
        for (index,item) in rows.prefix(15).enumerated() {
            if index>0 {let divider=UIView();divider.backgroundColor=palette.divider;divider.heightAnchor.constraint(equalToConstant:1).isActive=true;table.addArrangedSubview(divider)}
            table.addArrangedSubview(row(title:item.title,values:item.values,header:false,correct:item.correct))
        }
        if rows.count>15 {table.addArrangedSubview(label(ResultText.text("results_share_more_ellipsis"),30,palette.secondary))}
        ResultUI.pin(table,in:box,insets:UIEdgeInsets(top:24,left:24,bottom:24,right:24));column.addArrangedSubview(box)
        let size=root.systemLayoutSizeFitting(CGSize(width:1080,height:0),withHorizontalFittingPriority:.required,verticalFittingPriority:.fittingSizeLevel)
        guard size.height.isFinite,size.height<16000 else {return nil}
        root.frame=CGRect(x:0,y:0,width:1080,height:max(1080,ceil(size.height)));root.layoutIfNeeded()
        let format=UIGraphicsImageRendererFormat();format.scale=1;format.opaque=true
        return UIGraphicsImageRenderer(size:root.bounds.size,format:format).image { context in palette.background.setFill();context.fill(root.bounds);root.layer.render(in:context.cgContext) }
    }
}
