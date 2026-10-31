import UIKit

final class GameModesViewController:ThemedViewController,UITextFieldDelegate {
    private let selected:Bool
    private let levelField=UITextField()
    private let selector=UIView()
    private let modesScroll=AppScrollView()
    private let layout=AppDuoSplitView()
    private let modesStack=UIStackView()
    private let fieldSurface=ThemeSurfaceView(.button)
    private var recordLabels:[GameMode:AppLabel]=[:]
    private var playButtons:[AppButton]=[]
    private var resetButtons:[AppButton]=[]
    private var playWidths:[NSLayoutConstraint]=[]
    private var selectorWidth:NSLayoutConstraint?
    private var selectorHeight:NSLayoutConstraint!
    private var numberHeight:NSLayoutConstraint?
    private var wide:Bool?
    private var launching=false
    init(selected:Bool,router:AppRouter,data:AppDataStore) {
        self.selected=selected
        super.init(title:CatalogText.ui("level"),router:router,data:data)
    }
    required init?(coder:NSCoder){fatalError("init(coder:) has not been implemented")}
    override func buildContent() {
        layout.onArrangementChange = { [weak self] in
            self?.wide = nil
            self?.selectorWidth?.isActive = false
            self?.selectorHeight?.isActive = false
            self?.view.setNeedsLayout()
        }
        view.accessibilityIdentifier=selected ? "screen.selectedGameModes" : "screen.gameModes"
        layout.axis = .vertical;layout.translatesAutoresizingMaskIntoConstraints=false
        body.addSubview(layout);layout.addArrangedSubview(selector);layout.addArrangedSubview(modesScroll)
        NSLayoutConstraint.activate([
            layout.topAnchor.constraint(equalTo:body.topAnchor),layout.bottomAnchor.constraint(equalTo:body.bottomAnchor),
            layout.leadingAnchor.constraint(equalTo:body.leadingAnchor),layout.trailingAnchor.constraint(equalTo:body.trailingAnchor)
        ])
        let column=UIStackView();column.axis = .vertical;column.alignment = .center;column.spacing=4
        column.translatesAutoresizingMaskIntoConstraints=false;selector.addSubview(column)
        NSLayoutConstraint.activate([
            column.centerYAnchor.constraint(equalTo:selector.centerYAnchor),
            column.topAnchor.constraint(greaterThanOrEqualTo:selector.topAnchor),column.bottomAnchor.constraint(lessThanOrEqualTo:selector.bottomAnchor),
            column.leadingAnchor.constraint(equalTo:selector.leadingAnchor),column.trailingAnchor.constraint(equalTo:selector.trailingAnchor)
        ])
        selectorHeight = selector.heightAnchor.constraint(equalTo: column.heightAnchor)
        selectorHeight.isActive = true
        let up=button(CatalogText.ui("level")+" +",icon:.up,kind:.iconSurface){[weak self] in self?.changeLevel(1)}
        let down=button(CatalogText.ui("level")+" −",icon:.down,kind:.iconSurface){[weak self] in self?.changeLevel(-1)}
        for arrow in [up,down] {
            arrow.setContentInsets(UIEdgeInsets(top:8,left:8,bottom:8,right:8))
            NSLayoutConstraint.activate([arrow.widthAnchor.constraint(equalToConstant:60),arrow.heightAnchor.constraint(equalToConstant:60)])
        }
        column.addArrangedSubview(up)
        let numberRow=UIView();numberRow.translatesAutoresizingMaskIntoConstraints=false
        column.addArrangedSubview(numberRow);numberRow.widthAnchor.constraint(equalTo:column.widthAnchor).isActive=true
        levelField.keyboardType = .numberPad;levelField.textAlignment = .center;levelField.delegate=self
        levelField.accessibilityLabel=CatalogText.ui("difficulty");levelField.translatesAutoresizingMaskIntoConstraints=false
        fieldSurface.translatesAutoresizingMaskIntoConstraints=false;numberRow.addSubview(fieldSurface)
        levelField.addTarget(self,action:#selector(levelEditingEnded),for:.editingDidEnd)
        let toolbar=UIToolbar();toolbar.sizeToFit()
        toolbar.items=[.init(systemItem:.flexibleSpace),.init(barButtonSystemItem:.done,target:self,action:#selector(endEditing))]
        levelField.inputAccessoryView=toolbar;numberRow.addSubview(levelField)
        let leaderboard=button(MainText.text("leaderboard"),icon:.leaderboard,kind:.iconSurface){[weak self] in self?.router?.show(.difficultyLeaderboard)}
        leaderboard.setContentInsets(UIEdgeInsets(top:8,left:4,bottom:8,right:4));numberRow.addSubview(leaderboard)
        leaderboard.isHidden=selected
        let preferred=levelField.widthAnchor.constraint(equalToConstant:134);preferred.priority = .defaultHigh
        let height=numberRow.heightAnchor.constraint(equalToConstant:44);numberHeight=height
        selector.setContentHuggingPriority(.defaultHigh,for:.vertical)
        NSLayoutConstraint.activate([
            levelField.centerXAnchor.constraint(equalTo:numberRow.centerXAnchor),levelField.leadingAnchor.constraint(greaterThanOrEqualTo:numberRow.leadingAnchor),
            levelField.topAnchor.constraint(equalTo:numberRow.topAnchor),levelField.bottomAnchor.constraint(equalTo:numberRow.bottomAnchor),preferred,
            height,
            fieldSurface.leadingAnchor.constraint(equalTo:levelField.leadingAnchor),fieldSurface.trailingAnchor.constraint(equalTo:levelField.trailingAnchor),
            fieldSurface.topAnchor.constraint(equalTo:levelField.topAnchor),fieldSurface.bottomAnchor.constraint(equalTo:levelField.bottomAnchor),
            leaderboard.leadingAnchor.constraint(equalTo:levelField.trailingAnchor,constant:4),leaderboard.centerYAnchor.constraint(equalTo:numberRow.centerYAnchor),
            leaderboard.widthAnchor.constraint(equalToConstant:48)
        ])
        if !selected {leaderboard.trailingAnchor.constraint(lessThanOrEqualTo:numberRow.trailingAnchor).isActive=true}
        column.addArrangedSubview(down)
        modesScroll.alwaysBounceVertical=false
        modesStack.axis = .vertical;modesStack.alignment = .fill;modesStack.translatesAutoresizingMaskIntoConstraints=false
        let modesContent=UIView();modesContent.translatesAutoresizingMaskIntoConstraints=false
        modesScroll.addSubview(modesContent);modesContent.addSubview(modesStack)
        NSLayoutConstraint.activate([
            modesContent.topAnchor.constraint(equalTo:modesScroll.contentLayoutGuide.topAnchor),modesContent.bottomAnchor.constraint(equalTo:modesScroll.contentLayoutGuide.bottomAnchor),
            modesContent.leadingAnchor.constraint(equalTo:modesScroll.contentLayoutGuide.leadingAnchor),modesContent.trailingAnchor.constraint(equalTo:modesScroll.contentLayoutGuide.trailingAnchor),
            modesContent.widthAnchor.constraint(equalTo:modesScroll.frameLayoutGuide.widthAnchor),modesContent.heightAnchor.constraint(greaterThanOrEqualTo:modesScroll.frameLayoutGuide.heightAnchor),
            modesStack.centerYAnchor.constraint(equalTo:modesContent.centerYAnchor),
            modesStack.topAnchor.constraint(greaterThanOrEqualTo:modesContent.topAnchor,constant:8),modesStack.bottomAnchor.constraint(lessThanOrEqualTo:modesContent.bottomAnchor,constant:-8),
            modesStack.leadingAnchor.constraint(equalTo:modesContent.leadingAnchor,constant:8),modesStack.trailingAnchor.constraint(equalTo:modesContent.trailingAnchor,constant:-8)
        ])
        for mode in [GameMode.single,.minute,.speed,.noTime] {
            let card=UIStackView();card.axis = .vertical;card.alignment = .center;card.spacing=0
            let play=button(CatalogText.ui("mode_"+mode.rawValue),icon:icon(mode),kind:.dialog,balancesIcon:true){[weak self] in self?.launch(mode)}
            play.label.role = .gameMode
            play.accessibilityIdentifier="mode.\(mode.rawValue)";playButtons.append(play)
            play.label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            let graph=button(MainText.text("graph"),icon:.graph,kind:.iconSurface){[weak self] in guard let self else{return};router?.show(.gameGraph(mode,selected:selected))}
            let board=button(MainText.text("leaderboard"),icon:.leaderboard,kind:.iconSurface){[weak self] in guard let self else{return};router?.show(.gameLeaderboard(mode,selected:selected))}
            for item in [graph,board] {
                item.widthAnchor.constraint(equalToConstant:48).isActive=true
                item.setContentInsets(UIEdgeInsets(top:8,left:4,bottom:8,right:4));item.isHidden=selected
            }
            let actions=UIStackView(arrangedSubviews:[play,graph,board]);actions.axis = .horizontal;actions.alignment = .center
            card.addArrangedSubview(actions)
            let width=play.widthAnchor.constraint(equalToConstant:230);width.priority = .defaultHigh;width.isActive=true;playWidths.append(width)
            play.widthAnchor.constraint(lessThanOrEqualTo:card.widthAnchor,constant:selected ? 0 : -96).isActive=true
            let record=label("—",role:.detail);record.textAlignment = .center;recordLabels[mode]=record
            let reset=button(MainText.text("reset_score"),kind:.plain){[weak self] in self?.resetRecord(mode)}
            resetButtons.append(reset)
            reset.label.role = .detail;reset.label.numberOfLines=1;reset.setContentInsets(UIEdgeInsets(top:4,left:8,bottom:4,right:8),minimumHeight:48)
            let records=UIStackView(arrangedSubviews:[record,reset]);records.axis = .horizontal;records.alignment = .center;records.spacing=8
            card.addArrangedSubview(records);records.widthAnchor.constraint(lessThanOrEqualTo:card.widthAnchor).isActive=true
            modesStack.addArrangedSubview(card)
        }
    }
    private var testingLevel: Int64?
    private func currentLevel(_ progress:ProgressState)->Int64 {
        if AppConstants.unlockAllLevels, let testingLevel { return testingLevel }
        return selected ? progress.selectedCurrentLevel ?? progress.currentLevel : progress.currentLevel
    }
    private func maximumLevel(_ progress: ProgressState) -> Int64 {
        AppConstants.unlockAllLevels ? Int64(GameDifficulty.maximum) : progress.maximumLevel
    }
    override func update(_ progress:ProgressState?) {
        levelField.font=AppTypography.font(.catalogTrick,settings:settings,traits:traitCollection)
        numberHeight?.constant=max(44,levelField.font!.lineHeight+12)
        levelField.textColor=palette.text;fieldSurface.apply(settings:settings)
        selector.backgroundColor=palette.theme.isClassic ? palette.surface : .clear
        if let progress {
            header.setTitle(MainText.format("activity_game_tv_level","1 - \(min(Int64(GameDifficulty.maximum),maximumLevel(progress)))"))
            levelField.accessibilityHint="1–\(min(Int64(GameDifficulty.maximum),maximumLevel(progress)))"
            if !levelField.isFirstResponder {levelField.text=String(min(Int64(GameDifficulty.maximum),currentLevel(progress)))}
            for (mode,label) in recordLabels {
                let record=progress.records.first{$0.mode==mode && $0.selectedTricks==selected}
                let value=record.map{MathExpressionFormatter.number($0.value)} ?? (mode == .speed ? "---" : "0")
                label.text=MainText.text(mode == .speed ? "alert_dialog_timer_end_tv_time_max" : "alert_dialog_timer_end_tv_score_max")+value
                label.textColor=palette.accent
            }
        }
        themedButtons.forEach{$0.isEnabled=progress != nil && !launching}
        for button in resetButtons { button.apply(settings:settings,textTint:.gray) }
        view.setNeedsLayout()
    }
    private func icon(_ mode:GameMode)->AppIcon {
        switch mode {case .minute:return .modeMinute;case .speed:return .modeSpeed;case .noTime:return .modeNoTime;default:return .modeSingle}
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout.synchronizeArrangement()
        let landscape = layout.isHorizontal ?? (view.bounds.width > view.bounds.height)
        guard wide != landscape else { return }
        wide = landscape
        selectorWidth?.isActive = false
        selectorHeight.isActive = !landscape && !layout.usesNativeArrangement
        layout.axis = landscape ? .horizontal : .vertical
        modesStack.spacing = landscape ? 12 : 0
        if landscape && !layout.usesNativeArrangement {
            selectorWidth = selector.widthAnchor.constraint(equalTo: layout.widthAnchor, multiplier: view.usesDuoLayout ? 0.5 : 1/3)
            selectorWidth?.isActive = true
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let landscape = view.bounds.width > view.bounds.height
        let normal=AndroidDimensions.value("alert_dialog_theme_b_width",traits:traitCollection,size:view.bounds.size,fallback:230)
        // The scroll view can still have its previous/zero width on the first
        // layout pass. Do not shrink the caption to zero before it is displayed.
        let screenWidth = body.bounds.width
        guard screenWidth > 0 else { return }
        let contentWidth = modesScroll.bounds.width > 0 ? modesScroll.bounds.width : (landscape ? screenWidth * (view.usesDuoLayout ? 0.5 : 2 / 3) : screenWidth)
        let available=max(120,contentWidth-16-(selected ? 0 : 96))
        var width=min(normal,available)
        if playButtons.contains(where: { $0.label.sizeThatFits(CGSize(width:max(1,width-120),height:.greatestFiniteMagnitude)).height > $0.label.font.lineHeight*2+1 }) { width=available }
        for constraint in playWidths where abs(constraint.constant-width)>0.5 {constraint.constant=width}
    }
    @objc private func endEditing() { view.endEditing(true) }
    @objc private func levelEditingEnded() {
        guard let progress = data.snapshot else { return }
        let value = min(Int(min(Int64(GameDifficulty.maximum),maximumLevel(progress))), max(1, Int(levelField.text ?? "") ?? Int(currentLevel(progress))))
        levelField.text = String(value); saveLevel(value)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { textField.resignFirstResponder(); return true }
    private func changeLevel(_ delta: Int) {
        guard let progress = data.snapshot else { return }
        let value = min(Int(min(Int64(GameDifficulty.maximum),maximumLevel(progress))), max(1, Int(currentLevel(progress)) + delta)); saveLevel(value)
    }
    private func saveLevel(_ value: Int) {
        if AppConstants.unlockAllLevels {
            testingLevel = Int64(value)
            update(data.snapshot)
            return
        }
        Task { [weak self] in
            guard let self else { return }
            do { try await data.setCurrentLevel(Int64(value),selected:selected) } catch { showError(error) }
        }
    }
    private func launch(_ mode: GameMode) {
        endEditing()
        guard !launching, let progress = data.snapshot else { return }
        let requestedLevel = min(Int(min(Int64(GameDifficulty.maximum),maximumLevel(progress))), max(1, Int(levelField.text ?? "") ?? Int(currentLevel(progress))))
        launching = true; update(progress)
        Task { [weak self] in
            guard let self else { return }
            defer { launching = false; update(data.snapshot) }
            do {
                if !AppConstants.unlockAllLevels {
                    try await data.setCurrentLevel(Int64(requestedLevel),selected:selected)
                }
                let pool: [Int]
                if selected { pool = try await data.catalogProgress().filter { $0.selected && $0.unlocked }.map(\.id) }
                else { pool = TrickCatalog.shared.tricks.filter { AppPurchases.shared.hasFullVersion || AppConstants.unlockAllLevels || $0.initiallyUnlocked }.map(\.id) }
                guard !pool.isEmpty else { throw ProgressError.invalidValue }
                router?.show(.game(GameConfiguration(mode: mode, difficulty: requestedLevel, trickIDs: pool, selectedTricks: selected)))
            } catch { showError(error) }
        }
    }
    private func resetRecord(_ mode: GameMode) {
        present(AppDialogViewController(title: CatalogText.ui("reset_record"), message: CatalogText.ui("reset_record_confirm"), actions: [
            .init(title: CatalogText.ui("cancel"), handler: {}),
            .init(title: MainText.text("ok"), handler: { [weak self] in
                guard let self else { return }
                Task { [weak self] in
                    guard let self else { return }
                    do { try await data.resetGameRecord(mode, selected: selected) } catch { showError(error) }
                }
            })], data: data), animated: false)
    }
}
