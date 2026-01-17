# Bus Label Detector - Singapore Bus Number Recognition

A native iOS application built with Swift 6 that detects and recognizes Singapore bus numbers in real-time using the device camera. The app works completely offline without requiring internet connectivity.

## Features

- ✅ **Real-time Detection**: Instantly recognizes bus numbers through the camera
- ✅ **Offline Operation**: Uses on-device Vision framework - no internet required
- ✅ **Fast & Accurate**: Optimized for real-time performance with high accuracy
- ✅ **Singapore Bus Numbers**: Supports all Singapore bus number formats:
  - Standard numbers (e.g., 2, 15, 969)
  - Numbers with letters (e.g., 2A, 197A)
  - Special services (e.g., CT18, NR8)
- ✅ **Clean UI**: Detected bus number displayed prominently on camera preview
- ✅ **Native Swift 6**: Built with the latest Swift features and best practices

## Technology Stack

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Camera**: AVFoundation
- **Text Recognition**: Vision Framework (on-device OCR)
- **Minimum iOS**: iOS 17.0+

## Project Structure

```
BusLabelDetector/
├── BusLabelDetectorApp.swift    # App entry point
├── ContentView.swift             # Main view
├── CameraView.swift              # Camera preview UI with overlay
├── CameraManager.swift           # Camera & text recognition logic
├── Info.plist                    # App configuration & permissions
└── Assets.xcassets/              # App icons and colors
```

## Key Components

### CameraManager
- Manages AVCaptureSession for camera input
- Processes video frames using Vision framework
- Implements text recognition with VNRecognizeTextRequest
- Validates detected text against Singapore bus number patterns
- Includes debouncing logic for stable detection

### CameraView
- SwiftUI view with camera preview
- Displays detected bus number in overlay
- Responsive UI with clear visual feedback

### Bus Number Detection
The app recognizes Singapore bus numbers using regex patterns:
- Standard: `1-3 digits` (e.g., 2, 15, 969)
- With suffix: `1-3 digits + letter` (e.g., 2A, 197A)
- With prefix: `1-2 letters + 1-3 digits + optional letter` (e.g., CT18, NR8)

## Building the App

### Requirements
- macOS with Xcode 15.0 or later
- iOS 17.0+ device or simulator
- Apple Developer account (for device testing)

### Build Steps

1. Open the project in Xcode:
   ```bash
   open BusLabelDetector/BusLabelDetector.xcodeproj
   ```

2. Select your target device or simulator

3. Build and run (⌘R)

### Configuration

The app requires camera permissions. The permission request is configured in `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to detect and recognize Singapore bus numbers in real-time.</string>
```

## Usage

1. Launch the app
2. Grant camera permission when prompted
3. Point the camera at a bus number
4. The detected number will appear on screen in a large, bold label
5. Move the camera to detect different bus numbers

## Performance Optimizations

- **Fast Recognition**: Uses `VNRecognitionLevel.fast` for real-time performance
- **Debouncing**: Requires 3 consecutive detections to avoid flickering
- **Queue Management**: Separate queues for camera and processing
- **Frame Dropping**: Discards late frames to maintain smooth performance
- **Language Optimization**: Set to English for Singapore bus numbers

## Architecture Highlights

- **@MainActor**: Ensures UI updates on main thread
- **ObservableObject**: Reactive state management with Combine
- **Separation of Concerns**: Camera, recognition, and UI are separate
- **Type Safety**: Leverages Swift 6 strict concurrency checking

## Supported Bus Number Formats

The app is designed to recognize various Singapore bus number formats:
- Single digit: 2, 5, 7
- Double digit: 15, 66, 97
- Triple digit: 130, 197, 969
- With letter suffix: 2A, 66A, 197A
- Special services: NR1-NR8, CT18, etc.

## Future Enhancements

Potential improvements:
- Support for more bus types (e.g., express buses)
- History of detected bus numbers
- Integration with real-time bus arrival data
- Support for bus stop numbers
- Dark mode optimization

## License

This project is open source and available for educational and commercial use.

## Requirements Summary

✅ Native iOS application using Swift 6
✅ Detects Singapore bus numbers
✅ Runs natively without internet connection
✅ Fast and accurate detection using Vision framework
✅ Displays detected number on camera preview overlay