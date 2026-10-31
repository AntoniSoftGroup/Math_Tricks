import UIKit
import Combine

/// Android MyColorFragment: local draft, centered carousel and an overlapping settings dock.
final class ThemePickerViewController: AppDuoViewController, UIScrollViewDelegate {
    let isInitialSetup: Bool
    private weak var router: AppRouter?
    private let data: AppDataStore
    private var observation: AnyCancellable?
    private var loaded=false, saving=false, visible=false
    private var draft=AppSettings(), selectedTheme=AppTheme.light
    private var baseColor=ThemeColor.hex("0D47A1")
    private var intensities: [String:Int] = [:]
    private var expanded=true, fontChanged=false, previewFrame=0
    private var geometry=CGSize.zero, cardWidth: CGFloat = 0
    private var previewTask: Task<Void, Never>?
    private var pendingRefresh: DispatchWorkItem?
    private var previewGeneration = 0
    private var carouselMoving: Bool { pages.isDragging || pages.isDecelerating }
    private var activeCardIndex: Int {
        cards.indices.max { cards[$0].frame.intersection(pages.bounds).width < cards[$1].frame.intersection(pages.bounds).width } ?? currentIndex
    }
    private let background=ThemeBackgroundView(), header=UIView(), stage=UIView()
    private let duoLayout = AppDuoSplitView()
    private let carouselPane = UIView(), controlsPane = UIView()
    private var usesDuoPanes = false
    private let pages=AppScrollView(), settingsScroll=AppScrollView()
    private let panel=UIView(), dock=UIView(), fontControls=UIView(), switches=ResultUI.stack(.vertical)
    private var cards=AppTheme.pickerOrder.map { _ in ThemePreviewView() }
    private let nameLabel=UILabel(), codeLabel=UILabel(), fontLabel=UILabel(), intensityLabel=UILabel(), colorLabel=UILabel()
    private let spectrum=ColorSpectrumControl(), intensity=ColorSpectrumControl()
    private let fontSlider=UISlider(), systemMarker=UIView()
    private let categoryColors=UISwitch(), gameColors=UISwitch()
    private let toggle=UIButton(type:.system), cycle=UIButton(type:.system)
    private lazy var applyButton=AppButton(title:ResultText.text("theme_picker_apply"),kind:.dialog) { [weak self] in self?.save() }
    private lazy var backButton=AppButton(title:CatalogText.ui("back"),icon:.back,kind:.icon) { [weak self] in
        guard let self,!saving else { return };router?.goBack()
    }
    private var currentIndex: Int { AppTheme.pickerOrder.firstIndex(of:selectedTheme) ?? 0 }
    init(router: AppRouter,data: AppDataStore,initialSetup: Bool = false, preparedPreview: ThemePreviewView? = nil) {
        self.router=router;self.data=data;isInitialSetup=initialSetup
        if let preparedPreview, let theme = preparedPreview.appliedTheme, let index = AppTheme.pickerOrder.firstIndex(of:theme) { cards[index] = preparedPreview }
        super.init(nibName:nil,bundle:nil);title=CatalogText.ui("theme_title")
        expanded=UserDefaults.standard.object(forKey:"themeSettingsExpanded") as? Bool ?? !initialSetup
    }
    isolated deinit { previewTask?.cancel(); pendingRefresh?.cancel() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let palette=ThemePalette(settings:data.snapshot?.settings ?? AppSettings())
        return palette.theme.isClassic ? (ThemeColor.luminance(palette.systemBar)>0.5 ? .darkContent : .lightContent) : (palette.theme.isDark ? .lightContent : .darkContent)
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { viewIfLoaded?.usesDuoLayout == true || UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown }
    override func loadView() { view = AppDuoContentView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.isHidden=isInitialSetup
        view.addSubview(background);view.addSubview(header);view.addSubview(stage)
        for child in [backButton,nameLabel,applyButton] { child.translatesAutoresizingMaskIntoConstraints = true; header.addSubview(child) }
        stage.addSubview(pages);stage.addSubview(fontControls);stage.addSubview(dock);stage.addSubview(cycle)
        duoLayout.translatesAutoresizingMaskIntoConstraints = false;duoLayout.isHidden = true;stage.addSubview(duoLayout)
        duoLayout.addArrangedSubview(carouselPane);duoLayout.addArrangedSubview(controlsPane)
        duoLayout.onArrangementChange = { [weak self] in self?.geometry = .zero;self?.view.setNeedsLayout() }
        NSLayoutConstraint.activate([
            duoLayout.topAnchor.constraint(equalTo:stage.topAnchor),duoLayout.bottomAnchor.constraint(equalTo:stage.bottomAnchor),
            duoLayout.leadingAnchor.constraint(equalTo:stage.leadingAnchor),duoLayout.trailingAnchor.constraint(equalTo:stage.trailingAnchor)
        ])
        pages.delegate=self;pages.showsHorizontalScrollIndicator=false;pages.decelerationRate = .fast;pages.clipsToBounds=true
        for (index,card) in cards.enumerated() {
            pages.addSubview(card)
            card.addAction(UIAction { [weak self] _ in self?.select(index:index,scroll:true) },for:.touchUpInside)
        }
        dock.addSubview(toggle);dock.addSubview(settingsScroll);settingsScroll.addSubview(panel)
        settingsScroll.alwaysBounceVertical=false
        panel.backgroundColor=UIColor.black.withAlphaComponent(136/255);panel.layer.cornerRadius=12
        panel.layer.borderWidth=1;panel.layer.borderColor=UIColor.white.withAlphaComponent(85/255).cgColor
        colorLabel.text=ResultText.text("theme_picker_color");colorLabel.textColor = .white
        intensityLabel.textColor = .white;codeLabel.textColor = .white
        for label in [colorLabel,intensityLabel] { label.font=ResultUI.font(16,settings:AppSettings());label.numberOfLines=1 }
        codeLabel.font=UIFont.monospacedSystemFont(ofSize:13,weight:.regular);codeLabel.textAlignment = .right
        for child in [colorLabel,codeLabel,spectrum,intensityLabel,intensity,switches] { child.translatesAutoresizingMaskIntoConstraints = true; panel.addSubview(child) }
        for (caption,control) in [("change_system_color",categoryColors),("change_game_color",gameColors)] {
            let label=UILabel();label.text=ResultText.text(caption);label.numberOfLines=0;label.textColor = .white;label.font=ResultUI.font(16,settings:AppSettings())
            let row=ResultUI.stack(.horizontal,spacing:8);row.alignment = .center
            row.isLayoutMarginsRelativeArrangement=true;row.directionalLayoutMargins=NSDirectionalEdgeInsets(top:0,leading:8,bottom:0,trailing:8)
            row.addArrangedSubview(label);row.addArrangedSubview(control)
            row.heightAnchor.constraint(greaterThanOrEqualToConstant:56).isActive=true
            control.setContentCompressionResistancePriority(.required,for:.horizontal);control.accessibilityLabel=label.text
            switches.addArrangedSubview(row)
        }
        toggle.setImage(UIImage(systemName:"chevron.down"),for:.normal);toggle.tintColor = .white
        toggle.backgroundColor=UIColor.black.withAlphaComponent(85/255);toggle.layer.cornerRadius=8
        toggle.addAction(UIAction { [weak self] _ in
            guard let self else { return };expanded.toggle();UserDefaults.standard.set(expanded,forKey:"themeSettingsExpanded");geometry = .zero;view.setNeedsLayout()
        },for:.touchUpInside)
        cycle.setImage(UIImage(named:"ic_theme_preview_cycle")?.withRenderingMode(.alwaysTemplate),for:.normal);cycle.tintColor = .white
        cycle.backgroundColor=UIColor.black.withAlphaComponent(85/255);cycle.layer.cornerRadius=16;cycle.layer.borderWidth=1;cycle.layer.borderColor=UIColor.white.withAlphaComponent(85/255).cgColor
        cycle.accessibilityLabel=ResultText.text("theme_preview_cycle")
        cycle.addAction(UIAction { [weak self] _ in
            guard let self else { return };previewFrame=(previewFrame+1)%4;queuePreviewUpdates()
        },for:.touchUpInside)
        fontLabel.numberOfLines=0
        fontControls.addSubview(fontLabel);fontControls.addSubview(fontSlider);fontControls.addSubview(systemMarker)
        for (value,tag) in [("80%",80),("200%",200)] { let label=UILabel();label.text=value;label.tag=tag;label.font=ResultUI.font(14,settings:AppSettings());fontControls.addSubview(label) }
        fontSlider.minimumValue=80;fontSlider.maximumValue=200;fontSlider.accessibilityLabel=ResultText.text("option_font_size")
        fontSlider.addAction(UIAction { [weak self] _ in
            guard let self else { return };fontSlider.value=fontSlider.value.rounded();draft.fontSizePercent=Int(fontSlider.value);draft.useSystemFontSize=false;fontChanged=true
            fontLabel.text=ResultText.format("theme_font_size_current",Int64(draft.fontSizePercent))
            scheduleRefresh()
        },for:.valueChanged)
        fontSlider.addAction(UIAction { [weak self] _ in self?.refresh() },for:[.touchUpInside,.touchUpOutside,.touchCancel])
        systemMarker.isUserInteractionEnabled=false
        spectrum.accessibilityLabel=ResultText.text("theme_picker_color");intensity.accessibilityLabel=ResultText.text("theme_picker_intensity")
        spectrum.addAction(UIAction { [weak self] _ in guard let self else { return };baseColor=spectrum.color;scheduleRefresh() },for:.valueChanged)
        intensity.addAction(UIAction { [weak self] _ in guard let self else { return };intensities[String(selectedTheme.rawValue)]=Int((intensity.position*100).rounded());scheduleRefresh() },for:.valueChanged)
        for control in [spectrum, intensity] {
            control.addAction(UIAction { [weak self] _ in self?.refresh() },for:.editingDidEnd)
        }
        observation=data.$snapshot.sink { [weak self] progress in
            guard let self,let settings=progress?.settings else { return }
            if !loaded {
                loaded=true;draft=settings;selectedTheme=settings.theme ?? .light
                categoryColors.isOn=settings.tricksCategoryColors ?? true;gameColors.isOn=settings.gameCategoryColors ?? false
                baseColor=ThemeColor.hex(settings.themeBaseColorHex ?? settings.accentColorHex ?? "0D47A1")
                intensities=settings.themeIntensities;if let theme=settings.theme { intensities[String(theme.rawValue)]=settings.themeIntensity }
                if settings.useSystemFontSize {draft.fontSizePercent=Int((ResultUI.font(16,settings:settings).pointSize/16*100).rounded())}
                fontSlider.value=Float(min(200,max(80,draft.fontSizePercent)));spectrum.setColor(baseColor)
            }
            refresh();geometry = .zero;view.setNeedsLayout()
        }
    }
    private func previewSettings(_ theme: AppTheme) -> AppSettings {
        var settings=draft
        settings.useSystemFontSize=false
        let value=intensities[String(theme.rawValue)] ?? theme.defaultIntensity
        settings.theme=theme;settings.themeIntensity=value;settings.themeBaseColorHex=ThemeColor.hexString(baseColor)
        settings.accentColorHex=ThemeColor.hexString(ThemeColor.intensity(baseColor,theme.mappedIntensity(value)))
        return settings
    }
    /// Coalesce touch events; ending a gesture still applies its final value immediately.
    private func scheduleRefresh() {
        guard pendingRefresh == nil else { return }
        let work = DispatchWorkItem { [weak self] in self?.refresh() }
        pendingRefresh = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 30, execute: work)
    }
    private func refresh() {
        pendingRefresh?.cancel(); pendingRefresh = nil
        guard isViewLoaded else { return }
        let settings=previewSettings(selectedTheme),value=settings.themeIntensity
        let applied=data.snapshot?.settings ?? AppSettings()
        background.apply(settings:applied);ThemeColorTransition.apply(header,color:ThemePalette(settings:applied).header)
        let palette=ThemePalette(settings:applied),color: UIColor=palette.theme == .light ? .white : palette.text
        nameLabel.textColor=color;nameLabel.font=ResultUI.font(16,settings:applied);nameLabel.lineBreakMode = .byTruncatingTail
        backButton.apply(settings:applied,tint:color);applyButton.apply(settings:applied);applyButton.label.font=ResultUI.font(13,settings:applied)
        for child in fontControls.subviews.compactMap({ $0 as? UILabel }) { child.textColor=palette.text }
        systemMarker.backgroundColor=palette.text;fontSlider.tintColor=palette.accent
        overrideUserInterfaceStyle=palette.theme.isDark ? .dark : .light
        setNeedsStatusBarAppearanceUpdate()
        let accent = palette.switchOnTint
        categoryColors.onTintColor = accent; gameColors.onTintColor = accent
        for (index,theme) in AppTheme.pickerOrder.enumerated() {
            cards[index].prepareBackground(settings:previewSettings(theme))
            cards[index].decorate(selected:index==currentIndex,color:baseColor,title:theme.name)
        }
        intensity.setIntensity(base:baseColor,theme:selectedTheme,percent:value)
        codeLabel.text="#"+(settings.accentColorHex ?? "0D47A1")
        intensityLabel.text=ResultText.text("theme_picker_intensity")+" \(value)%"
        fontLabel.text=ResultText.format("theme_font_size_current",Int64(draft.fontSizePercent));fontLabel.font=ResultUI.font(16,settings:AppSettings())
        nameLabel.text=selectedTheme.name
        applyButton.isEnabled=loaded && !saving
        queuePreviewUpdates(); updateMotion()
    }
    private func queuePreviewUpdates() {
        previewTask?.cancel(); previewTask = nil; previewGeneration += 1
        guard visible, !carouselMoving else { return }
        let center = activeCardIndex
        let indices = (spectrum.isAdjusting || intensity.isAdjusting || fontSlider.isTracking) ? [center] : [center, center-1, center+1].filter { cards.indices.contains($0) }
        let generation = previewGeneration
        previewTask = Task { [weak self] in
            await Task.yield()
            for (offset, index) in indices.enumerated() {
                if offset > 0 {
                    do { try await Task.sleep(nanoseconds:32_000_000) } catch { return }
                }
                guard !Task.isCancelled, let self, visible, !carouselMoving, generation == previewGeneration else { return }
                cards[index].apply(settings:previewSettings(AppTheme.pickerOrder[index]))
                cards[index].showFrame(previewFrame)
                updateMotion()
            }
            if let self, generation == previewGeneration { previewTask = nil }
        }
    }
    private func select(index: Int,scroll: Bool) {
        guard cards.indices.contains(index),!saving else { return }
        selectedTheme=AppTheme.pickerOrder[index]
        if scroll,cardWidth>0 {
            pages.setContentOffset(CGPoint(x:CGFloat(index)*(cardWidth+16)-pages.contentInset.left,y:0),animated:false)
        }
        refresh()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background.frame=view.bounds
        let safe=view.appContentLayoutGuide.layoutFrame
        header.frame=CGRect(x:safe.minX,y:safe.minY,width:safe.width,height:AppDuoLayout.headerHeight(in:view))
        let headerContent=AppDuoLayout.roundedCornerSafeFrame(in:header,
            within:AppDuoLayout.unobscuredFrame(in:header,within:header.bounds))
        let headerRTL = header.effectiveUserInterfaceLayoutDirection == .rightToLeft
        backButton.frame=CGRect(x:headerRTL ? headerContent.maxX-AppMetrics.headerBackWidth : headerContent.minX,y:headerContent.minY,width:AppMetrics.headerBackWidth,height:AppMetrics.headerHeight)
        // AppLabel refreshes its role font on rotation; restore the compact header font before measuring.
        applyButton.label.font=ResultUI.font(13,settings:data.snapshot?.settings ?? AppSettings())
        let applyWidth=min(160,max(100,((applyButton.label.text ?? "") as NSString).size(withAttributes:[.font:applyButton.label.font!]).width+32))
        applyButton.frame=CGRect(x:headerRTL ? headerContent.minX+8 : headerContent.maxX-applyWidth-8,y:headerContent.minY+(AppMetrics.headerHeight-48)/2,width:applyWidth,height:48)
        nameLabel.frame=CGRect(x:headerContent.minX+(headerRTL ? applyWidth+20 : AppMetrics.headerBackWidth+4),y:headerContent.minY,width:max(1,headerContent.width-applyWidth-AppMetrics.headerBackWidth-24),height:AppMetrics.headerHeight)
        stage.frame=CGRect(x:safe.minX,y:header.frame.maxY,width:safe.width,height:max(1,safe.maxY-header.frame.maxY))
        stage.layoutIfNeeded()
        synchronizeDuoPanes()
        let size=stage.bounds.size,landscape=view.bounds.width>view.bounds.height
        let sideControls = usesDuoPanes || landscape
        let carouselSize = usesDuoPanes ? carouselPane.bounds.size : CGSize(width:landscape ? size.width*0.5 : size.width,height:size.height)
        let nominalPanelWidth=usesDuoPanes ? controlsPane.bounds.width : (landscape ? size.width*0.5 : size.width)
        let showSwitches=sideControls || expanded
        let toggleHeight: CGFloat=sideControls ? 0 : 104
        let portraitPanelHeight: CGFloat=20+168+(showSwitches ? 112 : 0)+8
        let nominalDockHeight=usesDuoPanes ? controlsPane.bounds.height : (landscape ? size.height : min(size.height,max(1,portraitPanelHeight+toggleHeight)))
        let dockFrame=usesDuoPanes ? controlsPane.bounds : AppDuoLayout.unobscuredFrame(in:stage,within: CGRect(x:landscape ? size.width-nominalPanelWidth : 0,y:landscape ? 0 : size.height-nominalDockHeight,width:nominalPanelWidth,height:nominalDockHeight))
        let panelWidth=dockFrame.width,dockHeight=dockFrame.height
        dock.frame=dockFrame
        let aspect=max(0.1,view.bounds.height/max(1,view.bounds.width)),carouselWidth=usesDuoPanes ? carouselSize.width : (landscape ? size.width-nominalPanelWidth : size.width)
        let nextWidth=sideControls ? max(1,min(carouselWidth*0.82,(carouselSize.height-14)/aspect)) : min(282,carouselWidth*0.76)
        let cardHeight=(nextWidth-6)*aspect+6,carouselHeight=cardHeight+8
        if sideControls { if fontControls.superview !== panel { fontControls.removeFromSuperview();panel.addSubview(fontControls) } }
        else if fontControls.superview !== stage { fontControls.removeFromSuperview();stage.addSubview(fontControls) }
        let nominalFontFrame=CGRect(x:sideControls ? 8 : 0,y:sideControls ? 8 : 0,width:sideControls ? panelWidth-16 : size.width,height:100)
        let fontFrame=sideControls ? nominalFontFrame : AppDuoLayout.unobscuredFrame(in:stage,within:nominalFontFrame)
        let fontWidth=fontFrame.width
        let labelHeight=max(23,ceil(fontLabel.sizeThatFits(CGSize(width:max(1,fontWidth-20),height:.greatestFiniteMagnitude)).height))
        let fontHeight=labelHeight+64,sliderTop=labelHeight+8
        fontControls.frame=CGRect(x:fontFrame.minX,y:fontFrame.minY,width:fontWidth,height:fontHeight)
        fontLabel.frame=CGRect(x:4,y:8,width:max(1,fontWidth-20),height:labelHeight)
        let trackWidth=max(1,fontWidth-116)
        fontSlider.frame=CGRect(x:50,y:sliderTop,width:trackWidth,height:48)
        fontControls.viewWithTag(80)?.frame=CGRect(x:4,y:sliderTop,width:44,height:48)
        fontControls.viewWithTag(200)?.frame=CGRect(x:fontWidth-62,y:sliderTop,width:58,height:48)
        let systemPercent=min(200,max(80,UIFontMetrics(forTextStyle:.body).scaledValue(for:100,compatibleWith:traitCollection)))
        let fraction=(systemPercent-80)/120,rtl=view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        systemMarker.frame=CGRect(x:fontSlider.frame.minX+2+(trackWidth-4)*(rtl ? 1-fraction : fraction)-1,y:sliderTop+18,width:2,height:12)
        systemMarker.accessibilityLabel=ResultText.format("font_size_system",Int64(systemPercent.rounded()))
        pages.frame=CGRect(x:0,y:sideControls ? max(0,(carouselSize.height-carouselHeight)/2) : fontHeight,width:carouselWidth,height:carouselHeight)
        let layoutChanged=geometry != size || abs(cardWidth-nextWidth)>0.5
        if layoutChanged {
            geometry=size;cardWidth=nextWidth
            let inset=max(0,(carouselWidth-cardWidth-16)/2)+8
            pages.contentInset=UIEdgeInsets(top:0,left:inset,bottom:0,right:inset)
            pages.contentSize=CGSize(width:CGFloat(cards.count)*(cardWidth+16)-16,height:carouselHeight)
            for (index,card) in cards.enumerated() { card.setReferenceSize(view.bounds.size);card.frame=CGRect(x:CGFloat(index)*(cardWidth+16),y:4,width:cardWidth,height:cardHeight) }
            pages.setContentOffset(CGPoint(x:CGFloat(currentIndex)*(cardWidth+16)-inset,y:0),animated:false)
        }
        switches.isHidden = !showSwitches;toggle.isHidden=sideControls
        toggle.setImage(UIImage(systemName:expanded ? "chevron.up":"chevron.down"),for:.normal)
        toggle.accessibilityLabel=ResultText.text(expanded ? "theme_settings_collapse":"theme_settings_expand")
        let start: CGFloat=sideControls ? fontHeight+16 : 20
        colorLabel.frame=CGRect(x:28,y:start,width:max(1,panelWidth-150),height:20)
        codeLabel.frame=CGRect(x:panelWidth-112,y:start,width:84,height:20)
        spectrum.frame=CGRect(x:16,y:start+20,width:panelWidth-32,height:64)
        intensityLabel.frame=CGRect(x:28,y:start+84,width:panelWidth-56,height:20)
        intensity.frame=CGRect(x:16,y:start+104,width:panelWidth-32,height:64)
        switches.frame=CGRect(x:8,y:start+168,width:panelWidth-16,height:showSwitches ? 112 : 0)
        let panelHeight=start+168+(showSwitches ? 112 : 0)+8
        toggle.frame=CGRect(x:panelWidth-48,y:72,width:40,height:32)
        settingsScroll.frame=CGRect(x:0,y:toggleHeight,width:panelWidth,height:max(1,dockHeight-toggleHeight))
        panel.frame=CGRect(x:0,y:0,width:panelWidth,height:max(panelHeight,sideControls ? settingsScroll.bounds.height : 0))
        settingsScroll.contentSize=panel.bounds.size
        cycle.frame=CGRect(x:(carouselWidth-72)/2,y:sideControls ? pages.frame.maxY-72 : dock.frame.minY+4,width:72,height:64)
        cycle.imageView?.contentMode = .scaleAspectFit
        if cycle.configuration == nil {var config=UIButton.Configuration.plain();config.image=UIImage(named:"ic_theme_preview_cycle")?.withRenderingMode(.alwaysTemplate);config.baseForegroundColor = .white;config.contentInsets=NSDirectionalEdgeInsets(top:16,leading:16,bottom:16,trailing:16);cycle.configuration=config}
        if usesDuoPanes {
            controlsPane.bringSubviewToFront(dock);carouselPane.bringSubviewToFront(cycle)
        } else {
            stage.bringSubviewToFront(dock);stage.bringSubviewToFront(cycle)
        }
        if layoutChanged { queuePreviewUpdates() }
        updateMotion()
    }
    private func synchronizeDuoPanes() {
        let shouldUse = AppDuoGameArrangement.canUse(in: stage)
        if usesDuoPanes != shouldUse {
            usesDuoPanes = shouldUse
            geometry = .zero
            if shouldUse {
                carouselPane.addSubview(pages);carouselPane.addSubview(cycle);controlsPane.addSubview(dock)
            } else {
                stage.addSubview(pages);stage.addSubview(dock);stage.addSubview(cycle)
            }
            duoLayout.isHidden = !shouldUse
        }
        if shouldUse { duoLayout.synchronizeArrangement();duoLayout.layoutIfNeeded() }
    }

