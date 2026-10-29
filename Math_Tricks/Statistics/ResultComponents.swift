import UIKit

nonisolated enum ResultText {
    static func text(_ key: String) -> String { NSLocalizedString(key, tableName: "Results", bundle: .main, value: key, comment: "") }
    static func format(_ key: String, _ arguments: CVarArg...) -> String { String(format: text(key), locale: .current, arguments: arguments) }
    static func time(_ seconds: TimeInterval?) -> String {
        guard let seconds, seconds > 0 else { return text("results_no_time") }
        return format("statistics_seconds", String(format: "%.2f", locale: Locale.current, seconds))
    }
    static func duration(_ seconds: TimeInterval) -> String {
        let whole = Int64(max(0,seconds))
        return format("example_statistics_duration", whole / 3600, whole / 60 % 60, whole % 60)
    }
}

struct ResultPalette {
    let surface: UIColor, primary: UIColor, secondary: UIColor, divider: UIColor, success: UIColor, error: UIColor, background: UIColor
    init(_ settings: AppSettings) {
        let theme = ThemePalette(settings: settings), dark = theme.theme.isDark
        if theme.theme.isClassic {
            surface = ThemeColor.rgb(dark ? 0x1E293B : 0xFFFFFF)
            primary = ThemeColor.rgb(dark ? 0xFFFFFF : 0x172B45)
            secondary = ThemeColor.rgb(dark ? 0x94A3B8 : 0x64748B)
            divider = ThemeColor.rgb(dark ? 0x334155 : 0xE2E8F0)
            background = ThemeColor.rgb(dark ? 0x101827 : 0xF5F7FB)
        } else {
            surface = theme.surface; primary = theme.text; secondary = theme.secondary; divider = theme.divider; background = theme.background
        }
        success = ThemeColor.rgb(dark ? 0x4ADE80 : 0x15803D)
        error = ThemeColor.rgb(dark ? 0xFB7185 : 0xBE123C)
    }
}

enum ResultUI {
    static func label(_ text: String, size: CGFloat, settings: AppSettings, color: UIColor, bold: Bool = false) -> UILabel {
        let label = UILabel(); label.numberOfLines = 0; label.text = text; label.textColor = color
        label.font = font(size,settings: settings,bold: bold); return label
    }
    static func font(_ size: CGFloat, settings: AppSettings, bold: Bool = false, weight: CGFloat? = nil) -> UIFont {
        let base = AppTypography.font(.body,settings: settings,traits: UITraitCollection.current,weight: weight ?? (bold ? 700 : 400))
        return base.withSize(base.pointSize * size / AppTextRole.body.size)
    }
    static func card(_ view: UIView, settings: AppSettings, radius: CGFloat = 16, border: Bool = false) {
        let palette = ResultPalette(settings)
        view.backgroundColor = palette.surface; view.layer.cornerRadius = radius
        view.layer.borderWidth = border ? 1 : 0; view.layer.borderColor = palette.divider.cgColor
    }
    static func button(_ title: String, icon: AppIcon? = nil, settings: AppSettings, action: @escaping () -> Void) -> UIButton {
        let palette = ResultPalette(settings), button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = title; configuration.image = icon?.image?.withRenderingMode(.alwaysTemplate)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8; configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        configuration.baseForegroundColor = palette.primary
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var result = incoming; result.font = font(14,settings: settings); return result
        }
        button.configuration = configuration; card(button,settings: settings,border: true)
        button.addAction(UIAction { _ in action() },for: .touchUpInside)
        return button
    }
    static func applyButton(_ button:UIButton,settings:AppSettings,size:CGFloat=14) {
        let palette=ResultPalette(settings)
        var configuration=button.configuration
        configuration?.baseForegroundColor=palette.primary
        configuration?.titleLineBreakMode = .byWordWrapping
        configuration?.titleTextAttributesTransformer=UIConfigurationTextAttributesTransformer{incoming in
            var value=incoming;value.font=font(size,settings:settings);return value
        }
        button.configuration=configuration;card(button,settings:settings,border:true)
    }
    static func pin(_ child: UIView, in parent: UIView, insets: UIEdgeInsets = .zero) {
        child.translatesAutoresizingMaskIntoConstraints = false; parent.addSubview(child)
        NSLayoutConstraint.activate([child.topAnchor.constraint(equalTo: parent.topAnchor,constant: insets.top),child.bottomAnchor.constraint(equalTo: parent.bottomAnchor,constant: -insets.bottom),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor,constant: insets.left),child.trailingAnchor.constraint(equalTo: parent.trailingAnchor,constant: -insets.right)])
    }
    static func stack(_ axis: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0) -> UIStackView {
        let view = UIStackView(); view.axis = axis; view.spacing = spacing; return view
    }
}

