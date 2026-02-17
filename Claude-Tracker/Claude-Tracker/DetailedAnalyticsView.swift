//
//  DetailedAnalyticsView.swift
//  Claude-Tracker
//
//  Created by AI on 2026-02-16.
//  Detailed analytics view with daily/monthly breakdowns and per-model stats
//

import SwiftUI
import Charts
import Combine

/// Main detailed analytics window
struct DetailedAnalyticsView: View {
    @StateObject private var viewModel = DetailedAnalyticsViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewTab(viewModel: viewModel)
                .tabItem {
                    Label("Overview", systemImage: "chart.bar.fill")
                }
                .tag(0)

            DailyViewTab(viewModel: viewModel)
                .tabItem {
                    Label("Daily", systemImage: "calendar")
                }
                .tag(1)

            MonthlyViewTab(viewModel: viewModel)
                .tabItem {
                    Label("Monthly", systemImage: "calendar.badge.clock")
                }
                .tag(2)

            ModelsTab(viewModel: viewModel)
                .tabItem {
                    Label("Models", systemImage: "cpu")
                }
                .tag(3)
        }
        .frame(width: 900, height: 600)
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - View Model

class DetailedAnalyticsViewModel: ObservableObject {
    @Published var entries: [UsageEntry] = []
    @Published var dailyData: [AggregatedPeriod] = []
    @Published var monthlyData: [AggregatedPeriod] = []
    @Published var modelStats: [ModelStats] = []
    @Published var totals: AggregatedStats? = nil
    @Published var isLoading = false

    private let aggregator = UsageAggregator()

    func loadData() {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let entries = self.aggregator.loadUsageEntries()
            let dailyData = self.aggregator.aggregateDaily(entries)
            let monthlyData = self.aggregator.aggregateMonthly(entries)
            let modelStats = self.aggregator.getModelStats(entries)
            let totals = self.aggregator.calculateTotals(entries)

            DispatchQueue.main.async {
                self.entries = entries
                self.dailyData = dailyData
                self.monthlyData = monthlyData
                self.modelStats = modelStats
                self.totals = totals
                self.isLoading = false
            }
        }
    }
}

// MARK: - Overview Tab

struct OverviewTab: View {
    @ObservedObject var viewModel: DetailedAnalyticsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let totals = viewModel.totals {
                    // Summary Cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Total Cost",
                            value: String(format: "$%.2f", totals.cost),
                            color: .green
                        )
                        StatCard(
                            title: "Total Tokens",
                            value: formatNumber(totals.totalTokens),
                            color: .blue
                        )
                        StatCard(
                            title: "Messages",
                            value: "\(totals.messageCount)",
                            color: .purple
                        )
                        StatCard(
                            title: "Models Used",
                            value: "\(totals.modelsUsed.count)",
                            color: .orange
                        )
                    }

                    // Token Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Token Breakdown")
                            .font(.headline)

                        HStack(spacing: 16) {
                            TokenBreakdownItem(
                                label: "Input",
                                tokens: totals.inputTokens,
                                color: .blue
                            )
                            TokenBreakdownItem(
                                label: "Output",
                                tokens: totals.outputTokens,
                                color: .green
                            )
                            TokenBreakdownItem(
                                label: "Cache Create",
                                tokens: totals.cacheCreationTokens,
                                color: .orange
                            )
                            TokenBreakdownItem(
                                label: "Cache Read",
                                tokens: totals.cacheReadTokens,
                                color: .purple
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                    // Last 7 Days Chart
                    if !viewModel.dailyData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last 7 Days")
                                .font(.headline)

                            let last7Days = Array(viewModel.dailyData.suffix(7))
                            Chart(last7Days) { period in
                                BarMark(
                                    x: .value("Date", period.periodKey),
                                    y: .value("Cost", period.stats.cost)
                                )
                                .foregroundStyle(Color.accentColor)
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Top Models
                    if !viewModel.modelStats.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Models by Cost")
                                .font(.headline)

                            ForEach(viewModel.modelStats.prefix(5)) { model in
                                HStack {
                                    Text(model.displayName)
                                        .frame(width: 200, alignment: .leading)
                                    Spacer()
                                    Text("\(formatNumber(model.totalTokens)) tokens")
                                        .foregroundColor(.secondary)
                                    Text(String(format: "$%.2f", model.cost))
                                        .frame(width: 80, alignment: .trailing)
                                        .fontWeight(.medium)
                                    Text(String(format: "(%.1f%%)", model.percentage))
                                        .frame(width: 60, alignment: .trailing)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                } else {
                    Text("No data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000.0)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000.0)
        } else {
            return "\(number)"
        }
    }
}

// MARK: - Daily View Tab

struct DailyViewTab: View {
    @ObservedObject var viewModel: DetailedAnalyticsViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading data...")
            } else if viewModel.dailyData.isEmpty {
                Text("No daily data available")
                    .foregroundColor(.secondary)
            } else {
                Table(viewModel.dailyData) {
                    TableColumn("Date") { period in
                        Text(period.periodKey)
                    }
                    .width(min: 100)

                    TableColumn("Models") { period in
                        Text(period.stats.modelsUsed.map { ModelPricingCalculator.getDisplayName(for: $0) }.joined(separator: ", "))
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    .width(min: 150)

                    TableColumn("Input") { period in
                        Text("\(formatTokens(period.stats.inputTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Output") { period in
                        Text("\(formatTokens(period.stats.outputTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Cache") { period in
                        Text("\(formatTokens(period.stats.cacheReadTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Total") { period in
                        Text("\(formatTokens(period.stats.totalTokens))")
                            .fontWeight(.medium)
                    }
                    .width(min: 80)

                    TableColumn("Messages") { period in
                        Text("\(period.stats.messageCount)")
                    }
                    .width(min: 70)

                    TableColumn("Cost") { period in
                        Text(String(format: "$%.2f", period.stats.cost))
                            .fontWeight(.medium)
                    }
                    .width(min: 80)
                }
            }
        }
        .padding()
    }

    private func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", Double(tokens) / 1_000_000.0)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", Double(tokens) / 1_000.0)
        } else {
            return "\(tokens)"
        }
    }
}

// MARK: - Monthly View Tab

struct MonthlyViewTab: View {
    @ObservedObject var viewModel: DetailedAnalyticsViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading data...")
            } else if viewModel.monthlyData.isEmpty {
                Text("No monthly data available")
                    .foregroundColor(.secondary)
            } else {
                Table(viewModel.monthlyData) {
                    TableColumn("Month") { period in
                        Text(period.periodKey)
                    }
                    .width(min: 100)

                    TableColumn("Models") { period in
                        Text(period.stats.modelsUsed.map { ModelPricingCalculator.getDisplayName(for: $0) }.joined(separator: ", "))
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    .width(min: 150)

                    TableColumn("Input") { period in
                        Text("\(formatTokens(period.stats.inputTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Output") { period in
                        Text("\(formatTokens(period.stats.outputTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Cache") { period in
                        Text("\(formatTokens(period.stats.cacheReadTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Total") { period in
                        Text("\(formatTokens(period.stats.totalTokens))")
                            .fontWeight(.medium)
                    }
                    .width(min: 80)

                    TableColumn("Messages") { period in
                        Text("\(period.stats.messageCount)")
                    }
                    .width(min: 70)

                    TableColumn("Cost") { period in
                        Text(String(format: "$%.2f", period.stats.cost))
                            .fontWeight(.medium)
                    }
                    .width(min: 80)
                }
            }
        }
        .padding()
    }

    private func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", Double(tokens) / 1_000_000.0)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", Double(tokens) / 1_000.0)
        } else {
            return "\(tokens)"
        }
    }
}

