//
//  PhotoCamera.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation

class PhotoCamera: BaseCamera, PhotoCameraInterface {
    private var photoCapturer: PhotoCapturer
    
    var onPhotoCaptureSuccess: ((Data) -> Void)? {
        didSet {
            photoCapturer.onPhotoCaptureSuccess = onPhotoCaptureSuccess
        }
    }
    var onPhotoCaptureError: ((CameraError) -> Void)? {
        didSet {
            photoCapturer.onPhotoCaptureError = onPhotoCaptureError
        }
    }
    
    init(session: Session,
         videoInput: VideoInput,
         videoLayer: VideoLayer,
         photoCapturer: PhotoCapturer,
         options: CameraComponentParsedOptions) {
        self.photoCapturer = photoCapturer
        super.init(session: session,
                   videoInput: videoInput,
                   videoLayer: videoLayer,
                   options: options)
    }
    
    override func flipCamera() throws {
        defer {
            session.commitConfiguration()
        }
        session.beginConfiguration()
        do {
            try super.flipCamera()
            try photoCapturer.handleFlip()
            try videoLayer.reloadPreviewLayer()
        } catch let error {
            throw error
        }
    }
    
    func capturePhoto(_ flashOption: FlashMode, redEyeCorrection: Bool) {
        photoCapturer.capturePhoto(flashOption, redEyeCorrection: redEyeCorrection)
    }
}
