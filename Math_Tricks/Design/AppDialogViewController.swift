import UIKit
import Combine

/// Shared app dialog. UIKit owns presentation; the message can scroll in landscape
/// or at accessibility text sizes, including the action buttons.
final class AppDialogViewController: AppDuoViewController {
    enum ActionLayout { case stacked, footer }
    struct Action {
        let title: String
        let handler: () -> Void
        var isSecondary = false
    }

    private var checkboxTitle: String?
    private var checkboxChanged: ((Bool) -> Void)?
    private let checkbox = AndroidCheckBox()
    private let checkboxLabel = AppLabel(.dialog)
    private var choices: [String] = []
    private var selection: Int = -1
    private var selectionChanged: ((Int) -> Void)?
    private var choiceButtons: [AppButton] = []
    private let message: String
    private let actionLayout: ActionLayout
    private let actions: [Action]
    private let data: AppDataStore
    private let messageLabel = AppLabel(.dialog)
    private var buttons: [AppButton] = []
    private var observation: AnyCancellable?

    init(title: String, message: String, actions: [Action], data: AppDataStore, actionLayout: ActionLayout = .stacked) {
        precondition(!actions.isEmpty, "A dialog needs a way to close it")
        self.message = message
        self.actions = actions
        self.actionLayout = actionLayout
        self.data = data
        super.init(nibName: nil, bundle: nil)
        self.title = title
        modalPresentationStyle = .overFullScreen; modalPresentationCapturesStatusBarAppearance = true
        modalTransitionStyle = .crossDissolve
    }

    func setChoices(_ choices: [String], selected: Int, onChange: @escaping (Int) -> Void) {
        self.choices = choices; selection = selected; selectionChanged = onChange
    }
    func setCheckbox(_ title: String, onChange: @escaping (Bool) -> Void) {
        checkboxTitle = title; checkboxChanged = onChange
    }
    func setMessage(_ text: String) { messageLabel.text = text; messageLabel.isHidden = text.isEmpty }
    func setPrimaryTitle(_ title: String) { buttons.last?.label.text = title }
    func setPrimaryEnabled(_ enabled: Bool) { buttons.last?.isEnabled = enabled }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        view.accessibilityViewIsModal = true
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let background = ThemeSurfaceView(.dialog)
        background.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(background)
        let footer: UIStackView? = actionLayout == .footer ? UIStackView() : nil
        if let footer {
            footer.axis = .horizontal; footer.alignment = .center; footer.spacing = 8
            footer.translatesAutoresizingMaskIntoConstraints = false
            footer.addArrangedSubview(UIView()); card.addSubview(footer)
            NSLayoutConstraint.activate([
                footer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppMetrics.dialogPadding),
                footer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppMetrics.dialogPadding),
                footer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppMetrics.dialogPadding)
            ])
        }
        let scroll = AppScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(scroll)
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        view.addSubview(card)
        let preferredHeight = scroll.heightAnchor.constraint(equalTo: content.heightAnchor)
        preferredHeight.priority = .defaultHigh
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: card.topAnchor),
            background.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: card.topAnchor, constant: AppMetrics.dialogPadding),
            scroll.bottomAnchor.constraint(equalTo: footer?.topAnchor ?? card.bottomAnchor, constant: footer == nil ? -AppMetrics.dialogPadding : -8),
            scroll.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppMetrics.dialogPadding),
            scroll.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppMetrics.dialogPadding),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 44), preferredHeight
        ])
        let heading = AppLabel(.title, weight: 500)
        heading.text = title
        heading.textAlignment = .center
        heading.accessibilityTraits = .header
        content.addArrangedSubview(heading)
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.isHidden = message.isEmpty
        content.addArrangedSubview(messageLabel)
        if let checkboxTitle {
            checkbox.accessibilityIdentifier = "reset.alsoCloud"
            checkbox.accessibilityLabel = checkboxTitle
            checkbox.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                checkboxChanged?(checkbox.isOn)
            },for:.valueChanged)
            checkboxLabel.text = checkboxTitle
            checkboxLabel.numberOfLines = 0
            checkboxLabel.isAccessibilityElement = false
            checkboxLabel.isUserInteractionEnabled = true
            checkboxLabel.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(toggleCheckbox)))
            let row = UIStackView(arrangedSubviews:[checkbox,checkboxLabel])
            row.axis = .horizontal; row.alignment = .center; row.spacing = 8
            checkbox.widthAnchor.constraint(equalToConstant:48).isActive = true
            checkbox.heightAnchor.constraint(equalToConstant:48).isActive = true
            content.addArrangedSubview(row)
        }
        for (index, choice) in choices.enumerated() {
            let button = AppButton(title: (selection == index ? "◉ " : "○ ") + choice, kind: .dialog) { [weak self] in
                guard let self else { return }
                selection = index
                for (i, button) in choiceButtons.enumerated() { button.label.text = (i == index ? "◉ " : "○ ") + choices[i] }
                selectionChanged?(index)
            }
            choiceButtons.append(button); content.addArrangedSubview(button)
        }
        for action in actions {
            if action.isSecondary, footer == nil {
                let divider = UIView()
                divider.backgroundColor = .separator
                divider.heightAnchor.constraint(equalToConstant: 1 / traitCollection.displayScale).isActive = true
                content.addArrangedSubview(divider)
            }
            let button = AppButton(title: action.title, kind: actionLayout == .footer || action.isSecondary ? .plain : .dialog) { [weak self] in
                self?.dismiss(animated: false, completion: action.handler)
            }
            if action.isSecondary {
                button.label.role = .dailyCaption
                button.setContentInsets(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), minimumHeight: AppMetrics.minimumTouchSize)
            }
            buttons.append(button)
            if let footer {
                button.label.role = .body
                button.setContentInsets(UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8), minimumHeight: 36)
                button.setContentHuggingPriority(.required, for: .horizontal)
                button.widthAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
                footer.addArrangedSubview(button)
            } else { content.addArrangedSubview(button) }
        }
        let safe = view.appContentLayoutGuide
        let width = card.widthAnchor.constraint(equalToConstant: 360)
        width.priority = .defaultHigh
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: safe.centerYAnchor), width,
            card.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -16),
            card.topAnchor.constraint(greaterThanOrEqualTo: safe.topAnchor, constant: 8),
            card.bottomAnchor.constraint(lessThanOrEqualTo: safe.bottomAnchor, constant: -8)
        ])
        observation = data.$snapshot.sink { [weak self, weak heading, weak background] progress in
            let settings = progress?.settings ?? AppSettings()
            let palette = ThemePalette(settings: settings)
            background?.apply(settings: settings)
            heading?.textColor = palette.text
            self?.messageLabel.textColor = palette.text
            heading?.apply(settings: settings)
            self?.messageLabel.apply(settings: settings)
            self?.checkbox.onTintColor = palette.accent
            self?.checkboxLabel.apply(settings: settings)
            self?.checkboxLabel.textColor = palette.text
            self?.choiceButtons.forEach { $0.apply(settings: settings) }
            self?.buttons.forEach { $0.apply(settings: settings) }
        }
    }

    @objc private func toggleCheckbox() {
        guard checkbox.isEnabled else { return }
        checkbox.setOn(!checkbox.isOn,animated:false)
        checkbox.sendActions(for:.valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .screenChanged, argument: title)
    }
}


