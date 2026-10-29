import UIKit
import FirebaseAuth
import Combine

final class SettingsViewController: ThemedViewController {
    private var switches: [String: UISwitch] = [:]
    private var interactiveRows: [SettingsRow] = []
    private lazy var links = AppExternalLinks(presenter: self, data: data)
    private let balance = AppLabel(.trickName)
    private let balanceIcon = UIImageView(image: AppIcon.coins.image)
    private let versionLabel = AppLabel(.catalogTrick)
    private let dateLabel = AppLabel(.catalogTrick)
    private let footer = UIStackView()
    private let heading = AppLabel(.settingsTitle)
    private var privacy: AppButton!
    private var busy = false
    private var pendingFlags: [String: Bool] = [:]
    private var adPrivacyRow: UIControl?
    private weak var settingsContent: UIStackView?
    private var adPrivacyObservation: AnyCancellable?
    private var cloudObservation: AnyCancellable?
    private var cloudButton: AppButton!

    override func buildContent() {
        view.accessibilityIdentifier = "screen.settings"
        heading.text = title; heading.accessibilityTraits = .header; heading.numberOfLines = 2
        header.replaceTitle(with: heading)
        cloudButton = button(CloudText.text("signInShort"),icon:.cloudUser,kind:.compact) { [weak self] in
            guard let self, !busy else { return }
            if CloudSync.shared.user != nil { self.router?.show(.cloud) }
            else { CloudSignInViewController.show(from:self) }
        }
        cloudButton.accessibilityIdentifier = "settings.signIn"
        cloudButton.label.numberOfLines = 1; cloudButton.label.lineBreakMode = .byTruncatingTail
        cloudButton.setContentInsets(UIEdgeInsets(top:8,left:12,bottom:8,right:12),minimumHeight:48)
        cloudButton.setContentHuggingPriority(.required,for:.horizontal)
        header.setAccessoryView(cloudButton)
        NSLayoutConstraint.activate([
            cloudButton.widthAnchor.constraint(greaterThanOrEqualToConstant:88),
            cloudButton.widthAnchor.constraint(lessThanOrEqualTo:header.widthAnchor,multiplier:0.45)
        ])
        cloudObservation = NotificationCenter.default.publisher(for:CloudSync.changed)
            .receive(on:RunLoop.main).sink { [weak self] _ in self?.updateCloudButton() }
        let column = UIStackView(); column.axis = .vertical; column.translatesAutoresizingMaskIntoConstraints = false
        body.addSubview(column)
        let scroll = AppScrollView(); scroll.alwaysBounceVertical = false; scroll.translatesAutoresizingMaskIntoConstraints = false
        let content = UIStackView(); content.axis = .vertical; content.spacing = 0; content.translatesAutoresizingMaskIntoConstraints = false
        settingsContent = content
        scroll.addSubview(content); column.addArrangedSubview(scroll)
        for (key, icon) in [("sound", AppIcon.sound), ("vibration", .vibration), ("wrong_signal", .wrongSignal)] {
            let control = UISwitch(); control.translatesAutoresizingMaskIntoConstraints = false; control.accessibilityLabel = CatalogText.ui(key); switches[key] = control
            control.addAction(UIAction { [weak self, weak control] _ in
                guard let self, let control else { return }
                save(key == "sound" ? .sound(control.isOn) : key == "vibration" ? .vibration(control.isOn) : .wrongAnswerSignal(control.isOn))
            }, for: .valueChanged)
            let row = makeRow(CatalogText.ui(key), icon: icon, toggle: control)
            row.addAction(UIAction { [weak control] _ in
                guard let control else { return }
                control.setOn(!control.isOn, animated: true); control.sendActions(for: .valueChanged)
            }, for: .touchUpInside)
            content.addArrangedSubview(row)
        }
        content.addArrangedSubview(actionRow(MainText.text("option_theme"), icon: .appearance) { [weak self] in self?.router?.show(.appearance) })
        content.addArrangedSubview(actionRow(CatalogText.ui("numpad"), icon: .numpad) { [weak self] in self?.router?.show(.numpad) })
        content.addArrangedSubview(actionRow(CatalogText.ui("font_size"), icon: .fontSize) { [weak self] in self?.router?.show(.fontSize) })
        // iOS manages application language in Settings. Keep the native link
        // with the language icon rather than an unrelated general-settings row.
        content.addArrangedSubview(actionRow(MainText.text("option_language"), icon: .language) {
            if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
        })
        content.addArrangedSubview(actionRow(CatalogText.ui("exit_settings_title"), icon: .exitConfirmation) { [weak self] in
            guard let self else { return }; ExitConfirmation.showSettings(from: self, data: data)
        })
        content.addArrangedSubview(actionRow(CloudText.text("title"), icon: .savedProgress) { [weak self] in self?.router?.show(.cloud) })
        content.addArrangedSubview(actionRow(CatalogText.ui("reset_progress"), icon: .resetProgress) { [weak self] in self?.offerReset() })
        let adPrivacy = actionRow(MainText.text("ad_privacy_options"), icon: .settings) { [weak self] in
            guard let self else { return }
            AppAdvertising.shared.presentPrivacyOptions(from: self)
        }
        adPrivacy.accessibilityIdentifier = "settings.adPrivacy"
        adPrivacyRow = adPrivacy
        updateAdPrivacy()
        adPrivacyObservation = NotificationCenter.default.publisher(for: AppAdvertising.changed)
            .sink { [weak self] _ in self?.updateAdPrivacy() }
        buildFooter()
        column.addArrangedSubview(footer)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: body.topAnchor), column.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            column.leadingAnchor.constraint(equalTo: body.leadingAnchor), column.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
    }

    private func updateAdPrivacy() {
        guard let row = adPrivacyRow else { return }
        if AppAdvertising.shared.privacyOptionsRequired {
            if row.superview == nil { settingsContent?.addArrangedSubview(row) }
        } else { row.removeFromSuperview() }
        row.isUserInteractionEnabled = !AppAdvertising.shared.isGatheringConsent && !busy
    }

    private func updateCloudButton() {
        let cloud = CloudSync.shared
        cloudButton.label.text = cloud.user == nil ? CloudText.text("signInShort") : cloud.accountName
        cloudButton.accessibilityLabel = cloud.user == nil ? CloudText.text("signedOut") : CloudText.text("account") + ": " + cloud.accountName
        cloudButton.isEnabled = data.snapshot != nil && !cloud.busy
        cloudButton.apply(settings:settings,tint:palette.headerText)
    }

    private func makeRow(_ title: String, icon: AppIcon, toggle: UISwitch? = nil) -> SettingsRow {
        let image = UIImageView(image: icon.image); image.contentMode = .scaleAspectFit
        // Android's settings assets are coloured illustrations, not templates.
        let size = icon.image?.size ?? CGSize(width: 43.75, height: 43.75)
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: size.width),
            image.heightAnchor.constraint(equalToConstant: size.height)
        ])
        image.isAccessibilityElement = false
        let caption = label(title, role: .catalogTrick)
        caption.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let slot = UIView(); slot.translatesAutoresizingMaskIntoConstraints = false
        slot.widthAnchor.constraint(equalToConstant: toggle == nil ? 48 : 56).isActive = true
        slot.heightAnchor.constraint(equalToConstant: 48).isActive = true
        if let toggle {
            slot.addSubview(toggle)
            toggle.setContentHuggingPriority(.required, for: .horizontal)
            toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
            NSLayoutConstraint.activate([
                toggle.centerYAnchor.constraint(equalTo: slot.centerYAnchor),
                toggle.trailingAnchor.constraint(equalTo: slot.trailingAnchor)
            ])
        }
        let row = UIStackView(arrangedSubviews: [image, caption, slot])
        row.axis = .horizontal; row.alignment = .center; row.spacing = 10
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let control = SettingsRow(); control.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false; control.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: control.topAnchor), row.bottomAnchor.constraint(equalTo: control.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: control.leadingAnchor), row.trailingAnchor.constraint(equalTo: control.trailingAnchor)
        ])
        interactiveRows.append(control)
        return control
    }

    private func actionRow(_ title: String, icon: AppIcon, action: @escaping () -> Void) -> UIControl {
        let control = makeRow(title, icon: icon)
        control.isAccessibilityElement = true; control.accessibilityLabel = title; control.accessibilityTraits = .button
        control.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return control
    }

    private func buildFooter() {
        footer.axis = .horizontal; footer.alignment = .bottom; footer.spacing = 8
        footer.isLayoutMarginsRelativeArrangement = true
        footer.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        balanceIcon.contentMode = .scaleAspectFit; balanceIcon.isAccessibilityElement = false
        NSLayoutConstraint.activate([
            balanceIcon.widthAnchor.constraint(equalToConstant: 32), balanceIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        balance.text = "—"; balance.numberOfLines = 1
        let coins = UIStackView(arrangedSubviews: [balanceIcon, balance]); coins.axis = .horizontal; coins.alignment = .center; coins.spacing = 4
        let right = UIStackView(); right.axis = .vertical; right.alignment = .trailing; right.spacing = 0
        privacy = button(MainText.text("privacy_policy"), kind: .plain) { [weak self] in self?.links.privacy() }
        privacy.label.role = .menuCaption; privacy.label.textAlignment = .right
        privacy.setContentInsets(UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1), minimumHeight: 0)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        versionLabel.text = "v\(version)"; versionLabel.textAlignment = .right
        dateLabel.text = AppConstants.releaseDate
        dateLabel.textAlignment = .right
        let versionRow = UIStackView(arrangedSubviews: [versionLabel, dateLabel])
        versionRow.axis = .horizontal; versionRow.alignment = .center; versionRow.spacing = 5
        right.addArrangedSubview(privacy); right.addArrangedSubview(versionRow)
        footer.addArrangedSubview(coins); footer.addArrangedSubview(UIView()); footer.addArrangedSubview(right)
    }

    override func update(_ progress: ProgressState?) {
        updateCloudButton()
        heading.apply(settings: settings)
        heading.font = heading.font.withSize(heading.font.pointSize * 24 / 18)
        heading.textColor = palette.theme == .light ? .white : palette.text
        let values = ["sound": settings.soundEnabled, "vibration": settings.vibrationEnabled, "wrong_signal": settings.signalWrongAnswer]
        for (key, control) in switches {
            let value = pendingFlags[key] ?? values[key] ?? false
            if control.isOn != value { control.setOn(value, animated: false) }
            if control.onTintColor != palette.switchOnTint { control.onTintColor = palette.switchOnTint }
            control.isEnabled = progress != nil
            control.isUserInteractionEnabled = !busy
        }
        interactiveRows.forEach { $0.applyHighlight(settings: appearanceSettings); $0.tintColor = palette.text; $0.isEnabled = progress != nil; $0.isUserInteractionEnabled = !busy }
        balance.text = progress.map { String($0.coins) } ?? "—"
        balance.apply(settings: settings); balance.textColor = palette.text
        balanceIcon.image = AppIcon.coins.image?.withTintColor(palette.accent, renderingMode: .alwaysOriginal)
        versionLabel.apply(settings: settings); versionLabel.textColor = palette.theme.isClassic ? palette.text : palette.secondary
        dateLabel.apply(settings: settings)
        dateLabel.font = versionLabel.font.withSize(versionLabel.font.pointSize / 1.5)
        dateLabel.textColor = palette.accent
        privacy.apply(settings: settings, textTint: palette.theme == .aurora ? .white : palette.secondary)
        if let italic = privacy.label.font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            privacy.label.font = UIFont(descriptor: italic, size: privacy.label.font.pointSize)
        }
    }

    private func save(_ change: SettingsChange) {
        guard !busy else { return }
        switch change {
        case .sound(let value): pendingFlags["sound"] = value
        case .vibration(let value): pendingFlags["vibration"] = value
        case .wrongAnswerSignal(let value): pendingFlags["wrong_signal"] = value
        default: break
        }
        busy = true; update(data.snapshot)
        Task { [weak self] in
            guard let self else { return }
            do { try await data.updateSettings(change) } catch { showError(error) }
            pendingFlags.removeAll(); busy = false; update(data.snapshot)
        }
    }
    private func offerReset() {
        let cloud = CloudSync.shared
        guard !busy, !cloud.busy, !cloud.fileOperationActive else { return }
        let account = cloud.user?.uid
        var alsoCloud = false
        let dialog = AppDialogViewController(title: CatalogText.ui("reset_progress"), message: CatalogText.ui("reset_progress_confirm"),
            actions: [.init(title: CatalogText.ui("cancel"), handler: {}), .init(title: CatalogText.ui("reset_progress"), handler: { [weak self] in self?.confirmReset(alsoCloud:alsoCloud,account:account) })], data: data)
        if account != nil {
            dialog.setCheckbox(CloudText.text("resetAlsoCloud")) { [weak dialog] checked in
                alsoCloud = checked
                dialog?.setMessage(checked ? CloudText.text("resetConfirm") : CatalogText.ui("reset_progress_confirm"))
            }
        }
        present(dialog, animated:false)
    }
    private func confirmReset(alsoCloud: Bool, account: String?) {
        let cloud = CloudSync.shared
        guard !busy, !cloud.busy, !cloud.fileOperationActive else { showError(CloudError.changed); return }
        guard alsoCloud else { performReset(); return }
        guard let account, cloud.user?.uid == account else { showError(CloudError.accountChanged); return }
        busy = true; update(data.snapshot)
        cloud.synchronize(.reset) { [weak self] result in
            guard let self else { return }
            busy = false; update(data.snapshot)
            switch result {
            case .success: router?.show(.main)
            case .failure:
                guard viewIfLoaded?.window != nil, presentedViewController == nil else { return }
                present(AppDialogViewController(title:CatalogText.ui("reset_progress"),message:CloudText.text("resetCloudFailed"),actions:[
                    .init(title:CatalogText.ui("cancel"),handler:{}),
                    .init(title:CatalogText.ui("retry"),handler:{ [weak self] in self?.confirmReset(alsoCloud:true,account:account) }),
                    .init(title:CloudText.text("resetLocalOnly"),handler:{ [weak self] in self?.performReset() })
                ],data:data),animated:false)
            }
        }
    }
    private func performReset() {
        guard !busy, !CloudSync.shared.busy, !CloudSync.shared.fileOperationActive else { showError(CloudError.changed); return }
        busy = true; update(data.snapshot)
        Task { [weak self] in
            guard let self else { return }
            do { try await data.resetLocalProgress(); router?.show(.main) } catch { showError(error) }
            busy = false; update(data.snapshot)
        }
    }
}

private final class SettingsRow: AppListRow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        var target: UIView? = hit
        while let current = target, current !== self {
            if current is UISwitch { return hit }
            target = current.superview
        }
        return self
    }
}
