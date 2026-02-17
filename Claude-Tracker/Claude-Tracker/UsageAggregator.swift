//
//  UsageAggregator.swift
//  Claude-Tracker
//
//  Created by AI on 2026-02-16.
//  Daily and monthly usage aggregation
//

import Foundation

/// Usage data for a single entry
struct UsageEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let model: String
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let messageId: String
    let requestId: String

    var cost: Double {
        ModelPricingCalculator.calculateCost(
            model: model,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: cacheCreationTokens,
            cacheReadTokens: cacheReadTokens
        )
    }

    var totalTokens: Int {
        inputTokens + outputTokens + cacheCreationTokens + cacheReadTokens
    }
}

/// Aggregated statistics for a time period
struct AggregatedStats {
    var inputTokens: Int = 0
    var outputTokens: Int = 0
    var cacheCreationTokens: Int = 0
    var cacheReadTokens: Int = 0
    var cost: Double = 0.0
    var messageCount: Int = 0
    var modelsUsed: Set<String> = []

    var totalTokens: Int {
        inputTokens + outputTokens + cacheCreationTokens + cacheReadTokens
    }

    mutating func addEntry(_ entry: UsageEntry) {
        inputTokens += entry.inputTokens
        outputTokens += entry.outputTokens
        cacheCreationTokens += entry.cacheCreationTokens
        cacheReadTokens += entry.cacheReadTokens
        cost += entry.cost
        messageCount += 1
        modelsUsed.insert(entry.model)
    }
}

/// Aggregated data for a specific period (day or month)
struct AggregatedPeriod: Identifiable, Hashable, Comparable {
    let id = UUID()
    let periodKey: String  // e.g., "2026-02-16" or "2026-02"
    var stats: AggregatedStats = AggregatedStats()
    var modelBreakdown: [String: AggregatedStats] = [:]

    mutating func addEntry(_ entry: UsageEntry) {
        // Add to overall stats
        stats.addEntry(entry)

        // Add to model-specific breakdown
        let normalizedModel = ModelPricingCalculator.normalizeModelName(entry.model)
        if modelBreakdown[normalizedModel] == nil {
            modelBreakdown[normalizedModel] = AggregatedStats()
        }
        modelBreakdown[normalizedModel]?.addEntry(entry)
    }

    static func < (lhs: AggregatedPeriod, rhs: AggregatedPeriod) -> Bool {
        return lhs.periodKey < rhs.periodKey
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AggregatedPeriod, rhs: AggregatedPeriod) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Per-model statistics
struct ModelStats: Identifiable, Hashable, Comparable {
    let id = UUID()
    let model: String
    let displayName: String
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let totalTokens: Int
    let cost: Double
    let messageCount: Int
    let percentage: Double  // Percentage of total usage

    static func < (lhs: ModelStats, rhs: ModelStats) -> Bool {
        return lhs.cost < rhs.cost
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ModelStats, rhs: ModelStats) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Aggregates usage data from JSONL files
class UsageAggregator {

    private let fileAccessManager = FileAccessManager.shared

    // MARK: - Load Entries

