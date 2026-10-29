import UIKit

/// Shared by all app-owned scrolling surfaces; system pickers keep UIKit behaviour.
private enum AppScrolling {
    static func update(_ scroll: UIScrollView, allowed: Bool = true, clampOffset: Bool = false) {
        scroll.bounces = false
        scroll.bouncesZoom = false
        scroll.alwaysBounceVertical = false
        scroll.alwaysBounceHorizontal = false
        guard scroll.bounds.width > 0, scroll.bounds.height > 0 else { return }
        let inset = scroll.adjustedContentInset
        let tolerance = 1 / max(1, scroll.traitCollection.displayScale)
        let horizontal = scroll.contentSize.width + inset.left + inset.right > scroll.bounds.width + tolerance
        let vertical = scroll.contentSize.height + inset.top + inset.bottom > scroll.bounds.height + tolerance
        let needsPan = allowed && (horizontal || vertical)
        // Keep pinch available for a fitting diagram, while disabling its pan.
        let canZoom = scroll.maximumZoomScale > scroll.minimumZoomScale
        let enabled = allowed && (needsPan || canZoom)
        if scroll.isScrollEnabled != enabled { scroll.isScrollEnabled = enabled }
        if scroll.panGestureRecognizer.isEnabled != needsPan { scroll.panGestureRecognizer.isEnabled = needsPan }
        guard clampOffset, !scroll.isZooming else { return }
        let minimum = CGPoint(x: -inset.left, y: -inset.top)
        let maximum = CGPoint(x: max(minimum.x, scroll.contentSize.width - scroll.bounds.width + inset.right),
                              y: max(minimum.y, scroll.contentSize.height - scroll.bounds.height + inset.bottom))
        let offset = CGPoint(x: min(maximum.x, max(minimum.x, scroll.contentOffset.x)),
                             y: min(maximum.y, max(minimum.y, scroll.contentOffset.y)))
        if abs(offset.x - scroll.contentOffset.x) > tolerance || abs(offset.y - scroll.contentOffset.y) > tolerance {
            scroll.setContentOffset(offset, animated: false)
        }
    }
}

final class AppScrollView: UIScrollView {
    /// A temporary application lock, independent of whether the content fits.
    var scrollingAllowed = true { didSet { AppScrolling.update(self, allowed: scrollingAllowed) } }
    override init(frame: CGRect = .zero) { super.init(frame: frame); AppScrolling.update(self) }
    required init?(coder: NSCoder) { super.init(coder: coder); AppScrolling.update(self) }
    override var contentSize: CGSize { didSet { AppScrolling.update(self, allowed: scrollingAllowed) } }
    override func layoutSubviews() { super.layoutSubviews(); AppScrolling.update(self, allowed: scrollingAllowed, clampOffset: true) }
    override func adjustedContentInsetDidChange() { super.adjustedContentInsetDidChange(); AppScrolling.update(self, allowed: scrollingAllowed) }
}

final class AppTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) { super.init(frame: frame, style: style); AppScrolling.update(self) }
    required init?(coder: NSCoder) { super.init(coder: coder); AppScrolling.update(self) }
    override var contentSize: CGSize { didSet { AppScrolling.update(self) } }
    override func layoutSubviews() { super.layoutSubviews(); AppScrolling.update(self, clampOffset: true) }
    override func adjustedContentInsetDidChange() { super.adjustedContentInsetDidChange(); AppScrolling.update(self) }
}

final class AppCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout); AppScrolling.update(self)
    }
    required init?(coder: NSCoder) { super.init(coder: coder); AppScrolling.update(self) }
    override var contentSize: CGSize { didSet { AppScrolling.update(self) } }
    override func layoutSubviews() { super.layoutSubviews(); AppScrolling.update(self, clampOffset: true) }
    override func adjustedContentInsetDidChange() { super.adjustedContentInsetDidChange(); AppScrolling.update(self) }
}

final class AppTextView: UITextView {
    override init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer); AppScrolling.update(self)
    }
    required init?(coder: NSCoder) { super.init(coder: coder); AppScrolling.update(self) }
    override var contentSize: CGSize { didSet { AppScrolling.update(self) } }
    override func layoutSubviews() { super.layoutSubviews(); AppScrolling.update(self, clampOffset: true) }
    override func adjustedContentInsetDidChange() { super.adjustedContentInsetDidChange(); AppScrolling.update(self) }
}
