import UIKit

final class PlayerInputBoard:UIView {
    var onAction:((PlayerAction)->Void)?
    var onBack:(()->Void)?
    private lazy var backButton = AppButton(title:CatalogText.ui("back"),icon:.back,kind:.icon) { [weak self] in self?.onBack?() }
    private let content=UIStackView()
    private let informationPanel=UIStackView()
    private var keyboardHeight:NSLayoutConstraint?
    private let title=AppLabel(.trickName)
    private let count=AppLabel(.trickName)
    private let score=AppLabel(.trickName)
    private let level=AppLabel(.trickName)
    private let equation=AppLabel(.playerExpression)
    private let answer=AppLabel(.playerExpression)
    private lazy var expression=FittingMathExpressionView(equation:equation,answer:answer)
    private let keyboard=UIStackView()
    private let keys=UIStackView()
    private let choices=UIStackView()
    private let boolPanel=UIStackView()
    private let booleans=UIStackView()
    private let proposal=AppLabel(.playerExpression)
    private var buttons:[AppButton]=[]
    private var variantButtons:[AppButton]=[]
    private var lastLayout:Bool?
    private var lastChoices:[Int64]=[]
    private var variantValues:[Int64]=[]
    private var lastPlayer:Int?
    private let solutionScroll=AppScrollView()
    private let solution=BooleanSolutionLabel(multiplayer:true)
    private var settings=AppSettings()
    private var playerColor=UIColor.black
    override init(frame:CGRect) {
        super.init(frame:frame)
        let content=self.content;content.axis = .vertical;content.spacing=0
        content.translatesAutoresizingMaskIntoConstraints=false;addSubview(content)
        let information=UIStackView(arrangedSubviews:[title,count]);information.alignment = .center;information.spacing=4
        title.numberOfLines=1;count.numberOfLines=1;count.textAlignment = .right;level.numberOfLines=1;level.textAlignment = .right
        title.setContentHuggingPriority(.defaultLow,for:.horizontal)
        informationPanel.axis = .vertical;informationPanel.spacing=0
        informationPanel.addArrangedSubview(information);informationPanel.addArrangedSubview(expression)
        content.addArrangedSubview(informationPanel)
        backButton.isHidden = true
        backButton.setContentInsets(UIEdgeInsets(top:8,left:8,bottom:8,right:8),minimumHeight:48)
        informationPanel.addSubview(backButton)
        NSLayoutConstraint.activate([backButton.leadingAnchor.constraint(equalTo:informationPanel.leadingAnchor,constant:14),
            backButton.centerYAnchor.constraint(equalTo:informationPanel.centerYAnchor),backButton.widthAnchor.constraint(equalToConstant:48),backButton.heightAnchor.constraint(equalToConstant:48)])
        information.layoutMargins=UIEdgeInsets(top:0,left:14,bottom:0,right:14);information.isLayoutMarginsRelativeArrangement=true
        let scoreRow=UIStackView(arrangedSubviews:[score,level]);scoreRow.alignment = .center;score.setContentHuggingPriority(.defaultLow,for:.horizontal);informationPanel.addArrangedSubview(scoreRow)
        scoreRow.layoutMargins=UIEdgeInsets(top:0,left:14,bottom:0,right:14);scoreRow.isLayoutMarginsRelativeArrangement=true
        keyboard.axis = .vertical;keyboard.spacing=0
        keys.axis = .vertical;keys.spacing=0;keys.distribution = .fillEqually
        choices.axis = .vertical;choices.spacing=0;choices.distribution = .fillEqually
        boolPanel.axis = .vertical;boolPanel.distribution = .fillEqually
        booleans.axis = .horizontal;booleans.distribution = .fillEqually
        proposal.textAlignment = .center;proposal.adjustsFontSizeToFitWidth=true;proposal.minimumScaleFactor=0.3;proposal.numberOfLines=1
        solution.translatesAutoresizingMaskIntoConstraints=false;solutionScroll.addSubview(solution)
        NSLayoutConstraint.activate([solution.topAnchor.constraint(equalTo:solutionScroll.contentLayoutGuide.topAnchor,constant:8),solution.bottomAnchor.constraint(equalTo:solutionScroll.contentLayoutGuide.bottomAnchor,constant:-8),
            solution.leadingAnchor.constraint(equalTo:solutionScroll.contentLayoutGuide.leadingAnchor,constant:15),solution.trailingAnchor.constraint(equalTo:solutionScroll.contentLayoutGuide.trailingAnchor,constant:-15),solution.widthAnchor.constraint(equalTo:solutionScroll.frameLayoutGuide.widthAnchor,constant:-30)])
        boolPanel.addArrangedSubview(solutionScroll);boolPanel.addArrangedSubview(booleans)
        keyboard.addArrangedSubview(keys);keyboard.addArrangedSubview(choices);keyboard.addArrangedSubview(boolPanel)
        content.addArrangedSubview(keyboard)
        for value in [false,true] {
            booleans.addArrangedSubview(key(CatalogText.ui(value ? "true":"false"),icon:value ? .correct:.incorrect){[weak self] in self?.onAction?(.boolean(value))})
        }
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo:topAnchor),content.bottomAnchor.constraint(equalTo:bottomAnchor),
            content.leadingAnchor.constraint(equalTo:leadingAnchor),content.trailingAnchor.constraint(equalTo:trailingAnchor),
        ])
        let height=keyboard.heightAnchor.constraint(equalToConstant:0);height.priority = .init(999);height.isActive=true;keyboardHeight=height
    }
    required init?(coder:NSCoder){fatalError("init(coder:) has not been implemented")}
    private func key(_ title:String,icon:AppIcon?=nil,action:@escaping()->Void)->AppButton {
        let button=AppButton(title:title,icon:icon,kind:icon==nil ? .playerKey:.keypadIcon,action:action)
        button.setContentInsets(UIEdgeInsets(top:0,left:2,bottom:0,right:2),minimumHeight:16)
        button.label.adjustsFontSizeToFitWidth=true;button.label.minimumScaleFactor=0.4
        button.apply(settings:settings,tint:playerColor,textTint:playerColor);buttons.append(button);return button
    }
    func render(_ session:GameSession,player:Int,points:Int64,settings:AppSettings,enabled:Bool) {
        let color=ThemePalette(settings:settings).text
        let appearanceChanged=self.settings != settings || lastLayout==nil || playerColor != color || lastPlayer != player
        self.settings=settings;playerColor=color
        if lastLayout != settings.numpad123 {rebuildDigits()}
        if lastChoices != session.choices || lastPlayer != player {
            lastPlayer=player;rebuildChoices(session.choices)
        }
        buttons.forEach{if appearanceChanged{$0.apply(settings:settings,tint:color,textTint:color)};$0.isEnabled=enabled}
        for (index, button) in variantButtons.enumerated() {
            let rejected = (session.rejectedChoices ?? []).contains(variantValues[index])
            button.isEnabled = enabled && !rejected
            button.label.text = rejected ? "×" : String(variantValues[index])
        }
        for (index, button) in booleans.arrangedSubviews.enumerated() {
            (button as? AppButton)?.isEnabled = enabled && session.rejectedBoolean != (index == 1)
        }
        if appearanceChanged {
            for label in [title,count,score,level,equation,answer,proposal] {label.apply(settings:settings);label.textColor=color}
            for label in [title,count,score,level] {
                let cap:CGFloat=min(UIScreen.main.bounds.width,UIScreen.main.bounds.height)<=400 ? 1.15:1.3
                let base=AndroidDimensions.value("player_tv_level",traits:traitCollection,fallback:15)
                label.font=label.font.withSize(min(label.font.pointSize,base*cap))
            }
            expression.apply(settings:settings,role:.playerExpression,player:lastPlayer)
        }
        backButton.isHidden = player != 0
        backButton.apply(settings:settings,tint:ThemePalette(settings:settings).theme == .light ? .white : color)
        backButton.alpha = ThemePalette(settings:settings).theme.isClassic ? 0.15 : 1
        informationPanel.bringSubviewToFront(backButton)
        title.text=TrickCatalog.shared.trick(session.example.trickID).map{AndroidRichText.plain(CatalogText.text($0.nameKey))} ?? ""
        count.text=MainText.format("activity_game_tv_examples","\(session.levelSolved)/\(session.target)")
        score.text=MainText.text("activity_game_tv_score")+" \(points)"
        level.text=MainText.format("activity_game_tv_level",String(session.level))
        equation.text=MathExpressionFormatter.text(session.example).replacingOccurrences(of:" ",with:"")+"="
        answer.text=session.input.isEmpty ? "?":session.input
        if session.inputMode == .boolean {answer.text=String(session.proposedAnswer)}
        score.isHidden = points < 0
        if solution.configure(example:session.example,settings:settings,
                              showing:session.inputMode == .boolean && session.rejectedBoolean != nil) {
            solutionScroll.setContentOffset(.zero,animated:false)
        }
        proposal.text=String(session.proposedAnswer);expression.setNeedsLayout()
        expression.animateNewExample(id:"\(session.id):\(session.solved):\(session.skipsRemaining):\(session.example.signature)");setNeedsLayout()
        keys.isHidden=session.inputMode != .digits;choices.isHidden=session.inputMode != .choices;boolPanel.isHidden=session.inputMode != .boolean
    }
    func signalWrongInput() {
        let shake=CAKeyframeAnimation(keyPath:"transform.translation.x");shake.values=[0,5,-5,5,-5,0];shake.duration=0.24;answer.layer.add(shake,forKey:"wrongAnswer")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let required:CGFloat=max(title.font.lineHeight,count.font.lineHeight)+max(score.font.lineHeight,level.font.lineHeight)+AppTypography.font(.playerExpression,settings:settings,traits:traitCollection).lineHeight+(ThemePalette(settings:settings).theme.isClassic ? 16 : 32)
        let fraction:CGFloat=min(0.75,max(35.0/95.0,required/max(1,bounds.height)))
        let height:CGFloat=max(0,bounds.height*(1-fraction))
        if keyboardHeight?.constant != height {keyboardHeight?.constant=height}
    }
    override func traitCollectionDidChange(_ previousTraitCollection:UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if lastLayout != nil {expression.apply(settings:settings,role:.playerExpression,player:lastPlayer)}
    }
    private func rebuildDigits() {
        lastLayout=settings.numpad123
        keys.arrangedSubviews.forEach{row in
            if let stack=row as? UIStackView {buttons.removeAll{stack.arrangedSubviews.contains($0)}}
            keys.removeArrangedSubview(row);row.removeFromSuperview()
        }
        let digits=settings.numpad123 ? [[1,2,3],[4,5,6],[7,8,9]]:[[7,8,9],[4,5,6],[1,2,3]]
        for numbers in digits+[[0,-1]] {
            let row=UIStackView();row.axis = .horizontal;row.distribution = .fillEqually
            for number in numbers {
                let button=key(number>=0 ? String(number):MainText.text("backspace"),icon:number>=0 ? nil:.backspace){[weak self] in self?.onAction?(number>=0 ? .digit(number):.delete)}
                if number<0 {button.addGestureRecognizer(UILongPressGestureRecognizer(target:self,action:#selector(clear(_:))))}
                row.addArrangedSubview(button)
            }
            keys.addArrangedSubview(row)
        }
    }
    @objc private func clear(_ gesture:UILongPressGestureRecognizer){if gesture.state == .began {onAction?(.clear)}}
    private func rebuildChoices(_ values:[Int64]) {
        lastChoices=values;buttons.removeAll{variantButtons.contains($0)};variantButtons.removeAll()
        choices.arrangedSubviews.forEach{choices.removeArrangedSubview($0);$0.removeFromSuperview()}
        // Android rotates each upper player's choice in place, preserving choice order.
        variantValues=lastPlayer == 1 ? Array(values.reversed()):values
        for pair in stride(from:0,to:variantValues.count,by:2) {
            let row=UIStackView();row.axis = .horizontal;row.distribution = .fillEqually
            for index in pair..<min(pair+2,values.count) {
                let value=variantValues[index];let button=key(String(value)){[weak self] in self?.onAction?(.choice(value))}
                variantButtons.append(button);row.addArrangedSubview(button)
            }
            choices.addArrangedSubview(row)
        }
    }
}
