import UIKit
import CoreText

/// Android sp values before system or user scaling. Never apply both scales.
enum AppTextRole {
    case gameMode,gameUtility,multiplayerResult,byHeartExample,playerExpression,playerNumber,caption, body, title, settingsTitle, menu, dialog, expression, number, score, scheme, menuCaption, headCount, dailyCaption, trickName, catalogTrick, catalogGroup, levelNumber, detail

    var size: CGFloat {
        switch self {
        case .gameUtility:return 17
        case .multiplayerResult,.byHeartExample:return 25
        case .playerExpression:return 33
        case .playerNumber:return 14
        case .caption, .menuCaption: return 12
        case .headCount: return 20
        case .dailyCaption: return 13
        case .detail: return 14
        case .trickName: return 15
        case .catalogTrick: return 20
        case .catalogGroup: return 25
        case .settingsTitle: return 18
        case .levelNumber: return 20
        case .body: return 16
        case .gameMode, .title, .dialog: return 20
        case .menu: return 30
        case .number: return 21
        case .expression: return 40
        case .score: return 22
        case .scheme: return 20
        }
    }

    var textStyle: UIFont.TextStyle {
        switch self {
        case .caption, .menuCaption, .dailyCaption: return .caption1
        case .title, .catalogGroup, .settingsTitle: return .headline
        case .menu, .expression, .number: return .title1
        default: return .body
        }
    }
}

enum AppTypography {
    private static let registration: Void = {
        // Roboto's variable font includes Light. A separate static Light font
        // collides with that named instance in Core Text on iOS 16 (error 305).
        for name in ["Roboto-Regular", "roboto_mono"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                NSLog("Missing bundled font: %@", name)
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error), let error {
                NSLog("Font registration: %@", String(describing: error.takeRetainedValue()))
            }
        }
    }()

    static func font(_ role: AppTextRole, settings: AppSettings, traits: UITraitCollection,
                     weight: CGFloat = 400) -> UIFont {
        _ = registration
        let resource: String?
        switch role {
        case .gameMode:resource="theme_alert_dialog_b_text"
        case .multiplayerResult:resource="theme_alert_dialog_timer_end_tv_score"
        case .byHeartExample:resource="theme_alert_dialog_level_complete_tv_score"
        case .playerExpression:resource="player_tv_expression"
        case .playerNumber:resource=nil
        case .menu: resource="theme_activity_game_b_text"
        case .title: resource="theme_activity_game_tv_level"
        case .menuCaption: resource="theme_activity_main_b_rate"
        case .headCount: resource="theme_activity_game_tv_expressions_count"
        case .trickName: resource="theme_activity_game_tv_trick_name"
        case .catalogTrick: resource="theme_activity_tricks_tv_trick"
        case .catalogGroup: resource="theme_activity_tricks_tv_group"
        case .levelNumber: resource="theme_activity_levels_b_levels_text"
        case .expression: resource="theme_activity_game_tv_expression"
        case .score: resource="theme_activity_game_tv_score"
        default: resource=nil
        }
        let size=resource.map{AndroidDimensions.value($0,traits:traits,fallback:role.size)} ?? role.size
        let name = role == .scheme ? "RobotoMono-Regular" : "Roboto-Regular"
        var descriptor = UIFontDescriptor(name: name, size: size)
        if role != .scheme {
            descriptor = descriptor.addingAttributes([
                UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [NSNumber(value: 0x77676874): weight]
            ])
        }
        let base = UIFont(descriptor: descriptor, size: size)
        if settings.useSystemFontSize {
            return UIFontMetrics(forTextStyle: role.textStyle).scaledFont(for: base, maximumPointSize: size * 1.3, compatibleWith: traits)
        }
        return base.withSize(size * CGFloat(min(200, max(80, settings.fontSizePercent))) / 100)
    }
}

final class AppLabel: UILabel {
    var role: AppTextRole { didSet { if role != oldValue { apply(settings: settings) } } }
    private var settings = AppSettings()
    private let weight: CGFloat

    init(_ role: AppTextRole = .body, weight: CGFloat = 400) {
        self.role = role
        self.weight = weight
        super.init(frame: .zero)
        numberOfLines = 0
        // Scaling is owned by AppTypography, including manual size mode.
        adjustsFontForContentSizeCategory = false
        textColor = .black
        apply(settings: settings)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(settings: AppSettings) {
        self.settings = settings
        font = AppTypography.font(role, settings: settings, traits: traitCollection, weight: weight)
        invalidateIntrinsicContentSize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory || previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass || previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass || previousTraitCollection?.displayScale != traitCollection.displayScale) {
            apply(settings: settings)
        }
    }
}
