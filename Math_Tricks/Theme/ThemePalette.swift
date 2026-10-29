import UIKit
import Metal

enum ThemeMotion {
    static let supported: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        // Apple GPU family 6 starts with A13; A12 and earlier keep static themes.
        return MTLCreateSystemDefaultDevice()?.supportsFamily(.apple6) == true
        #endif
    }()
}

extension AppTheme {
    static var pickerOrder: [AppTheme] { [.aurora, .neon, .lightAurora, .darkAurora, .light, .dark] }
    var name: String {
        CatalogText.ui("theme_\(rawValue)")
    }
    var isDark: Bool { self == .dark || self == .darkAurora || self == .aurora || self == .neon }
    var isClassic: Bool { self == .light || self == .dark }
    var isAnimated: Bool { self == .aurora || self == .neon }
    var intensityRange: ClosedRange<CGFloat> {
        self == .aurora ? 0.5...1 : (self == .light || self == .lightAurora ? 0.4...1 : 0...0.6)
    }
    var defaultIntensity: Int {
        if self == .aurora { return 40 }
        let range = intensityRange
        return Int(((0.5 - range.lowerBound) / (range.upperBound - range.lowerBound) * 100).rounded())
    }
    func mappedIntensity(_ percent: Int) -> CGFloat {
        let range = intensityRange
        return range.lowerBound + (range.upperBound - range.lowerBound) * CGFloat(min(100, max(0, percent))) / 100
    }
}

/// RGB mixing, HSL hue transfer, HSV shading and WCAG luminance mirror Android ColorUtils.
enum ThemeColor {
    static func hex(_ hex: String) -> UIColor {
        let value = UInt32(hex, radix: 16) ?? 0x0D47A1
        return rgb(value)
    }
    static func rgb(_ value: UInt32, alpha: CGFloat = 1) -> UIColor {
        UIColor(red: CGFloat(value >> 16 & 255) / 255, green: CGFloat(value >> 8 & 255) / 255,
                blue: CGFloat(value & 255) / 255, alpha: alpha)
    }
    static func components(_ color: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    static func hexString(_ color: UIColor) -> String {
        let (r,g,b,_) = components(color)
        return String(format: "%02X%02X%02X", Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded()))
    }
    static func blend(_ from: UIColor, _ to: UIColor, _ amount: CGFloat) -> UIColor {
        let t = min(1, max(0, amount)), (r,g,b,a) = components(from), (x,y,z,w) = components(to)
        return UIColor(red: r + (x-r)*t, green: g + (y-g)*t, blue: b + (z-b)*t, alpha: a + (w-a)*t)
    }
    static func hsv(_ color: UIColor) -> (CGFloat, CGFloat, CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        return (h,s,v)
    }
    static func shade(_ color: UIColor, _ scale: CGFloat) -> UIColor {
        let (h,s,v) = hsv(color)
        return UIColor(hue: h, saturation: s, brightness: min(1,max(0,v * scale)), alpha: 1)
    }
    static func intensity(_ base: UIColor, _ mapped: CGFloat) -> UIColor {
        mapped <= 0.5 ? blend(.white, base, mapped * 2) : blend(base, .black, (mapped - 0.5) * 2)
    }
    static func hsl(_ color: UIColor) -> (CGFloat, CGFloat, CGFloat) {
        let (r,g,b,_) = components(color)
        let maximum = max(r,g,b), minimum = min(r,g,b), delta = maximum - minimum
        let light = (maximum + minimum) / 2
        guard delta > 0 else { return (0,0,light) }
        var hue: CGFloat
        if maximum == r { hue = ((g-b)/delta).truncatingRemainder(dividingBy: 6) }
        else if maximum == g { hue = (b-r)/delta + 2 }
        else { hue = (r-g)/delta + 4 }
        hue = (hue / 6 + 1).truncatingRemainder(dividingBy: 1)
        return (hue, delta / (1 - abs(2 * light - 1)), light)
    }
    static func fromHSL(_ h: CGFloat, _ s: CGFloat, _ l: CGFloat) -> UIColor {
        let c = (1 - abs(2*l-1))*s, hh = h*6
        let x = c * (1 - abs(hh.truncatingRemainder(dividingBy: 2)-1)), m = l-c/2
        let rgb: (CGFloat,CGFloat,CGFloat)
        switch Int(hh) % 6 {
        case 0: rgb = (c,x,0)
        case 1: rgb = (x,c,0)
        case 2: rgb = (0,c,x)
        case 3: rgb = (0,x,c)
        case 4: rgb = (x,0,c)
        default: rgb = (c,0,x)
        }
        return UIColor(red: rgb.0+m, green: rgb.1+m, blue: rgb.2+m, alpha: 1)
    }
    static func tone(_ base: UInt32, accent: UIColor) -> UIColor {
        let (h,s,_) = hsl(accent), (_,bs,bl) = hsl(rgb(base))
        return fromHSL(h, s < 0.01 ? 0 : bs, bl)
    }
    static func luminance(_ color: UIColor) -> CGFloat {
        let (r,g,b,_) = components(color)
        func linear(_ v: CGFloat) -> CGFloat { v <= 0.04045 ? v / 12.92 : pow((v+0.055)/1.055, 2.4) }
        return 0.2126*linear(r) + 0.7152*linear(g) + 0.0722*linear(b)
    }
}

