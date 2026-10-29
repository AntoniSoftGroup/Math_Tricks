import UIKit

/// The same coloured, operand-dependent explanation shown by Android after a wrong Boolean choice.
final class BooleanSolutionLabel: UILabel {
    private let multiplayer: Bool
    private var renderedExample: MathExample?
    private var renderedSettings: AppSettings?
    private var renderedFont: UIFont?

    init(multiplayer: Bool = false) {
        self.multiplayer = multiplayer
        super.init(frame: .zero)
        numberOfLines = 0
        textAlignment = .left
        isHidden = true
        adjustsFontForContentSizeCategory = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Returns true when a new explanation enters, so its scroll view can return to the top.
    @discardableResult
    func configure(example: MathExample, settings: AppSettings, showing: Bool) -> Bool {
        guard showing else {
            isHidden = true
            layer.removeAnimation(forKey: "booleanSolutionEntrance")
            return false
        }
        let entering = isHidden || renderedExample != example
        isHidden = false
        let base = AppTypography.font(.body, settings: settings, traits: traitCollection)
        let size = AndroidDimensions.value(multiplayer ? "player_tv_trick_name" : "theme_alert_dialog_timer_end_tv_score_max",
                                           traits: traitCollection, fallback: multiplayer ? 15 : 20)
        let font = base.withSize(base.pointSize * size * 1.25 / AppTextRole.body.size)
        if renderedExample != example || renderedSettings != settings || renderedFont != font {
            renderedExample = example; renderedSettings = settings; renderedFont = font
            let html: String
            if let pointer = MTCreateBooleanSolution(Int32(example.trickID), example.operand1, example.operand2, example.answer) {
                html = String(cString: pointer)
                MTFreeBooleanSolution(pointer)
            } else {
                html = MathExpressionFormatter.text(example) + " = \(example.answer)"
            }
            attributedText = AndroidRichText.attributed(html, font: font, color: ThemePalette(settings: settings).text)
        }
        if entering, window != nil {
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.fromValue = superview?.bounds.width ?? bounds.width
            animation.toValue = 0
            animation.duration = 0.1
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            layer.add(animation, forKey: "booleanSolutionEntrance")
        }
        return entering
    }
}
