import AppKit
import QuartzCore

/// A small festive tree drawn in the desktop overlay. Its coloured lights twinkle independently
/// without involving the snow simulation or intercepting mouse events.
final class ChristmasTreeView: NSView {
    private var lightTimer: Timer?
    private var phase: CGFloat = 0

    override var isFlipped: Bool { false }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        let timer = Timer(timeInterval: 1.0 / 12.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            phase += 0.16
            needsDisplay = true
        }
        lightTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { lightTimer?.invalidate() }

    override func draw(_ dirtyRect: NSRect) {
        guard bounds.width > 20, bounds.height > 30 else { return }
        let w = bounds.width
        let cx = w * 0.5
        // A subtle vertical stretch makes the tree a little taller without changing its footprint.
        NSGraphicsContext.saveGraphicsState()
        let treeScale = NSAffineTransform()
        treeScale.scaleX(by: 1.0, yBy: 1.10)
        treeScale.concat()

        // Soft pool of light beneath the tree.
        NSColor(calibratedWhite: 1, alpha: 0.13).setFill()
        NSBezierPath(ovalIn: NSRect(x: cx - 49, y: 5, width: 98, height: 15)).fill()

        // Trunk and the three overlapping evergreen tiers.
        NSColor(calibratedRed: 0.36, green: 0.19, blue: 0.09, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: cx - 8, y: 12, width: 16, height: 27), xRadius: 3, yRadius: 3).fill()

        let tiers: [(CGFloat, CGFloat, CGFloat)] = [
            (cx, 43, 94), (cx, 72, 78), (cx, 101, 61)
        ]
        for (center, baseY, width) in tiers {
            let path = NSBezierPath()
            path.move(to: NSPoint(x: center, y: baseY + 62))
            path.curve(to: NSPoint(x: center - width / 2, y: baseY),
                       controlPoint1: NSPoint(x: center - 15, y: baseY + 47),
                       controlPoint2: NSPoint(x: center - width * 0.30, y: baseY + 8))
            path.curve(to: NSPoint(x: center + width / 2, y: baseY),
                       controlPoint1: NSPoint(x: center - width * 0.22, y: baseY + 5),
                       controlPoint2: NSPoint(x: center + width * 0.30, y: baseY + 8))
            path.curve(to: NSPoint(x: center, y: baseY + 62),
                       controlPoint1: NSPoint(x: center + 15, y: baseY + 47),
                       controlPoint2: NSPoint(x: center + 10, y: baseY + 58))
            path.close()
            NSColor(calibratedRed: 0.035, green: 0.31, blue: 0.16, alpha: 1).setFill()
            path.fill()
            NSColor(calibratedRed: 0.12, green: 0.48, blue: 0.25, alpha: 0.9).setStroke()
            path.lineWidth = 1.2
            path.stroke()
        }

        // A little snow resting on the branch tips.
        NSColor(calibratedWhite: 1, alpha: 0.92).setStroke()
        let snowLines: [(NSPoint, NSPoint)] = [
            (NSPoint(x: cx - 36, y: 48), NSPoint(x: cx - 20, y: 52)),
            (NSPoint(x: cx + 20, y: 52), NSPoint(x: cx + 37, y: 48)),
            (NSPoint(x: cx - 29, y: 78), NSPoint(x: cx - 15, y: 82)),
            (NSPoint(x: cx + 15, y: 82), NSPoint(x: cx + 29, y: 78)),
            (NSPoint(x: cx - 20, y: 108), NSPoint(x: cx - 10, y: 111)),
            (NSPoint(x: cx + 10, y: 111), NSPoint(x: cx + 20, y: 108))
        ]
        for (start, end) in snowLines {
            let line = NSBezierPath()
            line.lineWidth = 2.5
            line.lineCapStyle = .round
            line.move(to: start)
            line.line(to: end)
            line.stroke()
        }

