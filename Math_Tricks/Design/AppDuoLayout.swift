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
    enum CameraBandStyle { case bottom, horizontal, vertical }
    let contentGuide = UILayoutGuide()
    private(set) var hasHinge = false
    var cameraBandStyle: CameraBandStyle = .bottom {
        didSet {
            guard oldValue != cameraBandStyle else { return }
            invalidateDuoLayout(in: self)
        }
    }
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
        let band = AppDuoLayout.cameraBandFrame(in: self, style: cameraBandStyle)
        let vertical = cameraBandStyle == .vertical && !band.isEmpty
        let left = vertical && band.midX < bounds.midX ? band.width : 0
        let right = vertical && band.midX >= bounds.midX ? band.width : 0
        let top = cameraBandStyle == .horizontal && !band.isEmpty && band.midY < bounds.midY ? band.height : 0
        let cameraBottom = !vertical && !band.isEmpty && band.midY >= bounds.midY ? band.height : 0
        let bottom = max(safeAreaInsets.bottom, cameraBottom)
        edges[0].constant = hasHinge ? left - safeAreaInsets.left : 0
        edges[1].constant = hasHinge ? top - safeAreaInsets.top : 0
        edges[2].constant = hasHinge ? safeAreaInsets.right - right : 0
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
        let band = AppDuoLayout.cameraBandFrame(in: self, style: cameraBandStyle)
        cameraBar.frame = band
        cameraBar.isHidden = band.isEmpty
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
    static func isInnerDisplay(in view: UIView) -> Bool {
        guard view.usesDuoLayout, let window = view.window else { return false }
        #if MATH_TRICKS_DUO_SDK
        if #available(iOS 27.1, *) {
            return !window.reservedRegions(kind: .division, options: .includeInactive).isEmpty
        }
        #endif
        return false
    }

    /// Only foreground elements at the actual display edge need corner insets.
    /// A scrolling header outside that edge must not grow to chase the safe area.
    static func roundedCornerInsets(in view: UIView, within frame: CGRect? = nil) -> UIEdgeInsets {
        guard isInnerDisplay(in: view), let window = view.window else { return .zero }
        let frame = frame ?? view.bounds
        // Keep the app's normal 16 pt margin when the system reports no edge
        // inset; larger system safe areas take precedence without adding twice.
        let safeWindow = window.safeAreaLayoutGuide.layoutFrame.intersection(
            window.bounds.insetBy(dx: AppMetrics.margin, dy: AppMetrics.margin))
        let safe = view.convert(safeWindow, from: window)
        let display = view.convert(window.bounds, from: window)
        // A collapsed banner still needs its protected width before requesting
        // an adaptive ad, so include a zero-height frame on the display edge.
        guard !safe.isEmpty, frame.width > 0,
              frame.maxX > display.minX, frame.minX < display.maxX,
              frame.maxY >= display.minY, frame.minY <= display.maxY else { return .zero }
        let tolerance = 1 / max(1, view.traitCollection.displayScale)
        return UIEdgeInsets(
            top: frame.minY >= display.minY - tolerance ? max(0, safe.minY - frame.minY) : 0,
            left: frame.minX >= display.minX - tolerance ? max(0, safe.minX - frame.minX) : 0,
            bottom: frame.maxY <= display.maxY + tolerance ? max(0, frame.maxY - safe.maxY) : 0,
            right: frame.maxX <= display.maxX + tolerance ? max(0, frame.maxX - safe.maxX) : 0
        )
    }

    static func roundedCornerSafeFrame(in view: UIView, within frame: CGRect) -> CGRect {
        let insets = roundedCornerInsets(in: view, within: frame)
        return CGRect(x: min(frame.maxX, frame.minX + insets.left),
                      y: min(frame.maxY, frame.minY + insets.top),
                      width: max(0, frame.width - insets.left - insets.right),
                      height: max(0, frame.height - insets.top - insets.bottom))
    }

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

    static func cameraBandFrame(in view: UIView, style: AppDuoContentView.CameraBandStyle) -> CGRect {
        guard view.usesDuoLayout else { return .zero }
        if style == .bottom {
            let inset = bottomCameraInset(in: view)
            return CGRect(x: view.bounds.minX, y: view.bounds.maxY - inset, width: view.bounds.width, height: inset)
        }
        let cameras = occlusionFrames(in: view).map { $0.intersection(view.bounds) }
            .filter { !$0.isNull && !$0.isEmpty }
        guard let camera = cameras.max(by: { $0.width * $0.height < $1.width * $1.height }) else { return .zero }
        if style == .horizontal {
            if camera.midY < view.bounds.midY {
                return CGRect(x: view.bounds.minX, y: view.bounds.minY,
                              width: view.bounds.width, height: camera.maxY - view.bounds.minY)
            }
            return CGRect(x: view.bounds.minX, y: camera.minY,
                          width: view.bounds.width, height: view.bounds.maxY - camera.minY)
        }
        if camera.midX < view.bounds.midX {
            return CGRect(x: view.bounds.minX, y: view.bounds.minY,
                          width: camera.maxX - view.bounds.minX, height: view.bounds.height)
        }
        return CGRect(x: camera.minX, y: view.bounds.minY,
                      width: view.bounds.maxX - camera.minX, height: view.bounds.height)
    }

    static func headerHeight(in view: UIView, minimum: CGFloat = AppMetrics.headerHeight) -> CGFloat {
        let cameras = occlusionFrames(in: view).filter { $0.minY <= view.bounds.minY + minimum && $0.midY < view.bounds.midY }
        let header = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: minimum)
        let corners = roundedCornerInsets(in: view, within: header)
        return max(minimum + corners.top + corners.bottom, cameras.map { $0.maxY - view.bounds.minY }.max() ?? 0)
    }

    static func headerForegroundFrame(in view: UIView) -> CGRect {
        let cameras = occlusionFrames(in: view).filter { camera in
            guard let window = view.window else { return false }
            return camera.intersects(view.bounds) && view.convert(camera, to: window).midY < window.bounds.midY
        }
        var frame = unobscuredFrame(in: view, within: view.bounds)
        if let camera = cameras.max(by: { $0.width < $1.width }) {
            let left = camera.midX < view.bounds.midX ? max(view.bounds.minX, camera.maxX) : view.bounds.minX
            let right = camera.midX >= view.bounds.midX ? min(view.bounds.maxX, camera.minX) : view.bounds.maxX
            frame = CGRect(x: left, y: view.bounds.minY, width: max(0, right - left), height: view.bounds.height)
        }
        return roundedCornerSafeFrame(in: view, within: frame)
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
    var protectsRoundedCorners = false
    var avoidsCameraOcclusions = true
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
        var frame = avoidsCameraOcclusions ? AppDuoLayout.unobscuredFrame(in: self, within: bounds) : bounds
        if extendsAcrossTopCamera {
            if cameraHeight == nil {
                cameraHeight = heightAnchor.constraint(greaterThanOrEqualToConstant: AppMetrics.headerHeight)
                cameraHeight?.isActive = true
            }
            let cameras = AppDuoLayout.occlusionFrames(in: self).filter { camera in
                guard let window else { return false }
                return camera.intersects(bounds) && convert(camera, to: window).midY < window.bounds.midY
            }
            let corners = AppDuoLayout.roundedCornerInsets(in: self)
            cameraHeight?.constant = max(AppMetrics.headerHeight + corners.top + corners.bottom, cameras.map(\.maxY).max() ?? 0)
            frame = AppDuoLayout.headerForegroundFrame(in: self)
        } else if protectsRoundedCorners {
            frame = AppDuoLayout.roundedCornerSafeFrame(in: self, within: frame)
        }
        edges[0].constant = frame.minX - bounds.minX
        edges[1].constant = frame.minY - bounds.minY
        edges[2].constant = frame.maxX - bounds.maxX
        edges[3].constant = frame.maxY - bounds.maxY
        super.updateConstraints()
    }
}

/// Explicit app padding must not expand into a second full-height camera rail.
/// Camera avoidance and corner protection belong to the surrounding container.
final class AppDuoStackView: UIStackView {
    private var originalSafeAreaMargins: Bool?

    override func layoutSubviews() {
        if usesDuoLayout {
            if originalSafeAreaMargins == nil { originalSafeAreaMargins = insetsLayoutMarginsFromSafeArea }
            if insetsLayoutMarginsFromSafeArea { insetsLayoutMarginsFromSafeArea = false }
        } else if let original = originalSafeAreaMargins {
            insetsLayoutMarginsFromSafeArea = original
            originalSafeAreaMargins = nil
        }
        super.layoutSubviews()
    }
}
