import UIKit

final class FontScaleMarker: UIView {
    var percent = 100 { didSet { setNeedsDisplay() } }
    var markerX: CGFloat? { didSet { if oldValue != markerX { setNeedsDisplay() } } }
    override var tintColor: UIColor! { didSet { setNeedsDisplay() } }
    override init(frame: CGRect) { super.init(frame: frame); isOpaque = false; isAccessibilityElement = false }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let fraction = CGFloat(min(200, max(80, percent)) - 80) / 120
        let position = effectiveUserInterfaceLayoutDirection == .rightToLeft ? 1 - fraction : fraction
        let x = markerX ?? (2 + max(0, bounds.width - 4) * position)
        context.setStrokeColor((tintColor ?? .label).cgColor); context.setLineWidth(2)
        context.move(to: CGPoint(x: x, y: 0)); context.addLine(to: CGPoint(x: x, y: 10)); context.strokePath()
    }
}
