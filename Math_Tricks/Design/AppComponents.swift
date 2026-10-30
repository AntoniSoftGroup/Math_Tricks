import UIKit

/// Shared logical dimensions from Android.
enum AppMetrics {
    static let margin: CGFloat = 16
    static let headerHeight: CGFloat = 60
    static let headerBackWidth: CGFloat = 56
    static let minimumTouchSize: CGFloat = 48
    static let dialogPadding: CGFloat = 15
}

final class AppButton: UIControl {
    enum Kind { case menu, dialog, icon, compact, keypad, keypadIcon, playerKey, plain, iconSurface }
    let label: AppLabel
    private lazy var background = ThemeSurfaceView(kind == .icon || kind == .plain ? .icon : .button)
    private var settings = AppSettings()
    var preservesIconColors = false { didSet { updateState() } }
    private var iconTint: UIColor?
    private var textTint:UIColor?
    private var icon: AppIcon?
    private let iconView = UIImageView()
    private let trailingIcon: AppIcon?
    private let trailingIconView = UIImageView()
    private let kind: Kind
    private var contentRow:UIStackView?
    private var rowInsets: [NSLayoutConstraint] = []
    private var minimumHeightConstraint: NSLayoutConstraint?
    private var keyFont:UIFont?
    private var keyHeight:CGFloat?
    private var iconWidths: [NSLayoutConstraint] = []
    private var iconHeight:NSLayoutConstraint?
    private var naturalIconHeight:CGFloat=30