// MARK: - Models Tab

struct ModelsTab: View {
    @ObservedObject var viewModel: DetailedAnalyticsViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading data...")
            } else if viewModel.modelStats.isEmpty {
                Text("No model data available")
                    .foregroundColor(.secondary)
            } else {
                Table(viewModel.modelStats) {
                    TableColumn("Model") { model in
                        Text(model.displayName)
                            .fontWeight(.medium)
                    }
                    .width(min: 180)

                    TableColumn("Input") { model in
                        Text("\(formatTokens(model.inputTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Output") { model in
                        Text("\(formatTokens(model.outputTokens))")
                    }
                    .width(min: 80)

                    TableColumn("Cache Create") { model in
                        Text("\(formatTokens(model.cacheCreationTokens))")
                    }
                    .width(min: 100)

                    TableColumn("Cache Read") { model in
                        Text("\(formatTokens(model.cacheReadTokens))")
                    }
                    .width(min: 100)

                    TableColumn("Total") { model in
                        Text("\(formatTokens(model.totalTokens))")
                            .fontWeight(.medium)
                    }
                    .width(min: 100)

                    TableColumn("Messages") { model in
                        Text("\(model.messageCount)")
                    }
                    .width(min: 80)

                    TableColumn("Cost") { model in
                        Text(String(format: "$%.2f", model.cost))
                            .fontWeight(.semibold)
                    }
                    .width(min: 90)

                    TableColumn("%") { model in
                        Text(String(format: "%.1f%%", model.percentage))
                            .foregroundColor(.secondary)
                    }
                    .width(min: 60)
                }
            }
        }
        .padding()
    }

    private func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", Double(tokens) / 1_000_000.0)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", Double(tokens) / 1_000.0)
        } else {
            return "\(tokens)"
        }
    }
}

// MARK: - Support Views

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct TokenBreakdownItem: View {
    let label: String
    let tokens: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(formatTokens(tokens))
                    .font(.callout)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            return String(format: "%.1fM", Double(tokens) / 1_000_000.0)
        } else if tokens >= 1_000 {
            return String(format: "%.1fK", Double(tokens) / 1_000.0)
        } else {
            return "\(tokens)"
        }
    }
}

// MARK: - Preview

#Preview {
    DetailedAnalyticsView()
}
