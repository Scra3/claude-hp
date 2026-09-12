import AppKit
import Security

// MARK: - Data

struct Gauge {
    var name: String
    var usedPct: Double
    var resetsAt: Date?
    var health: CGFloat { CGFloat(max(0, min(100, 100 - usedPct)) / 100) }
}

enum API {
    static let home = URL(fileURLWithPath: NSHomeDirectory())

    /// Claude Code's OAuth token. macOS asks for permission on first access.
    /// Never logged, never written to disk.
    private static func token() -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var out: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess,
              let d = out as? Data,
              let j = try? JSONSerialization.jsonObject(with: d) as? [String: Any],
              let o = j["claudeAiOauth"] as? [String: Any],
              let t = o["accessToken"] as? String, !t.isEmpty
        else { return nil }
        return t
    }

    private static let stamp: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func parse(_ data: Data) -> [Gauge] {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rows = root["limits"] as? [[String: Any]] else { return [] }

        return rows.compactMap { row in
            guard let kind = row["kind"] as? String,
                  let pct = row["percent"] as? Double else { return nil }

            let name: String
            switch kind {
            case "session": name = "SESSION 5H"
            case "weekly_all": name = "WEEK 7D"
            default:
                let scope = row["scope"] as? [String: Any]
                let model = scope?["model"] as? [String: Any]
                guard let display = model?["display_name"] as? String else { return nil }
                name = display.uppercased() + " 7D"
            }
            let reset = (row["resets_at"] as? String).flatMap { stamp.date(from: $0) }
            return Gauge(name: name, usedPct: pct, resetsAt: reset)
        }
    }

    static func fetch(_ done: @escaping ([Gauge]?) -> Void) {
        guard let t = token(),
              let url = URL(string: "https://api.anthropic.com/api/oauth/usage")
        else { done(nil); return }

        var r = URLRequest(url: url)
        r.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        r.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        r.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        r.timeoutInterval = 10
        r.cachePolicy = .reloadIgnoringLocalCacheData

        URLSession.shared.dataTask(with: r) { data, resp, _ in
            let ok = (resp as? HTTPURLResponse)?.statusCode == 200
            guard ok, let data else { done(nil); return }
            let gauges = parse(data)
            done(gauges.isEmpty ? nil : gauges)
        }.resume()
    }
}

// MARK: - Palette

enum Ink {
    static func hex(_ v: UInt32, _ a: CGFloat = 1) -> NSColor {
        NSColor(srgbRed: CGFloat((v >> 16) & 0xFF) / 255,
                green: CGFloat((v >> 8) & 0xFF) / 255,
                blue: CGFloat(v & 0xFF) / 255,
                alpha: a)
    }
    static let panel      = hex(0x0A0B0E, 0.99)
    static let panelEdge  = hex(0x2E3238)
    static let trackLo    = hex(0x101216)
    static let trackHi    = hex(0x272B32)
    static let chromeHi   = hex(0xD8DEE7)
    static let chromeLo   = hex(0x5A606B)
    static let healthHi   = hex(0xFFE968)
    static let healthLo   = hex(0xFF8A14)
    static let dangerHi   = hex(0xFF6B3D)
    static let dangerLo   = hex(0xE01B0C)
    static let trailHi    = hex(0xFF3B2F)
    static let trailLo    = hex(0x9E1A11)
    static let fableHi    = hex(0x8FD8FF)
    static let fableLo    = hex(0x3A8FD8)
    static let text       = hex(0xF2F4F7)
    static let textDim    = hex(0x8E96A3)
    static let textWarn   = hex(0xFF7A5C)
}

let SHEAR: CGFloat = 0.30

func para(_ r: NSRect) -> NSBezierPath {
    let s = SHEAR * r.height
    let p = NSBezierPath()
    p.move(to: NSPoint(x: r.minX, y: r.minY))
    p.line(to: NSPoint(x: r.maxX, y: r.minY))
    p.line(to: NSPoint(x: r.maxX + s, y: r.maxY))
    p.line(to: NSPoint(x: r.minX + s, y: r.maxY))
    p.close()
    return p
}

func slice(_ r: NSRect, _ a: CGFloat, _ b: CGFloat) -> NSRect {
    let lo = min(a, b), hi = max(a, b)
    return NSRect(x: r.minX + r.width * lo, y: r.minY, width: r.width * (hi - lo), height: r.height)
}

func din(_ size: CGFloat) -> NSFont {
    NSFont(name: "DINCondensed-Bold", size: size) ?? .systemFont(ofSize: size, weight: .heavy)
}

