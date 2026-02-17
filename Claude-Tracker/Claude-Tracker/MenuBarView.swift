//
//  MenuBarView.swift
//  Claude-Tracker
//
//  Lightweight popover UI that only renders when visible
//

import SwiftUI
import Charts

struct MenuBarPopoverView: View {
    @ObservedObject var monitor: StatsMonitor
    var onShowDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let stats = monitor.currentStats {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Claude Token Tracker")
                            .font(.headline)
                        Text("Updated \(timeAgo(monitor.lastUpdateTime))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: { monitor.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
                }

                Divider()

                // Live Session (from JSONL monitoring)
                if monitor.liveTokenMonitor.isUIActive {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Live Session (Since Opened)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "waveform")
                                .font(.caption)
                                .foregroundStyle(monitor.liveTokenMonitor.liveSessionTokens > 0 ? .green : .gray)
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                Text(formatTokens(monitor.liveTokenMonitor.liveSessionTokens))
                                    .font(.title3.bold())
                                    .foregroundColor(monitor.liveTokenMonitor.liveSessionTokens > 0 ? .green : .secondary)
                                Text("tokens (since UI opened)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(formatCost(monitor.liveTokenMonitor.liveSessionCost))
                                    .font(.title3.bold())
                                    .foregroundColor(monitor.liveTokenMonitor.liveSessionTokens > 0 ? .green : .secondary)
                                Text("est. cost")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider()
                }

                // Today's Usage
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today (Confirmed)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        VStack(alignment: .leading) {
                            Text(formatTokens(stats.todayTokens))
                                .font(.title2.bold())
                            Text("tokens")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(formatCost(stats.todayCost))
                                .font(.title2.bold())
                            Text("estimated cost")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                // Total Usage
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        VStack(alignment: .leading) {
                            Text(formatTokens(stats.totalTokens))
                                .font(.title3.bold())
                            Text("tokens")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(formatCost(stats.totalCost))
                                .font(.title3.bold())
                            Text("estimated cost")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                // Cache Efficiency
                HStack {
                    Text("Cache Efficiency")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(stats.cacheEfficiency * 100))%")
                        .font(.title3.bold())
                        .foregroundColor(stats.cacheEfficiency > 0.5 ? .green : .orange)
                }

                Divider()

                // 7-Day Chart
                if !stats.dailyBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last 7 Days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Chart(stats.dailyBreakdown, id: \.date) { day in
                            BarMark(
                                x: .value("Date", formatDate(day.date)),
                                y: .value("Tokens", day.tokens)
                            )
                            .foregroundStyle(.blue.gradient)
                        }
                        .frame(height: 100)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let intValue = value.as(Int.self) {
                                        Text(formatTokensShort(intValue))
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                AxisValueLabel {
                                    if let stringValue = value.as(String.self) {
                                        Text(stringValue)
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                    }
                }

                Divider()

                // Tokens per message
                HStack {
                    Text("Avg per message")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(stats.tokensPerMessage)) tokens")
                        .font(.caption.bold())
                }

                Divider()

                // Details button
                Button(action: onShowDetails) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                        Text("Detailed Analytics")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Divider()

                // Quit button
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit Claude Tracker")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                }
                .buttonStyle(.borderless)

            } else {
                // Loading state
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading stats...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .frame(width: 320)
    }

    // MARK: - Formatting Helpers

    private func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", Double(tokens) / 1_000_000.0)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", Double(tokens) / 1_000.0)
        } else {
            return "\(tokens)"
        }
    }

    private func formatTokensShort(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.0fM", Double(tokens) / 1_000_000.0)
        } else if tokens >= 1_000 {
            return String(format: "%.0fK", Double(tokens) / 1_000.0)
        } else {
            return "\(tokens)"
        }
    }

    private func formatCost(_ cost: Double) -> String {
        return String(format: "$%.2f", cost)
    }

    private func formatDate(_ dateString: String) -> String {
        // Input format: "2026-02-16"
        let components = dateString.split(separator: "-")
        guard components.count == 3,
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return dateString
        }
        return "\(month)/\(day)"
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 5 {
            return "just now"
        } else if seconds < 60 {
            return "\(seconds)s ago"
        } else {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        }
    }
}

#Preview {
    let monitor = StatsMonitor()
    return MenuBarPopoverView(monitor: monitor, onShowDetails: {})
}