@MainActor
final class ExitConfirmation {
    private var lastBackPress: TimeInterval?
    private static var behavior: Int {
        get { UserDefaults.standard.object(forKey: "exit_behavior") as? Int ?? -1 }
        set { UserDefaults.standard.set(newValue, forKey: "exit_behavior") }
    }
    private static var choices: [String] {
        ["exit_always_ask", "exit_double_back", "exit_immediately"].map(CatalogText.ui)
    }
    static func showSettings(from presenter: UIViewController, data: AppDataStore) {
        var selected = behavior
        let dialog = AppDialogViewController(title: CatalogText.ui("exit_settings_title"), message: "", actions: [
            .init(title: CatalogText.ui("cancel"), handler: {}),
            .init(title: CatalogText.ui("exit_settings_save"), handler: { if selected >= 0 { behavior = selected } })
        ], data: data, actionLayout: .footer)
        dialog.setChoices(choices, selected: selected) { [weak dialog] index in selected = index; dialog?.setPrimaryEnabled(true) }
        dialog.loadViewIfNeeded(); dialog.setPrimaryEnabled(selected >= 0)
        presenter.present(dialog, animated: false)
    }
    func request(from presenter: UIViewController, data: AppDataStore, onExit: @escaping () -> Void,
                 onShow: () -> Void, onStay: @escaping () -> Void) {
        let behavior = Self.behavior
        if behavior == 2 { onExit(); return }
        if behavior == 1 {
            let now = ProcessInfo.processInfo.systemUptime
            if let lastBackPress, now - lastBackPress <= 2 { self.lastBackPress = nil; onExit() }
            else { lastBackPress = now; Self.toast(CatalogText.ui("exit_press_back_again"), from: presenter) }
            return
        }
        var selected = -1
        let dialog = AppDialogViewController(title: CatalogText.ui("exit_dialog_message"), message: "", actions: [
            .init(title: CatalogText.ui("dialog_no"), handler: onStay),
            .init(title: CatalogText.ui("dialog_yes"), handler: {
                if selected >= 0 { Self.behavior = selected; Self.toast(CatalogText.ui("exit_choice_settings_hint"), from: presenter.view.window?.rootViewController ?? presenter) }
                onExit()
            })
        ], data: data, actionLayout: .footer)
        if behavior == -1 {
            dialog.setChoices(Self.choices, selected: -1) { [weak dialog] index in selected = index; dialog?.setPrimaryTitle(CatalogText.ui("exit_yes_save")) }
        }
        onShow(); presenter.present(dialog, animated: false)
    }
    private static func toast(_ text: String, from presenter: UIViewController) {
        let label = UILabel(); label.text = text; label.numberOfLines = 0; label.textAlignment = .center
        label.textColor = .white; label.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        label.layer.cornerRadius = 10; label.clipsToBounds = true; label.translatesAutoresizingMaskIntoConstraints = false
        presenter.view.addSubview(label)
        NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: presenter.view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: presenter.view.appContentLayoutGuide.bottomAnchor, constant: -24),
            label.widthAnchor.constraint(lessThanOrEqualTo: presenter.view.widthAnchor, multiplier: 0.9),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { label.removeFromSuperview() }
    }
}