@discardableResult
func label(_ s: String, _ font: NSFont, _ color: NSColor, at p: NSPoint,
           tracking: CGFloat = 0, rightAlign: Bool = false, shear: Bool = true) -> CGFloat {
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.85)
    shadow.shadowOffset = NSSize(width: 0, height: -1)
    shadow.shadowBlurRadius = 2.5
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font, .foregroundColor: color, .kern: tracking, .shadow: shadow,
    ]
    let str = NSAttributedString(string: s, attributes: attrs)
    let w = str.size().width

    NSGraphicsContext.saveGraphicsState()
    let t = NSAffineTransform()
    t.transformStruct = NSAffineTransformStruct(
        m11: 1, m12: 0, m21: shear ? SHEAR : 0, m22: 1,
        tX: rightAlign ? p.x - w : p.x, tY: p.y)
    t.concat()
    str.draw(at: .zero)
    NSGraphicsContext.restoreGraphicsState()
    return w
}

func fmtCountdown(_ d: Date) -> String {
    let s = max(0, Int(d.timeIntervalSinceNow))
    let h = s / 3600, m = (s % 3600) / 60
    if h >= 24 { return "\(h / 24)D \(h % 24)H" }
    if h > 0 { return String(format: "%d:%02d", h, m) }
    return "\(m)M"
}

// MARK: - Vue

let ROW_PITCH: CGFloat = 62
let COMPACT_H: CGFloat = 82

func panelHeight(rows: Int) -> CGFloat { COMPACT_H + CGFloat(max(0, rows - 1)) * ROW_PITCH }

final class HUDView: NSView {
    var gauges: [Gauge] = []
    var expanded = false

    private var shown: [CGFloat] = []
    private var trail: [CGFloat] = []
    private var pulse: CGFloat = 0
    private var anim: Timer?

    var visibleRows: Int { expanded ? max(1, gauges.count) : 1 }

    func retarget() {
        let n = gauges.count
        if shown.count != n { shown = Array(repeating: 0, count: n); trail = shown }
        let targets = gauges.map(\.health)
        for i in 0..<n where trail[i] < targets[i] { trail[i] = targets[i] }
        animate(toward: targets)
    }

