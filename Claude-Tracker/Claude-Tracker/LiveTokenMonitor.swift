//
//  LiveTokenMonitor.swift
//  Claude-Tracker
//
//  Monitors Claude JSONL conversation files for real-time token usage
//  Reads input_tokens and output_tokens from ~/.claude/projects/
//

import Foundation
import Combine
import AppKit

class LiveTokenMonitor: ObservableObject {
    @Published var liveSessionTokens: Int = 0
    @Published var liveSessionCost: Double = 0.0
    @Published var isUIActive: Bool = false

    private var monitorTimer: Timer?
    private let monitorQueue = DispatchQueue(label: "com.claudetracker.livetokens", qos: .utility)

    // Session tracking
    private var sessionStartTokens: Int = 0
    private var sessionStartTime: Date?
    private var activeConversationFile: URL?  // Cache the active file path

    // Pricing (per 1M tokens) - using weighted average
    private let averagePricePerMillion: Double = 1.52  // Based on actual usage pattern

    // Polling intervals
    private let activePollInterval: TimeInterval = 0.5  // 2 Hz for near real-time
    private let backgroundPollInterval: TimeInterval = 30.0

    init() {
        startBackgroundMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startBackgroundMonitoring() {
        stopMonitoring()

        monitorTimer = Timer.scheduledTimer(withTimeInterval: backgroundPollInterval, repeats: true) { [weak self] _ in
            self?.checkTokenUsage()
        }

        checkTokenUsage()
        print("🔄 Started background monitoring (30s interval)")
    }

    func setUIActive(_ active: Bool) {
        guard isUIActive != active else { return }

        DispatchQueue.main.async { [weak self] in
            self?.isUIActive = active
        }

        if active {
            stopMonitoring()

            // Reset session tracking - THIS is the baseline
            sessionStartTime = Date()
            sessionStartTokens = 0  // Set to 0, will be set on first poll
            activeConversationFile = nil  // Reset cached file path

            DispatchQueue.main.async { [weak self] in
                self?.liveSessionTokens = 0
                self?.liveSessionCost = 0.0
            }

            // Fast polling for real-time updates (2 Hz)
            monitorTimer = Timer.scheduledTimer(withTimeInterval: activePollInterval, repeats: true) { [weak self] _ in
                self?.checkTokenUsage()
            }

            print("⚡ Switched to active monitoring (2 Hz) - will set baseline on first poll")
            checkTokenUsage()
        } else {
            print("📊 Session ended: \(liveSessionTokens) tokens ($\(String(format: "%.2f", liveSessionCost)))")
            activeConversationFile = nil  // Clear cache
            startBackgroundMonitoring()
        }
    }

    private func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
    }

    private func checkTokenUsage() {
        monitorQueue.async { [weak self] in
            guard let self = self else { return }

            // Check if Claude is running
            let isClaudeRunning = NSWorkspace.shared.runningApplications.contains { app in
                app.bundleIdentifier?.contains("claude") == true ||
                app.localizedName?.lowercased().contains("claude") == true
            }

            guard isClaudeRunning else {
                if self.isUIActive {
                    print("⚠️ Claude not running")
                }
                return
            }

            // Get current total tokens from all JSONL files
            let currentTotal = self.getCurrentTotalTokens()

            if self.isUIActive {
                print("🔍 Current total: \(currentTotal) tokens, Session start: \(self.sessionStartTokens) tokens")
            }

            if self.sessionStartTokens == 0 {
                self.sessionStartTokens = currentTotal
                print("✅ Session baseline set: \(currentTotal) tokens")
                return
            }

            // Calculate session tokens
            let sessionTokens = currentTotal - self.sessionStartTokens

            if sessionTokens > 0 {
                let estimatedCost = Double(sessionTokens) / 1_000_000.0 * self.averagePricePerMillion

                DispatchQueue.main.async { [weak self] in
                    self?.liveSessionTokens = sessionTokens
                    self?.liveSessionCost = estimatedCost
                }

                if self.isUIActive {
                    print("📊 Session: \(sessionTokens) tokens ($\(String(format: "%.2f", estimatedCost)))")
                }
            } else if self.isUIActive {
                print("⏸️ No new tokens yet (delta: \(sessionTokens))")
            }
        }
    }

