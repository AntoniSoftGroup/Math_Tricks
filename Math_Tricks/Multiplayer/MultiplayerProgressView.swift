import UIKit

/// Android's flat five-dp two-player bar, without UIKit's rounded track.
final class MultiplayerProgressView: UIView {
    private let fill = UIView()
    private var progress: CGFloat = 0
    var progressTintColor: UIColor? { didSet { fill.backgroundColor=progressTintColor } }
    var trackTintColor: UIColor? { didSet { backgroundColor=trackTintColor } }
    override init(frame: CGRect) { super.init(frame:frame);addSubview(fill);isAccessibilityElement=true;accessibilityTraits = .updatesFrequently }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func apply(settings: AppSettings) {
        let colors: (UInt32,UInt32)
        switch ThemePalette(settings:settings).theme {
        case .light, .lightAurora: colors = (0x1565C0,0xC62828)
        case .dark, .darkAurora: colors = (0x42A5F5,0xEF5350)
        case .aurora: colors = (0x63CAFF,0xFF6D8A)
        case .neon: colors = (0x00DFFF,0xFF4081)
        }
        progressTintColor = ThemeColor.rgb(colors.0)
        trackTintColor = ThemeColor.rgb(colors.1)
    }
    func setProgress(_ value: Float,animated: Bool) { progress=CGFloat(min(1,max(0,value)));accessibilityValue="\(Int(progress*100))%";setNeedsLayout() }
    override func layoutSubviews() { super.layoutSubviews();fill.frame=CGRect(x:0,y:0,width:bounds.width*progress,height:bounds.height) }
}