    private func animate(toward targets: [CGFloat]) {
        anim?.invalidate()
        guard !targets.isEmpty else { needsDisplay = true; return }
        anim = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            var moving = false
            for i in 0..<targets.count {
                let goal = targets[i]
                if abs(shown[i] - goal) > 0.0004 { shown[i] += (goal - shown[i]) * 0.18; moving = true }
                else { shown[i] = goal }
                if trail[i] > shown[i] + 0.0004 { trail[i] += (shown[i] - trail[i]) * 0.055; moving = true }
                else { trail[i] = shown[i] }
            }
            if targets.first.map({ $0 < 0.2 }) == true { pulse += 0.07; moving = true } else { pulse = 0 }
            needsDisplay = true
            if !moving { t.invalidate(); self.anim = nil }
        }
        RunLoop.main.add(anim!, forMode: .common)
    }

    // MARK: drawing

    override func draw(_ dirty: NSRect) {
        guard let ctx = NSGraphicsContext.current else { return }
        ctx.imageInterpolation = .high

        let body = bounds.insetBy(dx: 6, dy: 6)
        let shell = NSBezierPath(roundedRect: body, xRadius: 5, yRadius: 5)

        ctx.saveGraphicsState()
        let sh = NSShadow()
        sh.shadowColor = NSColor.black.withAlphaComponent(0.55)
        sh.shadowOffset = NSSize(width: 0, height: -3)
        sh.shadowBlurRadius = 12
        sh.set()
        Ink.panel.setFill()
        shell.fill()
        ctx.restoreGraphicsState()

        NSGradient(colors: [Ink.hex(0xFFFFFF, 0.06), Ink.hex(0xFFFFFF, 0.0)])?.draw(in: shell, angle: 90)
        Ink.panelEdge.setStroke()
        shell.lineWidth = 1
        shell.stroke()

        let x = body.minX + 14
        let w = body.width - 28

        guard !gauges.isEmpty else {
            drawRow(nil, idx: 0, y: body.maxY - 32, x: x, w: w)
            return
        }
        for i in 0..<visibleRows where i < gauges.count {
            drawRow(gauges[i], idx: i, y: body.maxY - 32 - CGFloat(i) * ROW_PITCH, x: x, w: w)
        }
    }

    private func drawRow(_ g: Gauge?, idx: Int, y: CGFloat, x: CGFloat, w: CGFloat) {
        let timerW: CGFloat = 98
        let barRect = NSRect(x: x, y: y, width: w - timerW - 18, height: 22)
        let frac = idx < shown.count ? shown[idx] : 0
        let tr = idx < trail.count ? trail[idx] : 0
        let danger = (g?.health ?? 1) < 0.2

        drawBar(barRect, frac: frac, trail: tr, danger: danger, live: g != nil,
                lo: danger ? Ink.dangerLo : Ink.healthLo,
                hi: danger ? Ink.dangerHi : Ink.healthHi)

        label(g?.name ?? "SESSION 5H", din(14), g != nil ? Ink.text : Ink.textDim,
              at: NSPoint(x: x, y: y - 17), tracking: 2.2)

        label(g.map { "\(Int(($0.health * 100).rounded()))%" } ?? "—", din(17),
              danger && g != nil ? Ink.textWarn : Ink.text,
              at: NSPoint(x: barRect.maxX + SHEAR * 22, y: y - 18), tracking: 0.5, rightAlign: true)

        let tx = x + w
        if let reset = g?.resetsAt {
            label(fmtCountdown(reset), din(34), Ink.text,
                  at: NSPoint(x: tx, y: y - 4), tracking: -0.5, rightAlign: true)
            label("RESET", din(10), Ink.textDim,
                  at: NSPoint(x: tx, y: y - 17), tracking: 2.4, rightAlign: true)
        } else {
            label("—", din(34), Ink.textDim, at: NSPoint(x: tx, y: y - 4), rightAlign: true)
            label(g == nil ? "NO SIGNAL" : "", din(10), Ink.textDim,
                  at: NSPoint(x: tx, y: y - 17), tracking: 1.6, rightAlign: true)
        }
    }

    // MARK: bar parts

    private func drawTrack(_ r: NSRect) {
        let p = para(r)
        NSGradient(colors: [Ink.trackLo, Ink.trackHi])?.draw(in: p, angle: 90)

        NSGraphicsContext.saveGraphicsState()
        p.setClip()
        Ink.hex(0xFFFFFF, 0.05).setStroke()
        let stripes = NSBezierPath()
        stripes.lineWidth = 3
        var sx = r.minX - r.height
        while sx < r.maxX + r.height * 2 {
            stripes.move(to: NSPoint(x: sx, y: r.minY))
            stripes.line(to: NSPoint(x: sx + r.height, y: r.maxY))
            sx += 9
        }
        stripes.stroke()
        NSGradient(colors: [Ink.hex(0x000000, 0.0), Ink.hex(0x000000, 0.6)])?.draw(in: p, angle: 90)
        NSGraphicsContext.restoreGraphicsState()
    }

    private func gloss(_ r: NSRect) {
        let top = NSRect(x: r.minX, y: r.midY, width: r.width, height: r.height / 2)
        NSGraphicsContext.saveGraphicsState()
        para(r).setClip()
        NSGradient(colors: [Ink.hex(0xFFFFFF, 0.30), Ink.hex(0xFFFFFF, 0.02)])?.draw(in: para(top), angle: -90)
        NSGraphicsContext.restoreGraphicsState()
    }

    private func edge(_ r: NSRect, at f: CGFloat, color: NSColor) {
        let ex = r.minX + r.width * f
        NSGraphicsContext.saveGraphicsState()
        para(r).setClip()
        color.setFill()
        para(NSRect(x: ex - 1.4, y: r.minY, width: 2.8, height: r.height)).fill()
        NSGraphicsContext.restoreGraphicsState()
    }

    private func frame(_ r: NSRect) {
        let p = para(r)
        Ink.hex(0x000000, 0.9).setStroke()
        p.lineWidth = 2.5
        p.stroke()

        NSGraphicsContext.saveGraphicsState()
        p.setClip()
        p.lineWidth = 2
        Ink.chromeLo.setStroke()
        p.stroke()
        let s = SHEAR * r.height
        let hi = NSBezierPath()
        hi.move(to: NSPoint(x: r.minX + s, y: r.maxY - 0.8))
        hi.line(to: NSPoint(x: r.maxX + s, y: r.maxY - 0.8))
        hi.lineWidth = 1.6
        Ink.chromeHi.setStroke()
        hi.stroke()
        NSGraphicsContext.restoreGraphicsState()
    }

    private func drawBar(_ r: NSRect, frac: CGFloat, trail t: CGFloat,
                         danger: Bool, live: Bool, lo: NSColor, hi: NSColor) {
        drawTrack(r)
        guard live else { frame(r); return }

        if t > frac + 0.002 {
            NSGraphicsContext.saveGraphicsState()
            para(slice(r, frac, t)).setClip()
            NSGradient(colors: [Ink.trailLo, Ink.trailHi])?.draw(in: para(r), angle: 90)
            NSGraphicsContext.restoreGraphicsState()
        }

        if frac > 0.001 {
            let boost = danger ? 0.10 * (sin(pulse) * 0.5 + 0.5) : 0
            NSGraphicsContext.saveGraphicsState()
            para(slice(r, 0, frac)).setClip()
            NSGradient(colors: [lo.blended(withFraction: boost, of: .white) ?? lo,
                                hi.blended(withFraction: boost, of: .white) ?? hi])?
                .draw(in: para(r), angle: 0)
            NSGraphicsContext.restoreGraphicsState()
            gloss(NSRect(x: r.minX, y: r.minY, width: r.width * frac, height: r.height))
            edge(r, at: frac, color: Ink.hex(0xFFF6D6, 0.95))
        }
        frame(r)
    }

    // MARK: interaction

    override func mouseDown(with e: NSEvent) {
        if e.clickCount == 1 { (window?.delegate as? AppDelegate)?.toggle() }
        window?.performDrag(with: e)
    }

    override func rightMouseDown(with e: NSEvent) {
        (window?.delegate as? AppDelegate)?.showMenu(e, in: self)
    }
}