        // Coloured bulbs twinkle in a repeating, offset sequence.
        let bulbs: [(CGFloat, CGFloat)] = [
            (-20, 48), (17, 51), (-31, 66), (29, 70), (-17, 80), (8, 87),
            (-23, 101), (22, 105), (-9, 116), (7, 128), (0, 94), (0, 62)
        ]
        let palette: [NSColor] = [
            NSColor(calibratedRed: 1.0, green: 0.18, blue: 0.20, alpha: 1),
            NSColor(calibratedRed: 0.18, green: 0.72, blue: 1.0, alpha: 1),
            NSColor(calibratedRed: 1.0, green: 0.78, blue: 0.12, alpha: 1),
            NSColor(calibratedRed: 0.45, green: 1.0, blue: 0.35, alpha: 1),
            NSColor(calibratedRed: 0.95, green: 0.35, blue: 0.92, alpha: 1)
        ]
        for (index, point) in bulbs.enumerated() {
            let pulse = (sin(phase + CGFloat(index) * 1.17) + 1) * 0.5
            let radius: CGFloat = 3.0 + pulse * 1.0
            let color = palette[index % palette.count]
            let bulbRect = NSRect(x: cx + point.0 - radius, y: point.1 - radius,
                                  width: radius * 2, height: radius * 2)
            let glow = NSBezierPath(ovalIn: bulbRect.insetBy(dx: -3.5, dy: -3.5))
            color.withAlphaComponent(0.12 + pulse * 0.18).setFill()
            glow.fill()
            color.withAlphaComponent(0.58 + pulse * 0.42).setFill()
            NSBezierPath(ovalIn: bulbRect).fill()
            NSColor(calibratedWhite: 1, alpha: 0.75).setFill()
            NSBezierPath(ovalIn: NSRect(x: bulbRect.minX + 1, y: bulbRect.minY + radius,
                                        width: 1.8, height: 1.8)).fill()
        }

        // Gold star with a subtle glow.
        let starCenter = NSPoint(x: cx, y: 165)
        let starGlow = NSBezierPath(ovalIn: NSRect(x: cx - 12, y: 153, width: 24, height: 24))
        NSColor(calibratedRed: 1, green: 0.78, blue: 0.18, alpha: 0.18).setFill()
        starGlow.fill()
        let star = NSBezierPath()
        for index in 0..<10 {
            let angle = CGFloat(index) * .pi / 5 - .pi / 2
            let radius: CGFloat = index.isMultiple(of: 2) ? 9 : 4
            let point = NSPoint(x: starCenter.x + cos(angle) * radius,
                                y: starCenter.y + sin(angle) * radius)
            if index == 0 { star.move(to: point) } else { star.line(to: point) }
        }
        star.close()
        NSColor(calibratedRed: 1, green: 0.79, blue: 0.20, alpha: 1).setFill()
        star.fill()
        NSColor(calibratedRed: 1, green: 0.94, blue: 0.60, alpha: 1).setStroke()
        star.lineWidth = 0.8
        star.stroke()

        // Two tiny presents under the tree.
        drawPresent(at: NSPoint(x: cx - 31, y: 13), size: NSSize(width: 23, height: 18), color: NSColor(calibratedRed: 0.82, green: 0.12, blue: 0.18, alpha: 1))
        drawPresent(at: NSPoint(x: cx + 8, y: 13), size: NSSize(width: 25, height: 21), color: NSColor(calibratedRed: 0.12, green: 0.38, blue: 0.82, alpha: 1))
        NSGraphicsContext.restoreGraphicsState()
    }

    private func drawPresent(at origin: NSPoint, size: NSSize, color: NSColor) {
        let box = NSRect(origin: origin, size: size)
        color.setFill()
        NSBezierPath(roundedRect: box, xRadius: 2, yRadius: 2).fill()
        NSColor(calibratedRed: 1, green: 0.82, blue: 0.28, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: box.midX - 2, y: box.minY, width: 4, height: box.height)).fill()
        NSBezierPath(rect: NSRect(x: box.minX, y: box.midY - 2, width: box.width, height: 4)).fill()
        let bow = NSBezierPath()
        bow.lineWidth = 2
        bow.appendOval(in: NSRect(x: box.midX - 7, y: box.maxY - 1, width: 7, height: 5))
        bow.appendOval(in: NSRect(x: box.midX, y: box.maxY - 1, width: 7, height: 5))
        bow.stroke()
    }
}
