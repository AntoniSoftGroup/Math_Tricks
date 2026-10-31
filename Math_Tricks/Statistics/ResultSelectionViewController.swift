import UIKit

/// Android spinner popup or single-choice radio dialog, with scrolling at large text sizes.
final class ResultSelectionViewController: AppDuoViewController {
    private let values: [String], selection: Int, settings: AppSettings
    private weak var anchor: UIView?
    private let handler: (Int) -> Void
    private let card=UIView(),scroll=AppScrollView(),heading=UILabel(),cancel=UIButton(type:.system)
    private var options: [UIButton] = []
    init(title: String,values: [String],selection: Int,settings: AppSettings,anchor: UIView?,handler: @escaping (Int) -> Void) {
        self.values=values;self.selection=selection;self.settings=settings;self.anchor=anchor;self.handler=handler
        super.init(nibName:nil,bundle:nil);self.title=title;modalPresentationStyle = .overFullScreen; modalPresentationCapturesStatusBarAppearance = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad();view.accessibilityViewIsModal=true
        let backdrop=UIControl();backdrop.frame=view.bounds;backdrop.autoresizingMask=[.flexibleWidth,.flexibleHeight]
        backdrop.backgroundColor=anchor == nil ? UIColor.black.withAlphaComponent(0.55) : .clear
        backdrop.addAction(UIAction { [weak self] _ in self?.dismiss(animated:false) },for:.touchUpInside);view.addSubview(backdrop)
        let palette=ThemePalette(settings:settings),fontSettings=settings
        card.backgroundColor=palette.dialogBackground;card.layer.cornerRadius=anchor == nil ? 20 : 4
        card.layer.shadowColor=UIColor.black.cgColor;card.layer.shadowOpacity=0.3;card.layer.shadowRadius=8;card.layer.shadowOffset=CGSize(width:0,height:4)
        view.addSubview(card);card.addSubview(scroll)
        heading.text=title;heading.numberOfLines=0;heading.textColor=palette.text;heading.font=ResultUI.font(20,settings:settings,weight:500);heading.accessibilityTraits = .header
        heading.isHidden=anchor != nil;card.addSubview(heading)
        cancel.setTitle(CatalogText.ui("cancel"),for:.normal);cancel.titleLabel?.font=ResultUI.font(16,settings:settings);cancel.tintColor=palette.accent
        cancel.isHidden=anchor != nil;cancel.addAction(UIAction { [weak self] _ in self?.dismiss(animated:false) },for:.touchUpInside);card.addSubview(cancel)
        for (index,value) in values.enumerated() {
            let button=UIButton(type:.system)
            var config=UIButton.Configuration.plain();config.title=value;config.baseForegroundColor=palette.text;config.contentInsets=NSDirectionalEdgeInsets(top:12,leading:16,bottom:12,trailing:16);config.titleLineBreakMode = .byWordWrapping
            config.titleTextAttributesTransformer=UIConfigurationTextAttributesTransformer { incoming in var result=incoming;result.font=ResultUI.font(18,settings:fontSettings);return result }
            if anchor == nil {config.image=radio(selected:index==selection,color:index==selection ? palette.accent : palette.secondary);config.imagePadding=24}
            button.configuration=config;button.contentHorizontalAlignment = .leading
            button.accessibilityTraits=index==selection ? [.button,.selected] : [.button]
            let highlight = AppListHighlightView.color(settings: settings)
            let selectedColor: UIColor = anchor != nil && index == selection ? highlight : .clear
            button.configurationUpdateHandler = { button in
                var configuration = button.configuration
                configuration?.background.backgroundColor = button.isHighlighted ? highlight : selectedColor
                button.configuration = configuration
            }
            button.addAction(UIAction { [weak self] _ in guard let self else { return };dismiss(animated:false) { [handler] in handler(index) } },for:.touchUpInside)
            scroll.addSubview(button);options.append(button)
        }
    }
    private func radio(selected: Bool,color: UIColor) -> UIImage {
        UIGraphicsImageRenderer(size:CGSize(width:24,height:24)).image { context in
            color.setStroke();context.cgContext.setLineWidth(2);context.cgContext.strokeEllipse(in:CGRect(x:3,y:3,width:18,height:18))
            if selected {color.setFill();context.cgContext.fillEllipse(in:CGRect(x:8,y:8,width:8,height:8))}
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe=view.appContentLayoutGuide.layoutFrame,dropdown=anchor != nil
        let rect=anchor.map { $0.convert($0.bounds,to:view) }
        let width=min(safe.width-24,dropdown ? max(180,rect?.width ?? 240) : 360)
        var y: CGFloat=0
        for button in options {let height=max(48,button.sizeThatFits(CGSize(width:width,height:.greatestFiniteMagnitude)).height);button.frame=CGRect(x:0,y:y,width:width,height:height);y += height}
        scroll.contentSize=CGSize(width:width,height:y)
        let titleHeight=dropdown ? 0 : heading.sizeThatFits(CGSize(width:width-40,height:.greatestFiniteMagnitude)).height+36
        let footer: CGFloat=dropdown ? 0 : 56
        let height=min(safe.height-24,y+titleHeight+footer)
        let x=dropdown ? min(safe.maxX-width-8,max(safe.minX+8,rect?.minX ?? safe.midX-width/2)) : safe.midX-width/2
        var top=safe.midY-height/2
        if let rect {top=rect.maxY+4;if top+height>safe.maxY-8 {top=max(safe.minY+8,rect.minY-height-4)}}
        card.frame=CGRect(x:x,y:top,width:width,height:height)
        heading.frame=CGRect(x:20,y:20,width:width-40,height:max(0,titleHeight-36))
        scroll.frame=CGRect(x:0,y:titleHeight,width:width,height:max(1,height-titleHeight-footer))
        cancel.frame=CGRect(x:max(8,width-140),y:height-footer,width:min(132,width-16),height:footer)
    }
    override func accessibilityPerformEscape() -> Bool {dismiss(animated:false);return true}
}
