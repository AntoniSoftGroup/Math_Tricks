import UIKit
import Combine

/// Temporary destinations for checking the shell before the real screens migrate.
final class ShellScreenViewController: AppDuoViewController {
    let route: AppRoute
    private weak var router: AppRouter?
    private let contentStack = UIStackView()
    private let data: AppDataStore
    private lazy var header = AppHeaderView(title: route.title, onBack: { [weak self] in
        self?.router?.goBack()
    })
    private var buttons: [AppButton] = []
    private var labels: [AppLabel] = []
    private var palette = ThemePalette(settings: AppSettings())
    private var progressObservation: AnyCancellable?

    init(route: AppRoute, router: AppRouter, data: AppDataStore) {
        self.route = route
        self.router = router
        self.data = data
        super.init(nibName: nil, bundle: nil)
        title = route.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        viewIfLoaded?.usesDuoLayout == true || UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
    }

    override func loadView() { view = AppDuoContentView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.accessibilityIdentifier = "screen.\(route)"

        let scrollView = AppScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        view.addSubview(header)
        view.addSubview(scrollView)

        let safeArea = view.appContentLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: safeArea.topAnchor),
            header.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
        populateContent()
        progressObservation = data.$snapshot.sink { [weak self] progress in
            guard let self else { return }
            let settings = progress?.settings ?? AppSettings()
            self.palette = ThemePalette(settings: settings)
            self.setNeedsStatusBarAppearanceUpdate()
            self.header.apply(settings: settings)
            self.buttons.forEach { $0.apply(settings: settings) }
            self.labels.forEach { $0.apply(settings: settings); $0.textColor = self.palette.secondary }

        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if palette.theme.isClassic { return ThemeColor.luminance(palette.systemBar) > 0.5 ? .darkContent : .lightContent }
        return palette.theme.isDark ? .lightContent : .darkContent
    }

    private func populateContent() {
        switch route {
        case .settings:
            addButton(for: .appearance)
        default:
            let label = AppLabel()
            label.text = MainText.text("unavailable")
            label.textColor = .darkGray
            label.numberOfLines = 0
            label.textAlignment = .center
            labels.append(label)
            contentStack.addArrangedSubview(label)
        }
    }

    private func addButton(for destination: AppRoute) {
        let icon: AppIcon
        switch destination {
        case .gameModes: icon = .singlePlayer
        case .tricks: icon = .training
        case .multiplayer: icon = .multiplayer
        case .byHeart: icon = .byHeart
        case .appearance: icon = .appearance
        default: icon = .settings
        }
        let button = AppButton(title: destination.title, icon: icon) { [weak self] in
            self?.router?.show(destination)
        }
        button.accessibilityIdentifier = "open.\(destination)"
        buttons.append(button)
        contentStack.addArrangedSubview(button)
    }
}
