# Installation Guide

## Quick Start

### 1. Download

Download the latest `Claude-Tracker.dmg` from the [Releases page](https://github.com/yourusername/Claude-Tracker/releases/latest).

### 2. Install

1. Open `Claude-Tracker.dmg`
2. Drag **Claude-Tracker.app** to your Applications folder
3. Eject the DMG

### 3. First Launch

1. Open **Applications** folder
2. Find **Claude-Tracker.app**
3. **Right-click** and select **Open** (required for first launch due to app not being signed)
4. Click **Open** in the security dialog

> **Why right-click?** The app is not signed with an Apple Developer certificate. Right-clicking bypasses Gatekeeper for unsigned apps.

### 4. Grant File Access

When the app launches, you'll see a dialog requesting file access:

1. Click **"Grant Access"**
2. In the file picker:
   - Press **⌘⇧.** (Command+Shift+Period) to show hidden files
   - Navigate to your home directory
   - Select the **`.claude`** folder (not a file, the folder itself)
   - Click **"Grant Access"**

The app will remember this permission and won't ask again.

### 5. Start Using

Look for the Claude C icon in your menubar (top-right of screen). Click it to see your token usage!

## Distribution Options

### For End Users

**DMG (Recommended)** - Simple drag-and-drop installation
- Download `Claude-Tracker.dmg`
- Works on any Mac running macOS 13.0+

### For Developers

**Build from Source** - Full control and customization
```bash
git clone https://github.com/yourusername/Claude-Tracker.git
cd Claude-Tracker/Claude-Tracker
open Claude-Tracker.xcodeproj
# Build with ⌘+R in Xcode
```

### For Advanced Users (Future)

**Homebrew Cask** (coming soon)
```bash
brew install --cask claude-tracker
```

## Troubleshooting

### "App is damaged and can't be opened"

This happens when Gatekeeper blocks unsigned apps:

**Solution 1** (Recommended):
1. Right-click the app
2. Select "Open"
3. Click "Open" in the dialog

**Solution 2** (Advanced):
```bash
xattr -cr /Applications/Claude-Tracker.app
```

### App doesn't appear in menubar

1. Check Activity Monitor - ensure Claude-Tracker is running
2. Quit and relaunch the app
3. Check System Settings > Login Items - ensure it's not blocked

### Can't find .claude folder

1. Open Finder
2. Press **⌘⇧.** (Command+Shift+Period) to toggle hidden files
3. Navigate to your home directory (⌘⇧H)
4. You should see a gray `.claude` folder

If it doesn't exist, you need to run Claude Code first to generate the stats file.

### File access dialog doesn't appear

The app already has access. You can:
1. Check System Settings > Privacy & Security > Files and Folders
2. Or reset access:
   ```bash
   defaults delete com.petrguan.Claude-Tracker claudeFolderBookmark
   ```
3. Relaunch the app

## Uninstallation

To completely remove Claude-Tracker:

1. Quit the app (right-click menubar icon)
2. Delete from Applications:
   ```bash
   rm -rf /Applications/Claude-Tracker.app
   ```
3. (Optional) Remove preferences:
   ```bash
   defaults delete com.petrguan.Claude-Tracker
   ```

## System Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3) or Intel Mac
- Claude Code installed and configured
- ~150KB disk space

## Security & Privacy

- The app is **sandboxed** for security
- Only requests **read-only** access to `.claude` folder
- **No network access** - all data stays local
- **No telemetry** - we don't collect anything
- **Open source** - inspect the code yourself

## Updating

When a new version is released:

1. Download the latest DMG
2. Quit the old version
3. Replace the app in Applications folder
4. Launch the new version

Your file access permissions are preserved across updates.

## Building for Distribution

### Creating a DMG

```bash
# Build release version
cd Claude-Tracker
xcodebuild -project Claude-Tracker.xcodeproj \
  -scheme Claude-Tracker \
  -configuration Release \
  clean build

# Create DMG
mkdir -p dist
cp -R ~/Library/Developer/Xcode/DerivedData/.../Claude-Tracker.app dist/
hdiutil create -volname "Claude Tracker" \
  -srcfolder dist \
  -ov -format UDZO \
  Claude-Tracker.dmg
```

### Code Signing (Optional)

For distribution outside the App Store, sign with Developer ID:

```bash
codesign --deep --force --sign "Developer ID Application: Your Name" \
  Claude-Tracker.app
```

## Support

- Report issues: [GitHub Issues](https://github.com/yourusername/Claude-Tracker/issues)
- Ask questions: [GitHub Discussions](https://github.com/yourusername/Claude-Tracker/discussions)

---

*This installation guide was AI-generated as part of our AI-native development philosophy.*