struct ThemePalette {
    let theme: AppTheme
    let selected: UIColor
    let intensity: Int
    var accent: UIColor { theme == .aurora ? .white : selected }
    var usesAccentHeaderIcons: Bool { theme == .lightAurora || theme == .darkAurora }
    func gameStars(_ count: Int) -> UIImage? {
        let image = UIImage(named: "ic_th_dark_b_star_\(count)")
        return usesAccentHeaderIcons ? image?.withTintColor(selected, renderingMode: .alwaysOriginal) : image?.withRenderingMode(.alwaysOriginal)
    }
    var switchOnTint: UIColor { theme == .aurora ? UIColor.white.withAlphaComponent(0.3) : accent }
    var background: UIColor {
        switch theme {
        case .light: return ThemeColor.rgb(0xF3F3F3)
        case .dark: return .black
        case .lightAurora: return ThemeColor.tone(0xFAFCFF, accent: selected)
        case .darkAurora: return ThemeColor.rgb(0x080A10)
        case .aurora: return ThemeColor.rgb(0x071B3D)
        case .neon: return ThemeColor.rgb(0x02030A)
        }
    }
    var header: UIColor {
        switch theme {
        case .light: return selected
        case .dark: return ThemeColor.shade(selected, 0.3)
        case .lightAurora: return ThemeColor.tone(0xF2F6FC, accent: selected)
        case .darkAurora: return ThemeColor.rgb(0x10131C)
        case .aurora: return UIColor.black.withAlphaComponent(22/255)
        case .neon: return ThemeColor.rgb(0x040915, alpha: 173/255)
        }
    }
    var headerText: UIColor {
        switch theme {
        case .light, .aurora, .neon: return .white
        case .dark: return ThemeColor.rgb(0xAAAAAA)
        case .lightAurora: return ThemeColor.rgb(0x172B45)
        case .darkAurora: return ThemeColor.rgb(0xEEF2FF)
        }
    }
    var systemBar: UIColor {
        if theme.isClassic { return ThemeColor.shade(header, 0.8) }
        if theme.isAnimated { return .clear }
        let (h,s,l) = ThemeColor.hsl(header)
        return ThemeColor.fromHSL(h,s,max(0,l-0.02))
    }
    var text: UIColor {
        switch theme {
        case .light: return .black
        case .dark: return ThemeColor.rgb(0xAAAAAA)
        case .lightAurora: return ThemeColor.rgb(0x172B45)
        case .darkAurora: return ThemeColor.rgb(0xEEF2FF)
        default: return .white
        }
    }
    var secondary: UIColor {
        switch theme {
        case .light: return .darkGray
        case .dark: return ThemeColor.rgb(0xAAAAAA)
        case .lightAurora: return ThemeColor.rgb(0x52647B)
        case .darkAurora: return ThemeColor.rgb(0xBFC6D7)
        case .aurora: return UIColor.white.withAlphaComponent(230/255)
        case .neon: return ThemeColor.rgb(0x9DA6BB)
        }
    }
    var surface: UIColor {
        switch theme {
        case .light: return .white
        case .dark: return ThemeColor.rgb(0x151515)
        case .lightAurora: return UIColor.white.withAlphaComponent(245/255)
        case .darkAurora: return ThemeColor.rgb(0x141720)
        case .aurora: return ThemeColor.rgb(0x020A14, alpha: 40/255)
        case .neon: return ThemeColor.rgb(0x0A1220, alpha: 184/255)
        }
    }
    var dialogBackground: UIColor { surface.withAlphaComponent(1) }
    var divider: UIColor {
        switch theme {
        case .light: return ThemeColor.rgb(0xCCCCCC)
        case .dark: return ThemeColor.rgb(0x444444)
        case .lightAurora: return ThemeColor.rgb(0xDEE6F0)
        case .darkAurora: return ThemeColor.rgb(0x303543)
        case .aurora: return UIColor.white.withAlphaComponent(48/255)
        case .neon: return selected.withAlphaComponent(68/255)
        }
    }
    init(settings: AppSettings) {
        theme = settings.theme ?? .light
        selected = ThemeColor.hex(settings.accentColorHex ?? "0D47A1")
        intensity = settings.theme == nil ? theme.defaultIntensity : settings.themeIntensity
    }
}
