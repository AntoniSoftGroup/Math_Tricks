import UIKit

/// Headers, system bars and backgrounds use Neon's duration and easing.
enum ThemeColorTransition {
    static let duration: TimeInterval = 0.4
    private static let driver = Driver()

    static func eased(_ progress: Double) -> CGFloat {
        let t = min(1, max(0, progress))
        return CGFloat(t * t * (3 - 2 * t))
    }

    static func apply(_ view: UIView, color: UIColor) {
        driver.apply(view: view, layer: view.layer, color: color, animated: view.window != nil && !view.isHidden)
    }

    static func apply(_ layer: CALayer, color: UIColor, animated: Bool) {
        driver.apply(view: nil, layer: layer, color: color, animated: animated)
    }

    private final class Driver: NSObject {
        private struct Change {
            weak var view: UIView?
            weak var layer: CALayer?
            let from: UIColor
            let to: UIColor
            var displayed: UIColor
            var progress: Double = 0
        }
        private var changes: [ObjectIdentifier: Change] = [:]
        private var link: CADisplayLink?
        private var lastFrame: CFTimeInterval = 0

        func apply(view: UIView?, layer: CALayer, color: UIColor, animated: Bool) {
            let key = ObjectIdentifier(layer)
            // Color blending follows the same policy as Neon's background, including Reduce Motion.
            if animated, changes[key]?.to == color { return }
            let displayed = changes[key]?.displayed ?? view?.backgroundColor
                ?? layer.backgroundColor.map { UIColor(cgColor: $0) }
            guard animated, let displayed, displayed != color else {
                changes.removeValue(forKey: key)
                paint(view: view, layer: layer, color: color)
                stopIfFinished()
                return
            }
            changes[key] = Change(view: view, layer: layer, from: displayed, to: color, displayed: displayed)
            if link == nil {
                let link = CADisplayLink(target: self, selector: #selector(frame(_:)))
                link.preferredFramesPerSecond = 30
                link.add(to: .main, forMode: .common)
                self.link = link
                lastFrame = 0
            }
        }

        private func paint(view: UIView?, layer: CALayer, color: UIColor) {
            CATransaction.begin(); CATransaction.setDisableActions(true)
            UIView.performWithoutAnimation {
                if let view { view.backgroundColor = color }
                else { layer.backgroundColor = color.cgColor }
            }
            CATransaction.commit()
        }

        @objc private func frame(_ link: CADisplayLink) {
            let delta = lastFrame == 0 ? 0 : min(0.1, max(0, link.timestamp - lastFrame))
            lastFrame = link.timestamp
            for key in Array(changes.keys) {
                guard var change = changes[key], let layer = change.layer else {
                    changes.removeValue(forKey: key)
                    continue
                }
                let hidden = change.view.map { $0.window == nil || $0.isHidden } ?? false
                change.progress = hidden ? 1 :
                    min(1, change.progress + delta / duration)
                change.displayed = ThemeColor.blend(change.from, change.to, eased(change.progress))
                paint(view: change.view, layer: layer, color: change.displayed)
                if change.progress >= 1 { changes.removeValue(forKey: key) }
                else { changes[key] = change }
            }
            stopIfFinished()
        }

        private func stopIfFinished() {
            guard changes.isEmpty else { return }
            link?.invalidate()
            link = nil
            lastFrame = 0
        }
    }
}
