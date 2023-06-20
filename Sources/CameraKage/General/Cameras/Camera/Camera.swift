//
//  Camera.swift
//  
//
//  Created by Lobont Andrei on 15.06.2023.
//

import Foundation

class Camera: InteractableCamera, CameraInterface {
    private var photoCapturer: PhotoCapturer
    private var movieCapturer: MovieCapturer
    
    var isRecording: Bool { movieCapturer.isRecording }
    
    var onMovieCaptureSuccess: ((URL) -> Void)? {
        didSet {
            movieCapturer.onMovieCaptureSuccess = onMovieCaptureSuccess
        }
    }
    var onMovieCaptureStart: ((URL) -> Void)? {
        didSet {
            movieCapturer.onMovieCaptureStart = onMovieCaptureStart
        }
    }
    var onMovieCaptureError: ((CameraError) -> Void)? {
        didSet {
            movieCapturer.onMovieCaptureError = onMovieCaptureError
        }
    }
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
         movieCapturer: MovieCapturer,
         options: CameraComponentParsedOptions) {
        self.photoCapturer = photoCapturer
        self.movieCapturer = movieCapturer
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
            try movieCapturer.handleFlip()
            try photoCapturer.handleFlip()
            try videoLayer.reloadPreviewLayer()
        } catch let error {
            throw error
        }
    }
    
    func capturePhoto(_ flashOption: FlashMode, redEyeCorrection: Bool) {
        photoCapturer.capturePhoto(flashOption, redEyeCorrection: redEyeCorrection)
    }
    
    func startVideoRecording() {
        movieCapturer.startMovieRecording()
    }
    
    func stopVideoRecording() {
        movieCapturer.stopMovieRecording()
    }
}
