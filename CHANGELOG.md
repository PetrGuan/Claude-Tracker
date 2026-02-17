# Changelog

All notable changes to Claude Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-02-16

### 🎉 Major Feature Release - Detailed Analytics

Comprehensive analytics window inspired by Claude-Code-Usage-Monitor with all the power user features!

### ✨ Added
- **Detailed Analytics Window** - Comprehensive usage analysis with tabbed interface
  - Overview Tab: Summary cards, charts, and top models by cost
  - Daily View: Day-by-day usage breakdown in table format
  - Monthly View: Month-by-month aggregation for long-term trends
  - Models Tab: Per-model statistics with cost percentages
- **Model-Specific Pricing** - Accurate costs for each Claude model
  - Claude 3/4 Opus: $15/$75 per 1M (input/output)
  - Claude 3.5/4 Sonnet: $3/$15 per 1M (default)
  - Claude 3/3.5 Haiku: $0.25/$1.25 per 1M
  - Cache token pricing included for all models
- **Message Counting** - Track number of messages alongside tokens
- **Deduplication Logic** - Prevents duplicate entries using message_id + request_id hashing
- **Daily/Monthly Aggregation** - Historical usage breakdowns with model information
- **Interactive Charts** - Visual representation of last 7 days usage
- **"Detailed Analytics" Button** - Easy access from menubar popover

### 🔧 Technical Improvements
- New `ModelPricingCalculator` - Model-specific pricing engine
- New `UsageAggregator` - Daily/monthly aggregation with deduplication
- New `DetailedAnalyticsView` - 4-tab SwiftUI interface
- Window lifecycle management with proper memory handling
- Strong references to avoid crashes on window close

### 🐛 Bug Fixes
- Fixed memory crash when closing analytics window (NSHostingController lifecycle)
- Properly manage window references to prevent premature deallocation

## [0.1.0] - 2026-02-16

### 🎉 Initial Beta Release

First public release of Claude Tracker! All core features are functional and ready for community testing.

### ✨ Added
- **Live Session Tracking** - Real-time token counter updates as you chat (2 Hz polling)
- **Dual Monitoring System** - Combines historical stats cache + live JSONL conversation monitoring
- **Active Conversation Detection** - Automatically finds and tracks the most recently modified conversation
- **Smart File Caching** - Caches active conversation file path for efficient polling
- Visual 7-day usage breakdown with charts
- Cost estimation based on Anthropic API pricing (Sonnet 3.5 default)
- Native macOS menubar application with custom Claude C icon
- SwiftUI interface with dark mode support
- FSEvents-based file monitoring (zero CPU overhead)
- Security-scoped bookmarks for sandboxed file access
- Today's usage statistics (tokens and cost)
- Total lifetime usage tracking
- Cache efficiency metrics (read/write ratio)
- Menubar-only mode (no dock icon)
- **Adaptive Polling** - 2 Hz when UI active, 30s in background for battery efficiency

### 🔒 Security
- App Sandbox enabled following Apple best practices
- Read-only access to user-selected .claude folder
- Security-scoped bookmark persistence
- No network access - all data stays local
- No telemetry or analytics

### 📦 Distribution
- DMG installer for easy installation
- GitHub Actions automated build pipeline
- Unsigned binary (requires right-click to open first time)

### ⚡ Performance
- Memory: 8-15 MB idle
- CPU: 0.0% in background
- Battery: No impact (Activity Monitor verified)
- File monitoring: Kernel-level FSEvents

### 🤖 Development
- **100% AI-generated codebase** using Claude Sonnet 4.5
- SwiftUI + AppKit hybrid architecture
- Comprehensive documentation (README, INSTALL, RELEASE guides)
- AI-native Code of Conduct and Philosophy

### ⚠️ Known Limitations
- App is unsigned (requires Apple Developer ID for signing)
- First launch shows Gatekeeper warning (expected for unsigned apps)
- Limited testing on various macOS versions (tested on 13.0+)
- File access dialog requires manual folder selection
- No automatic updates yet

### 📝 Technical Details
- **Language**: Swift 5.9+
- **Framework**: SwiftUI, AppKit, Charts
- **Minimum macOS**: 13.0 (Ventura)
- **Architecture**: Apple Silicon + Intel (Universal)
- **Size**: ~150KB DMG
- **Monitoring**: Dual-source (stats-cache.json + JSONL conversation files)
- **Polling**: Adaptive (2 Hz active, 30s background)

### 🙏 Credits
- Built entirely with Claude Sonnet 4.5
- Human architect: Petr Guan
- Inspired by Claude-Code-Usage-Monitor
- AI-native development demonstration

---

**Note**: This is a beta release. Please report issues on [GitHub Issues](https://github.com/yourusername/Claude-Tracker/issues).

[Unreleased]: https://github.com/yourusername/Claude-Tracker/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/yourusername/Claude-Tracker/releases/tag/v0.2.0
[0.1.0]: https://github.com/yourusername/Claude-Tracker/releases/tag/v0.1.0
