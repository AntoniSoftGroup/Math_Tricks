import UIKit

/// Four lazily cached, static preview scenes.
final class ThemePreviewView: AppListRow {
    private let sample = FontSamplePreview(kind:0)
    private var currentFrame = 0
    private(set) var appliedTheme: AppTheme?
    private var memoryObserver: NSObjectProtocol?
    override init(frame: CGRect) {
        super.init(frame:frame); clipsToBounds=true;layer.cornerRadius=10;layer.borderWidth=2
        sample.showsSelectionBorder=false;sample.isUserInteractionEnabled=false
        sample.accessibilityElementsHidden=true;addSubview(sample)
        isAccessibilityElement=true;accessibilityTraits = .button
        memoryObserver = NotificationCenter.default.addObserver(forName:UIApplication.didReceiveMemoryWarningNotification, object:nil, queue:.main) { [weak self] _ in
            MainActor.assumeIsolated { self?.sample.discardCachedScenes() }
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { if let memoryObserver { NotificationCenter.default.removeObserver(memoryObserver) } }
    func prepareBackground(settings: AppSettings) {
        backgroundColor=ThemePalette(settings:settings).background
        sample.prepareBackground(settings:settings)
    }
    func apply(settings: AppSettings) {
        applyHighlight(settings: settings)
        appliedTheme = settings.theme ?? .light
        prepareBackground(settings:settings);sample.apply(settings:settings)
        sample.setHostVisible(false)
    }
    func decorate(selected: Bool,color: UIColor,title: String) {
        layer.borderColor=color.withAlphaComponent(selected ? 1 : 90/255).cgColor
        accessibilityLabel=title;accessibilityValue=nil
        accessibilityTraits=selected ? [.button,.selected] : [.button]
    }
    func showFrame(_ frame: Int) {
        guard currentFrame != frame else { return }
        currentFrame = frame; sample.showFrame(frame); sample.setHostVisible(false)
    }
    func setReferenceSize(_ size: CGSize) {sample.referenceSize=size}
    override func layoutSubviews() { super.layoutSubviews();sample.frame=bounds.insetBy(dx:3,dy:3) }
}