    private func getCurrentTotalTokens() -> Int {
        // If we already found the active file, reuse it (no need to scan every time)
        if let cachedFile = activeConversationFile {
            let tokens = parseTokensFromJSONL(cachedFile)
            if isUIActive {
                print("📄 Active file (cached): \(cachedFile.lastPathComponent) - \(tokens) tokens")
            }
            return tokens
        }

        // Get the .claude folder URL from FileAccessManager
        guard let statsFileURL = FileAccessManager.shared.getStatsFileURL() else {
            print("❌ No file access granted")
            return 0
        }

        // Get the .claude folder (parent of stats-cache.json)
        let claudeFolder = statsFileURL.deletingLastPathComponent()
        let projectsPath = claudeFolder.appendingPathComponent("projects")

        guard FileManager.default.fileExists(atPath: projectsPath.path) else {
            print("❌ Projects folder not found: \(projectsPath.path)")
            return 0
        }

        do {
            // Find the most recently modified JSONL file (the active conversation)
            var mostRecentFile: URL?
            var mostRecentDate = Date.distantPast

            let projectDirs = try FileManager.default.contentsOfDirectory(
                at: projectsPath,
                includingPropertiesForKeys: nil
            )

            for projectDir in projectDirs {
                let jsonlFiles = try FileManager.default.contentsOfDirectory(
                    at: projectDir,
                    includingPropertiesForKeys: [.contentModificationDateKey]
                ).filter { $0.pathExtension == "jsonl" }

                for jsonlFile in jsonlFiles {
                    if let modDate = try? jsonlFile.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                       modDate > mostRecentDate {
                        mostRecentDate = modDate
                        mostRecentFile = jsonlFile
                    }
                }
            }

            guard let activeFile = mostRecentFile else {
                if isUIActive {
                    print("❌ No active JSONL file found")
                }
                return 0
            }

            // Cache the active file for subsequent polls
            activeConversationFile = activeFile

            // Only parse the active conversation file
            let tokens = parseTokensFromJSONL(activeFile)

            if isUIActive {
                let timeSinceModified = Date().timeIntervalSince(mostRecentDate)
                print("📄 Active file found: \(activeFile.lastPathComponent)")
                print("   Modified: \(Int(timeSinceModified))s ago")
                print("   Tokens: \(tokens)")
            }

            return tokens
        } catch {
            print("❌ Error reading projects: \(error)")
            return 0
        }
    }

    private func parseTokensFromJSONL(_ fileURL: URL) -> Int {
        var tokens = 0

        do {
            // Read file as string
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: "\n")

            for line in lines {
                guard !line.isEmpty else { continue }

                // Parse JSON line
                if let data = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? [String: Any],
                   let usage = message["usage"] as? [String: Any] {

                    // Sum all token types
                    if let inputTokens = usage["input_tokens"] as? Int {
                        tokens += inputTokens
                    }
                    if let outputTokens = usage["output_tokens"] as? Int {
                        tokens += outputTokens
                    }
                    if let cacheReadTokens = usage["cache_read_input_tokens"] as? Int {
                        tokens += cacheReadTokens
                    }
                    if let cacheWriteTokens = usage["cache_creation_input_tokens"] as? Int {
                        tokens += cacheWriteTokens
                    }
                }
            }
        } catch {
            // Silently fail for individual files
        }

        return tokens
    }

    func reset() {
        stopMonitoring()
        sessionStartTime = nil
        sessionStartTokens = 0
        DispatchQueue.main.async { [weak self] in
            self?.liveSessionTokens = 0
            self?.liveSessionCost = 0.0
            self?.isUIActive = false
        }
    }
}
