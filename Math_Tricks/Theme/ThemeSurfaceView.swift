import UIKit

/// Native counterpart of Aurora shape drawables and NeonSurfaceDrawable.
final class ThemeSurfaceView: UIView {
    enum Mode { case button, icon, card, dialog }
    private let mode: Mode
    private var palette = ThemePalette(settings: AppSettings())
    private let image = UIImageView()
    private var pressed = false
    private var enabled = true

    init(_ mode: Mode) {
        self.mode = mode
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isOpaque = false
        // Repaint rounded surfaces after layout changes instead of scaling an old drawing.
        contentMode = .redraw
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor), image.bottomAnchor.constraint(equalTo: bottomAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor), image.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        updateImage()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(settings: AppSettings, pressed: Bool = false, enabled: Bool = true) {
        palette = ThemePalette(settings: settings)
        self.pressed = pressed
        self.enabled = enabled
        updateImage()
        setNeedsDisplay()
    }

    private func updateImage() {
        image.isHidden = mode == .dialog || !palette.theme.isClassic || mode == .icon
        if mode == .dialog && palette.theme == .light { image.image = AndroidImages.dialog }
        else if palette.theme == .dark { image.image = pressed ? AndroidImages.darkPressedButton : AndroidImages.darkButton }
        else { image.image = pressed ? AndroidImages.pressedButton : AndroidImages.button }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        if mode == .dialog {
            let panel = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 20)
            context.addPath(panel.cgPath)
            context.setFillColor(palette.dialogBackground.cgColor)
            context.setStrokeColor(palette.divider.cgColor)
            context.setLineWidth(1)
            context.drawPath(using: .fillStroke)
            return
        }
        if palette.theme.isClassic {
            if mode == .icon && pressed {
                context.setFillColor(palette.text.withAlphaComponent(0.15).cgColor)
                context.fillEllipse(in: bounds)
            }
            return
        }
        let inset: CGFloat = mode == .button ? 3 : 0
        let box = bounds.insetBy(dx: inset+0.5, dy: inset+0.5)
        guard box.width > 0, box.height > 0 else { return }
        let radius: CGFloat = mode == .dialog ? 20 : 12
        let path = UIBezierPath(roundedRect: box, cornerRadius: radius)
        var fill = mode == .icon ? UIColor.clear : palette.surface
        var border = mode == .icon ? UIColor.clear : palette.divider
        if palette.theme == .neon {
            let active = pressed
            let stroke: CGFloat = !enabled ? 14 : active ? 180 : mode == .icon ? 0 : mode == .button ? 40 : 68
            border = palette.selected.withAlphaComponent(stroke/255)
            if active && mode != .card { fill = ThemeColor.blend(ThemeColor.rgb(0x0A1220), palette.selected, 0.10).withAlphaComponent(218/255) }
            if mode != .icon || active {
                context.addPath(path.cgPath)
                context.setStrokeColor(palette.selected.withAlphaComponent(active ? 36/255 : 3/255).cgColor)
                context.setLineWidth(active ? 6 : 3)
                context.strokePath()
            }
        } else if pressed {
            fill = ThemeColor.blend(fill, palette.accent, palette.theme.isDark ? 0.14 : 0.08)
        }
        context.addPath(path.cgPath)
        context.setFillColor(fill.cgColor)
        context.setStrokeColor(border.cgColor)
        context.setLineWidth(1)
        context.drawPath(using: .fillStroke)
    }
}
