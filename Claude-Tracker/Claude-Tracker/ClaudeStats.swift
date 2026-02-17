//
//  ClaudeStats.swift
//  Claude-Tracker
//
//  Token usage statistics models and parser
//

import Foundation

// MARK: - Data Models

struct ClaudeStats: Codable {
    let version: Int
    let lastComputedDate: String
    let dailyActivity: [DailyActivity]
    let dailyModelTokens: [DailyModelTokens]
    let modelUsage: [String: ModelUsage]
    let totalSessions: Int
    let totalMessages: Int
    let longestSession: LongestSession?
    let firstSessionDate: String
    let hourCounts: [String: Int]
    let totalSpeculationTimeSavedMs: Int
}

struct DailyActivity: Codable {
    let date: String
    let messageCount: Int
    let sessionCount: Int
    let toolCallCount: Int
}

struct DailyModelTokens: Codable {
    let date: String
    let tokensByModel: [String: Int]
}

struct ModelUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int
    let cacheReadInputTokens: Int
    let cacheCreationInputTokens: Int
    let webSearchRequests: Int
    let costUSD: Double
    let contextWindow: Int
    let maxOutputTokens: Int
}

struct LongestSession: Codable {
    let sessionId: String
    let duration: Int
    let messageCount: Int
    let timestamp: String
}

// MARK: - Computed Stats

struct ComputedStats {
    let totalTokens: Int
    let totalCost: Double
    let todayTokens: Int
    let todayCost: Double
    let cacheEfficiency: Double
    let dailyBreakdown: [(date: String, tokens: Int, cost: Double)]

    // Rate calculations
    var tokensPerMessage: Double {
        guard totalMessages > 0 else { return 0 }
        return Double(totalTokens) / Double(totalMessages)
    }

    private let totalMessages: Int

    init(from stats: ClaudeStats) {
        self.totalMessages = stats.totalMessages

        // Calculate totals from model usage
        var totalInput = 0
        var totalOutput = 0
        var totalCacheRead = 0
        var totalCacheWrite = 0

        for (_, usage) in stats.modelUsage {
            totalInput += usage.inputTokens
            totalOutput += usage.outputTokens
            totalCacheRead += usage.cacheReadInputTokens
            totalCacheWrite += usage.cacheCreationInputTokens
        }

        self.totalTokens = totalInput + totalOutput + totalCacheRead + totalCacheWrite

        // Calculate costs based on Anthropic pricing (per 1M tokens)
        // Input: $3, Output: $15, Cache write: $3.75, Cache read: $0.30
        let inputCost = Double(totalInput) / 1_000_000.0 * 3.0
        let outputCost = Double(totalOutput) / 1_000_000.0 * 15.0
        let cacheWriteCost = Double(totalCacheWrite) / 1_000_000.0 * 3.75
        let cacheReadCost = Double(totalCacheRead) / 1_000_000.0 * 0.30

        let computedTotalCost = inputCost + outputCost + cacheWriteCost + cacheReadCost
        self.totalCost = computedTotalCost

        // Cache efficiency: ratio of cache reads to total cache operations
        let totalCacheOps = totalCacheRead + totalCacheWrite
        self.cacheEfficiency = totalCacheOps > 0 ? Double(totalCacheRead) / Double(totalCacheOps) : 0

        // Today's stats
        let today = stats.lastComputedDate
        if let todayData = stats.dailyModelTokens.first(where: { $0.date == today }) {
            let todayToks = todayData.tokensByModel.values.reduce(0, +)
            self.todayTokens = todayToks
            // Approximate today's cost (proportional to total)
            self.todayCost = computedTotalCost * Double(todayToks) / Double(max(self.totalTokens, 1))
        } else {
            self.todayTokens = 0
            self.todayCost = 0
        }

        // Daily breakdown (last 7 days)
        // Use local variables to avoid capturing self before initialization
        let totalToks = self.totalTokens
        let totalCostValue = computedTotalCost
        self.dailyBreakdown = stats.dailyModelTokens.suffix(7).map { day in
            let tokens = day.tokensByModel.values.reduce(0, +)
            let cost = totalCostValue * Double(tokens) / Double(max(totalToks, 1))
            return (date: day.date, tokens: tokens, cost: cost)
        }
    }
}

// MARK: - Stats Parser

class StatsParser {
    /// Parse stats synchronously (optimized for performance)
    func parseStats() -> ClaudeStats? {
        // Use FileAccessManager for proper sandboxed access
        guard let statsPath = FileAccessManager.shared.getStatsFileURL() else {
            print("❌ Unable to access stats file - may need to grant permission")
            return nil
        }

        guard FileManager.default.fileExists(atPath: statsPath.path) else {
            print("❌ Stats file not found: \(statsPath.path)")
            return nil
        }

        do {
            let data = try Data(contentsOf: statsPath)
            let decoder = JSONDecoder()
            let stats = try decoder.decode(ClaudeStats.self, from: data)
            // Reduced logging - only log once on app start or errors
            return stats
        } catch {
            print("❌ Failed to parse stats: \(error)")
            return nil
        }
    }

    /// Compute derived statistics
    func computeStats() -> ComputedStats? {
        guard let stats = parseStats() else {
            return nil
        }
        let computed = ComputedStats(from: stats)
        // Reduced logging - NetworkMonitor will log changes
        return computed
    }
}
