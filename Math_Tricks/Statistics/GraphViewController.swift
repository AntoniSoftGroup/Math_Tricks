import UIKit

struct AppGraphPoint: Equatable {
    let label: String
    let value: Double
    var position: Double = 0
    var day: Int?
    var seriesStart: Int?
    var seriesCount: Int64 = 0
    var dailyTarget: Int?
}
final class GraphViewController: ThemedViewController {
    private let mode: GameMode?
    private let selected: Bool
    private let metric: MainMetric?
    private let chart = AppLineChart()
    private var lineButton: AppButton!
    private var points: [AppGraphPoint] = []
    private var readTask: Task<Void,Never>?
    private var preparedStatistics: PracticeStatistics?
    init(mode: GameMode? = nil, selected: Bool = false, metric: MainMetric? = nil, router: AppRouter, data: AppDataStore) {
        self.mode = mode; self.selected = selected; self.metric = metric
        super.init(title: mode.map { CatalogText.ui("mode_" + $0.rawValue) } ?? MainText.text("graph"), router: router, data: data)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    isolated deinit { readTask?.cancel() }
    func prepareForPresentation() async throws {
        preparedStatistics = try await data.practiceStatistics()
        try Task.checkCancellation()
        loadViewIfNeeded()
    }
    override func buildContent() {
        chart.translatesAutoresizingMaskIntoConstraints = false; body.addSubview(chart)
        lineButton = button(CatalogText.ui("graph_smooth"), icon: .graphSmooth, kind: .icon) { [weak self] in
            guard let self else { return }
            Task { do { try await self.data.updateSettings(.graphSmoothed(!(self.settings.graphSmoothed ?? false))) } catch { self.showError(error) } }
        }
        header.setAccessoryView(lineButton)
        NSLayoutConstraint.activate([chart.topAnchor.constraint(equalTo: body.topAnchor), chart.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            chart.leadingAnchor.constraint(equalTo: body.leadingAnchor), chart.trailingAnchor.constraint(equalTo: body.trailingAnchor)])
    }

    override func update(_ progress: ProgressState?) {
        chart.settings = settings; chart.smoothed = settings.graphSmoothed ?? false
        lineButton.accessibilityLabel = CatalogText.ui(chart.smoothed ? "graph_smooth" : "graph_linear")
        lineButton.apply(settings: settings, tint: palette.theme == .light ? .white : palette.text)
        chart.fractional = mode == .speed
        if metric == .dailyStreak || mode == .daily {
            header.setTitle(MainText.format("activity_main_tv_days_streak", String(progress?.daily.streak ?? 0)))
        }
        guard let progress else { return }
        if let statistics = preparedStatistics {
            preparedStatistics = nil
            applyStatistics(statistics, progress: progress)
            return
        }
        readTask?.cancel(); readTask = Task { [weak self] in
            guard let self else { return }
            do {
                let statistics = try await data.practiceStatistics(); guard !Task.isCancelled else { return }
                applyStatistics(statistics, progress: progress)
            } catch { guard !Task.isCancelled else { return }; showError(error, reading: true, retry: { [weak self] in self?.update(self?.data.snapshot) }) }
        }
    }
    private func applyStatistics(_ statistics: PracticeStatistics, progress: ProgressState) {
        let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyy.MM.dd - HH:mm:ss"
        if metric == .dailyStreak || mode == .daily {
            points = dailyPoints(progress, statistics: statistics)
            chart.dailyTarget = Double(progress.daily.target)
        } else if let mode {
            chart.dailyTarget = nil
            let old = selected ? [] : statistics.legacyGraphs.filter { $0.mode == mode }.compactMap { p -> AppGraphPoint? in
                guard let value = p.value, value.isFinite else { return nil }; return AppGraphPoint(label: p.dateText ?? "", value: value)
            }
            let current = statistics.sessions.filter { $0.hasGraphResult && $0.configuration.mode == mode && $0.configuration.selectedTricks == self.selected }
                .sorted { $0.startedAt < $1.startedAt }.map { AppGraphPoint(label: formatter.string(from: $0.startedAt), value: $0.resultValue) }
            points = old + current
            for index in points.indices { points[index].position = Double(index + 1) }
        } else {
            chart.dailyTarget = nil
            points = statistics.sessions.sorted { $0.startedAt < $1.startedAt }.filter { $0.solved > 0 }
                .enumerated().map { AppGraphPoint(label: formatter.string(from: $0.element.startedAt), value: Double($0.element.solved), position: Double($0.offset + 1)) }
        }
        if chart.points != points { chart.points = points }
    }
    private func dailyPoints(_ progress: ProgressState, statistics: PracticeStatistics) -> [AppGraphPoint] {
        var days: [String:AppGraphPoint] = [:]
        for point in statistics.legacyGraphs where point.mode == .daily {
            let key = String((point.dateText ?? "").prefix(10)).replacingOccurrences(of: ".", with: "-")
            guard DailyProgressEngine.isValidDayKey(key), let day = DailyProgressEngine.dayNumber(key), let value = point.value, value.isFinite else { continue }
            let candidate = AppGraphPoint(label: key, value: value, day: day, seriesStart: point.seriesStartDay,
                seriesCount: point.seriesCount ?? 0, dailyTarget: point.dailyTarget.flatMap { $0 > 0 ? $0 : nil })
            if let old = days[key], old.value > value || (old.value == value && (old.dailyTarget ?? 0) > (point.dailyTarget ?? 0)) { continue }
            days[key] = candidate
        }
        var history = progress.dailyHistory ?? []
        if let key = progress.daily.dayKey {
            history.append(DailyHistoryPoint(dayKey: key, solved: progress.daily.solved, target: progress.daily.target,
                streak: (progress.daily.completedToday ?? (progress.daily.solved >= progress.daily.target && progress.daily.streak > 0)) ? progress.daily.streak : 0, seriesStartDay: progress.daily.seriesStartDay))
        }
        for point in history {
            guard let day = DailyProgressEngine.dayNumber(point.dayKey) else { continue }
            days[point.dayKey] = AppGraphPoint(label: point.dayKey, value: Double(point.solved), day: day,
                seriesStart: point.seriesStartDay, seriesCount: point.streak, dailyTarget: point.target)
        }
        var ordered = days.sorted { $0.key < $1.key }.map(\.value)
        for index in ordered.indices {
            if ordered[index].value < Double(ordered[index].dailyTarget ?? progress.daily.target) { continue }
            if (ordered[index].seriesStart ?? 0) <= 0 {
                if index > 0, ordered[index - 1].seriesCount > 0,
                   ordered[index].day == (ordered[index - 1].day ?? 0) + 1 || ordered[index].seriesCount > ordered[index - 1].seriesCount {
                    ordered[index].seriesStart = ordered[index - 1].seriesStart
                    if ordered[index].seriesCount == 0 { ordered[index].seriesCount = ordered[index - 1].seriesCount + 1 }
                } else {
                    ordered[index].seriesStart = (ordered[index].day ?? 0) - Int(min(Int64(Int32.max), max(1, ordered[index].seriesCount))) + 1
                    if ordered[index].seriesCount == 0 { ordered[index].seriesCount = 1 }
                }
            }
        }
        var series: [Int:ClosedRange<Int>] = [:]
        for point in ordered where point.seriesCount > 0 {
            guard let start = point.seriesStart, start > 0, let day = point.day else { continue }
            let old = series[start] ?? day...day; series[start] = min(old.lowerBound, day)...max(old.upperBound, day)
        }
        // An insured failed day stays in storage, but is omitted inside a restored series.
        ordered = ordered.filter { point in
            guard point.value < Double(point.dailyTarget ?? progress.daily.target), let day = point.day else { return true }
            return !series.values.contains { day > $0.lowerBound && day < $0.upperBound }
        }
        var position = 0.0
        for index in ordered.indices {
            let same = index > 0 && ordered[index].seriesCount > 0 && ordered[index - 1].seriesCount > 0 && ordered[index].seriesStart == ordered[index - 1].seriesStart
            let gap = index == 0 || same ? 1 : min(2, max(1, (ordered[index].day ?? 0) - (ordered[index - 1].day ?? 0)))
            position += Double(gap); ordered[index].position = position
        }
        return ordered
    }
}

/// Rendering and interaction follow Android SimpleLineChart.
private final class AppLineChart: UIView {
    var settings = AppSettings() { didSet { setNeedsDisplay() } }
    var smoothed = false { didSet { setNeedsDisplay() } }
    var fractional = false { didSet { if oldValue != fractional { updateBounds() } } }
    var dailyTarget: Double? { didSet { if oldValue != dailyTarget { updateBounds() } } }
    var points: [AppGraphPoint] = [] { didSet { updateBounds() } }
    private var minimumX = 0.0, maximumX = 1.0, high = 1.0, low = 0.0
    private var axisSteps = 5
    private var zoom: CGFloat = 1, offset: CGFloat = 0
    private var selection: Int?
    private var seriesRanges: [(start: Double, end: Double, count: Int64)] = []
    private let decimal: NumberFormatter = {
        let formatter = NumberFormatter(); formatter.minimumFractionDigits = 1; formatter.maximumFractionDigits = 1
        formatter.usesGroupingSeparator = false; return formatter
    }()
    private var font: UIFont { UIFont.systemFont(ofSize: 11) }
    private var lineColor: UIColor {
        let palette = ThemePalette(settings: settings)
        return palette.theme == .light ? .black : palette.theme == .dark ? ThemeColor.rgb(0xAAAAAA) : palette.text
    }
    private var plot: CGRect {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let width = max((value(low) as NSString).size(withAttributes: attributes).width, (value(high) as NSString).size(withAttributes: attributes).width)
        return bounds.inset(by: UIEdgeInsets(top: dailyTarget == nil ? 38 : 82, left: width + 12, bottom: 38, right: width + 12))
    }
    override init(frame: CGRect) {
        super.init(frame: frame); contentMode = .redraw; backgroundColor = .clear; isAccessibilityElement = true; accessibilityTraits = .adjustable
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPoint(_:))))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func value(_ number: Double) -> String {
        fractional ? decimal.string(from: NSNumber(value: number == 0 ? 0 : number)) ?? "" : String(Int64(number.rounded()))
    }
    private func updateBounds() {
        zoom = 1; offset = 0; selection = nil
        low = points.map(\.value).min() ?? 0; high = points.map(\.value).max() ?? 1
        if let dailyTarget { low = min(0, low); high = max(dailyTarget, high) }
        minimumX = points.first?.position ?? 0; maximumX = points.last?.position ?? 1
        if maximumX == minimumX { minimumX -= 0.5; maximumX += 0.5 }
        else { let padding = (maximumX - minimumX) * 0.05; minimumX -= padding; maximumX += padding }
        let padding = high == low ? max(1, abs(high) * 0.1) : (high - low) * 0.1
        low -= padding; high += padding
        if dailyTarget != nil { low = 0 }
        let unit = fractional ? 0.1 : 1
        let step = max(unit, ceil((high - low) / (5 * unit)) * unit)
        low = floor(low / step) * step; high = ceil(high / step) * step
        axisSteps = max(1, Int(((high - low) / step).rounded()))
        var groups: [Int:(Double,Double,Int64)] = [:]
        for point in points where point.seriesCount > 0 {
            guard let start = point.seriesStart, start > 0 else { continue }
            let old = groups[start] ?? (point.position, point.position, point.seriesCount)
            groups[start] = (old.0, point.position, max(old.2, point.seriesCount))
        }
        seriesRanges = groups.values.map { ($0.0,$0.1,$0.2) }.sorted { $0.start < $1.start }
        accessibilityLabel = "\(points.count) · " + MainText.text("graph"); setNeedsDisplay()
    }
    private func x(_ value: Double) -> CGFloat { plot.minX + (CGFloat((value - minimumX) / (maximumX - minimumX)) - offset) * zoom * plot.width }
    private func y(_ value: Double) -> CGFloat { plot.maxY - CGFloat((value - low) / max(0.1, high - low)) * plot.height }
    private func clampOffset() { offset = max(0, min(1 - 1 / zoom, offset)) }
    @objc private func pinch(_ gesture: UIPinchGestureRecognizer) {
        let anchor = (gesture.location(in: self).x - plot.minX) / max(1, plot.width)
        let old = zoom; zoom = max(1, min(20, zoom * gesture.scale)); offset += anchor / old - anchor / zoom
        gesture.scale = 1; selection = nil; clampOffset(); setNeedsDisplay()
    }
    @objc private func pan(_ gesture: UIPanGestureRecognizer) {
        offset -= gesture.translation(in: self).x / max(1, plot.width * zoom)
        gesture.setTranslation(.zero, in: self); selection = nil; clampOffset(); setNeedsDisplay()
    }
    @objc private func selectPoint(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        selection = nil
        if plot.contains(location) {
            selection = points.indices.filter { x(points[$0].position) >= plot.minX && x(points[$0].position) <= plot.maxX }.min {
                hypot(x(points[$0].position) - location.x, y(points[$0].value) - location.y) < hypot(x(points[$1].position) - location.x, y(points[$1].value) - location.y)
            }
        }
        announceSelection(); setNeedsDisplay()
    }
    private func announceSelection() {
        guard let selection, points.indices.contains(selection) else { return }
        accessibilityValue = points[selection].label + ": " + value(points[selection].value)
    }
    override func accessibilityIncrement() { selectAccessible(min(points.count - 1, (selection ?? -1) + 1)) }
    override func accessibilityDecrement() { selectAccessible(max(0, (selection ?? points.count) - 1)) }
    private func selectAccessible(_ index: Int) {
        guard points.indices.contains(index) else { return }; selection = index
        let position = CGFloat((points[index].position - minimumX) / (maximumX - minimumX))
        if position < offset || position > offset + 1 / zoom { offset = position - 0.5 / zoom; clampOffset() }
        announceSelection(); setNeedsDisplay()
    }
    private func connected(_ a: AppGraphPoint, _ b: AppGraphPoint) -> Bool {
        dailyTarget == nil || (a.seriesCount > 0 && b.seriesCount > 0 && (a.seriesStart ?? 0) > 0 && a.seriesStart == b.seriesStart && b.position - a.position <= 1.01)
    }
    private func dateLabel(_ point: AppGraphPoint) -> String {
        let day = String(point.label.components(separatedBy: " - ")[0].prefix(10))
        let parts = day.replacingOccurrences(of: "-", with: ".").split(separator: ".")
        return parts.count == 3 ? "\(parts[2]).\(parts[1]).\(parts[0])" : day
    }
    private func drawText(_ text: String, x: CGFloat, baseline: CGFloat, size: CGFloat = 11, color: UIColor? = nil, alignment: NSTextAlignment = .center, bold: Bool = false) {
        let font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color ?? lineColor]
        let width = (text as NSString).size(withAttributes: attributes).width
        let left = alignment == .right ? x - width : alignment == .left ? x : x - width / 2
        (text as NSString).draw(at: CGPoint(x: left, y: baseline - font.ascender), withAttributes: attributes)
    }
    override func draw(_ rect: CGRect) {
        let palette = ThemePalette(settings: settings)
        if points.isEmpty {
            let paragraph = NSMutableParagraphStyle(); paragraph.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [.font: AppTypography.font(.title, settings: settings, traits: traitCollection).withSize(18), .foregroundColor: lineColor, .paragraphStyle: paragraph]
            let text = MainText.text("graph_no_data") as NSString
            let area = CGSize(width: max(1, bounds.width - 32), height: .greatestFiniteMagnitude)
            let size = text.boundingRect(with: area, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
            text.draw(in: CGRect(x: 16, y: max(0, (bounds.height - size.height) / 2), width: area.width, height: size.height), withAttributes: attributes)
            return
        }
        guard plot.width > 0, plot.height > 0, let context = UIGraphicsGetCurrentContext() else { return }
        for row in 0...axisSteps {
            let position = plot.maxY - plot.height * CGFloat(row) / CGFloat(axisSteps)
            let vertical = plot.minX + plot.width * CGFloat(row) / CGFloat(axisSteps)
            let grid = UIBezierPath(); grid.move(to: CGPoint(x: plot.minX, y: position)); grid.addLine(to: CGPoint(x: plot.maxX, y: position))
            grid.move(to: CGPoint(x: vertical, y: plot.minY)); grid.addLine(to: CGPoint(x: vertical, y: plot.maxY))
            lineColor.withAlphaComponent(70/255).setStroke(); grid.lineWidth = 0.5; grid.setLineDash([10,10], count: 2, phase: 0); grid.stroke()
            let label = value(low + (high - low) * Double(row) / Double(axisSteps))
            drawText(label, x: plot.minX - 5, baseline: position + 4, alignment: .right)
            drawText(label, x: plot.maxX + 5, baseline: position + 4, alignment: .left)
        }
        var previousRight = -CGFloat.greatestFiniteMagnitude
        for point in points {
            let position = x(point.position); guard position >= plot.minX, position <= plot.maxX, !point.label.isEmpty else { continue }
            let text = dateLabel(point), half = (text as NSString).size(withAttributes: [.font: font]).width / 2
            let center = max(plot.minX + half, min(plot.maxX - half, position))
            guard center - half >= previousRight + 12 else { continue }
            drawText(text, x: center, baseline: plot.maxY + 22); drawText(text, x: center, baseline: plot.minY - 14)
            previousRight = center + half
        }
        lineColor.setStroke(); let border = UIBezierPath(rect: plot); border.lineWidth = 0.8; border.stroke()
        context.saveGState(); context.clip(to: plot)
        var start = 0
        for end in 1...points.count {
            guard end == points.count || !connected(points[end - 1], points[end]) else { continue }
            if end - start > 1 {
                let line = UIBezierPath(); line.move(to: CGPoint(x: x(points[start].position), y: y(points[start].value)))
                for index in (start + 1)..<end {
                    let a = points[index - 1], b = points[index]
                    let destination = CGPoint(x: x(b.position), y: y(b.value))
                    if smoothed {
                        let before = points[max(start, index - 2)], after = points[min(end - 1, index + 1)]
                        line.addCurve(to: destination,
                            controlPoint1: CGPoint(x: x(a.position + (b.position - before.position) * 0.2), y: y(a.value + (b.value - before.value) * 0.2)),
                            controlPoint2: CGPoint(x: x(b.position - (after.position - a.position) * 0.2), y: y(b.value - (after.value - a.value) * 0.2)))
                    } else { line.addLine(to: destination) }
                }
                let fill = UIBezierPath(cgPath: line.cgPath)
                fill.addLine(to: CGPoint(x: x(points[end - 1].position), y: plot.maxY)); fill.addLine(to: CGPoint(x: x(points[start].position), y: plot.maxY)); fill.close()
                palette.accent.withAlphaComponent(85/255).setFill(); fill.fill()
                lineColor.setStroke(); line.lineWidth = 1; line.setLineDash([10,5], count: 2, phase: 0); line.stroke()
            }
            start = end
        }
        if let target = dailyTarget {
            let line = UIBezierPath(); line.move(to: CGPoint(x: plot.minX, y: y(target))); line.addLine(to: CGPoint(x: plot.maxX, y: y(target)))
            line.setLineDash([8,5], count: 2, phase: 0); line.lineWidth = 1.8; palette.accent.setStroke(); line.stroke()
        }
        for (index, point) in points.enumerated() {
            let position = x(point.position); guard position >= plot.minX - 4, position <= plot.maxX + 4 else { continue }
            if dailyTarget != nil && index == points.count - 1 {
                palette.accent.setStroke(); let ring = UIBezierPath(ovalIn: CGRect(x: position - 8, y: y(point.value) - 8, width: 16, height: 16)); ring.lineWidth = 2; ring.stroke()
                palette.accent.setFill(); UIBezierPath(ovalIn: CGRect(x: position - 5, y: y(point.value) - 5, width: 10, height: 10)).fill()
            } else {
                lineColor.setFill(); UIBezierPath(ovalIn: CGRect(x: position - 3, y: y(point.value) - 3, width: 6, height: 6)).fill()
            }
        }
        if let selection {
            let point = points[selection], cross = UIBezierPath()
            cross.move(to: CGPoint(x: x(point.position), y: plot.minY)); cross.addLine(to: CGPoint(x: x(point.position), y: plot.maxY))
            cross.move(to: CGPoint(x: plot.minX, y: y(point.value))); cross.addLine(to: CGPoint(x: plot.maxX, y: y(point.value)))
            cross.setLineDash([10,5], count: 2, phase: 0); cross.lineWidth = 1; lineColor.setStroke(); cross.stroke()
        }
        context.restoreGState()
        if let target = dailyTarget {
            drawSeriesBrackets()
            drawText(MainText.count("graph_daily_target", Int64(target)), x: plot.minX + 6, baseline: y(target) - 6, color: palette.accent, alignment: .left)
        }
        let stride = max(1, Int(ceil(CGFloat(points.count) / (max(1, plot.width / 40) * zoom))))
        previousRight = -CGFloat.greatestFiniteMagnitude
        for (index, point) in points.enumerated() {
            let position = x(point.position), latest = dailyTarget != nil && index == points.count - 1
            guard position >= plot.minX, position <= plot.maxX, index % stride == 0 || index == points.count - 1 else { continue }
            let text = value(point.value), font = latest ? UIFont.boldSystemFont(ofSize: 12) : UIFont.systemFont(ofSize: 12)
            let half = (text as NSString).size(withAttributes: [.font: font]).width / 2
            let center = max(plot.minX + half + 8, min(plot.maxX - half - 8, position))
            guard center - half >= previousRight + 4 || latest else { continue }
            drawText(text, x: center, baseline: max(plot.minY + font.ascender, y(point.value) - 9), size: 12, color: latest ? palette.accent : lineColor, bold: latest)
            previousRight = center + half
        }
        if let selection { drawMarker(points[selection]) }
    }
    private func drawMarker(_ point: AppGraphPoint) {
        let text = value(point.value), date = dateLabel(point)
        let components = point.label.components(separatedBy: " - ")
        let time = dailyTarget == nil && components.count > 1 ? String(components[1].prefix(5)) : ""
        let valueWidth = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 15)]).width
        let dateWidth = max((date as NSString).size(withAttributes: [.font: font]).width, (time as NSString).size(withAttributes: [.font: font]).width)
        let width = min(bounds.width, max(valueWidth, dateWidth) + 20), height: CGFloat = date.isEmpty ? 36 : time.isEmpty ? 54 : 70
        let box = CGRect(x: max(0, min(bounds.width - width, x(point.position) - width / 2)), y: max(plot.minY + 4, min(bounds.height - height, y(point.value) - height - 8)), width: width, height: height)
        ThemeColor.rgb(0x555555, alpha: 0.8).setFill(); UIBezierPath(roundedRect: box, cornerRadius: 4).fill()
        drawText(text, x: box.midX, baseline: box.minY + 23, size: 15, color: .white)
        if !date.isEmpty { drawText(date, x: box.midX, baseline: box.minY + 42, color: .white) }
        if !time.isEmpty { drawText(time, x: box.midX, baseline: box.minY + 58, color: .white) }
    }
    private func drawSeriesBrackets() {
        func missed(_ left: CGFloat, _ right: CGFloat) {
            guard right >= plot.minX, left <= plot.maxX else { return }
            let a = max(plot.minX, left), b = min(plot.maxX, right), top = plot.minY - 37
            let red = ThemeColor.rgb(0xE05252), line = UIBezierPath()
            line.move(to: CGPoint(x: max(plot.minX, a - 9), y: top)); line.addLine(to: CGPoint(x: min(plot.maxX, b + 9), y: top))
            red.setStroke(); line.lineWidth = 2; line.stroke(); drawText("∅", x: (a + b) / 2, baseline: top - 7, size: 16, color: red)
        }
        for index in points.indices where index > 0 {
            if points[index].position - points[index - 1].position > 1.01, !connected(points[index - 1], points[index]) { missed(x(points[index - 1].position + 1), x(points[index - 1].position + 1)) }
        }
        func failed(_ index: Int) -> Bool {
            let point = points[index]
            return index < points.count - 1 && point.value < Double(point.dailyTarget ?? Int(dailyTarget ?? 1)) && !seriesRanges.contains { point.position > $0.start && point.position < $0.end }
        }
        var index = 0
        while index < points.count - 1 {
            if failed(index) {
                let left = x(points[index].position)
                while index + 1 < points.count - 1 && failed(index + 1) { index += 1 }
                missed(left, x(points[index].position))
            }
            index += 1
        }
        var previousRight = -CGFloat.greatestFiniteMagnitude
        for range in seriesRanges {
            guard x(range.end) >= plot.minX, x(range.start) <= plot.maxX else { continue }
            var left = max(plot.minX, x(range.start)), right = min(plot.maxX, x(range.end))
            if right - left < 26 { let center = (left + right) / 2; left = max(plot.minX, center - 13); right = min(plot.maxX, center + 13) }
            var mid = (left + right) / 2
            let top = plot.minY - 37, h: CGFloat = 7, brace = UIBezierPath()
            brace.move(to: CGPoint(x: left, y: top + h))
            brace.addCurve(to: CGPoint(x: mid - 8, y: top), controlPoint1: CGPoint(x: left, y: top), controlPoint2: CGPoint(x: left, y: top))
            brace.addCurve(to: CGPoint(x: mid, y: top - h), controlPoint1: CGPoint(x: mid - 2, y: top), controlPoint2: CGPoint(x: mid - 2, y: top - h))
            brace.addCurve(to: CGPoint(x: mid + 8, y: top), controlPoint1: CGPoint(x: mid + 2, y: top - h), controlPoint2: CGPoint(x: mid + 2, y: top))
            brace.addCurve(to: CGPoint(x: right, y: top + h), controlPoint1: CGPoint(x: right, y: top), controlPoint2: CGPoint(x: right, y: top))
            lineColor.setStroke(); brace.lineWidth = 1.2; brace.stroke()
            let label = String(format: CatalogText.ui("graph_series_days"), locale: Locale.current, range.count), half = (label as NSString).size(withAttributes: [.font: font]).width / 2
            mid = max(plot.minX + half, min(plot.maxX - half, mid))
            if mid - half >= previousRight + 4 { drawText(label, x: mid, baseline: top - h - 5); previousRight = mid + half }
        }
    }
}
