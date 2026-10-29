import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform
import UIKit

@MainActor
final class AppAdvertising {
    static let shared = AppAdvertising()
    static let changed = Notification.Name("AppAdvertisingChanged")
    private(set) var isGatheringConsent = false
    private var consentBegan: TimeInterval?
    private var requestedAge: Int?
    private var requestFailed = false
    private var consentRetryAfter = Date.distantPast
    private var consentRetryTask: Task<Void, Never>?
    private var sdkStarting = false
    private var sdkStarted = false

    var canRequestAds: Bool {
        AppPurchases.shared.isReady && !AppPurchases.shared.hasFullVersion && sdkStarted && !isGatheringConsent && ConsentInformation.shared.canRequestAds
            && AppAgeAssurance.shared.canContinue(settings: AppDataStore.shared.snapshot?.settings ?? AppDataStore.shared.launchSettings)
    }
    var privacyOptionsRequired: Bool { ConsentInformation.shared.privacyOptionsRequirementStatus == .required }

    func start(from presenter: UIViewController, settings: AppSettings) {
        guard AppPurchases.shared.isReady, !AppPurchases.shared.hasFullVersion, (settings.onboarding?.phase ?? .complete) == .complete,
              AppAgeAssurance.shared.canContinue(settings: settings) else { return }
        // Returning users without an age receive the same restrictions as the youngest group.
        let age = settings.onboarding?.minimumKnownAge ?? 0
        guard requestedAge != age, !isGatheringConsent else { return }
        guard Date() >= consentRetryAfter else { scheduleConsentRetry(); return }
        guard UIApplication.shared.applicationState == .active, presenter.viewIfLoaded?.window != nil,
              presenter.view.window?.rootViewController?.presentedViewController == nil,
              presenter.presentedViewController == nil else {
            if requestFailed, UIApplication.shared.applicationState == .active { scheduleConsentRetry(after: 15) }
            return
        }
        consentRetryTask?.cancel(); consentRetryTask = nil
        requestFailed = false
        requestedAge = age
        consentBegan = ProcessInfo.processInfo.systemUptime
        isGatheringConsent = true
        configureAge(age)
        notifyChanged()
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = age < 16
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self, weak presenter] error in
            Task { @MainActor [weak self, weak presenter] in
                guard let self else { return }
                if let error {
                    self.finish(age: age, error: error)
                    return
                }
                guard let presenter, presenter.viewIfLoaded?.window != nil else {
                    self.finish(age: age, error: URLError(.cancelled))
                    return
                }
                do {
                    // Published GDPR and IDFA messages also sequence Apple's ATT alert.
                    try await ConsentForm.loadAndPresentIfRequired(from: presenter)
                    self.finish(age: age, error: nil)
                } catch { self.finish(age: age, error: error) }
            }
        }
    }

    func becameActive(settings: AppSettings) {
        AppAnalytics.shared.updateAdvertisingConsent(age: settings.onboarding?.minimumKnownAge ?? 0, canRequestAds: canRequestAds)
    }

    func presentPrivacyOptions(from presenter: UIViewController) {
        guard privacyOptionsRequired, !isGatheringConsent, presenter.presentedViewController == nil else { return }
        isGatheringConsent = true
        notifyChanged()
        Task {
            do {
                try await ConsentForm.presentPrivacyOptionsForm(from: presenter)
                finish(age: requestedAge ?? 0, error: nil)
            } catch {
                finish(age: requestedAge ?? 0, error: error)
                if let screen = presenter as? ThemedViewController, screen.viewIfLoaded?.window != nil, screen.presentedViewController == nil {
                    screen.present(AppDialogViewController(title: MainText.text("ad_privacy_options"),
                        message: MainText.text("ad_privacy_error"), actions: [.init(title: MainText.text("ok"), handler: {})], data: screen.data), animated: false)
                }
            }
        }
    }

    private func configureAge(_ age: Int) {
        let configuration = MobileAds.shared.requestConfiguration
        configuration.ageRestrictedTreatment = age >= 16 ? .unspecified : age >= 13 ? .teen : .child
        configuration.maxAdContentRating = age >= 21 ? .matureAudience : age >= 13 ? .teen : .general
    }

    private func finish(age: Int, error: Error?) {
        if let consentBegan { NSLog("Startup consent flow: %.3f s",ProcessInfo.processInfo.systemUptime - consentBegan) }
        consentBegan = nil
        isGatheringConsent = false
        requestFailed = error != nil
        consentRetryTask?.cancel(); consentRetryTask = nil
        if let error {
            NSLog("AdMob consent: %@", error.localizedDescription)
            if ConsentInformation.shared.canRequestAds {
                // Cached consent already permits ads; don't interrupt a working banner to retry.
                requestedAge = age
                consentRetryAfter = .distantPast
            } else {
                // A failed attempt must not block a fresh consent check later in this session.
                requestedAge = nil
                consentRetryAfter = Date().addingTimeInterval(60)
                scheduleConsentRetry()
            }
        } else {
            requestedAge = age
            consentRetryAfter = .distantPast
        }
        AppAnalytics.shared.updateAdvertisingConsent(age: age, canRequestAds: ConsentInformation.shared.canRequestAds)
        if !AppPurchases.shared.hasFullVersion && ConsentInformation.shared.canRequestAds && !sdkStarting && !sdkStarted {
            sdkStarting = true
            MobileAds.shared.start { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.sdkStarting = false
                    self.sdkStarted = true
                    self.notifyChanged()
                }
            }
        }
        notifyChanged()
    }

    private func scheduleConsentRetry(after delay: TimeInterval? = nil) {
        guard requestFailed, consentRetryTask == nil else { return }
        let interval = max(1, delay ?? consentRetryAfter.timeIntervalSinceNow)
        consentRetryTask = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000)) }
            catch { return }
            guard let self else { return }
            consentRetryTask = nil
            // Foreground activation already calls startServices; don't prompt in the background.
            guard requestFailed, UIApplication.shared.applicationState == .active else { return }
            notifyChanged()
        }
    }

    private func notifyChanged() { NotificationCenter.default.post(name: Self.changed, object: self) }
}
