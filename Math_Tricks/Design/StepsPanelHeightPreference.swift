import UIKit

/// Independent persistent portrait sizes for Rule and Solution, in logical points.
struct StepsPanelHeightPreference {
    enum Screen { case rule, solution }
    static let increment = 24
    private let key: String

    init(screen: Screen) {
        key = screen == .rule ? "rule_steps_portrait_height" : "solution.stepsPortraitHeight"
    }
    var savedHeight: CGFloat? {
        guard let value = UserDefaults.standard.object(forKey:key) as? NSNumber else { return nil }
        let height = CGFloat(value.doubleValue)
        return height.isFinite && height > 0 ? height : nil
    }
    func height(in limits: ClosedRange<CGFloat>) -> CGFloat {
        let preferred = savedHeight ?? limits.upperBound * 0.5
        return min(limits.upperBound, max(limits.lowerBound, preferred))
    }
    func resize(by delta: Int, currentHeight: CGFloat, limits: ClosedRange<CGFloat>) -> CGFloat {
        let height = min(limits.upperBound, max(limits.lowerBound, currentHeight + CGFloat(delta)))
        UserDefaults.standard.set(Double(height), forKey: key)
        return height
    }
}
