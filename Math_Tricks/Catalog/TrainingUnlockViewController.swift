import UIKit
import Combine

/// Android's coin unlock dialog. Successful purchase returns to the same list.
final class TrainingUnlockViewController: AppDuoViewController {
    private let trick: CatalogTrick
    private let data: AppDataStore
    private let name = UILabel()
    private let errorLabel = AppLabel(.detail)
    private let surface = ThemeSurfaceView(.dialog)
    private var observation: AnyCancellable?
    private var saving = false
    private let onBuyPro: () -> Void
    private lazy var balance = AppButton(title: "—", icon: .coins, kind: .plain, balancesIcon: false, action: {})
    private lazy var pro = AppButton(title: MainText.text("activity_main_b_buy_pro"), icon: .noAds, kind: .dialog, balancesIcon: false) { [weak self] in
        guard let self else { return }
        dismiss(animated:false,completion:onBuyPro)
    }
    private lazy var price = AppButton(title: String(TrickCatalog.shared.unlockPrice), icon: .buyCoins, trailingIcon: .lock, kind: .dialog, action: {})
    private lazy var cancel = AppButton(title: CatalogText.ui("cancel"), icon: .back, kind: .iconSurface) { [weak self] in self?.dismiss(animated: false) }
    private lazy var confirm = AppButton(title: CatalogText.ui("unlock"), icon: .shop, kind: .iconSurface) { [weak self] in self?.unlock() }

    init(trick: CatalogTrick, data: AppDataStore, onBuyPro: @escaping () -> Void) {
        self.trick = trick; self.data = data; self.onBuyPro = onBuyPro
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen; modalPresentationCapturesStatusBarAppearance = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(136 / 255)
        view.accessibilityViewIsModal = true
        view.accessibilityIdentifier = "training.unlock.\(trick.id)"
        let card = UIView(); card.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(card)
        surface.translatesAutoresizingMaskIntoConstraints = false; card.addSubview(surface)
        let scroll = AppScrollView(); scroll.translatesAutoresizingMaskIntoConstraints = false; card.addSubview(scroll)
        let column = UIStackView(); column.axis = .vertical; column.spacing = 20
        column.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(column)
        balance.isUserInteractionEnabled = false; balance.accessibilityTraits = .staticText
        balance.label.role = .trickName
        let top = UIStackView(arrangedSubviews: [balance, pro]); top.axis = .horizontal; top.alignment = .center; top.spacing = 8
        balance.setContentHuggingPriority(.required, for: .horizontal)
        column.addArrangedSubview(top)
        name.numberOfLines = 0; name.textAlignment = .center; name.accessibilityTraits = .header
        column.addArrangedSubview(name)
        price.isUserInteractionEnabled = false; price.accessibilityTraits = .staticText
        price.label.role = .trickName
        let priceRow = UIStackView(arrangedSubviews: [UIView(), price, UIView()]); priceRow.axis = .horizontal
        priceRow.arrangedSubviews[0].widthAnchor.constraint(equalTo: priceRow.arrangedSubviews[2].widthAnchor).isActive = true
        column.addArrangedSubview(priceRow)
        errorLabel.textAlignment = .center; errorLabel.isHidden = true; column.addArrangedSubview(errorLabel)
        let actions = UIStackView(arrangedSubviews: [cancel, confirm]); actions.axis = .horizontal; actions.distribution = .fillEqually
        column.addArrangedSubview(actions)
        let safe = view.appContentLayoutGuide
        let width = card.widthAnchor.constraint(equalToConstant: 400); width.priority = .defaultHigh
        let height = scroll.heightAnchor.constraint(equalTo: column.heightAnchor); height.priority = .defaultHigh
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: safe.centerXAnchor), card.centerYAnchor.constraint(equalTo: safe.centerYAnchor), width,
            card.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -12),
            card.topAnchor.constraint(greaterThanOrEqualTo: safe.topAnchor, constant: 8),
            card.bottomAnchor.constraint(lessThanOrEqualTo: safe.bottomAnchor, constant: -8),
            surface.topAnchor.constraint(equalTo: card.topAnchor), surface.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            surface.leadingAnchor.constraint(equalTo: card.leadingAnchor), surface.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: card.topAnchor, constant: 15), scroll.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15),
            scroll.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15), scroll.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            column.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), column.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            column.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), column.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            column.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor), scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 48), height
        ])
        observation = data.$snapshot.sink { [weak self] progress in self?.update(progress) }
    }

    private func update(_ progress: ProgressState?) {
        let settings = TrainingCatalogAppearance.settings(progress?.settings ?? AppSettings(), groupID: trick.groupID)
        let palette = ThemePalette(settings: settings)
        surface.apply(settings: settings)
        name.attributedText = AndroidRichText.attributed(CatalogText.text(trick.nameKey) + ":",
            font: AppTypography.font(.dialog, settings: settings, traits: traitCollection), color: palette.text)
        for button in [balance, pro, price, cancel, confirm] { button.apply(settings: settings) }
        balance.label.text = progress.map { String($0.coins) } ?? "—"
        balance.accessibilityLabel = progress.map { String(format: CatalogText.ui("coins"), $0.coins) } ?? "—"
        errorLabel.apply(settings: settings); errorLabel.textColor = palette.text
        cancel.isEnabled = !saving; confirm.isEnabled = progress != nil && !saving; pro.isEnabled = !saving
    }

    private func unlock() {
        guard !saving, data.snapshot != nil else { return }
        saving = true; errorLabel.isHidden = true; update(data.snapshot)
        Task { [weak self] in
            guard let self else { return }
            do {
                try await data.unlockTrick(trick.id)
                AppFeedback.shared.play(.levelComplete)
                dismiss(animated: false)
            } catch {
                saving = false
                if (error as? ProgressError) == .alreadyUnlocked { dismiss(animated: false); return }
                errorLabel.text = CatalogText.ui((error as? ProgressError) == .insufficientCoins ? "not_enough_coins" : "save_error")
                errorLabel.isHidden = false; update(data.snapshot)
                if (error as? ProgressError) == .insufficientCoins { balance.shakeIcon() }
                AppFeedback.shared.play(.error)
                UIAccessibility.post(notification: .announcement, argument: errorLabel.text)
            }
        }
    }
}
