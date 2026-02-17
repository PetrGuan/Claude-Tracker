//
//  FileAccessManager.swift
//  Claude-Tracker
//
//  Manages secure file access with proper sandboxing using Security-Scoped Bookmarks
//

import Foundation
import AppKit

class FileAccessManager {
    static let shared = FileAccessManager()

    private let bookmarkKey = "claudeFolderBookmark"
    private var securityScopedFolderURL: URL?

    private init() {
        // Try to restore previously granted access
        restoreFileAccess()
    }

    /// Get the stats file URL with proper sandbox access
    func getStatsFileURL() -> URL? {
        // If we have folder access, construct the file path
        if let folderURL = securityScopedFolderURL {
            return folderURL.appendingPathComponent("stats-cache.json")
        }
        return nil
    }

    /// Request access to the .claude folder via file picker
    func requestFileAccess(completion: @escaping (URL?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.message = """
        Claude Tracker needs access to the .claude folder.

        Steps:
        1. Press ⌘⇧. (Cmd+Shift+.) to show hidden files
        2. Select the '.claude' folder in your home directory
        3. Click "Grant Access"
        """
        openPanel.prompt = "Grant Access"
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true  // Select folder
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        openPanel.showsHiddenFiles = true

        // Try to navigate to home directory
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        openPanel.directoryURL = homeDir

        openPanel.begin { [weak self] response in
            guard response == .OK, let folderURL = openPanel.url else {
                completion(nil)
                return
            }

            // Validate that it's the .claude folder
            guard folderURL.lastPathComponent == ".claude" else {
                let alert = NSAlert()
                alert.messageText = "Wrong Folder"
                alert.informativeText = "Please select the '.claude' folder (not '\(folderURL.lastPathComponent)')."
                alert.alertStyle = .warning
                alert.runModal()
                completion(nil)
                return
            }

            // Create security-scoped bookmark for the folder
            do {
                let bookmark = try folderURL.bookmarkData(
                    options: [.withSecurityScope],
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                UserDefaults.standard.set(bookmark, forKey: self?.bookmarkKey ?? "")
                self?.securityScopedFolderURL = folderURL

                // Start accessing the folder
                _ = folderURL.startAccessingSecurityScopedResource()

                // Return the file URL
                let fileURL = folderURL.appendingPathComponent("stats-cache.json")
                completion(fileURL)
            } catch {
                print("Failed to create bookmark: \(error)")
                completion(nil)
            }
        }
    }

    /// Restore file access from saved bookmark
    private func restoreFileAccess() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return
        }

        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                // Bookmark is stale, need to request access again
                print("Bookmark is stale, need to request access again")
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                return
            }

            securityScopedFolderURL = url
            _ = url.startAccessingSecurityScopedResource()
            print("Restored access to: \(url.path)")
        } catch {
            print("Failed to restore bookmark: \(error)")
            UserDefaults.standard.removeObject(forKey: bookmarkKey)
        }
    }

    func stopAccessingSecurityScopedResource() {
        securityScopedFolderURL?.stopAccessingSecurityScopedResource()
    }
}
