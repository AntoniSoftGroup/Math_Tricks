import UIKit
import Combine
import AuthenticationServices
import GoogleSignIn

final class CloudViewController: ThemedViewController {
    private let cloud = CloudSync.shared
    private let profile = AppLabel(.body)
    private let status = AppLabel(.caption)
    private let comparison = AppLabel(.body)
    private var capacity: UIStackView!
    private var signIn: AppButton!
    private var observation: AnyCancellable?
    private var signedInButtons: [AppButton] = []
    private var linkAccount: AppButton!
    private var choices: UIStackView!
    private let cloudCard = AppCardView(padding:8)
    let fileCard = AppCardView(padding:8)
    let fileStatus = AppLabel(.body)
    weak var importingPicker: UIDocumentPickerViewController?
    var choosingRevision: Int64?
    var pendingArchive: ProgressArchive?
    var pendingFileIsNative = false
    private let usage = AppLabel(.caption)
    private let localOnly = AppLabel(.caption)
    private var usageTask: Task<Void,Never>?
    private var usageRevision: Int64 = -1
    private var usageText: String?
    private var usageWarning = false
    private var hasLocalOnlyDetails = false

    isolated deinit { usageTask?.cancel() }

    override func buildContent() {
        view.accessibilityIdentifier = "screen.cloud"
        let column = scrollStack(padding:8)
        column.spacing = 8
        cloudCard.accessibilityIdentifier = "progress.cloudSection"
        fileCard.accessibilityIdentifier = "progress.fileSection"
        column.addArrangedSubview(cloudCard); column.addArrangedSubview(fileCard)
        cloudCard.content.spacing = 6; fileCard.content.spacing = 6
        let stack = cloudCard.content
        stack.addArrangedSubview(label(CloudText.text("cloudSection"),role:.settingsTitle))
        for label in [profile,status,comparison] { label.numberOfLines = 0; label.apply(settings:settings); themedLabels.append(label); stack.addArrangedSubview(label) }
        capacity = UIStackView(); capacity.axis = .vertical; capacity.spacing = 8
        capacity.addArrangedSubview(label(CloudText.text("capacityWarning")))
        capacity.addArrangedSubview(button(CloudText.text("exportFile"),icon:.exportFile) { [weak self] in self?.showFileSection() })
        stack.addArrangedSubview(capacity)
        signIn = button(CloudText.text("signInShort"),icon:.cloudUser) { [weak self] in
            guard let self else { return }; CloudSignInViewController.show(from:self)
        }
        signIn.accessibilityIdentifier = "cloud.signIn"
        stack.addArrangedSubview(signIn)
        linkAccount = button(CloudText.text("linkGoogle"),icon:.linkAccount) { [weak self] in
            guard let self, !cloud.busy, !cloud.fileOperationActive, cloud.user != nil,
                  !cloud.hasGoogle || !cloud.hasApple else { return }
            let provider: CloudIdentity.Provider = cloud.hasGoogle ? .apple : .google
            confirm("linkConfirm") { [weak self] in
                guard let self else { return }
                cloud.signIn(provider,from:self,link:true)
            }
        }
        linkAccount.accessibilityIdentifier = "cloud.linkAccount"
        linkAccount.label.role = .detail; linkAccount.label.numberOfLines = 0
        linkAccount.setContentInsets(UIEdgeInsets(top:4,left:12,bottom:4,right:8),minimumHeight:44)
        stack.addArrangedSubview(linkAccount)
        let actions: [(String,AppIcon,() -> Void)] = [
            ("save",AppIcon.cloudUpload,{ [weak self] in self?.cloud.synchronize(.save) }),
            ("restore",.cloudDownload,{ [weak self] in self?.confirm("restoreConfirm") { self?.cloud.synchronize(.restore) } }),
            ("signOut",.signOut,{ [weak self] in self?.confirm("signOutConfirm") { self?.cloud.signOut() } }),
            ("deleteAccount",.deleteAccount,{ [weak self] in self?.confirm("deleteConfirm") { guard let self else { return }; self.cloud.deleteAccount(from:self) } })
        ]
        let saveRow = UIStackView(); saveRow.axis = .horizontal; saveRow.distribution = .fillEqually; saveRow.spacing = 8
        stack.addArrangedSubview(saveRow)
        let accountRow = UIStackView(); accountRow.axis = .horizontal; accountRow.distribution = .fillEqually; accountRow.spacing = 4
        stack.addArrangedSubview(accountRow)
        for (key,icon,handler) in actions {
            let primary = key == "save" || key == "restore"
            let item = button(CloudText.text(key),icon:icon,action:handler)
            item.label.role = .detail
            item.label.numberOfLines = 0
            item.setContentInsets(UIEdgeInsets(top:4,left:12,bottom:4,right:8),minimumHeight:44)
            signedInButtons.append(item)
            if primary { saveRow.addArrangedSubview(item) }
            else { accountRow.addArrangedSubview(item) }
        }
        choices = UIStackView(); choices.axis = .vertical; choices.spacing = 8
        choices.addArrangedSubview(button(CloudText.text("chooseLocal"),icon:.localProgress) { [weak self] in self?.cloud.synchronize(.save,choosingLocal:true) })
        choices.addArrangedSubview(button(CloudText.text("chooseCloud"),icon:.savedProgress) { [weak self] in self?.cloud.synchronize(.save,choosingLocal:false) })
        stack.addArrangedSubview(choices)
        stack.addArrangedSubview(label(CloudText.text("accountHelp"),role:.caption))
        for item in [usage,localOnly] { item.numberOfLines = 0; themedLabels.append(item); stack.addArrangedSubview(item) }
        buildFileSection(in:fileCard.content)
        observation = NotificationCenter.default.publisher(for:CloudSync.changed).receive(on:RunLoop.main).sink { [weak self] _ in self?.update(self?.data.snapshot) }
    }
    override func applyAppearance() {
        super.applyAppearance()
        cloudCard.apply(settings:appearanceSettings); fileCard.apply(settings:appearanceSettings)
        usage.textColor = usageWarning ? .systemRed : palette.secondary
        localOnly.textColor = palette.secondary
    }
    private func refreshUsage(_ progress: ProgressState?) {
        guard let revision = progress?.revision, revision != usageRevision else { return }
        usageRevision = revision
        usageTask?.cancel()
        usageTask = Task { [weak self] in
            guard let self else { return }
            do {
                let bytes = try await data.exportProgressArchive()
                let (text,near,localDetails) = try await Task.detached(priority:.utility) {
                    let p = try CloudProgress(archive:ProgressArchive.decode(bytes))
                    let payload = try CloudPayload(p)
                    let rows = [("trickCapacity",1),("detailCapacity",3),("exampleCapacity",2)]
                    let near = payload.fraction >= 0.8
                    let text = rows.compactMap { key,index -> String? in
                        let percent = min(100,Int(100 * Double(payload.texts[index].utf8.count) / Double(CloudProgress.limit)))
                        return percent >= 80 ? String(format:CloudText.text(key),percent) : nil
                    }.joined(separator:"\n")
                    return (text,near,p.details.values.contains { $0[1] > 10 })
                }.value
                guard !Task.isCancelled, data.snapshot?.revision == revision else { return }
                usageText = text; usageWarning = near; hasLocalOnlyDetails = localDetails
            } catch {
                guard !Task.isCancelled else { return }
                usageText = error as? CloudError == .tooLarge ? CloudText.text("tooLarge") : nil
                usageWarning = error as? CloudError == .tooLarge
            }
            update(data.snapshot)
        }
    }
    func showFileSection() {
        view.layoutIfNeeded()
        if let scroll = fileCard.superview?.superview as? UIScrollView {
            scroll.scrollRectToVisible(fileCard.convert(fileCard.bounds,to:scroll),animated:true)
        }
    }
    private func confirm(_ key: String, action: @escaping () -> Void) {
        present(AppDialogViewController(title:CloudText.text("title"),message:CloudText.text(key),actions:[
            .init(title:CatalogText.ui("cancel"),handler:{}),
            .init(title:MainText.text("ok"),handler:action)
        ],data:data),animated:false)
    }
    override func update(_ progress: ProgressState?) {
        let signedIn = cloud.user != nil, enabled = progress != nil && !cloud.busy && !cloud.fileOperationActive
        profile.text = signedIn ? cloud.accountName : CloudText.text("guest")
        status.text = cloud.status
        capacity.isHidden = !usageWarning && (!signedIn || cloud.capacityFraction < 0.8)
        usage.text = usageText; usage.isHidden = usageText?.isEmpty != false
        usage.textColor = usageWarning ? .systemRed : palette.secondary
        localOnly.text = CloudText.text("localOnlyDetails"); localOnly.isHidden = !hasLocalOnlyDetails
        signIn.isHidden = signedIn
        linkAccount.isHidden = !signedIn
        linkAccount.label.text = cloud.hasGoogle && cloud.hasApple
            ? CloudText.text("providersLinked")
            : CloudText.text(cloud.hasGoogle ? "linkApple" : "linkGoogle")
        linkAccount.accessibilityLabel = cloud.hasGoogle && cloud.hasApple
            ? CloudText.text("appleLinked") + " · " + CloudText.text("googleLinked")
            : linkAccount.label.text
        signedInButtons.forEach { $0.isHidden = !signedIn }
        themedButtons.forEach { $0.isEnabled = enabled }
        linkAccount.isEnabled = enabled && (!cloud.hasGoogle || !cloud.hasApple)
        choices.isHidden = cloud.conflict == nil; comparison.isHidden = cloud.conflict == nil
        refreshUsage(progress)
        if let conflict = cloud.conflict {
            func summary(_ p: CloudProgress) -> String {
                "\(CloudText.text("coins")): \(p.coins)\n\(CloudText.text("unlocks")): \(p.coinUnlocks.count)\n\(CloudText.text("solved")): \(p.stats["totalSolved"] ?? 0)\n\(CloudText.text("maxLevel")): \(p.records["maxLevel"] ?? 5)"
            }
            comparison.text = CloudText.text("local") + "\n" + summary(conflict.local) + "\n\n" + CloudText.text("remote") + "\n" + summary(conflict.remote) + "\n\n" + CloudText.text("comparisonHelp")
        }
    }
}