    init(title: String, icon: AppIcon? = nil, trailingIcon: AppIcon? = nil, kind: Kind = .menu, balancesIcon: Bool = true, action: @escaping () -> Void) {
        self.kind = kind
        self.icon = icon
        self.trailingIcon = trailingIcon
        let role: AppTextRole = kind == .playerKey ? .playerNumber : kind == .menu ? .menu : kind == .compact ? .menuCaption : kind == .keypad ? .number : kind == .plain ? .dailyCaption : .dialog
        label = AppLabel(role)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits = .button
        label.text = title
        label.textAlignment = .center
        label.isAccessibilityElement = false
        iconView.image = icon?.image
        iconView.contentMode = .scaleAspectFit
        iconView.isAccessibilityElement = false
        background.isUserInteractionEnabled = false
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        let row = UIStackView();contentRow=row
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        if icon != nil {
            row.addArrangedSubview(iconView)
            let size = iconView.image?.size ?? CGSize(width: 40, height: 30)
            naturalIconHeight=min(40,size.height)
            let height=iconView.heightAnchor.constraint(equalToConstant:naturalIconHeight);iconHeight=height
            let width = iconView.widthAnchor.constraint(equalToConstant: icon == .cooperative || icon == .versus ? size.width : min(40, size.width))
            iconWidths.append(width)
            NSLayoutConstraint.activate([width, height])
        }
        if kind != .icon && kind != .keypadIcon && kind != .iconSurface {
            row.addArrangedSubview(label)
            if let trailingIcon {
                trailingIconView.image = trailingIcon.image
                trailingIconView.contentMode = .scaleAspectFit
                trailingIconView.isAccessibilityElement = false
                row.addArrangedSubview(trailingIconView)
                let trailingSize=trailingIconView.image?.size ?? CGSize(width:40,height:30)
                let width = trailingIconView.widthAnchor.constraint(equalToConstant:min(40,trailingSize.width))
                iconWidths.append(width)
                NSLayoutConstraint.activate([width,
                    trailingIconView.heightAnchor.constraint(equalToConstant:min(40,trailingSize.height))])
            } else if icon != nil && balancesIcon { // Android drawableRight spacer centers captions.
                let spacer = UIView()
                row.addArrangedSubview(spacer)
                spacer.widthAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true
            }
        }
        addSubview(row)
        let verticalPadding: CGFloat = kind == .plain ? 2 : kind == .playerKey ? 4 : 10
        let rowBottom = row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding)
        rowBottom.priority = .init(999)
        let leadingLimit = row.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12)
        let trailingLimit = row.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12)
        leadingLimit.priority = .init(999); trailingLimit.priority = .init(999)
        let minimumHeight = heightAnchor.constraint(greaterThanOrEqualToConstant: kind == .playerKey ? 44 : kind == .plain ? 28 : AppMetrics.minimumTouchSize)
        minimumHeightConstraint=minimumHeight
        minimumHeight.priority = .init(999)
        let rowTop=row.topAnchor.constraint(equalTo: topAnchor,constant:verticalPadding)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor), background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor), background.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowTop, rowBottom,
            leadingLimit, trailingLimit,
            row.centerXAnchor.constraint(equalTo: centerXAnchor),
            minimumHeight
        ])
        rowInsets=[rowTop,rowBottom,leadingLimit,trailingLimit]
        addAction(UIAction { _ in action() }, for: .touchUpInside)
        if kind != .icon && kind != .keypadIcon && kind != .iconSurface {
            let leading=row.leadingAnchor.constraint(equalTo: leadingAnchor,constant:12)
            leading.isActive=true
            let trailing = row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
            trailing.priority = .init(999); trailing.isActive = true
            rowInsets.append(contentsOf:[leading,trailing])
        }
        keyFont=label.font
        updateState()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(settings: AppSettings, tint: UIColor? = nil,textTint:UIColor?=nil) {
        guard self.settings != settings || iconTint != tint || self.textTint != textTint else { return }
        self.settings = settings
        iconTint = tint;self.textTint=textTint
        label.apply(settings: settings);keyFont=label.font;keyHeight=nil;setNeedsLayout()
        updateState()
    }

    func shakeIcon() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let animation=CAKeyframeAnimation(keyPath:"transform.translation.x")
        animation.values=[0,6,-6,4,-4,0];animation.duration=0.35
        iconView.layer.add(animation,forKey:"insufficientCoins")
    }

    func setContentSpacing(_ value:CGFloat) {contentRow?.spacing=value}

    func setIconsHidden(_ hidden: Bool) {
        guard iconView.isHidden != hidden else { return }
        if hidden { NSLayoutConstraint.deactivate(iconWidths) }
        iconView.isHidden = hidden
        trailingIconView.isHidden = hidden
        if !hidden { NSLayoutConstraint.activate(iconWidths) }
    }

    func setIconScale(_ scale: CGFloat) { iconView.transform = CGAffineTransform(scaleX: scale, y: scale) }

    func setIcon(_ icon:AppIcon) {
        guard self.icon != nil,self.icon != icon else{return};self.icon=icon;updateState()
    }

    func setContentInsets(_ insets:UIEdgeInsets,minimumHeight:CGFloat?=nil) {
        guard rowInsets.count>=4 else{return}
        rowInsets[0].constant=insets.top;rowInsets[1].constant = -insets.bottom
        rowInsets[2].constant=insets.left;rowInsets[3].constant = -insets.right
        if rowInsets.count==6 {rowInsets[4].constant=insets.left;rowInsets[5].constant = -insets.right}
        if let minimumHeight {minimumHeightConstraint?.constant=minimumHeight}
        keyHeight=nil;setNeedsLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection:UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if kind == .keypad || kind == .playerKey {
            keyFont=AppTypography.font(label.role,settings:settings,traits:traitCollection);keyHeight=nil;setNeedsLayout()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.height>1,keyHeight != bounds.height,rowInsets.count>=2 else{return}
        keyHeight=bounds.height
        let available=max(1,bounds.height-rowInsets[0].constant+rowInsets[1].constant)
        if kind == .keypad || kind == .playerKey,let base=keyFont {
            let size=max(1,min(base.pointSize,base.pointSize*available/max(1,base.lineHeight)))
            let font=base.withSize(size)
            if label.font != font {label.font=font}
        } else if kind == .keypadIcon {iconHeight?.constant=min(naturalIconHeight,available)}
    }

    override var isHighlighted: Bool { didSet { if oldValue != isHighlighted { updateState() } } }
    override var isEnabled: Bool { didSet { if oldValue != isEnabled { updateState() } } }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isHighlighted = true
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isHighlighted = bounds.contains(touch.location(in: self))
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) { isHighlighted = false }
    override func cancelTracking(with event: UIEvent?) { isHighlighted = false }

    override func accessibilityActivate() -> Bool {
        guard isEnabled else { return false }
        sendActions(for: .touchUpInside)
        return true
    }

    private func updateState() {
        let palette = ThemePalette(settings: settings)
        background.apply(settings: settings, pressed: isHighlighted, enabled: isEnabled)
        label.textColor = textTint ?? palette.text
        func image(_ item:AppIcon?)->UIImage? {
            guard let item else{return nil}
            if item == .noAds {
                return UIImage(named:palette.theme.isDark ? "ic_th_dark_b_no_ads" : "ic_th_light_b_no_ads")?.withRenderingMode(.alwaysOriginal)
            }
            if item == .cloudUser, palette.theme == .light {
                return item.image?.withTintColor(.black, renderingMode: .alwaysOriginal)
            }
            if item == .back, palette.usesAccentHeaderIcons {
                return item.image?.withTintColor(palette.selected, renderingMode: .alwaysOriginal)
            }
            if item == .pro {return item.image}
            if item == .backspace { return item.image?.withTintColor(label.textColor ?? palette.text,renderingMode:.alwaysOriginal) }
            if preservesIconColors {
                let name = palette.theme.isDark ? item.rawValue.replacingOccurrences(of:"ic_th_light_iw_",with:"ic_th_dark_iw_") : item.rawValue
                return UIImage(named:name)?.withRenderingMode(.alwaysOriginal)
            }
            return item.image?.withTintColor(iconTint ?? palette.accent,renderingMode:.alwaysOriginal)
        }
        iconView.image=image(icon);trailingIconView.image=image(trailingIcon)
        label.layer.shadowColor = palette.theme == .neon ? palette.selected.withAlphaComponent(65/255).cgColor : nil
        label.layer.shadowRadius = palette.theme == .neon ? 2 : 0
        label.layer.shadowOpacity = palette.theme == .neon ? 1 : 0
        label.layer.shadowOffset = .zero
        alpha = isEnabled ? 1 : 0.5
        accessibilityTraits = isEnabled ? .button : [.button, .notEnabled]
    }
}

