# Technical Documentation - Bus Label Detector

## Overview

This native iOS application uses Apple's Vision framework to detect and recognize Singapore bus numbers in real-time through the device camera. The solution is completely offline and optimized for speed and accuracy.

## Architecture

### Component Hierarchy

```
BusLabelDetectorApp (App Entry)
└── ContentView (SwiftUI)
    └── CameraView (SwiftUI)
        ├── CameraPreviewView (UIViewRepresentable)
        └── CameraManager (ObservableObject)
```

## Key Technologies

### 1. AVFoundation
- **Purpose**: Camera capture and video processing
- **Components**:
  - `AVCaptureSession`: Manages data flow from camera to app
  - `AVCaptureDevice`: Accesses rear camera
  - `AVCaptureVideoDataOutput`: Provides video frames for processing
  - `AVCaptureVideoPreviewLayer`: Displays live camera feed

### 2. Vision Framework
- **Purpose**: On-device text recognition (OCR)
- **Components**:
  - `VNRecognizeTextRequest`: Performs text detection
  - `VNRecognizedTextObservation`: Contains detected text results
  - `VNImageRequestHandler`: Processes each video frame

### 3. SwiftUI
- **Purpose**: Modern reactive UI
- **Components**:
  - `@StateObject`: Manages CameraManager lifecycle
  - `@Published`: Reactive state updates
  - `UIViewRepresentable`: Bridges UIKit camera preview

## Implementation Details

### Camera Setup

1. **Session Configuration**:
   ```swift
   captureSession.sessionPreset = .high
   ```
   Uses high-quality preset for better OCR accuracy

2. **Video Output**:
   ```swift
   videoOutput.videoSettings = [
       kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA
   ]
   ```
   BGRA format is optimal for Vision framework

3. **Thread Safety**:
   - Camera operations run on `sessionQueue`
   - Processing runs on `processingQueue`
   - UI updates on main thread via `@MainActor`

### Text Recognition Pipeline

```
Video Frame → CMSampleBuffer → CVPixelBuffer → VNImageRequestHandler
→ VNRecognizeTextRequest → VNRecognizedTextObservation → Bus Number Validation
```

### Performance Optimizations

1. **Fast Recognition Mode**:
   ```swift
   request.recognitionLevel = .fast
   ```
   Prioritizes speed over maximum accuracy (suitable for real-time)

2. **Frame Dropping**:
   ```swift
   videoOutput.alwaysDiscardsLateVideoFrames = true
   ```
   Prevents processing backlog

3. **Language Optimization**:
   ```swift
   request.recognitionLanguages = ["en-US"]
   request.usesLanguageCorrection = false
   ```
   Reduces processing time by limiting language model

4. **Early Exit**:
   ```swift
   return // Stop after first valid bus number found
   ```
   Stops processing once a valid bus number is detected

### Debouncing Algorithm

Prevents flickering by requiring stable detections:

```swift
private var consecutiveDetections: [String] = []
private let detectionConfidenceThreshold = 3
private let detectionCooldown: TimeInterval = 0.3
```

**Logic**:
1. Store last 3 detections in array
2. Only update UI if all 3 are identical
3. Enforce 0.3s cooldown between updates
4. Provides stable, flicker-free display

### Singapore Bus Number Patterns

The app validates against these regex patterns:

| Pattern | Example | Description |
|---------|---------|-------------|
| `^[0-9]{1,3}[A-Z]?$` | 2, 15, 969, 2A, 197A | Standard format |
| `^[A-Z]{1,2}[0-9]{1,3}[A-Z]?$` | CT18, NR8 | Prefix format |
| `^[0-9]{1,3}[a-z]?$` | 15a | Lowercase variant |
| `^[a-z]{1,2}[0-9]{1,3}[a-z]?$` | ct18 | Lowercase prefix |

All detected numbers are normalized to uppercase.

## Swift 6 Features

### Concurrency

