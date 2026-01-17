# Quick Start Guide

## Getting Started in 5 Minutes

### Prerequisites
- Mac with macOS Monterey or later
- Xcode 15.0 or later installed
- iPhone or iPad running iOS 17.0+ (for testing on real device)

### Step 1: Clone the Repository
```bash
git clone https://github.com/j2damax/bus-label-test.git
cd bus-label-test
```

### Step 2: Open in Xcode
```bash
open BusLabelDetector/BusLabelDetector.xcodeproj
```

### Step 3: Select Target Device
In Xcode:
1. Click on the device selector in the toolbar
2. Choose your iPhone/iPad (connected via USB or WiFi)
   - Or select an iPhone simulator for UI testing

### Step 4: Build and Run
Press **⌘R** or click the Play button in Xcode toolbar

### Step 5: Grant Camera Permission
When the app launches:
1. You'll see a permission dialog
2. Tap **"Allow"** to grant camera access
3. The camera preview will appear

### Step 6: Test Detection
Point your camera at:
- A bus number on a real bus
- A printed bus number (e.g., "197" or "NR8")
- A bus number displayed on a screen

The detected number will appear in large text on the screen!

## Troubleshooting

### "No camera available" on Simulator
**Solution**: Use a physical device. Camera functionality requires real hardware.

### Camera preview is black
**Solutions**:
- Check camera permission in Settings → Privacy → Camera
- Restart the app
- Ensure camera is not being used by another app

### Text recognition not working
**Solutions**:
- Ensure good lighting
- Hold device steady
- Keep bus number in frame and in focus
- Make sure bus number is clearly visible and not too small

### Build errors
**Solutions**:
- Clean build folder: **⌘+Shift+K**
- Update Xcode to latest version
- Check iOS deployment target is 17.0+

## Testing Tips

### Best Results
- ✅ Good, even lighting
- ✅ Clear, high-contrast bus numbers
- ✅ Hold camera steady (1-2 feet away)
- ✅ Keep number centered in view

### What to Avoid
- ❌ Very dim lighting
- ❌ Blurry or motion-blurred numbers
- ❌ Numbers too small in frame
- ❌ Extreme angles or reflections

## Next Steps

### Customize the App
1. **Change App Name**: 
   - Edit `Info.plist` → `CFBundleDisplayName`

2. **Modify Detection Logic**:
   - Edit patterns in `CameraManager.swift` → `processBusNumber()`

3. **Update UI**:
   - Edit `CameraView.swift` to change overlay appearance

4. **Add App Icon**:
   - Add images to `Assets.xcassets/AppIcon.appiconset/`

### Deploy to Device

#### For Personal Testing (Free)
1. Connect your iPhone
2. In Xcode, select your iPhone as target
3. Click Run (⌘R)
4. Trust certificate on device when prompted

#### For Distribution
1. Enroll in Apple Developer Program ($99/year)
2. Create App ID and Provisioning Profile
3. Configure signing in Xcode project settings
4. Archive and submit to App Store Connect

## Code Structure

```
BusLabelDetector/
├── BusLabelDetectorApp.swift    # App entry point
├── ContentView.swift             # Root view
├── CameraView.swift              # Main UI with camera
├── CameraManager.swift           # Camera and recognition logic
├── Info.plist                    # App configuration
└── Assets.xcassets/              # Images and colors
```

## Key Files to Edit

| File | Purpose | What to Change |
|------|---------|----------------|
| `CameraManager.swift` | Detection logic | Bus number patterns, debouncing |
| `CameraView.swift` | UI layout | Text size, colors, positioning |
| `Info.plist` | App settings | Permissions, bundle ID, version |

## Common Customizations

### Change Detection Confidence
```swift
// In CameraManager.swift
private let detectionConfidenceThreshold = 3 // Try 2 or 5
```

### Adjust Cooldown Period
```swift
// In CameraManager.swift
private let detectionCooldown: TimeInterval = 0.3 // Try 0.5 or 0.1
```

### Modify Text Style
```swift
// In CameraView.swift
.font(.system(size: 72, weight: .bold, design: .rounded))
// Change size, weight, or design
```

## Support

For issues or questions:
1. Check the README.md
2. Read TECHNICAL.md for details
3. Review code comments
4. Open an issue on GitHub

## Congratulations! 🎉

You now have a working Singapore bus number detector running on your device!
