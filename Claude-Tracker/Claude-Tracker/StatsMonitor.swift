//
//  StatsMonitor.swift
//  Claude-Tracker
//
//  Ultra-efficient file monitoring using FSEvents (kernel-level, 0% CPU)
//

import Foundation
import Combine

class StatsMonitor: ObservableObject {
    @Published var currentStats: ComputedStats?
    @Published var lastUpdateTime: Date = Date()
    @Published var liveTokenMonitor = LiveTokenMonitor()

    private let parser = StatsParser()
    private var fileMonitor: DispatchSourceFileSystemObject?
    private let monitorQueue = DispatchQueue(label: "com.claudetracker.monitor", qos: .utility)
    private var refreshTimer: Timer?

    init() {
        // Load initial stats immediately
        loadStats()

        // Start monitoring for changes
        startMonitoring()

        // Start automatic refresh timer (every 3 seconds for live updates)
        startAutoRefresh()
    }

    deinit {
        stopMonitoring()
        stopAutoRefresh()
    }

    // MARK: - File Monitoring

    private func startMonitoring() {
        guard let statsPath = FileAccessManager.shared.getStatsFileURL() else {
            print("Cannot start monitoring: no file access")
            return
        }

        guard FileManager.default.fileExists(atPath: statsPath.path) else {
            print("Stats file not found: \(statsPath.path)")
            return
        }

        // Open file descriptor
        let fileDescriptor = open(statsPath.path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            print("Failed to open file for monitoring")
            return
        }

        // Create dispatch source for file watching
        // This uses kernel-level FSEvents - zero CPU overhead!
        fileMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .extend],  // Watch for file modifications
            queue: monitorQueue
        )

        // Event handler - only fires when file actually changes
        fileMonitor?.setEventHandler { [weak self] in
            self?.handleFileChange()
        }

        // Cleanup handler
        fileMonitor?.setCancelHandler {
            close(fileDescriptor)
        }

        // Start monitoring
        fileMonitor?.resume()

        print("Started monitoring: \(statsPath.path)")
    }

    private func stopMonitoring() {
        fileMonitor?.cancel()
        fileMonitor = nil
    }

    private func handleFileChange() {
        // Debounce: wait a bit for writes to complete
        monitorQueue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadStats()
        }
    }

    // MARK: - Stats Loading

    private func loadStats() {
        // Compute stats on background queue
        monitorQueue.async { [weak self] in
            guard let self = self else { return }

            let stats = self.parser.computeStats()

            // Update published property on main thread
            DispatchQueue.main.async {
                self.currentStats = stats
                self.lastUpdateTime = Date()
            }
        }
    }

    // MARK: - Manual Refresh

    func refresh() {
        loadStats()
    }

    // MARK: - Auto Refresh

    private func startAutoRefresh() {
        // Refresh every 3 seconds for live updates
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.loadStats()
        }
    }

    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
