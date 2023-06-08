//
//  CameraComposer.swift
//  
//
//  Created by Lobont Andrei on 30.05.2023.
//

import UIKit

final class CameraComposer: UIView, CameraComposerProtocol {
    private var sessionComposer: SessionComposerProtocol
    private let sessionQueue = DispatchQueue(label: "LA.cameraKage.sessionQueue")
    private var cameraComponent: CameraComponent!
    
    var isSessionRunning: Bool { sessionComposer.isSessionRunning }
    var isRecording: Bool { cameraComponent.isRecording }
    
    weak var delegate: CameraComposerDelegate?
    
    init(sessionComposer: SessionComposerProtocol = SessionComposer()) {
        self.sessionComposer = sessionComposer
        super.init(frame: .zero)
        self.sessionComposer.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("Using custom init")
    }
    
    func startCameraSession(with options: CameraComponentParsedOptions) {
        setupCameraComponent(with: options)
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.sessionComposer.startSession()
        }
    }
    
    func stopCameraSession() {
        destroyCameraComponent()
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.sessionComposer.stopSession()
        }
    }
    
    func capturePhoto(_ flashOption: FlashMode, redEyeCorrection: Bool) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.cameraComponent.capturePhoto(flashOption, redEyeCorrection: redEyeCorrection)
        }
    }
    
    func startVideoRecording() {
        sessionQueue.async { [weak self] in
            guard let self, !self.isRecording else { return }
            self.cameraComponent.startMovieRecording()
        }
    }
    
    func stopVideoRecording() {
        sessionQueue.async { [weak self] in
            guard let self, self.isRecording else { return }
            self.cameraComponent.stopMovieRecording()
        }
    }
    
    func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let self, !self.isRecording else { return }
            self.sessionComposer.pauseSession()
            self.cameraComponent.flipCamera()
            self.sessionComposer.resumeSession()
        }
    }
    
    func adjustFocusAndExposure(with focusMode: FocusMode,
                                exposureMode: ExposureMode,
                                at devicePoint: CGPoint,
                                monitorSubjectAreaChange: Bool) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.cameraComponent.focus(with: focusMode,
                                  exposureMode: exposureMode,
                                  at: devicePoint,
                                  monitorSubjectAreaChange: monitorSubjectAreaChange)
        }
    }
    
    private func setupCameraComponent(with options: CameraComponentParsedOptions) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let cameraCreationResult = self.sessionComposer.createCamera(options)
            switch cameraCreationResult {
            case .success(let camera):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.cameraComponent = CameraComponent(camera: camera)
                    camera.delegate = self
                    self.addSubview(self.cameraComponent)
                    self.cameraComponent.layoutToFill(inView: self)
                }
            case .failure(let error):
                self.delegate?.cameraComposer(self, didReceiveError: error)
            }
        }
    }
    
    private func destroyCameraComponent() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.cameraComponent.removeFromSuperview()
            self.cameraComponent = nil
        }
    }
}

// MARK: - SessionComposerDelegate
extension CameraComposer: SessionComposerDelegate {
    func sessionComposer(_ sessionComposer: SessionComposerProtocol, didReceiveRuntimeError error: CameraError, shouldRestartCamera restart: Bool) {
        if restart {
            sessionQueue.async {
                sessionComposer.resumeSession()
            }
        }
        delegate?.cameraComposer(self, didReceiveError: error)
    }
    
    func sessionComposer(_ sessionComposer: SessionComposerProtocol, didReceiveSessionInterruption reason: SessionInterruptionReason) {
        delegate?.cameraComposer(self, didReceiveSessionInterruption: reason)
    }
    
    func sessionComposerDidFinishSessionInterruption(_ sessionComposer: SessionComposerProtocol) {
        delegate?.cameraComposerDidFinishSessionInterruption(self)
    }
    
    func sessionComposerDidStartCameraSession(_ sessionComposer: SessionComposerProtocol) {
        delegate?.cameraComposerDidStartCameraSession(self)
    }
    
    func sessionComposerDidStopCameraSession(_ sessionComposer: SessionComposerProtocol) {
        delegate?.cameraComposerDidStopCameraSession(self)
    }
    
    func sessionComposerDidChangeDeviceAreaOfInterest(_ sessionComposer: SessionComposerProtocol) {
        delegate?.cameraComposerDidChangeDeviceAreaOfInterest(self)
    }
}

// MARK: - CameraComponentDelegate
extension CameraComposer: CameraDelegate {
    func camera(_ camera: Camera, didCapturePhoto photo: Data) {
        delegate?.cameraComposer(self, didCapturePhoto: photo)
    }
    
    func camera(_ camera: Camera, didStartRecordingVideo atFileURL: URL) {
        delegate?.cameraComposer(self, didStartRecordingVideo: atFileURL)
    }
    
    func camera(_ camera: Camera, didRecordVideo videoURL: URL) {
        delegate?.cameraComposer(self, didRecordVideo: videoURL)
    }
    
    func camera(_ camera: Camera, didZoomAtScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat) {
        delegate?.cameraComposer(self, didZoomAtScale: scale, outOfMaximumScale: maxScale)
    }
    
    func camera(_ camera: Camera, didFail withError: CameraError) {
        delegate?.cameraComposer(self, didReceiveError: withError)
    }
}