struct ResultMetric { let value: String; let caption: String; var color: UIColor? = nil }

/// Equal global-statistics cells; result cards stack only when measured text cannot fit.
final class ResultMetricGrid: UIView {
    var usesIntrinsicSizing = true
    private var cards: [(UIView,UILabel,UILabel)] = []
    private let columns: Int
    private let adaptive: Bool
    private let fontScale: CGFloat
    private var measuredWidth: CGFloat = 0
    private var fittingWidth: CGFloat?
    func measure(width: CGFloat) {
        guard fittingWidth != width else { return };fittingWidth=width;invalidateIntrinsicContentSize()
    }
    init(_ metrics: [ResultMetric], settings: AppSettings, columns: Int = 2, border: Bool = true, adaptive: Bool = false) {
        self.columns = max(1,columns); self.adaptive = adaptive
        fontScale = ResultUI.font(16,settings: settings).pointSize / 16
        super.init(frame: .zero)
        let palette = ResultPalette(settings)
        for metric in metrics {
            let card = UIView()
            let value = ResultUI.label(metric.value,size: adaptive ? 24 : 20,settings: settings,color: metric.color ?? palette.primary,bold: !adaptive)
            if adaptive { value.font = ResultUI.font(24,settings: settings,weight: 500) }
            let caption = ResultUI.label(metric.caption,size: 12,settings: settings,color: palette.secondary)
            value.textAlignment = .center; caption.textAlignment = .center
            card.addSubview(value); card.addSubview(caption); addSubview(card)
            ResultUI.card(card,settings: settings,radius: adaptive ? 16 : 12,border: border)
            cards.append((card,value,caption))
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func geometry(_ width: CGFloat) -> (Int,CGFloat,[CGFloat]) {
        let gap: CGFloat = adaptive ? 12 : 8, pad: CGFloat = adaptive ? 12 : 10
        var count = columns
        if adaptive {
            let widest = cards.map { _,value,caption in
                let valueWidth = ((value.text ?? "") as NSString).size(withAttributes: [.font:value.font!]).width
                let captionWidth = (caption.text ?? "").split(whereSeparator: { $0.isWhitespace }).map { (String($0) as NSString).size(withAttributes: [.font:caption.font!]).width }.max() ?? 0
                return max(valueWidth,captionWidth) + 2 * pad
            }.max() ?? 0
            count = fontScale >= 1.6 || width < widest * CGFloat(cards.count) + gap * CGFloat(max(0,cards.count-1)) ? 1 : max(1,cards.count)
        }
        let cellWidth = max(1,(width - gap * CGFloat(count-1))/CGFloat(count))
        var heights = cards.map { _,value,caption in
            value.sizeThatFits(CGSize(width: max(1,cellWidth-2*pad),height: .greatestFiniteMagnitude)).height + caption.sizeThatFits(CGSize(width: max(1,cellWidth-2*pad),height: .greatestFiniteMagnitude)).height + 6 + (adaptive ? 24 : 20)
        }
        if !adaptive || count > 1 { let height = heights.max() ?? 0; heights = heights.map { _ in height } }
        return (count,cellWidth,heights)
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (count,_,heights) = geometry(size.width), gap: CGFloat = adaptive ? 12 : 8
        var height: CGFloat = 0
        for start in stride(from: 0,to: heights.count,by: count) { height += heights[start..<min(start+count,heights.count)].max() ?? 0 }
        height += CGFloat(max(0,(heights.count+count-1)/count-1))*gap
        return CGSize(width:size.width,height:ceil(height))
    }
    override var intrinsicContentSize: CGSize {
        let width = fittingWidth ?? (bounds.width > 0 ? bounds.width : max(1,UIScreen.main.bounds.width-32))
        return CGSize(width:UIView.noIntrinsicMetric,height:sizeThatFits(CGSize(width:width,height:0)).height)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let (count,width,heights) = geometry(bounds.width), gap: CGFloat = adaptive ? 12 : 8, pad: CGFloat = adaptive ? 12 : 10
        let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
        var y: CGFloat = 0
        for (index,item) in cards.enumerated() {
            if index > 0 && index % count == 0 { y += heights[index-1]+gap }
            let column = rtl ? count-1-index%count : index%count
            item.0.frame = CGRect(x:CGFloat(column)*(width+gap),y:y,width:width,height:heights[index])
            let valueHeight = item.1.sizeThatFits(CGSize(width:max(1,width-2*pad),height:.greatestFiniteMagnitude)).height
            let captionHeight = item.2.sizeThatFits(CGSize(width:max(1,width-2*pad),height:.greatestFiniteMagnitude)).height
            let top = max(0,(heights[index]-valueHeight-captionHeight-6)/2)
            item.1.frame = CGRect(x:pad,y:top,width:max(1,width-2*pad),height:valueHeight)
            item.2.frame = CGRect(x:pad,y:top+valueHeight+6,width:max(1,width-2*pad),height:captionHeight)
        }
        if usesIntrinsicSizing && abs(measuredWidth-bounds.width)>0.5 { measuredWidth=bounds.width;invalidateIntrinsicContentSize() }
    }
}

/// Proportional persistent-statistics columns; fixed timing columns for game results.
final class ResultColumnsView: UIView {
    private let expression: UILabel
    private let values: [UILabel]
    private let status = UIImageView()
    private let divider = UIView()
    private let fixed: Bool
    private let scale: CGFloat
    init(title: String, values: [String], settings: AppSettings, header: Bool = false, fixed: Bool = false, correct: Bool? = nil, colors: [UIColor]? = nil, last: Bool = false) {
        let palette = ResultPalette(settings)
        self.fixed = fixed
        expression = ResultUI.label(title,size: header ? 14 : 16,settings: settings,color: header ? palette.secondary : palette.primary)
        self.values = values.enumerated().map { index,text in
            let label = ResultUI.label(text,size: header ? 13 : 14,settings: settings,color: colors?[index] ?? palette.secondary)
            let maximum = (header ? 13.0 : 14.0) * 1.2
            label.font = label.font.withSize(min(maximum,label.font.pointSize)); label.textAlignment = .center; return label
        }
        scale = expression.font.pointSize / (header ? 14 : 16)
        super.init(frame: .zero); backgroundColor = palette.surface
        addSubview(expression); self.values.forEach(addSubview); addSubview(status); addSubview(divider)
        if let correct {
            status.image = UIImage(named: correct ? "ic_result_correct" : "ic_result_incorrect")?.withTintColor(correct ? palette.success : palette.error,renderingMode: .alwaysOriginal)
        }
        status.contentMode = .scaleAspectFit; status.isHidden = correct == nil
        divider.backgroundColor = palette.divider; divider.isHidden = last || header
        isAccessibilityElement = true; accessibilityLabel = ([title] + values).joined(separator: ", ")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func sizes(_ width: CGFloat) -> (Bool,CGFloat,[CGFloat],CGFloat) {
        let available = max(1,width - 24), count = max(1,values.count), icon: CGFloat = status.isHidden ? 0 : 18
        let stacked = !fixed && available < CGFloat(180 + 40 * count) * scale
        let timing: [CGFloat] = values.indices.map { fixed ? ($0 == 2 ? 72 : 68) : available / CGFloat(count + 2) }
        let expressionWidth = stacked ? available : max(1,available - timing.reduce(0,+) - icon)
        let expressionHeight = expression.sizeThatFits(CGSize(width: expressionWidth,height: .greatestFiniteMagnitude)).height
        let timesHeight = values.enumerated().map { index,label in label.sizeThatFits(CGSize(width: stacked ? available / CGFloat(count) : timing[index],height: .greatestFiniteMagnitude)).height }.max() ?? 0
        return (stacked,expressionHeight,timing,stacked ? expressionHeight + 8 + timesHeight + 24 : max(expressionHeight,timesHeight) + 24)
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize { CGSize(width: size.width,height: sizes(size.width).3 + 1) }
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric,height: sizeThatFits(CGSize(width: bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 32,height: 0)).height) }
    override func layoutSubviews() {
        super.layoutSubviews()
        let (stacked,expressionHeight,timing,_) = sizes(bounds.width), available = max(1,bounds.width - 24), count = max(1,values.count)
        let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
        func place(_ view: UIView,_ rect: CGRect) { view.frame = rtl ? CGRect(x: bounds.width - rect.maxX,y: rect.minY,width: rect.width,height: rect.height) : rect }
        let icon: CGFloat = status.isHidden ? 0 : 18
        let expressionWidth = stacked ? available : max(1,available - timing.reduce(0,+) - icon)
        let contentHeight = bounds.height - 24
        place(status,CGRect(x: 12,y: (bounds.height - 14) / 2,width: 14,height: 14))
        place(expression,CGRect(x: 12 + (stacked ? 0 : icon),y: stacked ? 12 : (bounds.height - expressionHeight) / 2,width: expressionWidth,height: expressionHeight))
        var x = 12 + expressionWidth + icon
        for (index,label) in values.enumerated() {
            let width = stacked ? available / CGFloat(count) : timing[index]
            let y: CGFloat = stacked ? 12 + expressionHeight + 8 : 12
            place(label,CGRect(x: stacked ? 12 + CGFloat(index) * width : x,y: y,width: width,height: stacked ? max(1,contentHeight - expressionHeight - 8) : max(1,contentHeight)))
            x += width
        }
        divider.frame = CGRect(x: 12,y: bounds.height - 1,width: max(0,bounds.width - 24),height: 1)
    }
}

final class ResultColumnsCell: AppListCell {
    private var row: ResultColumnsView?
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) { super.init(style: style,reuseIdentifier: reuseIdentifier); backgroundColor = .clear; selectionStyle = .none }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func systemLayoutSizeFitting(_ targetSize: CGSize,withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,verticalFittingPriority: UILayoutPriority) -> CGSize {
        row?.sizeThatFits(CGSize(width: targetSize.width,height: .greatestFiniteMagnitude)) ?? super.systemLayoutSizeFitting(targetSize,withHorizontalFittingPriority: horizontalFittingPriority,verticalFittingPriority: verticalFittingPriority)
    }
    func configure(_ view: ResultColumnsView, settings: AppSettings) {
        row?.removeFromSuperview(); row = view; ResultUI.pin(view,in: contentView)
        applyHighlight(settings: settings)
    }
}

final class StatisticsTextCell: AppListCell {
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) { super.init(style: style,reuseIdentifier: reuseIdentifier); backgroundColor = .clear; selectionStyle = .none }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(title: String,subtitle: String? = nil,settings: AppSettings,heading: Bool = false) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        let palette = ResultPalette(settings), stack = ResultUI.stack(.vertical,spacing: 6)
        stack.addArrangedSubview(ResultUI.label(title,size: heading ? 16 : 18,settings: settings,color: palette.primary,bold: heading))
        if let subtitle { stack.addArrangedSubview(ResultUI.label(subtitle,size: 14,settings: settings,color: palette.error)) }
        ResultUI.pin(stack,in: contentView,insets: UIEdgeInsets(top: 12,left: 12,bottom: 12,right: 12))
        if heading { ResultUI.card(contentView,settings: settings,radius: 12,border: true) } else { contentView.backgroundColor = palette.surface;contentView.layer.cornerRadius = 0;contentView.layer.borderWidth = 0 }
        applyHighlight(settings: settings, enabled: !heading)
    }
}
