# MoneyAssist iOS - Build Instructions

## Prerequisites

### System Requirements
- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 18.0 or later (deployment target)
- CocoaPods (optional, for dependencies)

### Development Tools
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
```

---

## Project Setup

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/monassist-native.git
cd MonassistNative
```

### 2. Install Dependencies (if using CocoaPods)
```bash
pod install
```

### 3. Open Project
```bash
# Using Xcode
open MonassistNative.xcodeproj

# Or if using CocoaPods
open MonassistNative.xcworkspace
```

---

## Configuration

### 1. API Configuration
Update `APIService.swift` with your backend URL:

```swift
private let baseUrl = "https://your-backend-url.com/api"
```

### 2. App Identifier
Update in Xcode:
1. Select project → MonassistNative target
2. General tab → Bundle Identifier
3. Change to your unique identifier (e.g., `com.yourcompany.monassist`)

### 3. Signing & Capabilities
1. Select project → MonassistNative target
2. Signing & Capabilities tab
3. Select your team
4. Enable required capabilities:
   - Face ID (if using biometric auth)
   - Push Notifications (if needed)

### 4. Info.plist
Verify all permissions are set:
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSMicrophoneUsageDescription
- NSSpeechRecognitionUsageDescription
- NSFaceIDUsageDescription
- NSLocationWhenInUseUsageDescription

---

## Building for Development

### 1. Select Simulator or Device
```bash
# List available simulators
xcrun simctl list devices

# Select simulator in Xcode
Product → Destination → [Select Simulator]
```

### 2. Build & Run
```bash
# Using Xcode
Product → Run (⌘R)

# Or using command line
xcodebuild -scheme MonassistNative -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

### 3. Run on Physical Device
1. Connect iPhone via USB
2. Trust the computer on iPhone
3. Select device in Xcode
4. Product → Run (⌘R)

---

## Building for Release

### 1. Archive Build
```bash
# Using Xcode
Product → Archive

# Or using command line
xcodebuild -scheme MonassistNative -configuration Release archive -archivePath ./build/MonassistNative.xcarchive
```

### 2. Export IPA
```bash
# Using Xcode
1. Window → Organizer
2. Select archive
3. Distribute App
4. Select distribution method (Ad Hoc, Enterprise, or App Store)
5. Follow prompts

# Or using command line
xcodebuild -exportArchive \
  -archivePath ./build/MonassistNative.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath ./build/
```

### 3. ExportOptions.plist
Create `ExportOptions.plist` for command line export:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
</dict>
</plist>
```

---

## Building IPA for Distribution

### 1. Ad Hoc Distribution
```bash
# Create Ad Hoc IPA
xcodebuild -scheme MonassistNative \
  -configuration Release \
  -derivedDataPath build \
  -archivePath build/MonassistNative.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/MonassistNative.xcarchive \
  -exportOptionsPlist ExportOptions-AdHoc.plist \
  -exportPath build/
```

### 2. App Store Distribution
```bash
# Create App Store IPA
xcodebuild -exportArchive \
  -archivePath build/MonassistNative.xcarchive \
  -exportOptionsPlist ExportOptions-AppStore.plist \
  -exportPath build/
```

### 3. Enterprise Distribution
```bash
# Create Enterprise IPA
xcodebuild -exportArchive \
  -archivePath build/MonassistNative.xcarchive \
  -exportOptionsPlist ExportOptions-Enterprise.plist \
  -exportPath build/
```

---

## Testing

### 1. Unit Tests
```bash
# Run all tests
xcodebuild test -scheme MonassistNative

# Run specific test class
xcodebuild test -scheme MonassistNative -only-testing:MonassistNativeTests/HomeViewModelTests
```

### 2. UI Tests
```bash
# Run UI tests
xcodebuild test -scheme MonassistNative -only-testing:MonassistNativeUITests
```

### 3. Code Coverage
```bash
# Generate coverage report
xcodebuild test \
  -scheme MonassistNative \
  -enableCodeCoverage YES \
  -derivedDataPath build
```

---

## Debugging

### 1. Console Logging
```swift
print("Debug message: \(value)")
```

### 2. Breakpoints
1. Click line number to set breakpoint
2. Run app (⌘R)
3. App pauses at breakpoint
4. Use Debug Navigator to inspect variables

