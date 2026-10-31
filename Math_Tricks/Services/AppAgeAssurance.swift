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
    private var requestID: UUID?
    private var requestTask: Task<Void, Never>?
    private var deadlineTask: Task<Void, Never>?
    private let backgroundTimeout: UInt64 = 10_000_000_000

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
        let id = UUID()
        requestID = id
        startBackgroundDeadline(for: id)
        #if DEBUG
        Self.checkAgePolicy()
        #endif
        requestTask = Task { [weak self, weak presenter] in
            guard let self else { return }
            var required = true
            do {
                if #available(iOS 26.4, *) {
                    required = try await AgeRangeService.shared.requiredRegulatoryFeatures.contains(.declaredAgeRangeRequired)
                } else {
                    required = try await AgeRangeService.shared.isEligibleForAgeFeatures
                }
                // A system call may ignore cancellation and return after the
                // manual screen has opened. Never let that response change it.
                guard checking, requestID == id else { return }
                deadlineTask?.cancel(); deadlineTask = nil
                guard required else { finish(systemAgeRequired: false); return }
                guard let presenter else { finish(systemAgeRequired: false); return }
                // The system sheet waits for the person's answer, without the
                // background deadline interrupting their choice.
                let response = try await AgeRangeService.shared.requestAgeRange(ageGates: 13, 16, 18, in: presenter)
                guard checking, requestID == id else { return }
                switch response {
                case .sharing(let range):
                    try await data.updateSettings(.declaredAgeRange(DeclaredAgeBounds(lowerBound: range.lowerBound, upperBound: range.upperBound)))
                    guard checking, requestID == id else { return }
                    finish(systemAgeRequired: false)
                case .declinedSharing:
                    finish(systemAgeRequired: required)
                @unknown default:
                    finish(systemAgeRequired: required)
                }
            } catch {
                guard checking, requestID == id else { return }
                NSLog("Apple age range: %@", error.localizedDescription)
                // Leave the age unselected so onboarding opens its normal age
                // screen. Only the person's explicit choice is persisted.
                finish(systemAgeRequired: false)
            }
        }
    }

    private func startBackgroundDeadline(for id: UUID) {
        deadlineTask?.cancel()
        deadlineTask = Task { [weak self] in
            guard let self else { return }
            do { try await Task.sleep(nanoseconds: backgroundTimeout) }
            catch { return }
            guard checking, requestID == id else { return }
            NSLog("Apple age range: background check timed out")
            requestTask?.cancel()
            // Do not await cancellation: an unresponsive API must not keep
            // onboarding blocked. The request ID rejects any late response.
            finish(systemAgeRequired: false)
        }
    }

    func retry() {
        guard !checking else { return }
        isReady = false
        NotificationCenter.default.post(name: Self.changed, object: self)
    }

    private func finish(systemAgeRequired: Bool) {
        deadlineTask?.cancel(); deadlineTask = nil
        requestID = nil
        requestTask = nil
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
