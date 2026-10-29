import UIKit
import GoogleMobileAds

/// The host survives navigation. Its height can follow an adaptive ad or collapse.
final class BannerContainerView: UIView, BannerViewDelegate {
    var onBuyPro: (() -> Void)?
    private var banner: BannerView?
    private var loaded = false
    private var bannerVisible = false
    private var requestedSize = CGSize.zero
    private var retryAfter = Date.distantPast
    private lazy var placeholder = AppButton(title: MainText.text("buy_pro_to_remove_ads"), icon: .noAds, kind: .plain) { [weak self] in self?.onBuyPro?() }
    private var hostedView: UIView?
    private var hostedConstraints: [NSLayoutConstraint] = []
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.94, alpha: 1)
        clipsToBounds = true
        accessibilityIdentifier = "sharedBannerContainer"
        heightConstraint.isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(settings: AppSettings) {
        backgroundColor = ThemePalette(settings: settings).surface
        placeholder.apply(settings: settings, textTint: ThemePalette(settings: settings).text)
    }

    func update(presenter: UIViewController, visible: Bool, canRequestAds: Bool) {
        bannerVisible = visible
        if !canRequestAds {
            if banner != nil { NSLog("AdMob banner removed: canRequestAds=false") }
            banner?.delegate = nil
            banner?.removeFromSuperview()
            if let banner, hostedView === banner {
                NSLayoutConstraint.deactivate(hostedConstraints)
                hostedConstraints = []
                hostedView = nil
            }
            banner = nil; loaded = false
        }
        guard visible, bounds.width > 0 else {
            if !isHidden { NSLog("AdMob banner hidden: visible=%@ width=%.0f", String(visible), bounds.width) }
            collapse(); return
        }
        // Use Google's adaptive size directly so the container matches the requested ad.
        let width = floor(bounds.width)
        let isLandscape = presenter.view.window?.windowScene?.interfaceOrientation.isLandscape
            ?? (presenter.view.bounds.width > presenter.view.bounds.height)
        let adaptiveSize = isLandscape
            ? landscapeAnchoredAdaptiveBanner(width: width)
            : portraitAnchoredAdaptiveBanner(width: width)
        let size = cgSize(for: adaptiveSize)
        guard size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else {
            collapse(); return
        }
        if !canRequestAds { setContent(placeholder, height: size.height); return }
        if banner != nil && requestedSize == size {
            if loaded, let banner { setContent(banner, height: size.height) }
            else { setContent(placeholder, height: size.height) }
            return
        }
        guard UIApplication.shared.applicationState == .active, Date() >= retryAfter else {
            setContent(placeholder, height: size.height); return
        }
        banner?.delegate = nil
        banner?.removeFromSuperview()
        NSLog("AdMob banner request: format=anchored-adaptive size=%.0fx%.0f test=%@", size.width, size.height, String(AppConstants.useTestAds))
        let ad = BannerView(adSize: adaptiveSize)
        ad.adUnitID = AppConstants.useTestAds
            ? "ca-app-pub-3940256099942544/2435281174"
            : "ca-app-pub-4469463872184379/9708489246"
        ad.rootViewController = presenter
        ad.delegate = self
        banner = ad; loaded = false; requestedSize = size
        setContent(placeholder, height: size.height)
        ad.load(Request())
    }

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        guard bannerView === banner else { return }
        loaded = true
        NSLog("AdMob banner loaded: response=%@", String(describing: bannerView.responseInfo))
        if bannerVisible, AppAdvertising.shared.canRequestAds { setContent(bannerView, height: requestedSize.height) }
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        guard bannerView === banner else { return }
        let failure = error as NSError
        let response = failure.userInfo[GADErrorUserInfoKeyResponseInfo] ?? bannerView.responseInfo as Any
        NSLog("AdMob banner failed: domain=%@ code=%ld message=%@ response=%@",
              failure.domain, failure.code, failure.localizedDescription, String(describing: response))
        bannerView.delegate = nil
        bannerView.removeFromSuperview()
        banner = nil; loaded = false
        retryAfter = Date().addingTimeInterval(60)
        if bannerVisible { setContent(placeholder, height: requestedSize.height) }
    }

    func setContent(_ content: UIView, height: CGFloat) {
        guard height.isFinite, height > 0 else {
            collapse()
            return
        }
        if hostedView !== content {
            NSLayoutConstraint.deactivate(hostedConstraints)
            hostedView?.removeFromSuperview()
            hostedView = content
            content.translatesAutoresizingMaskIntoConstraints = false
            addSubview(content)
            hostedConstraints = [
                content.leadingAnchor.constraint(equalTo: leadingAnchor),
                content.trailingAnchor.constraint(equalTo: trailingAnchor),
                content.topAnchor.constraint(equalTo: topAnchor),
                content.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
            NSLayoutConstraint.activate(hostedConstraints)
        }
        setHeight(height)
    }

    /// Keeps the hosted view available for later reuse, without reserving a gap.
    func collapse() {
        setHeight(0)
    }

    private func setHeight(_ height: CGFloat) {
        if heightConstraint.constant != height {
            heightConstraint.constant = height
        }
        isHidden = height == 0
    }
}
