//
//  Claude_TrackerApp.swift
//  Claude-Tracker
//
//  Created by Petr on 2026/2/16.
//

import SwiftUI
import AppKit

@main
struct Claude_TrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty scene - we only use menubar
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var monitor: StatsMonitor!
    private var detailsWindow: NSWindow?
    private var detailsHostingController: NSHostingController<DetailedAnalyticsView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize stats monitor
        monitor = StatsMonitor()

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Use custom drawn Claude C icon
            button.image = NSImage.claudeCIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView(monitor: monitor, onShowDetails: { [weak self] in
                self?.showDetailsWindow()
            })
        )

        print("Claude Tracker loaded successfully")

        // Check if we need to request file access
        checkFileAccess()
    }

    private func checkFileAccess() {
        // Try to access the file
        if FileAccessManager.shared.getStatsFileURL() == nil {
            // Show alert and request access
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.requestFileAccessDialog()
            }
        }
    }

    private func requestFileAccessDialog() {
        let alert = NSAlert()
        alert.messageText = "Grant File Access"
        alert.informativeText = "Claude Tracker needs access to ~/.claude/stats-cache.json to display your usage statistics.\n\nClick 'Grant Access' to select the file."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Grant Access")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            FileAccessManager.shared.requestFileAccess { [weak self] url in
                if url != nil {
                    // Access granted, refresh stats
                    self?.monitor.refresh()
                    print("File access granted successfully")
                } else {
                    print("File access was not granted")
                }
            }
        }
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
                // Switch to background monitoring (30s interval)
                monitor.liveTokenMonitor.setUIActive(false)
            } else {
                // Refresh stats when opening popover
                monitor.refresh()
                // Switch to active monitoring (2 Hz)
                monitor.liveTokenMonitor.setUIActive(true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func showDetailsWindow() {
        // Close popover
        popover.performClose(nil)

        if let existingWindow = detailsWindow {
            // Bring existing window to front
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // Create hosting controller first and keep a strong reference
            let hostingController = NSHostingController(rootView: DetailedAnalyticsView())
            self.detailsHostingController = hostingController

            // Create new window
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Claude Token Tracker - Detailed Analytics"
            window.contentViewController = hostingController

            // Handle window close
            window.delegate = self

            // Prevent window from being released when closed
            window.isReleasedWhenClosed = false

            detailsWindow = window
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up timers and resources
        monitor.liveTokenMonitor.reset()
        print("🛑 Claude Tracker is terminating")
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Allow immediate termination
        return .terminateNow
    }
}

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == detailsWindow {
            detailsWindow = nil
            detailsHostingController = nil
        }
    }
}
