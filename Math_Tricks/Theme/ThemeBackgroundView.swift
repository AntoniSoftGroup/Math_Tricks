import UIKit
import Combine

private final class ThemeFrameTarget: NSObject {
    weak var owner: ThemeBackgroundView?
    @objc func frame(_ link: CADisplayLink) { owner?.frame(link) }
}

/// One continuous activity background. Hidden previews never own a running frame loop.
final class ThemeBackgroundView: UIView {
    private var palette = ThemePalette(settings: AppSettings())
    private let staticBackground = CALayer()
    private let timelyLayers = TimelyBackgroundLayers()
    private let neonLayers = NeonBackgroundLayers()
    private var link: CADisplayLink?
    private let target = ThemeFrameTarget()
    private var observations = Set<AnyCancellable>()
    private var hostVisible = false
    private var lifecycleActive = true
    private var lastFrame: CFTimeInterval = 0
    private var transition: (from: UIColor, fromIntensity: Int, progress: Double)?
    private var displayedColor = ThemeColor.hex("0D47A1")
    private var paintedIntensity = 0
    private var timelyHue: CGFloat = 198/360
    private var base: CGGradient?
    private var light: CGGradient?
    private var secondary: CGGradient?
    private var glow: CGGradient?
    private var streak: CGGradient?
    private var grid: CGPath?
    private var timelyParticles: CGImage?
    private var gridScale: CGFloat = 0
    private var neonPaintColor: UIColor?
    private var timelyPaint: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat)?
    private var timelyBaseColors: [CGColor] = []
    private var timelyLightColor = UIColor.clear
    private static let neonBase = gradient([ThemeColor.rgb(0x10172C), ThemeColor.rgb(0x060A17), ThemeColor.rgb(0x02030A)], [0,0.45,1])
    private var gridSize = CGSize.zero
    private var bubbles: [[CGFloat]] = []
    private var comets: [[CGFloat]] = []
    private let bubbleGradient = ThemeBackgroundView.gradient([.white.withAlphaComponent(18/255), .white.withAlphaComponent(6/255), .white.withAlphaComponent(34/255), .clear], [0,0.72,0.9,1])
    private let cometGradient = ThemeBackgroundView.gradient([.clear, .white.withAlphaComponent(12/255), .white.withAlphaComponent(128/255)], [0,0.7,1])

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        accessibilityElementsHidden = true
        clipsToBounds = true
        isOpaque = true
        // Static decorative gradients do not need a full Retina backing store.
        if !ThemeMotion.supported { contentScaleFactor = 1 }
        staticBackground.backgroundColor = palette.background.cgColor
        layer.addSublayer(staticBackground)
        layer.addSublayer(timelyLayers)
        layer.addSublayer(neonLayers)
        target.owner = self
        // java.util.Random(1701), preserving Android's particle arrangement.
        var seed: UInt64 = (1701 ^ 0x5DEECE66D) & ((1 << 48) - 1)
        func random() -> CGFloat {
            seed = (seed &* 0x5DEECE66D &+ 11) & ((1 << 48) - 1)
            return CGFloat(seed >> 24) / 16777216
        }
        for _ in 0..<9 { bubbles.append([random(), random(), 0.018 + random()*0.075, 35 + random()*60, 0.35 + random()*0.5]) }
        for _ in 0..<3 { comets.append([random(), random(), 8 + random()*12, 0.09 + random()*0.18]) }
        // Capture the visible frame synchronously, before UIKit snapshots or detaches layers.
        for name in [UIApplication.willResignActiveNotification, UIApplication.didEnterBackgroundNotification,
                     UIScene.willDeactivateNotification, UIScene.didEnterBackgroundNotification] {
            NotificationCenter.default.publisher(for: name)
                .sink { [weak self] notification in self?.updateLifecycle(notification, active: false) }
                .store(in: &observations)
        }
        for name in [UIApplication.didBecomeActiveNotification, UIScene.didActivateNotification] {
            NotificationCenter.default.publisher(for: name)
                .sink { [weak self] notification in self?.updateLifecycle(notification, active: true) }
                .store(in: &observations)
        }
        for name in [UIApplication.willEnterForegroundNotification, UIScene.willEnterForegroundNotification] {
            NotificationCenter.default.publisher(for: name)
                .sink { [weak self] notification in self?.updateLifecycle(notification, active: nil) }
                .store(in: &observations)
        }
        for name in [UIAccessibility.reduceMotionStatusDidChangeNotification,
                     Notification.Name.NSProcessInfoPowerStateDidChange] {
            NotificationCenter.default.publisher(for: name).receive(on: RunLoop.main)
                .sink { [weak self] _ in self?.updateMotion() }.store(in: &observations)
        }
        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in self?.grid = nil; self?.timelyParticles = nil }.store(in: &observations)
        updatePaints(color: displayedColor, intensity: palette.intensity)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit { link?.invalidate() }

    func apply(settings: AppSettings) {
        let next = ThemePalette(settings: settings)
        guard next.theme != palette.theme || next.selected != palette.selected || next.intensity != palette.intensity else {
            updateMotion()
            return
        }
        let sameTheme = next.theme == palette.theme
        let animate = sameTheme && palette.theme.isAnimated && canPresentMotion
        if !sameTheme { grid = nil; timelyParticles = nil; timelyPaint = nil; base = nil }
        transition = animate ? (displayedColor, paintedIntensity, 0) : nil
        palette = next
        updateStaticBackground(animated: sameTheme && hostVisible)
        if !animate { updatePaints(color: next.selected, intensity: next.intensity, force: true) }
        setNeedsDisplay()
        updateMotion()
    }

    func setHostVisible(_ visible: Bool) { hostVisible = visible; updateMotion() }
    override func didMoveToWindow() { super.didMoveToWindow(); updateMotion() }
    override var isHidden: Bool { didSet { updateMotion() } }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin(); CATransaction.setDisableActions(true)
        staticBackground.frame = bounds
        CATransaction.commit()
        let resized = gridSize != bounds.size || gridScale != contentScaleFactor
        if resized {
            grid = nil; timelyParticles = nil
            gridSize = bounds.size; gridScale = contentScaleFactor
        }
        updateTimelyLayers()
        updateNeonLayers()
        updateMotion()
        if resized { setNeedsDisplay() }
    }

    private func updateStaticBackground(animated: Bool) {
        let canAnimate = animated && !palette.theme.isAnimated && window != nil && !isHidden
        CATransaction.begin(); CATransaction.setDisableActions(true)
        staticBackground.isHidden = palette.theme.isAnimated
        ThemeColorTransition.apply(staticBackground, color: palette.background, animated: canAnimate)
        CATransaction.commit()
    }

    private func updateLifecycle(_ notification: Notification, active: Bool?) {
        if let scene = notification.object as? UIScene, let ownScene = window?.windowScene,
           scene !== ownScene { return }
        if let active { lifecycleActive = active }
        // Restore the paused composition before the first foreground frame is presented.
        updateTimelyLayers()
        updateNeonLayers()
        updateMotion()
    }

    private var canPresentMotion: Bool {
        lifecycleActive && hostVisible && window != nil && !isHidden && !bounds.isEmpty
            && window?.windowScene?.activationState == .foregroundActive
            && UIApplication.shared.applicationState == .active
            && palette.theme.isAnimated
    }

    private func updateMotion() {
        let visible = canPresentMotion
        let allowed = ThemeMotion.supported && visible
        // Hiding must be immediate: pausing the layer also freezes implicit animations.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        timelyLayers.isHidden = palette.theme != .aurora || !ThemeMotion.supported
        timelyLayers.setRunning(allowed && palette.theme == .aurora)
        neonLayers.isHidden = palette.theme != .neon || !ThemeMotion.supported
        neonLayers.setRunning(allowed && palette.theme == .neon)
        CATransaction.commit()
        // A short color transition is also available on devices with static particles.
        let needsFrames = visible && transition != nil
        if needsFrames && link == nil {
            let displayLink = CADisplayLink(target: target, selector: #selector(ThemeFrameTarget.frame(_:)))
            displayLink.preferredFramesPerSecond = 30
            displayLink.add(to: .main, forMode: .common)
            link = displayLink
            lastFrame = 0
        } else if !needsFrames {
            link?.invalidate()
            link = nil
            lastFrame = 0
            // Keep the displayed color and transition progress while the scene is paused.
        }
    }

    fileprivate func frame(_ displayLink: CADisplayLink) {
        let delta = lastFrame == 0 ? 0 : min(0.1, max(0, displayLink.timestamp - lastFrame))
        lastFrame = displayLink.timestamp
        if var change = transition {
            change.progress += delta / ThemeColorTransition.duration
            let t = min(1, change.progress), eased = ThemeColorTransition.eased(t)
            let color: UIColor
            if palette.theme == .aurora {
                let (h,s,v) = ThemeColor.hsv(change.from), (nh,ns,nv) = ThemeColor.hsv(palette.selected)
                let diff = (nh-h+1.5).truncatingRemainder(dividingBy: 1)-0.5
                color = UIColor(hue: (h+diff*eased+1).truncatingRemainder(dividingBy: 1), saturation: s+(ns-s)*eased, brightness: v+(nv-v)*eased, alpha: 1)
            } else { color = ThemeColor.blend(change.from, palette.selected, eased) }
            updatePaints(color: color, intensity: Int((CGFloat(change.fromIntensity) + CGFloat(palette.intensity-change.fromIntensity)*eased).rounded()), force: t >= 1)
            if !ThemeMotion.supported { setNeedsDisplay() }
            transition = t >= 1 ? nil : change
        }
        if transition == nil { updateMotion() }
    }

    private static func gradient(_ colors: [UIColor], _ locations: [CGFloat]) -> CGGradient {
        CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map(\.cgColor) as CFArray, locations: locations)!
    }

    private func updatePaints(color: UIColor, intensity: Int, force: Bool = false) {
        displayedColor = color
        paintedIntensity = intensity
        if palette.theme == .neon {
            if neonPaintColor == color && base != nil { return }
            neonPaintColor = color
            base = Self.neonBase
            if ThemeMotion.supported {
                updateNeonLayers()
                return
            }
            let (h,s,v) = ThemeColor.hsv(color)
            let other = UIColor(hue: (h-25/360+1).truncatingRemainder(dividingBy: 1), saturation: s, brightness: v, alpha: 1)
            secondary = Self.gradient([other.withAlphaComponent(56/255), other.withAlphaComponent(0)], [0,1])
            light = Self.gradient([color.withAlphaComponent(30/255), color.withAlphaComponent(0)], [0,1])
            glow = Self.gradient([color, color.withAlphaComponent(0)], [0,1])
            streak = Self.gradient([.clear, color.withAlphaComponent(38/255), color.withAlphaComponent(217/255), .white, color.withAlphaComponent(178/255), .clear], [0,0.2,0.5,0.7,0.8,1])
        } else if palette.theme == .aurora {
            var (h,s,_) = ThemeColor.hsv(color)
            if s == 0 { h = timelyHue } else if h >= 0.5 && h < 2/3 { h = min(2/3, h+12/360) }
            timelyHue = h
            let mapped = AppTheme.aurora.mappedIntensity(intensity)
            let saturation = min(1, mapped*2), brightness = min(1, (1-mapped)*2)
            if !force, let painted = timelyPaint {
                let hueDelta = abs(h-painted.hue)
                if min(hueDelta, 1-hueDelta) < 0.15/360 && abs(saturation-painted.saturation) < 0.001 && abs(brightness-painted.brightness) < 0.001 { return }
            }
            timelyPaint = (h, saturation, brightness)
            func tone(_ sat: CGFloat, _ value: CGFloat) -> UIColor {
                var v = value
                var result = UIColor(hue: h, saturation: sat*saturation, brightness: v, alpha: 1)
                while 1.05 / (ThemeColor.luminance(result)+0.05) < 5.6 {
                    v *= 0.96
                    result = UIColor(hue: h, saturation: sat*saturation, brightness: v, alpha: 1)
                }
                result = ThemeColor.blend(result, .white, 1-saturation)
                return ThemeColor.blend(.black, result, brightness)
            }
            let colors = [tone(0.82,0.13), tone(0.9,0.43), tone(0.88,0.25)]
            let bright = tone(0.82,0.78)
            timelyBaseColors = colors.map(\.cgColor)
            timelyLightColor = bright
            if !ThemeMotion.supported {
                base = Self.gradient(colors, [0,0.63,1])
                light = Self.gradient([bright, bright.withAlphaComponent(160/255), bright.withAlphaComponent(0)], [0,0.42,1])
            }
            updateTimelyLayers()
        }
    }

    private func updateTimelyLayers() {
        guard ThemeMotion.supported, palette.theme == .aurora, !bounds.isEmpty else { return }
        timelyLayers.configure(size: bounds.size, baseColors: timelyBaseColors, lightColor: timelyLightColor,
                               bubble: bubbleGradient, comet: cometGradient,
                               bubbles: bubbles, comets: comets)
    }

    private func updateNeonLayers() {
        guard ThemeMotion.supported, palette.theme == .neon, !bounds.isEmpty else { return }
        neonLayers.configure(size: bounds.size, color: displayedColor)
    }

    private func radial(_ context: CGContext, _ gradient: CGGradient?, x: CGFloat, y: CGFloat, radius: CGFloat, alpha: CGFloat = 1) {
        guard let gradient, radius > 0 else { return }
        context.saveGState()
        context.setAlpha(alpha)
        context.drawRadialGradient(gradient, startCenter: CGPoint(x:x,y:y), startRadius: 0, endCenter: CGPoint(x:x,y:y), endRadius: radius, options: [])
        context.restoreGState()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), bounds.width > 0, bounds.height > 0 else { return }
        let w = bounds.width, h = bounds.height
        context.setFillColor(palette.background.cgColor)
        context.fill(bounds)
        switch palette.theme {
        case .neon:
            if !ThemeMotion.supported { drawStaticNeon(context, w, h) }
        case .aurora:
            if !ThemeMotion.supported { drawStaticTimely(context, w, h) }
        default: break // Android's current Aura Light/Dark have zero decorative blobs.
        }
    }

    /// Old devices keep the complete Timely appearance without an animation loop.
    private func drawStaticTimely(_ c: CGContext, _ w: CGFloat, _ h: CGFloat) {
        if let base {
            c.drawLinearGradient(base, start: .zero, end: CGPoint(x: w, y: h),
                                 options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
        radial(c, light, x: w * 0.87, y: h * 0.92, radius: max(w, h) * 0.9, alpha: 205.0 / 255)
        if timelyParticles == nil {
            let format = UIGraphicsImageRendererFormat()
            format.scale = contentScaleFactor; format.opaque = false
            timelyParticles = UIGraphicsImageRenderer(size: bounds.size, format: format).image { output in
                drawTimelyParticles(output.cgContext, w, h)
            }.cgImage
        }
        if let timelyParticles {
            UIImage(cgImage: timelyParticles, scale: contentScaleFactor, orientation: .up).draw(in: bounds)
        }
    }

    /// These white decorations are independent of the selected hue and intensity.
    private func drawTimelyParticles(_ c: CGContext, _ w: CGFloat, _ h: CGFloat) {
        let short = min(w, h)
        for bubble in bubbles {
            let r = short * bubble[2]
            let x = w * (bubble[0] + 0.035 * sin(bubble[1] * 12))
            let y = h + r * 2 - bubble[1] * (h + r * 4)
            radial(c, bubbleGradient, x: x, y: y, radius: r, alpha: bubble[4])
        }
        for comet in comets {
            let progress = comet[0], length = w * comet[3]
            let x = -length + progress * (w + length * 2), y = h * comet[1]
            let thickness = max(0.8, short * 0.0018), fade = pow(sin(progress * .pi), 2)
            c.saveGState()
            c.addPath(UIBezierPath(roundedRect: CGRect(x: x - length, y: y, width: length, height: thickness),
                                  cornerRadius: thickness).cgPath)
            c.clip(); c.setAlpha(120.0 / 255 * fade)
            c.drawLinearGradient(cometGradient, start: CGPoint(x: x - length, y: y),
                                 end: CGPoint(x: x, y: y), options: [])
            c.restoreGState()
            c.setFillColor(UIColor.white.withAlphaComponent(58.0 / 255 * fade).cgColor)
            c.fillEllipse(in: CGRect(x: x - thickness * 0.8, y: y - thickness * 0.3,
                                    width: thickness * 1.6, height: thickness * 1.6))
        }
    }

    private func drawStaticNeon(_ c: CGContext, _ w: CGFloat, _ h: CGFloat) {
        let t: Double = 0, wave: CGFloat = 0, scale: CGFloat = 1.035
        c.saveGState()
        c.translateBy(x:-0.015*w*wave+w/2,y:0.01*h*wave+h/2)
        c.scaleBy(x:scale,y:scale)
        c.translateBy(x:-w/2,y:-h/2)
        if let base { c.drawLinearGradient(base, start: .zero, end: CGPoint(x:w,y:h), options:[.drawsBeforeStartLocation,.drawsAfterEndLocation]) }
        radial(c, secondary, x:w*0.78,y:h*0.05,radius:max(w,h)*0.4)
        radial(c, light, x:w*0.05,y:h*0.82,radius:max(w,h)*0.5)
        c.restoreGState()
        drawStaticGlow(c, x:w-150, y:-80, size:350, alpha:0.17, dx:-130, dy:130, scale:1.18)
        drawStaticGlow(c, x:-150, y:h-40, size:290, alpha:0.10, dx:140, dy:-110, scale:0.9)
        drawStaticGlow(c, x:w*0.38, y:h*0.35, size:190, alpha:0.055, dx:80, dy:100, scale:1.3)
        if grid == nil { buildGrid() }
        if let grid {
            c.saveGState()
            c.addPath(grid); c.setLineWidth(1)
            c.setStrokeColor(displayedColor.withAlphaComponent(8/255).cgColor); c.strokePath()
            c.restoreGState()
        }
        guard let streak else { return }
        let streaks: [[CGFloat]] = [[180,180,0,1], [430,115,3.2,0.55], [555,220,4.7,0.30]]
        for s in streaks {
            let p = CGFloat((t+Double(s[2])).truncatingRemainder(dividingBy: 6)/6)
            let opacity: CGFloat = p < 0.12 ? p/0.12*0.75 : p < 0.78 ? 0.75-(p-0.12)/0.66*0.4 : 0.35*(1-(p-0.78)/0.22)
            c.saveGState()
            c.translateBy(x:p*(w+s[1]+300)-s[1]-150,y:s[0])
            c.rotate(by:-5 * .pi/180)
            c.clip(to:CGRect(x:0,y:-0.5,width:s[1],height:1))
            c.setAlpha(opacity*s[3])
            c.drawLinearGradient(streak, start:.zero,end:CGPoint(x:s[1],y:0),options:[])
            c.restoreGState()
        }
    }
    private func drawStaticGlow(_ context: CGContext, x: CGFloat, y: CGFloat, size: CGFloat, alpha: CGFloat, dx: CGFloat, dy: CGFloat, scale: CGFloat) {
        let progress: CGFloat = 0.5
        radial(context, glow, x:x+dx*progress, y:y+dy*progress, radius:size/2*(1+(scale-1)*progress), alpha:alpha)
    }
    private func buildGrid() {
        let path = CGMutablePath()
        for x in stride(from:CGFloat(0), to:bounds.width, by:35) { path.move(to:CGPoint(x:x,y:0)); path.addLine(to:CGPoint(x:x,y:bounds.height)) }
        for y in stride(from:CGFloat(0), to:bounds.height, by:35) { path.move(to:CGPoint(x:0,y:y)); path.addLine(to:CGPoint(x:bounds.width,y:y)) }
        grid = path
    }

}

/// Cached gradient textures move in the render server, independently of table scrolling.
private class AnimatedBackgroundLayers: CALayer {
    private struct Cycle {
        weak var layer: CALayer?
        let key: String
        let animation: CAKeyframeAnimation
    }
    private var cycles: [Cycle] = []
    private(set) var isRunning = true

    func setRunning(_ running: Bool) {
        CATransaction.begin(); CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }
        if !running && (isRunning || speed != 0) {
            let paused = convertTime(CACurrentMediaTime(), from: nil)
            preserveVisibleFrame()
            speed = 0; timeOffset = paused
        }
        // Restore on the paused timeline first, preserving each cycle's original beginTime.
        // Restarting at the current time would reset the light and particle phases.
        cycles.removeAll { $0.layer == nil }
        for cycle in cycles {
            guard let layer = cycle.layer, layer.animation(forKey: cycle.key) == nil else { continue }
            layer.add(cycle.animation, forKey: cycle.key)
        }
        if running && (!isRunning || speed != 1) {
            let paused = timeOffset
            speed = 1; timeOffset = 0; beginTime = 0
            beginTime = convertTime(CACurrentMediaTime(), from: nil) - paused
        }
        isRunning = running
    }

    private func preserveVisibleFrame() {
        var captured = Set<ObjectIdentifier>()
        for cycle in cycles {
            guard let layer = cycle.layer, captured.insert(ObjectIdentifier(layer)).inserted,
                  let displayed = layer.presentation() else { continue }
            // The model layer must also contain a complete frame if UIKit drops animations.
            layer.position = displayed.position
            layer.bounds = displayed.bounds
            layer.transform = displayed.transform
            layer.opacity = displayed.opacity
        }
    }

    func texture(size: CGSize, gradient: CGGradient?, radial: Bool) -> CGImage? {
        guard let gradient else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1; format.opaque = !radial
        return UIGraphicsImageRenderer(size: size, format: format).image { output in
            let c = output.cgContext
            if radial {
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                c.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                                     endCenter: center, endRadius: size.width / 2, options: [])
            } else {
                c.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height),
                                     options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
            }
        }.cgImage
    }

    func cycle(_ layer: CALayer, key: String, duration: Double, values: [Any], phase: Double = 0,
               keyTimes: [NSNumber]? = nil) {
        let animation = CAKeyframeAnimation(keyPath: key)
        animation.values = values; animation.duration = duration
        animation.keyTimes = keyTimes
        animation.repeatCount = .infinity; animation.calculationMode = .linear
        animation.fillMode = .both
        animation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        animation.timeOffset = phase * duration
        cycles.removeAll { $0.layer == nil || ($0.layer === layer && $0.key == key) }
        cycles.append(Cycle(layer: layer, key: key, animation: animation))
        layer.add(animation, forKey: key)
    }
}

