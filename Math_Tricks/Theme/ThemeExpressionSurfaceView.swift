import UIKit

/// Geometry and HSV sweep from Android AuroraBorderRelativeLayout.
final class ThemeExpressionSurfaceView: UIView {
    private var settings = AppSettings()
    private var accent: UIColor?
    private let classic = ThemeSurfaceView(.card)
    private let fill = CAGradientLayer()
    private let border = CALayer()
    private let sweep = CAGradientLayer()
    private let maskShape = CAShapeLayer()
    private let haloLayer = CALayer()
    private var geometryBounds = CGRect.null
    private var geometryRadius: CGFloat = 0
    private let halos = [CAShapeLayer(),CAShapeLayer(),CAShapeLayer()]
    private var observers: [NSObjectProtocol] = []
    var motionEnabled = true { didSet { updateMotion() } }
    override init(frame: CGRect) {
        super.init(frame: frame); isUserInteractionEnabled = false
        addSubview(classic)
        haloLayer.shouldRasterize = true
        haloLayer.rasterizationScale = traitCollection.displayScale
        layer.addSublayer(haloLayer)
        for halo in halos { halo.fillColor = UIColor.clear.cgColor; haloLayer.addSublayer(halo) }
        layer.addSublayer(fill); layer.addSublayer(border)
        sweep.type = .conic; sweep.startPoint = CGPoint(x:0.5,y:0.5); sweep.endPoint = CGPoint(x:0.5,y:0)
        maskShape.fillColor = UIColor.clear.cgColor; maskShape.strokeColor = UIColor.white.cgColor; maskShape.lineWidth = 1; border.mask = maskShape; border.addSublayer(sweep)
        for name in [UIApplication.didBecomeActiveNotification,UIApplication.willResignActiveNotification,UIScene.didActivateNotification,UIScene.willDeactivateNotification,UIWindow.didBecomeHiddenNotification,UIWindow.didBecomeVisibleNotification,Notification.Name.NSProcessInfoPowerStateDidChange,UIAccessibility.reduceMotionStatusDidChangeNotification] {
            observers.append(NotificationCenter.default.addObserver(forName:name,object:nil,queue:.main) { [weak self] _ in MainActor.assumeIsolated { self?.updateMotion() } })
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { observers.forEach(NotificationCenter.default.removeObserver) }
    func apply(settings: AppSettings,accent: UIColor? = nil) {
        guard settings != self.settings || accent != self.accent || sweep.colors == nil else { return }
        self.settings=settings; self.accent=accent
        let palette=ThemePalette(settings:settings), theme=palette.theme
        classic.apply(settings:settings); classic.isHidden = !theme.isClassic
        fill.isHidden=theme.isClassic; border.isHidden=theme.isClassic
        halos.forEach { $0.isHidden=theme.isClassic || theme == .aurora }
        let color=accent ?? palette.accent, (h,s,v)=ThemeColor.hsv(color)
        let colors: [UIColor]
        if theme == .aurora { colors=[.white.withAlphaComponent(48/255),.white.withAlphaComponent(48/255)] }
        else if theme == .neon {
            let neon=accent ?? palette.selected
            colors=[105,165,105,135,105].map { neon.withAlphaComponent(CGFloat($0)/255) }
        } else {
            let saturation=theme.isDark ? min(0.90,max(0.54,s*0.72)) : min(0.38,max(0.22,s*0.40))
            let brightness=theme.isDark ? max(0.82,min(v*1.05,1)) : max(0.70,min(v*0.80,0.78))
            colors=[-45.0,-20,0,25,50,25,-45].map { offset in
                s < 0.08 ? color : UIColor(hue:(h+CGFloat(offset)/360+1).truncatingRemainder(dividingBy:1),saturation:saturation,brightness:brightness,alpha:1)
            }
        }
        CATransaction.begin(); CATransaction.setDisableActions(true)
        sweep.colors=colors.map(\.cgColor)
        switch theme {
        case .aurora: fill.colors=[ThemeColor.rgb(0x020A14,alpha:16/255).cgColor,ThemeColor.rgb(0x020A14,alpha:40/255).cgColor]
        case .neon: fill.colors=[ThemeColor.rgb(0x030812,alpha:163/255).cgColor,ThemeColor.rgb(0x030812,alpha:163/255).cgColor]
        case .darkAurora: fill.colors=[ThemeColor.rgb(0x141720).cgColor,ThemeColor.rgb(0x0B0D13).cgColor]
        default: fill.colors=[UIColor.white.withAlphaComponent(248/255).cgColor,UIColor.white.withAlphaComponent(248/255).cgColor]
        }
        fill.startPoint=CGPoint(x:0,y:0);fill.endPoint=CGPoint(x:1,y:1)
        let haloColor=(accent ?? (theme == .neon ? palette.selected : color)).withAlphaComponent(theme == .neon ? 45/255 : 0.55)
        for (i,halo) in halos.enumerated() {
            halo.strokeColor=haloColor.withAlphaComponent(haloColor.cgColor.alpha * [0.32,0.48,0.65][i]).cgColor
            halo.lineWidth=[6,3.5,2][i];halo.shadowColor=haloColor.cgColor;halo.shadowOpacity=Float([0.32,0.48,0.65][i]);halo.shadowRadius=[4,2.5,1.2][i];halo.shadowOffset = .zero
        }
        CATransaction.commit();setNeedsLayout();updateMotion()
    }
    override func layoutSubviews() {
        super.layoutSubviews(); updateMotion()
        let radius: CGFloat = settings.theme == .neon ? 14 : 18
        let scale = max(1,traitCollection.displayScale)
        guard geometryBounds != bounds || geometryRadius != radius || haloLayer.rasterizationScale != scale else { return }
        geometryBounds = bounds; geometryRadius = radius
        CATransaction.begin(); CATransaction.setDisableActions(true)
        haloLayer.frame=bounds;haloLayer.rasterizationScale=scale
        classic.frame=bounds
        let box=bounds.insetBy(dx:8,dy:8)
        let path=UIBezierPath(roundedRect:box,cornerRadius:radius).cgPath
        fill.frame=box;fill.cornerRadius=radius
        border.frame=bounds;maskShape.frame=bounds;maskShape.path=path
        let side=hypot(bounds.width,bounds.height)
        sweep.bounds=CGRect(x:0,y:0,width:side,height:side);sweep.position=CGPoint(x:bounds.midX,y:bounds.midY)
        for halo in halos { halo.frame=bounds;halo.path=path;halo.shadowPath=path }
        CATransaction.commit()
    }
    override func didMoveToWindow() { super.didMoveToWindow();updateMotion() }
    override var isHidden: Bool { didSet { updateMotion() } }
    private func updateMotion() {
        var ancestor: UIView? = self
        while let view = ancestor {
            if view.isHidden || view.alpha == 0 { sweep.removeAnimation(forKey:"sweep"); return }
            ancestor = view.superview
        }
        let animated=settings.theme == .lightAurora || settings.theme == .darkAurora
        let enabled=ThemeMotion.supported && animated && motionEnabled && window?.isHidden == false && window?.windowScene?.activationState == .foregroundActive && UIApplication.shared.applicationState == .active
        if enabled && sweep.animation(forKey:"sweep") == nil {
            let animation=CABasicAnimation(keyPath:"transform.rotation.z")
            animation.fromValue=0;animation.toValue=Double.pi*2
            animation.duration=settings.theme == .darkAurora ? 7 : 6;animation.repeatCount = .infinity
            animation.preferredFrameRateRange = CAFrameRateRange(minimum:30,maximum:30,preferred:30)
            sweep.add(animation,forKey:"sweep")
        } else if !enabled { sweep.removeAnimation(forKey:"sweep") }
    }
}
