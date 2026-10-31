import UIKit

class AppDuoViewController: UIViewController {
    override func loadView() { view = AppDuoContentView() }
    override var prefersStatusBarHidden: Bool { viewIfLoaded?.usesDuoLayout == true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        viewIfLoaded?.usesDuoLayout == true ? .all : super.supportedInterfaceOrientations
    }
}

/// Shared camera-safe bounds. Folding does not resize an undivided screen;
/// screens with two related panes opt into AppDuoSplitView themselves.
final class AppDuoContentView: UIView {
    let contentGuide = UILayoutGuide()
    private(set) var hasHinge = false
    var onDuoAvailabilityChange: ((Bool) -> Void)? {
        didSet { onDuoAvailabilityChange?(hasHinge) }
    }
    var onDivisionChange: (() -> Void)?
    private var edges: [NSLayoutConstraint] = []
    private let cameraBar = UIView()
    private var previousRegions: [CGRect] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addLayoutGuide(contentGuide)
        setContentAnchors(to: safeAreaLayoutGuide)
        cameraBar.backgroundColor = .black
        cameraBar.isUserInteractionEnabled = false
        cameraBar.accessibilityElementsHidden = true
        addSubview(cameraBar)
        #if MATH_TRICKS_DUO_SDK
        if #available(iOS 27.1, *) {
            addInteraction(UIHingeInteraction { [weak self] _, update in
                guard let self else { return }
                let available = update.hinge != nil && traitCollection.userInterfaceIdiom == .phone
                guard hasHinge != available else { return }
                hasHinge = available
                onDuoAvailabilityChange?(available)
                owningController?.setNeedsStatusBarAppearanceUpdate()
                window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                if #available(iOS 16.0, *) {
                    owningController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                    window?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
                invalidateDuoLayout(in: self)
            })
        }
        #endif
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var owningController: UIViewController? {
        var responder: UIResponder? = next
        while let current = responder {
            if let controller = current as? UIViewController { return controller }
            responder = current.next
        }
        return nil
    }

    private func setContentAnchors(to guide: UILayoutGuide) {
        NSLayoutConstraint.deactivate(edges)
        edges = [
            contentGuide.leftAnchor.constraint(equalTo: guide.leftAnchor),
            contentGuide.topAnchor.constraint(equalTo: guide.topAnchor),
            contentGuide.rightAnchor.constraint(equalTo: guide.rightAnchor),
            contentGuide.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(edges)
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        let occlusions = AppDuoLayout.occlusionFrames(in: self)
        let divisions = AppDuoLayout.divisionFrames(in: self)
        let bottom = max(safeAreaInsets.bottom, AppDuoLayout.bottomCameraInset(in: self))
        edges[0].constant = hasHinge ? -safeAreaInsets.left : 0
        edges[1].constant = hasHinge ? -safeAreaInsets.top : 0
        edges[2].constant = hasHinge ? safeAreaInsets.right : 0
        edges[3].constant = hasHinge ? -(bottom - safeAreaInsets.bottom) : 0
        let regions = occlusions + divisions
        if previousRegions != regions {
            previousRegions = regions
            invalidateDuoLayout(in: self)
            onDivisionChange?()
        }
        super.updateConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = AppDuoLayout.bottomCameraInset(in: self)
        cameraBar.frame = CGRect(x: bounds.minX, y: bounds.maxY - inset, width: bounds.width, height: inset)
        cameraBar.isHidden = inset <= 0
        bringSubviewToFront(cameraBar)
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
        }
        #endif
        return obstacles
    }

    static func bottomCameraInset(in view: UIView) -> CGFloat {
        guard view.usesDuoLayout else { return 0 }
        return occlusionFrames(in: view).filter {
            $0.midY > view.bounds.midY && $0.maxY >= view.bounds.maxY - max(view.safeAreaInsets.bottom, $0.height)
        }.map { max(0, view.bounds.maxY - $0.minY) }.max() ?? 0
    }

    static func headerHeight(in view: UIView, minimum: CGFloat = AppMetrics.headerHeight) -> CGFloat {
        let cameras = occlusionFrames(in: view).filter { $0.minY <= view.bounds.minY + minimum && $0.midY < view.bounds.midY }
        return max(minimum, cameras.map { $0.maxY - view.bounds.minY }.max() ?? 0)
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
    var extendsAcrossTopCamera = false
    private var cameraHeight: NSLayoutConstraint?

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
        var frame = AppDuoLayout.unobscuredFrame(in: self, within: bounds)
        if extendsAcrossTopCamera {
            if cameraHeight == nil {
                cameraHeight = heightAnchor.constraint(greaterThanOrEqualToConstant: AppMetrics.headerHeight)
                cameraHeight?.isActive = true
            }
            let cameras = AppDuoLayout.occlusionFrames(in: self).filter { camera in
                guard let window else { return false }
                return camera.intersects(bounds) && convert(camera, to: window).midY < window.bounds.midY
            }
            cameraHeight?.constant = max(AppMetrics.headerHeight, cameras.map(\.maxY).max() ?? 0)
            if let camera = cameras.max(by: { $0.width < $1.width }) {
                // A top-left camera moves Back physically to its right in any language.
                let left = camera.midX < bounds.midX ? max(bounds.minX, camera.maxX) : bounds.minX
                let right = camera.midX >= bounds.midX ? min(bounds.maxX, camera.minX) : bounds.maxX
                frame = CGRect(x: left, y: bounds.minY, width: max(0, right - left), height: bounds.height)
            }
        }
        edges[0].constant = frame.minX - bounds.minX
        edges[1].constant = frame.minY - bounds.minY
        edges[2].constant = frame.maxX - bounds.maxX
        edges[3].constant = frame.maxY - bounds.maxY
        super.updateConstraints()
    }
}
