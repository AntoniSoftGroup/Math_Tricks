import UIKit

final class SolutionStepRow: AppListRow {
    private let caption = UILabel()
    private let hint = UILabel()
    init(title: String, step: SolutionStep, settings: AppSettings, selected: Bool, action: @escaping () -> Void) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let content = UIStackView(); content.axis = .vertical; content.spacing = 0
        content.isUserInteractionEnabled = false; content.translatesAutoresizingMaskIntoConstraints = false
        caption.numberOfLines = 0; hint.numberOfLines = 0
        content.addArrangedSubview(caption); content.addArrangedSubview(hint)
        addSubview(content)
        NSLayoutConstraint.activate([content.topAnchor.constraint(equalTo:topAnchor,constant:10),content.bottomAnchor.constraint(equalTo:bottomAnchor,constant:-10),content.leadingAnchor.constraint(equalTo:leadingAnchor,constant:10),content.trailingAnchor.constraint(equalTo:trailingAnchor,constant:-10)])
        apply(title:title, step:step, settings:settings, selected:selected)
        addAction(UIAction { _ in action() },for:.touchUpInside)
    }
    func apply(title: String, step: SolutionStep, settings: AppSettings, selected: Bool) {
        applyHighlight(settings: settings)
        let palette = ThemePalette(settings: settings)
        let font = AppTypography.font(.body,settings:settings,traits:traitCollection)
        let foreground = selected ? palette.text : palette.secondary
        let text = NSMutableAttributedString(string:title + " - " + AndroidRichText.plain(step.description),attributes:[.font:font,.foregroundColor:foreground])
        let bold = AppTypography.font(.body,settings:settings,traits:traitCollection,weight:700)
        text.addAttributes([.font:bold,.foregroundColor:palette.text],range:NSRange(location:0,length:(title as NSString).length))
        caption.attributedText = text
        hint.isHidden = step.hintExpr.isEmpty; hint.text = "(" + step.hintExpr + ")"
        let hintFont = font.withSize(font.pointSize * 18 / 16)
        hint.font = hintFont.fontDescriptor.withSymbolicTraits(.traitItalic).map { UIFont(descriptor:$0,size:hintFont.pointSize) } ?? hintFont
        hint.textColor = foreground; hint.alpha = 0.8
        backgroundColor = selected ? palette.accent.withAlphaComponent(0.2) : .clear
        isAccessibilityElement = true; accessibilityLabel = title + " - " + AndroidRichText.plain(step.description) + " " + step.hintExpr
        accessibilityTraits = selected ? [.button,.selected] : .button
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
