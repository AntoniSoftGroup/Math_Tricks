import UIKit
import Combine

/// Optional manual age entry; mandatory declarations are handled by Apple.
final class AgeScreenViewController: UIViewController {
    var prepareThemePreview: ((AppSettings) -> Void)?
    private var previewPrepared = false
    private let data: AppDataStore
    private var value: Int?
    private var saving = false
    private var settings = AppSettings()
    private var observation: AnyCancellable?
    private let ageLabel = AppLabel(.expression)
    private let prompt = AppLabel(.dialog)
    private let heading = AppLabel(.score)
    private let header = AppDuoAvoidingView()
    private let info = UIStackView()
    private var buttons: [AppButton] = []
    private weak var contentArea:UIView?
    private weak var actionRow:UIView?
    private var keypadHeight:NSLayoutConstraint?
    private lazy var links = AppExternalLinks(presenter: self, data: data)

    init(data: AppDataStore) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown }
    override var preferredStatusBarStyle: UIStatusBarStyle { settings.theme?.isDark == true ? .lightContent : .darkContent }

    override func loadView() { view = AppDuoContentView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.accessibilityIdentifier = "screen.age"
        header.translatesAutoresizingMaskIntoConstraints = false
        heading.text = MainText.text("age_window")
        heading.accessibilityTraits = .header
        heading.translatesAutoresizingMaskIntoConstraints = false
        let skip = makeButton(CatalogText.ui("skip"), icon: .close, kind: .icon) { [weak self] in self?.saveAge(nil) }
        skip.accessibilityIdentifier = "age.skip"
        skip.setIconScale(0.75)
        let logo = UIImageView(image: AppIcon.ageLogo.image)
        logo.contentMode = .scaleAspectFit; logo.translatesAutoresizingMaskIntoConstraints = false
        logo.isAccessibilityElement = false
        header.addSubview(skip); header.addSubview(heading); header.addSubview(logo); view.addSubview(header)
        let scroll = UIView();contentArea=scroll; scroll.translatesAutoresizingMaskIntoConstraints = false
        let content = UIStackView(); content.axis = .vertical; content.spacing = 4
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content); view.addSubview(scroll)
        let region = UIView(); region.translatesAutoresizingMaskIntoConstraints = false
        info.axis = .vertical; info.alignment = .center; info.spacing = 12
        info.translatesAutoresizingMaskIntoConstraints = false
        prompt.text = MainText.text("age_screen")
        prompt.textAlignment = .center
        prompt.numberOfLines = 0
        let numberBox = AppCardView(padding: 8)
        numberBox.widthAnchor.constraint(equalToConstant: 132).isActive = true
        ageLabel.text = "__"; ageLabel.textAlignment = .center
        ageLabel.accessibilityLabel = MainText.text("age_screen")
        ageLabel.accessibilityIdentifier = "age.value"
        numberBox.content.addArrangedSubview(ageLabel)
        info.addArrangedSubview(prompt); info.addArrangedSubview(numberBox); region.addSubview(info)
        NSLayoutConstraint.activate([
            region.heightAnchor.constraint(greaterThanOrEqualToConstant:0),
            info.centerXAnchor.constraint(equalTo: region.centerXAnchor), info.centerYAnchor.constraint(equalTo: region.centerYAnchor),
            info.topAnchor.constraint(greaterThanOrEqualTo: region.topAnchor, constant: 12),
            info.bottomAnchor.constraint(lessThanOrEqualTo: region.bottomAnchor, constant: -12),
            info.leadingAnchor.constraint(greaterThanOrEqualTo: region.leadingAnchor, constant: 12),
            info.trailingAnchor.constraint(lessThanOrEqualTo: region.trailingAnchor, constant: -12)
        ])
        content.addArrangedSubview(region)
        let privacy = makeButton(MainText.text("privacy_policy"), kind: .compact) { [weak self] in self?.links.privacy() }
        let ok = makeButton(MainText.text("ok"), kind: .keypad) { [weak self] in self?.confirm() }
        ok.accessibilityIdentifier = "age.confirm"
        ok.backgroundColor=UIColor.green.withAlphaComponent(0.33);ok.layer.cornerRadius=12
        let actions = UIStackView(arrangedSubviews: [privacy, ok])
        actionRow=actions
        actions.axis = .horizontal; actions.distribution = .fillEqually
        content.addArrangedSubview(actions)
        let keypad = UIStackView(); keypad.axis = .vertical; keypad.spacing = 0;keypad.distribution = .fillEqually
        for digits in [[1,2,3],[4,5,6],[7,8,9],[0,-1]] {
            let row = UIStackView(); row.axis = .horizontal; row.distribution = .fillEqually
            for digit in digits {
                let button: AppButton
                if digit >= 0 {
                    button = makeButton(String(digit), kind: .keypad) { [weak self] in self?.append(digit) }
                    button.accessibilityIdentifier = "age.digit.\(digit)"
                } else {
                    button = makeButton(MainText.text("backspace"), icon: .backspace, kind: .keypadIcon) { [weak self] in self?.deleteDigit() }
                    button.accessibilityIdentifier = "age.delete"
                    button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(clearAge(_:))))
                }
                button.setContentInsets(UIEdgeInsets(top:2,left:4,bottom:2,right:4),minimumHeight:24)
                button.label.adjustsFontSizeToFitWidth=true;button.label.minimumScaleFactor=0.5
                row.addArrangedSubview(button)
            }
            keypad.addArrangedSubview(row)
        }
        content.addArrangedSubview(keypad)
        keypadHeight=keypad.heightAnchor.constraint(equalToConstant:300);keypadHeight?.priority = .init(999);keypadHeight?.isActive=true
        let fill = content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor)
        fill.priority = .defaultLow
        let safe = view.appContentLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: safe.topAnchor), header.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: safe.trailingAnchor), header.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            skip.leadingAnchor.constraint(equalTo: header.unobscuredLayoutGuide.leadingAnchor, constant: 4), skip.centerYAnchor.constraint(equalTo: header.unobscuredLayoutGuide.centerYAnchor),
            skip.widthAnchor.constraint(equalToConstant: AppMetrics.minimumTouchSize), skip.heightAnchor.constraint(equalToConstant: AppMetrics.minimumTouchSize),
            heading.topAnchor.constraint(equalTo: header.unobscuredLayoutGuide.topAnchor, constant: 12), heading.bottomAnchor.constraint(equalTo: header.unobscuredLayoutGuide.bottomAnchor, constant: -12),
            heading.leadingAnchor.constraint(equalTo: skip.trailingAnchor),
            heading.trailingAnchor.constraint(lessThanOrEqualTo: logo.leadingAnchor, constant: -8),
            logo.trailingAnchor.constraint(equalTo: header.unobscuredLayoutGuide.trailingAnchor, constant: -5), logo.centerYAnchor.constraint(equalTo: header.unobscuredLayoutGuide.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 80), logo.heightAnchor.constraint(equalToConstant: 50),
            scroll.topAnchor.constraint(equalTo: header.bottomAnchor), scroll.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: safe.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.topAnchor), content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor), content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor), fill
        ])
        observation = data.$snapshot.sink { [weak self, weak numberBox] progress in
            guard let self else { return }
            self.settings = progress?.settings ?? AppSettings()
            let palette = ThemePalette(settings: self.settings)
            ThemeColorTransition.apply(self.header, color: palette.header)
            self.heading.apply(settings: self.settings)
            self.heading.textColor = palette.theme.isClassic ? .white : palette.text
            self.prompt.apply(settings: self.settings); self.prompt.textColor = palette.text
            self.ageLabel.apply(settings: self.settings); self.ageLabel.textColor = palette.text
            numberBox?.apply(settings: self.settings)
            self.buttons.forEach { $0.apply(settings: self.settings); $0.isEnabled = progress != nil && !self.saving }
            skip.apply(settings: self.settings, tint: UIColor(white: ThemeColor.luminance(palette.header) > 0.18 ? 0.15 : 0.9, alpha: 0.7))
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard settings.onboarding?.phase == .age, !previewPrepared else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, viewIfLoaded?.window != nil, data.snapshot != nil, !previewPrepared else { return }
            previewPrepared = true; prepareThemePreview?(settings)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let horizontal = view.bounds.width > view.bounds.height
        info.axis = horizontal ? .horizontal : .vertical
        keypadHeight?.constant=max(0,((contentArea?.bounds.height ?? 0)-(actionRow?.bounds.height ?? 0)-8)*0.6)
    }
    private func makeButton(_ title: String, icon: AppIcon? = nil, kind: AppButton.Kind, action: @escaping () -> Void) -> AppButton {
        let button = AppButton(title: title, icon: icon, kind: kind, action: action)
        buttons.append(button); return button
    }
    private func append(_ digit: Int) {
        guard !saving else { return }
        if let current = value { if current <= 9 { value = current*10+digit } }
        else { value = digit }
        updateValue()
        AppFeedback.shared.play(.keypress)
    }
    private func deleteDigit() {
        guard !saving else { return }
        value = value.flatMap { $0 >= 10 ? $0/10 : nil }
        updateValue()
    }
    @objc private func clearAge(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, !saving else { return }
        value = nil; updateValue()
    }
    private func updateValue() {
        ageLabel.text = value.map(String.init) ?? "__"
        ageLabel.textColor = ThemePalette(settings: settings).text
    }
    private func confirm() {
        guard !saving, let value else {
            ageLabel.textColor = .systemRed
            AppFeedback.shared.play(.error)
            UIAccessibility.post(notification: .announcement, argument: MainText.text("age_screen"))
            return
        }
        saveAge(value)
    }
    private func saveAge(_ age: Int?) {
        guard !saving, !AppAgeAssurance.shared.requiresSystemAge else { return }
        saving = true; buttons.forEach { $0.isEnabled = false }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.data.updateSettings(.age(age))
                AppFeedback.shared.play(.solution)
            } catch {
                if self.navigationController?.topViewController === self {
                    self.present(AppDialogViewController(title: MainText.text("age_window"), message: MainText.text("onboarding_error"),
                        actions: [.init(title: MainText.text("ok"), handler: {})], data: self.data), animated: false)
                }
            }
            self.saving = false; self.buttons.forEach { $0.isEnabled = true }
        }
    }
}
