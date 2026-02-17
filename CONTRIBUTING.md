# Contributing to Claude Token Tracker

First off, thank you for considering contributing to Claude Token Tracker! It's people like you that make this tool better for everyone.

**Important**: This is an **AI-native project**. We strongly encourage all code contributions to be AI-generated. See our [Code of Conduct](CODE_OF_CONDUCT.md) for our philosophy on AI-assisted development.

## 🤖 The AI-Native Workflow

### Preferred Way to Contribute

1. **Open an issue** describing what you want to implement
2. **Have a conversation with Claude/GPT/etc** to implement it
3. **Share the key parts of the conversation** (optional but encouraged)
4. **Submit the AI-generated code** as a Pull Request
5. **Attribute both human and AI** in the commit message

### Example Commit Message

```
feat: Add CSV export functionality

Added export button and file save dialog for usage data.
Users can now export their token usage history.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
Prompted-By: YourName <your@email.com>
```

### Why AI-Generated?

- ⚡ **Faster development** - AI writes boilerplate instantly
- 🎯 **Focus on design** - Humans architect, AI implements
- 📚 **Better documentation** - AI explains as it writes
- 🧪 **Consistent style** - AI follows patterns reliably
- 🌍 **Lower barrier to entry** - Anyone can contribute with good prompts

## Code of Conduct

This project and everyone participating in it is governed by our [AI-Native Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

**Remember**: We won't reject manually-written code, but we will ask "why didn't you use AI?" 😄

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Include macOS version and Claude Code version**
- **Add screenshots if relevant**
- **Include Console.app logs if applicable**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List some examples of how it would be used**

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes** following our code style guidelines
3. **Test thoroughly** - ensure the app still builds and runs correctly
4. **Update documentation** if you changed APIs or added features
5. **Write a clear commit message** describing what and why

#### Code Style Guidelines

- Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused on a single task
- Use `// MARK: -` to organize code sections
- Format code consistently (use Xcode's default formatter)

#### Performance Guidelines

Since this is a lightweight menubar app, performance is critical:

- **Minimize memory usage** - avoid unnecessary object retention
- **Use background threads** - keep file I/O off the main thread
- **Lazy initialization** - only create objects when needed
- **Efficient algorithms** - avoid O(n²) operations where possible
- **Profile your changes** - use Instruments to verify no regressions

#### Security Guidelines

- **Never disable sandboxing** without discussion
- **Use security-scoped bookmarks** for file access
- **Validate all user input**
- **Don't log sensitive information**
- **Follow Apple's security best practices**

## Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Claude-Tracker.git
   cd Claude-Tracker
   ```

2. Open in Xcode:
   ```bash
   open Claude-Tracker/Claude-Tracker.xcodeproj
   ```

3. Build and run (⌘+R)

## Testing

Currently, the project doesn't have automated tests (contributions welcome!). Please manually test:

- Launch the app from Xcode
- Grant file access when prompted
- Verify stats display correctly
- Check memory usage in Activity Monitor
- Test with missing stats file
- Test with invalid JSON in stats file
- Verify file monitoring updates automatically

## Project Structure

```
Claude-Tracker/
├── ClaudeStats.swift          # Data models & parsing
├── StatsMonitor.swift         # File monitoring
├── FileAccessManager.swift    # Sandboxed file access
├── MenuBarView.swift          # UI components
├── Claude_TrackerApp.swift    # App lifecycle
└── Info.plist                 # Configuration
```

## Commit Message Format

Use clear, descriptive commit messages:

```
Add feature to export usage data to CSV

- Implement CSV export functionality
- Add export button to popover UI
- Handle file save dialog
- Format data with proper headers
```

Good commit messages:
- ✅ "Fix crash when stats file is missing"
- ✅ "Add dark mode support for chart colors"
- ✅ "Optimize JSON parsing performance by 30%"

Bad commit messages:
- ❌ "Fix bug"
- ❌ "Update code"
- ❌ "WIP"

## Questions?

Feel free to open an issue with the "question" label if you have questions about contributing.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
