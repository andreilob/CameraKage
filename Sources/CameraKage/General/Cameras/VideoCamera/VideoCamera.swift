//
//  VideoCamera.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation

class VideoCamera: InteractableCamera, VideoCameraInterface {
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
    
    init(session: Session,
         videoInput: VideoInput,
         videoLayer: VideoLayer,
         movieCapturer: MovieCapturer,
         options: CameraComponentParsedOptions) {
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
            try videoLayer.reloadPreviewLayer()
        } catch let error {
            throw error
        }
    }
    
    func startVideoRecording() {
        movieCapturer.startMovieRecording()
    }
    
    func stopVideoRecording() {
        movieCapturer.stopMovieRecording()
    }
}
