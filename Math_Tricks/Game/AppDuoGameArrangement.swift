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

/// A stack on other devices; a native, animated pair of panes on the inner Duo display.
/// The original views survive every fold/unfold and keep their current state.
final class AppDuoSplitView: UIView {
    private let stack = UIStackView()
    private var panes: [UIView] = []
    private var arrangement: (any AppDuoGameArranging)?
    private var paneConstraints: [NSLayoutConstraint] = []
    var onArrangementChange: (() -> Void)?
    private weak var owner: UIViewController?
    var usesNativeArrangement: Bool { arrangement != nil }
    var isHorizontal: Bool? { arrangement?.isHorizontal }
    var axis: NSLayoutConstraint.Axis {
        get { stack.axis }
        set { stack.axis = newValue }
    }
    var distribution: UIStackView.Distribution {
        get { stack.distribution }
        set { stack.distribution = newValue }
    }
    var spacing: CGFloat {
        get { stack.spacing }
        set { stack.spacing = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func addArrangedSubview(_ pane: UIView) {
        precondition(panes.count < 2)
        panes.append(pane)
        stack.addArrangedSubview(pane)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        synchronizeArrangement()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil { synchronizeArrangement() }
    }

    func removeAllArrangedSubviews() {
        detachArrangement()
        panes.forEach { stack.removeArrangedSubview($0); $0.removeFromSuperview() }
        panes = []
    }

    private func detachArrangement() {
        NSLayoutConstraint.deactivate(paneConstraints)
        paneConstraints = []
        if let old = arrangement {
            old.controller.willMove(toParent: nil)
            old.controller.view.removeFromSuperview()
            old.controller.removeFromParent()
            arrangement = nil
        }
        stack.isHidden = false
    }

    func synchronizeArrangement() {
        let shouldUse = window != nil && panes.count == 2 && AppDuoGameArrangement.canUse(in: self)
        guard shouldUse != usesNativeArrangement else { return }
        var responder: UIResponder? = next
        while responder != nil && !(responder is UIViewController) { responder = responder?.next }
        guard let owner = (responder as? UIViewController) ?? owner else { return }
        self.owner = owner
        // Let the screen release its fallback size constraints before reparenting.
        onArrangementChange?()
        NSLayoutConstraint.deactivate(paneConstraints)
        paneConstraints = []
        for pane in panes {
            stack.removeArrangedSubview(pane)
            pane.removeFromSuperview()
        }
        if let old = arrangement {
            old.controller.willMove(toParent: nil)
            old.controller.view.removeFromSuperview()
            old.controller.removeFromParent()
            arrangement = nil
        }
        if shouldUse, let next = AppDuoGameArrangement.make() {
            arrangement = next
            next.onAxisChange = { [weak self, weak owner] in
                self?.onArrangementChange?()
                owner?.view.setNeedsLayout()
            }
            owner.addChild(next.controller)
            let host = next.controller.view!
            host.translatesAutoresizingMaskIntoConstraints = false
            addSubview(host)
            paneConstraints = [
                host.topAnchor.constraint(equalTo: topAnchor), host.bottomAnchor.constraint(equalTo: bottomAnchor),
                host.leadingAnchor.constraint(equalTo: leadingAnchor), host.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
            for (pane, destination) in zip(panes, [next.primaryContent, next.secondaryContent]) {
                destination.addSubview(pane)
                pane.translatesAutoresizingMaskIntoConstraints = false
                paneConstraints += [
                    pane.topAnchor.constraint(equalTo: destination.topAnchor), pane.bottomAnchor.constraint(equalTo: destination.bottomAnchor),
                    pane.leadingAnchor.constraint(equalTo: destination.leadingAnchor), pane.trailingAnchor.constraint(equalTo: destination.trailingAnchor)
                ]
            }
            NSLayoutConstraint.activate(paneConstraints)
            next.controller.didMove(toParent: owner)
            next.update(animated: false)
        } else {
            panes.forEach { stack.addArrangedSubview($0) }
        }
        stack.isHidden = usesNativeArrangement
        onArrangementChange?()
        owner.view.setNeedsLayout()
    }
}
