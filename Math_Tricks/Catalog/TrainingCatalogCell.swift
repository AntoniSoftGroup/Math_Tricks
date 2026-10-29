import UIKit

/// Separate from CatalogCell: statistics and result rows have different layouts.
final class TrainingCatalogCell: AppListCell {
    private let name = UILabel()
    private let number = UILabel()
    private let progress = UILabel()
    private let star = UIImageView()
    private let check = AndroidCheckBox()
    private let pro = UILabel()
    private let price = UILabel()
    private let coin = UIImageView()
    private let lock = UIImageView()
    private let purchase = UIStackView()
    private let purchaseSurface = ThemeSurfaceView(.card)
    private let completion = UIStackView()
    var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        name.numberOfLines = 0
        number.textAlignment = .natural
        progress.textAlignment = .right
        pro.text = " PRO "; pro.textColor = .white
        for image in [star, coin, lock] {
            image.contentMode = .scaleAspectFit
            image.isAccessibilityElement = false
            image.translatesAutoresizingMaskIntoConstraints = false
        }
        purchase.axis = .horizontal; purchase.alignment = .center; purchase.spacing = 3
        purchase.isLayoutMarginsRelativeArrangement = true
        purchase.directionalLayoutMargins = NSDirectionalEdgeInsets(top:4,leading:6,bottom:4,trailing:6)
        purchaseSurface.translatesAutoresizingMaskIntoConstraints = false
        purchase.addSubview(purchaseSurface)
        NSLayoutConstraint.activate([purchaseSurface.topAnchor.constraint(equalTo:purchase.topAnchor),purchaseSurface.bottomAnchor.constraint(equalTo:purchase.bottomAnchor),
            purchaseSurface.leadingAnchor.constraint(equalTo:purchase.leadingAnchor),purchaseSurface.trailingAnchor.constraint(equalTo:purchase.trailingAnchor)])
        [pro, coin, price, lock].forEach { purchase.addArrangedSubview($0) }
        completion.axis = .horizontal; completion.alignment = .center; completion.spacing = 0
        [star, check].forEach { completion.addArrangedSubview($0) }
        let accessory = UIView()
        for item in [progress, completion, purchase] {
            item.translatesAutoresizingMaskIntoConstraints = false
            accessory.addSubview(item)
        }
        let row = UIStackView(arrangedSubviews: [number, name, accessory])
        row.axis = .horizontal; row.spacing = 5; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        number.setContentHuggingPriority(.required, for: .horizontal)
        number.setContentCompressionResistancePriority(.required, for: .horizontal)
        accessory.setContentCompressionResistancePriority(.required, for: .horizontal)
        name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let purchaseWidth = accessory.widthAnchor.constraint(greaterThanOrEqualTo: purchase.widthAnchor)
        purchaseWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 68),
            accessory.widthAnchor.constraint(greaterThanOrEqualToConstant: 64), purchaseWidth,
            accessory.heightAnchor.constraint(greaterThanOrEqualTo: completion.heightAnchor),
            accessory.heightAnchor.constraint(greaterThanOrEqualTo: purchase.heightAnchor),
            completion.trailingAnchor.constraint(equalTo: accessory.trailingAnchor),
            completion.centerYAnchor.constraint(equalTo: accessory.centerYAnchor),
            progress.trailingAnchor.constraint(equalTo: check.leadingAnchor),
            progress.bottomAnchor.constraint(equalTo: completion.centerYAnchor, constant: -12),
            progress.topAnchor.constraint(greaterThanOrEqualTo: accessory.topAnchor, constant: -10),
            progress.leadingAnchor.constraint(greaterThanOrEqualTo: accessory.leadingAnchor),
            purchase.trailingAnchor.constraint(equalTo: accessory.trailingAnchor),
            purchase.centerYAnchor.constraint(equalTo: accessory.centerYAnchor),
            check.widthAnchor.constraint(equalToConstant: 48), check.heightAnchor.constraint(equalToConstant: 48),
            star.widthAnchor.constraint(equalToConstant: 24), star.heightAnchor.constraint(equalToConstant: 24),
            coin.widthAnchor.constraint(equalToConstant: 24), coin.heightAnchor.constraint(equalToConstant: 24),
            lock.widthAnchor.constraint(equalToConstant: 20), lock.heightAnchor.constraint(equalToConstant: 24)
        ])
        check.addAction(UIAction { [weak self] _ in
            guard let self else { return }; onToggle?(check.isOn)
        }, for: .valueChanged)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func prepareForReuse() { super.prepareForReuse(); onToggle = nil }

    func configure(trick: CatalogTrick, position: Int, value: TrickProgress?, completed: Int?, settings: AppSettings, busy: Bool) {
        let palette = ThemePalette(settings: settings)
        purchaseSurface.apply(settings:settings)
        let tint = TrainingCatalogAppearance.foreground(trick.groupID, settings: settings)
        let font = AppTypography.font(.catalogTrick, settings: settings, traits: traitCollection)
        name.attributedText = AndroidRichText.attributed(CatalogText.text(trick.nameKey), font: font, color: palette.text)
        number.text = String(format: "%02d.", position)
        number.font = AppTypography.font(.catalogTrick, settings: settings, traits: traitCollection, weight: 700).withSize(font.pointSize / 1.25)
        progress.font = font.withSize(font.pointSize / 1.5)
        price.font = font.withSize(font.pointSize / 1.5)
        pro.font = font.withSize(font.pointSize / 1.7)
        [number, progress, price].forEach { $0.textColor = tint }
        pro.backgroundColor = settings.theme == .aurora ? UIColor.white.withAlphaComponent(48 / 255) : tint
        price.text = String(TrickCatalog.shared.unlockPrice)
        coin.image = AppIcon.buyCoins.image?.withTintColor(tint, renderingMode: .alwaysOriginal)
        lock.image = UIImage(named: "ic_th_light_b_lock")?.withTintColor(tint, renderingMode: .alwaysOriginal)
        star.image = AppIcon.star.image?.withTintColor(tint, renderingMode: .alwaysOriginal)
        let unlocked = value?.unlocked ?? trick.initiallyUnlocked
        purchase.isHidden = unlocked
        completion.isHidden = !unlocked
        progress.isHidden = !unlocked || completed == nil || completed == TrickCatalog.shared.levelCount
        progress.text = completed.map { "\($0)/\(TrickCatalog.shared.levelCount)" }
        progress.alpha = completed == 0 ? 0.5 : 1
        // Android uses INVISIBLE here, preserving the slot beside the checkbox.
        star.alpha = completed == TrickCatalog.shared.levelCount ? 1 : 0
        check.isOn = value?.selected ?? false
        check.onTintColor = tint
        check.isEnabled = value != nil && !busy
        check.accessibilityLabel = AndroidRichText.plain(CatalogText.text(trick.nameKey))
        accessibilityIdentifier = "training.trick.\(trick.id)"
        name.accessibilityLabel = AndroidRichText.plain(CatalogText.text(trick.nameKey))
        purchase.isAccessibilityElement = true
        purchase.accessibilityLabel = "PRO, \(CatalogText.ui("locked")), \(TrickCatalog.shared.unlockPrice)"
        applyHighlight(settings: settings, groupID: trick.groupID)
    }
}

