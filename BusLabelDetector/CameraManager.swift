//
//  CameraManager.swift
//  BusLabelDetector
//
//  Created on 2026-01-17.
//

import AVFoundation
import Vision
import UIKit

@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var detectedBusNumber: String?
    @Published var permissionGranted = false
    
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let processingQueue = DispatchQueue(label: "camera.processing.queue")
    
    // Debouncing mechanism to stabilize detection
    private var lastDetectionTime = Date()
    private var consecutiveDetections: [String] = []
    private let detectionConfidenceThreshold = 3 // Require 3 consecutive same readings
    private let detectionCooldown: TimeInterval = 0.3 // Minimum time between detections
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.permissionGranted = granted
                    if granted {
                        self?.startSession()
                    }
                }
            }
        default:
            permissionGranted = false
        }
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            print("Failed to setup camera input")
            return
        }
        
        captureSession.addInput(videoInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        guard captureSession.canAddOutput(videoOutput) else {
            print("Failed to setup camera output")
            return
        }
        
        captureSession.addOutput(videoOutput)
        
        // Configure video orientation
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
    }
    
    private func startSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    // Process detected text and extract Singapore bus numbers
    private func processBusNumber(from text: String) -> String? {
        // Singapore bus numbers can be:
        // - 1 to 3 digits (e.g., 2, 15, 969)
        // - May include letters (e.g., 2A, 197A, NR8)
        // - Special services may have prefixes (e.g., CT18, NR1)
        
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Pattern for Singapore bus numbers
        // Matches: digits only (1-3), digits with single letter, or prefix+digits+optional letter
        let patterns = [
            "^[0-9]{1,3}[A-Z]?$",           // Standard: 2, 15A, 969
            "^[A-Z]{1,2}[0-9]{1,3}[A-Z]?$", // With prefix: CT18, NR8
            "^[0-9]{1,3}[a-z]?$",           // Lowercase variant: 15a
            "^[a-z]{1,2}[0-9]{1,3}[a-z]?$"  // Lowercase prefix variant
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               regex.firstMatch(in: cleanedText, range: NSRange(cleanedText.startIndex..., in: cleanedText)) != nil {
                return cleanedText.uppercased()
            }
        }
        
        return nil
    }
    
    private func updateDetectedBusNumber(_ number: String) {
        let now = Date()
        
        // Add to consecutive detections
        consecutiveDetections.append(number)
        
        // Keep only recent detections
        if consecutiveDetections.count > detectionConfidenceThreshold {
            consecutiveDetections.removeFirst()
        }
        
        // Check if we have enough consecutive same detections
        if consecutiveDetections.count >= detectionConfidenceThreshold,
           Set(consecutiveDetections).count == 1,
           now.timeIntervalSince(lastDetectionTime) > detectionCooldown {
            
            self.detectedBusNumber = number
            self.lastDetectionTime = now
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Create Vision request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            // Process all detected text
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    continue
                }
                
                let recognizedText = topCandidate.string
                
                // Check if this looks like a bus number
                if let busNumber = self.processBusNumber(from: recognizedText) {
                    Task { @MainActor in
                        self.updateDetectedBusNumber(busNumber)
                    }
                    return // Stop after first valid bus number found
                }
            }
        }
        
        // Configure text recognition for optimal performance
        request.recognitionLevel = .fast // Use fast recognition for real-time performance
        request.usesLanguageCorrection = false // Disable for speed
        request.recognitionLanguages = ["en-US"] // Singapore uses English
        
        // Perform the request
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        try? handler.perform([request])
    }
}
