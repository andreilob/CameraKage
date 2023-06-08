//
//  PhotoOutput.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

class PhotoOutput: AVCapturePhotoOutput {
    private var photoData: Data?
    
    private(set) var videoPortConnection: AVCaptureConnection?
    
    var onPhotoCaptureSuccess: ((Data) -> Void)?
    var onPhotoCaptureError: ((CameraError) -> Void)?
    
    func capturePhoto(_ flashMode: FlashMode,
                      redEyeCorrection: Bool) {
        var photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = flashMode.avFlashOption
        photoSettings.isAutoRedEyeReductionEnabled = redEyeCorrection
        
        if availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        capturePhoto(with: photoSettings, delegate: self)
    }
    
    func configurePhotoOutput(forSession session: CaptureSession,
                              andOptions options: CameraComponentParsedOptions,
                              videoDevice: VideoCaptureDevice,
                              isFlipped: Bool) -> Bool {
        let camera = isFlipped ? options.flipCameraDevice : options.cameraDevice
        guard session.canAddOutput(self) else { return false }
        session.addOutputWithNoConnections(self)
        maxPhotoQualityPrioritization = options.photoQualityPrioritizationMode
        
        let photoConnection = AVCaptureConnection(inputPorts: [videoDevice.videoDevicePort], output: self)
        guard session.canAddConnection(photoConnection) else { return false }
        session.addConnection(photoConnection)
        photoConnection.videoOrientation = options.cameraOrientation
        photoConnection.isVideoMirrored = camera.avDevicePosition == .front
        self.videoPortConnection = photoConnection
        
        return true
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension PhotoOutput: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else {
            onPhotoCaptureError?(.cameraComponentError(reason: .failedToOutputPhoto(message: error?.localizedDescription)))
            return
        }
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        guard error == nil, let photoData else {
            onPhotoCaptureError?(.cameraComponentError(reason: .failedToOutputPhoto(message: error?.localizedDescription)))
            return
        }
        onPhotoCaptureSuccess?(photoData)
    }
}
