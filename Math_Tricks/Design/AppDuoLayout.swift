import UIKit

/// Uses the hinge only to scope this opt-in to Duo; layout comes from view geometry.
final class AppDuoContentView: UIView {
    let contentGuide = UILayoutGuide()
    private(set) var hasHinge = false
    private var left: NSLayoutConstraint!
    private var right: NSLayoutConstraint!
    var onDivisionChange: (() -> Void)?
    private var previousDivisions: [CGRect] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addLayoutGuide(contentGuide)
        left = contentGuide.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
        right = contentGuide.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
        NSLayoutConstraint.activate([
            left, right,
            contentGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        // Availability alone cannot hide unknown declarations from an older SDK.
        #if MATH_TRICKS_DUO_SDK
        if #available(iOS 27.1, *) {
            addInteraction(UIHingeInteraction { [weak self] _, update in
                guard let self else { return }
                let available = update.hinge != nil && traitCollection.userInterfaceIdiom == .phone
                guard hasHinge != available else { return }
                hasHinge = available
                invalidateDuoLayout(in: self)
            })
        }
        #endif
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        // Keep vertical safe areas, including the home indicator. Only Duo may
        // reclaim a rail that actually contains an occlusion. The opposite
        // edge keeps its own inset, including any space for rounded corners.
        let safe = safeAreaLayoutGuide.layoutFrame
        let leftRail = CGRect(x: bounds.minX, y: safe.minY, width: safeAreaInsets.left, height: safe.height)
        let rightRail = CGRect(x: safe.maxX, y: safe.minY, width: safeAreaInsets.right, height: safe.height)
        let occlusions = hasHinge ? AppDuoLayout.occlusionFrames(in: self) : []
        left.constant = occlusions.contains { $0.intersects(leftRail) && !leftRail.isEmpty } ? -safeAreaInsets.left : 0
        right.constant = occlusions.contains { $0.intersects(rightRail) && !rightRail.isEmpty } ? safeAreaInsets.right : 0
        // Reading here lets UIKit track fold changes even when the window size
        // stays the same. Layout still uses region geometry, not hinge angles.
        let divisions = AppDuoLayout.divisionFrames(in: self)
        if previousDivisions != divisions {
            previousDivisions = divisions
            onDivisionChange?()
        }
        super.updateConstraints()
    }

    private func invalidateDuoLayout(in target: UIView) {
        target.setNeedsUpdateConstraints()
        target.setNeedsLayout()
        target.subviews.forEach { invalidateDuoLayout(in: $0) }
    }
}

extension UIView {
    var appContentLayoutGuide: UILayoutGuide {
        (self as? AppDuoContentView)?.contentGuide ?? safeAreaLayoutGuide
    }

    var usesDuoLayout: Bool {
        var ancestor: UIView? = self
        while let current = ancestor {
            if let content = current as? AppDuoContentView, content.hasHinge { return true }
            ancestor = current.superview
        }
        return false
    }
}

enum AppDuoLayout {
    /// Active folds only; a flat display keeps the existing layout and spacing.
    static func divisionFrames(in view: UIView) -> [CGRect] {
        guard view.usesDuoLayout else { return [] }
        #if MATH_TRICKS_DUO_SDK
        if #available(iOS 27.1, *) {
            return view.reservedRegions(kind: .division).filter(\.isActive).map(\.frame)
        }
        #endif
        return []
    }

    static func occlusionFrames(in view: UIView) -> [CGRect] {
        guard view.usesDuoLayout else { return [] }
        var obstacles: [CGRect] = []
        #if MATH_TRICKS_DUO_SDK
        if #available(iOS 27.1, *) {
            obstacles = view.reservedRegions(kind: .occlusion).map(\.frame)
            if let scene = view.window?.windowScene, let status = scene.statusBarManager,
               !status.isStatusBarHidden {
                obstacles.append(view.convert(status.statusBarFrame, from: scene.coordinateSpace))
            }
        }
        #endif
        return obstacles
    }

    /// Returns the largest unobscured part of this component, in local coordinates.
    /// Region frames already contain Apple's touch margins; do not add them twice.
    static func unobscuredFrame(in view: UIView, within frame: CGRect) -> CGRect {
        guard view.usesDuoLayout, frame.width > 0, frame.height > 0 else { return frame }
        let obstacles = occlusionFrames(in: view)
        var candidates = [frame]
        for obstacle in obstacles where !obstacle.isEmpty && !obstacle.isNull {
            candidates = candidates.flatMap { candidate -> [CGRect] in
                let overlap = candidate.intersection(obstacle)
                guard !overlap.isNull, !overlap.isEmpty else { return [candidate] }
                return [
                    CGRect(x: candidate.minX, y: candidate.minY, width: max(0, overlap.minX - candidate.minX), height: candidate.height),
                    CGRect(x: overlap.maxX, y: candidate.minY, width: max(0, candidate.maxX - overlap.maxX), height: candidate.height),
                    CGRect(x: candidate.minX, y: candidate.minY, width: candidate.width, height: max(0, overlap.minY - candidate.minY)),
                    CGRect(x: candidate.minX, y: overlap.maxY, width: candidate.width, height: max(0, candidate.maxY - overlap.maxY))
                ].filter { !$0.isEmpty }
            }
        }
        return candidates.max { $0.width * $0.height < $1.width * $1.height } ?? .zero
    }
}

/// The background keeps its full frame; only this component's foreground moves.
class AppDuoAvoidingView: UIView {
    let unobscuredLayoutGuide = UILayoutGuide()
    private var edges: [NSLayoutConstraint] = []
    private var previousBounds = CGRect.null

    override init(frame: CGRect) {
        super.init(frame: frame)
        addLayoutGuide(unobscuredLayoutGuide)
        edges = [
            unobscuredLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
            unobscuredLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            unobscuredLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
            unobscuredLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(edges)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        if previousBounds != bounds {
            previousBounds = bounds
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }

    override func updateConstraints() {
        let frame = AppDuoLayout.unobscuredFrame(in: self, within: bounds)
        edges[0].constant = frame.minX - bounds.minX
        edges[1].constant = frame.minY - bounds.minY
        edges[2].constant = frame.maxX - bounds.maxX
        edges[3].constant = frame.maxY - bounds.maxY
        super.updateConstraints()
    }
}
