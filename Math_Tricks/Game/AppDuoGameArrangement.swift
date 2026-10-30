import UIKit

/// Erases the new SDK types so the game still builds with Xcode 26.6.
protocol AppDuoGameArranging: AnyObject {
    var controller: UIViewController { get }
    var primaryContent: UIView { get }
    var secondaryContent: UIView { get }
    var isHorizontal: Bool? { get }
    var onAxisChange: (() -> Void)? { get set }
    func update(animated: Bool)
}

enum AppDuoGameArrangement {
    static func canUse(in view: UIView) -> Bool {
        guard view.usesDuoLayout, !view.bounds.isEmpty else { return false }
        #if MATH_TRICKS_DUO_SDK
        if #available(iOS 27.1, *) {
            // Keep the native container on the flat inner display as well, so
            // UIKit owns the complete transition into and out of the fold.
            // The outer display has no division and keeps the phone layout.
            return view.reservedRegions(kind: .division, options: .includeInactive).contains { region in
                let frame = region.frame
                return frame.width < frame.height
                    ? frame.midX > view.bounds.minX && frame.midX < view.bounds.maxX
                    : frame.midY > view.bounds.minY && frame.midY < view.bounds.maxY
            }
        }
        #endif
        return false
    }

    static func make() -> (any AppDuoGameArranging)? {
        #if MATH_TRICKS_DUO_SDK
        if #available(iOS 27.1, *) { return NativeDuoGameArrangement() }
        #endif
        return nil
    }
}

#if MATH_TRICKS_DUO_SDK
@available(iOS 27.1, *)
private final class NativeDuoGameArrangement: UIArrangementViewController, AppDuoGameArranging {
    private let primaryPane = UIViewController()
    private let secondaryPane = UIViewController()
    private var lastHorizontal: Bool?
    private var hasPlacedContent = false
    var onAxisChange: (() -> Void)?

    var controller: UIViewController { self }
    var primaryContent: UIView { primaryPane.view }
    var secondaryContent: UIView { secondaryPane.view }
    var isHorizontal: Bool? {
        guard let current = state(for: .primary), !current.isHidden else { return nil }
        if current.splitAxis == .horizontal { return true }
        if current.splitAxis == .vertical { return false }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        primaryPane.view.backgroundColor = .clear
        secondaryPane.view.backgroundColor = .clear
        setViewController(primaryPane, for: .primary, animated: false)
        setViewController(secondaryPane, for: .secondary, animated: false)
        // Both axes remain supported, including the portrait laptop pose.
        updateArrangement(.split, animated: false)
    }

    func update(animated: Bool) {
        updateArrangement(.split, animated: hasPlacedContent && animated && !UIAccessibility.isReduceMotionEnabled)
        hasPlacedContent = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let horizontal = isHorizontal
        if lastHorizontal != horizontal {
            lastHorizontal = horizontal
            onAxisChange?()
        }
    }
}

#endif
