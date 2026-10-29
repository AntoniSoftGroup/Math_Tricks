import UIKit

final class StatisticsViewController: ThemedViewController, UITableViewDataSource, UITableViewDelegate {
    private enum Row { case entry(PracticeEntry), aggregate(PracticeAggregate), example(PracticeAggregate), heading(String), text(String), link(Int) }
    private struct LevelSelection: Hashable {
        let first: Int
        let range: Bool
        var levels: ClosedRange<Int> { first...(range ? first + 9 : first) }
        var order: Int { (range ? first + 9 : first) * 2 + (range ? 1 : 0) }
    }
    private let filter: StatisticsFilter
    private let section: Int
    private var selectedInput: GameInputMode
    private var statistics: PracticeStatistics?
    private var preparedStatistics: PracticeStatistics?
    private var rows: [Row] = []
    private let table = AppTableView(frame: .zero, style: .plain)
    private var statisticsTitle:AppLabel!
    private var inputButton: UIButton!
    private let inputCard=UIView()
    private var inputCaption:UILabel!
    private let column=ResultUI.stack(.vertical)
    private let controls=ResultUI.stack(.vertical)
    private let listControls=ResultUI.stack(.horizontal,spacing:8)
    private let overview=ResultUI.stack(.vertical,spacing:12)
    private let overviewCards=ResultUI.stack(.vertical,spacing:8)
    private let overviewActions=ResultUI.stack(.vertical,spacing:8)
    private let overviewScroll=AppScrollView()
    private let actionsScroll=AppScrollView()
    private var inputWidth:NSLayoutConstraint?
    private var overviewWidth:NSLayoutConstraint?
    private var landscape:Bool?
    private var clearButton:UIButton?
    private var shareButton:UIButton?
    private var sortButton:UIButton?
    private var pagePrevious:UIButton!
    private var pageNext:UIButton!
    private lazy var resultDetails=ResultDetailsCoordinator(owner:self,router:router)
    private var summary: AppLabel!
    private var rangeButton: AppButton!
    private var previousLevel: AppButton!
    private var nextLevel: AppButton!
    private var rangeControls: UIStackView!
    private var pageLabel: AppLabel!
    private var sizeButton: UIButton!
    private var page = 0
    private var pageSize = 20
    private var levelSelection = LevelSelection(first: 1, range: false)
    private var selections: [LevelSelection] = []
    private var sort = 0
    private var readTask: Task<Void, Never>?
    init(filter: StatisticsFilter = .all, section: Int? = nil, input: GameInputMode? = nil, router: AppRouter, data: AppDataStore) {
        self.filter = filter
        self.section = section ?? (filter == .all ? 0 : { if case .trick = filter { return 2 }; return 1 }())
        selectedInput = input ?? data.snapshot?.settings.gameInputMode ?? .digits
        super.init(title: Self.sectionTitle(self.section), router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { readTask?.cancel() }
    private static func sectionTitle(_ section: Int) -> String {
        if section == 0 { return MainText.text("example_statistics_title") }
        return CatalogText.ui(["", "stats_examples", "stats_tricks", "stats_repeat", "stats_trick_repeat"][section])
    }
    func prepareForPresentation() async throws {
        preparedStatistics = try await data.practiceStatistics()
        try Task.checkCancellation()
        loadViewIfNeeded()
    }
    override func buildContent() {
        view.accessibilityIdentifier="screen.statistics"
        ResultUI.pin(column,in:body)
        statisticsTitle=label(Self.sectionTitle(section),role:.settingsTitle);header.replaceTitle(with:statisticsTitle)
        let palette=ResultPalette(settings)
        let input=ResultUI.stack(.vertical,spacing:0)
        inputCaption=ResultUI.label(ResultText.text("statistics_input_type"),size:14,settings:settings,color:palette.secondary)
        input.addArrangedSubview(inputCaption)
        inputButton=UIButton(type:.system)
        inputButton.contentHorizontalAlignment = .leading
        inputButton.addAction(UIAction{[weak self] _ in self?.selectInput()},for:.touchUpInside)
        input.addArrangedSubview(inputButton)
        ResultUI.pin(input,in:inputCard,insets:UIEdgeInsets(top:8,left:16,bottom:12,right:16))
        column.addArrangedSubview(inputCard)
        rangeButton=button("",kind:.plain){[weak self] in self?.selectLevel()}
        previousLevel=button(ResultText.text("statistics_previous_level"),icon:.previous,kind:.icon){[weak self] in self?.changeLevel(-1)}
        nextLevel=button(ResultText.text("statistics_next_level"),icon:.next,kind:.icon){[weak self] in self?.changeLevel(1)}
        rangeControls=UIStackView(arrangedSubviews:[previousLevel,rangeButton,nextLevel]);rangeControls.alignment = .center
        previousLevel.widthAnchor.constraint(equalToConstant:48).isActive=true
        nextLevel.widthAnchor.constraint(equalTo:previousLevel.widthAnchor).isActive=true
        rangeButton.setContentHuggingPriority(.defaultLow,for:.horizontal)
        let centeredLevels=UIStackView(arrangedSubviews:[rangeControls]);centeredLevels.axis = .vertical;centeredLevels.alignment = .center
        rangeControls.widthAnchor.constraint(lessThanOrEqualTo:centeredLevels.widthAnchor).isActive=true
        centeredLevels.isHidden = ![2,4].contains(section);controls.addArrangedSubview(centeredLevels)
        if [1,2].contains(section) {
            let label=ResultUI.label(ResultText.text("statistics_sort_label"),size:12,settings:settings,color:palette.secondary)
            listControls.addArrangedSubview(label)
            sortButton=ResultUI.button("",settings:settings){[weak self] in guard let self else{return};sort=(sort+1)%3;page=0;rebuild()}
            sizeButton=ResultUI.button("",settings:settings){[weak self] in self?.selectPageSize()}
            label.setContentHuggingPriority(.required,for:.horizontal)
            for key in [sortButton!,sizeButton!] {
                var configuration=key.configuration
                configuration?.contentInsets=NSDirectionalEdgeInsets(top:4,leading:6,bottom:4,trailing:6)
                configuration?.titleTextAttributesTransformer=UIConfigurationTextAttributesTransformer{[settings] incoming in var value=incoming;value.font=ResultUI.font(10,settings:settings);return value}
                key.configuration=configuration;key.titleLabel?.numberOfLines=1;key.titleLabel?.adjustsFontSizeToFitWidth=true;key.titleLabel?.minimumScaleFactor=0.8
                key.heightAnchor.constraint(greaterThanOrEqualToConstant:36).isActive=true
                listControls.addArrangedSubview(key)
            }
            controls.addArrangedSubview(listControls)
        }
        column.addArrangedSubview(controls)
        summary=label("",role:.caption);summary.isHidden=true
        table.backgroundColor = .clear;table.dataSource=self;table.delegate=self;table.separatorStyle = .none
        table.rowHeight=UITableView.automaticDimension;table.estimatedRowHeight=70;table.sectionHeaderTopPadding=0
        table.register(ResultColumnsCell.self,forCellReuseIdentifier:"columns");table.register(StatisticsTextCell.self,forCellReuseIdentifier:"text")
        let list=UIView();ResultUI.pin(table,in:list,insets:UIEdgeInsets(top:0,left:16,bottom:0,right:16));column.addArrangedSubview(list)
        if section==0 {
            table.isHidden=true
            overviewScroll.translatesAutoresizingMaskIntoConstraints=false;actionsScroll.translatesAutoresizingMaskIntoConstraints=false
            ResultUI.pin(overview,in:list,insets:UIEdgeInsets(top:0,left:16,bottom:12,right:16))
            overview.addArrangedSubview(overviewScroll);overview.addArrangedSubview(actionsScroll)
            configureScroll(overviewScroll,content:overviewCards)
            configureScroll(actionsScroll,content:overviewActions)
            clearButton=ResultUI.button(ResultText.text("statistics_clear"),icon:.statisticsDelete,settings:settings){[weak self] in self?.confirmClear()}
            clearButton?.widthAnchor.constraint(lessThanOrEqualToConstant:140).isActive=true
            var configuration=clearButton?.configuration
            configuration?.titleTextAttributesTransformer=UIConfigurationTextAttributesTransformer{[settings] incoming in var value=incoming;value.font=ResultUI.font(11,settings:settings);return value}
            clearButton?.configuration=configuration
        }
        if [1,2].contains(section) {
            pageLabel=label("",role:.caption);pageLabel.textAlignment = .center
            pagePrevious=ResultUI.button("‹",settings:settings){[weak self] in self?.changePage(-1)}
            pageNext=ResultUI.button("›",settings:settings){[weak self] in self?.changePage(1)}
            let pages=UIStackView(arrangedSubviews:[pagePrevious,pageLabel,pageNext]);pages.alignment = .center
            shareButton=ResultUI.button(ResultText.text("results_share_results"),icon:.resultShare,settings:settings){[weak self] in self?.share()}
            let bottom=UIStackView(arrangedSubviews:[pages,shareButton!]);bottom.axis = .horizontal;bottom.alignment = .center;bottom.distribution = .fillEqually;bottom.spacing=8
            bottom.layoutMargins=UIEdgeInsets(top:4,left:16,bottom:4,right:16);bottom.isLayoutMarginsRelativeArrangement=true;column.addArrangedSubview(bottom)
        } else {pageLabel=label("",role:.caption)}
    }
    private func configureScroll(_ scroll:UIScrollView,content:UIView) {
        content.translatesAutoresizingMaskIntoConstraints=false;scroll.addSubview(content)
        NSLayoutConstraint.activate([content.topAnchor.constraint(equalTo:scroll.contentLayoutGuide.topAnchor),content.bottomAnchor.constraint(equalTo:scroll.contentLayoutGuide.bottomAnchor),content.leadingAnchor.constraint(equalTo:scroll.contentLayoutGuide.leadingAnchor),content.trailingAnchor.constraint(equalTo:scroll.contentLayoutGuide.trailingAnchor),content.widthAnchor.constraint(equalTo:scroll.frameLayoutGuide.widthAnchor)])
    }
    override func update(_ progress:ProgressState?) {
        let palette=ResultPalette(settings)
        statisticsTitle.textColor=ThemePalette(settings:settings).theme == .light ? .white:palette.primary
        inputCaption.textColor=palette.secondary
        inputCaption.font=ResultUI.font(14,settings:settings)
        for key in [clearButton,shareButton,pagePrevious,pageNext,sortButton,sizeButton] {
            if let key {ResultUI.applyButton(key,settings:settings,size:key === clearButton ? 11:(key === sortButton || key === sizeButton) ? 10:14)}
        }
        if let sortLabel=listControls.arrangedSubviews.first as? UILabel {sortLabel.font=ResultUI.font(12,settings:settings);sortLabel.textColor=palette.secondary}
        if let preparedStatistics {
            self.preparedStatistics = nil
            statistics = preparedStatistics
            rebuild()
        } else if progress != nil {load()}
    }
    override func viewDidAppear(_ animated:Bool) {super.viewDidAppear(animated);resultDetails.restore(settings:settings)}
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let next=view.bounds.width>view.bounds.height
        if landscape != next {landscape=next;placeControls(landscape:next);if statistics != nil {rebuild()}}
        if let header=table.tableHeaderView {
            let height=header.systemLayoutSizeFitting(CGSize(width:table.bounds.width,height:0),withHorizontalFittingPriority:.required,verticalFittingPriority:.fittingSizeLevel).height
            if abs(header.frame.height-height)>0.5 || header.frame.width != table.bounds.width {header.frame=CGRect(x:0,y:0,width:table.bounds.width,height:height);table.tableHeaderView=header}
        }
    }
    private func placeControls(landscape:Bool) {
        inputWidth?.isActive=false;overviewWidth?.isActive=false
        inputCard.removeFromSuperview()
        let accessory=ResultUI.stack(.horizontal,spacing:8);accessory.alignment = .center
        if landscape {
            accessory.addArrangedSubview(inputCard)
            inputWidth=inputCard.widthAnchor.constraint(equalToConstant:min(300,view.bounds.width*0.32));inputWidth?.isActive=true
        } else {column.insertArrangedSubview(inputCard,at:0)}
        if let clearButton {clearButton.removeFromSuperview();accessory.addArrangedSubview(clearButton)}
        header.setAccessoryView(accessory)
        controls.axis=landscape ? .horizontal:.vertical;controls.alignment = .fill
        controls.layoutMargins=UIEdgeInsets(top:0,left:16,bottom:4,right:16);controls.isLayoutMarginsRelativeArrangement=true
        if section==0 {
            overview.axis=landscape ? .horizontal:.vertical
            overviewActions.removeFromSuperview()
            if landscape {
                configureScroll(actionsScroll,content:overviewActions);actionsScroll.isHidden=false
                overviewWidth=actionsScroll.widthAnchor.constraint(equalTo:overview.widthAnchor,multiplier:0.46);overviewWidth?.isActive=true
            } else {actionsScroll.isHidden=true;overviewCards.addArrangedSubview(overviewActions)}
        }
        updateInputAppearance()
    }
    private func updateInputAppearance() {
        let inHeader=landscape==true,theme=ThemePalette(settings:settings),palette=ResultPalette(settings)
        let color=inHeader && theme.theme == .light ? UIColor.white:palette.primary
        inputCaption.textColor=inHeader && theme.theme == .light ? .white:palette.secondary
        var configuration=UIButton.Configuration.plain();configuration.title=ResultText.text(["example_statistics_keyboard","example_statistics_choices","example_statistics_boolean"][selectedInput.rawValue])
        configuration.image=UIImage(systemName:"chevron.down");configuration.imagePlacement = .trailing;configuration.imagePadding=12
        configuration.contentInsets=NSDirectionalEdgeInsets(top:8,leading:0,bottom:4,trailing:0);configuration.baseForegroundColor=color
        configuration.titleTextAttributesTransformer=UIConfigurationTextAttributesTransformer{[settings] incoming in var value=incoming;value.font=ResultUI.font(18,settings:settings);return value}
        inputButton.configuration=configuration
    }
    private func load() {
        readTask?.cancel(); readTask = Task { [weak self] in
            guard let self else { return }
            do { let value = try await data.practiceStatistics(); guard !Task.isCancelled else { return }; statistics = value; rebuild() }
            catch { guard !Task.isCancelled else { return }; showError(error, reading: true, retry: { [weak self] in self?.load() }) }
        }
    }
    private var sessionOnly: Bool { if case .session = filter { return true }; if case .example = filter { return true }; return false }
    private func accepts(_ record: ImportedPracticeRecord) -> Bool {
        switch filter { case .all: return true; case .session: return false; case .trick(let id): return record.trickID == id; case .example(let id): return record.id == id }
    }
    private func updateSelections(_ statistics: PracticeStatistics) {
        let levels = Set(statistics.filtered(filter, input: selectedInput).map { $0.attempt.level })
        let imported = statistics.importedDetails.filter { accepts($0) && $0.trickID != nil && $0.matches(input: selectedInput, levels: nil) }
        var values = levels.map { LevelSelection(first: $0, range: false) }
        values += Set(levels.map { ($0 - 1) / 10 * 10 + 1 }).map { LevelSelection(first: $0, range: true) }
        values += imported.compactMap { record in record.level.map { LevelSelection(first: $0, range: record.completeRange) } }
        selections = Array(Set(values)).sorted { $0.order < $1.order }
        if !selections.contains(levelSelection), let first = selections.first { levelSelection = first }
        rangeButton.label.text = levelText(levelSelection)
        let index = selections.firstIndex(of: levelSelection) ?? 0
        previousLevel.isEnabled = index > 0; nextLevel.isEnabled = index + 1 < selections.count
        rangeButton.isEnabled = !selections.isEmpty
    }
    private func levelText(_ value: LevelSelection) -> String {
        value.range ? ResultText.format("statistics_level_average",Int64(value.first),Int64(value.first+9)):ResultText.format("statistics_level",Int64(value.first))
    }
    private func rebuild() {
        guard let statistics else { return }
        updateInputAppearance()
        if [2,4].contains(section) { updateSelections(statistics) }
        let selectedLevels = [2,4].contains(section) && !sessionOnly ? levelSelection.levels : nil
        let entries = statistics.filtered(filter, input: selectedInput, levels: selectedLevels)
        let source = selectedLevels != nil && !levelSelection.range ? statistics.importedDetails.filter { !$0.completeRange } : statistics.imported
        let retained = source.filter { accepts($0) && $0.matches(input: selectedInput, levels: selectedLevels) }
        let total = PracticeAggregate(id: "all", entries: entries, imported: retained.filter { $0.trickID != nil })
        summary.text = "\(CatalogText.ui("solved")): \(total.solved) · \(CatalogText.ui("independent")): \(total.independentCount)\n\(CatalogText.ui("errors")): \(total.errors) · \(CatalogText.ui("average")): \(time(total.average))"
        func aggregate(_ examples: Bool) -> [PracticeAggregate] {
            let current = examples ? PracticeStatistics.examples(entries).filter { $0.best != nil } : PracticeStatistics.tricks(entries)
            var combined = Dictionary(uniqueKeysWithValues: current.map { ($0.id, $0) })
            for (id, records) in Dictionary(grouping: retained.filter { examples ? $0.expression != nil : $0.trickID != nil }, by: \.id) {
                var value = combined[id] ?? PracticeAggregate(id: id, entries: [],trickRecord:!examples); value.imported += records; combined[id] = value
            }
            return Array(combined.values)
        }
        if sessionOnly {
            rows = entries.map(Row.entry)
            if case .example = filter { rows += aggregate(true).filter { !$0.imported.isEmpty }.map(Row.example) }
        } else if section == 0 {
            rows = [.text("\(CatalogText.ui("solved")): \(total.solved)\n\(CatalogText.ui("statistics_attempts")): \(total.attempts)\n\(CatalogText.ui("independent")): \(total.independentCount)"),
                .text("\(CatalogText.ui("average")): \(time(total.average))\n\(CatalogText.ui("errors")): \(total.errors)\n\(CatalogText.ui("hint")): \(total.hints)"),
                .link(1), .link(2), .link(3), .link(4)]
        } else {
            let examples = section == 1 || section == 3
            var values = aggregate(examples)
            if section == 4 {
                let slow = values.filter { $0.average != nil }.sorted { $0.average == $1.average ? $0.id < $1.id : ($0.average ?? 0) > ($1.average ?? 0) }
                let mistakes = values.filter { $0.errors > 0 }.sorted { $0.errorRate == $1.errorRate ? $0.id < $1.id : $0.errorRate > $1.errorRate }
                rows = []
                if !slow.isEmpty { rows += [.heading(CatalogText.ui("statistics_tricks_slow"))] + slow.prefix(5).map(Row.aggregate) }
                if !mistakes.isEmpty { rows += [.heading(CatalogText.ui("statistics_tricks_errors"))] + mistakes.prefix(5).map(Row.aggregate) }
            } else {
                values.sort {
                    if section == 3 || sort == 2 { return $0.best == $1.best ? $0.id < $1.id : ($0.best ?? 0) > ($1.best ?? 0) }
                    if sort == 1 { return $0.best == $1.best ? $0.id < $1.id : ($0.best ?? .greatestFiniteMagnitude) < ($1.best ?? .greatestFiniteMagnitude) }
                    return examples ? $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending : (Int($0.id) ?? 0) < (Int($1.id) ?? 0)
                }
                if section == 3 { values = Array(values.filter { $0.best != nil }.prefix(5)) }
                rows = (section == 3 && !values.isEmpty ? [.heading(ResultText.text("example_statistics_slow"))] : []) + values.map { examples ? Row.example($0) : Row.aggregate($0) }
            }
        }
        page = min(page, max(0, (rows.count - 1) / effectivePageSize))
        let start=rows.isEmpty ? 0:page*effectivePageSize+1,end=min(rows.count,(page+1)*effectivePageSize)
        pageLabel.text=ResultText.format("statistics_page_range",Int64(start),Int64(end),Int64(rows.count))
        pagePrevious?.isEnabled=page>0;pageNext?.isEnabled=page+1<(rows.count+effectivePageSize-1)/effectivePageSize
        shareButton?.isEnabled = !rows.isEmpty
        sortButton?.setTitle(ResultText.text(sort==0 ? "statistics_sort_best":sort==1 ? "statistics_sort_fastest":"statistics_sort_slowest"),for:.normal)
        sizeButton?.setTitle(pageSize==0 ? ResultText.text("statistics_page_all"):ResultText.format("statistics_page_size_value",Int64(pageSize)),for:.normal)
        if section==0 {rebuildOverview(total:total,examples:aggregate(true))}
        table.reloadData()
        rebuildTableHeader()
        table.backgroundView = rows.isEmpty ? emptyLabel() : nil
    }
    private var effectivePageSize: Int { pageSize == 0 || ![1,2].contains(section) ? max(1, rows.count) : pageSize }
    private func emptyLabel() -> UILabel { let label = UILabel(); label.text = CatalogText.ui("statistics_empty"); label.textColor = palette.secondary; label.textAlignment = .center; label.numberOfLines = 0; return label }
    private func changePage(_ delta: Int) { page = max(0, min(max(0, (rows.count - 1) / effectivePageSize), page + delta)); rebuild(); table.setContentOffset(.zero, animated: false) }
    private func changeLevel(_ delta: Int) {
        guard let index = selections.firstIndex(of: levelSelection), selections.indices.contains(index + delta) else { return }
        levelSelection = selections[index + delta]; page = 0; rebuild()
    }
    private func selectInput() {
        choose(title: CatalogText.ui("change_input"), values: ["example_statistics_keyboard","example_statistics_choices","example_statistics_boolean"].map(ResultText.text),current:selectedInput.rawValue,anchor:inputButton) { [weak self] index in
            self?.selectedInput = GameInputMode(rawValue: index) ?? .digits; self?.page = 0; self?.rebuild()
        }
    }
    private func selectLevel() {
        // UIMenu is deliberately bounded by the actual recorded positions.
        choose(title: CatalogText.ui("level"), values: selections.map(levelText),current:selections.firstIndex(of:levelSelection) ?? 0) { [weak self] index in
            guard let self else { return }; levelSelection = selections[index]; page = 0; rebuild()
        }
    }
    private func selectPageSize() {
        let sizes = section == 2 ? [10,20,50,0] : [10,20,50,100]
        choose(title: CatalogText.ui("statistics_page_size"), values: sizes.map { $0 == 0 ? CatalogText.ui("all") : String($0) },current:sizes.firstIndex(of:pageSize) ?? 0,anchor:sizeButton) { [weak self] index in
            self?.pageSize = sizes[index]; self?.page = 0; self?.rebuild()
        }
    }
    private func choose(title: String,values: [String],current: Int,anchor: UIView? = nil,selected: @escaping (Int) -> Void) {
        guard presentedViewController == nil else { return }
        present(ResultSelectionViewController(title:title,values:values,selection:current,settings:settings,anchor:anchor,handler:selected),animated:false)
    }
    private func confirmClear() {
        guard presentedViewController == nil else { return }
        present(AppDialogViewController(title: CatalogText.ui("statistics_clear"), message: CatalogText.ui("statistics_clear_confirm"), actions: [
            .init(title: CatalogText.ui("cancel"), handler: {}),
            .init(title: CatalogText.ui("statistics_clear"), handler: { [weak self] in
                guard let self else { return }
                Task { do { try await self.data.clearPracticeStatistics(); self.page = 0; self.load() } catch { self.showError(error) } }
            })
        ], data: data), animated: false)
    }
    private func time(_ value: TimeInterval?) -> String { value.map { MathExpressionFormatter.number($0) + " " + CatalogText.ui("seconds") } ?? "—" }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { min(effectivePageSize, max(0, rows.count - page * effectivePageSize)) }
    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath)->UITableViewCell {
        let index=page*effectivePageSize+indexPath.row
        guard rows.indices.contains(index) else { return tableView.dequeueReusableCell(withIdentifier:"text",for:indexPath) }
        let row=rows[index],palette=ResultPalette(settings)
        switch row {
        case .example(let aggregate),.aggregate(let aggregate):
            let isExample:Bool;if case .example=row {isExample=true}else{isExample=false}
            let name=isExample ? exampleName(aggregate):trickName(aggregate)
            if [3,4].contains(section) {
                let cell=tableView.dequeueReusableCell(withIdentifier:"text",for:indexPath) as! StatisticsTextCell
                let detail = isExample ? ResultText.format("statistics_example_best_value",ResultText.time(aggregate.best)) :
                    (aggregate.errors>0 && indexPath.row>=(rows.firstIndex{if case .heading(let title)=$0{return title==CatalogText.ui("statistics_tricks_errors")};return false} ?? Int.max) ? ResultText.format("example_statistics_error_value",Int64(aggregate.errors),Int64(aggregate.attempts)):ResultText.format("example_statistics_slow_value",ResultText.time(aggregate.average),Int64(aggregate.independentCount)))
                cell.configure(title:name,subtitle:detail,settings:settings);return cell
            }
            let cell=tableView.dequeueReusableCell(withIdentifier:"columns",for:indexPath) as! ResultColumnsCell
            let first=ResultText.time(aggregate.first),best=ResultText.time(aggregate.best),equal=aggregate.first != nil && first==best
            cell.configure(ResultColumnsView(title:name,values:[first,equal ? "=":best],settings:settings,colors:[palette.secondary,equal ? palette.secondary:(aggregate.best ?? .greatestFiniteMagnitude)<(aggregate.first ?? 0) ? palette.success:palette.primary],last:indexPath.row==tableView.numberOfRows(inSection:0)-1),settings:settings);return cell
        case .entry(let entry):
            let cell=tableView.dequeueReusableCell(withIdentifier:"text",for:indexPath) as! StatisticsTextCell
            cell.configure(title:MathExpressionFormatter.text(entry.attempt.example),subtitle:ResultAnswerStatus.text(entry.attempt) ?? ResultText.time(entry.attempt.elapsed),settings:settings);return cell
        case .heading(let title),.text(let title):
            let cell=tableView.dequeueReusableCell(withIdentifier:"text",for:indexPath) as! StatisticsTextCell;cell.configure(title:title,settings:settings,heading:true);return cell
        case .link(let section):
            let cell=tableView.dequeueReusableCell(withIdentifier:"text",for:indexPath) as! StatisticsTextCell;cell.configure(title:Self.sectionTitle(section),settings:settings);return cell
        }
    }
    private func exampleName(_ aggregate:PracticeAggregate)->String {aggregate.entries.first.map{MathExpressionFormatter.text($0.attempt.example)} ?? aggregate.imported.first?.expression?.replacingOccurrences(of:"*",with:"×").replacingOccurrences(of:"/",with:"÷") ?? ""}
    private func trickName(_ aggregate:PracticeAggregate)->String {(aggregate.entries.first.map{$0.attempt.example.trickID} ?? aggregate.imported.first?.trickID).flatMap{TrickCatalog.shared.trick($0)}.map{AndroidRichText.plain(CatalogText.text($0.nameKey))} ?? ""}
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath) {
        tableView.deselectRow(at:indexPath,animated:false)
        let index=page*effectivePageSize+indexPath.row
        guard rows.indices.contains(index) else { return }
        switch rows[index] {
        case .heading,.text:break
        case .link(let section):router?.show(.statisticsList(section,selectedInput))
        case .entry(let entry):resultDetails.show(SessionResultQuestion(attempts:[entry.attempt]),settings:settings)
        case .example(let aggregate):
            showMetrics(title:exampleName(aggregate),metrics:[ResultMetric(value:ResultText.time(aggregate.first),caption:ResultText.text("results_first_time")),ResultMetric(value:ResultText.time(aggregate.best),caption:ResultText.text("results_share_best_time"))])
        case .aggregate(let aggregate):
            let values=[String(aggregate.solved),String(aggregate.attempts),String(aggregate.independentCount),ResultText.time(aggregate.average),ResultText.duration(aggregate.totalTime),String(aggregate.errors),String(aggregate.hints),String(aggregate.skipped),ResultText.time(aggregate.first),ResultText.time(aggregate.best)]
            let names=["example_statistics_solved","statistics_attempts_card","example_statistics_clean","example_statistics_average","example_statistics_practice","results_trick_errors_label","results_trick_hints_label","results_trick_skipped_label","results_first_time","results_share_best_time"]
            showMetrics(title:trickName(aggregate),metrics:zip(values,names).map{ResultMetric(value:$0.0,caption:ResultText.text($0.1))})
        }
    }
    private func showMetrics(title:String,metrics:[ResultMetric]) {
        guard presentedViewController==nil else{return}
        present(ResultDetailsViewController(title:title,metrics:metrics,settings:settings),animated:false)
    }
    private func rebuildOverview(total:PracticeAggregate,examples:[PracticeAggregate]) {
        overviewCards.arrangedSubviews.forEach{overviewCards.removeArrangedSubview($0);$0.removeFromSuperview()}
        overviewActions.arrangedSubviews.forEach{overviewActions.removeArrangedSubview($0);$0.removeFromSuperview()}
        let clean=total.attempts==0 ? "—":ResultText.format("example_statistics_clean_value",Int64(total.independentCount),String(format:"%.1f",locale:Locale.current,100*Double(total.independentCount)/Double(total.attempts)))
        let improved=examples.filter{($0.first ?? 0)>($0.best ?? .greatestFiniteMagnitude)}.count
        let values=[String(total.solved),String(examples.count),clean,ResultText.time(total.average),ResultText.duration(total.totalTime),String(improved),String(total.attempts),String(total.errors),String(total.hints),String(total.skipped)]
        let names=["example_statistics_solved","example_statistics_unique","example_statistics_clean","example_statistics_average","example_statistics_practice","example_statistics_improvements","statistics_attempts_card","results_trick_errors_label","results_trick_hints_label","results_trick_skipped_label"]
        overviewCards.addArrangedSubview(ResultMetricGrid(zip(values,names).map{ResultMetric(value:$0.0,caption:ResultText.text($0.1))},settings:settings))
        overviewCards.addArrangedSubview(ResultUI.label(ResultText.text("example_statistics_counts_note"),size:12,settings:settings,color:ResultPalette(settings).secondary))
        let items:[(Int,AppIcon)]=[(4,.recommendTricks),(3,.recommendExamples),(2,.statisticsTricks),(1,.statisticsExamples)]
        for (section,icon) in items {
            let key=ResultUI.button(Self.sectionTitle(section),icon:icon,settings:settings){[weak self] in guard let self else{return};router?.show(.statisticsList(section,selectedInput))}
            overviewActions.addArrangedSubview(key)
        }
        if landscape != true {overviewCards.addArrangedSubview(overviewActions)}
    }
    private func rebuildTableHeader() {
        guard [1,2].contains(section),!sessionOnly else{table.tableHeaderView=nil;return}
        let stack=ResultUI.stack(.vertical,spacing:8)
        let note=ResultUI.label(ResultText.text(section==2 && levelSelection.range ? "statistics_range_note":"example_statistics_note"),size:12,settings:settings,color:ResultPalette(settings).secondary)
        stack.addArrangedSubview(note)
        if !rows.isEmpty {stack.addArrangedSubview(ResultColumnsView(title:ResultText.text(section==1 ? "results_example":"results_trick"),values:[ResultText.text("results_first_time_header"),ResultText.text("results_share_best_time")],settings:settings,header:true))}
        table.tableHeaderView=stack;view.setNeedsLayout()
    }
    private func share() {
        guard presentedViewController == nil,!rows.isEmpty else { return }
        let sharedRows: [ResultShareRow] = rows.dropFirst(page*effectivePageSize).prefix(effectivePageSize).compactMap { row in
            switch row {
            case .example(let aggregate): return ResultShareRow(title:exampleName(aggregate),values:[ResultText.time(aggregate.first),ResultText.time(aggregate.best)])
            case .aggregate(let aggregate): return ResultShareRow(title:trickName(aggregate),values:[ResultText.time(aggregate.first),ResultText.time(aggregate.best)])
            default: return nil
            }
        }
        let subtitle=CatalogText.ui("input_\(selectedInput.rawValue)")+"\n"+(pageLabel.text ?? "")
        guard let image=ResultShareCard.make(title:Self.sectionTitle(section),subtitle:subtitle,headings:[ResultText.text(section==2 ? "results_trick":"results_example"),ResultText.text("results_first_time_header"),ResultText.text("results_share_best_time")],rows:sharedRows,settings:settings) else { return }
        let caption = Self.sectionTitle(section) + "\n" + subtitle + "\n\n" + ResultShareCard.links
        let sheet=UIActivityViewController(activityItems:[image,caption],applicationActivities:nil)
        sheet.popoverPresentationController?.sourceView=body;sheet.popoverPresentationController?.sourceRect=CGRect(x:body.bounds.midX,y:0,width:1,height:1)
        present(sheet,animated:false)
    }
}
