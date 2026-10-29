import UIKit

/// Android's solution_share_header and SolutionSchemeShare bitmap layout.
enum SolutionSchemeShare {
    static func make(step: SolutionStep, input: String, example: MathExample, steps: [SolutionStep], settings: AppSettings, traits: UITraitCollection) -> UIImage? {
        var export = settings; export.useSystemFontSize = false; export.fontSizePercent = 100
        let palette = ResultPalette(export), accent = ThemePalette(settings: export).accent
        func label(_ text: String, size: CGFloat, color: UIColor, bold: Bool = false) -> UILabel {
            let label = UILabel(); label.numberOfLines = 0; label.text = text; label.textColor = color
            label.font = .systemFont(ofSize: size, weight: bold ? .medium : .regular)
            return label
        }
        func layout(_ view: UIView, width: CGFloat) -> CGFloat {
            let size = view.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            view.frame = CGRect(x: 0, y: 0, width: width, height: ceil(max(size.height, view.intrinsicContentSize.height))); view.layoutIfNeeded()
            return view.bounds.height
        }
        let header = ResultUI.stack(.vertical, spacing: 32)
        header.isLayoutMarginsRelativeArrangement = true
        header.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 64, leading: 64, bottom: 64, trailing: 64)
        let brand = ResultUI.stack(.horizontal, spacing: 32); brand.alignment = .center
        let logo = UIImageView(image: UIImage(named: "result_share_logo")); logo.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([logo.widthAnchor.constraint(equalToConstant: 160), logo.heightAnchor.constraint(equalToConstant: 160)])
        brand.addArrangedSubview(logo)
        let name = label(ResultText.text("solution_share_app_name"), size: 48, color: accent, bold: true)
        name.attributedText = NSAttributedString(string: ResultText.text("solution_share_app_name"), attributes: [.font: name.font!, .foregroundColor: accent, .kern: 48 * 0.15])
        brand.addArrangedSubview(name); header.addArrangedSubview(brand)
        let stores = ResultUI.stack(.horizontal); stores.alignment = .center
        var previous: UIStackView?
        let number = NumberFormatter(); number.minimumFractionDigits = 1; number.maximumFractionDigits = 1
        for (value, caption) in [(ResultText.format("results_store_rating", number.string(from: 4.5) ?? "4.5"), ResultText.text("results_store_reviews")), (ResultText.text("results_store_download_count"), ResultText.text("results_store_downloads"))] {
            let column = ResultUI.stack(.vertical, spacing: 8)
            for text in [label(value, size: 36, color: palette.primary, bold: true), label(caption, size: 26, color: palette.secondary)] {
                text.textAlignment = .center; column.addArrangedSubview(text)
            }
            if previous != nil {
                let divider = UIView(); divider.backgroundColor = UIColor(white: 0.5, alpha: 64 / 255)
                NSLayoutConstraint.activate([divider.widthAnchor.constraint(equalToConstant: 1), divider.heightAnchor.constraint(equalToConstant: 64)])
                stores.addArrangedSubview(divider)
            }
            stores.addArrangedSubview(column)
            if let previous { column.widthAnchor.constraint(equalTo: previous.widthAnchor).isActive = true }
            previous = column
        }
        header.addArrangedSubview(stores)
        let slogan = label(ResultText.text("solution_share_scheme_slogan"), size: 38, color: palette.primary)
        slogan.textAlignment = .center; header.addArrangedSubview(slogan)
        let headerHeight = layout(header, width: 1080)
        let scheme = SolutionSchemeView()
        let style = SolutionSchemeView.RuleStyle(width: 320, texts: [step.processedEquation(input: input, trickID: example.trickID).text], settings: export, traits: traits, zoom: 1)
        scheme.apply(step: step, input: input, example: example, settings: export, ruleStyle: style)
        let schemeHeight = layout(scheme, width: 320), schemeScale: CGFloat = 904 / 320
        let hints = ResultUI.stack(.vertical)
        for (index, step) in steps.enumerated() {
            let row = ResultUI.stack(.vertical)
            row.isLayoutMarginsRelativeArrangement = true
            row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            let title = CatalogText.ui("rule_step_title").replacingOccurrences(of: "%d", with: String(index + (steps.first?.isIntro == true ? 0 : 1)))
            let description = label("", size: 32, color: palette.primary)
            let text = NSMutableAttributedString(string: title + " - " + AndroidRichText.plain(step.description), attributes: [.font: UIFont.systemFont(ofSize: 32), .foregroundColor: palette.primary])
            text.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 32), range: NSRange(location: 0, length: (title as NSString).length))
            description.attributedText = text; row.addArrangedSubview(description)
            if !step.hintExpr.isEmpty {
                let hint = label("(" + step.hintExpr + ")", size: 34, color: palette.primary)
                hint.font = .italicSystemFont(ofSize: 34); row.addArrangedSubview(hint)
            }
            hints.addArrangedSubview(row)
        }
        let hintsHeight = layout(hints, width: 904), gap: CGFloat = steps.isEmpty ? 0 : 32
        let height = headerHeight + ceil(schemeHeight * schemeScale) + gap + hintsHeight + 112
        guard height.isFinite, height > 0, schemeHeight > 0 else { return nil }
        let scale = min(1, 4096 / height)
        let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true; format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: CGSize(width: max(1, floor(1080 * scale)), height: max(1, floor(height * scale))), format: format).image { renderer in
            let context = renderer.cgContext
            palette.background.setFill(); renderer.fill(CGRect(x: 0, y: 0, width: 1080, height: height))
            context.scaleBy(x: scale, y: scale)
            header.layer.render(in: context)
            palette.surface.setFill()
            UIBezierPath(roundedRect: CGRect(x: 64, y: headerHeight, width: 952, height: height - 64 - headerHeight), cornerRadius: 24).fill()
            context.saveGState(); context.translateBy(x: 88, y: headerHeight + 24); context.scaleBy(x: schemeScale, y: schemeScale)
            scheme.layer.render(in: context); context.restoreGState()
            context.translateBy(x: 88, y: headerHeight + 24 + ceil(schemeHeight * schemeScale) + gap)
            hints.layer.render(in: context)
        }
    }
}