1. **@MainActor**:
   ```swift
   @MainActor
   class CameraManager: NSObject, ObservableObject
   ```
   Ensures all property access happens on main thread

2. **nonisolated**:
   ```swift
   nonisolated func captureOutput(...)
   ```
   Allows delegate callback on background thread

3. **Task**:
   ```swift
   Task { @MainActor in
       self?.detectedBusNumber = number
   }
   ```
   Hops back to main actor for UI updates

### Type Safety

- Strict concurrency checking enabled
- Sendable protocol compliance
- Isolation enforced at compile time

## Permission Handling

The app requests camera access with a clear message:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to detect and recognize 
Singapore bus numbers in real-time.</string>
```

Permission flow:
1. Check current authorization status
2. Request if not determined
3. Start camera session if granted
4. Show message if denied

## UI Design

### Layout

```
ZStack
├── CameraPreviewView (background, full screen)
└── VStack
    ├── Spacer
    ├── Text (detected number or prompt)
    └── Spacer
```

### Visual Hierarchy

- **Detected Number**: 
  - 72pt bold rounded font
  - White on black background (70% opacity)
  - 20pt rounded corners
  - Drop shadow for depth

- **Prompt Message**:
  - 20pt medium weight
  - White on black background (50% opacity)
  - 15pt rounded corners

## Offline Capability

The app is completely offline because:

1. **Vision Framework**: 
   - Runs entirely on-device
   - Uses Apple Neural Engine
   - No network requests

2. **No External Dependencies**:
   - No third-party SDKs
   - No API calls
   - No cloud services

3. **Local Processing**:
   - All text recognition is local
   - Pattern matching is local
   - No telemetry or analytics

## Testing Considerations

### On Simulator

- Camera preview won't work (no camera)
- Can test UI layout and state management
- Cannot test actual text recognition

### On Physical Device

- Full functionality available
- Test with actual bus numbers or printed samples
- Verify different lighting conditions
- Test various angles and distances

## Best Practices Implemented

1. ✅ Resource Management: Proper session lifecycle
2. ✅ Thread Safety: Separate queues for different tasks
3. ✅ Memory Management: Weak references to prevent cycles
4. ✅ Error Handling: Graceful degradation on failures
5. ✅ User Privacy: Clear permission messages
6. ✅ Performance: Optimized for real-time operation
7. ✅ Accessibility: SwiftUI's built-in support
8. ✅ Code Organization: Clear separation of concerns

## Potential Improvements

### Accuracy
- Add custom ML model trained on Singapore bus numbers
- Implement region of interest (ROI) detection
- Add multiple frame aggregation

### Features
- History of detected numbers
- Sound feedback on detection
- Support for bus stop codes
- Night mode optimization

### Performance
- Implement adaptive frame rate
- Dynamic quality adjustment
- Battery optimization mode

## Build Configuration

### Requirements
- **Xcode**: 15.0+
- **Swift**: 6.0
- **iOS**: 17.0+
- **Deployment Target**: iPhone/iPad

### Frameworks Used
- SwiftUI (UI)
- AVFoundation (Camera)
- Vision (Text Recognition)
- Combine (Reactive Programming)

### Bundle Settings
- **Bundle Identifier**: com.buslabeldetector.app
- **Display Name**: Bus Number Detector
- **Version**: 1.0 (Build 1)

## Security & Privacy

### Data Collection
- **None**: No user data is collected
- **No Analytics**: No tracking or telemetry
- **No Network**: Completely offline

### Permissions
- **Camera**: Required for core functionality
- **Clear Purpose**: Explicit usage description

### Code Security
- **No Hardcoded Secrets**: Clean codebase
- **Safe APIs**: Uses Apple's secure frameworks
- **Sandboxed**: Standard iOS app sandbox

## Conclusion

This implementation provides a fast, accurate, and privacy-respecting solution for detecting Singapore bus numbers using native iOS technologies. The offline-first approach ensures reliability and user privacy while maintaining excellent performance through careful optimization and modern Swift concurrency features.
