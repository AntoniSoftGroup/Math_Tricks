import UIKit

enum AppIcon: String {
    case resultShare="ic_result_share", resultRetry="ic_result_retry", resultNext="ic_result_next", resultBack="ic_result_back"
    case statisticsExamples="ic_examples_statistics", statisticsTricks="ic_tricks_statistics"
    case recommendExamples="ic_examples_recommendations", recommendTricks="ic_tricks_recommendations"
    case statisticsDelete="ic_statistics_delete"
    case voiceOff="ic_th_b_tts_off"
    case voiceOn="ic_th_b_tts_on"
    case voiceBoth="ic_th_b_tts_both"
    case inputDigits="ic_th_light_iw_numpad_change_numpad"
    case inputChoices="ic_th_light_iw_numpad_change_block"
    case up="theme_light_b_arrow_up_off"
    case down="theme_light_b_arrow_down_off"
    case modeSingle = "ic_th_light_b_gt_single"
    case modeMinute = "ic_th_light_b_gt_minute"
    case modeSpeed = "ic_th_light_b_gt_time"
    case modeNoTime = "ic_th_light_b_gt_non_time"
    case zoomIn = "ic_zoom_in"
    case zoomOut = "ic_zoom_out"
    case hint = "ic_hint_vector"
    case skip = "ic_skip_next_vector"
    case correct = "ic_th_b_numpad_change_bool_true"
    case incorrect = "ic_th_b_numpad_change_bool_false"
    case changeInput = "ic_th_b_numpad_change"
    case previous = "ic_step_prev"
    case next = "ic_step_next"
    case forward = "ic_th_dark_b_next"
    case backward = "ic_th_light_b_back"
    case exportFile = "ic_file_backup_save"
    case importFile = "ic_file_backup_restore"
    case exitConfirmation = "ic_th_light_b_settings_exit"
    case sound = "ic_th_light_b_settings_sound"
    case vibration = "ic_th_light_b_settings_vibration"
    case wrongSignal = "ic_th_light_b_settings_wrong_input"
    case fontSize = "ic_th_light_b_settings_font_size"
    case numpad = "ic_th_light_b_settings_numpad"
    case resetProgress = "ic_settings_reset_progress"
    case versus = "ic_th_b_multiplayer_vs"
    case cooperative = "ic_th_b_multiplayer_plus"
    case tableList = "ic_table_list_view"
    case keyboardExpand = "ic_arrow_up_small"
    case keyboardCollapse = "ic_arrow_down_small"
    case solveAll = "ic_solve_equal"
    case solveStep = "ic_steps_arrow_up"
    case table = "ic_table_grid_9"
    case levels = "ic_rule_levels"
    case bell = "ic_bell"
    case daily = "day_streak_play"
    case statistics = "ic_menu_statistics"
    case noAds = "ic_th_light_b_no_ads"
    case pro = "icon_final_pro_128"
    case star = "ic_th_light_b_star"
    case support = "ic_th_light_b_support"
    case more = "ic_more"
    case instagram = "icon_instagram"
    case backspace = "ic_th_light_b_delete"
    case ageLogo = "ic_launcher_age_screen_free"
    case singlePlayer = "ic_th_light_b_single_player"
    case multiplayer = "ic_th_light_b_two_players"
    case training = "ic_th_light_b_training"
    case byHeart = "ic_th_light_b_by_heart"
    case settings = "ic_settings_gear"
    case appearance = "ic_th_light_b_settings_theme"
    case back = "ic_th_dark_b_back"
    case coins = "ic_th_light_b_money_total"
    case graphSmooth = "ic_th_light_b_graph_cube"
    case intervalMore = "ic_th_light_b_more"
    case graph = "ic_th_light_b_graph"
    case leaderboard = "ic_th_light_b_leaderboard"
    case retry = "ic_th_dark_b_retry"
    case close = "ic_close"
    case buyCoins = "ic_th_light_b_money_buy"
    case shop = "ic_th_dark_b_shop"
    case lock = "ic_th_light_b_lock"
    case language = "ic_th_light_b_settings_language"
    case savedProgress = "ic_settings_cloud"
    case cloudUpload = "ic_cloud_backup_upload"
    case cloudDownload = "ic_cloud_backup_download"
    case cloudUser = "ic_cloud_user"

