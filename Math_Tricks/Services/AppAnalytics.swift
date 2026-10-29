import AppTrackingTransparency
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

@MainActor
final class AppAnalytics {
    static let shared = AppAnalytics()
    private var configured = false

    func configure() {
        guard !configured else { return }
        let began = ProcessInfo.processInfo.systemUptime
        defer { NSLog("Startup Firebase initialization: %.3f s",ProcessInfo.processInfo.systemUptime - began) }
        #if DEBUG
        assert(Self.hasConsent(1, in: "1001001", gdprApplies: true))
        assert(!Self.hasConsent(3, in: "1001001", gdprApplies: true))
        assert(!Self.hasConsent(7, in: "1", gdprApplies: true))
        assert(!Self.hasConsent(1, in: "", gdprApplies: true))
        assert(Self.hasConsent(1, in: "", gdprApplies: false))
        assert(Self.hasConsent(755, in: String(repeating: "0", count: 754) + "1", gdprApplies: true))
        #endif
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path),
              options.bundleID == Bundle.main.bundleIdentifier else {
            NSLog("Firebase disabled: add GoogleService-Info.plist for com.antoni.mathtricks.free")
            return
        }
        FirebaseApp.configure(options: options)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        configured = true
        updateAdvertisingConsent(age: 0, canRequestAds: false)
        // Match Android: basic Analytics starts immediately; advertising consent is separate.
        Analytics.setAnalyticsCollectionEnabled(true)
        recordVersionLaunch()
    }

    func updateAdvertisingConsent(age: Int, canRequestAds: Bool) {
        guard configured else { return }
        let defaults = UserDefaults.standard
        let purposes = defaults.string(forKey: "IABTCF_PurposeConsents") ?? ""
        let vendors = defaults.string(forKey: "IABTCF_VendorConsents") ?? ""
        let gdprApplies = defaults.integer(forKey: "IABTCF_gdprApplies") == 1
        let advertisingAllowed = age >= 16 && canRequestAds
            && ATTrackingManager.trackingAuthorizationStatus == .authorized
            && (!gdprApplies || Self.hasConsent(755, in: vendors, gdprApplies: true))
        func consent(_ purpose: Int) -> ConsentStatus {
            advertisingAllowed && Self.hasConsent(purpose, in: purposes, gdprApplies: gdprApplies) ? .granted : .denied
        }
        Analytics.setConsent([
            .analyticsStorage: .granted,
            .adStorage: consent(1),
            .adUserData: consent(7),
            .adPersonalization: consent(3) == .granted && consent(4) == .granted ? .granted : .denied
        ])
    }

    private static func hasConsent(_ id: Int, in choices: String, gdprApplies: Bool) -> Bool {
        guard id > 0 else { return false }
        if choices.isEmpty { return !gdprApplies }
        return choices.dropFirst(id - 1).first == "1"
    }

    private func recordVersionLaunch() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let parameters: [String: Any] = ["app_version": version, "version_code": Int(build) ?? 0]
        Analytics.logEvent("app_version_launch", parameters: parameters)
        let key = "analytics_version_launches.reported_\(build)_\(version)"
        if !UserDefaults.standard.bool(forKey: key) {
            Analytics.logEvent("app_version_first_launch", parameters: parameters)
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}
