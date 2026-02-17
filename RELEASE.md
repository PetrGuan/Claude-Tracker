# Release Guide

This guide explains how to create and publish releases for Claude Tracker.

## Automated Release (Recommended)

We use GitHub Actions to automatically build and publish releases when you create a version tag.

### Steps:

1. **Ensure everything is committed and pushed**
   ```bash
   git add .
   git commit -m "Prepare for release v1.0.0"
   git push
   ```

2. **Create and push a version tag**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **GitHub Actions automatically:**
   - Builds the Release version
   - Creates the DMG installer
   - Creates a GitHub Release
   - Uploads the DMG as a release asset
   - Generates release notes from commits

4. **View your release**
   - Go to: `https://github.com/YOUR_USERNAME/Claude-Tracker/releases`
   - Edit the release notes if needed
   - Publish (if draft)

### Version Numbering

Use semantic versioning: `v{MAJOR}.{MINOR}.{PATCH}`

- **MAJOR** - Breaking changes (v2.0.0)
- **MINOR** - New features (v1.1.0)
- **PATCH** - Bug fixes (v1.0.1)

Examples:
```bash
git tag v1.0.0    # First release
git tag v1.1.0    # Added new feature
git tag v1.0.1    # Bug fix
```

## Manual Release (Alternative)

If you prefer to create releases manually or GitHub Actions doesn't work:

### 1. Build the DMG locally

```bash
cd Claude-Tracker
xcodebuild -project Claude-Tracker.xcodeproj \
  -scheme Claude-Tracker \
  -configuration Release \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  clean build

# Create DMG
mkdir -p dist
cp -R ~/Library/Developer/Xcode/DerivedData/.../Build/Products/Release/Claude-Tracker.app dist/
hdiutil create -volname "Claude Tracker" \
  -srcfolder dist \
  -ov -format UDZO \
  Claude-Tracker.dmg
```

### 2. Create GitHub Release manually

1. Go to: `https://github.com/YOUR_USERNAME/Claude-Tracker/releases/new`
2. Create a new tag (e.g., `v1.0.0`)
3. Release title: "Claude Tracker v1.0.0"
4. Description: Add release notes (see template below)
5. Upload `Claude-Tracker.dmg` as an asset
6. Click "Publish release"

### Release Notes Template

```markdown
## 🎉 Claude Tracker v1.0.0

### ✨ Features
- Real-time token usage monitoring for Claude Code
- Visual 7-day usage chart
- Cost estimation based on Anthropic pricing
- Native macOS menubar application
- Ultra-lightweight (8-15MB RAM, 0% CPU)
- Sandboxed for security

### 📦 Installation

Download `Claude-Tracker.dmg` below, open it, and drag the app to Applications.

**First launch:** Right-click the app and select "Open" to bypass Gatekeeper (app is unsigned).

See [INSTALL.md](https://github.com/YOUR_USERNAME/Claude-Tracker/blob/main/INSTALL.md) for detailed instructions.

### 🔧 Requirements
- macOS 13.0 (Ventura) or later
- Claude Code installed

### 📝 Full Changelog
- Initial release
- 100% AI-generated codebase

**Full Changelog**: https://github.com/YOUR_USERNAME/Claude-Tracker/commits/v1.0.0
```

## Updating the DMG Download Link

After creating a release, users can download from:
```
https://github.com/YOUR_USERNAME/Claude-Tracker/releases/latest/download/Claude-Tracker.dmg
```

This URL always points to the latest release, so your README stays up to date automatically.

## Release Checklist

Before creating a release:

- [ ] All code is committed and pushed
- [ ] Version number updated in Info.plist (if applicable)
- [ ] README is up to date
- [ ] CHANGELOG updated (if you maintain one)
- [ ] App tested on clean macOS install
- [ ] DMG builds successfully
- [ ] Installation instructions verified

## Release Workflow

```
┌─────────────────┐
│ Development     │
│ & Testing       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Commit Changes  │
│ git push        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Create Tag      │
│ git tag v1.0.0  │
│ git push --tags │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ GitHub Actions  │
│ Auto-builds DMG │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ GitHub Release  │
│ Published!      │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Users Download  │
│ & Install       │
└─────────────────┘
```

## Troubleshooting

### GitHub Actions fails to build

Check the Actions tab for error logs. Common issues:
- Xcode version mismatch
- Missing dependencies
- Build settings errors

### DMG too large

The DMG should be ~150KB. If larger:
```bash
# Use better compression
hdiutil create -volname "Claude Tracker" \
  -srcfolder dist \
  -ov -format UDZO \
  -imagekey zlib-level=9 \
  Claude-Tracker.dmg
```

### Release not showing up

- Ensure tag was pushed: `git push --tags`
- Check GitHub Actions status
- Verify workflow permissions in repo settings

## Code Signing (Future)

To remove the "unsigned app" warning:

1. Join Apple Developer Program ($99/year)
2. Get Developer ID certificate
3. Update build settings:
   ```bash
   codesign --deep --force \
     --sign "Developer ID Application: Your Name" \
     Claude-Tracker.app
   ```
4. Notarize with Apple:
   ```bash
   xcrun notarytool submit Claude-Tracker.dmg \
     --apple-id your@email.com \
     --team-id TEAMID \
     --password app-specific-password \
     --wait
   ```

## Distribution Summary

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| GitHub Releases | Free, simple, version control | Manual download | Open source projects |
| Homebrew Cask | Easy install for devs | Requires approval | CLI users |
| App Store | No warnings, auto-updates | $99/year, review process | Mainstream users |
| Direct DMG | Quick sharing | No version tracking | Beta testing |

## Monitoring Downloads

Check download statistics:
1. Go to Releases page
2. Scroll to Assets
3. View download count for each DMG

GitHub tracks downloads per version automatically.

---

*This release guide was AI-generated as part of our AI-native development philosophy.*