final class TrainingCatalogGroupCell: AppListCell {
    private let name = UILabel()
    private let icon = UIImageView()
    private let indicator = UIImageView()
    private let classicBackground = UIImageView()
    private let surface = ThemeSurfaceView(.card)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        for background in [classicBackground, surface] {
            background.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(background)
            NSLayoutConstraint.activate([
                background.topAnchor.constraint(equalTo: contentView.topAnchor),
                background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
                background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }
        name.numberOfLines = 0
        icon.contentMode = .scaleAspectFit; indicator.contentMode = .center
        let row = UIStackView(arrangedSubviews: [icon, name, indicator])
        row.axis = .horizontal; row.alignment = .center; row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false; contentView.addSubview(row)
        let trailing = row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        trailing.priority = .init(999)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trailing,
            row.topAnchor.constraint(equalTo: contentView.topAnchor),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            icon.widthAnchor.constraint(equalToConstant: 56.25), icon.heightAnchor.constraint(equalToConstant: 56.25),
            indicator.widthAnchor.constraint(equalToConstant: 35), indicator.heightAnchor.constraint(equalToConstant: 24),
            name.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            name.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
        isAccessibilityElement = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(group: CatalogGroup, expanded: Bool, settings: AppSettings) {
        let palette = ThemePalette(settings: settings)
        name.attributedText = AndroidRichText.attributed(CatalogText.text(group.nameKey),
            font: AppTypography.font(.catalogGroup, settings: settings, traits: traitCollection, weight: 700), color: palette.text)
        icon.image = UIImage(named: group.iconName)?.withRenderingMode(.alwaysOriginal)
        indicator.image = AndroidImages.catalogIndicator(expanded: expanded, dark: palette.theme.isDark)
        classicBackground.image = palette.theme == .dark ? AndroidImages.darkCatalogGroup : AndroidImages.catalogGroup
        classicBackground.isHidden = !palette.theme.isClassic
        surface.isHidden = palette.theme.isClassic
        surface.apply(settings: settings)
        applyHighlight(settings: settings, groupID: group.id)
        accessibilityLabel = AndroidRichText.plain(CatalogText.text(group.nameKey))
        accessibilityValue = CatalogText.ui(expanded ? "collapse_all" : "expand_all")
        accessibilityTraits = [.button, .header]
        accessibilityIdentifier = "training.group.\(group.id)"
    }
}
