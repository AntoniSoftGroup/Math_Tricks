import UIKit

final class ByHeartRowCell: AppListCell {
    private let level = AppLabel(.catalogTrick, weight: 700)
    private let number = AppLabel(.catalogTrick)
    private let interval = AppLabel(.catalogTrick)
    private let score = AppLabel(.catalogTrick)
    private let icon = UIImageView()
    private let scoreBackground = UIImageView()
    private let scorePanel = UIView()
    private let expression = UIStackView()
    private let expressionHost = UIView()
    private var expressionPosition:NSLayoutConstraint?
    private let result = UIStackView()
    private let row = UIStackView()
    private var scoreSize: [NSLayoutConstraint] = []
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear; selectionStyle = .none
        expression.axis = .horizontal; expression.alignment = .center
        expression.addArrangedSubview(number); expression.addArrangedSubview(interval)
        scorePanel.addSubview(scoreBackground); scorePanel.addSubview(score)
        for view in [scoreBackground, score] {
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: scorePanel.topAnchor), view.bottomAnchor.constraint(equalTo: scorePanel.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: scorePanel.leadingAnchor), view.trailingAnchor.constraint(equalTo: scorePanel.trailingAnchor)])
        }
        score.textAlignment = .center; scoreBackground.contentMode = .scaleAspectFit
        result.alignment = .center; result.addArrangedSubview(scorePanel); result.addArrangedSubview(icon)
        row.axis = .horizontal; row.alignment = .center; row.spacing = 0
        expression.translatesAutoresizingMaskIntoConstraints=false;expressionHost.addSubview(expression)
        NSLayoutConstraint.activate([expression.centerYAnchor.constraint(equalTo:expressionHost.centerYAnchor),expression.topAnchor.constraint(greaterThanOrEqualTo:expressionHost.topAnchor),expression.bottomAnchor.constraint(lessThanOrEqualTo:expressionHost.bottomAnchor),
            expression.leadingAnchor.constraint(greaterThanOrEqualTo:expressionHost.leadingAnchor),expression.trailingAnchor.constraint(lessThanOrEqualTo:expressionHost.trailingAnchor)])
        row.addArrangedSubview(level); row.addArrangedSubview(expressionHost); row.addArrangedSubview(result)
        row.translatesAutoresizingMaskIntoConstraints = false; contentView.addSubview(row)
        for label in [level, number, interval, score] { label.numberOfLines = 1 }
        level.setContentHuggingPriority(.required, for: .horizontal)
        result.setContentHuggingPriority(.required, for: .horizontal)
        expressionHost.setContentHuggingPriority(.defaultLow, for: .horizontal)
        icon.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10), row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20), row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            expressionHost.heightAnchor.constraint(greaterThanOrEqualTo:expression.heightAnchor)])
        let iconWidth=icon.widthAnchor.constraint(equalToConstant:64),iconHeight=icon.heightAnchor.constraint(equalToConstant:25)
        iconWidth.priority = .init(999);iconHeight.priority = .init(999);NSLayoutConstraint.activate([iconWidth,iconHeight])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(level: String, number: Int, range: ClosedRange<Int>, score: String, icon: String?, highlight: Bool, settings: AppSettings) {
        applyHighlight(settings: settings)
        let palette = ThemePalette(settings: settings), isLevel = !level.isEmpty
        for label in [self.level, self.number, interval, self.score] { label.apply(settings: settings); label.textColor = palette.accent }
        self.number.textColor = palette.text
        self.level.text = level; self.level.isHidden = !isLevel
        self.level.text = isLevel ? level + "  " : ""
        self.number.text = (number < 10 && !isLevel ? "\u{00a0}" : "") + "\(number) × "
        interval.text = isLevel ? String(format: "[%2d..%2d]", range.lowerBound, range.upperBound) : "[2..99]"
        interval.font = UIFont.monospacedSystemFont(ofSize: interval.font.pointSize, weight: .regular)
        expression.distribution = .fill
        expressionPosition?.isActive=false
        expressionPosition=isLevel ? expression.centerXAnchor.constraint(equalTo:expressionHost.centerXAnchor):expression.leadingAnchor.constraint(equalTo:expressionHost.leadingAnchor)
        expressionPosition?.isActive=true
        self.number.setContentHuggingPriority(.required,for:.horizontal);interval.setContentHuggingPriority(.required,for:.horizontal)
        self.score.text = score; self.score.alpha = !isLevel && score == "0/21" ? 0.5 : 1
        self.score.isHidden = isLevel && score.isEmpty
        result.axis = isLevel ? .vertical : .horizontal
        if isLevel { result.removeArrangedSubview(self.icon); result.addArrangedSubview(self.icon) }
        else { result.removeArrangedSubview(self.icon); result.insertArrangedSubview(self.icon, at: 0) }
        self.icon.isHidden = icon == nil
        self.icon.image = icon.flatMap { UIImage(named: $0) }?.withTintColor(palette.accent, renderingMode: .alwaysOriginal)
        scoreBackground.isHidden = !isLevel || score.isEmpty
        scoreBackground.image = UIImage(named: "bg_th_light_b_level")?.withTintColor(palette.accent, renderingMode: .alwaysOriginal)
        NSLayoutConstraint.deactivate(scoreSize)
        if isLevel {
            let size = AndroidDimensions.value("ll_bg_level_size", traits: traitCollection, fallback: 90)
            scoreSize = [scorePanel.widthAnchor.constraint(equalToConstant: size), scorePanel.heightAnchor.constraint(equalToConstant: size)]
        } else { scoreSize = [scorePanel.widthAnchor.constraint(equalToConstant: self.score.intrinsicContentSize.width), scorePanel.heightAnchor.constraint(equalToConstant: self.score.intrinsicContentSize.height)] }
        NSLayoutConstraint.activate(scoreSize)
        contentView.backgroundColor = highlight ? palette.accent.withAlphaComponent(0.33) : .clear
        accessibilityLabel = [level, "\(number) × \(interval.text ?? "")", score].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
