import UIKit

final class ByHeartViewController: ThemedViewController, UITableViewDataSource, UITableViewDelegate {
    private let number: Int?
    private let table = AppTableView(frame: .zero, style: .plain)
    private var saved: [LevelKey: LevelProgress] = [:]
    private var loaded = false
    private var completedLabel:AppLabel!
    private var leaderboardButton:AppButton?
    private var readTask: Task<Void, Never>?
    init(number: Int? = nil, router: AppRouter, data: AppDataStore) {
        self.number = number
        super.init(title: number.map { "\(AppRoute.byHeart.title) · \($0)" } ?? AppRoute.byHeart.title, router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { readTask?.cancel() }
    override func buildContent() {
        view.accessibilityIdentifier = number.map { "screen.byHeartLevels.\($0)" } ?? "screen.byHeart"
        table.translatesAutoresizingMaskIntoConstraints = false; table.backgroundColor = .clear
        table.dataSource = self; table.delegate = self; table.rowHeight = UITableView.automaticDimension; table.estimatedRowHeight = 70
        table.register(ByHeartRowCell.self, forCellReuseIdentifier: "number")
        let column = UIStackView(); column.axis = .vertical; column.translatesAutoresizingMaskIntoConstraints = false
        header.setTitle(AppRoute.byHeart.title)
        if number==nil {
            completedLabel=label("—",role:.headCount);completedLabel.numberOfLines=1;completedLabel.textAlignment = .right
            let leaderboard=button(MainText.text("leaderboard"),icon:.leaderboard,kind:.icon){[weak self] in self?.router?.show(.byHeartLeaderboard)}
            leaderboard.widthAnchor.constraint(equalToConstant:max(48,min(40,AppIcon.leaderboard.image?.size.width ?? 40)+24)).isActive=true
            completedLabel.setContentHuggingPriority(.required,for:.horizontal)
            leaderboardButton=leaderboard
            let counts=UIStackView(arrangedSubviews:[leaderboard,completedLabel]);counts.alignment = .center;counts.spacing=4
            counts.setContentHuggingPriority(.required,for:.horizontal)
            counts.setContentCompressionResistancePriority(.required,for:.horizontal)
            header.setAccessoryView(counts,trailingInset:0)
        }
        column.addArrangedSubview(table); body.addSubview(column)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: body.topAnchor), column.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            column.leadingAnchor.constraint(equalTo: body.leadingAnchor), column.trailingAnchor.constraint(equalTo: body.trailingAnchor)
        ])
    }
    override func update(_ progress: ProgressState?) {
        table.separatorStyle = .none
        leaderboardButton?.apply(settings:settings,tint:palette.theme == .light ? .white:palette.text)
        guard progress != nil else { return }
        readTask?.cancel()
        readTask = Task { [weak self] in
            guard let self else { return }
            do {
                let values = try await data.allLevels(scope: .multiplication)
                guard !Task.isCancelled else { return }
                saved = Dictionary(uniqueKeysWithValues: values.map { ($0.key, $0) }); loaded = true
                completedLabel?.text="\(values.filter{$0.bestScore>0}.count)/2058"
                completedLabel?.textColor=palette.theme == .light ? .white:palette.text
                table.reloadData()
            } catch {
                guard !Task.isCancelled else { return }
                showError(error, reading: true, retry: { [weak self] in self?.update(self?.data.snapshot) })
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { number == nil ? 98 : 21 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier:"number",for:indexPath) as! ByHeartRowCell
        if let number {
            let level=indexPath.row+1
            let interval=GameSession.multiplicationInterval(stage:level)
            let value=saved[LevelKey(scope:.multiplication,parentID:number,level:level)]
            let unlocked=AppConstants.unlockAllLevels || level==1 || level==21 || value?.unlocked==true
            cell.configure(level:String(format:"%02d.",level),number:number,range:interval,score:unlocked ? String(value?.bestScore ?? 0):"",icon:unlocked ? "ic_th_light_b_star_\(value?.bestStars ?? 0)":"ic_th_light_b_lock",highlight:level==21,settings:settings)
        } else {
            let value=indexPath.row+2
            let complete=saved.values.filter{$0.key.parentID==value && $0.bestScore>0}.count
            cell.configure(level:"",number:value,range:2...99,score:loaded ? "\(complete)/21":"—",icon:complete == 21 ? "ic_th_light_b_star":nil,highlight:false,settings:settings)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard loaded else { return }
        guard let number else { router?.show(.byHeartLevels(indexPath.row + 2)); return }
        let level = indexPath.row + 1
        guard AppConstants.unlockAllLevels || level == 1 || level == 21 || saved[LevelKey(scope: .multiplication, parentID: number, level: level)]?.unlocked == true else { return }
        if level == 21 {
            router?.show(.game(GameConfiguration(mode: .byHeart, difficulty: 1, trickIDs: [3], exampleCount: 50, multiplicationNumber: number, multiplicationLevel: level)))
        } else { router?.show(.byHeartExamples(number: number, level: level)) }
    }
}
