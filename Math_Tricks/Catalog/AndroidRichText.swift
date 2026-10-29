import UIKit
import CoreText

/// Preserves Android's HTML, superscripts and worked-example colours.
enum AndroidRichText {
    private static let cache = NSCache<NSString, NSAttributedString>()
    /// Main-menu counters use only inline small/bold/italic markup. Parsing
    /// these directly avoids starting the HTML importer after every answer.
    static func inline(_ html:String,font:UIFont,color:UIColor)->NSAttributedString {
        struct Style { var scale:CGFloat=1;var bold=false;var italic=false }
        var style=Style()
        var stack:[(String,Style)]=[]
        let result=NSMutableAttributedString(string:"")
        func append(_ text:String) {
            guard !text.isEmpty else{return}
            let descriptor=font.fontDescriptor.addingAttributes([
                UIFontDescriptor.AttributeName(rawValue:kCTFontVariationAttribute as String):[NSNumber(value:0x77676874):style.bold ? 700 : 400]
            ])
            var attributes:[NSAttributedString.Key:Any]=[.font:UIFont(descriptor:descriptor,size:font.pointSize*style.scale),.foregroundColor:color]
            if style.italic {attributes[.obliqueness]=0.15}
            result.append(NSAttributedString(string:plain(text),attributes:attributes))
        }
        let source=html as NSString
        let tags=(try? NSRegularExpression(pattern:"<[^>]*>"))?.matches(in:html,range:NSRange(location:0,length:source.length)) ?? []
        var cursor=0
        for match in tags {
            append(source.substring(with:NSRange(location:cursor,length:match.range.location-cursor)))
            let tag=source.substring(with:match.range).lowercased().trimmingCharacters(in:CharacterSet(charactersIn:"<> /"))
            if tag == "br" {append("\n")}
            else if source.substring(with:match.range).hasPrefix("</") {
                if let index=stack.lastIndex(where:{$0.0==tag}) {style=stack[index].1;stack.removeSubrange(index...)}
            } else if ["small","b","strong","i","em"].contains(tag) {
                stack.append((tag,style))
                if tag == "small" {style.scale *= 0.8}
                if tag == "b" || tag == "strong" {style.bold=true}
                if tag == "i" || tag == "em" {style.italic=true}
            }
            cursor=NSMaxRange(match.range)
        }
        append(source.substring(from:cursor))
        return result
    }
    static func attributed(_ html: String, font: UIFont, color: UIColor) -> NSAttributedString {
        let rgba = color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        rgba.getRed(&r, green: &g, blue: &b, alpha: &a)
        let hex = String(format: "#%02x%02x%02x", Int(r * 255), Int(g * 255), Int(b * 255))
        let key = "\(font.fontName)|\(font.pointSize)|\(hex)|\(html)" as NSString
        if let value = cache.object(forKey: key) { return value }
        let document = "<html><head><meta charset='utf-8'><style>body {font-family: 'Roboto', sans-serif; font-size: \(font.pointSize)px; color: \(hex);} </style></head><body>\(html)</body></html>"
        let value = (try? NSAttributedString(data: Data(document.utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)) ?? NSAttributedString(string: html, attributes: [.font: font, .foregroundColor: color])
        cache.countLimit = 160
        cache.setObject(value, forKey: key)
        return value
    }
    static func plain(_ html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&nbsp;", with: " ")
    }
}

final class CatalogCell: AppListCell {
    private let name = UILabel()
    private let icon = UIImageView()
    private let selection = UIButton(type: .custom)
    private let status = UILabel()
    var onToggle: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        name.numberOfLines = 0
        icon.contentMode = .scaleAspectFit
        status.textAlignment = .right
        let row = UIStackView(arrangedSubviews: [icon, name, status, selection])
        row.axis = .horizontal; row.spacing = 8; row.alignment = .center; row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8), row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12), row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            icon.widthAnchor.constraint(equalToConstant: 30), icon.heightAnchor.constraint(equalToConstant: 30),
            selection.widthAnchor.constraint(equalToConstant: 48), selection.heightAnchor.constraint(equalToConstant: 48),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        status.setContentCompressionResistancePriority(.required, for: .horizontal)
        selection.addAction(UIAction { [weak self] _ in self?.onToggle?() }, for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(title: String, iconName: String?, settings: AppSettings, selected: Bool?, unlocked: Bool = true, expanded: Bool = false, groupRow: Bool = false) {
        applyHighlight(settings: settings)
        let palette = ThemePalette(settings: settings)
        let font = AppTypography.font(groupRow ? .title:.trickName, settings: settings, traits: traitCollection)
        name.attributedText = AndroidRichText.attributed(title, font: font, color: palette.text)
        icon.image = iconName.flatMap { UIImage(named: $0) }?.withTintColor(palette.accent, renderingMode: .alwaysOriginal)
        icon.isHidden = iconName == nil
        selection.isHidden = selected == nil
        selection.setImage(selected.map { UIImage(named: $0 ? "ic_th_light_cb_trick_on" : "ic_th_light_cb_trick_off")?.withTintColor(palette.accent, renderingMode: .alwaysOriginal) } ?? nil, for: .normal)
        selection.accessibilityLabel = AndroidRichText.plain(title)
        selection.accessibilityTraits = selected == true ? [.button, .selected] : .button
        status.text = selected == nil ? (groupRow ? (expanded ? "−" : "+") : "") : unlocked ? "" : "200"
        status.font = AppTypography.font(.caption, settings: settings, traits: traitCollection)
        status.textColor = palette.secondary
        if !unlocked { icon.image = UIImage(named: "ic_th_light_b_lock")?.withTintColor(palette.accent, renderingMode: .alwaysOriginal); icon.isHidden = false }
        accessibilityLabel = AndroidRichText.plain(title) + (unlocked ? "" : ", " + CatalogText.ui("locked"))
        contentView.backgroundColor = groupRow ? palette.header.withAlphaComponent(0.45) : .clear
    }
}
