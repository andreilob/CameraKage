//
//  Camera.swift
//  
//
//  Created by Lobont Andrei on 30.05.2023.
//

import Foundation
import QuartzCore.CALayer

class Camera {
    let session: CaptureSession
    let options: CameraComponentParsedOptions
    
    private let videoDevice: VideoCaptureDevice
    private let audioDevice: AudioCaptureDevice
    private let photoOutput: PhotoOutput
    private let movieOutput: MovieOutput
    private let previewLayer: PreviewLayer
    private var lastZoomFactor: CGFloat = 1.0
    private var isFlipped = false
    
    var allowsPinchZoom: Bool { options.pinchToZoomEnabled }
    var isRecording: Bool { movieOutput.isRecording }
    
    weak var delegate: CameraDelegate?
    
    init?(session: CaptureSession,
          options: CameraComponentParsedOptions,
          videoDevice: VideoCaptureDevice = VideoCaptureDevice(),
          audioDevice: AudioCaptureDevice = AudioCaptureDevice(),
          photoOutput: PhotoOutput = PhotoOutput(),
          movieOutput: MovieOutput = MovieOutput(),
          previewLayer: PreviewLayer = PreviewLayer()) {
        self.session = session
        self.options = options
        self.videoDevice = videoDevice
        self.audioDevice = audioDevice
        self.photoOutput = photoOutput
        self.movieOutput = movieOutput
        self.previewLayer = previewLayer
        
        do {
            try configureSession()
        } catch let error as CameraError {
            delegate?.camera(self, didFail: error)
            return nil
        } catch {
            delegate?.camera(self, didFail: .cameraComponentError(reason: .failedToComposeCamera))
            return nil
        }
    }
    
    deinit {
        videoDevice.removeObserver()
    }
    
    func embedPreviewLayer(in layer: CALayer) {
        layer.addSublayer(previewLayer)
    }
    
    func setPreviewLayerFrame(frame: CGRect) {
        previewLayer.bounds = frame
        previewLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    func capturePhoto(_ flashMode: FlashMode, redEyeCorrection: Bool) {
        photoOutput.capturePhoto(flashMode, redEyeCorrection: redEyeCorrection)
    }
    
    func startMovieRecording() {
        movieOutput.startMovieRecording()
    }
    
    func stopMovieRecording() {
        movieOutput.stopMovieRecording()
    }
    
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {
        let point = previewLayer.captureDevicePointConverted(fromLayerPoint: devicePoint)
        do {
            try videoDevice.focus(with: focusMode,
                                  exposureMode: exposureMode,
                                  at: point,
                                  monitorSubjectAreaChange: monitorSubjectAreaChange)
        } catch let error as CameraError {
            delegate?.camera(self, didFail: error)
        } catch {
            delegate?.camera(self, didFail: .cameraComponentError(reason: .failedToLockDevice))
        }
    }
    
    func flipCamera() {
        do {
            isFlipped.toggle()
            DispatchQueue.main.async {
                self.previewLayer.removeFromSuperlayer()
            }
            videoDevice.removeObserver()
            session.cleanupSession()
            try configureSession()
            videoDevice.addObserver()
        } catch let error as CameraError {
            delegate?.camera(self, didFail: error)
        } catch {
            delegate?.camera(self, didFail: .cameraComponentError(reason: .failedToLockDevice))
        }
    }
    
    func zoom(atScale: CGFloat) {
        lastZoomFactor = videoDevice.minMaxZoom(atScale * lastZoomFactor, with: options)
        do {
            try videoDevice.zoom(atScale: lastZoomFactor)
        } catch let error as CameraError {
            delegate?.camera(self, didFail: error)
        } catch {
            delegate?.camera(self, didFail: .cameraComponentError(reason: .failedToLockDevice))
        }
    }
    
    private func configureSession() throws {
        defer {
            session.commitConfiguration()
        }
        session.beginConfiguration()
        
        guard configureVideoDevice() else {
            throw CameraError.cameraComponentError(reason: .failedToConfigureVideoDevice)
        }
        guard configureAudioDevice() else {
            throw CameraError.cameraComponentError(reason: .failedToConfigureAudioDevice)
        }
        guard configureMovieOutput() else {
            throw CameraError.cameraComponentError(reason: .failedToAddMovieOutput)
        }
        guard configurePhotoOutput() else {
            throw CameraError.cameraComponentError(reason: .failedToAddPhotoOutput)
        }
        guard configurePreviewLayer() else {
            throw CameraError.cameraComponentError(reason: .failedToAddPreviewLayer)
        }
    }
    
    private func configureVideoDevice() -> Bool {
        let configurationResult = videoDevice.configureVideoDevice(forSession: session,
                                                                   andOptions: options,
                                                                   isFlipped: isFlipped)
        videoDevice.addObserver()
        videoDevice.onVideoDeviceError = { [weak self] error in
            guard let self else { return }
            delegate?.camera(self, didFail: error)
        }
        
        return configurationResult
    }
    
    private func configureAudioDevice() -> Bool {
        audioDevice.configureAudioDevice(forSession: session,
                                               andOptions: options,
                                               isFlipped: isFlipped)
    }
    
    private func configureMovieOutput() -> Bool {
        let configurationResult = movieOutput.configureMovieFileOutput(forSession: session,
                                                                       andOptions: options,
                                                                       videoDevice: videoDevice,
                                                                       audioDevice: audioDevice,
                                                                       isFlipped: isFlipped)
        
        movieOutput.onMovieCaptureStart = { [weak self] url in
            guard let self else { return }
            delegate?.camera(self, didStartRecordingVideo: url)
        }
        movieOutput.onMovieCaptureSuccess = { [weak self] url in
            guard let self else { return }
            delegate?.camera(self, didRecordVideo: url)
        }
        movieOutput.onMovieCaptureError = { [weak self] error in
            guard let self else { return }
            delegate?.camera(self, didFail: error)
        }
        
        return configurationResult
    }
    
    private func configurePhotoOutput() -> Bool {
        let configurationResult = photoOutput.configurePhotoOutput(forSession: session,
                                                                   andOptions: options,
                                                                   videoDevice: videoDevice,
                                                                   isFlipped: isFlipped)
        
        photoOutput.onPhotoCaptureSuccess = { [weak self] data in
            guard let self else { return }
            delegate?.camera(self, didCapturePhoto: data)
        }
        photoOutput.onPhotoCaptureError = { [weak self] error in
            guard let self else { return }
            delegate?.camera(self, didFail: error)
        }
        
        return configurationResult
    }
    
    private func configurePreviewLayer() -> Bool {
        previewLayer.configurePreviewLayer(forSession: session,
                                                 andOptions: options,
                                                 videoDevice: videoDevice)
    }
}
