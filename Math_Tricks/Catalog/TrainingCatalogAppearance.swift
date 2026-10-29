import UIKit

/// ResColors.getGroupColor and AuroraPalette.foreground from Android.
enum TrainingCatalogAppearance {
    static let changed = Notification.Name("trainingCatalogAppearanceChanged")

    static func color(_ groupID: Int) -> UIColor {
        let colors: [UInt32] = [0x00838F, 0x797100, 0x1565C0, 0x992424, 0x6A1B9A, 0x773500, 0x9E6202, 0x2E7D32]
        return ThemeColor.rgb(colors.indices.contains(groupID - 1) ? colors[groupID - 1] : colors[0])
    }

    static func foreground(_ groupID: Int, settings: AppSettings) -> UIColor {
        settings.theme == .aurora ? .white : color(groupID)
    }

    static func settings(_ settings: AppSettings, groupID: Int?, enabled: Bool? = nil) -> AppSettings {
        guard let groupID, enabled ?? (settings.tricksCategoryColors != false) else { return settings }
        var value = settings
        value.accentColorHex = ThemeColor.hexString(color(groupID))
        return value
    }
}