    private func updateMotion() {
        background.setHostVisible(visible && !carouselMoving)
    }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated);visible=true;queuePreviewUpdates();updateMotion() }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated);visible=false;pendingRefresh?.cancel();pendingRefresh=nil;previewTask?.cancel();previewTask=nil;updateMotion() }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === pages else { return }
        previewTask?.cancel(); previewTask=nil
         updateMotion()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === pages else { return }
        selectCenteredPage(); updateMotion()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,withVelocity velocity: CGPoint,targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === pages, cardWidth>0 else { return }
        let index=min(cards.count-1,max(0,Int(((targetContentOffset.pointee.x+pages.contentInset.left)/(cardWidth+16)).rounded())))
        targetContentOffset.pointee.x=CGFloat(index)*(cardWidth+16)-pages.contentInset.left
        select(index:index,scroll:false)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { if scrollView === pages { selectCenteredPage();updateMotion() } }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,willDecelerate decelerate: Bool) { if scrollView === pages && !decelerate { selectCenteredPage();updateMotion() } }
    private func selectCenteredPage() {
        guard cardWidth>0 else { return }
        select(index:min(cards.count-1,max(0,Int(((pages.contentOffset.x+pages.contentInset.left)/(cardWidth+16)).rounded()))),scroll:false)
    }
    private func save() {
        guard loaded,!saving else { return };selectCenteredPage();saving=true
        let selected=previewSettings(selectedTheme)
        intensities[String(selectedTheme.rawValue)]=selected.themeIntensity
        view.isUserInteractionEnabled=false
        Task { [weak self] in
            guard let self else { return }
            do {
                try await data.updateSettings(.appearance(theme:selectedTheme,colorHex:selected.accentColorHex,intensity:selected.themeIntensity,baseColorHex:selected.themeBaseColorHex,intensities:intensities,categoryColors:categoryColors.isOn,gameCategoryColors:gameColors.isOn,fontPercent:fontChanged ? draft.fontSizePercent : nil,systemFont:fontChanged ? draft.useSystemFontSize : nil))
                router?.show(.main)
            } catch {
                let dialog=AppDialogViewController(title:CatalogText.ui("theme_title"),message:CatalogText.ui("save_error"),actions:[.init(title:"OK",handler:{})],data:data)
                present(dialog,animated:false)
            }
            saving=false;view.isUserInteractionEnabled=true;refresh()
        }
    }
}
