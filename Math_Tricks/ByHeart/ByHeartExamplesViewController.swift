import UIKit

final class ByHeartExamplesViewController: ThemedViewController {
    private let number: Int
    private let level: Int
    private let hintExample: MathExample?
    private var headingLabel: AppLabel!
    private var countLabel: AppLabel!
    private var examplesLabel: AppLabel!
    private var moreImage: UIImageView!
    private var countButtons:[AppButton]=[]
    private var count = 10
    init(number: Int, level: Int, hintExample: MathExample? = nil, router: AppRouter, data: AppDataStore) {
        self.number = number; self.level = level; self.hintExample = hintExample
        super.init(title: "\(AppRoute.byHeart.title) · \(number)", router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func buildContent() {
        headingLabel=label(hintExample == nil ? AppRoute.byHeart.title : CatalogText.ui("hint"),role:.settingsTitle);headingLabel.numberOfLines=1
        headingLabel.setContentHuggingPriority(.required,for:.horizontal)
        headingLabel.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        countLabel=label("0/10",role:.trickName);countLabel.numberOfLines=1
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let up=button(CatalogText.ui("examples"),icon:.up,kind:.icon){[weak self] in self?.changeCount(10)}
        let down=button(CatalogText.ui("examples"),icon:.down,kind:.icon){[weak self] in self?.changeCount(-10)}
        for key in [up,down] {key.setContentInsets(UIEdgeInsets(top:12,left:4,bottom:12,right:4),minimumHeight:44);key.widthAnchor.constraint(equalToConstant:32).isActive=true}
        countButtons=[up,down]
        let controls=UIStackView(arrangedSubviews:[up,countLabel,down]);controls.alignment = .center
        controls.spacing = 0; controls.setContentHuggingPriority(.required,for:.horizontal)
        let spacer=UIView();spacer.setContentHuggingPriority(.init(1),for:.horizontal)
        let headerContent=UIStackView(arrangedSubviews:hintExample == nil ? [headingLabel,spacer,controls] : [headingLabel,spacer]);headerContent.alignment = .center
        header.replaceTitle(with:headerContent)
        let panel=UIView();panel.translatesAutoresizingMaskIntoConstraints=false;body.addSubview(panel)
        let next=button(CatalogText.ui(hintExample == nil ? "play" : "resume"),icon:.forward,kind:.iconSurface){[weak self] in
            guard let self else{return}
            if hintExample != nil { router?.goBack(confirmed:true); return }
            router?.show(.game(GameConfiguration(mode:.byHeart,difficulty:1,trickIDs:[3],exampleCount:count,multiplicationNumber:number,multiplicationLevel:level)))
        }
        let padding=AndroidDimensions.value("ib_arrow_padding",traits:traitCollection,fallback:18)
        next.setContentInsets(UIEdgeInsets(top:padding,left:padding,bottom:padding,right:padding));body.addSubview(next)
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo:body.topAnchor),panel.leadingAnchor.constraint(equalTo:body.leadingAnchor),panel.trailingAnchor.constraint(equalTo:body.trailingAnchor),panel.bottomAnchor.constraint(equalTo:next.topAnchor),
            next.centerXAnchor.constraint(equalTo:body.centerXAnchor),next.bottomAnchor.constraint(equalTo:body.bottomAnchor),next.widthAnchor.constraint(equalToConstant:AndroidDimensions.value("theme_alert_dialog_b_width",traits:traitCollection,fallback:132))
        ])
        let column=UIStackView();column.axis = .vertical;column.alignment = .center;column.spacing=0
        column.translatesAutoresizingMaskIntoConstraints=false;panel.addSubview(column)
        let range=GameSession.multiplicationInterval(stage:level)
        let interval=label("\(number) × [\(range.lowerBound)..\(range.upperBound)]:",role:.byHeartExample)
        interval.textAlignment = .center;column.addArrangedSubview(interval)
        let more=UIImageView(image:AppIcon.intervalMore.image);more.contentMode = .scaleAspectFit
        more.tintColor=palette.accent;column.addArrangedSubview(more)
        let scroll=AppScrollView();scroll.translatesAutoresizingMaskIntoConstraints=false;column.addArrangedSubview(scroll)
        let examples=label(range.map{"\(number) × \($0) = \(number*$0)"}.joined(separator:"\n"),role:hintExample == nil ? .byHeartExample : .catalogTrick)
        examples.textAlignment = .center;examples.translatesAutoresizingMaskIntoConstraints=false;scroll.addSubview(examples)
        NSLayoutConstraint.activate([
            column.centerYAnchor.constraint(equalTo:panel.centerYAnchor),column.leadingAnchor.constraint(equalTo:panel.leadingAnchor,constant:10),column.trailingAnchor.constraint(equalTo:panel.trailingAnchor,constant:-10),
            column.topAnchor.constraint(greaterThanOrEqualTo:panel.topAnchor,constant:10),column.bottomAnchor.constraint(lessThanOrEqualTo:panel.bottomAnchor,constant:-10),
            more.widthAnchor.constraint(equalToConstant:40),more.heightAnchor.constraint(equalToConstant:25),
            scroll.widthAnchor.constraint(equalTo:column.widthAnchor),
            examples.topAnchor.constraint(equalTo:scroll.contentLayoutGuide.topAnchor),examples.bottomAnchor.constraint(equalTo:scroll.contentLayoutGuide.bottomAnchor),
            examples.leadingAnchor.constraint(equalTo:scroll.contentLayoutGuide.leadingAnchor),examples.trailingAnchor.constraint(equalTo:scroll.contentLayoutGuide.trailingAnchor),
            examples.widthAnchor.constraint(equalTo:scroll.frameLayoutGuide.widthAnchor)
        ])
        let height=scroll.heightAnchor.constraint(equalTo:examples.heightAnchor);height.priority = .defaultHigh;height.isActive=true
        examplesLabel=examples;moreImage=more
    }

    override func update(_ progress: ProgressState?) {
        if hintExample == nil, let descriptor=examplesLabel.font.fontDescriptor.withSymbolicTraits(.traitItalic) {examplesLabel.font=UIFont(descriptor:descriptor,size:examplesLabel.font.pointSize)}
        examplesLabel.textColor=hintExample == nil ? palette.accent : palette.text
        if let hintExample {
            let range=GameSession.multiplicationInterval(stage:level)
            let factor=hintExample.operand1 == Int64(number) ? hintExample.operand2 : hintExample.operand1
            let text=NSMutableAttributedString(string:"")
            for value in range {
                if value != range.lowerBound { text.append(NSAttributedString(string:"\n")) }
                text.append(NSAttributedString(string:"\(number) × \(value) = \(number*value)",attributes:[.font:examplesLabel.font!, .foregroundColor:Int64(value) == factor ? palette.accent : palette.text]))
            }
            examplesLabel.attributedText=text
        }
        moreImage.image=AppIcon.intervalMore.image?.withTintColor(palette.accent,renderingMode:.alwaysOriginal)
        count = progress?.settings.trainingExampleCount ?? 10; countLabel.text = "0/\(count)"
        countLabel.textColor=palette.headerText
        headingLabel.textColor=countLabel.textColor
        countButtons.forEach{$0.apply(settings:settings,tint:countLabel.textColor)}
        themedButtons.forEach { $0.isEnabled = progress != nil }
    }
    private func changeCount(_ delta: Int) {
        let next = max(10, min(50, count + delta))
        Task { [weak self] in
            guard let self else { return }
            do { try await data.updateSettings(.trainingExampleCount(next)) } catch { showError(error) }
        }
    }
}
