import UIKit

/// Android ColorSpectrumView: the same ten RGB stops and white/base/black intensity mapping.
final class ColorSpectrumControl: UIControl {
    private static let colors: [UIColor] = [0xB71C1C,0xBF360C,0xBA8700,0x558B2F,0x1B5E20,0x00838F,0x1565C0,0x3F51B5,0x6A1B9A,0xAD1457].map { ThemeColor.rgb($0) }
    private static let stops: [CGFloat] = [0,0.10,0.20,0.32,0.43,0.55,0.68,0.79,0.90,1]
    private var intensityBase: UIColor?
    private var range: ClosedRange<CGFloat> = 0...1
    private(set) var position: CGFloat = 0
    private(set) var color = ThemeColor.hex("0D47A1")
    private var gradient: CGGradient?
    private(set) var isAdjusting = false
    private var track: CGRect { CGRect(x:21,y:bounds.midY-12,width:max(0,bounds.width-42),height:24) }
    private var rtl: Bool { effectiveUserInterfaceLayoutDirection == .rightToLeft }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        isAccessibilityElement = true
        accessibilityTraits = .adjustable
        contentMode = .redraw
        updateGradient()
    }
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: 64) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setColor(_ color: UIColor) {
        intensityBase = nil
        self.color = color
        let (r,g,b,_) = ThemeColor.components(color)
        var best = CGFloat.greatestFiniteMagnitude
        for i in 0...1000 {
            let p = CGFloat(i)/1000, (x,y,z,_) = ThemeColor.components(colorAt(p))
            let distance = pow(x-r,2)+pow(y-g,2)+pow(z-b,2)
            if distance < best { best = distance; position = p }
        }
        updateGradient()
    }

    func setIntensity(base: UIColor, theme: AppTheme, percent: Int) {
        let changed = intensityBase != base || range != theme.intensityRange
        intensityBase = base
        range = theme.intensityRange
        position = CGFloat(percent)/100
        color = colorAt(position)
        if changed { updateGradient() } else { updateValue() }
    }

    private func colorAt(_ p: CGFloat) -> UIColor {
        if let intensityBase { return ThemeColor.intensity(intensityBase, range.lowerBound+(range.upperBound-range.lowerBound)*p) }
        for i in 1..<Self.stops.count where p <= Self.stops[i] {
            return ThemeColor.blend(Self.colors[i-1],Self.colors[i],(p-Self.stops[i-1])/(Self.stops[i]-Self.stops[i-1]))
        }
        return Self.colors.last!
    }

    private func updateGradient() {
        let colors: [UIColor], stops: [CGFloat]
        if let intensityBase {
            if range.lowerBound < 0.5 && range.upperBound > 0.5 {
                colors = [colorAt(0),intensityBase,colorAt(1)]
                stops = [0,(0.5-range.lowerBound)/(range.upperBound-range.lowerBound),1]
            } else { colors = [colorAt(0),colorAt(1)]; stops = [0,1] }
        } else { colors = Self.colors; stops = Self.stops }
        gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map(\.cgColor) as CFArray, locations: stops)
        updateValue()
    }
    private func updateValue() {
        accessibilityValue = intensityBase == nil ? "#"+ThemeColor.hexString(color) : "\(Int((position*100).rounded()))%"
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let gradient else { return }
        context.saveGState()
        context.addPath(UIBezierPath(roundedRect: track,cornerRadius:12).cgPath)
        context.clip()
        context.drawLinearGradient(gradient, start: CGPoint(x:rtl ? track.maxX : track.minX,y:0), end: CGPoint(x:rtl ? track.minX : track.maxX,y:0),options:[])
        context.restoreGState()
        let x = track.minX+track.width*(rtl ? 1-position : position), y = track.midY
        let circles: [(CGFloat,CGFloat,UIColor)] = [(19,1,UIColor.black.withAlphaComponent(96/255)),(17,0,.white),(13,0,color)]
        for (radius,offset,fill) in circles {
            context.setFillColor(fill.cgColor)
            context.fillEllipse(in:CGRect(x:x-radius,y:y-radius+offset,width:radius*2,height:radius*2))
        }
    }
    private func select(_ value: CGFloat) {
        position = min(1,max(0,value)); color = colorAt(position)
        updateValue(); sendActions(for:.valueChanged)
    }
    private func select(_ touch: UITouch) {
        guard track.width > 0 else { return }
        let p = (touch.location(in:self).x-track.minX)/track.width
        select(rtl ? 1-p : p)
    }
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard isEnabled else { return false }; isAdjusting = true; select(touch); return true
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool { select(touch); return true }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch { select(touch) }; isAdjusting = false; sendActions(for:.editingDidEnd)
    }
    override func cancelTracking(with event: UIEvent?) { isAdjusting = false; sendActions(for:.editingDidEnd) }
    override func accessibilityIncrement() { if isEnabled { select(position+0.025) } }
    override func accessibilityDecrement() { if isEnabled { select(position-0.025) } }
}
