import DeclaredAgeRange
import UIKit

@MainActor
final class AppAgeAssurance {
    static let shared = AppAgeAssurance()
    static let changed = Notification.Name("AppAgeAssuranceChanged")
    private(set) var isReady = false
    private(set) var requiresSystemAge = false
    private var checking = false
    private var startedAt: TimeInterval?

    func needsManualAge(settings: AppSettings) -> Bool {
        isReady && !requiresSystemAge && settings.onboarding?.hasAgeChoice != true
    }

    func canContinue(settings: AppSettings) -> Bool {
        isReady && !requiresSystemAge && !needsManualAge(settings: settings)
    }

    func start(from presenter: UIViewController, data: AppDataStore) {
        guard !isReady, !checking, let settings = data.snapshot?.settings else { return }
        if settings.onboarding?.hasAgeChoice == true {
            finish(systemAgeRequired: false)
            return
        }
        guard #available(iOS 26.2, *) else { finish(systemAgeRequired: false); return }
        guard UIApplication.shared.applicationState == .active, presenter.viewIfLoaded?.window != nil,
              presenter.presentedViewController == nil,
              presenter.view.window?.rootViewController?.presentedViewController == nil else { return }
        checking = true
        startedAt = ProcessInfo.processInfo.systemUptime
        #if DEBUG
        Self.checkAgePolicy()
        #endif
        Task {
            var required = true
            do {
                if #available(iOS 26.4, *) {
                    required = try await AgeRangeService.shared.requiredRegulatoryFeatures.contains(.declaredAgeRangeRequired)
                } else {
                    required = try await AgeRangeService.shared.isEligibleForAgeFeatures
                }
                guard required else { finish(systemAgeRequired: false); return }
                let response = try await AgeRangeService.shared.requestAgeRange(ageGates: 13, 16, 18, in: presenter)
                switch response {
                case .sharing(let range):
                    try await data.updateSettings(.declaredAgeRange(DeclaredAgeBounds(lowerBound: range.lowerBound, upperBound: range.upperBound)))
                    finish(systemAgeRequired: false)
                case .declinedSharing:
                    finish(systemAgeRequired: required)
                @unknown default:
                    finish(systemAgeRequired: required)
                }
            } catch {
                NSLog("Apple age range: %@", error.localizedDescription)
                do {
                    // Remember unknown age so ads remain CHILD/G and startup never retries this check.
                    try await data.updateSettings(.age(nil))
                    finish(systemAgeRequired: false)
                } catch {
                    NSLog("Age fallback could not save: %@", error.localizedDescription)
                    finish(systemAgeRequired: true)
                }
            }
        }
    }

    func retry() {
        guard !checking else { return }
        isReady = false
        NotificationCenter.default.post(name: Self.changed, object: self)
    }

    private func finish(systemAgeRequired: Bool) {
        if let startedAt {
            NSLog("Startup age check: %.3f s", ProcessInfo.processInfo.systemUptime - startedAt)
        }
        startedAt = nil
        checking = false
        requiresSystemAge = systemAgeRequired
        isReady = true
        NotificationCenter.default.post(name: Self.changed, object: self)
    }

    #if DEBUG
    private static func checkAgePolicy() {
        let child = DeclaredAgeBounds(lowerBound: nil, upperBound: 12)
        assert(child.isValid)
        assert(OnboardingState(phase: .complete, age: 40, declaredAgeRange: child).minimumKnownAge == 0)
        assert(OnboardingState(phase: .complete, declaredAgeRange: .init(lowerBound: 13, upperBound: 17)).minimumKnownAge == 13)
        assert(OnboardingState(phase: .complete, declaredAgeRange: .init(lowerBound: 18, upperBound: nil)).minimumKnownAge == 18)
        assert(OnboardingState(phase: .complete, ageChoiceMade: true).minimumKnownAge == nil)
        assert(OnboardingState(phase: .complete, ageChoiceMade: true).hasAgeChoice)
        assert(!DeclaredAgeBounds(lowerBound: 18, upperBound: 12).isValid)
        assert(!DeclaredAgeBounds(lowerBound: nil, upperBound: nil).isValid)
        assert(OnboardingState(phase: .complete, age: 40).hasAgeChoice)
        assert(OnboardingState(phase: .complete, declaredAgeRange: child).hasAgeChoice)
        assert(!OnboardingState(phase: .age).hasAgeChoice)
    }
    #endif
}
