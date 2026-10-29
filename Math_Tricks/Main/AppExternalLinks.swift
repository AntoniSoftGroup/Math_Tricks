import UIKit
import SafariServices
import MessageUI

/// Opens user-selected destinations only. Never sends a message automatically.
final class AppExternalLinks: NSObject, MFMailComposeViewControllerDelegate {
    private weak var presenter: UIViewController?
    private let data: AppDataStore
    init(presenter: UIViewController, data: AppDataStore) { self.presenter = presenter; self.data = data }

    func privacy() { openWeb("https://antonisoftgroup.github.io/privacy.html") }
    func instagram() { openWeb("https://www.instagram.com/math__tricks/") }
    func rate() { openWeb("https://apps.apple.com/app/id1209287132") }
    func support() {
        guard let presenter, presenter.presentedViewController == nil else { return }
        var actions: [AppDialogViewController.Action] = []
        for (name, address) in [("Gmail", "googlegmail:///co"), ("Outlook", "ms-outlook://compose")] {
            guard let url = supportURL(address), UIApplication.shared.canOpenURL(url) else { continue }
            actions.append(.init(title:name,handler:{ [weak self] in self?.openMail(url) }))
        }
        if MFMailComposeViewController.canSendMail() {
            actions.append(.init(title:"Apple Mail",handler:{ [weak self] in self?.composeMail() }))
        }
        guard !actions.isEmpty else {
            if let url = supportURL("mailto:Rusion@bk.ru") { openMail(url) }
            return
        }
        actions.append(.init(title:CatalogText.ui("cancel"),handler:{}))
        presenter.present(AppDialogViewController(title:MainText.text("activity_main_b_support"),message:"",actions:actions,data:data),animated:false)
    }
    private func supportURL(_ address: String) -> URL? {
        guard var components = URLComponents(string:address) else { return nil }
        components.queryItems = [URLQueryItem(name:"subject",value:"Math Tricks Support")]
        if components.scheme != "mailto" { components.queryItems?.append(URLQueryItem(name:"to",value:"Rusion@bk.ru")) }
        return components.url
    }
    private func openMail(_ url: URL) {
        UIApplication.shared.open(url,options:[:]) { [weak self] success in
            if !success { self?.showError("mail_error") }
        }
    }
    private func composeMail() {
        guard let presenter else { return }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["Rusion@bk.ru"])
        composer.setSubject("Math Tricks Support")
        presenter.present(composer,animated:false)
    }
    private func openWeb(_ string: String) {
        guard let url = URL(string: string), let presenter else { return }
        // Store links use the system handler; web pages stay in a Safari sheet.
        if url.host == "apps.apple.com" {
            UIApplication.shared.open(url, options: [:]) { [weak self] success in
                if !success { self?.showError("link_error") }
            }
        } else { presenter.present(SFSafariViewController(url: url), animated: false) }
    }
    private func showError(_ key: String) {
        guard let presenter, presenter.presentedViewController == nil else { return }
        presenter.present(AppDialogViewController(title: "Math Tricks", message: MainText.text(key),
            actions: [.init(title: MainText.text("ok"), handler: {})], data: data), animated: false)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: false)
    }
}
