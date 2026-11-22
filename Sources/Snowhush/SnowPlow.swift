import AppKit

/// A lightweight cartoon snowplow that makes one left-to-right pass and exits the display.
/// Its blade callback follows the leading edge so the simulation gathers snow into a windrow.
final class SnowPlowView: NSView {
    private var timer: Timer?
    private var x: CGFloat = -160
    private var y: CGFloat = 0
    private var wheelAngle: CGFloat = 0
    private var beaconPhase: CGFloat = 0
    private let speed: CGFloat = 250
    private let wheelRadius: CGFloat = 13.5
    private let vehicleWidth: CGFloat = 145
    var onSweep: ((SIMD2<Float>?) -> Void)?
    private(set) var isRunning = false
    override var isFlipped: Bool { false }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        x = -vehicleWidth - 12
        y = 0
        wheelAngle = 0
        beaconPhase = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in self?.advance() }
        publishSweep()
        needsDisplay = true
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        onSweep?(nil)
        needsDisplay = true
    }

    private func publishSweep() {
        // The blade stays at the front of the truck: this version only travels left-to-right.
        let bladeX = x + 139
        onSweep?(SIMD2(Float(bladeX), Float(y + 27)))
    }

    private func advance() {
        guard isRunning else { return }
        let dt = CGFloat(1.0 / 60.0)
        let oldX = x
        x += speed * dt
        wheelAngle -= (x - oldX) / wheelRadius
        beaconPhase += dt * 7.5

        // Continue a little beyond the right edge so the whole vehicle exits cleanly.
        if x > bounds.width + 12 {
            stop()
            return
        }

        publishSweep()
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard isRunning else { return }
        NSGraphicsContext.saveGraphicsState()
        let y = self.y

        // Soft ground shadow makes the vehicle read as one solid machine.
        NSColor(calibratedWhite: 0.08, alpha: 0.20).setFill()
        NSBezierPath(ovalIn: NSRect(x: x + 13, y: y - 1, width: 119, height: 9)).fill()

        // Rear chassis and lower frame.
        let frame = NSBezierPath(roundedRect: NSRect(x: x + 17, y: y + 10, width: 99, height: 15),
                                 xRadius: 5, yRadius: 5)
        NSColor(calibratedRed: 0.19, green: 0.22, blue: 0.24, alpha: 1).setFill()
        frame.fill()
        let chassis = NSBezierPath()
        chassis.move(to: NSPoint(x: x + 17, y: y + 21))
        chassis.line(to: NSPoint(x: x + 20, y: y + 42))
        chassis.curve(to: NSPoint(x: x + 42, y: y + 49), controlPoint1: NSPoint(x: x + 25, y: y + 49), controlPoint2: NSPoint(x: x + 33, y: y + 49))
        chassis.line(to: NSPoint(x: x + 91, y: y + 49))
        chassis.curve(to: NSPoint(x: x + 108, y: y + 34), controlPoint1: NSPoint(x: x + 104, y: y + 48), controlPoint2: NSPoint(x: x + 108, y: y + 42))
        chassis.line(to: NSPoint(x: x + 112, y: y + 17))
        chassis.close()
        NSColor(calibratedRed: 0.96, green: 0.49, blue: 0.075, alpha: 1).setFill()
        chassis.fill()
        NSColor(calibratedRed: 0.67, green: 0.27, blue: 0.035, alpha: 1).setStroke()
        chassis.lineWidth = 1.8
        chassis.stroke()

        // Side panel, accent stripe and rear service hatch.
        let sidePanel = NSBezierPath(roundedRect: NSRect(x: x + 25, y: y + 27, width: 29, height: 12), xRadius: 3, yRadius: 3)
        NSColor(calibratedRed: 1.0, green: 0.68, blue: 0.16, alpha: 1).setFill()
        sidePanel.fill()
        let stripe = NSBezierPath()
        stripe.move(to: NSPoint(x: x + 22, y: y + 25))
        stripe.line(to: NSPoint(x: x + 103, y: y + 25))
        stripe.lineWidth = 3
        NSColor(calibratedRed: 1.0, green: 0.79, blue: 0.22, alpha: 1).setStroke()
        stripe.stroke()
        let hatch = NSBezierPath(roundedRect: NSRect(x: x + 28, y: y + 31, width: 17, height: 8), xRadius: 2, yRadius: 2)
        NSColor(calibratedRed: 0.86, green: 0.36, blue: 0.055, alpha: 1).setFill()
        hatch.fill()

        // Cab: integrated sloped windshield and roof, not a floating box.
        let cab = NSBezierPath()
        cab.move(to: NSPoint(x: x + 52, y: y + 43))
        cab.line(to: NSPoint(x: x + 57, y: y + 76))
        cab.curve(to: NSPoint(x: x + 69, y: y + 84), controlPoint1: NSPoint(x: x + 59, y: y + 83), controlPoint2: NSPoint(x: x + 63, y: y + 84))
        cab.line(to: NSPoint(x: x + 91, y: y + 84))
        cab.curve(to: NSPoint(x: x + 101, y: y + 74), controlPoint1: NSPoint(x: x + 99, y: y + 84), controlPoint2: NSPoint(x: x + 101, y: y + 80))
        cab.line(to: NSPoint(x: x + 104, y: y + 43))
        cab.close()
        NSColor(calibratedRed: 1.0, green: 0.66, blue: 0.13, alpha: 1).setFill()
        cab.fill()
        NSColor(calibratedRed: 0.67, green: 0.27, blue: 0.035, alpha: 1).setStroke()
        cab.lineWidth = 1.8
        cab.stroke()

        // Large blue glass with a subtle reflection.
        let glass = NSBezierPath()
        glass.move(to: NSPoint(x: x + 62, y: y + 48))
        glass.line(to: NSPoint(x: x + 66, y: y + 75))
        glass.curve(to: NSPoint(x: x + 72, y: y + 79), controlPoint1: NSPoint(x: x + 67, y: y + 79), controlPoint2: NSPoint(x: x + 69, y: y + 79))
        glass.line(to: NSPoint(x: x + 89, y: y + 79))
        glass.curve(to: NSPoint(x: x + 94, y: y + 74), controlPoint1: NSPoint(x: x + 93, y: y + 79), controlPoint2: NSPoint(x: x + 94, y: y + 77))
        glass.line(to: NSPoint(x: x + 97, y: y + 48))
        glass.close()
        NSColor(calibratedRed: 0.20, green: 0.60, blue: 0.78, alpha: 1).setFill()
        glass.fill()
        NSColor(calibratedRed: 0.08, green: 0.25, blue: 0.35, alpha: 1).setStroke()
        glass.lineWidth = 2
        glass.stroke()
        let reflection = NSBezierPath()
        reflection.move(to: NSPoint(x: x + 70, y: y + 73))
        reflection.line(to: NSPoint(x: x + 74, y: y + 77))
        reflection.line(to: NSPoint(x: x + 80, y: y + 77))
        reflection.lineWidth = 2
        NSColor(calibratedWhite: 1, alpha: 0.48).setStroke()
        reflection.stroke()
        // Cab pillar and door handle.
        let pillar = NSBezierPath()
        pillar.move(to: NSPoint(x: x + 82, y: y + 47))
        pillar.line(to: NSPoint(x: x + 82, y: y + 80))
        pillar.lineWidth = 2
        NSColor(calibratedRed: 0.72, green: 0.31, blue: 0.045, alpha: 1).setStroke()
        pillar.stroke()
        let handle = NSBezierPath(roundedRect: NSRect(x: x + 86, y: y + 42, width: 5, height: 2), xRadius: 1, yRadius: 1)
        NSColor(calibratedWhite: 0.24, alpha: 1).setFill()
        handle.fill()

        // Front grille and reinforced bumper.
        let grille = NSBezierPath(roundedRect: NSRect(x: x + 105, y: y + 29, width: 8, height: 17), xRadius: 2, yRadius: 2)
        NSColor(calibratedRed: 0.13, green: 0.19, blue: 0.22, alpha: 1).setFill()
        grille.fill()
        for lineIndex in 0..<4 {
            let yy = y + 32 + CGFloat(lineIndex) * 3.5
            let line = NSBezierPath()
            line.move(to: NSPoint(x: x + 107, y: yy))
            line.line(to: NSPoint(x: x + 111, y: yy))
            line.lineWidth = 1
            NSColor(calibratedWhite: 0.62, alpha: 1).setStroke()
            line.stroke()
        }
        let bumper = NSBezierPath(roundedRect: NSRect(x: x + 105, y: y + 8, width: 17, height: 8), xRadius: 3, yRadius: 3)
        NSColor(calibratedWhite: 0.25, alpha: 1).setFill()
        bumper.fill()
        NSColor(calibratedWhite: 0.48, alpha: 1).setStroke()
        bumper.lineWidth = 1
        bumper.stroke()

        // Snowplow blade: curved steel with a dark cutting edge at snow level.
        let blade = NSBezierPath()
        blade.move(to: NSPoint(x: x + 111, y: y + 5))
        blade.curve(to: NSPoint(x: x + 146, y: y + 17), controlPoint1: NSPoint(x: x + 121, y: y + 1), controlPoint2: NSPoint(x: x + 139, y: y + 5))
        blade.line(to: NSPoint(x: x + 137, y: y + 48))
        blade.curve(to: NSPoint(x: x + 108, y: y + 39), controlPoint1: NSPoint(x: x + 132, y: y + 46), controlPoint2: NSPoint(x: x + 116, y: y + 44))
        blade.close()
        NSColor(calibratedRed: 0.76, green: 0.83, blue: 0.87, alpha: 1).setFill()
        blade.fill()
        NSColor(calibratedWhite: 0.34, alpha: 1).setStroke()
        blade.lineWidth = 2
        blade.stroke()
        let bladeHighlight = NSBezierPath()
        bladeHighlight.move(to: NSPoint(x: x + 116, y: y + 36))
        bladeHighlight.curve(to: NSPoint(x: x + 134, y: y + 43), controlPoint1: NSPoint(x: x + 123, y: y + 40), controlPoint2: NSPoint(x: x + 129, y: y + 42))
        bladeHighlight.lineWidth = 2
        NSColor(calibratedWhite: 1, alpha: 0.72).setStroke()
        bladeHighlight.stroke()
        let cuttingEdge = NSBezierPath()
        cuttingEdge.move(to: NSPoint(x: x + 111, y: y + 5))
        cuttingEdge.curve(to: NSPoint(x: x + 146, y: y + 17), controlPoint1: NSPoint(x: x + 121, y: y + 1), controlPoint2: NSPoint(x: x + 139, y: y + 5))
        cuttingEdge.lineWidth = 3
        NSColor(calibratedWhite: 0.22, alpha: 1).setStroke()
        cuttingEdge.stroke()

        // Two visible chunky tyres with animated tread and rotating hubs.
        for wheelX in [x + 37, x + 91] {
            let center = NSPoint(x: wheelX, y: y + 15.5)
            let tyreRect = NSRect(x: center.x - wheelRadius, y: center.y - wheelRadius,
                                  width: wheelRadius * 2, height: wheelRadius * 2)
            let tyre = NSBezierPath(ovalIn: tyreRect)
            NSColor(calibratedWhite: 0.09, alpha: 1).setFill()
            tyre.fill()
            NSColor(calibratedWhite: 0.31, alpha: 1).setStroke()
            tyre.lineWidth = 1.5
            tyre.stroke()
            NSColor(calibratedWhite: 0.27, alpha: 1).setFill()
            for treadIndex in 0..<12 {
                let angle = CGFloat(treadIndex) * (.pi / 6) + wheelAngle
                let tread = NSBezierPath(roundedRect: NSRect(x: center.x - 2.2,
                                                               y: center.y + wheelRadius - 3.2,
                                                               width: 4.4, height: 5.2),
                                         xRadius: 1.2, yRadius: 1.2)
                let transform = NSAffineTransform()
                transform.translateX(by: center.x, yBy: center.y)
                transform.rotate(byRadians: angle)
                transform.translateX(by: -center.x, yBy: -center.y)
                tread.transform(using: transform as AffineTransform)
                tread.fill()
            }
            let rim = NSBezierPath(ovalIn: NSRect(x: center.x - 8.2, y: center.y - 8.2, width: 16.4, height: 16.4))
            NSColor(calibratedRed: 0.91, green: 0.56, blue: 0.13, alpha: 1).setFill()
            rim.fill()
            NSColor(calibratedRed: 0.47, green: 0.28, blue: 0.09, alpha: 1).setStroke()
            rim.lineWidth = 1
            rim.stroke()
            for spokeIndex in 0..<6 {
                let angle = wheelAngle + CGFloat(spokeIndex) * (.pi / 3)
                let spoke = NSBezierPath()
                spoke.lineWidth = 2.1
                spoke.lineCapStyle = .round
                spoke.move(to: center)
                spoke.line(to: NSPoint(x: center.x + cos(angle) * 5.7, y: center.y + sin(angle) * 5.7))
                NSColor(calibratedWhite: 0.20, alpha: 1).setStroke()
                spoke.stroke()
            }
            let axle = NSBezierPath(ovalIn: NSRect(x: center.x - 2.5, y: center.y - 2.5, width: 5, height: 5))
            NSColor(calibratedWhite: 0.16, alpha: 1).setFill()
            axle.fill()
        }

        // Headlight glow and warm lamp. The glow is deliberately subtle.
        let glow = NSBezierPath(ovalIn: NSRect(x: x + 111, y: y + 43, width: 22, height: 17))
        NSColor(calibratedRed: 1, green: 0.83, blue: 0.30, alpha: 0.16).setFill()
        glow.fill()
        let lamp = NSBezierPath(roundedRect: NSRect(x: x + 109, y: y + 43, width: 9, height: 8), xRadius: 3, yRadius: 3)
        NSColor(calibratedRed: 1, green: 0.97, blue: 0.68, alpha: 1).setFill()
        lamp.fill()
        NSColor(calibratedRed: 1, green: 0.82, blue: 0.30, alpha: 1).setStroke()
        lamp.lineWidth = 1
        lamp.stroke()

        // Amber rotating beacon on the roof, pulsing independently of wheel motion.
        let beaconGlowAlpha = 0.12 + 0.16 * (0.5 + 0.5 * sin(beaconPhase))
        let beaconGlow = NSBezierPath(ovalIn: NSRect(x: x + 69, y: y + 82, width: 25, height: 13))
        NSColor(calibratedRed: 1, green: 0.57, blue: 0.04, alpha: beaconGlowAlpha).setFill()
        beaconGlow.fill()
        let beaconBase = NSBezierPath(roundedRect: NSRect(x: x + 74, y: y + 82, width: 15, height: 3), xRadius: 1, yRadius: 1)
        NSColor(calibratedWhite: 0.22, alpha: 1).setFill()
        beaconBase.fill()
        let beacon = NSBezierPath(roundedRect: NSRect(x: x + 76, y: y + 85, width: 11, height: 7), xRadius: 3, yRadius: 3)
        NSColor(calibratedRed: 1, green: 0.52 + 0.20 * (0.5 + 0.5 * sin(beaconPhase)), blue: 0.04, alpha: 1).setFill()
        beacon.fill()
        NSColor(calibratedRed: 1, green: 0.88, blue: 0.48, alpha: 0.9).setStroke()
        beacon.lineWidth = 1
        beacon.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }
}
