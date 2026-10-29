import UIKit

/// TextKit gives the same UTF-16 offsets used by Android's arithmetic diagrams.
final class SolutionSchemeView: UIView {
    struct RuleStyle {
        private let texts: [String]
        private let settings: AppSettings
        private let traits: UITraitCollection
        private let zoom: CGFloat
        let isSolution: Bool
        let width: CGFloat
        let originalSize: CGFloat
        let fontSize: CGFloat
        let maximumZoom: CGFloat
        init(width: CGFloat, texts: [String], settings: AppSettings, traits: UITraitCollection, zoom: CGFloat, isSolution: Bool = false) {
            self.width = width
            self.isSolution = isSolution
            self.texts = texts; self.settings = settings; self.traits = traits; self.zoom = zoom
            let original = AppTypography.font(.scheme,settings:settings,traits:traits).pointSize * 32 / 20
            originalSize = original
            let font = AppTypography.font(.scheme,settings:settings,traits:traits).withSize(original)
            let widest = texts.flatMap { $0.components(separatedBy:"\n") }.filter { !$0.contains("- -") && !$0.contains("◀") && !$0.contains("▶") }.map { ($0 as NSString).size(withAttributes:[.font:font]).width }.max() ?? 0
            let target = max(1,width - (isSolution ? 12 : 36))
            let base = widest > target ? max(10,original * target / widest) : original
            maximumZoom = widest > 0 ? min(3.5,target / (widest * base / original)) : 3.5
            let candidate = base * zoom
            let scaledWidth = widest * candidate / original
            fontSize = scaledWidth > target ? max(10,candidate * target / scaledWidth) : candidate
        }
        func fitting(width: CGFloat) -> RuleStyle {
            RuleStyle(width: width, texts: texts, settings: settings, traits: traits, zoom: zoom, isSolution: isSolution)
        }
    }
    private var ruleContent: (step: SolutionStep, input: String, example: MathExample, settings: AppSettings, frozen: Bool, style: RuleStyle)?
    private var textOrigin = CGPoint(x:28,y:28)
    private var drawingFont = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
    private var ruleFontSize: CGFloat?
    private var geometryScale: CGFloat = 1
    private let storage = NSTextStorage()
    private let manager = NSLayoutManager()
    private let container = NSTextContainer(size: .zero)
    private var step: SolutionStep?
    private var arrows: [SolutionArrow] = []
    private struct ArrowKey: Hashable {
        let start, end: Int
        init(_ arrow: SolutionArrow) { start = arrow.startOffset; end = arrow.endOffset }
    }
    private final class AnimationTarget: NSObject {
        weak var view: SolutionSchemeView?
        init(_ view: SolutionSchemeView) { self.view = view }
        @objc func tick() { view?.advanceAnimation() }
    }
    private var arrowStartTimes: [ArrowKey: CFTimeInterval] = [:]
    private var displayLink: CADisplayLink?
    private let animationDuration: CFTimeInterval = 0.6
    private var frozen = false
    private var settings = AppSettings()
    private let padding: CGFloat = 28
    private var measured = CGSize(width: 240, height: 100)
    private var foreground = UIColor.label
    private var processed: SolutionStep.DisplayedEquation?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isAccessibilityElement = true
        storage.addLayoutManager(manager); manager.addTextContainer(container)
        container.lineFragmentPadding = 0
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var intrinsicContentSize: CGSize { measured }
    func apply(step: SolutionStep, input: String, example: MathExample, settings: AppSettings, frozen: Bool = false, ruleStyle: RuleStyle? = nil) {
        self.step = step; self.settings = settings; self.frozen = frozen
        ruleContent = ruleStyle.map { (step, input, example, settings, frozen, $0) }
        let palette = ThemePalette(settings: settings); foreground = palette.text
        let processed = step.processedEquation(input: input, trickID: example.trickID).removingLeadingBlankLines()
        self.processed = processed
        let text = processed.text
        let originalFont = AppTypography.font(.scheme, settings: settings, traits: traitCollection)
        let font = ruleStyle.map { originalFont.withSize($0.fontSize) } ?? originalFont
        drawingFont = font
        ruleFontSize = ruleStyle?.fontSize
        geometryScale = ruleStyle.map { $0.fontSize / $0.originalSize } ?? 1
        textOrigin = ruleStyle.map { $0.isSolution ? CGPoint(x:0,y:20) : CGPoint(x:12,y:20) } ?? CGPoint(x:padding,y:padding)
        let paragraph = NSMutableParagraphStyle()
        paragraph.baseWritingDirection = .leftToRight
        paragraph.lineSpacing = ruleStyle == nil ? ([1,2,3,4].contains(example.trickID) ? 1 : max(28,font.pointSize * 1.6)) : ([1,2,3,4].contains(example.trickID) ? (ruleStyle?.isSolution == true ? 1 : 4) : 47) * geometryScale
        if ruleStyle != nil { paragraph.alignment = .center }
        let attributed = NSMutableAttributedString(string: text, attributes: [.font: font, .foregroundColor: foreground, .paragraphStyle: paragraph])
        let length = attributed.length
        for index in step.crossedOutOffsets {
            guard let range = processed.range(index), NSMaxRange(range) <= length else { continue }
            attributed.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        for range in step.highlightedRanges where range.count == 2 && range[0] >= 0 && range[1] <= length && range[0] < range[1] {
            attributed.addAttribute(.backgroundColor, value: palette.accent.withAlphaComponent(0.2), range: processed.range(range[0],length: range[1]-range[0]) ?? NSRange(location: 0,length: 0))
        }
        for index in step.transparentOffsets {
            guard let range = processed.range(index), NSMaxRange(range) <= length else { continue }
            attributed.addAttribute(.foregroundColor, value: UIColor.clear, range: range)
        }
        let widest = text.components(separatedBy: "\n").map { ($0 as NSString).size(withAttributes: [.font: font]).width }.max() ?? 0
        let textWidth = ruleStyle.map { max(1,$0.width - ($0.isSolution ? 0 : 24)) } ?? max(200,widest + 2)
        if ruleStyle != nil, ![1,2,3,4].contains(example.trickID) {
            var offset = 0
            let spaceWidth = (" " as NSString).size(withAttributes:[.font:font]).width
            for line in text.components(separatedBy:"\n") {
                let leading = line.prefix(while:{$0 == " "}).count
                let trailing = line.reversed().prefix(while:{$0 == " "}).count
                // Include explicit padding when centering, as Android does.
                // TextKit otherwise discards trailing spaces from centered line width.
                if leading + trailing > 0, line.count > leading + trailing {
                    let visible = String(line.dropFirst(leading).dropLast(trailing))
                    let width = (visible as NSString).size(withAttributes:[.font:font]).width + CGFloat(leading + trailing) * spaceWidth
                    let centered = paragraph.mutableCopy() as! NSMutableParagraphStyle
                    centered.alignment = .left
                    centered.firstLineHeadIndent = max(0,(textWidth-width)/2)
                    centered.headIndent = centered.firstLineHeadIndent
                    attributed.addAttribute(.paragraphStyle,value:centered,range:NSRange(location:offset,length:(line as NSString).length))
                }
                offset += (line as NSString).length + 1
            }
        }
        storage.setAttributedString(attributed)
        container.size = CGSize(width:textWidth,height:.greatestFiniteMagnitude)
        manager.ensureLayout(for: container)
        let used = manager.usedRect(for: container)
        measured = ruleStyle.map { CGSize(width:$0.width,height:max(4,used.height + textOrigin.y)) } ?? CGSize(width:max(240,used.width + 2 * padding),height:max(100,used.height + 2 * padding))
        arrows = frozen && !step.frozenArrows.isEmpty ? step.frozenArrows : step.arrows
        let previousTimes = arrowStartTimes, now = CACurrentMediaTime()
        arrowStartTimes.removeAll(keepingCapacity: true)
        if !frozen {
            for arrow in arrows where !arrow.isDimmed {
                let key = ArrowKey(arrow)
                arrowStartTimes[key] = previousTimes[key] ?? now
            }
        }
        updateAnimation()
        accessibilityLabel = text
        invalidateIntrinsicContentSize(); setNeedsDisplay()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // Scroll and stack views settle their widths after the first content update.
        // Fit TextKit to the actual drawing view before its first frame is painted.
        guard let content = ruleContent, bounds.width > 36,
              abs(content.style.width - bounds.width) > 0.5 else { return }
        apply(step: content.step, input: content.input, example: content.example,
              settings: content.settings, frozen: content.frozen, ruleStyle: content.style.fitting(width: bounds.width))
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateAnimation()
    }
    deinit { displayLink?.invalidate() }
    private func updateAnimation() {
        let now = CACurrentMediaTime()
        let running = window != nil && !frozen && arrowStartTimes.values.contains { now - $0 < animationDuration }
        if running, displayLink == nil {
            let link = CADisplayLink(target: AnimationTarget(self), selector: #selector(AnimationTarget.tick))
            link.add(to: .main, forMode: .common)
            displayLink = link
        } else if !running {
            displayLink?.invalidate(); displayLink = nil
        }
    }
    private func advanceAnimation() {
        setNeedsDisplay()
        updateAnimation()
    }
    private func progress(for arrow: SolutionArrow) -> CGFloat {
        guard window != nil, !frozen, !arrow.isDimmed,
              let start = arrowStartTimes[ArrowKey(arrow)] else { return 1 }
        return CGFloat(min(1,max(0,(CACurrentMediaTime() - start) / animationDuration)))
    }
    private func opacity(for arrow: SolutionArrow, progress: CGFloat, label: Bool = false) -> CGFloat {
        if label ? arrow.alwaysShowLabel : arrow.noHead { return 1 }
        if arrow.isDimmed { return 56 / 255 }
        return step?.isFinal == true ? 56 / 255 + (1 - 56 / 255) * progress : progress
    }
    private func hintColor(for text: String, explicit: UInt32, palette: ThemePalette) -> UIColor {
        var rgb = explicit & 0xFFFFFF
        if explicit == 0 || rgb == 0x66BB00 || rgb == 0x00FF00 {
            if text.contains(where: { $0.isNumber }) { rgb = 0x66BB00 }
            else if text.contains("+") { rgb = 0x009688 }
            else if text.contains("-") || text.contains("−") { rgb = 0xFBC02D }
            else if text.contains("×") || text.contains("*") { rgb = 0x1976D2 }
            else if text.contains("/") || text.contains("÷") || text.contains(":") { rgb = 0xD32F2F }
            else { rgb = 0x66BB00 }
        }
        let factor: CGFloat = palette.theme.isDark ? 0.5 : 1
        return UIColor(red:CGFloat((rgb >> 16) & 255) / 255 * factor,
                       green:CGFloat((rgb >> 8) & 255) / 255 * factor,
                       blue:CGFloat(rgb & 255) / 255 * factor,alpha:1)
    }
    private func tokenRect(_ offset: Int, length: Int) -> CGRect? {
        guard let mapped = processed?.range(offset,length: length), NSMaxRange(mapped) <= storage.length else { return nil }
        let range = manager.glyphRange(forCharacterRange: mapped, actualCharacterRange: nil)
        return manager.boundingRect(forGlyphRange: range, in: container).offsetBy(dx: textOrigin.x, dy: textOrigin.y)
    }
    func nestingAnchor(parent: Bool) -> CGRect? {
        guard let processed else { return nil }
        let text = processed.text as NSString
        let range: NSRange
        if parent {
            let offset = processed.cursorOffset ?? text.range(of: "?").location
            guard offset != NSNotFound, offset < text.length else { return nil }
            var end = offset + 1
            while end < text.length, text.character(at: end) == 63 { end += 1 }
            range = NSRange(location: offset, length: end - offset)
        } else {
            let first = processed.text.components(separatedBy: "\n").first ?? ""
            let pattern = [1,2,3,4].contains(ruleContent?.example.trickID ?? 0) ? #"\||\d+"# : #"[+−×÷√^]|\d+"#
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: first, range: NSRange(first.startIndex..., in: first)) else { return nil }
            if first.contains("|"), let pipe = first.range(of: "|") { range = NSRange(pipe, in: first) }
            else if ![1,2,3,4].contains(ruleContent?.example.trickID ?? 0),
                    let sign = first.rangeOfCharacter(from: CharacterSet(charactersIn: "+−×÷√^")) { range = NSRange(sign, in: first) }
            else { range = match.range }
        }
        let glyphs = manager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        return manager.boundingRect(forGlyphRange: glyphs, in: container).offsetBy(dx: textOrigin.x, dy: textOrigin.y)
    }
    override func draw(_ rect: CGRect) {
        guard storage.length > 0 else { return }
        let glyphs = manager.glyphRange(for: container)
        manager.drawBackground(forGlyphRange: glyphs, at: textOrigin)
        manager.drawGlyphs(forGlyphRange: glyphs, at: textOrigin)
        let palette = ThemePalette(settings: settings)
        if ruleFontSize != nil { drawRuleArrows(palette: palette); return }
        for arrow in arrows {
            guard let from = tokenRect(arrow.startOffset, length: arrow.startTokenLength),
                  let to = tokenRect(arrow.endOffset, length: arrow.tokenLength) else { continue }
            let color = palette.theme.isDark ? palette.secondary : ThemeColor.rgb(arrow.color & 0xFFFFFF)
            color.withAlphaComponent(arrow.isDimmed ? 0.28 : 0.85).setStroke()
            let path = UIBezierPath(); path.lineWidth = 1.2
            if arrow.noHead {
                path.move(to: CGPoint(x: from.minX, y: from.midY)); path.addLine(to: CGPoint(x: to.maxX, y: to.midY)); path.stroke(); continue
            }
            if arrow.isSquareBox {
                UIBezierPath(roundedRect: to.insetBy(dx: -2, dy: -2), cornerRadius: 2).stroke(); continue
            }
            let down = to.midY >= from.midY
            let start = CGPoint(x: from.midX, y: down ? from.maxY + 2 : from.minY - 2)
            let end = CGPoint(x: to.midX, y: down ? to.minY - 3 : to.maxY + 3)
            let bend = CGFloat(arrow.curveAmount) * 16 * geometryScale
            let control = CGPoint(x: (start.x + end.x) / 2 - bend, y: (start.y + end.y) / 2)
            path.move(to: start); path.addQuadCurve(to: end, controlPoint: control); path.stroke()
            let angle = atan2(end.y - control.y, end.x - control.x)
            path.move(to: CGPoint(x: end.x - 5 * cos(angle - .pi / 6), y: end.y - 5 * sin(angle - .pi / 6)))
            path.addLine(to: end); path.addLine(to: CGPoint(x: end.x - 5 * cos(angle + .pi / 6), y: end.y - 5 * sin(angle + .pi / 6))); path.stroke()
            if !arrow.label.isEmpty && (!arrow.isDimmed || arrow.alwaysShowLabel) {
                let labelColor = palette.theme.isDark ? palette.accent : ThemeColor.rgb(arrow.labelColor & 0xFFFFFF)
                let baseFont = AppTypography.font(.caption, settings: settings, traits: traitCollection)
                let font = ruleFontSize.map { baseFont.withSize($0 * 0.55) } ?? baseFont
                let label = arrow.label as NSString
                let size = label.size(withAttributes: [.font: font])
                label.draw(at: CGPoint(x: control.x - size.width / 2, y: control.y - size.height), withAttributes: [.font: font, .foregroundColor: labelColor])
            }
        }
    }
    private struct ArrowGeometry {
        let arrow: SolutionArrow
        let start, end, control: CGPoint
        var midpoint: CGPoint { CGPoint(x:start.x * 0.25 + control.x * 0.5 + end.x * 0.25,y:start.y * 0.25 + control.y * 0.5 + end.y * 0.25) }
    }
    private func ruleToken(_ offset: Int, length: Int, gap: Bool) -> (x: CGFloat, baseline: CGFloat, line: Int)? {
        guard let processed, let range = processed.range(offset), range.location < storage.length else { return nil }
        let text = storage.string as NSString
        let first = text.character(at:range.location)
        var count = max(1,length)
        if length <= 0, first != 32, first != 10 {
            count = 1
            func kind(_ value: unichar) -> Int { value >= 48 && value <= 57 ? 1 : value == 63 ? 2 : value == 32 || value == 10 ? 0 : 3 }
            while range.location + count < text.length, kind(text.character(at:range.location + count)) == kind(first) { count += 1 }
        }
        if first == 32 { count = 1 }
        let mapped = NSRange(location:range.location,length:min(count,text.length - range.location))
        let glyphs = manager.glyphRange(forCharacterRange:mapped,actualCharacterRange:nil)
        guard glyphs.location < manager.numberOfGlyphs else { return nil }
        let rect = manager.boundingRect(forGlyphRange:glyphs,in:container)
        let fragment = manager.lineFragmentRect(forGlyphAt:glyphs.location,effectiveRange:nil)
        let location = manager.location(forGlyphAt:glyphs.location)
        let x = first == 32 && !gap ? rect.minX : rect.midX
        let prefix = text.substring(to:range.location)
        return (x + textOrigin.x,fragment.minY + location.y + textOrigin.y,prefix.filter { $0 == "\n" }.count)
    }
    private func drawRuleArrows(palette: ThemePalette) {
        let scale = max(0.2,geometryScale), margin = 8 * max(0.2,geometryScale)
        var geometries: [ArrowGeometry] = []
        for arrow in arrows {
            let startLength = arrow.startTokenLength > 0 ? arrow.startTokenLength : arrow.tokenLength
            guard let from = ruleToken(arrow.startOffset,length:startLength,gap:arrow.startGap),
                  let to = ruleToken(arrow.endOffset,length:arrow.tokenLength,gap:arrow.targetGap) else { continue }
            let ascending = from.line > to.line
            var start = CGPoint(x:from.x,y:from.baseline + (ascending ? -drawingFont.ascender * 0.7 - margin : margin))
            var end = CGPoint(x:to.x,y:to.baseline + (ascending ? margin : -drawingFont.ascender * 0.7 - margin))
            if arrow.noHead && from.line == to.line { start.y = from.baseline + margin * 0.6; end.y = start.y }
            let dx = end.x - start.x, dy = end.y - start.y, distance = hypot(dx,dy)
            let bend = CGFloat(arrow.curveAmount) * 40 * scale
            let control = CGPoint(x:(start.x + end.x) / 2 - (distance > 0 ? dy / distance * bend : 0),y:(start.y + end.y) / 2 + (distance > 0 ? dx / distance * bend : 0))
            geometries.append(ArrowGeometry(arrow:arrow,start:start,end:end,control:control))
            guard arrow.color != 0 else { continue }
            let progress = progress(for: arrow)
            let lineProgress: CGFloat = step?.isFinal == true ? 1 : progress
            let animatedEnd = CGPoint(x:start.x + dx * lineProgress,y:start.y + dy * lineProgress)
            let animatedBend = bend * lineProgress
            let animatedControl = CGPoint(x:(start.x + animatedEnd.x) / 2 - (distance > 0 ? dy / distance * animatedBend : 0),
                                          y:(start.y + animatedEnd.y) / 2 + (distance > 0 ? dx / distance * animatedBend : 0))
            (palette.theme == .aurora ? UIColor.white : ThemeColor.rgb(arrow.color & 0xFFFFFF)).withAlphaComponent(opacity(for:arrow,progress:progress)).setStroke()
            let path = UIBezierPath(); path.lineWidth = 2 * scale; path.lineCapStyle = .round
            path.move(to:start); path.addQuadCurve(to:animatedEnd,controlPoint:animatedControl); path.stroke()
            if !arrow.noHead {
                let angle = atan2(animatedEnd.y - animatedControl.y,animatedEnd.x - animatedControl.x), size = 10 * scale
                let head = UIBezierPath(); head.lineWidth = path.lineWidth; head.lineCapStyle = .round
                head.move(to:CGPoint(x:animatedEnd.x + cos(angle + .pi * 0.85) * size,y:animatedEnd.y + sin(angle + .pi * 0.85) * size))
                head.addLine(to:animatedEnd); head.addLine(to:CGPoint(x:animatedEnd.x + cos(angle - .pi * 0.85) * size,y:animatedEnd.y + sin(angle - .pi * 0.85) * size)); head.stroke()
            }
        }
        for geometry in geometries {
            let arrow = geometry.arrow
            let progress = progress(for: arrow)
            guard !arrow.label.isEmpty, arrow.alwaysShowLabel || (step?.isFinal == true || !arrow.isDimmed) && progress > 0.5 else { continue }
            var group = [geometry]
            group += geometries.filter { other in
                let candidate = other.arrow
                return candidate.label.isEmpty && candidate.isDimmed == arrow.isDimmed && (candidate.endOffset == arrow.endOffset || arrow.centerBetweenArrows && candidate.startOffset == arrow.startOffset)
            }
            var text = arrow.label
            if group.count > 1, !arrow.centerBetweenArrows, text.range(of:#"^[+\-−]\s*\d+$"#,options:.regularExpression) == nil {
                if text.contains("+") { text = "+" } else if text.contains("×") || text.contains("*") { text = "×" } else if text.contains("-") || text.contains("−") { text = "-" } else if text.contains("/") || text.contains("÷") { text = "÷" }
            }
            var center = geometry.midpoint
            if arrow.isCarryFlight && group.count == 1 {
                let t = progress * progress * (3 - 2 * progress), mt = 1 - t
                let control = CGPoint(x:(geometry.start.x + geometry.end.x) / 2,y:min(geometry.start.y,geometry.end.y) - 60 * scale)
                center = CGPoint(x:mt * mt * geometry.start.x + 2 * mt * t * control.x + t * t * geometry.end.x,
                                 y:mt * mt * geometry.start.y + 2 * mt * t * control.y + t * t * geometry.end.y)
            }
            else if arrow.centerBetweenArrows && group.count > 1 {
                center = CGPoint(x:group.map { $0.midpoint.x }.reduce(0,+) / CGFloat(group.count),y:group.map { $0.midpoint.y }.reduce(0,+) / CGFloat(group.count))
            } else if group.count == 1 {
                if arrow.startOffset == arrow.endOffset || arrow.color == 0 || hypot(geometry.end.x - geometry.start.x,geometry.end.y - geometry.start.y) < 40 * scale { center = CGPoint(x:geometry.end.x,y:geometry.end.y - 17.5 * scale) }
            } else {
                var vx: CGFloat = 0, vy: CGFloat = 0
                for item in group {
                    let dx = item.end.x - item.control.x, dy = item.end.y - item.control.y, length = hypot(dx,dy)
                    if length > 0 { vx -= dx / length; vy -= dy / length }
                }
                let length = hypot(vx,vy)
                center = CGPoint(x:geometry.end.x + (length > 0 ? vx / length : 0) * 25 * scale,y:geometry.end.y + (length > 0 ? vy / length : -1) * 25 * scale)
            }
            let font = drawingFont.withSize(drawingFont.pointSize * 0.45)
            let label = text as NSString, size = (text as NSString).size(withAttributes:[.font:font])
            let rect = CGRect(x:center.x - size.width / 2 - 5 * scale,y:center.y - size.height / 2 - 3 * scale,width:size.width + 10 * scale,height:size.height + 6 * scale)
            let alpha = opacity(for:arrow,progress:progress,label:true)
            hintColor(for:text,explicit:arrow.labelColor,palette:palette).withAlphaComponent(alpha).setFill()
            UIBezierPath(roundedRect:rect,cornerRadius:arrow.isSquareBox ? 0 : 6 * scale).fill()
            let textColor = palette.theme == .aurora || !palette.theme.isDark ? UIColor.white : UIColor(white:0.8,alpha:1)
            label.draw(in:rect.insetBy(dx:5 * scale,dy:3 * scale),withAttributes:[.font:font,.foregroundColor:textColor.withAlphaComponent(alpha)])
        }
    }

}

/// Shared geometry and timing for the arrows between nested Rule/Solution examples.
final class SchemeNestingArrows: CALayer {
    private var arrows: [CAShapeLayer] = []
    func update(parents: [SolutionSchemeView], active: SolutionSchemeView, ids: [String], container: UIView, palette: ThemePalette, scale: CGFloat) {
        while arrows.count > parents.count { arrows.removeLast().removeFromSuperlayer() }
        while arrows.count < parents.count { let line = CAShapeLayer(); line.addSublayer(CAShapeLayer()); addSublayer(line); arrows.append(line) }
        CATransaction.begin(); CATransaction.setDisableActions(true)
        frame = container.bounds
        for (depth, parent) in parents.enumerated() {
            guard ids.indices.contains(depth) else { continue }
            let child = depth + 1 < parents.count ? parents[depth + 1] : active
            guard let source = child.nestingAnchor(parent:false), let target = parent.nestingAnchor(parent:true) else { continue }
            let line = arrows[depth], head = line.sublayers![0] as! CAShapeLayer
            let fresh = line.name != ids[depth]; line.name = ids[depth]
            let a = child.convert(CGPoint(x:source.midX,y:source.minY-8*scale),to:container)
            let b = parent.convert(CGPoint(x:target.midX,y:target.maxY+8*scale),to:container)
            let angle = atan2(b.y-a.y,b.x-a.x), size = 10*scale
            let path = UIBezierPath(); path.move(to:a); path.addLine(to:b)
            line.frame = container.bounds; line.path = path.cgPath
            let tip = UIBezierPath()
            tip.move(to:CGPoint(x:cos(angle + .pi*0.85)*size,y:sin(angle + .pi*0.85)*size)); tip.addLine(to:.zero)
            tip.addLine(to:CGPoint(x:cos(angle - .pi*0.85)*size,y:sin(angle - .pi*0.85)*size))
            head.path = tip.cgPath; head.position = b
            let color = palette.theme == .aurora ? UIColor.white : ThemeColor.rgb(palette.theme.isDark ? 0x66BB00 : 0x009688)
            for shape in [line,head] { shape.fillColor = nil; shape.strokeColor = color.cgColor; shape.lineWidth = 2*scale; shape.lineCap = .round; shape.lineJoin = .round }
            if fresh, container.window != nil {
                let draw = CABasicAnimation(keyPath:"strokeEnd"); draw.fromValue = 0; draw.toValue = 1; draw.duration = 0.6
                line.add(draw,forKey:"draw")
                let move = CABasicAnimation(keyPath:"position"); move.fromValue = NSValue(cgPoint:a); move.toValue = NSValue(cgPoint:b); move.duration = 0.6
                head.add(move,forKey:"move")
                let fade = CABasicAnimation(keyPath:"opacity"); fade.fromValue = 0; fade.toValue = 1; fade.duration = 0.6
                line.add(fade,forKey:"fade")
            }
        }
        CATransaction.commit()
    }
}

/// Keep the old scroll range until the replacement scheme can settle smoothly.
final class SchemeScrollPosition {
    private var previous: (height: CGFloat, offset: CGFloat, target: CGFloat?)?
    private var parents: [CGFloat] = []
    private var generation = 0
    func begin(_ scroll: UIScrollView, depth: Int) {
        guard previous == nil, scroll.window != nil else { return }
        generation += 1
        var target: CGFloat?
        if depth < parents.count { target = parents[depth]; parents.removeSubrange(depth...) }
        while parents.count < depth { parents.append(scroll.contentOffset.y) }
        previous = (scroll.contentSize.height,scroll.contentOffset.y,target)
        scroll.contentInset.bottom = max(0,scroll.contentOffset.y + scroll.bounds.height)
    }
    func finish(_ scroll: UIScrollView) {
        guard let previous else { return }; self.previous = nil
        let maximum = max(0,scroll.contentSize.height-scroll.bounds.height)
        let delta = scroll.contentSize.height-previous.height
        let floor = min(maximum,parents.last ?? 0)
        let desired = previous.target ?? (delta > 0.5 ? maximum : max(floor,previous.offset + min(0,delta)))
        let target = max(0,min(maximum,desired))
        let distance = abs(target-previous.offset)
        scroll.setContentOffset(CGPoint(x:0,y:previous.offset),animated:false)
        guard distance > 0.5, !scroll.isDragging else {
            scroll.contentInset = .zero; scroll.setContentOffset(CGPoint(x:0,y:target),animated:false); return
        }
        let duration = min(previous.target == nil ? 0.45 : 0.3,max(previous.target == nil ? 0.25 : 0.16,Double(distance)/1000))
        let generation = generation
        UIView.animate(withDuration:duration,delay:0,options:[.beginFromCurrentState,.allowUserInteraction,.curveEaseOut],animations:{
            scroll.contentOffset = CGPoint(x:0,y:target)
        },completion:{ [weak self] _ in if self?.generation == generation { scroll.contentInset = .zero } })
    }
}
