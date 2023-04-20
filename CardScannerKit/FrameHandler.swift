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
    
    private let context = CIContext()
    private var startScan: Bool = false
    private var permissionGranted: Bool = false
    private var takeScreenShot: Bool = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")

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
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = captureSession
    }
    
}

extension CardFrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        imageFromSampleBuffer(sampleBuffer: sampleBuffer)
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        if takeScreenShot {
            self.startScan = false
            self.takeScreenShot = false
            self.captureSession.stopRunning()
            self.cardImage = convert(cmage: ciImage)
            return
        }
        
        if startScan {
            let requestHandler = VNSequenceRequestHandler()
            let textDetectionRequest = VNDetectTextRectanglesRequest()
            let documentRequest = VNDetectDocumentSegmentationRequest()
            
            textDetectionRequest.usesCPUOnly = false
            documentRequest.usesCPUOnly = false
            try? requestHandler.perform([textDetectionRequest, documentRequest], on: ciImage)
            
            if completedVisionRequest(textDetectionRequest, documentRequest) {
                self.startScan.toggle()
                self.captureSession.stopRunning()
                self.cardImage = convert(cmage: ciImage)
            }
        }
    }
    
    func convert(cmage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let image = UIImage(cgImage: cgImage)
        return image
    }
        
    func completedVisionRequest(_ textDetectionRequest: VNRequest?,_ documentRequest: VNRequest?) -> Bool {
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
        
        if let confidence = documentRectangles.last?.confidence {
            print(confidence)
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