    case linkAccount = "person.badge.plus"
    case signOut = "rectangle.portrait.and.arrow.right"
    case deleteAccount = "person.crop.circle.badge.minus"
    case localProgress = "iphone"

    var image: UIImage? {
        switch self {
        case .linkAccount,.signOut,.deleteAccount,.localProgress:
            return UIImage(systemName:rawValue,withConfiguration:UIImage.SymbolConfiguration(pointSize:24,weight:.regular))
        default: break
        }
        let image=UIImage(named:rawValue)?.withRenderingMode(.alwaysOriginal)
        switch self {case .back,.previous,.next,.forward,.backward:return image?.imageFlippedForRightToLeftLayoutDirection();default:return image}
    }
}

/// Original Android nine-patches, with their one-pixel metadata border removed.
/// Caps come from the stretch markers, so shadows and corners retain their size.
enum AndroidImages {
    static let gameProgressTrack = ninePatch("theme_light_progress_bar_black")
    static let gameProgressFill = ninePatch("theme_light_progress_bar_black_light")
    static let darkGameProgressTrack = ninePatch("theme_dark_progress_bar_black")
    static let darkGameProgressFill = ninePatch("theme_dark_progress_bar_black_dark")
    static let catalogGroup = ninePatch("bg_th_light_elv_item_off")
    static let darkCatalogGroup = ninePatch("bg_th_dark_elv_item_off")
    static func catalogIndicator(expanded: Bool, dark: Bool) -> UIImage? {
        let name = "theme_\(dark ? "dark" : "light")_group_indicator_\(expanded ? "down" : "up")"
        guard let url = Bundle.main.url(forResource: name + ".9", withExtension: "png"),
              let source = UIImage(contentsOfFile: url.path)?.cgImage,
              let cropped = source.cropping(to: CGRect(x: 1, y: 1, width: source.width - 2, height: source.height - 2)) else { return nil }
        return UIImage(cgImage: cropped, scale: 2, orientation: .up)
    }
    static let button = ninePatch("bg_th_light_b_main_off")
    static let pressedButton = ninePatch("bg_th_light_b_main_on")
    static let darkButton = ninePatch("bg_th_dark_b_main_off")
    static let darkPressedButton = ninePatch("bg_th_dark_b_main_on")

    static let dialog = ninePatch("theme_dark_border_expression_dark", scale: 1)

    private static func ninePatch(_ name: String, scale: CGFloat = 2) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name + ".9", withExtension: "png"),
              let data = try? Data(contentsOf: url), let source = UIImage(data: data)?.cgImage,
              source.width > 2, source.height > 2 else {
            NSLog("Missing Android nine-patch: %@", name)
            return nil
        }
        let width = source.width, height = source.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let valid = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height,
                                          bitsPerComponent: 8, bytesPerRow: width * 4,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard valid, let cropped = source.cropping(to: CGRect(x: 1, y: 1, width: width - 2, height: height - 2)) else { return nil }
        func isMarker(_ x: Int, _ y: Int) -> Bool {
            let index = (y * width + x) * 4
            return bytes[index + 3] > 127 && bytes[index] < 32 && bytes[index + 1] < 32 && bytes[index + 2] < 32
        }
        let horizontal = (1..<(width - 1)).filter { isMarker($0, 0) }
        let vertical = (1..<(height - 1)).filter { isMarker(0, $0) }
        guard let left = horizontal.first, let right = horizontal.last,
              let top = vertical.first, let bottom = vertical.last else {
            NSLog("Invalid Android stretch markers: %@", name)
            return nil
        }
        return UIImage(cgImage: cropped, scale: scale, orientation: .up).resizableImage(
            withCapInsets: UIEdgeInsets(top: CGFloat(top - 1) / scale, left: CGFloat(left - 1) / scale,
                                       bottom: CGFloat(height - 2 - bottom) / scale, right: CGFloat(width - 2 - right) / scale),
            resizingMode: .stretch)
    }
}