    /// Load all usage entries from JSONL files
    func loadUsageEntries() -> [UsageEntry] {
        guard let claudeFolder = fileAccessManager.getStatsFileURL()?.deletingLastPathComponent() else {
            print("❌ No file access")
            return []
        }

        let projectsPath = claudeFolder.appendingPathComponent("projects")
        guard let projectDirs = try? FileManager.default.contentsOfDirectory(
            at: projectsPath,
            includingPropertiesForKeys: [.isDirectoryKey]
        ).filter({ (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }) else {
            return []
        }

        var allEntries: [UsageEntry] = []
        var seenHashes: Set<String> = []

        for projectDir in projectDirs {
            guard let jsonlFiles = try? FileManager.default.contentsOfDirectory(
                at: projectDir,
                includingPropertiesForKeys: nil
            ).filter({ $0.pathExtension == "jsonl" }) else {
                continue
            }

            for jsonlFile in jsonlFiles {
                let entries = parseJSONLFile(jsonlFile, seenHashes: &seenHashes)
                allEntries.append(contentsOf: entries)
            }
        }

        return allEntries.sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Parse JSONL

    private func parseJSONLFile(_ fileURL: URL, seenHashes: inout Set<String>) -> [UsageEntry] {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }

        var entries: [UsageEntry] = []

        for line in content.components(separatedBy: .newlines) {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let data = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = json["message"] as? [String: Any],
                  let usage = message["usage"] as? [String: Any],
                  let model = message["model"] as? String,
                  let timestampStr = json["timestamp"] as? String,
                  let timestamp = parseISO8601Date(timestampStr) else {
                continue
            }

            // Deduplication
            let messageId = (json["message_id"] as? String) ?? (message["id"] as? String) ?? ""
            let requestId = (json["request_id"] as? String) ?? (json["requestId"] as? String) ?? "unknown"
            let uniqueHash = "\(messageId):\(requestId)"

            guard !messageId.isEmpty && !requestId.isEmpty && !seenHashes.contains(uniqueHash) else {
                continue
            }
            seenHashes.insert(uniqueHash)

            // Extract token counts
            let inputTokens = usage["input_tokens"] as? Int ?? 0
            let outputTokens = usage["output_tokens"] as? Int ?? 0
            let cacheCreationTokens = usage["cache_creation_input_tokens"] as? Int ?? 0
            let cacheReadTokens = usage["cache_read_input_tokens"] as? Int ?? 0

            // Skip entries with no tokens
            guard inputTokens > 0 || outputTokens > 0 || cacheCreationTokens > 0 || cacheReadTokens > 0 else {
                continue
            }

            let entry = UsageEntry(
                timestamp: timestamp,
                model: model,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                cacheCreationTokens: cacheCreationTokens,
                cacheReadTokens: cacheReadTokens,
                messageId: messageId,
                requestId: requestId
            )

            entries.append(entry)
        }

        return entries
    }

    // MARK: - date Parsing

    private func parseISO8601Date(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }

    // MARK: - Aggregation

    /// Aggregate entries by day
    func aggregateDaily(_ entries: [UsageEntry]) -> [AggregatedPeriod] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var periodsDict: [String: AggregatedPeriod] = [:]

        for entry in entries {
            let periodKey = formatter.string(from: entry.timestamp)

            if periodsDict[periodKey] == nil {
                periodsDict[periodKey] = AggregatedPeriod(periodKey: periodKey)
            }

            periodsDict[periodKey]?.addEntry(entry)
        }

        return Array(periodsDict.values).sorted { $0.periodKey < $1.periodKey }
    }

    /// Aggregate entries by month
    func aggregateMonthly(_ entries: [UsageEntry]) -> [AggregatedPeriod] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        var periodsDict: [String: AggregatedPeriod] = [:]

        for entry in entries {
            let periodKey = formatter.string(from: entry.timestamp)

            if periodsDict[periodKey] == nil {
                periodsDict[periodKey] = AggregatedPeriod(periodKey: periodKey)
            }

            periodsDict[periodKey]?.addEntry(entry)
        }

        return Array(periodsDict.values).sorted { $0.periodKey < $1.periodKey }
    }

    /// Get per-model statistics from entries
    func getModelStats(_ entries: [UsageEntry]) -> [ModelStats] {
        var modelBreakdown: [String: AggregatedStats] = [:]

        // Aggregate by model
        for entry in entries {
            let normalizedModel = ModelPricingCalculator.normalizeModelName(entry.model)
            if modelBreakdown[normalizedModel] == nil {
                modelBreakdown[normalizedModel] = AggregatedStats()
            }
            modelBreakdown[normalizedModel]?.addEntry(entry)
        }

        // Calculate total cost for percentage
        let totalCost = modelBreakdown.values.reduce(0.0) { $0 + $1.cost }

        // Convert to ModelStats array
        return modelBreakdown.map { (model, stats) in
            ModelStats(
                model: model,
                displayName: ModelPricingCalculator.getDisplayName(for: model),
                inputTokens: stats.inputTokens,
                outputTokens: stats.outputTokens,
                cacheCreationTokens: stats.cacheCreationTokens,
                cacheReadTokens: stats.cacheReadTokens,
                totalTokens: stats.totalTokens,
                cost: stats.cost,
                messageCount: stats.messageCount,
                percentage: totalCost > 0 ? (stats.cost / totalCost * 100) : 0
            )
        }.sorted { $0.cost > $1.cost }  // Sort by cost descending
    }

    /// Calculate overall totals from entries
    func calculateTotals(_ entries: [UsageEntry]) -> AggregatedStats {
        var totals = AggregatedStats()

        for entry in entries {
            totals.addEntry(entry)
        }

        return totals
    }
}