/// Compact Android control with an icon above a caption.
final class AppCaptionIconButton: UIControl {
    let label = UILabel()
    private let iconView = UIImageView()
    private let iconSize: CGFloat
    private let padding: CGFloat
    private var foreground = UIColor.label

    init(imageName: String, iconSize: CGFloat, captionSize: CGFloat, bold: Bool = false, padding: CGFloat, action: @escaping () -> Void) {
        self.iconSize = iconSize; self.padding = padding
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true; accessibilityTraits = .button
        setContentHuggingPriority(.required, for: .horizontal)
        iconView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        label.font = .systemFont(ofSize: captionSize, weight: bold ? .bold : .regular)
        label.numberOfLines = 0; label.textAlignment = .center
        let content = UIStackView(arrangedSubviews: [iconView, label])
        content.axis = .vertical; content.alignment = .center; content.isUserInteractionEnabled = false
        content.translatesAutoresizingMaskIntoConstraints = false; addSubview(content)
        let bottom = content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        let trailing = content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        bottom.priority = .init(999); trailing.priority = .init(999)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: iconSize), iconView.heightAnchor.constraint(equalToConstant: iconSize),
            content.topAnchor.constraint(equalTo: topAnchor, constant: padding), bottom,
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding), trailing
        ])
        addAction(UIAction { _ in action() }, for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var intrinsicContentSize: CGSize {
        let caption = label.intrinsicContentSize
        return CGSize(width: max(44, max(iconSize, caption.width) + padding * 2), height: iconSize + caption.height + padding * 2)
    }
    func apply(color: UIColor, iconColor: UIColor? = nil) {
        foreground = color; label.textColor = color; iconView.tintColor = iconColor ?? color
        accessibilityLabel = label.text; invalidateIntrinsicContentSize()
    }
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? foreground.withAlphaComponent(0.12) : .clear }
    }
}

