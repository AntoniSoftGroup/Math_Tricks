import UIKit

/// Bound the export bitmap even when a zoomed math diagram is unusually large.
/// Callers present the resulting image only through a user-requested share sheet.
enum AppSnapshotImage {
    static func make(view: UIView, background: UIColor) -> UIImage? {
        view.layoutIfNeeded()
        let size = view.bounds.size
        guard size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0,
              size.width <= 16_384, size.height <= 16_384 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.preferredRange = .standard
        format.scale = min(2, sqrt(8_000_000 / (size.width * size.height)))
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            background.setFill(); context.fill(CGRect(origin: .zero, size: size))
            view.layer.render(in: context.cgContext)
        }
    }
}