/// Neon uses one cached radial mask; color changes only update layer tints.
private final class NeonBackgroundLayers: AnimatedBackgroundLayers {
    private let backdropGroup = CALayer()
    private let backdrop = CAGradientLayer()
    private let secondary = CALayer()
    private let light = CALayer()
    private let glows = (0..<3).map { _ in CALayer() }
    private let grid = CAShapeLayer()
    private let streaks = (0..<3).map { _ in CALayer() }
    private let streakPaints = (0..<3).map { _ in CAGradientLayer() }
    private var preparedSize = CGSize.zero
    private var preparedColor: UIColor?
    private static let radialMask: CGImage? = {
        let size = CGSize(width: 128, height: 128)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1; format.opaque = false
        let colors = [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) else { return nil }
        return UIGraphicsImageRenderer(size: size, format: format).image { output in
            let center = CGPoint(x: 64, y: 64)
            output.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                                                endCenter: center, endRadius: 64, options: [])
        }.cgImage
    }()

    override init() {
        super.init()
        masksToBounds = true
        addSublayer(backdropGroup)
        backdropGroup.addSublayer(backdrop)
        backdrop.colors = [0x10172C, 0x060A17, 0x02030A].map { ThemeColor.rgb(UInt32($0)).cgColor }
        backdrop.locations = [0, 0.45, 1]
        backdrop.startPoint = .zero; backdrop.endPoint = CGPoint(x: 1, y: 1)
        for radial in [secondary, light] + glows {
            let mask = CALayer(); mask.contents = Self.radialMask
            radial.mask = mask
        }
        backdropGroup.addSublayer(secondary)
        backdropGroup.addSublayer(light)
        for glow in glows { addSublayer(glow) }
        addSublayer(grid)
        grid.fillColor = nil; grid.lineWidth = 1
        for (sprite, paint) in zip(streaks, streakPaints) {
            addSublayer(sprite); sprite.addSublayer(paint)
            sprite.anchorPoint = CGPoint(x: 0, y: 0.5)
            sprite.transform = CATransform3DMakeRotation(-5 * .pi / 180, 0, 0, 1)
            paint.startPoint = CGPoint(x: 0, y: 0.5); paint.endPoint = CGPoint(x: 1, y: 0.5)
            paint.locations = [0, 0.2, 0.5, 0.7, 0.8, 1]
        }
    }
    override init(layer: Any) { super.init(layer: layer) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func placeRadial(_ layer: CALayer, center: CGPoint, radius: CGFloat) {
        layer.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        layer.position = center
        layer.mask?.frame = layer.bounds
    }

    func configure(size: CGSize, color: UIColor) {
        let resized = preparedSize != size
        guard resized || preparedColor != color else { return }
        CATransaction.begin(); CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }
        if preparedColor != color {
            preparedColor = color
            let (h, s, v) = ThemeColor.hsv(color)
            secondary.backgroundColor = UIColor(hue: (h - 25.0 / 360 + 1).truncatingRemainder(dividingBy: 1),
                                                saturation: s, brightness: v, alpha: 1).cgColor
            secondary.opacity = 56.0 / 255
            light.backgroundColor = color.cgColor; light.opacity = 30.0 / 255
            for glow in glows { glow.backgroundColor = color.cgColor }
            grid.strokeColor = color.withAlphaComponent(8.0 / 255).cgColor
            let colors = [UIColor.clear, color.withAlphaComponent(38.0 / 255), color.withAlphaComponent(217.0 / 255),
                          .white, color.withAlphaComponent(178.0 / 255), .clear].map(\.cgColor)
            for paint in streakPaints { paint.colors = colors }
        }
        guard resized else { return }
        preparedSize = size
        frame = CGRect(origin: .zero, size: size)
        let w = size.width, h = size.height
        backdropGroup.bounds = bounds; backdropGroup.position = CGPoint(x: w / 2, y: h / 2)
        backdrop.frame = bounds
        placeRadial(secondary, center: CGPoint(x: w * 0.78, y: h * 0.05), radius: max(w, h) * 0.4)
        placeRadial(light, center: CGPoint(x: w * 0.05, y: h * 0.82), radius: max(w, h) * 0.5)
        let wave = (0...120).map { CGFloat(sin(Double($0) / 120 * 2 * .pi)) }
        cycle(backdropGroup, key: "position", duration: 12, values: wave.map {
            NSValue(cgPoint: CGPoint(x: w / 2 - 0.015 * w * $0, y: h / 2 + 0.01 * h * $0))
        })
        cycle(backdropGroup, key: "transform.scale", duration: 12, values: wave.map { 1 + 0.07 * ($0 * 0.5 + 0.5) })
        let glowSettings: [(x: CGFloat, y: CGFloat, size: CGFloat, alpha: Float, dx: CGFloat, dy: CGFloat, scale: CGFloat, period: Double)] = [
            (w - 150, -80, 350, 0.17, -130, 130, 1.18, 14),
            (-150, h - 40, 290, 0.10, 140, -110, 0.9, 19),
            (w * 0.38, h * 0.35, 190, 0.055, 80, 100, 1.3, 16)
        ]
        for (glow, settings) in zip(glows, glowSettings) {
            placeRadial(glow, center: CGPoint(x: settings.x, y: settings.y), radius: settings.size / 2)
            glow.opacity = settings.alpha
            let progress = wave.map { $0 * 0.5 + 0.5 }
            cycle(glow, key: "position", duration: settings.period, values: progress.map {
                NSValue(cgPoint: CGPoint(x: settings.x + settings.dx * $0, y: settings.y + settings.dy * $0))
            })
            cycle(glow, key: "transform.scale", duration: settings.period,
                  values: progress.map { 1 + (settings.scale - 1) * $0 })
        }
        grid.frame = bounds
        let path = CGMutablePath()
        for x in stride(from: CGFloat(0), to: w, by: 35) {
            path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: h))
        }
        for y in stride(from: CGFloat(0), to: h, by: 35) {
            path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: w, y: y))
        }
        grid.path = path
        let streakSettings: [(y: CGFloat, length: CGFloat, delay: Double, alpha: Double)] = [
            (180, 180, 0, 1), (430, 115, 3.2, 0.55), (555, 220, 4.7, 0.30)
        ]
        for index in streaks.indices {
            let sprite = streaks[index], settings = streakSettings[index]
            sprite.bounds = CGRect(x: 0, y: 0, width: settings.length, height: 1)
            sprite.position = CGPoint(x: -settings.length - 150, y: settings.y)
            streakPaints[index].frame = sprite.bounds
            cycle(sprite, key: "position.x", duration: 6,
                  values: [-settings.length - 150, w + 150], phase: settings.delay / 6)
            cycle(sprite, key: "opacity", duration: 6,
                  values: [0, 0.75 * settings.alpha, 0.35 * settings.alpha, 0], phase: settings.delay / 6,
                  keyTimes: [0, 0.12, 0.78, 1])
        }
    }
}

