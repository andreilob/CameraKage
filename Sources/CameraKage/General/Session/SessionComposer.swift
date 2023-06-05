//
//  SessionComposer.swift
//  CameraKage
//
//  Created by Lobont Andrei on 26.05.2023.
//

import AVFoundation

final class SessionComposer: SessionComposerProtocol {
    private let session: AVCaptureMultiCamSession
    
    var isSessionRunning: Bool { session.isRunning }
    
    weak var delegate: SessionComposerDelegate?
    
    init(session: AVCaptureMultiCamSession = AVCaptureMultiCamSession()) {
        self.session = session
    }
    
    func startSession() {
        addObservers()
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
        removeObservers()
    }
    
    func pauseSession() {
        session.stopRunning()
    }
    
    func resumeSession() {
        session.startRunning()
    }
    
    func createCamera(_ options: CameraComponentParsedOptions) -> Result<Camera, CameraError> {
        do {
            guard let camera = try Camera(session: session, options: options) else {
                return .failure(.cameraComponentError(reason: .failedToComposeCamera))
            }
            return .success(camera)
        } catch let error as CameraError {
            return .failure(error)
        } catch {
            return .failure(.cameraComponentError(reason: .failedToComposeCamera))
        }
    }
}

// MARK: - Notifications
extension SessionComposer {
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionDidStartRunning),
                                               name: .AVCaptureSessionDidStartRunning,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionDidStopRunning),
                                               name: .AVCaptureSessionDidStopRunning,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceSubjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: session)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        let cameraError = CameraError.cameraSessionError(reason: .runtimeError(error))
        delegate?.sessionComposer(self,
                                  didReceiveRuntimeError: cameraError,
                                  shouldRestartCamera: error.code == .mediaServicesWereReset)
    }
    
    @objc private func sessionDidStartRunning(notification: NSNotification) {
        delegate?.sessionComposerDidStartCameraSession(self)
    }
    
    @objc private func sessionDidStopRunning(notification: NSNotification) {
        delegate?.sessionComposerDidStopCameraSession(self)
    }
    
    /// This will be called anytime there is another app that tries to use the audio or video devices
    /// Removing that device will unfreeze the camera but video will be corrupted (couldn't find a reason yet)
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        guard let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
              let reasonIntegerValue = userInfoValue.integerValue,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) else { return }
        var interruptionReason: SessionInterruptionReason
        switch reason {
        case .videoDeviceNotAvailableInBackground:
            interruptionReason = .videoDeviceNotAvailableInBackground
        case .audioDeviceInUseByAnotherClient:
            interruptionReason = .audioDeviceInUseByAnotherClient
        case .videoDeviceInUseByAnotherClient:
            interruptionReason = .videoDeviceInUseByAnotherClient
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            interruptionReason = .videoDeviceNotAvailableWithMultipleForegroundApps
        case .videoDeviceNotAvailableDueToSystemPressure:
            interruptionReason = .videoDeviceNotAvailableDueToSystemPressure
        @unknown default:
            interruptionReason = .unknown
        }
        delegate?.sessionComposer(self, didReceiveSessionInterruption: interruptionReason)
    }
    
    /// This will be called anytime the problem with the session was solved
    /// Entering in this method dosen't necessarly means that the call or the other application that invoked the problem was closed
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        delegate?.sessionComposerDidFinishSessionInterruption(self)
    }
    
    @objc private func deviceSubjectAreaDidChange(notification: NSNotification) {
        delegate?.sessionComposerDidChangeDeviceAreaOfInterest(self)
    }
}
