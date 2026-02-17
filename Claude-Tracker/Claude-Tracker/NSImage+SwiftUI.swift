//
//  NSImage+CustomIcons.swift
//  Claude-Tracker
//
//  Custom menubar icons drawn with CoreGraphics
//

import AppKit

extension NSImage {
    /// Creates a custom Claude C icon
    static func claudeCIcon(size: CGSize = CGSize(width: 16, height: 16)) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return image
        }

        // Set up drawing
        NSColor.controlTextColor.setStroke()

        let lineWidth: CGFloat = 2.0
        let arcSize = size.width * 0.80  // Increased from 0.55 to fill more space
        let centerX = size.width / 2
        let centerY = size.height / 2

        // Draw C shape (arc)
        let path = NSBezierPath()
        path.appendArc(
            withCenter: CGPoint(x: centerX, y: centerY),
            radius: arcSize / 2,
            startAngle: 50,   // Slightly adjusted angles
            endAngle: 310,
            clockwise: false
        )
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.stroke()

        // Add one small sparkle dot (simplified)
        let dotSize: CGFloat = 2.5
        let sparkleX = size.width * 0.72
        let sparkleY = size.height * 0.28

        NSColor.controlTextColor.setFill()
        let dotRect = CGRect(
            x: sparkleX - dotSize / 2,
            y: sparkleY - dotSize / 2,
            width: dotSize,
            height: dotSize
        )
        let dotPath = NSBezierPath(ovalIn: dotRect)
        dotPath.fill()

        image.unlockFocus()
        image.isTemplate = true

        return image
    }

    /// Creates a token counter icon (three stacked dots)
    static func tokenCounterIcon(size: CGSize = CGSize(width: 16, height: 16)) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        let dotSize: CGFloat = size.width * 0.22
        let centerX = size.width / 2

        // Three dots vertically stacked
        let positions: [CGFloat] = [
            size.height * 0.25,
            size.height * 0.5,
            size.height * 0.75
        ]

        NSColor.controlTextColor.setFill()
        for yPos in positions {
            let rect = CGRect(
                x: centerX - dotSize / 2,
                y: yPos - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            let path = NSBezierPath(ovalIn: rect)
            path.fill()
        }

        // Small accent dot to the right
        let accentDot = CGRect(
            x: centerX + dotSize,
            y: positions[1] - dotSize * 0.3 / 2,
            width: dotSize * 0.3,
            height: dotSize * 0.3
        )
        NSBezierPath(ovalIn: accentDot).fill()

        image.unlockFocus()
        image.isTemplate = true

        return image
    }

    /// Creates a chart dots icon (upward trend)
    static func chartDotsIcon(size: CGSize = CGSize(width: 16, height: 16)) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        let dotSize: CGFloat = 3.5

        // Four dots in upward trend
        let points: [(x: CGFloat, y: CGFloat)] = [
            (size.width * 0.15, size.height * 0.75),
            (size.width * 0.38, size.height * 0.55),
            (size.width * 0.62, size.height * 0.35),
            (size.width * 0.85, size.height * 0.20)
        ]

        // Draw connecting lines
        NSColor.controlTextColor.withAlphaComponent(0.4).setStroke()
        let linePath = NSBezierPath()
        linePath.move(to: CGPoint(x: points[0].x, y: points[0].y))
        for point in points.dropFirst() {
            linePath.line(to: CGPoint(x: point.x, y: point.y))
        }
        linePath.lineWidth = 1.0
        linePath.stroke()

        // Draw dots
        NSColor.controlTextColor.setFill()
        for point in points {
            let rect = CGRect(
                x: point.x - dotSize / 2,
                y: point.y - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            let path = NSBezierPath(ovalIn: rect)
            path.fill()
        }

        image.unlockFocus()
        image.isTemplate = true

        return image
    }
}