### 3. Network Debugging
```swift
// Enable network logging in APIService
print("GET Request -> \(url.absoluteString)")
print("Response Code -> \(statusCode)")
```

### 4. View Hierarchy Debugger
1. Run app
2. Debug → View Hierarchy
3. Inspect view layers and properties

---

## Performance Optimization

### 1. Profiling
```bash
# Profile with Instruments
xcodebuild -scheme MonassistNative -configuration Release -derivedDataPath build
open build/Logs/Build/MonassistNative.xcarchive
```

### 2. Memory Leaks
1. Product → Scheme → Edit Scheme
2. Run → Diagnostics
3. Enable "Malloc Stack"
4. Run app and check for leaks

### 3. App Size
```bash
# Check app size
du -sh build/MonassistNative.app
```

---

## Continuous Integration (GitHub Actions)

### 1. Create Workflow File
Create `.github/workflows/build.yml`:

```yaml
name: Build iOS App

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode version
      run: sudo xcode-select -s /Applications/Xcode_15.0.app/Contents/Developer
    
    - name: Build
      run: |
        xcodebuild -scheme MonassistNative \
          -configuration Release \
          -derivedDataPath build \
          -archivePath build/MonassistNative.xcarchive \
          archive
    
    - name: Export IPA
      run: |
        xcodebuild -exportArchive \
          -archivePath build/MonassistNative.xcarchive \
          -exportOptionsPlist ExportOptions.plist \
          -exportPath build/
    
    - name: Upload Artifact
      uses: actions/upload-artifact@v3
      with:
        name: MonassistNative.ipa
        path: build/MonassistNative.ipa
```

---

## Troubleshooting

### Build Errors

#### "Xcode cannot find module"
```bash
# Clean build folder
xcodebuild clean -scheme MonassistNative

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Rebuild
xcodebuild build -scheme MonassistNative
```

#### "Code signing error"
1. Xcode → Preferences → Accounts
2. Add Apple ID
3. Download provisioning profiles
4. Select correct team in project settings

#### "Pod install fails"
```bash
# Update CocoaPods
sudo gem install cocoapods

# Remove Pods and lock file
rm -rf Pods Podfile.lock

# Reinstall
pod install
```

### Runtime Errors

#### "API connection fails"
1. Check API URL in APIService.swift
2. Verify backend is running
3. Check network connectivity
4. Review API response in console

#### "Keychain access denied"
1. Check app entitlements
2. Verify Keychain sharing is enabled
3. Check app identifier matches provisioning profile

#### "Permission denied"
1. Check Info.plist permissions
2. Verify user granted permission
3. Check permission request timing

---

## Release Checklist

- [ ] Update version number (CFBundleShortVersionString)
- [ ] Update build number (CFBundleVersion)
- [ ] Update CHANGELOG.md
- [ ] Run all tests
- [ ] Check code coverage
- [ ] Review API endpoints
- [ ] Test on physical device
- [ ] Verify all permissions work
- [ ] Check dark/light mode
- [ ] Test accessibility features
- [ ] Create archive
- [ ] Export IPA
- [ ] Submit to App Store (if applicable)

---

## Deployment

### 1. TestFlight (Beta Testing)
1. Archive app
2. Export for App Store
3. Upload to TestFlight via Xcode or App Store Connect
4. Add testers
5. Distribute build

### 2. App Store
1. Archive app
2. Export for App Store
3. Upload via Xcode or Transporter
4. Fill app information
5. Submit for review

### 3. Ad Hoc Distribution
1. Archive app
2. Export Ad Hoc IPA
3. Distribute via email or file sharing
4. Users install via Xcode or Apple Configurator

---

## Version Management

### Semantic Versioning
- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes

Example: 1.2.3
- 1 = MAJOR
- 2 = MINOR
- 3 = PATCH

### Update Version
```bash
# In Xcode
1. Select project
2. General tab
3. Update "Version" (CFBundleShortVersionString)
4. Update "Build" (CFBundleVersion)
```

---

## Documentation

- API Documentation: `BACKEND_DOCUMENTATION.md`
- Database Schema: `DATABASE_SCHEMA.md`
- Code Style Guide: Follow Swift API Design Guidelines
- Architecture: MVVM + Combine/Observation

---

## Support

For issues or questions:
1. Check troubleshooting section
2. Review API documentation
3. Check GitHub issues
4. Contact development team

---

## Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [Xcode Help](https://help.apple.com/xcode/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