final class AppHeaderView: AppDuoAvoidingView {
    private let titleLabel=AppLabel(.settingsTitle)
    private let row=UIStackView()
    private var backButton:AppButton?
    private var replacement:UIView?
    private var accessory:UIView?
    private var rowTrailing: NSLayoutConstraint?
    init(title:String,onBack:(()->Void)?) {
        super.init(frame:.zero)
        let content = unobscuredLayoutGuide
        translatesAutoresizingMaskIntoConstraints=false
        row.axis = .horizontal;row.alignment = .center;row.spacing=0
        row.translatesAutoresizingMaskIntoConstraints=false;addSubview(row)
        let trailing = row.trailingAnchor.constraint(equalTo:content.trailingAnchor,constant:-8); rowTrailing = trailing
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo:content.topAnchor),row.bottomAnchor.constraint(equalTo:content.bottomAnchor),
            row.leadingAnchor.constraint(equalTo:content.leadingAnchor,constant:onBack == nil ? 0 : AppMetrics.headerBackWidth),trailing,
            heightAnchor.constraint(greaterThanOrEqualToConstant:AppMetrics.headerHeight)
        ])
        if let onBack {
            let back=AppButton(title:CatalogText.ui("back"),icon:.back,kind:.icon,action:onBack)
            back.setContentInsets(UIEdgeInsets(top:8,left:8,bottom:8,right:8),minimumHeight:AppMetrics.headerHeight)
            back.accessibilityIdentifier="navigationBack"
            insertSubview(back,at:0)
            NSLayoutConstraint.activate([
                back.topAnchor.constraint(equalTo:content.topAnchor),back.leadingAnchor.constraint(equalTo:content.leadingAnchor),
                back.widthAnchor.constraint(equalToConstant:AppMetrics.headerBackWidth),
                back.heightAnchor.constraint(equalToConstant:AppMetrics.headerHeight)
            ])
            backButton=back
        }
        titleLabel.text=title;titleLabel.textAlignment = .natural
        titleLabel.numberOfLines=2;titleLabel.accessibilityTraits = .header
        row.addArrangedSubview(titleLabel)
        apply(settings:AppSettings())
    }
    required init?(coder:NSCoder){fatalError("init(coder:) has not been implemented")}
    func setTitle(_ title:String){titleLabel.text=title}
    func replaceTitle(with view:UIView) {
        replacement?.removeFromSuperview();replacement=view;titleLabel.isHidden=true
        row.insertArrangedSubview(view,at:0)
    }
    func setAccessoryView(_ view:UIView?,trailingInset:CGFloat = 8) {
        accessory?.removeFromSuperview();accessory=view
        rowTrailing?.constant = -trailingInset
        if let view {row.addArrangedSubview(view)}
    }
    func apply(settings:AppSettings) {
        let palette=ThemePalette(settings:settings)
        ThemeColorTransition.apply(self, color: palette.header)
        titleLabel.apply(settings:settings)
        titleLabel.textColor=palette.headerText
        backButton?.apply(settings:settings,tint:titleLabel.textColor)
    }
}

final class AppCardView: UIView {
    let content = UIStackView()
    private let background = ThemeSurfaceView(.card)

    init(padding: CGFloat = AppMetrics.dialogPadding) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        content.axis = .vertical
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        // UIStackView may collapse this card while progress is still being read.
        let bottomConstraint = content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        bottomConstraint.priority = .init(999)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor), background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor), background.trailingAnchor.constraint(equalTo: trailingAnchor),
            content.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            bottomConstraint,
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }

    func apply(settings: AppSettings) { background.apply(settings: settings) }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
