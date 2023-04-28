//
//  FrameHandler.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import AVFoundation
import Vision
import SwiftUI


public class ImagePermissionHandler {
    public static let shared = ImagePermissionHandler()
    
    private init() { }
    
    public func checkPermissions(_ completion: @escaping (Bool) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return completion(true)
        case .notDetermined:
            requestPermissions(completion)
        default:
            completion(false)
        }
    }

    func requestPermissions(_ completion: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { granted in completion(granted)}
    }
}

class CardFrameHandler: NSObject, ObservableObject {
    @Published var cardImage: UIImage?
    let previewLayer = AVCaptureVideoPreviewLayer()
    let autoCropImage: Bool
    
    private let context = CIContext()
    private var startScan: Bool = false
    private var permissionGranted: Bool = false
    private var takeScreenShot: Bool = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    private let requestHandler = VNSequenceRequestHandler()
    private let textDetectionRequest = VNDetectTextRectanglesRequest()
    private let documentRequest = VNDetectDocumentSegmentationRequest()
    
    init(autoCropImage: Bool) {
        self.autoCropImage = autoCropImage
    }

    func startCamera(scanDelay: Double) {
        checkPermissions()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
        
        sessionQueue.asyncAfter(deadline: .now() + scanDelay) {
            self.startScan = true
        }
    }
    
    func stopCamera() {
        self.captureSession.stopRunning()
        self.startScan = false
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermissions()
        default:
            permissionGranted = false
        }
    }
    
    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        guard permissionGranted else { return }
        
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
//        videoDeviceInput.videoMinFrameDurationOverride = CMTimeMake(value: 1, timescale: 15)
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
//        videoOutput.connection(with: .video)?.videoOrientation = .landscapeRight
//        videoOutput.connection(with: .video)?.videoOrientation = .landscapeLeft
        
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080 // resolution
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = captureSession
        
        textDetectionRequest.reportCharacterBoxes = false
        textDetectionRequest.usesCPUOnly = false
        documentRequest.usesCPUOnly = false
    }
    
}

extension CardFrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        imageFromSampleBuffer(sampleBuffer: sampleBuffer)
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Error: Unable to get image from sample buffer")
            return
        }
        
        var ciImage = CIImage(cvImageBuffer: imageBuffer)
        
        if takeScreenShot {
            self.startScan = false
            self.takeScreenShot = false
            self.captureSession.stopRunning()
            try? requestHandler.perform([textDetectionRequest, documentRequest], on: ciImage)

            if autoCropImage && validCompletedVisionRequest(textDetectionRequest, documentRequest) {
                ciImage = doPerspectiveCorrection(ciImage, detectedDocument: documentRequest.results?.first)
            }
            DispatchQueue.main.async {
                self.cardImage = self.convert(cmage: ciImage)
            }
            return
        }
        
        if startScan {
            try? requestHandler.perform([textDetectionRequest, documentRequest], on: ciImage)
            
            if validCompletedVisionRequest(textDetectionRequest, documentRequest) {
                self.startScan.toggle()
                self.captureSession.stopRunning()
                
                if autoCropImage {
                    ciImage = doPerspectiveCorrection(ciImage, detectedDocument: documentRequest.results?.first)
                }
                DispatchQueue.main.async {
                    self.cardImage = self.convert(cmage: ciImage)
                }
                return
            }
        }
    }
    
    private func doPerspectiveCorrection(_ ciImage: CIImage, detectedDocument: VNRectangleObservation?) -> CIImage {
        guard let observedDocument = detectedDocument else { return ciImage }
                        
        // Get the size of the original image
        let imageSize = ciImage.extent.size
        // Convert the bounding box from normalized coordinates to pixel coordinates
        let x = observedDocument.boundingBox.origin.x * imageSize.width
        let y = observedDocument.boundingBox.origin.y * imageSize.height
        let width = observedDocument.boundingBox.width * imageSize.width
        let height = observedDocument.boundingBox.height * imageSize.height

        // Create a rect from the pixel coordinates
        let rect = CGRect(x: x, y: y, width: width + 50, height: height + 50)
        
//        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
//            "inputTopLeft": CIVector(cgPoint: topLeft),
//            "inputTopRight": CIVector(cgPoint: topRight),
//            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//            "inputBottomRight": CIVector(cgPoint: bottomRight),
//        ])
        
        // Crop the original image to the rect
        let croppedImage = ciImage.cropped(to: rect)
        return croppedImage
    }
    
    private func convert(cmage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let image = UIImage(cgImage: cgImage)
        return image
    }
        
    private func validCompletedVisionRequest(_ textDetectionRequest: VNRequest?,_ documentRequest: VNRequest?) -> Bool {
        // Only proceed if a rectangular image was detected.
        guard let textRectangles = textDetectionRequest?.results as? [VNObservation] else {
            return false
        }

        if textRectangles.count == 0 {
            return false
        }
    
        guard let documentRectangles = documentRequest?.results as? [VNRectangleObservation] else {
            return false
        }
        
        if documentRectangles.count == 0 {
            return false
        }
        
        if let confidence = documentRectangles.first?.confidence {
            return confidence > 0.95
        } else {
            return false
        }
    }
    
    func captureImage() {
        startScan = false
        takeScreenShot = true
    }
}
