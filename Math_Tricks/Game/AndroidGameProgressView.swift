import UIKit

/// Android's five-dp nine-patch timer with a distinct themed fill and track.
final class AndroidGameProgressView: UIView {
    private let track = UIImageView(), fill = UIImageView()
    private var progress: Float = 1
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(track); addSubview(fill)
        isAccessibilityElement = true; accessibilityTraits = .updatesFrequently
        let height=heightAnchor.constraint(equalToConstant:5);height.priority = .init(999);height.isActive=true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func apply(settings: AppSettings) {
        let palette = ThemePalette(settings: settings), dark = palette.theme.isDark
        let (h,s,v) = ThemeColor.hsv(palette.accent)
        let tint = UIColor(hue:h,saturation:s,brightness:dark ? max(0.85,v) : v,alpha:1)
        let trackTint = ThemeColor.blend(palette.background,tint,dark ? 0.24 : 0.18)
        track.image = (dark ? AndroidImages.darkGameProgressTrack : AndroidImages.gameProgressTrack)?.withTintColor(trackTint, renderingMode: .alwaysOriginal)
        fill.image = (dark ? AndroidImages.darkGameProgressFill : AndroidImages.gameProgressFill)?.withTintColor(tint, renderingMode: .alwaysOriginal)
    }
    func setProgress(_ value: Float, animated: Bool) {
        progress = min(1,max(0,value)); accessibilityValue = "\(Int(progress * 100))%"; setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews(); track.frame = bounds
        fill.frame = CGRect(x: 0, y: 0, width: bounds.width * CGFloat(progress), height: bounds.height)
    }
}
