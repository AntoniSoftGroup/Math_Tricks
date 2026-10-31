import UIKit

final class TextAndKeypadViewController:ThemedViewController {
    private let fontMode:Bool
    private let slider=UISlider()
    private var value:AppLabel!
    private var systemValue:AppLabel!
    private var reset:AppButton!
    private var apply:AppButton!
    private var draft=AppSettings()
    private var loadedDraft=false
    private var saving=false
    private let previews=UIStackView()
    private var fontPreviews:[FontSamplePreview]=[]
    private var fontPreviewTask: Task<Void, Never>?
    private var pendingFontPreviews = Set<Int>()
    private var nextFontPreview = 0
    private var fontVisible = false
    private var keypadCards:[AppCardView]=[]
    private var keypadKeys: [(AppButton, Int)] = []
    private var keypadSelections: [AppButton] = []
    private let systemMarker = FontScaleMarker()
    private var previewAspects: [NSLayoutConstraint] = []
    private var previewRatio: CGFloat = 0
    private let fontLayout=UIStackView(),fontSidebar=UIStackView()
    private let fontControlsScroll=AppScrollView(),fontPreviewHost=UIView()
    private var fontLandscape: Bool?
    private let duoFontLayout = AppDuoSplitView(), duoKeypads = AppDuoSplitView()
    private let keypadScroll = AppScrollView()
    private var keypadWidthLimits: [NSLayoutConstraint] = []
    private var duoKeypadConstraints: [NSLayoutConstraint] = []
    private var usesDuoPanes = false
    init(fontMode:Bool,router:AppRouter,data:AppDataStore){self.fontMode=fontMode;super.init(title:CatalogText.ui(fontMode ? "font_size":"numpad"),router:router,data:data)}
    isolated deinit { fontPreviewTask?.cancel() }
    required init?(coder:NSCoder){fatalError("init(coder:) has not been implemented")}
    override func buildContent(){
        if fontMode {buildFont()} else {buildKeypads()}
        let pair = fontMode ? duoFontLayout : duoKeypads
        pair.translatesAutoresizingMaskIntoConstraints = false;pair.isHidden = true;body.addSubview(pair)
        pair.onArrangementChange = { [weak self] in self?.view.setNeedsLayout() }
        NSLayoutConstraint.activate([
            pair.topAnchor.constraint(equalTo:body.topAnchor,constant:8),pair.bottomAnchor.constraint(equalTo:body.bottomAnchor,constant:-8),
            pair.leadingAnchor.constraint(equalTo:body.leadingAnchor,constant:fontMode ? 16 : 0),pair.trailingAnchor.constraint(equalTo:body.trailingAnchor,constant:fontMode ? -16 : 0)
        ])
    }
    private func buildFont(){
        reset=button(MainText.text("font_size_reset"),kind:.compact){[weak self] in self?.resetFont()}
        reset.label.numberOfLines = 2
        reset.widthAnchor.constraint(equalToConstant:128).isActive=true;header.setAccessoryView(reset)
        let heading = label(CatalogText.ui("font_size"), role: .body)
        heading.numberOfLines = 2; header.replaceTitle(with: heading)
        let column=fontLayout;column.axis = .vertical;column.spacing=8;column.translatesAutoresizingMaskIntoConstraints=false;body.addSubview(column)
        let controls=UIStackView();controls.axis = .vertical;controls.spacing=4
        value=label("",role:.detail);value.textAlignment = .right
        systemValue=label("",role:.detail)
        slider.minimumValue=80;slider.maximumValue=200;slider.accessibilityLabel=CatalogText.ui("font_size")
        slider.addTarget(self,action:#selector(sliderMoved),for:.valueChanged)
        slider.addTarget(self,action:#selector(sliderReleased),for:[.touchUpInside,.touchUpOutside,.touchCancel])
        let markerTrack = UIStackView(arrangedSubviews: [slider, systemMarker]); markerTrack.axis = .vertical
        slider.heightAnchor.constraint(equalToConstant: 48).isActive = true
        systemMarker.heightAnchor.constraint(equalToConstant: 12).isActive = true
        let track=UIStackView(arrangedSubviews:[label("80%",role:.detail),markerTrack,label("200%",role:.detail)]);track.alignment = .center;track.spacing=12
        controls.addArrangedSubview(track)
        let percentages=UIStackView(arrangedSubviews:[systemValue,value]);percentages.distribution = .fillEqually;controls.addArrangedSubview(percentages)
        controls.translatesAutoresizingMaskIntoConstraints=false;fontControlsScroll.addSubview(controls)
        NSLayoutConstraint.activate([
            controls.topAnchor.constraint(equalTo:fontControlsScroll.contentLayoutGuide.topAnchor),controls.bottomAnchor.constraint(equalTo:fontControlsScroll.contentLayoutGuide.bottomAnchor),
            controls.leadingAnchor.constraint(equalTo:fontControlsScroll.contentLayoutGuide.leadingAnchor),controls.trailingAnchor.constraint(equalTo:fontControlsScroll.contentLayoutGuide.trailingAnchor),
            controls.widthAnchor.constraint(equalTo:fontControlsScroll.frameLayoutGuide.widthAnchor)
        ])
        let controlsHeight=fontControlsScroll.heightAnchor.constraint(equalTo:controls.heightAnchor);controlsHeight.priority = .defaultHigh;controlsHeight.isActive=true
        column.addArrangedSubview(fontControlsScroll)
        let host=fontPreviewHost;column.addArrangedSubview(host)
        let cards=scrollStack(in:host,padding:0)
        for pair in [[0,1],[2,3]] {
            let row=UIStackView();row.axis = .horizontal;row.distribution = .fillEqually;row.spacing=8
            for kind in pair {
                let title=label(MainText.text(["font_size_preview","font_size_menu_preview","font_size_solution_preview","font_size_tricks_preview"][kind]),role:.detail);title.textAlignment = .center
                let preview=FontSamplePreview(kind:kind);preview.prepareBackground(settings:settings);fontPreviews.append(preview)
                let group=UIStackView(arrangedSubviews:[title,preview]);group.axis = .vertical;group.spacing=4
                row.addArrangedSubview(group)
                let aspect = preview.heightAnchor.constraint(equalTo:preview.widthAnchor,multiplier:1.8)
                aspect.isActive = true; previewAspects.append(aspect)
            }
            cards.addArrangedSubview(row)
        }
        apply=button(MainText.text("font_size_apply")){[weak self] in self?.saveFont()};column.addArrangedSubview(apply)
        NSLayoutConstraint.activate([column.topAnchor.constraint(equalTo:body.topAnchor,constant:8),column.bottomAnchor.constraint(equalTo:body.bottomAnchor,constant:-8),column.leadingAnchor.constraint(equalTo:body.leadingAnchor,constant:16),column.trailingAnchor.constraint(equalTo:body.trailingAnchor,constant:-16)])
    }
    private func buildKeypads(){
        let scroll = keypadScroll; scroll.translatesAutoresizingMaskIntoConstraints = false; body.addSubview(scroll)
        let host = UIView(); host.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(host)
        previews.axis = .vertical;previews.alignment = .center;previews.spacing=12
        previews.translatesAutoresizingMaskIntoConstraints = false; host.addSubview(previews)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: body.topAnchor), scroll.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: body.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            host.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), host.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            host.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), host.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            host.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor), host.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor),
            previews.centerXAnchor.constraint(equalTo: host.centerXAnchor), previews.centerYAnchor.constraint(equalTo: host.centerYAnchor),
            previews.leadingAnchor.constraint(greaterThanOrEqualTo: host.leadingAnchor, constant: 8), previews.trailingAnchor.constraint(lessThanOrEqualTo: host.trailingAnchor, constant: -8),
            previews.topAnchor.constraint(greaterThanOrEqualTo: host.topAnchor, constant: 8), previews.bottomAnchor.constraint(lessThanOrEqualTo: host.bottomAnchor, constant: -8)
        ])
        for ascending in [true,false] {
            let card=AppCardView(padding:4);card.content.spacing=0;keypadCards.append(card)
            let keyboard=UIStackView();keyboard.axis = .vertical;keyboard.spacing=0
            for numbers in (ascending ? [[1,2,3],[4,5,6],[7,8,9]]:[[7,8,9],[4,5,6],[1,2,3]])+[[0,-1]] {
                let row=UIStackView();row.axis = .horizontal;row.distribution = .fillEqually
                for number in numbers {
                    let key=button(number>=0 ? String(number):MainText.text("backspace"),icon:number>=0 ? nil:.backspace,kind:number>=0 ? .keypad:.keypadIcon){}
                    key.isUserInteractionEnabled = false; keypadKeys.append((key, number))
                    key.setContentInsets(UIEdgeInsets(top:4,left:2,bottom:4,right:2),minimumHeight:44)
                    row.addArrangedSubview(key)
                }
                keyboard.addArrangedSubview(row)
            }
            let select=button(CatalogText.ui("numpad")+" "+(ascending ? "123":"789"),icon:.next,kind:.icon){[weak self] in self?.saveKeypad(ascending)}
            select.widthAnchor.constraint(equalToConstant:60).isActive=true
            keypadSelections.append(select)
            let row=UIStackView(arrangedSubviews:[keyboard,select]);row.axis = .horizontal;row.alignment = .center
            card.content.addArrangedSubview(row);previews.addArrangedSubview(card)
            let widthLimit = card.widthAnchor.constraint(lessThanOrEqualTo:previews.widthAnchor)
            widthLimit.isActive=true;keypadWidthLimits.append(widthLimit)
            let preferred=card.widthAnchor.constraint(equalToConstant:250);preferred.priority = .defaultHigh;preferred.isActive=true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);fontVisible=true
        if fontMode { queueFontPreviews() }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);fontVisible=false
        fontPreviewTask?.cancel();fontPreviewTask=nil;pendingFontPreviews.removeAll()
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        synchronizeDuoPanes()
        if !fontMode {previews.axis=view.bounds.width>view.bounds.height ? .horizontal:.vertical;previews.distribution=previews.axis == .horizontal ? .fillEqually:.fill}
        else if view.bounds.width > 0 {
            let landscape=view.bounds.width>view.bounds.height
            if !usesDuoPanes, fontLandscape != landscape {
                fontLandscape=landscape
                for stack in [fontLayout,fontSidebar] {for child in stack.arrangedSubviews {stack.removeArrangedSubview(child);child.removeFromSuperview()}}
                fontLayout.axis=landscape ? .horizontal : .vertical;fontLayout.distribution=landscape ? .fillEqually : .fill
                if landscape {
                    fontSidebar.axis = .vertical;fontSidebar.spacing=8
                    fontSidebar.addArrangedSubview(fontControlsScroll);fontSidebar.addArrangedSubview(UIView());fontSidebar.addArrangedSubview(apply)
                    fontLayout.addArrangedSubview(fontPreviewHost);fontLayout.addArrangedSubview(fontSidebar)
                } else {
                    fontLayout.addArrangedSubview(fontControlsScroll);fontLayout.addArrangedSubview(fontPreviewHost);fontLayout.addArrangedSubview(apply)
                }
            }
            for preview in fontPreviews {preview.referenceSize=view.bounds.size}
            systemMarker.markerX = slider.thumbRect(forBounds: slider.bounds, trackRect: slider.trackRect(forBounds: slider.bounds), value: Float(min(200, max(80, systemPercent)))).midX
            let ratio = view.bounds.height / view.bounds.width
            if abs(ratio - previewRatio) > 0.01 {
                previewRatio = ratio; NSLayoutConstraint.deactivate(previewAspects)
                previewAspects = fontPreviews.map { $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: ratio) }
                NSLayoutConstraint.activate(previewAspects)
            }
        }
    }
    private func synchronizeDuoPanes() {
        let shouldUse = AppDuoGameArrangement.canUse(in: body)
        if usesDuoPanes != shouldUse {
            usesDuoPanes = shouldUse
            if fontMode {
                fontLandscape = nil
                for stack in [fontLayout,fontSidebar] {
                    for child in stack.arrangedSubviews { stack.removeArrangedSubview(child);child.removeFromSuperview() }
                }
                if shouldUse {
                    fontSidebar.axis = .vertical;fontSidebar.spacing = 8
                    fontSidebar.addArrangedSubview(fontControlsScroll)
                    fontSidebar.addArrangedSubview(UIView());fontSidebar.addArrangedSubview(apply)
                    duoFontLayout.addArrangedSubview(fontPreviewHost);duoFontLayout.addArrangedSubview(fontSidebar)
                } else {
                    duoFontLayout.removeAllArrangedSubviews()
                }
                fontLayout.isHidden = shouldUse;duoFontLayout.isHidden = !shouldUse
            } else {
                if shouldUse {
                    NSLayoutConstraint.deactivate(keypadWidthLimits)
                    for card in keypadCards {
                        previews.removeArrangedSubview(card);card.removeFromSuperview()
                        let scroll = AppScrollView(), content = UIView()
                        content.translatesAutoresizingMaskIntoConstraints = false;scroll.addSubview(content);content.addSubview(card)
                        duoKeypadConstraints += [
                            content.topAnchor.constraint(equalTo:scroll.contentLayoutGuide.topAnchor),content.bottomAnchor.constraint(equalTo:scroll.contentLayoutGuide.bottomAnchor),
                            content.leadingAnchor.constraint(equalTo:scroll.contentLayoutGuide.leadingAnchor),content.trailingAnchor.constraint(equalTo:scroll.contentLayoutGuide.trailingAnchor),
                            content.widthAnchor.constraint(equalTo:scroll.frameLayoutGuide.widthAnchor),content.heightAnchor.constraint(greaterThanOrEqualTo:scroll.frameLayoutGuide.heightAnchor),
                            card.centerXAnchor.constraint(equalTo:content.centerXAnchor),card.centerYAnchor.constraint(equalTo:content.centerYAnchor),
                            card.leadingAnchor.constraint(greaterThanOrEqualTo:content.leadingAnchor,constant:8),card.trailingAnchor.constraint(lessThanOrEqualTo:content.trailingAnchor,constant:-8),
                            card.topAnchor.constraint(greaterThanOrEqualTo:content.topAnchor,constant:8),card.bottomAnchor.constraint(lessThanOrEqualTo:content.bottomAnchor,constant:-8)
                        ]
                        duoKeypads.addArrangedSubview(scroll)
                    }
                    NSLayoutConstraint.activate(duoKeypadConstraints)
                } else {
                    NSLayoutConstraint.deactivate(duoKeypadConstraints);duoKeypadConstraints = []
                    duoKeypads.removeAllArrangedSubviews()
                    keypadCards.forEach { $0.removeFromSuperview();previews.addArrangedSubview($0) }
                    NSLayoutConstraint.activate(keypadWidthLimits)
                }
                keypadScroll.isHidden = shouldUse;duoKeypads.isHidden = !shouldUse
            }
        }
        if usesDuoPanes { (fontMode ? duoFontLayout : duoKeypads).synchronizeArrangement() }
    }

    override func update(_ progress:ProgressState?){
        if !loadedDraft,progress != nil {draft=settings;loadedDraft=true}
        if fontMode {
            slider.isEnabled=progress != nil && !saving;slider.tintColor=palette.accent;renderFont()
            apply.isEnabled=progress != nil && !saving
        } else {
            keypadCards.forEach{$0.apply(settings:settings)}
            themedButtons.forEach{$0.isEnabled=progress != nil && !saving}
            for (key, number) in keypadKeys {
                let tint = (1...3).contains(number) ? ThemeColor.rgb(0x992424) : (7...9).contains(number) ? ThemeColor.rgb(0x2E7D32) : palette.text
                key.apply(settings: settings, textTint: tint)
            }
            keypadSelections.forEach { $0.apply(settings: settings, tint: .gray) }
        }
    }
    private var systemPercent:Int {Int(UIFontMetrics(forTextStyle:.body).scaledValue(for:100,compatibleWith:traitCollection).rounded())}
    @objc private func sliderMoved(){draft.fontSizePercent=Int(slider.value.rounded());draft.useSystemFontSize=false;renderFont()}
    @objc private func sliderReleased(){renderFont()}
    private func resetFont(){draft.useSystemFontSize=true;renderFont()}
    private func renderFont(){
        let percent=draft.useSystemFontSize ? min(130,systemPercent):draft.fontSizePercent
        value.text=MainText.count("font_size_current",Int64(percent));systemValue.text=MainText.count("font_size_system",Int64(systemPercent));slider.value=Float(min(200,max(80,percent)))
        reset.isEnabled = !draft.useSystemFontSize && !saving
        systemMarker.percent = systemPercent; systemMarker.tintColor = palette.text
        fontPreviews.forEach { $0.prepareBackground(settings:draft) }
        queueFontPreviews()
    }
    private func queueFontPreviews() {
        pendingFontPreviews.formUnion(fontPreviews.indices)
        guard fontVisible, loadedDraft, !fontPreviews.isEmpty, fontPreviewTask == nil else { return }
        fontPreviewTask = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(nanoseconds:32_000_000) } catch { return }
                guard let self, fontVisible else { return }
                let count=fontPreviews.count
                guard let index=(0..<count).map({(nextFontPreview+$0)%count}).first(where:{pendingFontPreviews.contains($0)}) else {
                    fontPreviewTask=nil;return
                }
                pendingFontPreviews.remove(index);nextFontPreview=(index+1)%count
                fontPreviews[index].apply(settings:draft);fontPreviews[index].layoutIfNeeded()
                if pendingFontPreviews.isEmpty { fontPreviewTask=nil;return }
            }
        }
    }
    private func saveFont(){
        guard !saving,loadedDraft else{return};saving=true;update(data.snapshot)
        let selected=draft
        Task{[weak self] in guard let self else{return};do{try await data.updateSettings(.fontSize(useSystem:selected.useSystemFontSize,percent:selected.fontSizePercent));router?.goBack()}catch{showError(error)};saving=false;update(data.snapshot)}
    }
    private func saveKeypad(_ ascending:Bool){
        guard !saving else{return};saving=true;update(data.snapshot)
        Task{[weak self] in guard let self else{return};do{try await data.updateSettings(.numpad123(ascending));router?.goBack()}catch{showError(error)};saving=false;update(data.snapshot)}
    }
}