private final class TimelyBackgroundLayers: AnimatedBackgroundLayers {
    private let backdrop = CAGradientLayer()
    private let illumination = CALayer()
    private var preparedSize = CGSize.zero
    private var preparedBaseColors: [CGColor] = []
    private var preparedLightColor: UIColor?

    override init() {
        super.init()
        masksToBounds = true
        addSublayer(backdrop)
        addSublayer(illumination)
        backdrop.locations = [0, 0.63, 1]
        backdrop.startPoint = .zero; backdrop.endPoint = CGPoint(x: 1, y: 1)
        let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(160.0 / 255).cgColor,
                      UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.42, 1])
        let mask = CALayer()
        mask.contents = texture(size: CGSize(width: 256, height: 256), gradient: gradient, radial: true)
        illumination.mask = mask
    }
    override init(layer: Any) { super.init(layer: layer) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(size: CGSize, baseColors: [CGColor], lightColor: UIColor, bubble: CGGradient,
                   comet: CGGradient, bubbles: [[CGFloat]], comets: [[CGFloat]]) {
        let resized = preparedSize != size
        guard resized || baseColors != preparedBaseColors || lightColor != preparedLightColor else { return }
        CATransaction.begin(); CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }
        frame = CGRect(origin: .zero, size: size)
        backdrop.frame = bounds
        backdrop.colors = baseColors
        illumination.backgroundColor = lightColor.cgColor
        preparedBaseColors = baseColors; preparedLightColor = lightColor
        guard resized else { return }
        preparedSize = size
        sublayers?.filter { $0 !== backdrop && $0 !== illumination }.forEach { $0.removeFromSuperlayer() }
        let w = size.width, h = size.height, short = min(w, h), radius = max(w, h) * 0.9
        illumination.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        illumination.mask?.frame = illumination.bounds
        illumination.position = CGPoint(x: w * 0.87, y: h * 0.8)
        cycle(illumination, key: "position.x", duration: 2 * .pi / 0.095,
              values: (0...180).map { w * (0.87 + sin(CGFloat($0) / 180 * 2 * .pi) * 0.13) })
        cycle(illumination, key: "position.y", duration: 2 * .pi / 0.075,
              values: (0...180).map { h * (0.8 + cos(CGFloat($0) / 180 * 2 * .pi) * 0.12) })
        cycle(illumination, key: "transform.scale", duration: 2 * .pi / 0.17,
              values: (0...120).map { 1 + sin(Double($0) / 120 * 2 * .pi) * 0.07 / 0.9 })
        cycle(illumination, key: "opacity", duration: 2 * .pi / 0.17,
              values: (0...120).map { (205 + sin(Double($0) / 120 * 2 * .pi) * 25) / 255 })
        let bubbleImage = texture(size: CGSize(width: 128, height: 128), gradient: bubble, radial: true)
        for particle in bubbles {
            let sprite = CALayer(), r = short * particle[2], period = Double(particle[3])
            sprite.contents = bubbleImage; sprite.opacity = Float(particle[4])
            sprite.bounds = CGRect(x: 0, y: 0, width: r * 2, height: r * 2)
            addSublayer(sprite)
            // A reset happens entirely outside the clipped screen.
            let positions: [Any] = (0...180).map { index in
                let progress = CGFloat(index) / 180
                let t = Double(progress) * period
                return NSValue(cgPoint: CGPoint(x: w * (particle[0] + 0.035 * sin(CGFloat(t * 0.12) + particle[1] * 12)),
                                               y: h + r * 2 - progress * (h + r * 4)))
            }
            cycle(sprite, key: "position", duration: period, values: positions, phase: Double(particle[1]))
        }
        let cometImage = texture(size: CGSize(width: 256, height: 4), gradient: comet, radial: false)
        for particle in comets {
            let sprite = CALayer(), length = w * particle[3], thickness = max(0.8, short * 0.0018)
            sprite.bounds = CGRect(x: 0, y: 0, width: length, height: thickness)
            let trail = CALayer()
            trail.frame = sprite.bounds; trail.contents = cometImage
            trail.cornerRadius = thickness / 2; trail.masksToBounds = true
            sprite.addSublayer(trail)
            let head = CALayer(), diameter = thickness * 1.6
            head.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            head.position = CGPoint(x: length, y: thickness / 2)
            head.cornerRadius = diameter / 2
            head.backgroundColor = UIColor.white.withAlphaComponent(58.0 / 120).cgColor
            sprite.addSublayer(head)
            sprite.position.y = h * particle[1]
            addSublayer(sprite)
            let period = Double(particle[2])
            cycle(sprite, key: "position.x", duration: period,
                  values: [-length * 1.5, w + length * 0.5], phase: Double(particle[0]))
            cycle(sprite, key: "opacity", duration: period,
                  values: (0...120).map { 120.0 / 255 * pow(sin(Double($0) / 120 * .pi), 2) },
                  phase: Double(particle[0]))
        }
    }
}
