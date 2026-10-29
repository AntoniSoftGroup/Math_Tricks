import UIKit

/// Shared touch and pointer feedback, including rows with opaque artwork.
final class AppListHighlightView: UIView {
    private var active = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        alpha = 0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    static func color(settings: AppSettings, groupID: Int? = nil) -> UIColor {
        let palette = ThemePalette(settings: settings)
        let accent = groupID.map { TrainingCatalogAppearance.foreground($0, settings: settings) } ?? palette.accent
        return ThemeColor.blend(accent, palette.theme.isDark ? .white : .black,
                                palette.theme.isDark ? 0.45 : 0.25)
            .withAlphaComponent(palette.theme.isDark ? 0.24 : 0.18)
    }
    func apply(settings: AppSettings, groupID: Int? = nil) {
        backgroundColor = Self.color(settings: settings, groupID: groupID)
    }
    func setActive(_ active: Bool) {
        guard active != self.active else { return }
        self.active = active
        layer.removeAllAnimations()
        if active { alpha = 1 }
        else {
            UIView.animate(withDuration: UIAccessibility.isReduceMotionEnabled ? 0 : 0.15,
                           delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                self.alpha = 0
            }
        }
    }
    func reset() {
        active = false
        layer.removeAllAnimations()
        alpha = 0
    }
}

/// Stack-based lists share the same feedback as table and collection rows.
class AppListRow: UIControl {
    private let selectionOverlay = AppListHighlightView()
    private var hovering = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(selectionOverlay)
        addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(hoverChanged(_:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func applyHighlight(settings: AppSettings) {
        selectionOverlay.apply(settings: settings)
        refreshHighlight()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionOverlay.frame = bounds
        bringSubviewToFront(selectionOverlay)
    }
    override var isHighlighted: Bool { didSet { refreshHighlight() } }
    override var isEnabled: Bool { didSet { refreshHighlight() } }
    override var isUserInteractionEnabled: Bool { didSet { refreshHighlight() } }
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isHighlighted = true; return true
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isHighlighted = bounds.contains(touch.location(in: self)); return true
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) { isHighlighted = false }
    override func cancelTracking(with event: UIEvent?) { isHighlighted = false }
    @objc private func hoverChanged(_ gesture: UIHoverGestureRecognizer) {
        hovering = gesture.state == .began || gesture.state == .changed
        refreshHighlight()
    }
    private func refreshHighlight() {
        selectionOverlay.setActive(isEnabled && isUserInteractionEnabled && (isHighlighted || hovering))
    }
}

class AppListCell: UITableViewCell {
    private let selectionOverlay = AppListHighlightView()
    private var highlightEnabled = true
    private var hovering = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        installOverlay()
        addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(hoverChanged(_:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func applyHighlight(settings: AppSettings, groupID: Int? = nil, enabled: Bool = true) {
        highlightEnabled = enabled
        selectionOverlay.apply(settings: settings, groupID: groupID)
        installOverlay()
        updateHighlight()
    }
    private func installOverlay() {
        if selectionOverlay.superview !== contentView { contentView.addSubview(selectionOverlay) }
        selectionOverlay.frame = contentView.bounds
        contentView.bringSubviewToFront(selectionOverlay)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        installOverlay()
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateHighlight()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateHighlight()
    }
    @objc private func hoverChanged(_ gesture: UIHoverGestureRecognizer) {
        hovering = gesture.state == .began || gesture.state == .changed
        updateHighlight()
    }
    private func updateHighlight() {
        selectionOverlay.setActive(highlightEnabled && (isHighlighted || isSelected || hovering))
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        hovering = false
        selectionOverlay.reset()
    }
}