final class CloudSignInViewController: ThemedViewController {
    private weak var source: ThemedViewController?

    static func show(from presenter: ThemedViewController) {
        guard !CloudSync.shared.busy, !CloudSync.shared.fileOperationActive, CloudSync.shared.user == nil,
              presenter.presentedViewController == nil, let router = presenter.router else { return }
        let picker = CloudSignInViewController(title:CloudText.text("signInShort"),router:router,data:presenter.data)
        picker.source = presenter
        picker.modalPresentationStyle = .formSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(),.large()]; sheet.prefersGrabberVisible = true
        }
        presenter.present(picker,animated:true)
    }

    override func buildContent() {
        view.accessibilityIdentifier = "cloud.signInPicker"
        setHeaderHidden(true)
        let stack = scrollStack(padding:24)
        stack.addArrangedSubview(label(CloudText.text("signInShort"),role:.title))
        stack.addArrangedSubview(label(CloudText.text("signedOut")))
        let apple = ASAuthorizationAppleIDButton(type:.signIn,style:palette.theme.isDark ? .white : .black)
        let googleTitle = GIDSignInButton()
        googleTitle.style = .wide
        var googleStyle = UIButton.Configuration.plain()
        googleStyle.title = googleTitle.accessibilityLabel
        googleStyle.image = UIImage(named:"google_sign_in")
        googleStyle.imagePadding = 8
        googleStyle.baseForegroundColor = palette.theme.isDark ? .black : .white
        googleStyle.background.backgroundColor = palette.theme.isDark ? .white : .black
        googleStyle.background.cornerRadius = apple.cornerRadius
        googleStyle.contentInsets = NSDirectionalEdgeInsets(top:0,leading:12,bottom:0,trailing:12)
        googleStyle.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = UIFont.systemFont(ofSize:19,weight:.medium)
            return attributes
        }
        let google = UIButton(configuration:googleStyle)
        google.contentHorizontalAlignment = .center
        google.titleLabel?.textAlignment = .center
        google.titleLabel?.adjustsFontSizeToFitWidth = true
        google.titleLabel?.minimumScaleFactor = 0.7
        apple.accessibilityIdentifier = "cloud.signIn.apple"
        google.accessibilityIdentifier = "cloud.signIn.google"
        for control in [apple,google] {
            control.heightAnchor.constraint(equalToConstant:48).isActive = true
            stack.addArrangedSubview(control)
        }
        apple.addAction(UIAction { [weak self] _ in self?.choose(.apple) },for:.touchUpInside)
        google.addAction(UIAction { [weak self] _ in self?.choose(.google) },for:.touchUpInside)
        stack.addArrangedSubview(button(CatalogText.ui("cancel"),icon:.close) { [weak self] in self?.dismiss(animated:true) })
    }

    override func applyAppearance() {
        super.applyAppearance()
        view.backgroundColor = palette.background
    }

    private func choose(_ provider: CloudIdentity.Provider) {
        guard let source, !CloudSync.shared.busy else { return }
        dismiss(animated:false) { [weak source] in
            guard let source, source.viewIfLoaded?.window != nil else { return }
            CloudSync.shared.signIn(provider,from:source)
        }
    }
}
