# Changelog

All notable changes to Claude Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-02-16

### 🎉 Initial Beta Release

First public release of Claude Tracker! All core features are functional and ready for community testing.

### ✨ Added
- Real-time token usage monitoring for Claude Code
- Visual 7-day usage breakdown with charts
- Cost estimation based on Anthropic API pricing
  - Input tokens: $3.00 per 1M
  - Output tokens: $15.00 per 1M
  - Cache writes: $3.75 per 1M
  - Cache reads: $0.30 per 1M
- Native macOS menubar application with custom Claude C icon
- SwiftUI interface with dark mode support
- FSEvents-based file monitoring (zero CPU overhead)
- Security-scoped bookmarks for sandboxed file access
- Today's usage statistics (tokens and cost)
- Total lifetime usage tracking
- Cache efficiency metrics (read/write ratio)
- Menubar-only mode (no dock icon)

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

### 🙏 Credits
- Built entirely with Claude Sonnet 4.5
- Human architect: Petr Guan
- AI-native development demonstration

---

**Note**: This is a beta release. Please report issues on [GitHub Issues](https://github.com/yourusername/Claude-Tracker/issues).

[Unreleased]: https://github.com/yourusername/Claude-Tracker/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/Claude-Tracker/releases/tag/v0.1.0
