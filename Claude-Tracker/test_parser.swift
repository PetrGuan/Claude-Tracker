import Foundation

// Quick test of stats parser
let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude/stats-cache.json")

do {
    let data = try Data(contentsOf: fileURL)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    
    print("Stats file loaded successfully:")
    print("Version:", json?["version"] ?? "unknown")
    print("Last computed:", json?["lastComputedDate"] ?? "unknown")
    print("Total messages:", json?["totalMessages"] ?? "unknown")
    
    if let modelUsage = json?["modelUsage"] as? [String: [String: Any]] {
        for (model, usage) in modelUsage {
            print("\nModel:", model)
            print("  Input tokens:", usage["inputTokens"] ?? 0)
            print("  Output tokens:", usage["outputTokens"] ?? 0)
            print("  Cache read:", usage["cacheReadInputTokens"] ?? 0)
            print("  Cache write:", usage["cacheCreationInputTokens"] ?? 0)
        }
    }
    
    if let dailyTokens = json?["dailyModelTokens"] as? [[String: Any]] {
        print("\nDaily tokens count:", dailyTokens.count)
        if let last = dailyTokens.last {
            print("Last day:", last["date"] ?? "unknown")
            if let tokens = last["tokensByModel"] as? [String: Int] {
                print("  Tokens:", tokens.values.reduce(0, +))
            }
        }
    }
} catch {
    print("Error:", error)
}