// MARK: - App

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let panel = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: COMPACT_H),
                         styleMask: .borderless, backing: .buffered, defer: false)
    let view = HUDView()
    var expanded = false
    private let agent = URL(fileURLWithPath: NSHomeDirectory())
        .appendingPathComponent("Library/LaunchAgents/com.alban.claudehp.plist")

    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.accessory)

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.contentView = view
        panel.delegate = self

        if let s = UserDefaults.standard.string(forKey: "origin") {
            panel.setFrameOrigin(NSPointFromString(s))
        } else if let vis = NSScreen.main?.visibleFrame {
            panel.setFrameOrigin(NSPoint(x: vis.maxX - 520, y: vis.maxY - 102))
        }
        expanded = UserDefaults.standard.bool(forKey: "expanded")
        view.expanded = expanded
        panel.orderFrontRegardless()

        refresh()
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in self.refresh() }
        // The RESET countdown has to keep moving even when the percentages do not.
        Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in self.view.needsDisplay = true }
    }

    func windowDidMove(_ n: Notification) {
        UserDefaults.standard.set(NSStringFromPoint(panel.frame.origin), forKey: "origin")
    }

    private func refresh() {
        // SecItemCopyMatching can open the keychain dialog and block: never on the main thread.
        DispatchQueue.global(qos: .utility).async {
            API.fetch { gauges in
            DispatchQueue.main.async {
                guard let gauges else { return }
                let had = self.view.gauges.count
                self.view.gauges = gauges
                self.view.retarget()
                if gauges.count != had { self.resize(animated: false) }
                }
            }
        }
    }

    private func resize(animated: Bool) {
        let h = panelHeight(rows: view.visibleRows)
        guard abs(panel.frame.height - h) > 0.5 else { return }
        var f = panel.frame
        f.origin.y = f.maxY - h
        f.size.height = h
        panel.setFrame(f, display: true, animate: animated)
    }

    func toggle() {
        expanded.toggle()
        UserDefaults.standard.set(expanded, forKey: "expanded")
        view.expanded = expanded
        resize(animated: true)
        view.retarget()
    }

    func showMenu(_ e: NSEvent, in v: NSView) {
        let m = NSMenu()
        let launch = NSMenuItem(title: "Launch at login", action: #selector(toggleLaunch), keyEquivalent: "")
        launch.target = self
        launch.state = FileManager.default.fileExists(atPath: agent.path) ? .on : .off
        m.addItem(launch)
        m.addItem(.separator())
        m.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        NSMenu.popUpContextMenu(m, with: e, for: v)
    }

    @objc private func toggleLaunch() {
        let fm = FileManager.default
        if fm.fileExists(atPath: agent.path) { try? fm.removeItem(at: agent); return }
        let exe = Bundle.main.executablePath ?? CommandLine.arguments[0]
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
          <key>Label</key><string>com.alban.claudehp</string>
          <key>ProgramArguments</key><array><string>\(exe)</string></array>
          <key>RunAtLoad</key><true/>
        </dict></plist>
        """
        try? fm.createDirectory(at: agent.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? plist.write(to: agent, atomically: true, encoding: .utf8)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
