import UIKit

/// Fits both sides with the same scale, preserving the Android inline expression.
final class FittingMathExpressionView: UIView {
    var fillsSurface = false { didSet {setNeedsLayout()} }
    private let equation: AppLabel
    private let answer: AppLabel
    private var baseFont: UIFont?
    private var exampleID: String?
    private let surface=ThemeExpressionSurfaceView()
    private let playerSurface = UIView()
    private var multiplayer = false
    private var multiplayerClassic = false
    init(equation: AppLabel, answer: AppLabel) {
        self.equation=equation;self.answer=answer
        super.init(frame:.zero)
        translatesAutoresizingMaskIntoConstraints=false
        semanticContentAttribute = .forceLeftToRight
        playerSurface.isUserInteractionEnabled = false; playerSurface.isHidden = true
        addSubview(playerSurface); addSubview(surface)
        for label in [equation,answer] {label.numberOfLines=1;addSubview(label)}
    }
    required init?(coder:NSCoder){fatalError("init(coder:) has not been implemented")}
    func apply(settings:AppSettings,role:AppTextRole = .expression,accent:UIColor? = nil,player:Int? = nil) {
        baseFont=AppTypography.font(role,settings:settings,traits:traitCollection)
        let palette = ThemePalette(settings:settings)
        multiplayer = player != nil; multiplayerClassic = multiplayer && palette.theme.isClassic
        playerSurface.isHidden = !multiplayerClassic; surface.isHidden = multiplayerClassic
        let borderColor = player.map { ThemeColor.rgb($0 == 0 ? 0x385AA6 : 0xE53935) }
        if let player {
            playerSurface.backgroundColor = ThemeColor.rgb(player == 0 ? 0x1565C0 : 0x992424)
            let foreground: UIColor = palette.theme == .light ? .white : palette.text
            equation.textColor = foreground; answer.textColor = foreground
        }
        surface.apply(settings:settings,accent:borderColor ?? accent)
        setNeedsLayout()
    }
    func animateNewExample(id: String) {
        let previous = exampleID
        exampleID = id
        guard let previous, previous != id, window != nil else { return }
        layoutIfNeeded()
        for label in [equation, answer] {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 0; animation.toValue = 1; animation.duration = 0.1
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            label.layer.add(animation, forKey: "newExample")
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let font=baseFont ?? equation.font ?? UIFont.systemFont(ofSize:40)
        let a=((equation.text ?? "") as NSString).size(withAttributes:[.font:font])
        let b=((answer.text ?? "") as NSString).size(withAttributes:[.font:font])
        let verticalPadding: CGFloat = multiplayer && !multiplayerClassic ? 32 : 16
        let scale=min(1,max(0.05,min(max(0,bounds.width-48)/max(1,a.width+b.width),max(0,bounds.height-verticalPadding)/max(1,max(a.height,b.height)))))
        let fitted=font.withSize(font.pointSize*scale)
        if equation.font != fitted {equation.font=fitted;answer.font=fitted}
        let start=max(0,(bounds.width-(a.width+b.width)*scale)/2)
        let width=min(bounds.width,max(0,(a.width+b.width)*scale+48)),height=min(bounds.height,max(a.height,b.height)*scale+16)
        if multiplayer {
            let panelHeight = min(bounds.height,max(a.height,b.height)*scale+verticalPadding)
            let inset: CGFloat = multiplayerClassic ? 1 : 0
            let panel = CGRect(x:inset,y:(bounds.height-panelHeight)/2,width:max(0,bounds.width-2*inset),height:panelHeight)
            surface.frame = panel; playerSurface.frame = panel
        } else {
            surface.frame=fillsSurface ? bounds: CGRect(x:(bounds.width-width)/2,y:(bounds.height-height)/2,width:width,height:height)
        }
        equation.frame=CGRect(x:start,y:0,width:a.width*scale,height:bounds.height)
        answer.frame=CGRect(x:start+a.width*scale,y:0,width:b.width*scale,height:bounds.height)
    }
}
