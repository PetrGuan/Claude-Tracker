//
//  MenuBarIcon.swift
//  Claude-Tracker
//
//  Custom drawn menubar icons (AI-generated)
//

import SwiftUI

/// Custom icon designs for the menubar
enum MenuBarIconStyle {
    case tokenCounter   // Stylized counter with dots
    case chartDots      // Minimal chart with dots
    case claudeC        // Letter C with sparkle
}

struct MenuBarIconView: View {
    let style: MenuBarIconStyle

    var body: some View {
        switch style {
        case .tokenCounter:
            TokenCounterIcon()
        case .chartDots:
            ChartDotsIcon()
        case .claudeC:
            ClaudeCIcon()
        }
    }
}

// MARK: - Token Counter Icon (Recommended)

/// Three stacked dots representing tokens/counting
struct TokenCounterIcon: View {
    var body: some View {
        Canvas { context, size in
            let dotSize: CGFloat = size.width * 0.22
            let spacing: CGFloat = size.height * 0.12
            let centerX = size.width / 2

            // Three dots vertically stacked
            let positions: [CGFloat] = [
                size.height * 0.25,
                size.height * 0.5,
                size.height * 0.75
            ]

            for yPos in positions {
                let rect = CGRect(
                    x: centerX - dotSize / 2,
                    y: yPos - dotSize / 2,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(.primary)
                )
            }

            // Small accent dot to the right (token sparkle)
            let accentDot = CGRect(
                x: centerX + dotSize,
                y: positions[1] - dotSize * 0.3 / 2,
                width: dotSize * 0.3,
                height: dotSize * 0.3
            )
            context.fill(
                Circle().path(in: accentDot),
                with: .color(.primary.opacity(0.6))
            )
        }
        .frame(width: 16, height: 16)
    }
}

// MARK: - Chart Dots Icon

/// Minimalist upward trending dots
struct ChartDotsIcon: View {
    var body: some View {
        Canvas { context, size in
            let dotSize: CGFloat = 3.5

            // Four dots in upward trend
            let points: [(x: CGFloat, y: CGFloat)] = [
                (size.width * 0.15, size.height * 0.75),
                (size.width * 0.38, size.height * 0.55),
                (size.width * 0.62, size.height * 0.35),
                (size.width * 0.85, size.height * 0.20)
            ]

            // Draw connecting lines
            var path = Path()
            path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            for point in points.dropFirst() {
                path.addLine(to: CGPoint(x: point.x, y: point.y))
            }

            context.stroke(
                path,
                with: .color(.primary.opacity(0.4)),
                lineWidth: 1.0
            )

            // Draw dots
            for point in points {
                let rect = CGRect(
                    x: point.x - dotSize / 2,
                    y: point.y - dotSize / 2,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(.primary)
                )
            }
        }
        .frame(width: 16, height: 16)
    }
}

// MARK: - Claude C Icon

/// Letter C with sparkle dots
struct ClaudeCIcon: View {
    var body: some View {
        Canvas { context, size in
            let lineWidth: CGFloat = 2.0
            let arcSize = size.width * 0.55
            let centerX = size.width / 2
            let centerY = size.height / 2

            // Draw C shape (arc)
            var path = Path()
            path.addArc(
                center: CGPoint(x: centerX, y: centerY),
                radius: arcSize / 2,
                startAngle: Angle(degrees: 45),
                endAngle: Angle(degrees: 315),
                clockwise: false
            )

            context.stroke(
                path,
                with: .color(.primary),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )

            // Add two small sparkle dots
            let dotSize: CGFloat = 2.0
            let sparklePositions: [(x: CGFloat, y: CGFloat)] = [
                (size.width * 0.75, size.height * 0.25),
                (size.width * 0.85, size.height * 0.45)
            ]

            for pos in sparklePositions {
                let rect = CGRect(
                    x: pos.x - dotSize / 2,
                    y: pos.y - dotSize / 2,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(.primary.opacity(0.7))
                )
            }
        }
        .frame(width: 16, height: 16)
    }
}

// MARK: - Preview

#Preview("All Icons") {
    HStack(spacing: 20) {
        VStack {
            MenuBarIconView(style: .tokenCounter)
            Text("Token Counter")
                .font(.caption2)
        }

        VStack {
            MenuBarIconView(style: .chartDots)
            Text("Chart Dots")
                .font(.caption2)
        }

        VStack {
            MenuBarIconView(style: .claudeC)
            Text("Claude C")
                .font(.caption2)
        }
    }
    .padding()
}
