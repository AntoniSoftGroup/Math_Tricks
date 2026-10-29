import UIKit

final class MultiplicationTableViewController: ThemedViewController {
    private let canvas = MultiplicationTableCanvas()
    private let scroll = AppScrollView()
    private let content = UIView()
    private var canvasCenterY: NSLayoutConstraint!
    private var canvasTop: NSLayoutConstraint!
    private var canvasWidth: NSLayoutConstraint!
    private var canvasHeight: NSLayoutConstraint!
    private var list = UserDefaults.standard.bool(forKey: "table.listView")
    private var toggle: AppButton!
    private let heading = AppLabel(.settingsTitle,weight:700)
    override func buildContent() {
        view.accessibilityIdentifier = "screen.multiplicationTable"
        heading.text = CatalogText.ui("multiplication_table"); heading.numberOfLines = 1
        heading.adjustsFontSizeToFitWidth = true; heading.minimumScaleFactor = 0.6
        header.replaceTitle(with: heading)
        toggle = button("",icon:.tableList,kind:.icon) { [weak self] in
            guard let self else { return }
            list.toggle(); UserDefaults.standard.set(list,forKey:"table.listView")
            scroll.setContentOffset(.zero,animated:false); update(data.snapshot); view.setNeedsLayout()
        }
        toggle.setContentInsets(UIEdgeInsets(top:12,left:12,bottom:12,right:12),minimumHeight:48)
        toggle.widthAnchor.constraint(equalToConstant:48).isActive = true
        header.setAccessoryView(toggle)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.contentInsetAdjustmentBehavior = .never
        content.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(content)
        canvas.translatesAutoresizingMaskIntoConstraints = false; content.addSubview(canvas); body.addSubview(scroll)
        let fittingWidth = content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        let fittingHeight = content.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        fittingWidth.priority = .init(249); fittingHeight.priority = .init(249)
        canvasWidth = canvas.widthAnchor.constraint(equalToConstant:330)
        canvasHeight = canvas.heightAnchor.constraint(equalToConstant:330)
        NSLayoutConstraint.activate([canvasWidth,canvasHeight])
        canvasCenterY = canvas.centerYAnchor.constraint(equalTo: content.centerYAnchor)
        canvasTop = canvas.topAnchor.constraint(equalTo: content.topAnchor)
        canvasCenterY.isActive = !list; canvasTop.isActive = list
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: body.topAnchor), scroll.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: body.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor), fittingWidth, fittingHeight,
            canvas.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            canvas.leadingAnchor.constraint(greaterThanOrEqualTo: content.leadingAnchor), canvas.topAnchor.constraint(greaterThanOrEqualTo: content.topAnchor),
            canvas.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor)
        ])
    }
    override func update(_ progress: ProgressState?) {
        guard toggle != nil else { return }
        heading.apply(settings:settings); heading.textColor = palette.headerText
        toggle.setIcon(list ? .table : .tableList)
        toggle.accessibilityLabel = CatalogText.ui(list ? "table_grid" : "table_list")
        toggle.apply(settings:settings,tint:heading.textColor)
        layoutCanvas()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutCanvas()
    }
    private func layoutCanvas() {
        guard scroll.bounds.width > 0, scroll.bounds.height > 0 else { return }
        if canvasCenterY.isActive == list {
            canvasCenterY.isActive = false; canvasTop.isActive = false
            canvasCenterY.isActive = !list; canvasTop.isActive = list
        }
        let size = canvas.apply(settings: settings, list: list, viewport: scroll.bounds.size)
        if canvasWidth.constant != size.width || canvasHeight.constant != size.height {
            canvasWidth.constant = size.width; canvasHeight.constant = size.height
            scroll.setNeedsLayout(); scroll.layoutIfNeeded()
        }
    }
}
private final class MultiplicationTableCanvas: UIView {
    private var settings = AppSettings()
    private var list = false
    private var viewport = CGSize.zero
    private var cell = CGSize(width:28,height:28)
    private var size = CGSize(width:330,height:330)
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var intrinsicContentSize: CGSize { size }
    @discardableResult
    func apply(settings:AppSettings,list:Bool,viewport:CGSize) -> CGSize {
        guard self.settings != settings || self.list != list || self.viewport != viewport else { return size }
        self.settings = settings; self.list = list; self.viewport = viewport
        cell = CGSize(width:max(28,viewport.width/11-2),height:max(28,viewport.height/11-2))
        let font = AppTypography.font(.body,settings:settings,traits:traitCollection,weight:700)
        size = list ? CGSize(width:max(1,viewport.width),height:10 + 27 * (font.lineHeight + 4) + 44) : CGSize(width:(cell.width + 2) * 11,height:(cell.height + 2) * 11)
        backgroundColor = .clear; isAccessibilityElement = true; accessibilityLabel = CatalogText.ui("multiplication_table")
        invalidateIntrinsicContentSize(); setNeedsDisplay()
        return size
    }
    override func draw(_ rect:CGRect) {
        let palette = ThemePalette(settings:settings)
        if list {
            let base = AppTypography.font(.body,settings:settings,traits:traitCollection,weight:700)
            let rowHeight = base.lineHeight + 4, width = max(1,(size.width - 10) / 3)
            var y:CGFloat = 5
            for block in 0..<3 {
                if block > 0 {
                    y += 10; palette.divider.setFill()
                    UIBezierPath(rect:CGRect(x:5,y:y,width:size.width - 10,height:2)).fill(); y += 12
                }
                for row in 1...9 {
                    for column in 0..<3 {
                        let factor = block * 3 + column + 1, text = "\(factor) × \(row) = \(factor * row)" as NSString
                        let available = max(1,width - 13), measured = text.size(withAttributes:[.font:base]).width
                        let font = base.withSize(base.pointSize * min(1,available / max(1,measured)))
                        text.draw(at:CGPoint(x:5 + CGFloat(column) * width + 12,y:y + (rowHeight - font.lineHeight) / 2),withAttributes:[.font:font,.foregroundColor:palette.text])
                    }
                    y += rowHeight
                }
            }
            return
        }
        let base = AppTypography.font(.body,settings:settings,traits:traitCollection)
        let font = base.withSize(base.pointSize * (min(cell.width,cell.height) > 40 ? 14 : 12) / 16)
        let bold = AppTypography.font(.body,settings:settings,traits:traitCollection,weight:700).withSize(font.pointSize)
        for row in 0...10 {
            for column in 0...10 {
                let header = row == 0 || column == 0, diagonal = row == column
                let background:UIColor, foreground:UIColor
                if palette.theme.isAnimated {
                    background = UIColor.black.withAlphaComponent(header ? 0x66 / 255 : diagonal ? 0x4D / 255 : 0x26 / 255)
                    foreground = header && palette.theme == .neon ? palette.selected : .white
                } else if !palette.theme.isClassic {
                    background = header ? palette.header : diagonal ? ThemeColor.blend(palette.surface,palette.accent,0.12) : palette.surface
                    foreground = header ? palette.headerText : palette.text
                } else {
                    background = header ? palette.selected : palette.theme.isDark ? ThemeColor.shade(palette.selected,diagonal ? 0.4 : 0.2) : ThemeColor.blend(palette.selected,.white,diagonal ? 0.6 : 0.85)
                    foreground = header ? .white : palette.theme.isDark ? ThemeColor.rgb(0xB0B0B0) : .black
                }
                let area = CGRect(x:CGFloat(column) * (cell.width + 2) + 1,y:CGFloat(row) * (cell.height + 2) + 1,width:cell.width,height:cell.height)
                background.setFill(); UIBezierPath(rect:area).fill()
                let text = (header ? row == 0 && column == 0 ? "×" : String(row == 0 ? column : row) : String(row * column)) as NSString
                let baseFace = header ? bold : font
                let textWidth = text.size(withAttributes:[.font:baseFace]).width
                let face = baseFace.withSize(baseFace.pointSize * min(1,max(1,area.width-4)/max(1,textWidth)))
                let measured = text.size(withAttributes:[.font:face])
                text.draw(at:CGPoint(x:area.midX - measured.width / 2,y:area.midY - measured.height / 2),withAttributes:[.font:face,.foregroundColor:foreground])
            }
        }
    }
}
