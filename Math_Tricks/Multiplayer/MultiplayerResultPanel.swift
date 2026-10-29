import UIKit

/// Android keeps both result sections stacked, with side buttons in landscape.
final class MultiplayerResultPanel: UIView {
    var onRetry: (() -> Void)?
    var onExit: (() -> Void)?
    private let player: Int
    private let card = UIView()
    private let surface = ThemeExpressionSurfaceView()
    private let scroll = AppScrollView()
    private let text = UILabel()
    private var settings = AppSettings()
    private lazy var retry = AppButton(title: CatalogText.ui("retry"), icon: .retry, kind: .iconSurface) { [weak self] in self?.onRetry?() }
    private lazy var exit = AppButton(title: CatalogText.ui("back"), icon: .backward, kind: .iconSurface) { [weak self] in self?.onExit?() }

    init(player: Int) {
        self.player = player
        super.init(frame: .zero)
        addSubview(card); card.addSubview(surface); card.addSubview(scroll); scroll.addSubview(text)
        text.numberOfLines = 0; text.textAlignment = .center
        card.clipsToBounds = true
        for button in [retry,exit] {
            button.translatesAutoresizingMaskIntoConstraints = true
            button.setContentInsets(UIEdgeInsets(top:18,left:18,bottom:18,right:18),minimumHeight:48)
            addSubview(button)
            if player == 1 { button.transform = CGAffineTransform(rotationAngle:.pi) }
        }
        if player == 1 { card.transform = CGAffineTransform(rotationAngle:.pi) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: NSAttributedString, settings: AppSettings, enabled: Bool) {
        self.settings = settings
        self.text.attributedText = text
        let palette = ThemePalette(settings:settings)
        surface.isHidden = palette.theme.isClassic
        surface.apply(settings:settings,accent:ThemeColor.rgb(player == 0 ? 0x385AA6 : 0xE53935))
        for button in [retry,exit] { button.apply(settings:settings,tint:palette.accent); button.isEnabled = enabled }
        setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let landscape = (window?.bounds.width ?? UIScreen.main.bounds.width) > (window?.bounds.height ?? UIScreen.main.bounds.height)
        let buttonWidth = AndroidDimensions.value("theme_alert_dialog_b_width",traits:traitCollection,fallback:132)
        let buttonHeight: CGFloat = 51
        let cardFrame: CGRect
        if landscape {
            let width = min(buttonWidth,max(48,bounds.width / 3))
            let height = min(buttonHeight,max(0,bounds.height / 2))
            let x = max(0,bounds.width - width - 8), y = (bounds.height - 2 * height) / 2
            retry.bounds = CGRect(x:0,y:0,width:width,height:height);retry.center = CGPoint(x:x + width / 2,y:y + height / 2)
            exit.bounds = retry.bounds;exit.center = CGPoint(x:retry.center.x,y:y + 1.5 * height)
            cardFrame = CGRect(x:8,y:2,width:max(0,x - 12),height:max(0,bounds.height - 4))
        } else {
            let width = min(buttonWidth,max(0,(bounds.width - 16) / 2))
            let height = min(buttonHeight,bounds.height / 2)
            let y: CGFloat = player == 1 ? 0 : bounds.height - height
            let left = player == 1 ? retry : exit, right = player == 1 ? exit : retry
            left.bounds = CGRect(x:0,y:0,width:width,height:height);left.center = CGPoint(x:bounds.midX - width / 2,y:y + height / 2)
            right.bounds = left.bounds;right.center = CGPoint(x:bounds.midX + width / 2,y:left.center.y)
            cardFrame = CGRect(x:8,y:player == 1 ? height + 4 : 4,width:max(0,bounds.width - 16),height:max(0,bounds.height - height - 8))
        }
        card.bounds = CGRect(origin:.zero,size:cardFrame.size); card.center = CGPoint(x:cardFrame.midX,y:cardFrame.midY)
        surface.frame = card.bounds
        let inset = UIEdgeInsets(top:landscape ? 6 : 14,left:landscape ? 12 : 16,bottom:landscape ? 6 : 14,right:landscape ? 12 : 16)
        scroll.frame = card.bounds.inset(by:inset)
        let width = max(0,scroll.bounds.width - 12)
        let height = max(scroll.bounds.height,text.sizeThatFits(CGSize(width:width,height:.greatestFiniteMagnitude)).height + 12)
        text.frame = CGRect(x:6,y:0,width:width,height:height)
        scroll.contentSize = CGSize(width:scroll.bounds.width,height:height)
    }
}
